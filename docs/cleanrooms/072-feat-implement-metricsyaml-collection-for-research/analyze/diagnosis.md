---
id: diagnosis
title: "Diagnóstico: recolección prospectiva de metrics.yaml con almacenamiento dual"
date: 2025-07-18
status: active
tags: [diagnosis, metrics, architecture, dual-storage, darwin, transition-contract]
author: socrates
---

# Diagnóstico — Issue #72: metrics.yaml collection

## 1. Definición del problema

El paper de investigación (`docs/research/ape_builds_ape/bootstrap-validation.md`) necesita datos empíricos estructurados para ser creíble. Sin métricas por ciclo, el paper es opinión, no contribución. El review-log reporta reproducibilidad = 2/10.

El esquema ya existe (`docs/research/ape_builds_ape/metrics-schema.md`): 17 campos, solo `issue` obligatorio. Lo que falta es el **mecanismo de recolección** — cómo, cuándo y quién genera `metrics.yaml` dentro del ciclo APE.

### Pivote de alcance

El issue #72 original proponía tres fases: (1) métricas retroactivas para 7 issues históricos, (2) proceso de recolección prospectiva, (3) automatización CLI. El análisis reveló que la Fase 1 es inviable sin fabricar datos y la Fase 3 es trabajo futuro. El alcance se reduce a la **Fase 2: mecanismo de recolección prospectiva**, con una arquitectura de almacenamiento dual que resuelve las restricciones de DARWIN.

---

## 2. Registro de decisiones

13 decisiones tomadas en 5 rondas de indagación socrática. D10 fue supersedida por D11.

### Decisiones de alcance (qué entra, qué no)

| ID | Decisión | Justificación |
|----|----------|---------------|
| D1 | Solo métricas para issues con directorio existente | Ghost issues (#55, #61, #67) no tienen artefactos; no crear directorios retroactivamente |
| D5 | No fabricar datos históricos; foco prospectivo | Los datos perdidos (delta_failures, tests) no se inventan |
| D13 | Eliminar retroactivos del alcance; actualizar acceptance criteria | Complicación innecesaria; las métricas serán más útiles con APE maduro |

### Decisiones de calidad y nomenclatura

| ID | Decisión | Justificación |
|----|----------|---------------|
| D2 | Sin umbral mínimo de campos — aprender iterativamente | La métrica enseña qué es útil; no definir a priori |
| D3 | NNN es placeholder; norma estricta going forward | Inconsistencia histórica aceptada tal cual |

### Decisiones de arquitectura

| ID | Decisión | Justificación |
|----|----------|---------------|
| D4 | No extraer tests históricos; recolectar en tiempo real | Integrar en el ciclo APE, no en scripts retroactivos |
| D6 | Recolección condicionada a `evolution: enabled: true` | No intrusivo con usuarios que no necesitan métricas |
| D7 | Madurez: manual → orquestador → CLI | Etapa 1 es orquestador (prompt); etapa 3 es `ape metrics collect` |
| D8 | Capturar `tests.before` al inicio del ciclo, aunque sea impreciso | Mejor dato aproximado que ninguno; snapshot en IDLE → ANALYZE |
| D9 | Declarar `collect_metrics` en `transition_contract.yaml` | Señal de intención sin executor; consistente con effects existentes |
| D11 | Almacenamiento dual: `.ape/` siempre, `docs/` condicional | DARWIN escribe en `.ape/`; copia a `docs/` solo si `evolution=true` AND repo es `finite_ape_machine` |
| D12 | metrics.yaml solo para ciclos completos (que alcanzan EVOLUTION) | Artefacto de condiciones de laboratorio; ciclos parciales no producen datos |

### Decisión supersedida

| ID | Decisión original | Reemplazada por |
|----|-------------------|-----------------|
| D10 | DARWIN escribe metrics.yaml; constraint = no `code/*` ni `docs/*` | D11 (almacenamiento dual resuelve la contradicción topológica) |

---

## 3. Arquitectura

### 3.1 Almacenamiento dual (D11)

```
┌─────────────────────────────────────────────────────────┐
│                     DARWIN genera                        │
│                  .ape/metrics.yaml                       │
│              (siempre, si evolution=true)                │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
              ┌─────────────────────┐
              │  ¿remote origin =   │
              │  finite_ape_machine?│
              └────┬──────────┬─────┘
                   │ Sí       │ No
                   ▼          ▼
    ┌──────────────────────┐  ┌──────────────────┐
    │ COPIAR a:            │  │ Solo .ape/       │
    │ docs/issues/<slug>/  │  │ (gitignored)     │
    │   metrics.yaml       │  │ Fin del flujo    │
    │ (committed al PR)    │  └──────────────────┘
    └──────────────────────┘
```

**Propiedad de escritura:**
- DARWIN escribe **exclusivamente** en `.ape/metrics.yaml`
- El constraint de DARWIN (`ape.agent.md:487`) permanece intacto: "Never modify the project's code or documentation"
- `.ape/` no es code ni documentation — es espacio de trabajo del framework
- La copia a `docs/` es un side-effect del flujo de transición, no una acción de DARWIN

### 3.2 Captura en dos puntos (D8 + D12)

```
IDLE ──────────► ANALYZE ──────► PLAN ──────► EXECUTE ──────► EVOLUTION ──────► IDLE
  │                                                              │
  │ Punto 1:                                                     │ Punto 2:
  │ snapshot_metrics                                             │ collect_metrics
  │ - tests.before                                               │ - todos los campos
  │ - timing.branch_created                                      │ - consolida snapshot
  │ → guarda en .ape/                                            │ → genera .ape/metrics.yaml
  │   metrics_snapshot.yaml                                      │ → copia condicional a docs/
```

**Campos y momento de captura:**

| Campo | Punto de captura | Mecanismo |
|-------|-----------------|-----------|
| `issue` | Punto 2 | `.ape/state.yaml → cycle.task` |
| `version` | Punto 2 | `pubspec.yaml` o `lib/src/version.dart` |
| `model` | Punto 2 | Self-report del agente |
| `agent` | Punto 2 | Contexto del runtime |
| `cycle.completed` | Punto 2 | Implícito (si llega a EVOLUTION = true) |
| `cycle.darwin_activated` | Punto 2 | Implícito (si está en EVOLUTION = true) |
| `cycle.darwin_issue` | Punto 2 | Output de DARWIN (`gh issue create`) |
| `timing.branch_created` | Punto 1 | `git log --reverse --format=%aI` |
| `timing.pr_merged` | Post-ciclo | `gh pr view --json mergedAt` (asíncrono) |
| `plan.total_phases` | Punto 2 | `grep -c "^### " plan.md` |
| `plan.completed_phases` | Punto 2 | `grep -c "\[x\]" plan.md` |
| `plan.deviations` | Punto 2 | Comparación manual o inferida |
| `tests.before` | **Punto 1** | `grep -rc 'test(' test/` o `dart test --reporter json` |
| `tests.after` | Punto 2 | Mismo mecanismo que `tests.before` |
| `tests.delta` | Punto 2 | Derivado: `after - before` |
| `delta_failures.count` | Punto 2 | Self-report del agente |
| `observations` | Punto 2 | Freeform del agente o usuario |

### 3.3 Integración con DARWIN

DARWIN ya recibe los artefactos del ciclo (`ape.agent.md:468-474`): `diagnosis.md`, `plan.md`, `retrospective.md`, `.ape/mutations.md`, commit history. Estos son los mismos datos necesarios para poblar `metrics.yaml`.

**Flujo propuesto dentro de EVOLUTION:**
1. DARWIN evalúa el ciclo (comportamiento actual — sin cambios)
2. DARWIN genera `.ape/metrics.yaml` usando los artefactos recibidos + queries a git/GitHub
3. DARWIN busca/crea issues en `finite_ape_machine` (comportamiento actual)
4. Side-effect: si `remote = finite_ape_machine`, copiar `.ape/metrics.yaml` → `docs/issues/<slug>/metrics.yaml`
5. Transición EVOLUTION → IDLE

### 3.4 Hooks en el contrato de transiciones (D9)

**Modificaciones a `transition_contract.yaml`:**

| Transición | Effect a agregar | Propósito |
|-----------|-----------------|-----------|
| IDLE → ANALYZE | `snapshot_metrics` | Capturar `tests.before`, `timing.branch_created` en `.ape/metrics_snapshot.yaml` |
| EVOLUTION → IDLE | `collect_metrics` | Señal para generar `metrics.yaml` final; consolidar snapshot + datos finales |

Estos effects son **declarativos** — consistentes con el patrón existente donde `finalize_execution`, `close_cycle`, `reset_mutations` son etiquetas interpretadas por el orquestador, no funciones ejecutadas por el CLI (ver `transition.dart:167-171`).

---

## 4. Restricciones

### 4.1 Restricción de DARWIN (invariante)

```
DARWIN NUNCA modifica code/* ni docs/*.
DARWIN escribe EXCLUSIVAMENTE en .ape/.
```

Fuentes: `ape.agent.md:174`, `ape.agent.md:487`.
Resolución: D11 — escritura en `.ape/`, copia condicional como side-effect del flujo.

### 4.2 Gate de activación (D6)

```
metrics.yaml se genera SOLO si .ape/config.yaml → evolution.enabled = true.
```

La recolección no es intrusiva. Proyectos que no habilitan evolution no ven ningún cambio en su flujo.

### 4.3 Gate de completitud (D12)

```
metrics.yaml se genera SOLO para ciclos que alcanzan EVOLUTION.
Ciclos abortados o parciales NO producen métricas.
```

Precondiciones: el ciclo transitó IDLE → ANALYZE → PLAN → EXECUTE → EVOLUTION.

### 4.4 Gate de repositorio (D11)

```
La copia a docs/issues/<slug>/metrics.yaml SOLO ocurre si:
  remote origin ≈ ccisnedev/finite_ape_machine
```

Esto asegura que la copia committed solo existe en el repo de investigación.

---

## 5. Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|-------------|---------|-----------|
| `tests.before` impreciso por timing de snapshot | Media | Bajo | D8 acepta imprecisión; el dato aproximado es mejor que nada |
| `timing.pr_merged` no disponible al momento de generar métricas (PR aún no mergeado) | Alta | Bajo | Campo se deja vacío; se puede llenar post-merge con script futuro |
| DARWIN olvida generar `metrics.yaml` (es un LLM, no es determinista) | Media | Medio | El prompt debe ser explícito; validación post-ciclo podría detectar ausencia |
| Effects declarativos sin executor acumulan deuda técnica | Baja | Bajo | Deuda aceptada (D7/D9); el executor es trabajo de etapa 3 |
| Detección de remote origin frágil si el usuario usa múltiples remotes | Baja | Bajo | Usar `git remote get-url origin` y comparar con patrón; documentar supuesto |
| El esquema actual no cubre campos que resulten necesarios | Media | Bajo | D2: sin umbral mínimo; el esquema puede evolucionar |

---

## 6. Alcance

### DENTRO del alcance de este issue

1. **Modificar `ape.agent.md`** — Instrucciones a DARWIN para generar `.ape/metrics.yaml` durante EVOLUTION
2. **Modificar `transition_contract.yaml`** — Agregar effects `snapshot_metrics` (IDLE → ANALYZE) y `collect_metrics` (EVOLUTION → IDLE)
3. **Validar `metrics-schema.md`** — Confirmar que el esquema existente es consistente con la arquitectura decidida (actualizar si es necesario, ej: la nota "created at cycle end" debe reflejar la captura en dos puntos)
4. **Documentar el proceso de recolección** — Cuándo, quién, cómo se genera `metrics.yaml`
5. **Definir lógica de copia condicional** — `.ape/` → `docs/issues/<slug>/` cuando `evolution=true` AND `remote = finite_ape_machine`
6. **Actualizar prompt de DARWIN** — Agregar instrucción de generación de métricas y constraint de escritura en `.ape/`
7. **Actualizar acceptance criteria** — Reflejar el alcance pivotado

### FUERA del alcance

1. ~~Archivos `metrics.yaml` retroactivos para issues #51, #55, #58, #61, #66, #67, #68~~ (D13)
2. Comando `ape metrics collect` — etapa 3 de D7, issue futuro
3. Comando `ape metrics summary` — etapa 3 de D7, issue futuro
4. Effect executor en `transition.dart` — infraestructura CLI futura
5. Cambios a `ape init` o defaults de `.ape/config.yaml`
6. Dashboards, visualización o agregación de métricas
7. Creación de directorios para issues históricos sin directorio

---

## 7. Acceptance criteria actualizados

Los siguientes criterios reemplazan los originales del issue #72:

- [ ] `transition_contract.yaml` declara effect `snapshot_metrics` en transición IDLE → ANALYZE
- [ ] `transition_contract.yaml` declara effect `collect_metrics` en transición EVOLUTION → IDLE
- [ ] `ape.agent.md` incluye instrucciones para que DARWIN genere `.ape/metrics.yaml` durante EVOLUTION
- [ ] `ape.agent.md` actualiza el constraint de DARWIN para reflejar que puede escribir en `.ape/`
- [ ] Documentado el mecanismo de copia condicional (`.ape/` → `docs/issues/<slug>/`) gated por `evolution=true` AND `remote = finite_ape_machine`
- [ ] `metrics-schema.md` actualizado para reflejar la arquitectura de captura en dos puntos (notas sobre `tests.before` snapshot)
- [ ] Proceso de recolección documentado: cuándo se toma el snapshot, cuándo se genera el archivo completo, quién es responsable en cada etapa de madurez (D7)

---

## 8. Referencias

### Documentos de análisis

| # | Documento | Contenido |
|---|-----------|-----------|
| 1 | [socratic-inquiry.md](socratic-inquiry.md) | R1: Clarificación — 5 lagunas identificadas, términos definidos |
| 2 | [socratic-inquiry-02.md](socratic-inquiry-02.md) | R2: Supuestos — Pivote de alcance detectado, D1-D5 |
| 3 | [socratic-inquiry-03.md](socratic-inquiry-03.md) | R3: Evidencia — Validación contra codebase, D6-D7, viabilidad |
| 4 | [socratic-inquiry-04.md](socratic-inquiry-04.md) | R4: Implicaciones — D8-D10, contradicciones cruzadas |
| 5 | [socratic-inquiry-05.md](socratic-inquiry-05.md) | R5: Meta-reflexión — D11-D13, evaluación de completitud |

### Artefactos del codebase referenciados

| Archivo | Relevancia |
|---------|-----------|
| `docs/research/ape_builds_ape/metrics-schema.md` | Esquema de 17 campos; fuente de verdad para la estructura de `metrics.yaml` |
| `code/cli/assets/agents/ape.agent.md` | Prompt del orquestador y de DARWIN; constraints de escritura |
| `code/cli/assets/fsm/transition_contract.yaml` | Contrato FSM; effects declarativos; hooks de transición |
| `code/cli/src/commands/transition.dart:167-171` | Evidencia de que effects son strings retornados, no ejecutados |
| `code/cli/src/commands/init.dart:160-163` | `ape init` crea `evolution: enabled: false` por defecto |
