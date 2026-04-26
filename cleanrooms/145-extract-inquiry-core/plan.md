---
id: plan
title: "Plan — v0.2.0: Rediseño del scheduler como Finite APE Machine"
date: 2026-04-25
status: active
tags: [plan, fsm, scheduler, v0.2.0, tdd]
author: descartes
---

# Plan — v0.2.0: Rediseño del scheduler como Finite APE Machine

## Hipótesis

> Si implementamos estas 8 fases en este orden — bugs primero, luego infraestructura FSM ascendente, luego sub-agentes, luego firmware, luego init — resolveremos el problema del monolito y cerraremos el gap spec↔código, manteniendo backward-compatibility en cada commit.

Si la ejecución falsifica esta hipótesis (desviación detectada), el ciclo retorna a ANALYZE.

## Grafo de dependencias

```
Phase 0 (Bugs)          ─────────────────────────────────────────┐
Phase 1 (FSM module)    ────┬───────────────────────────────────┐│
Phase 2 (fsm state)     ────┤                                   ││
Phase 3 (effects)       ←───┘                                   ││
Phase 4 (Sub-agent YAML)─────┐                                  ││
Phase 5 (ape prompt)    ←────┘                                  ││
Phase 6 (Firmware)      ←── Phase 2 + Phase 5                   ││
Phase 7 (Init regen)    ←── Phase 6 + Phase 0                   ││
Phase 8 (Integración)   ←── ALL ────────────────────────────────┘│
Phase 8b (QA bug fixes) ←── Phase 8 (bugs descubiertos en e2e)  │
                                                                 │
```

---

## Phase 0 — Bug fixes aislados

**Objetivo**: Corregir los 2 bugs pendientes antes de tocar la arquitectura.
**Justificación**: Son independientes del rediseño y eliminan ruido en doctor/init para las fases posteriores.
**Dependencias**: Ninguna.
**TDD**: RED→GREEN directo.

### 0.1 Bug: doctor reporta "0 skills deployed"

- [x] **ROOT CAUSE**: `global_builder.dart` no pasaba `Assets` a `DoctorCommand` → `_assets` null → `_getExpectedSkills()` retorna `[]` → `totalSkills == 0`.
- [x] **GREEN**: Inyectar `Assets` en `buildGlobalModule` → `DoctorCommand`. Extraer `assetsRoot` en `inquiry_cli.dart` para evitar duplicación.
- [x] **REFACTOR**: Tests existentes (17) ya cubren el edge case (`no assets available → 0 skills expected`).
- [x] Verificar manualmente: `iq doctor` reporta conteo correcto. → `agent + 4 skills deployed` ✓

**Test pseudocódigo:**
```
test('doctor counts deployed skills correctly')
  setup: crear tmpDir con structure ~/.copilot/skills/{issue-start,issue-end,memory-read,memory-write}/SKILL.md
  result = DoctorCommand(input, homeDir: tmpDir).execute()
  expect result.targetChecks[0].totalSkills == 4
  expect result.targetChecks[0].missingSkills.isEmpty
```

### 0.2 Bug: init crea `docs\cleanrooms` en vez de `.\cleanrooms`

- [x] **ANÁLISIS**: Código ya correcto — `init.dart` usa `$root/cleanrooms`. Bug no reproducible (posible versión anterior).
- [x] **REGRESSION TEST**: Agregado test explícito `creates cleanrooms/ at root, not under docs/` que assert `docs/cleanrooms` NO existe.
- [x] **REFACTOR**: Test de idempotencia ya existente (`running init twice produces same result`).
- [x] Verificar manualmente: `iq init` → `already initialized` (correcto). cleanrooms/ en raíz ✓

**Test pseudocódigo:**
```
test('init creates cleanrooms at project root, not under docs/')
  setup: crear tmpDir vacío con .git/
  InitCommand(InitInput(workingDirectory: tmpDir)).execute()
  expect Directory(p.join(tmpDir, 'cleanrooms')).existsSync() == true
  expect Directory(p.join(tmpDir, 'docs', 'cleanrooms')).existsSync() == false
```

**Riesgo**: Bajo. Cambios localizados en un solo archivo cada uno.

---

## Phase 1 — Renombrar módulo `state` → `fsm`

**Objetivo**: Renombrar `iq state transition` → `iq fsm transition`. Preparar el namespace para los comandos nuevos.
**Dependencias**: Ninguna (puede ejecutarse en paralelo con Phase 0).
**TDD**: Rename mecánico, tests existentes se actualizan.

- [x] Renombrar directorio `lib/modules/state/` → `lib/modules/fsm/`
- [x] Renombrar `state_builder.dart` → `fsm_builder.dart`
- [x] En `fsm_builder.dart`: cambiar nombre del módulo de `'state'` a `'fsm'`
- [x] En `inquiry_cli.dart`: cambiar `cli.module('state', ...)` → `cli.module('fsm', ...)`
- [x] Actualizar imports en todos los archivos afectados
- [x] Renombrar `state_transition_test.dart` → `fsm_transition_test.dart`
- [x] Renombrar `state_transition_integration_test.dart` → `fsm_transition_integration_test.dart`
- [x] Actualizar imports en tests
- [x] Ejecutar `dart analyze` — 0 errores
- [x] Ejecutar `dart test` — 161 tests pasan

**Verificación:**
```
iq fsm transition --event start_analyze --state IDLE   → funciona
iq state transition ...                                → comando no reconocido
```

**Riesgo**: Bajo. Es un rename mecánico. El riesgo es olvidar un import.
**Mitigación**: `dart analyze` captura imports rotos.

---

## Phase 2 — Implementar `iq fsm state --json`

**Objetivo**: Nuevo comando que retorna el estado actual del FSM en formato JSON para que el firmware lo consuma.
**Dependencias**: Phase 1 (el comando vive en el módulo `fsm`).
**TDD**: RED→GREEN completo.

### 2.1 Definir Input/Output

- [x] **RED**: 14 tests escritos cubriendo JSON structure, transitions, APEs, instructions, missing workspace, toText().
- [x] **GREEN**: Creado `lib/modules/fsm/commands/state.dart` con `FsmStateInput`, `FsmStateOutput`, `FsmStateCommand`.

### 2.2 Calcular transiciones válidas

- [x] **RED**: Tests verifican ANALYZE→{complete_analysis, block} y IDLE→{start_analyze}.
- [x] **GREEN**: Filtrar `contract.transitions` por `(currentState, *)` donde `allowed == true`.

### 2.3 Calcular APEs activos

- [x] **RED**: Tests verifican ANALYZE→socrates, PLAN→descartes, EXECUTE→basho, EVOLUTION→darwin, IDLE→[].
- [x] **GREEN**: Mapeo constante `_stateApes` con 6 estados.

### 2.4 Generar instructions inline

- [x] **RED**: Tests verifican ANALYZE→contains('socrates'), IDLE→contains('start_analyze').
- [x] **GREEN**: Mapeo constante `_stateInstructions` con 6 estados.

### 2.5 Registrar comando en el módulo

- [x] Registrar `FsmStateCommand` en `fsm_builder.dart` como subcomando `state`
- [x] Agregar flag `--json` (default true, para futuro soporte texto) — **diferido**: toText() ya funciona
- [x] Verificar manualmente: `iq fsm state` retorna JSON válido

**Riesgo**: El schema JSON podría no cubrir lo que el firmware necesita.
**Mitigación**: El schema está definido en diagnosis §7.2. Si en Phase 6 el firmware necesita más, se itera.

---

## Phase 3 — Implementar ejecución de effects en `iq fsm transition`

**Objetivo**: Cerrar el gap spec↔código. `transition.dart` actualmente valida pero no ejecuta effects. Implementar los effects que tocan `.inquiry/`.
**Dependencias**: Phase 1 (el comando ya está en módulo `fsm`).
**TDD**: RED→GREEN por cada effect.

### 3.1 Inventariar effects del contrato

- [x] Leer `transition_contract.yaml` completo y listar todos los effects únicos.
- [x] Clasificar cada effect:

**CLI-side (ejecuta el CLI):**
- `update_state` — siempre ejecutado en transición válida
- `reset_mutations` — limpia `.inquiry/mutations.md`
- `snapshot_metrics` — crea `.inquiry/metrics_snapshot.yaml`
- `close_cycle` — reset state a IDLE
- `collect_metrics` — append a `.inquiry/metrics.yaml`

**Skill-side (CLI reporta, skill ejecuta):**
- `open_analysis_context`, `continue_analysis`, `pause_analysis`, `reopen_analysis`
- `generate_plan`, `prepare_execute`, `continue_execute`, `finalize_execution`
- `push_branch`, `create_pull_request`
- `noop`

### 3.2 Implementar effect executor

- [x] **RED**: 12 tests para EffectExecutor (update_state, reset_mutations, snapshot_metrics, close_cycle, collect_metrics, executeAll).
- [x] **GREEN**: Creado `lib/modules/fsm/effect_executor.dart` con `EffectExecutor`.

### 3.3 Integrar executor en `StateTransitionCommand`

- [x] **GREEN**: Inyectar `EffectExecutor` en `StateTransitionCommand.execute()`. Effects CLI-side ejecutados tras validación. `operationsExecuted` refleja lo realmente ejecutado.
- [x] Test actualizado: `generate_plan` es skill-side, `update_state` verifica state.yaml actualizado.

### 3.4 Effects que NO ejecuta el CLI

- [x] Documentado en `effect_executor.dart` library doc: effects como `push_branch`, `create_pull_request` son skill-side.

### 3.5 Pruebas manuales

- [x] `iq init` → `state: IDLE, issue: null` ✓
- [x] `iq fsm transition --event start_analyze` → state.yaml=ANALYZE, mutations reset, snapshot creado ✓
- [x] `iq fsm state` → `State: ANALYZE, APEs: socrates` ✓
- [x] `iq fsm transition --event approve_plan` → ilegal, exit 64 ✓
- [x] `iq fsm transition --event block` → `state: IDLE` ✓

**Riesgo**: Los effects del contrato pueden ser ambiguos o incompletos.
**Mitigación**: El inventario (3.1) resuelve ambigüedades antes de codificar. Si un effect no tiene semántica clara, se documenta como "skill-side" y no se implementa en el CLI.

---

## Phase 4 — Crear YAMLs de sub-agentes

**Objetivo**: Crear los archivos YAML versionados en `assets/apes/` para cada sub-agente.
**Dependencias**: Ninguna (datos estáticos, no requiere código nuevo aún).
**TDD**: No aplica directamente (son datos). Se validan en Phase 5.

### 4.1 Extraer prompts del monolito

- [x] Leer `assets/agents/inquiry.agent.md` completo (~600 líneas).
- [x] Identificar y aislar SOCRATES, DESCARTES, BASHŌ, DARWIN.
- [x] Separar `base_prompt` (personalidad + mindset) vs `states` (fases internas).

### 4.2–4.5 Crear YAMLs

- [x] `assets/apes/socrates.yaml` — 6 estados: clarification, assumptions, evidence, perspectives, implications, meta_reflection
- [x] `assets/apes/descartes.yaml` — 4 estados: decomposition, ordering, verification, enumeration
- [x] `assets/apes/basho.yaml` — 3 estados: implement, test, commit
- [x] `assets/apes/darwin.yaml` — 4 estados: observe, compare, select, report
- [x] Fidelidad verificada via tests de keywords (Socratic method, scientific method, 用の美, natural selection)

### 4.6 Validación de schema

- [x] **RED**: 15 tests — schema validation, state counts, assemblePrompt, prompt fidelity.
- [x] **GREEN**: `lib/modules/ape/ape_definition.dart` con `ApeDefinition.parse()` y `assemblePrompt()`.

**Riesgo**: La fragmentación del monolito puede perder contexto entre secciones.
**Mitigación**: Comparación lado a lado del prompt generado vs. monolito original (test de regresión en Phase 5).

---

## Phase 5 — Implementar `iq ape prompt <name>`

**Objetivo**: Comando que lee YAML del sub-agente + estado actual → genera prompt ensamblado.
**Dependencias**: Phase 4 (necesita los YAMLs), Phase 2 (necesita leer estado de `.inquiry/`).
**TDD**: RED→GREEN completo.

### 5.1 Definir Input/Output

- [x] **RED**: 20 tests — prompt assembly, APE_NOT_FOUND, APE_NOT_ACTIVE, sub-state, validate, output format, regression.
- [x] **GREEN**: `lib/modules/ape/commands/prompt.dart` con `ApePromptInput`, `ApePromptOutput`, `ApePromptCommand`.

### 5.2 Ensamblar prompt

- [x] `ApeDefinition.assemblePrompt(stateName:)` concatena `base_prompt + state.prompt`.
- [x] Sub-estado es opcional via `--state <sub_state>`. Sin él, retorna solo base_prompt.

### 5.3 Sub-agente no existe

- [x] `APE_NOT_FOUND` con ruta del YAML faltante.

### 5.4 Sub-agente no activo en fase actual

- [x] `APE_NOT_ACTIVE` con nombre del estado actual y APEs activos.

### 5.5 Registrar módulo `ape`

- [x] `lib/modules/ape/ape_builder.dart` creado
- [x] Registrado en `inquiry_cli.dart`: `cli.module('ape', ...)`
- [x] CLI: `iq ape prompt --name <name> [--state <sub_state>]`

### 5.6 Test de regresión vs. monolito

- [x] 4 tests de prompt fidelity: keywords de cada sub-agente verificados.

### 5.7 Pruebas manuales

- [x] `iq ape prompt --name basho` → prompt de BASHŌ completo (estado EXECUTE) ✓
- [x] `iq ape prompt --name basho --state implement` → base + sub-estado ✓
- [x] `iq ape prompt --name socrates` → `APE_NOT_ACTIVE` (EXECUTE, no socrates) ✓
- [x] `iq ape prompt --name nonexistent` → `APE_NOT_FOUND` ✓

**Riesgo**: Prompts modulares degradan comportamiento del LLM vs. monolito.
**Mitigación**: Tests de regresión (5.6). Si la degradación es observable, se itera el YAML.

---

## Decisión: Modelo RTOS — FSM dual (principal + per-APE)

> **Contexto**: Phase 5 original trataba sub-estados como argumento manual (`--state`). No hay persistencia, transiciones validadas, ni observabilidad del sub-estado. Esto rompe el principio de CLI-como-kernel.
>
> **Decisión**: Implementar FSM formal per-APE siguiendo el patrón RTOS:
> - **FSM principal** (ya existe): IDLE → ANALYZE → PLAN → EXECUTE → END → EVOLUTION → IDLE
> - **FSM per-APE** (nuevo): cada APE tiene su propio contrato de transiciones internas
> - Ambos niveles: contrato YAML, validación, persistencia en `.inquiry/state.yaml`, observabilidad via JSON
>
> **Formato de state.yaml**:
> ```yaml
> state: ANALYZE
> issue: "145"
> ape:
>   name: socrates
>   state: assumptions
> ```
>
> **Principio**: El CLI trackea todo. El firmware no necesita memoria, solo lee estado.

---

## Phase 5b — Sub-FSM per-APE (RTOS)

**Objetivo**: Cada APE tiene un FSM interno con transiciones validadas, persistidas, y observables.
**Dependencias**: Phase 4 (YAMLs), Phase 5 (prompt command), Phase 3 (effect_executor pattern).
**TDD**: RED→GREEN completo.

### 5b.1 Agregar transiciones a YAMLs de sub-agentes

- [x] Extender schema de cada `assets/apes/<name>.yaml`:

```yaml
initial_state: clarification
states:
  clarification:
    description: "..."
    prompt: |
      ...
    transitions:
      - event: next
        to: assumptions
      - event: skip
        to: evidence
  assumptions:
    transitions:
      - event: next
        to: evidence
      - event: back
        to: clarification
  # ...
  meta_reflection:
    transitions:
      - event: complete
        to: _DONE    # sentinel: señala fin del sub-FSM
```

- [x] `socrates.yaml`: 6 estados, transiciones lineales + `back` + `skip`, `meta_reflection → _DONE`
- [x] `descartes.yaml`: 4 estados, `decomposition → ordering → verification → enumeration → _DONE`
- [x] `basho.yaml`: 3 estados, `implement → test → commit → _DONE` (loop: `test → implement` on failure)
- [x] `darwin.yaml`: 4 estados, `observe → compare → select → report → _DONE`

**Nota**: `_DONE` es un sentinel, no un estado real. Indica al FSM principal que el APE completó su trabajo. El firmware puede entonces solicitar transición del FSM principal.

### 5b.2 Extender `ApeDefinition` para parsear transiciones

- [x] **RED**: Tests que validan:
  - Cada estado tiene campo `transitions` (lista de `{event, to}`)
  - `initial_state` existe y apunta a un estado definido
  - Todos los `to` targets apuntan a estados definidos o `_DONE`
  - No hay estados inalcanzables (excepto `initial_state`)
- [x] **GREEN**: Extender `ApeDefinition.parse()` y `ApeState` con `transitions` y `initialState`.

**Test pseudocódigo:**
```
test('socrates.yaml has valid internal transitions')
  def = ApeDefinition.parse(File('assets/apes/socrates.yaml'))
  expect def.initialState == 'clarification'
  for state in def.states:
    expect state.transitions.isNotEmpty
    for t in state.transitions:
      expect def.states.any((s) => s.name == t.to) || t.to == '_DONE'

test('_DONE is reachable from every APE')
  for ape in ['socrates', 'descartes', 'basho', 'darwin']:
    def = ApeDefinition.parse(...)
    // At least one state has transition to _DONE
    expect def.states.any((s) => s.transitions.any((t) => t.to == '_DONE'))
```

### 5b.3 Persistir sub-estado en `.inquiry/state.yaml`

- [x] **RED**: Tests que validan escritura/lectura de `ape:` en state.yaml:
  - Escribir `{name: socrates, state: clarification}` → leer lo mismo
  - Leer state.yaml sin campo `ape` → retorna null (backward-compatible)
  - Transición principal (e.g., ANALYZE→PLAN) limpia campo `ape`
- [x] **GREEN**: Modificar `EffectExecutor.update_state` para incluir `ape:` cuando aplique. Agregar helpers de lectura/escritura en los comandos que lo necesiten.

**Test pseudocódigo:**
```
test('update_state preserves ape sub-state')
  writeStateYaml(state: 'ANALYZE', issue: '99', ape: {name: 'socrates', state: 'assumptions'})
  content = readStateYaml()
  expect content.ape.name == 'socrates'
  expect content.ape.state == 'assumptions'

test('main FSM transition clears ape field')
  writeStateYaml(state: 'ANALYZE', issue: '99', ape: {name: 'socrates', state: 'meta_reflection'})
  executeTransition(event: 'complete_analysis')  // ANALYZE → PLAN
  content = readStateYaml()
  expect content.state == 'PLAN'
  expect content.ape == null  // limpio, descartes aún no activado
```

### 5b.4 Implementar `iq ape transition --event <e>`

- [x] **RED**: Tests:
  - `iq ape transition --event next` en `socrates:clarification` → `socrates:assumptions` ✓
  - `iq ape transition --event complete` en `socrates:meta_reflection` → `_DONE` (escribe ape.state = _DONE) ✓
  - `iq ape transition --event next` en `_DONE` → error `APE_COMPLETED` ✓
  - `iq ape transition --event invalid` → error `INVALID_APE_EVENT` ✓
  - `iq ape transition` sin APE activo (IDLE) → error `NO_ACTIVE_APE` ✓
- [x] **GREEN**: Crear `lib/modules/ape/commands/transition.dart`:
  1. Leer `.inquiry/state.yaml` → obtener FSM state + `ape.name` + `ape.state`
  2. Si no hay APE activo → error
  3. Cargar YAML del APE → buscar transición `(current_ape_state, event)`
  4. Si no existe → error
  5. Escribir nuevo `ape.state` en state.yaml
  6. Retornar `{ape, from, event, to}`
- [x] Registrar en `ape_builder.dart`

**Test pseudocódigo:**
```
test('ape transition next advances socrates from clarification to assumptions')
  setup: state.yaml con {state: ANALYZE, issue: '99', ape: {name: socrates, state: clarification}}
  cmd = ApeTransitionCommand(input: {event: 'next', workingDirectory: tmpDir})
  result = cmd.execute()
  expect result.from == 'clarification'
  expect result.to == 'assumptions'
  expect readStateYaml().ape.state == 'assumptions'
```

### 5b.5 Implementar `iq ape state`

- [x] **RED**: Tests:
  - En ANALYZE con `ape: {name: socrates, state: assumptions}` → JSON con `name`, `state`, `valid_transitions[]`, `prompt_preview`
  - Sin APE activo → JSON con `ape: null`
  - APE en `_DONE` → JSON con `state: _DONE`, `transitions: []`
- [x] **GREEN**: Crear `lib/modules/ape/commands/state.dart`:
  1. Leer state.yaml → `ape` field
  2. Si `ape` null → retornar `{ape: null}`
  3. Cargar YAML → computar transiciones válidas desde `ape.state`
  4. Retornar JSON
- [x] Registrar en `ape_builder.dart`

**Test pseudocódigo:**
```
test('ape state returns current sub-state and valid transitions')
  setup: state.yaml con {state: ANALYZE, ape: {name: socrates, state: evidence}}
  result = ApeStateCommand(workingDirectory: tmpDir).execute()
  expect result.name == 'socrates'
  expect result.state == 'evidence'
  expect result.transitions contains {event: 'next', to: 'perspectives'}
```

### 5b.6 Activación automática del APE en transición principal

- [x] **RED**: Tests:
  - `iq fsm transition --event start_analyze` → state.yaml tiene `ape: {name: socrates, state: clarification}`
  - `iq fsm transition --event complete_analysis` → state.yaml tiene `ape: {name: descartes, state: decomposition}`
  - `iq fsm transition --event block` → state.yaml tiene `ape: null`
- [x] **GREEN**: Modificar `EffectExecutor` o `StateTransitionCommand`: al transicionar, si el nuevo estado tiene un APE asignado, escribir `ape: {name: <x>, state: <initial_state>}`. Si no tiene APE (IDLE), escribir `ape: null`.

**Test pseudocódigo:**
```
test('fsm transition to ANALYZE auto-activates socrates at initial_state')
  setup: state.yaml = {state: IDLE, issue: '99'}
  executeTransition(event: 'start_analyze')
  state = readStateYaml()
  expect state.state == 'ANALYZE'
  expect state.ape.name == 'socrates'
  expect state.ape.state == 'clarification'
```

### 5b.7 Modificar `iq ape prompt` para leer sub-estado automáticamente

- [x] **RED**: Tests:
  - Sin `--state` flag: lee sub-estado de state.yaml y ensambla `base_prompt + states[ape.state].prompt`
  - Con `--state` flag: override manual (útil para debug)
  - APE en `_DONE`: retorna solo base_prompt (o error — decidir)
- [x] **GREEN**: Modificar `ApePromptCommand.execute()`:
  1. Si `input.subState` provisto → usarlo (override)
  2. Si no → leer `ape.state` de state.yaml
  3. Si `ape.state == _DONE` → retornar base_prompt sin sub-estado
  4. Ensamblar prompt

### 5b.8 Extender `iq fsm state --json` con info de APE

- [x] **RED**: Tests:
  - `iq fsm state --json` en ANALYZE con socrates:assumptions → JSON incluye `ape: {name: "socrates", state: "assumptions", transitions: [...]}`
  - En IDLE → JSON tiene `ape: null`
- [x] **GREEN**: Modificar `FsmStateOutput.toJson()` y `FsmStateCommand.execute()` para incluir campo `ape` leyendo state.yaml + YAML del APE.

### 5b.9 Pruebas manuales

- [x] Compilar `code/cli/bin/inquiry.exe`
- [x] `iq fsm state` → muestra APE activo con sub-estado
- [x] `iq ape state` → muestra sub-estado y transiciones válidas
- [x] `iq ape transition --event next` → avanza sub-estado
- [x] `iq ape prompt` (sin --state) → prompt incluye sub-estado actual
- [x] `iq ape transition --event complete` → llega a `_DONE`
- [x] `iq fsm transition --event complete_analysis` → limpia APE, activa descartes

**Riesgo**: Complejidad del schema YAML crece. Cada APE necesita transiciones bien diseñadas.
**Mitigación**: TDD primero. Si un APE tiene transiciones ambiguas, usar patrón lineal simple (next/back/complete). Iterar post-v0.2.0.

---

## Phase 6 — Rediseñar `inquiry.agent.md` como firmware thin

**Objetivo**: Reemplazar el monolito (~600 líneas) por un firmware de ~20-30 líneas que ejecuta el scheduler loop dual.
**Dependencias**: Phase 2 (`iq fsm state --json`), Phase 5b (`iq ape state/transition/prompt`).
**TDD**: Test de contenido del template.

### 6.1 Escribir el firmware template

- [x] Crear `assets/agents/inquiry.agent.md` (nuevo contenido, reemplaza monolito).
- [x] El firmware debe contener SOLO:
  1. Identidad: "Eres el scheduler de Inquiry"
  2. Outer loop (FSM principal):
     - Ejecuta `iq fsm state --json` → lee `state`, `ape`, `transitions`
     - Si no hay APE activo (IDLE): presenta transiciones al usuario
  3. Inner loop (FSM per-APE):
     - Ejecuta `iq ape state` → lee sub-estado y transiciones internas
     - Ejecuta `iq ape prompt` → obtiene prompt del sub-agente
     - Opera como el sub-agente indica
     - Cuando el usuario apruebe: `iq ape transition --event <e>`
     - Si `_DONE`: solicita transición del FSM principal
  4. Transición principal: `iq fsm transition --event <e>`
  5. Regla: "NUNCA escribas en `.inquiry/` directamente"
  6. Regla: "Si un comando falla, reporta y ofrece retry"
- [x] Verificar que el archivo no excede 50 líneas (excluido frontmatter).

### 6.2 Preservar monolito como referencia

- [x] Mover monolito actual a `assets/agents/inquiry.agent.md.legacy` (o `assets/archive/`).
- [x] Esto permite comparación y rollback de emergencia.

### 6.3 Test de contenido del firmware

- [x] **RED**: Test que lee `assets/agents/inquiry.agent.md` y valida:
  - Contiene `iq fsm state`
  - Contiene `iq ape state`
  - Contiene `iq ape prompt`
  - Contiene `iq ape transition`
  - Contiene `iq fsm transition`
  - NO contiene prompts de sub-agentes (no "epistemic humility", "用の美")
  - Longitud < 60 líneas
- [x] **GREEN**: El template de 6.1 pasa.

**Test pseudocódigo:**
```
test('firmware agent is thin and references all CLI commands')
  content = File('assets/agents/inquiry.agent.md').readAsStringSync()
  expect content contains 'iq fsm state'
  expect content contains 'iq ape state'
  expect content contains 'iq ape prompt'
  expect content contains 'iq ape transition'
  expect content contains 'iq fsm transition'
  expect content.split('\n').length < 60
  expect content NOT contains 'epistemic humility'
  expect content NOT contains '用の美'
```

**Riesgo**: ALTO. El LLM podría no seguir el loop dual (outer + inner).
**Mitigación**: Prompt estructurado como pseudocódigo. Si el LLM no sigue, iterar template. La arquitectura es correcta independientemente del template.

---

## Phase 7 — `iq init` regeneración con detección de shell

**Objetivo**: `iq init` detecta shell (bash/powershell), genera agent + skills con comandos shell-aware. Genera `state.yaml` con formato nuevo (`ape:` field).
**Dependencias**: Phase 6 (necesita firmware template), Phase 5b (nuevo formato state.yaml).
**TDD**: RED→GREEN.

### 7.1 Detectar shell

- [x] **RED**: Test que verifica: en Windows, `detectShell()` retorna `powershell`. En Linux/Mac (o WSL), retorna `bash`.
- [x] **GREEN**: Implementar `detectShell()` basado en `Platform.isWindows` + variables de entorno (`SHELL`, `ComSpec`).

### 7.2 Skills shell-aware

- [x] **RED**: Test que verifica: skill generada para powershell contiene `iq` (no `./iq`).
- [x] **GREEN**: Revisar templates de skills en `assets/skills/`. Si ya son shell-agnostic (solo usan `iq`, `git`, `gh`), este paso es no-op.

### 7.3 Regenerar firmware en init

- [x] **RED**: Test que verifica: tras `iq init`, el agent desplegado contiene el firmware thin.
- [x] **GREEN**: Actualizar `InitCommand` y/o `TargetDeployer` para usar el nuevo template de Phase 6.

### 7.4 state.yaml con formato nuevo

- [x] **RED**: Test que verifica: `iq init` genera `state.yaml` con `state: IDLE\nissue: null\nape: null\n`.
- [x] **GREEN**: Actualizar `_ensureStateYaml` en `init.dart`.

### 7.5 Test de idempotencia

- [x] **RED**: Ejecutar `iq init` dos veces → segundo run no falla, resultado idéntico.
- [x] **GREEN**: El init ya es idempotente; verificar que sigue siéndolo con los cambios.

**Riesgo**: La detección de shell puede fallar en entornos híbridos (WSL, Git Bash en Windows).
**Mitigación**: Fallback a `powershell` en Windows, `bash` en todo lo demás.

---

## Decisión: Dev container para e2e (Phase 8)

> **Contexto**: Instalar y desplegar inquiry para pruebas reales daña el entorno de desarrollo actual.
> **Decisión**: Phases 5b-7 continúan en Windows compilando a `code/cli/bin/inquiry.exe` sin instalar. Phase 8 introduce `.devcontainer/devcontainer.json` con Dart SDK para ejecutar `install.sh → init → doctor → fsm state → ape state → ape prompt` en entorno desechable.
> **Beneficio**: Valida `install.sh` (Linux), paridad con CI (GitHub Actions), entorno destruible.

---

## Phase 8 — Integración y cobertura final

**Objetivo**: Verificar que todo funciona end-to-end con el modelo RTOS dual. Cobertura ≥ 95% en lógica FSM + APE.
**Dependencias**: Todas las fases anteriores.
**TDD**: Tests de integración.

### 8.1 Test end-to-end del scheduler loop dual

- [x] Test que simula un ciclo completo con ambos FSMs:
  1. `iq init` → `.inquiry/state.yaml` con `state: IDLE, ape: null`
  2. `iq fsm transition --event start_analyze` → `state: ANALYZE, ape: {socrates, clarification}`
  3. `iq ape state` → `{name: socrates, state: clarification, transitions: [next, skip]}`
  4. `iq ape prompt` → prompt con clarification focus
  5. `iq ape transition --event next` → `ape.state: assumptions`
  6. Repetir hasta `iq ape transition --event complete` → `ape.state: _DONE`
  7. `iq fsm transition --event complete_analysis` → `state: PLAN, ape: {descartes, decomposition}`
  8. Repetir sub-ciclo descartes hasta _DONE
  9. `iq fsm transition --event approve_plan` → `state: EXECUTE, ape: {basho, implement}`
  10. Repetir sub-ciclo basho hasta _DONE
  11. Continuar hasta EVOLUTION → IDLE

**Test pseudocódigo:**
```
test('full RTOS dual-FSM cycle from IDLE back to IDLE')
  setup: tmpDir con .git/, assets/fsm/, assets/apes/

  // IDLE → ANALYZE (auto-activates socrates:clarification)
  transResult = fsmTransition(event: 'start_analyze')
  apeState = apeState()
  expect apeState.name == 'socrates'
  expect apeState.state == 'clarification'

  // Walk socrates sub-FSM to completion
  apeTransition(event: 'next')  // → assumptions
  apeTransition(event: 'next')  // → evidence
  apeTransition(event: 'next')  // → perspectives
  apeTransition(event: 'next')  // → implications
  apeTransition(event: 'next')  // → meta_reflection
  apeTransition(event: 'complete')  // → _DONE

  // ANALYZE → PLAN (auto-activates descartes:decomposition)
  fsmTransition(event: 'complete_analysis')
  apeState = apeState()
  expect apeState.name == 'descartes'
  expect apeState.state == 'decomposition'

  // ... continue pattern through EXECUTE, END, EVOLUTION, IDLE
```

### 8.2 Cobertura

- [x] Ejecutar `dart test --coverage` y verificar cobertura ≥ 95% en:
  - `lib/modules/fsm/commands/state.dart`
  - `lib/modules/fsm/commands/transition.dart`
  - `lib/modules/fsm/effect_executor.dart`
  - `lib/modules/ape/commands/prompt.dart`
  - `lib/modules/ape/commands/state.dart`
  - `lib/modules/ape/commands/transition.dart`
  - `lib/modules/ape/ape_definition.dart`
  - `lib/fsm_contract.dart`

### 8.3 Verificación manual en dev container

- [x] Crear `.devcontainer/devcontainer.json` con Dart SDK
- [x] `install.sh` → `iq init` → `iq doctor`
- [x] `iq fsm state --json` → verificar JSON con campo `ape`
- [x] Abrir VS Code con Copilot → verificar que el firmware thin activa el scheduler loop dual
- [x] Documentar hallazgos si el LLM no sigue el loop

### 8.4 Cleanup

- [x] Eliminar `inquiry.agent.md.legacy` si el firmware thin está validado
- [x] Sincronizar `build/assets/` (incluyendo `apes/`)
- [x] Actualizar `README.md` del CLI si la interfaz pública cambió
- [x] `dart analyze` — 0 warnings

**Riesgo**: La prueba manual con LLM puede revelar que el firmware no funciona como esperado.
**Mitigación**: Esto es esperado y aceptable. El firmware es una hipótesis. Si falla, se itera el template sin cambiar la arquitectura subyacente (los comandos CLI son correctos independientemente de si el LLM los usa bien).

---

## Resumen de entregables por fase

| Phase | Entregable principal | Tests nuevos | Archivos nuevos/modificados |
|-------|---------------------|-------------|---------------------------|
| 0 | 2 bugs corregidos | 2 | `doctor.dart`, `init.dart` |
| 1 | Módulo renombrado | 0 (actualizados) | `fsm_builder.dart`, `inquiry_cli.dart` |
| 2 | `iq fsm state --json` | ~14 | `fsm/commands/state.dart` |
| 3 | Effects ejecutados | ~12 | `fsm/effect_executor.dart`, `transition.dart` |
| 4 | 4 YAMLs de sub-agentes | ~15 | `assets/apes/*.yaml`, `ape_definition.dart` |
| 5 | `iq ape prompt` | ~20 | `ape/commands/prompt.dart`, `ape_builder.dart` |
| 5b | Sub-FSM RTOS per-APE | ~25 | `ape/commands/{state,transition}.dart`, YAMLs + transitions, state.yaml format |
| 6 | Firmware thin (loop dual) | ~3 | `assets/agents/inquiry.agent.md` |
| 7 | Init regenerado + state format | ~5 | `init.dart` |
| 8 | Integración dual-FSM e2e | ~5 | `.devcontainer/`, tests only |

| 8b | QA bug fixes (BUG-1/2/3) | 5 | `ape/commands/{transition,prompt}.dart`, `effect_executor.dart` |

**Total estimado**: ~100+ tests, ~15 archivos nuevos, ~10 archivos modificados.

---

## Phase 8b — Bug fixes descubiertos en QA e2e (Linux)

**Origen**: QA completo ejecutado en dev container Linux (2026-04-26). 14 secciones, 285 tests pasaron, pero e2e binario reveló 3 bugs de error handling.
**Dependencias**: Phase 8 (descubiertos durante e2e).
**TDD**: RED→GREEN por cada fix.
**Análisis completo**: `cleanrooms/145-extract-inquiry-core/qa/index.md`

### 8b.0 Bugs descubiertos

| Bug | Severidad | Síntoma | Root cause |
|-----|-----------|---------|------------|
| BUG-1 | MEDIUM | `ape transition`/`ape prompt` errores de dominio → stacktrace + exit 255 | Usa `throw StateError` en vez de `throw CommandException` |
| BUG-2 | LOW | EXECUTE→END re-inicializa basho a `implement` en vez de preservar `_DONE` | `updateState()` siempre llama `_resolveInitialState()` sin verificar si el mismo APE ya estaba activo |
| BUG-3 | MEDIUM | `ape transition`/`ape prompt` sin flags → stacktrace + exit 255 | Factory constructors lanzan `ArgumentError` que el SDK no captura |

**Patrón sistémico**: El módulo `ape` usa un patrón de error handling diferente al módulo `fsm`. El SDK solo captura `CommandException`. Todos los `StateError`/`ArgumentError` escapan al runtime.

### 8b.1 Fix A — Missing flags (BUG-3) ✅

- [x] **RED**: Test `throws CommandException when event flag is missing` (ape_transition_test.dart)
- [x] **RED**: Test `throws CommandException when name flag is missing` (ape_prompt_test.dart)
- [x] **GREEN** `transition.dart`: `ApeTransitionInput.event` → `String?` nullable. Factory acepta null. Validación en `execute()` con `CommandException(code: 'MISSING_EVENT', exitCode: ExitCode.validationFailed)`.
- [x] **GREEN** `prompt.dart`: `ApePromptInput.name` → `String?` nullable. Factory acepta null. Validación en `execute()` con `CommandException(code: 'MISSING_NAME', exitCode: ExitCode.validationFailed)`.

### 8b.2 Fix B — Domain errors como CommandException (BUG-1) ✅

- [x] **RED**: Actualizar 9 tests existentes: `isA<StateError>()` → `isA<CommandException>()` con `.having()` en `code` y `exitCode`.
- [x] **GREEN** `transition.dart`: Reemplazar 4× `throw StateError(...)` → `throw CommandException(...)`:
  - `NO_ACTIVE_APE` → exit 6 (conflict)
  - `APE_COMPLETED` → exit 6 (conflict)
  - `APE_NOT_FOUND` → exit 4 (notFound)
  - `INVALID_APE_EVENT` → exit 7 (validationFailed)
- [x] **GREEN** `prompt.dart`: Reemplazar 2× `throw StateError(...)`:
  - `APE_NOT_FOUND` → exit 4 (notFound)
  - `APE_NOT_ACTIVE` → exit 6 (conflict)

### 8b.3 Fix C — END preserva APE sub-estado (BUG-2) ✅

- [x] **RED**: Test `preserves APE _DONE state when same APE continues (EXECUTE→END)` (effect_executor_test.dart)
- [x] **RED**: Test `re-initializes APE when transitioning to state with DIFFERENT APE` (effect_executor_test.dart)
- [x] **GREEN** `effect_executor.dart`: En `updateState()`, si `_stateApes[newState] == currentState.apeName`, preservar `currentState.apeState` en vez de re-inicializar.

### 8b.4 Verificación ✅

- [x] `dart analyze` — 0 issues
- [x] `dart test` — 290 tests, all pass (285 + 5 nuevos)
- [x] Compilar binario y verificar: BUG-1 exit 4/6/7 sin stacktrace, BUG-2 basho:_DONE preservado, BUG-3 exit 7 sin stacktrace

---

## Criterio de éxito global

La hipótesis se confirma si:
1. `iq fsm state --json` retorna JSON válido con campo `ape` (nombre + sub-estado + transiciones internas)
2. `iq fsm transition --event <e>` ejecuta effects, muta `.inquiry/`, y auto-activa el APE correspondiente en su `initial_state`
3. `iq ape state` retorna sub-estado actual y transiciones internas válidas
4. `iq ape transition --event <e>` valida y ejecuta transiciones internas del APE
5. `iq ape prompt` retorna prompt determinístico sin flags manuales (lee sub-estado de state.yaml)
6. `inquiry.agent.md` tiene < 60 líneas, referencia los 5 comandos, y describe el loop dual (outer + inner)
7. `dart test` pasa con 0 fallos y ≥ 95% cobertura en módulos nuevos
8. `iq doctor` reporta skills correctamente
9. `iq init` genera `state.yaml` con formato nuevo (`ape:` field)
7. `iq init` crea `./cleanrooms/` (no `docs/cleanrooms`)
