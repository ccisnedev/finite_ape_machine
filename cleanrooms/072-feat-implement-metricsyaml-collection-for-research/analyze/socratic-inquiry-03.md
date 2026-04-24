---
id: socratic-inquiry-03
title: "Tercera indagación: evidencia del codebase sobre viabilidad de recolección"
date: 2025-07-18
status: active
tags: [socratic, analysis, metrics, evidence, architecture, transitions]
author: socrates
---

# Tercera Indagación Socrática — Issue #72

## Contexto

Esta indagación procesa las respuestas de la Ronda 3 y las contrasta con **evidencia directa del codebase**. El usuario ha tomado decisiones claras (D6, D7). La tarea ahora es verificar si la arquitectura existente las soporta.

## Nuevas decisiones registradas

### D6: Recolección condicionada a `evolution: enabled: true`

> "Solo se recolectan si evolution=true. Existen independientemente pero no podemos ser intrusivos con el usuario."

**Evidencia del codebase:**
- `ape init` crea `.ape/config.yaml` con `evolution: enabled: false` por defecto (`init.dart:160-163`).
- `ape.agent.md:153` confirma: "If EVOLUTION is disabled (.ape/config.yaml → evolution.enabled: false), END transitions directly to IDLE after PR creation."
- El flag existe y es leído por el orquestador. La infraestructura de gating está en su lugar.

### D7: Madurez en tres etapas — manual → orquestador → CLI

> "Podemos hacer que APE el orquestador se encargue de esto inicialmente. Luego debe ser un ape o subagente el que se encargue, o tal vez mejor sea parte de los comandos ape para que ocurra programáticamente en cada transición."

**Evidencia del codebase** (ver sección de análisis abajo).

### P3 (acceptance criteria) — SIN RESPUESTA

El usuario no respondió directamente a P3 sobre si los acceptance criteria deben actualizarse. Esta tensión sigue abierta.

## Análisis de evidencia

### E1: ¿El orquestador PUEDE recolectar métricas de forma confiable?

**Lo que el orquestador ya hace hoy:**

El prompt de DARWIN (`ape.agent.md:460-491`) ya instruye al subagente a ejecutar comandos como:
- `gh issue list --repo ccisnedev/finite_ape_machine --search "keyword"` (línea 481)
- `gh issue create --repo ccisnedev/finite_ape_machine --title "..."` (línea 483)

Esto establece precedente: los subagentes **ya usan herramientas CLI** para interactuar con git/GitHub.

**Datos del esquema y cómo extraerlos:**

| Campo | Fuente | ¿Extraíble por orquestador? |
|-------|--------|----------------------------|
| `issue` | Contexto APE (`.ape/state.yaml → cycle.task`) | ✅ Trivial |
| `version` | `lib/src/version.dart` o `pubspec.yaml` | ✅ Trivial |
| `model` | El agente sabe qué modelo es | ✅ Self-report |
| `timing.branch_created` | `git log --reverse --format=%aI HEAD` | ✅ Git query |
| `timing.pr_merged` | `gh pr view --json mergedAt` | ⚠️ Solo post-merge |
| `plan.total_phases` | `grep -c "^### " docs/issues/NNN/plan.md` | ✅ File parsing |
| `plan.completed_phases` | `grep -c "\[x\]" docs/issues/NNN/plan.md` | ✅ File parsing |
| `tests.before` | Snapshot al inicio del ciclo | ❌ **No disponible al final** |
| `tests.after` | `dart test` o `grep -c 'test(' test/` | ✅ Al final sí |
| `delta_failures` | Autoobservación del agente | ⚠️ Self-report subjetivo |

**Hallazgo clave:** La mayoría de los campos son extraíbles al final del ciclo. Pero `tests.before` requiere captura **al inicio** — y hoy no hay mecanismo para eso.

### E2: ¿La arquitectura de transiciones soporta side-effects programáticos?

**Hallazgo crítico:** NO en su estado actual.

El comando `ape state transition` (`transition.dart:99-178`) hace lo siguiente:

1. Parsea el contrato FSM (`transition_contract.yaml`)
2. Valida si la transición es legal
3. Ejecuta prechecks (issue_selected, feature_branch_selected)
4. **Retorna los effects como strings** — NO los ejecuta

```dart
// transition.dart:167-171
operationsExecuted: <String>[
  'validate_transition',
  'validate_prechecks',
  ...(operations?.effects ?? const <String>[]),
],
```

Los effects en `transition_contract.yaml` (`finalize_execution`, `close_cycle`, `reset_mutations`) son **etiquetas declarativas**, no funciones que se ejecutan. No hay un `switch` sobre el nombre del effect que dispare lógica real.

**Implicación:** Para que métricas se recolecten "programáticamente en cada transición" (D7 etapa 3), se necesitaría:
1. Un mecanismo de ejecución de effects en `transition.dart` (hoy no existe)
2. Un nuevo effect como `collect_metrics` en `transition_contract.yaml`
3. Lógica que lea `config.yaml → evolution.enabled` antes de ejecutar

Esto no es un bug — es una decisión arquitectónica. El CLI delega effects al orquestador (el prompt de agente), no los ejecuta él mismo.

### E3: ¿Dónde se enganchan las métricas en el ciclo?

**El contrato FSM define estas transiciones relevantes:**

| Transición | Event | Effects actuales | ¿Métrica posible? |
|-----------|-------|------------------|-------------------|
| IDLE → ANALYZE | `start_analyze` | `open_analysis_context, reset_mutations` | `tests.before` aquí |
| EXECUTE → EVOLUTION | `finish_execute` | `finalize_execution` | `tests.after`, `plan.*`, `timing` aquí |
| EVOLUTION → IDLE | `finish_evolution` | `close_cycle, reset_mutations` | Consolidar `metrics.yaml` aquí |

**Observación:** El contrato ya tiene `artifacts` por transición:
- `IDLE → ANALYZE`: artifacts: `[analysis/index.md]`
- `EXECUTE → EVOLUTION`: artifacts: `[execution_summary.md]`
- `EVOLUTION → IDLE`: artifacts: `[retrospective.md]`

Se podría añadir `metrics.yaml` como artifact en la transición apropiada. La infraestructura declarativa existe; lo que falta es la ejecución.

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

## Preguntas socráticas — Fase de evidencia

### P1: `tests.before` — ¿dato fantasma o dato que se captura en dos tiempos?

El esquema define `tests.before` y `tests.after` con un `delta` derivado. Pero la evidencia muestra que **no hay mecanismo para capturar `tests.before` al inicio del ciclo**. La transición `IDLE → ANALYZE` tiene effects `[open_analysis_context, reset_mutations]` — no hay nada que tome un snapshot de tests.

Si `metrics.yaml` se genera al final (durante EVOLUTION o END), `tests.before` ya es inaccesible — el código ha cambiado.

Hay dos caminos posibles:
- **a)** Capturar `tests.before` en IDLE → ANALYZE y guardarlo en un lugar intermedio (¿`.ape/metrics_partial.yaml`? ¿una entrada en `state.yaml`?)
- **b)** Recalcular al final via `git stash && git checkout main && dart test` (frágil, lento)

**¿Cuál de estos dos caminos es aceptable para la etapa 1 (orquestador)?** ¿O `tests.before` simplemente se omite hasta que exista la etapa 3 (CLI automatizado)?

### P2: Effects declarativos sin executor — ¿deuda técnica intencional o gap que bloquea D7?

El `transition.dart` retorna los effects como strings pero **no los ejecuta**. Esto no es accidental — es el diseño actual donde el orquestador (prompt del agente) interpreta los effects y actúa. Pero tu decisión D7 dice que la etapa 3 es "programáticamente en cada transición" via CLI.

La evidencia muestra que para llegar a D7-etapa-3, se necesitaría construir un **effect executor** en el CLI — un cambio arquitectónico no trivial. Los effects hoy son `finalize_execution`, `close_cycle`, `reset_mutations`: ninguno tiene implementación en Dart.

**¿Es este gap un blocker para el issue #72, o D7-etapa-3 es trabajo futuro que este issue no necesita resolver?** Si es futuro, ¿basta con que el contrato declare el effect `collect_metrics` aunque nadie lo ejecute programáticamente todavía?

### P3: Si EVOLUTION es el hogar natural de DARWIN, ¿es también el hogar natural de las métricas?

DARWIN ya recibe `diagnosis.md`, `plan.md`, `retrospective.md`, `mutations.md` y el historial de commits (`ape.agent.md:468-474`). Son los mismos artefactos que alimentan la mayoría de los campos de `metrics.yaml`.

Pero DARWIN tiene una regla estricta: **"Never modify the project's code or documentation"** (`ape.agent.md:487`). Si `metrics.yaml` vive en `docs/issues/NNN-slug/`, es documentación del proyecto — y DARWIN no puede crearlo.

**¿Quién genera el archivo?** ¿Es el orquestador APE antes de invocar a DARWIN? ¿Es un nuevo subagente? ¿O se relaja la regla de DARWIN para permitirle escribir métricas? Cada opción tiene consecuencias diferentes para la separación de responsabilidades.
