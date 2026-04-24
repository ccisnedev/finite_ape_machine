---
id: socratic-inquiry-05
title: "Quinta indagación: meta-reflexión — D11, D12, D13 y evaluación de completitud"
date: 2025-07-18
status: completed
tags: [socratic, analysis, metrics, meta-reflection, dual-storage, scope-closure]
author: socrates
---

# Quinta Indagación Socrática — Issue #72

## Contexto

Esta es la fase de **META-REFLEXIÓN**: preguntas sobre las preguntas. Después de 4 rondas y 10 decisiones, el usuario resolvió las tres últimas implicaciones abiertas (P1, P2, P3 de `socratic-inquiry-04.md`). Las respuestas producen tres decisiones finales que cierran todos los hilos abiertos de la investigación.

El usuario señaló: *"Si luego de estas respuestas aún quedan pendientes, abordémoslos uno por uno"* — indicando que desea cerrar el análisis.

## Nuevas decisiones registradas

### D11: Arquitectura de almacenamiento dual

> "metrics.yaml siempre se guarda en .ape/ pero cuando evolution=true Y repo=finite_ape_machine, entonces se agrega una copia a docs/issues/<slug>/metrics.yaml."

**Lo que resuelve:** La contradicción topológica de D10 (P1 de `socratic-inquiry-04.md`). DARWIN no puede escribir en `docs/*`, pero `metrics.yaml` vive en `docs/issues/NNN-slug/`. La solución bifurca el almacenamiento:

| Ubicación | Condición | Persistencia | Propósito |
|-----------|-----------|-------------|-----------|
| `.ape/metrics.yaml` | Siempre (cuando `evolution: enabled`) | Efímera (gitignored) | Dato de trabajo para cualquier usuario/repo |
| `docs/issues/<slug>/metrics.yaml` | `evolution: enabled` AND `remote origin ≈ finite_ape_machine` | Permanente (committed) | Artefacto de investigación para el paper |

**Mecanismo implícito:**
1. DARWIN genera `metrics.yaml` en `.ape/` (su espacio permitido — no es `code/*` ni `docs/*`)
2. Una validación compara el remote origin del repo con el repo oficial (`ccisnedev/finite_ape_machine`)
3. Si hay match, se copia `.ape/metrics.yaml` → `docs/issues/<slug>/metrics.yaml`
4. La copia se incluye en el commit/PR del ciclo

**Consecuencias:**
- DARWIN nunca toca `docs/*` directamente — la copia es un side-effect del flujo, no una acción de DARWIN
- Usuarios en forks o repos externos nunca ven métricas en su commit — no es intrusivo (consistente con D6)
- El constraint de DARWIN (`ape.agent.md:487`) permanece intacto sin excepciones
- La contradicción topológica desaparece: DARWIN escribe en `.ape/`, el flujo copia a `docs/`

**Refinamiento de D10:** D11 reemplaza D10. La formulación original ("DARWIN puede escribir `metrics.yaml`; constraint = no `code/*` ni `docs/*`") tenía la contradicción. D11 la resuelve con la separación escritura/copia.

### D12: metrics.yaml solo para ciclos completos

> "Solo será útil un metrics.yaml completo. Es un artefacto de condiciones de laboratorio."

**Lo que resuelve:** P2 de `socratic-inquiry-04.md` — la arquitectura de dos puntos no cubre los puntos intermedios. Si un ciclo aborta en ANALYZE o EXECUTE, los datos intermedios (`plan.total_phases`, `tests.after`) no existen.

**Regla:** `metrics.yaml` solo se genera para ciclos que alcanzan EVOLUTION. Ciclos parciales o abortados no producen métricas.

**Precondiciones formales para generación de `metrics.yaml`:**
1. El ciclo debe haber pasado por IDLE → ANALYZE → PLAN → EXECUTE → EVOLUTION
2. `evolution: enabled: true` en `.ape/config.yaml`
3. DARWIN fue invocado (es decir, la transición `finish_execute` ocurrió)

**Consecuencias:**
- Elimina el problema de `metrics.yaml` parciales sin campos de plan o tests
- Simplifica la arquitectura: no hay que manejar estados intermedios inválidos
- `tests.before` (D8) solo tiene sentido si el ciclo llega a completion — el snapshot no se desperdicia
- Reduce el ruido: solo datos de "condiciones de laboratorio" llegan al dataset
- La implicación I3 de `socratic-inquiry-04.md` (evolution habilitada a mitad de ciclo) se vuelve irrelevante: si evolution no estaba habilitada desde el inicio, no hay snapshot de `tests.before`, ergo el ciclo no produce métricas completas

### D13: Eliminar métricas retroactivas del alcance

> "Archivos retroactivos es una complicación innecesaria. [...] Las métricas serán más útiles cuando APE esté más maduro."

**Lo que resuelve:** La tensión abierta desde la Ronda 2 (P3 de `socratic-inquiry-02.md`, repetida en P3 de `socratic-inquiry-04.md`). Los acceptance criteria del issue #72 piden 7 archivos `metrics.yaml` retroactivos. Las decisiones D1-D5 ya habían deprioritizado los datos históricos, pero la tensión con los criteria formales seguía abierta.

**Nuevo alcance:** El issue #72 NO entrega archivos retroactivos. Entrega:
1. Mecanismo de recolección prospectiva integrado en el ciclo APE
2. Validación del esquema `metrics-schema.md`
3. Arquitectura de almacenamiento dual (D11)
4. Hooks declarativos en el contrato de transiciones (D9)

**Consecuencia directa:** Los acceptance criteria del issue DEBEN actualizarse antes de pasar a PLAN. El `diagnosis.md` debe incluir los nuevos criteria.

## Meta-reflexión: evaluación de completitud

### ¿Quedan contradicciones sin resolver?

| Contradicción | Estado | Resolución |
|---------------|--------|-----------|
| DARWIN no puede escribir en `docs/*` pero `metrics.yaml` vive en `docs/` | ✅ Resuelta | D11: escritura en `.ape/`, copia condicional a `docs/` |
| Acceptance criteria piden 7 archivos retroactivos pero decisiones dicen "prospectivo" | ✅ Resuelta | D13: retroactivos eliminados del alcance; criteria se actualizan |
| `tests.before` no capturizable al final del ciclo | ✅ Resuelta | D8: snapshot al inicio; D12: solo ciclos completos |
| Effects declarativos sin executor en CLI | ✅ Aceptada | D7/D9: etapa 1-2 es orquestador, effects son señales de intención |
| Evolution habilitada a mitad de ciclo pierde `tests.before` | ✅ Disuelta | D12: solo ciclos completos; si no hay snapshot, no hay métricas |

**No quedan contradicciones abiertas.**

### ¿Hay decisiones que conflicten entre sí?

Revisión cruzada de las 13 decisiones:

- D1 (solo issues con directorio) + D13 (sin retroactivos) → Consistentes. D13 hace D1 irrelevante para este issue (no hay generación retroactiva).
- D6 (gated por evolution) + D11 (dual storage gated por evolution AND repo) → D11 es un refinamiento de D6. Consistentes.
- D8 (snapshot al inicio) + D12 (solo ciclos completos) → Consistentes. El snapshot se toma al inicio; si el ciclo no se completa, se descarta.
- D9 (effects declarativos) + D7 (madurez incremental) → Consistentes. D9 implementa la señal de D7 etapa 1.
- D10 (DARWIN escribe metrics) → **Supersedida por D11**. No hay conflicto porque D11 refina el mecanismo.

**No hay conflictos entre decisiones vigentes.**

### ¿El alcance está claramente delimitado?

**DENTRO del alcance:**
- Esquema `metrics-schema.md` (ya existe — validar, no reescribir)
- Effects `snapshot_metrics` y `collect_metrics` en `transition_contract.yaml`
- Instrucciones a DARWIN para generar `.ape/metrics.yaml`
- Lógica de copia condicional `.ape/` → `docs/issues/<slug>/`
- Actualización de `ape.agent.md` (prompt de DARWIN y reglas)
- Actualización de acceptance criteria del issue
- Documentación del proceso de recolección

**FUERA del alcance:**
- Archivos `metrics.yaml` retroactivos para issues históricos
- Comando `ape metrics collect` (CLI, etapa 3 de D7)
- Comando `ape metrics summary` (CLI, etapa 3 de D7)
- Effect executor en `transition.dart` (infraestructura CLI futura)
- Cambios a `ape init` o `.ape/config.yaml` defaults
- Dashboards o visualización de métricas

### Veredicto

**El análisis está COMPLETO.** Las 5 rondas han:
1. **Clarificado** términos y detectado lagunas (R1)
2. **Desafiado** supuestos y detectado el pivote de alcance (R2)
3. **Validado** contra evidencia del codebase (R3)
4. **Explorado** implicaciones cruzadas (R4)
5. **Cerrado** todas las contradicciones y delimitado el alcance (R5)

Se recomienda proceder a `diagnosis.md`.

## Registro completo de decisiones

| ID | Decisión | Justificación | Ronda |
|----|----------|---------------|-------|
| D1 | Solo métricas para issues con directorio existente | Ghost issues siempre existirán | R1 |
| D2 | Sin umbral mínimo — aprender iterativamente | La métrica enseña qué es útil | R1 |
| D3 | NNN es placeholder; norma estricta going forward | Inconsistencia histórica aceptada | R1 |
| D4 | No extraer tests históricos; recolectar en tiempo real | Integrar en el ciclo | R1 |
| D5 | No fabricar datos históricos; foco prospectivo | Hacia adelante, no atrás | R1 |
| D6 | Recolección condicionada a `evolution: enabled: true` | No intrusivo con usuarios | R2 |
| D7 | Madurez: manual → orquestador → CLI | Automatización incremental | R2 |
| D8 | Capturar `tests.before` al inicio, aunque sea impreciso | Mejor dato aproximado que ninguno | R3 |
| D9 | Declarar `collect_metrics` en contrato de transiciones | Señal declarativa de intención | R3 |
| D10 | ~~DARWIN escribe metrics.yaml; constraint = no code/*, no docs/*~~ | **Supersedida por D11** | R3 |
| D11 | Almacenamiento dual: `.ape/` siempre, `docs/` condicional | Resuelve contradicción topológica de D10 | R4 |
| D12 | metrics.yaml solo para ciclos completos (que alcanzan EVOLUTION) | Artefacto de condiciones de laboratorio | R4 |
| D13 | Eliminar retroactivos del alcance; actualizar acceptance criteria | Complicación innecesaria; foco prospectivo | R4 |
