---
id: socratic-inquiry-04
title: "Cuarta indagación: implicaciones de D8, D9, D10 — permisos, contratos y captura de datos"
date: 2025-07-18
status: active
tags: [socratic, analysis, metrics, implications, darwin-constraints, transition-contract, data-capture]
author: socrates
---

# Cuarta Indagación Socrática — Issue #72

## Contexto

Esta indagación entra en la fase de **IMPLICACIONES**. Las rondas anteriores clarificaron términos (ronda 1), desafiaron supuestos (ronda 2) y validaron contra evidencia del codebase (ronda 3). Ahora las 10 decisiones acumuladas forman un sistema coherente — pero todo sistema coherente tiene consecuencias no obvias.

Las tres decisiones nuevas (D8, D9, D10) tocan respectivamente: captura de datos, contrato de transiciones y permisos de escritura. Juntas, definen *cómo*, *cuándo* y *quién* para la recolección de métricas.

## Nuevas decisiones registradas

### D8: Capturar `tests.before` al inicio del ciclo, aunque sea impreciso

> "Sí, es mejor guardar el before aunque no sea exacto, que no tenerlo."

**Mecanismo implícito:** En la transición IDLE → ANALYZE, se debe tomar un snapshot del conteo de tests y almacenarlo en un lugar intermedio (¿`.ape/metrics_partial.yaml`? ¿una entrada en `state.yaml`?). Este dato se consolida al final cuando se genera `metrics.yaml`.

**Implicación directa:** Esto crea una arquitectura de **captura en dos puntos**:
- **Punto 1 (IDLE → ANALYZE):** snapshot de `tests.before`
- **Punto 2 (EXECUTE → EVOLUTION o EVOLUTION → IDLE):** recolección del resto + consolidación

Ningún otro dato del esquema requiere captura en dos tiempos. `tests.before` es el único campo que necesita estado intermedio persistente entre fases.

### D9: Declarar `collect_metrics` como effect en `transition_contract.yaml`

> "Supongo que es mejor al menos declararlo, es un avance que nos indica la dirección en la que queremos ir."

**Estado actual del contrato:**

Los effects existentes son etiquetas declarativas sin executor (`transition.dart:167-171` los retorna como strings). El contrato ya define:

| Transición | Effects actuales |
|-----------|-----------------|
| IDLE → ANALYZE | `open_analysis_context, reset_mutations` |
| EXECUTE → EVOLUTION | `finalize_execution` |
| EVOLUTION → IDLE | `close_cycle, reset_mutations` |

**Implicación directa:** Se añadirían effects como:
- `snapshot_metrics` en IDLE → ANALYZE (para D8)
- `collect_metrics` en EXECUTE → EVOLUTION o EVOLUTION → IDLE (para la consolidación)

Estos effects no tendrán executor en etapa 1-2 (D7). Son señales de intención — el contrato documenta *dónde* deberían engancharse las métricas, aunque solo el orquestador actúe sobre ellos inicialmente.

**Consistencia:** Esto es coherente con el patrón existente. `finalize_execution`, `close_cycle`, `reset_mutations` tampoco tienen implementación en Dart — todos son interpretados por el orquestador (el prompt del agente).

### D10: DARWIN puede escribir `metrics.yaml` — redefinición de constraint

> "metrics.yaml es propiedad de DARWIN. Lo único que no debe poder modificar DARWIN es code/* y tal vez docs/*."

**Constraint actual (dos fuentes):**

1. `ape.agent.md:174` — "DARWIN never modifies the project code or documentation — only creates issues/comments in the APE repo."
2. `ape.agent.md:487` (prompt de DARWIN) — "Never modify the project's code or documentation."

**Constraint propuesto:** "DARWIN nunca modifica `code/*` ni `docs/*` — excepto `docs/issues/NNN-slug/metrics.yaml`."

**Contradicción topológica:** `metrics.yaml` vive en `docs/issues/NNN-slug/`. Pero `docs/issues/` está **dentro** de `docs/`. La regla "no modificar docs/*" y "sí escribir docs/issues/NNN/metrics.yaml" son mutuamente excluyentes tal como están formuladas.

Esto requiere una de tres resoluciones:

1. **Exclusión explícita:** "Never modify `code/*` or `docs/*`, except `docs/issues/*/metrics.yaml`."
2. **Reclasificación:** Mover métricas fuera de `docs/` (e.g., `.ape/metrics/NNN.yaml` o `research/metrics/NNN.yaml`).
3. **Distinción semántica:** Definir que `docs/issues/*/` no es "documentation" sino "research artifacts" — y reformular la regla como "never modify project documentation or source code" con una definición clara de qué cuenta como documentación.

Cada opción tiene consecuencias diferentes para la claridad de las reglas y el riesgo de scope creep.

## Análisis de implicaciones cruzadas

### I1: D8 + D9 crean una arquitectura de captura en dos puntos — ¿pero qué pasa con los puntos intermedios?

El esquema define campos que solo son conocibles en momentos específicos:

| Campo | Momento más temprano en que es conocible |
|-------|----------------------------------------|
| `tests.before` | IDLE → ANALYZE (D8) |
| `plan.total_phases` | ANALYZE → PLAN (cuando se genera plan.md) |
| `plan.completed_phases` | Durante EXECUTE (evoluciona con cada fase) |
| `tests.after` | EXECUTE → EVOLUTION (tras último test) |
| `timing.pr_merged` | Post-EVOLUTION (asíncrono, fuera del ciclo) |

Una arquitectura de dos puntos (inicio + final) captura `tests.before` y `tests.after`. Pero `plan.total_phases` solo existe después de PLAN — capturarlo al inicio es imposible, capturarlo al final requiere leer un artefacto de una fase anterior.

**Consecuencia:** La "captura en dos puntos" funciona para la mayoría de campos, pero presupone que al final del ciclo todos los artefactos intermedios siguen disponibles (lo cual es cierto hoy: `plan.md` persiste en el filesystem). No es un problema ahora, pero es una fragilidad si los artefactos cambian de ubicación o formato.

### I2: D10 sin boundary exacto invita scope creep

Si DARWIN puede escribir `metrics.yaml` en `docs/issues/*/`, la pregunta inmediata es: ¿qué más puede escribir ahí? El directorio `docs/issues/NNN-slug/` contiene:
- `analyze/` (documentos de SOCRATES)
- `plan.md` (documento de DESCARTES)
- `retrospective.md` (documento del ciclo)
- `metrics.yaml` (propuesto para DARWIN)

La regla actual ("solo issues/comments en el repo") es **binaria y fácil de auditar**. La regla propuesta ("no code/*, no docs/*, excepto metrics.yaml") es una **allowlist con excepciones** — más difícil de auditar y más fácil de expandir progresivamente.

### I3: D6 + D8 juntas implican que el snapshot solo ocurre si evolution está habilitada

D6 dice: recolección gated por `evolution: enabled: true`. D8 dice: capturar `tests.before` en IDLE → ANALYZE. Pero si el gate es `evolution: enabled`, ¿se toma el snapshot al inicio de un ciclo donde evolution está habilitada? ¿Qué pasa si el usuario habilita evolution a mitad de ciclo? El `before` ya se perdió.

**Consecuencia:** El gate de D6 debería evaluarse en dos momentos, no solo al final. O aceptar que `tests.before` será `null` si evolution se habilitó después de IDLE → ANALYZE.

## Decisiones acumuladas

| ID | Decisión | Justificación |
|----|----------|---------------|
| D1 | Solo métricas para issues con directorio existente | Ghost issues siempre existirán |
| D2 | Sin umbral mínimo — aprender iterativamente | La métrica enseña qué es útil |
| D3 | NNN es placeholder; norma estricta going forward | Inconsistencia histórica aceptada |
| D4 | No extraer tests históricos; recolectar en tiempo real | Integrar en el ciclo |
| D5 | No fabricar datos históricos; foco prospectivo | Hacia adelante, no atrás |
| D6 | Recolección condicionada a `evolution: enabled: true` | No intrusivo con usuarios |
| D7 | Madurez: manual → orquestador → CLI | Automatización incremental |
| D8 | Capturar `tests.before` al inicio, aunque sea impreciso | Mejor dato aproximado que ninguno |
| D9 | Declarar `collect_metrics` en contrato aunque no haya executor | Señal declarativa de intención |
| D10 | DARWIN puede escribir `metrics.yaml`; constraint = no `code/*` ni `docs/*` | metrics.yaml es artefacto de investigación, no documentación |

## Preguntas socráticas — Fase de implicaciones

### P1: D10 — `docs/issues/*/metrics.yaml` está dentro de `docs/*`. ¿Cuál es la regla exacta?

Dijiste que DARWIN no debe modificar `code/*` ni `docs/*`. Pero `metrics.yaml` vive en `docs/issues/NNN-slug/` — que es un subdirectorio de `docs/`. Tal como está formulada, la regla se contradice a sí misma.

Hay tres formas de resolver esto (ver sección I2 arriba). Pero la elección tiene consecuencias: una exclusión explícita ("excepto metrics.yaml") es precisa pero crea precedente para más excepciones. Una reclasificación (mover métricas fuera de `docs/`) es limpia pero rompe la convención de "todo sobre un issue vive en su directorio". Una distinción semántica ("docs/issues/ no es documentación") requiere definir dónde termina "research artifact" y empieza "project documentation".

**Si hoy DARWIN puede escribir `metrics.yaml` en `docs/issues/*/`, ¿qué impide que mañana alguien argumente que `retrospective.md` también es un "artefacto de investigación" y DARWIN debería poder modificarlo?** ¿Cuál es el principio que traza la línea, no solo la regla?

### P2: D8 captura `tests.before`, D9 declara el hook — pero el plan solo existe después de PLAN. ¿Qué pasa con la fidelidad de plan?

La arquitectura de dos puntos (snapshot al inicio + consolidación al final) resuelve `tests.before/after`. Pero `plan.total_phases` y `plan.completed_phases` solo son conocibles *después* de que DESCARTES genere `plan.md`. No existen en IDLE → ANALYZE.

Hoy esto no es problema porque `plan.md` persiste en disco y se puede leer al final. Pero esta dependencia es implícita — ningún artefacto declara que "metrics.yaml depende de plan.md". Si un ciclo aborta en ANALYZE (nunca llega a PLAN), ¿se genera un `metrics.yaml` parcial sin campos de plan? ¿O no se genera nada?

**¿Las métricas son un artefacto de ciclos completos, o de cualquier ciclo que llegue a EVOLUTION?** Esto determina si `metrics.yaml` tiene precondiciones implícitas que deberían ser explícitas.

### P3: Los acceptance criteria del issue #72 siguen pidiendo 7 archivos retroactivos. Las decisiones D1-D5 dicen "foco prospectivo". Si construimos el mecanismo y no los 7 archivos, ¿qué hacemos con el issue?

Esta tensión lleva abierta desde la ronda 2 (P3 de `socratic-inquiry-02.md`, sin respuesta). Ahora hay 10 decisiones que asumen alcance prospectivo, pero el issue dice otra cosa.

Las consecuencias de no resolverlo:
- **Si no actualizamos criteria:** El issue técnicamente nunca se cierra. DARWIN evaluará el ciclo como "incompleto" porque los acceptance criteria no se cumplieron. Paradójicamente, la herramienta que D10 autoriza a escribir métricas reportará que el issue que la creó falló.
- **Si actualizamos criteria:** Cambiamos el alcance oficialmente. Pero el paper de investigación pierde los 7 puntos de datos históricos que motivaron el issue.
- **Si dividimos en dos issues:** Uno prospectivo (#72 reducido) y uno retroactivo (nuevo). Esto es limpio pero crea overhead.

**¿Cuál de estas tres opciones tiene el menor costo y el menor riesgo de deuda?**
