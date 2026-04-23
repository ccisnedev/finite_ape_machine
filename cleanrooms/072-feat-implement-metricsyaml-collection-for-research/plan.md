---
id: plan
title: "Plan: recolección prospectiva de metrics.yaml con almacenamiento dual"
date: 2025-07-18
status: draft
tags: [plan, metrics, darwin, transition-contract, prompt-engineering]
author: descartes
---

# Plan — Issue #72: metrics.yaml collection

## Hipótesis

> Si modificamos `transition_contract.yaml` para declarar los effects de métricas, actualizamos el prompt de DARWIN para generar `.ape/metrics.yaml` durante EVOLUTION con lógica de copia condicional, y documentamos la arquitectura de captura en dos puntos en `metrics-schema.md`, entonces el ciclo APE producirá datos empíricos estructurados de forma prospectiva sin alterar el flujo existente.

## Artefactos a modificar

| Artefacto | Acción | Riesgo |
|-----------|--------|--------|
| `code/cli/assets/fsm/transition_contract.yaml` | Agregar effects `snapshot_metrics` y `collect_metrics` | Medio — los tests Dart parsean este archivo |
| `code/cli/assets/agents/ape.agent.md` | Modificar EVOLUTION, DARWIN prompt, IDLE | Bajo — archivo de prompt, sin tests directos |
| `docs/research/ape_builds_ape/metrics-schema.md` | Actualizar notas de captura en dos puntos | Bajo — solo documentación |
| `docs/issues/072-feat-implement-metricsyaml-collection-for-research/collection-process.md` | Crear nuevo — documentar proceso | Ninguno — archivo nuevo |

## Dependencias entre fases

```
Fase 1 ──► Fase 2 ──► Fase 3
              │
              ▼
           Fase 4 ──► Fase 5 ──► Fase 6
```

- **Fase 1** es independiente (contrato FSM).
- **Fase 2** depende de Fase 1 (el prompt referencia los effects declarados en el contrato).
- **Fase 3** depende de Fase 2 (el schema documenta lo que el prompt genera).
- **Fase 4** depende de Fase 2 (documenta el proceso definido en el prompt).
- **Fase 5** depende de Fases 1-4 (validación de regresión sobre todos los cambios).
- **Fase 6** es la retrospectiva final, depende de Fase 5.

---

## Fase 1 — Declarar effects de métricas en `transition_contract.yaml`

**Entrada:** Estado actual del contrato FSM (`code/cli/assets/fsm/transition_contract.yaml`).
**Salida:** Contrato con dos nuevos effects declarativos.
**Riesgo:** Los tests en `fsm_contract_test.dart` validan que la matriz es total y que la estructura es parseable. Los effects son listas de strings dentro de `operations` — agregar strings a listas existentes no debería romper parsing, pero se debe verificar.

### Pasos

- [x] **1.1** En la transición `IDLE → ANALYZE` (evento `start_analyze`, líneas 22-31), agregar `snapshot_metrics` a la lista `effects`.
  - Estado actual: `effects: [open_analysis_context, reset_mutations]`
  - Estado deseado: `effects: [open_analysis_context, reset_mutations, snapshot_metrics]`
  - Justificación: D8 — capturar `tests.before` y `timing.branch_created` al inicio del ciclo.

- [x] **1.2** En la transición `EVOLUTION → IDLE` (evento `finish_evolution`, líneas 279-288), agregar `collect_metrics` a la lista `effects`.
  - Estado actual: `effects: [close_cycle, reset_mutations]`
  - Estado deseado: `effects: [close_cycle, reset_mutations, collect_metrics]`
  - Justificación: D9/D12 — señal para generar metrics.yaml final al cerrar el ciclo completo.

- [x] **1.3** Agregar `.ape/metrics_snapshot.yaml` a los `artifacts` de `IDLE → ANALYZE`.
  - Estado actual: `artifacts: [analysis/index.md]`
  - Estado deseado: `artifacts: [analysis/index.md, .ape/metrics_snapshot.yaml]`
  - Justificación: Documenta que esta transición produce un artefacto de snapshot.

- [x] **1.4** Agregar `.ape/metrics.yaml` a los `artifacts` de `EVOLUTION → IDLE`.
  - Estado actual: `artifacts: [retrospective.md]`
  - Estado deseado: `artifacts: [retrospective.md, .ape/metrics.yaml]`
  - Justificación: Documenta que esta transición produce el artefacto final de métricas.

### Verificación Fase 1

```pseudo
VERIFICAR:
  1. Parsear transition_contract.yaml con un parser YAML (ej: python -c "import yaml; yaml.safe_load(open(...))")
     → No debe lanzar error
  2. Buscar "snapshot_metrics" en effects de IDLE → ANALYZE (start_analyze)
     → Presente en la lista
  3. Buscar "collect_metrics" en effects de EVOLUTION → IDLE (finish_evolution)
     → Presente en la lista
  4. Buscar ".ape/metrics_snapshot.yaml" en artifacts de IDLE → ANALYZE
     → Presente en la lista
  5. Buscar ".ape/metrics.yaml" en artifacts de EVOLUTION → IDLE
     → Presente en la lista
  6. Ejecutar tests existentes: cd code/cli && dart test test/fsm_contract_test.dart
     → Todos pasan (la matriz sigue siendo total, los effects son strings sin validación)
  7. Ejecutar tests de transición: cd code/cli && dart test test/state_transition_test.dart
     → Todos pasan
```

**Nota de riesgo:** `fsm_contract_test.dart` (línea 22-34) valida que la matriz es total para todos states × events. Los cambios no agregan ni eliminan transiciones, solo modifican listas dentro de `operations` — no debería afectar la totalidad. Sin embargo, si `parseFsmContract()` valida effects contra un enum o whitelist, el test podría fallar. Verificar output del test antes de proceder.

---

## Fase 2 — Modificar prompt del orquestador en `ape.agent.md`

**Entrada:** Fase 1 completada (effects declarados en contrato).
**Salida:** `ape.agent.md` con instrucciones actualizadas para snapshot en IDLE, generación de métricas en EVOLUTION, y prompt de DARWIN ampliado.
**Riesgo:** Este archivo es un prompt de ~516 líneas. Los cambios deben ser quirúrgicos y no contradecir reglas existentes. El constraint de DARWIN ("Never modify the project's code or documentation") debe refinarse sin perder su intención.

### Sub-fase 2A — Instrucción de snapshot en IDLE

- [x] **2A.1** En la sección `### IDLE — Triage` (líneas 36-58), agregar una instrucción después del paso 5 (cuando la infraestructura está lista) que indique al orquestador capturar el snapshot de métricas antes de transitar a ANALYZE.
  - Texto a agregar (después de la línea que dice "suggest transitioning to ANALYZE"):
    ```
    6. If `.ape/config.yaml` → `evolution.enabled: true`, capture a metrics snapshot before transitioning:
       - Count current tests: `grep -rc 'test(' test/ | tail -1` or `dart test --reporter json 2>/dev/null | grep -c '"testID"'`
       - Record branch creation time: `git log --reverse --format=%aI HEAD | head -1`
       - Write `.ape/metrics_snapshot.yaml` with fields `tests_before` and `branch_created`
    ```
  - Justificación: D8 — captura en dos puntos; el primer punto es IDLE → ANALYZE.

### Sub-fase 2B — Instrucciones de EVOLUTION para métricas

- [x] **2B.1** En la sección `### EVOLUTION — Automatic process evaluation via DARWIN` (líneas 155-174), insertar un paso de generación de métricas entre la invocación de DARWIN y la transición a IDLE.
  - El flujo actual (líneas 161-169) es:
    1. Invocar DARWIN con artefactos
    2. DARWIN evalúa
    3. DARWIN busca/crea issues
    4. Transición a IDLE
  - El flujo actualizado debe ser:
    1. Invocar DARWIN con artefactos (sin cambios)
    2. DARWIN evalúa Y genera `.ape/metrics.yaml` (nuevo)
    3. DARWIN busca/crea issues (sin cambios)
    4. Si `remote origin ≈ ccisnedev/finite_ape_machine`: copiar `.ape/metrics.yaml` → `docs/issues/<slug>/metrics.yaml` (nuevo)
    5. Transición a IDLE (sin cambios)

- [x] **2B.2** Agregar texto explícito sobre la generación de métricas en la lista numerada de EVOLUTION. Después del punto 5 (DARWIN creates issues), agregar:
  ```
  6. DARWIN generates `.ape/metrics.yaml` using cycle artifacts (see DARWIN prompt below for field mapping).
  7. Conditional copy: if `git remote get-url origin` contains `ccisnedev/finite_ape_machine`, copy `.ape/metrics.yaml` to `docs/issues/<slug>/metrics.yaml`.
  ```

- [x] **2B.3** En las **Rules** de EVOLUTION (líneas 171-174), agregar una regla sobre métricas:
  ```
  - metrics.yaml is generated ONLY for complete cycles (IDLE → ANALYZE → PLAN → EXECUTE → EVOLUTION). If evolution.enabled is false, no metrics are generated.
  ```

### Sub-fase 2C — Ampliar prompt de DARWIN

- [x] **2C.1** En la sección `## DARWIN — Subagent Prompt (EVOLUTION)` (líneas 453-491), agregar una nueva sección `## Metrics Collection` dentro del prompt (entre `## Process` y `## Rules`). Contenido:
  ```
  ## Metrics Collection

  After evaluating the cycle, generate `.ape/metrics.yaml` with these fields:

  ### Field mapping

  | Field | Source | Command/Method |
  |-------|--------|----------------|
  | `issue` | `.ape/state.yaml` → `cycle.task` | Read file |
  | `version` | `pubspec.yaml` → `version` or `lib/src/version.dart` | Read file |
  | `model` | Self-report | Your model identifier |
  | `agent` | Context | Agent runtime (copilot, crush, local) |
  | `cycle.completed` | Implicit | `true` (you are in EVOLUTION) |
  | `cycle.darwin_activated` | Implicit | `true` (you are DARWIN) |
  | `cycle.darwin_issue` | Your output | Issue # you created/commented |
  | `timing.branch_created` | `.ape/metrics_snapshot.yaml` | Read file (captured at cycle start) |
  | `timing.pr_merged` | `gh pr view --json mergedAt` | May be empty if PR not yet merged |
  | `plan.total_phases` | `docs/issues/<slug>/plan.md` | `grep -c "^## Fase\|^### Fase\|^## Phase" plan.md` |
  | `plan.completed_phases` | `docs/issues/<slug>/plan.md` | `grep -c "\[x\]" plan.md` |
  | `plan.deviations` | `docs/issues/<slug>/plan.md` | Count deviation annotations |
  | `tests.before` | `.ape/metrics_snapshot.yaml` | Read file (captured at cycle start) |
  | `tests.after` | Current test count | `grep -rc 'test(' test/ \| tail -1` |
  | `tests.delta` | Derived | `tests.after - tests.before` |
  | `delta_failures.count` | Self-report | Times you needed corrections |
  | `observations` | Freeform | Notable observations from the cycle |

  ### Output format

  Write `.ape/metrics.yaml` following the schema in `docs/research/ape_builds_ape/metrics-schema.md`.
  If `.ape/metrics_snapshot.yaml` does not exist, omit `tests.before` and `timing.branch_created`.
  Omit any field you cannot reliably determine — do not fabricate data.
  ```

- [x] **2C.2** Modificar el constraint de DARWIN en `## Rules` (línea 487) para reflejar la excepción de escritura en `.ape/`:
  - Estado actual: `- Never modify the project's code or documentation.`
  - Estado deseado: `- Never modify the project's code or documentation. Exception: write `.ape/metrics.yaml` as part of metrics collection.`
  - Justificación: D11 — `.ape/` es espacio de trabajo del framework, no código ni documentación del proyecto. El constraint se refina sin relajar su intención.

- [x] **2C.3** Agregar `.ape/metrics.yaml` a la lista de artefactos que DARWIN genera, en la línea 488:
  - Estado actual: `- Only create issues/comments in the finite_ape_machine repository.`
  - Estado deseado: `- Only create issues/comments in the finite_ape_machine repository. Also write `.ape/metrics.yaml` locally.`

### Verificación Fase 2

```pseudo
VERIFICAR:
  1. Revisar que ape.agent.md es parseable (frontmatter YAML válido)
     → cat archivo, verificar que el frontmatter entre --- es YAML válido
  2. Buscar "snapshot" en sección IDLE
     → Instrucción de captura presente con ejemplo de comando
  3. Buscar "metrics.yaml" en sección EVOLUTION
     → Paso de generación y copia condicional presentes
  4. Buscar "Metrics Collection" en prompt de DARWIN
     → Sección completa con tabla de field mapping
  5. Buscar "Exception: write" en Rules de DARWIN
     → Constraint refinado, no eliminado
  6. Verificar que NO hay contradicciones:
     → "Never modify code or documentation" + excepción para .ape/ son compatibles
     → DARWIN genera .ape/metrics.yaml (workspace) NO docs/issues/.../metrics.yaml (eso es side-effect del orquestador)
  7. Contar que las Rules de DARWIN siguen siendo 3 reglas + refinamientos
     → No se eliminó ninguna regla original
```

---

## Fase 3 — Actualizar `metrics-schema.md` con notas de captura en dos puntos

**Entrada:** Fase 2 completada (el prompt define qué campos se capturan y cuándo).
**Salida:** `metrics-schema.md` actualizado con notas sobre la arquitectura de captura en dos puntos y almacenamiento dual.
**Riesgo:** Bajo — es documentación pura. No hay tests que validen este archivo.

### Pasos

- [x] **3.1** Actualizar el comentario de cabecera del schema (línea 10 de `metrics-schema.md`):
  - Estado actual: `# docs/issues/NNN-slug/metrics.yaml`
  - Estado deseado: `# .ape/metrics.yaml (primary) → docs/issues/NNN-slug/metrics.yaml (conditional copy)`
  - Justificación: D11 — reflejar almacenamiento dual.

- [x] **3.2** Agregar notas de captura en dos puntos al campo `tests.before`:
  - Localización: tabla `Field Reference`, fila de `tests.before` (línea 65).
  - Actualizar columna `Description`:
    - De: `Test count at cycle start`
    - A: `Test count at cycle start. Captured via snapshot at IDLE → ANALYZE transition (.ape/metrics_snapshot.yaml). May be approximate.`

- [x] **3.3** Agregar nota similar a `timing.branch_created`:
  - De: `When feature branch was created`
  - A: `When feature branch was created. Captured via snapshot at IDLE → ANALYZE transition (.ape/metrics_snapshot.yaml).`

- [x] **3.4** Actualizar la sección `## Notes` (líneas 108-113) para reflejar la nueva arquitectura:
  - Reemplazar el contenido actual por:
    ```markdown
    ## Notes

    - **Primary storage:** `.ape/metrics.yaml` — generated by DARWIN during EVOLUTION.
    - **Conditional copy:** copied to `docs/issues/NNN-slug/metrics.yaml` only if `evolution.enabled: true` AND `remote origin ≈ ccisnedev/finite_ape_machine`.
    - **Two-point capture:** `tests.before` and `timing.branch_created` are captured at cycle start (IDLE → ANALYZE) in `.ape/metrics_snapshot.yaml`. All other fields are collected at cycle end (EVOLUTION).
    - **Complete cycles only:** `metrics.yaml` is only generated for cycles that reach EVOLUTION. Partial or aborted cycles do not produce metrics.
    - **Maturity roadmap (D7):** Stage 1 = orchestrator prompt (current). Stage 2 = sub-agent. Stage 3 = `ape metrics collect` CLI command.
    - Future: `ape` CLI command to auto-generate from git/GitHub data.
    - Fields with `no` required can be omitted — extraction scripts handle missing fields gracefully.
    - `timing.pr_merged` may be empty at generation time (PR not yet merged); can be filled post-merge.
    ```

- [x] **3.5** Actualizar la línea 109 del schema:
  - De: `- This file is created at cycle end (during END or EVOLUTION state)`
  - A: (eliminada, reemplazada por el bloque de Notes en 3.4)

### Verificación Fase 3

```pseudo
VERIFICAR:
  1. Buscar "Two-point capture" o "Captura en dos puntos" en Notes
     → Presente con descripción de snapshot y collection
  2. Buscar "metrics_snapshot.yaml" en descripción de tests.before
     → Presente con nota sobre aproximación
  3. Buscar "Conditional copy" o "conditional" en Notes
     → Lógica de almacenamiento dual documentada
  4. Buscar "Complete cycles only" en Notes
     → Gate de completitud documentado (D12)
  5. Verificar que el ejemplo YAML (líneas 74-105) sigue siendo válido
     → El ejemplo no requiere cambios (es una instancia válida del schema)
```

---

## Fase 4 — Documentar el proceso de recolección

**Entrada:** Fases 2 y 3 completadas (el proceso está definido en el prompt y documentado en el schema).
**Salida:** Nuevo archivo `docs/issues/072-feat-implement-metricsyaml-collection-for-research/collection-process.md`.
**Riesgo:** Ninguno — es un archivo nuevo de documentación.

### Pasos

- [x] **4.1** Crear `collection-process.md` en el directorio del issue con la siguiente estructura:

  ```markdown
  ---
  id: collection-process
  title: "Proceso de recolección de metrics.yaml"
  date: 2025-07-18
  status: active
  tags: [metrics, process, documentation]
  author: basho
  ---

  # Proceso de recolección de metrics.yaml

  ## Resumen

  metrics.yaml captura datos empíricos por ciclo APE para alimentar el paper
  de investigación (bootstrap-validation.md). La recolección es prospectiva:
  solo ciclos futuros que alcancen EVOLUTION generan métricas.

  ## Precondiciones

  - `.ape/config.yaml` → `evolution.enabled: true`
  - El ciclo debe completarse (alcanzar EVOLUTION)

  ## Flujo de recolección

  ### Punto 1: Snapshot (IDLE → ANALYZE)

  **Cuándo:** Al transitar de IDLE a ANALYZE (effect `snapshot_metrics`).
  **Quién:** El orquestador APE (no un subagente).
  **Qué captura:**
  - `tests_before`: conteo de tests actual (`grep -rc 'test(' test/`)
  - `branch_created`: timestamp de creación del branch (`git log --reverse --format=%aI HEAD | head -1`)

  **Dónde escribe:** `.ape/metrics_snapshot.yaml`

  **Formato:**
  ```yaml
  tests_before: 127
  branch_created: "2025-07-18T10:00:00Z"
  ```

  ### Punto 2: Recolección completa (EVOLUTION)

  **Cuándo:** Durante EVOLUTION, después de que DARWIN evalúa el ciclo (effect `collect_metrics`).
  **Quién:** DARWIN (subagente de EVOLUTION).
  **Qué captura:** Todos los 17 campos del schema (`metrics-schema.md`), consolidando el snapshot del Punto 1.

  **Dónde escribe:** `.ape/metrics.yaml`

  **Fuentes de datos:**
  | Campo | Fuente |
  |-------|--------|
  | `issue` | `.ape/state.yaml` → `cycle.task` |
  | `version` | `pubspec.yaml` o `lib/src/version.dart` |
  | `model` | Self-report del agente |
  | `agent` | Contexto del runtime |
  | `cycle.*` | Implícito + output de DARWIN |
  | `timing.branch_created` | `.ape/metrics_snapshot.yaml` |
  | `timing.pr_merged` | `gh pr view --json mergedAt` (puede estar vacío) |
  | `plan.*` | Parsing de `plan.md` |
  | `tests.before` | `.ape/metrics_snapshot.yaml` |
  | `tests.after` | Conteo actual de tests |
  | `tests.delta` | Derivado |
  | `delta_failures.*` | Self-report |
  | `observations` | Freeform |

  ### Copia condicional

  **Cuándo:** Después de generar `.ape/metrics.yaml`.
  **Condición:** `git remote get-url origin` contiene `ccisnedev/finite_ape_machine`.
  **Acción:** Copiar `.ape/metrics.yaml` → `docs/issues/<slug>/metrics.yaml`.
  **Quién:** Side-effect del flujo de EVOLUTION (no DARWIN directamente).

  ## Almacenamiento dual (D11)

  | Ubicación | Siempre | Committed | Propósito |
  |-----------|---------|-----------|-----------|
  | `.ape/metrics.yaml` | Sí (si evolution=true) | No (gitignored) | Workspace del framework |
  | `docs/issues/<slug>/metrics.yaml` | Solo si remote=finite_ape_machine | Sí (en el PR) | Datos de investigación |

  ## Etapas de madurez (D7)

  | Etapa | Responsable | Estado |
  |-------|-------------|--------|
  | 1. Orquestador (prompt) | DARWIN vía instrucciones en `ape.agent.md` | **Actual** |
  | 2. Sub-agente dedicado | Agente especializado en métricas | Futuro |
  | 3. CLI automatizado | `ape metrics collect` | Futuro |

  ## Campos omitibles

  Si un campo no se puede determinar de forma confiable, se omite.
  No fabricar datos (D5). El schema permite todos los campos como opcionales
  excepto `issue`.
  ```

### Verificación Fase 4

```pseudo
VERIFICAR:
  1. El archivo existe en docs/issues/072-feat-implement-metricsyaml-collection-for-research/collection-process.md
  2. Tiene frontmatter YAML válido
  3. Documenta ambos puntos de captura (snapshot + recolección)
  4. Documenta la copia condicional con la condición exacta
  5. Documenta las tres etapas de madurez (D7)
  6. Referencia los artefactos: .ape/metrics_snapshot.yaml, .ape/metrics.yaml, docs/issues/<slug>/metrics.yaml
  7. Es consistente con los cambios de Fases 1-3
```

---

## Fase 5 — Validación de regresión y coherencia

**Entrada:** Fases 1-4 completadas.
**Salida:** Todos los tests existentes pasan; no hay contradicciones entre artefactos.
**Riesgo:** Medio — los tests de FSM (`fsm_contract_test.dart`, `state_transition_test.dart`, `state_transition_integration_test.dart`) son los más sensibles a cambios en `transition_contract.yaml`.

### Pasos

- [x] **5.1** Ejecutar la suite completa de tests del CLI:
  ```bash
  cd code/cli && dart test
  ```
  - Criterio: **Todos los tests pasan** (0 failures).
  - Si algún test falla, diagnosticar si el fallo es causado por los cambios de Fase 1 (effects/artifacts en el contrato) o es un fallo preexistente.

- [x] **5.2** Validar YAML del contrato de transiciones:
  ```bash
  python -c "import yaml; yaml.safe_load(open('code/cli/assets/fsm/transition_contract.yaml'))"
  ```
  - Criterio: Sin errores de parsing.

- [x] **5.3** Verificar coherencia cruzada entre artefactos:
  - `transition_contract.yaml` declara `snapshot_metrics` → `ape.agent.md` IDLE menciona snapshot → `metrics-schema.md` Notes menciona snapshot → `collection-process.md` Punto 1 describe snapshot.
  - `transition_contract.yaml` declara `collect_metrics` → `ape.agent.md` EVOLUTION menciona generación → DARWIN prompt tiene Metrics Collection → `collection-process.md` Punto 2 describe recolección.
  - `ape.agent.md` DARWIN Rules dice "Exception: write `.ape/metrics.yaml`" → `collection-process.md` confirma DARWIN escribe en `.ape/`.
  - `ape.agent.md` EVOLUTION menciona copia condicional → `collection-process.md` Copia condicional describe la condición.

- [x] **5.4** Verificar que los 7 acceptance criteria del diagnóstico §7 están cubiertos:
  1. ✅ `transition_contract.yaml` declara `snapshot_metrics` en IDLE → ANALYZE → Fase 1.1
  2. ✅ `transition_contract.yaml` declara `collect_metrics` en EVOLUTION → IDLE → Fase 1.2
  3. ✅ `ape.agent.md` incluye instrucciones para DARWIN genere `.ape/metrics.yaml` → Fase 2C.1
  4. ✅ `ape.agent.md` actualiza constraint de DARWIN para `.ape/` → Fase 2C.2
  5. ✅ Documentado mecanismo de copia condicional → Fases 2B.2 y 4.1
  6. ✅ `metrics-schema.md` actualizado con captura en dos puntos → Fase 3
  7. ✅ Proceso documentado: cuándo, quién, etapas de madurez → Fase 4

### Verificación Fase 5

```pseudo
VERIFICAR:
  1. `dart test` en code/cli → 0 failures
  2. YAML parsing de transition_contract.yaml → OK
  3. Los 7 acceptance criteria tienen mapeo a fases del plan → Todos cubiertos
  4. No hay contradicciones entre los 4 artefactos modificados/creados
```

---

## Fase 6 — Retrospectiva

**Entrada:** Fase 5 completada (todo validado).
**Salida:** `retrospective.md` en el directorio del issue.

### Pasos

- [x] **6.1** Crear `docs/issues/072-feat-implement-metricsyaml-collection-for-research/retrospective.md` con:
  - **What went well:** Lista de lo que funcionó.
  - **What deviated:** Cualquier desviación respecto a este plan.
  - **What surprised:** Hallazgos inesperados durante ejecución.
  - **Spawn issues:** Issues identificados para trabajo futuro (ej: effect executor D7-etapa-3, `ape metrics collect`).

- [x] **6.2** Verificar que `retrospective.md` es consistente con las desviaciones anotadas en este `plan.md` durante ejecución.

### Verificación Fase 6

```pseudo
VERIFICAR:
  1. retrospective.md existe
  2. Tiene las 4 secciones requeridas
  3. Spawn issues identificados para trabajo futuro
```

---

## Resumen de riesgos

| Riesgo | Fase | Mitigación |
|--------|------|-----------|
| Tests de FSM fallan por effects nuevos | 1 | Ejecutar tests inmediatamente después de modificar el contrato (Fase 5.1). Los effects son strings sin validación de whitelist en el parser. |
| Prompt de DARWIN demasiado largo/ambiguo | 2 | La tabla de field mapping es determinista. Si DARWIN no genera métricas, es un riesgo aceptado de LLMs no-deterministas (ver diagnóstico §5). |
| Contradicción en constraint de DARWIN | 2 | El refinamiento es aditivo ("Exception: write .ape/metrics.yaml"). La regla base se preserva intacta. |
| `metrics_snapshot.yaml` no existe cuando DARWIN necesita leerlo | 2C.1 | El prompt instruye: "If .ape/metrics_snapshot.yaml does not exist, omit tests.before and timing.branch_created." Degradación graceful. |
| Schema y prompt divergen con el tiempo | 3 | `collection-process.md` sirve como documento de referencia unificado. |

## Aplicabilidad TDD

Los artefactos de este issue son **prompts, YAML configs y documentación** — no código ejecutable. TDD clásico (RED→GREEN) no aplica. La verificación es:

- **YAML validity:** parser check (Fase 5.2)
- **Regresión de tests existentes:** `dart test` (Fase 5.1)
- **Coherencia semántica:** revisión cruzada manual (Fase 5.3)
- **Cobertura de acceptance criteria:** mapeo explícito (Fase 5.4)
