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
- [ ] Agregar flag `--json` (default true, para futuro soporte texto) — **diferido**: toText() ya funciona
- [ ] Verificar manualmente: `iq fsm state` retorna JSON válido

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

- [ ] **RED**: Test para `ApePromptCommand` con `name=socrates`, estado ANALYZE, sub-estado `clarification` → assert output contiene `base_prompt` + prompt de `clarification`.
- [ ] **GREEN**: Crear `lib/modules/ape/commands/prompt.dart` con `ApePromptInput`, `ApePromptOutput`, `ApePromptCommand`.

**Test pseudocódigo:**
```
test('ape prompt socrates returns assembled prompt for current sub-state')
  setup: crear tmpDir con .inquiry/state.yaml (state: ANALYZE, ape_state: {socrates: clarification})
         copiar assets/apes/socrates.yaml
  result = ApePromptCommand(ApePromptInput(name: 'socrates', workingDirectory: tmpDir)).execute()
  expect result.prompt contains 'SOCRATES'
  expect result.prompt contains 'Clarification questions'
```

### 5.2 Ensamblar prompt

- [ ] **RED**: Test que verifica el ensamblaje: `base_prompt + "\n\n## Current Focus\n\n" + states[sub_state].prompt`.
- [ ] **GREEN**: Leer YAML con `ApeDefinition`, leer sub-estado de `.inquiry/state.yaml`, concatenar.

### 5.3 Sub-agente no existe

- [ ] **RED**: Test con `name=nonexistent` → assert error con código claro (`APE_NOT_FOUND`).
- [ ] **GREEN**: Validación en comando.

### 5.4 Sub-agente no activo en fase actual

- [ ] **RED**: Test con `name=socrates` en estado `EXECUTE` (donde socrates es DORMANT) → assert error `APE_NOT_ACTIVE`.
- [ ] **GREEN**: Consultar mapeo estado→apes (de Phase 2.3) para validar.

### 5.5 Registrar módulo `ape`

- [ ] Crear `lib/modules/ape/ape_builder.dart`
- [ ] Registrar en `inquiry_cli.dart`: `cli.module('ape', (m) => buildApeModule(m))`
- [ ] Test de integración: `iq ape prompt socrates` retorna prompt válido

### 5.6 Test de regresión vs. monolito

- [ ] **RED**: Test que compara secciones clave del prompt generado contra el contenido del monolito original (snapshot test).
- [ ] **GREEN**: Ajustar YAMLs si hay divergencias significativas.

**Test pseudocódigo:**
```
test('generated socrates prompt covers all key sections from monolith')
  monolith = File('assets/agents/inquiry.agent.md').readAsStringSync()
  prompt = ApePromptCommand(...socrates, ANALYZE, clarification...).execute().prompt
  // Verificar que conceptos clave están presentes
  expect prompt contains 'Socratic method'
  expect prompt contains 'epistemic humility'
  expect prompt contains 'Clarification'
```

**Riesgo**: Prompts modulares degradan comportamiento del LLM vs. monolito.
**Mitigación**: Tests de regresión (5.6). Si la degradación es observable, se itera el YAML.

---

## Phase 6 — Rediseñar `inquiry.agent.md` como firmware thin

**Objetivo**: Reemplazar el monolito (~600 líneas) por un firmware de ~10-15 líneas que ejecuta el scheduler loop.
**Dependencias**: Phase 2 (`iq fsm state --json`), Phase 5 (`iq ape prompt <name>`).
**TDD**: Test de contenido del template.

### 6.1 Escribir el firmware template

- [ ] Crear `assets/agents/inquiry.agent.md` (nuevo contenido, reemplaza monolito).
- [ ] El firmware debe contener SOLO:
  1. Identidad: "Eres el scheduler de Inquiry"
  2. Loop: "1) Ejecuta `iq fsm state --json` 2) Para cada ape en `apes`: ejecuta `iq ape prompt <name>` 3) Despacha 4) Cuando el usuario apruebe transición: `iq fsm transition --event <e>` 5) Repite"
  3. Regla: "NUNCA escribas en `.inquiry/` directamente"
  4. Regla: "Si un comando falla, reporta y ofrece retry"
- [ ] Verificar que el archivo no excede 20 líneas (excluido frontmatter).

### 6.2 Preservar monolito como referencia

- [ ] Mover monolito actual a `assets/agents/inquiry.agent.md.legacy` (o `assets/archive/`).
- [ ] Esto permite comparación durante Phase 5.6 y rollback de emergencia.

### 6.3 Test de contenido del firmware

- [ ] **RED**: Test que lee `assets/agents/inquiry.agent.md` y valida:
  - Contiene `iq fsm state`
  - Contiene `iq ape prompt`
  - Contiene `iq fsm transition`
  - NO contiene prompts de sub-agentes (no "SOCRATES", "DESCARTES" como secciones completas)
  - Longitud < 50 líneas
- [ ] **GREEN**: El template de 6.1 pasa.

**Test pseudocódigo:**
```
test('firmware agent is thin and references CLI commands')
  content = File('assets/agents/inquiry.agent.md').readAsStringSync()
  expect content contains 'iq fsm state'
  expect content contains 'iq ape prompt'
  expect content contains 'iq fsm transition'
  expect content.split('\n').length < 50
  // No debe contener prompts completos de sub-agentes
  expect content NOT contains '## Mindset'  // sección de sub-agente
  expect content NOT contains 'epistemic humility'  // contenido de socrates
```

**Riesgo**: ALTO. El LLM podría ignorar el loop del firmware (el monolito funcionaba por volumen de instrucciones).
**Mitigación**: Prompt ultra-corto y enfático. Si en pruebas manuales el LLM no sigue el loop, iterar el template (agregar énfasis, repetición, ejemplos inline). Esto es el riesgo principal de v0.2.0.

---

## Phase 7 — `iq init` regeneración con detección de shell

**Objetivo**: `iq init` detecta shell (bash/powershell), genera agent + skills con comandos shell-aware.
**Dependencias**: Phase 6 (necesita firmware template), Phase 0.2 (bug de cleanrooms corregido).
**TDD**: RED→GREEN.

### 7.1 Detectar shell

- [ ] **RED**: Test que verifica: en Windows, `detectShell()` retorna `powershell`. En Linux/Mac (o WSL), retorna `bash`.
- [ ] **GREEN**: Implementar `detectShell()` basado en `Platform.isWindows` + variables de entorno (`SHELL`, `ComSpec`).

**Test pseudocódigo:**
```
test('detectShell returns powershell on Windows')
  // Con mock de Platform.isWindows = true
  expect detectShell() == ShellType.powershell

test('detectShell returns bash when SHELL=/bin/bash')
  // Con mock de environment SHELL=/bin/bash
  expect detectShell() == ShellType.bash
```

### 7.2 Skills shell-aware

- [ ] **RED**: Test que verifica: skill `issue-start` generada para powershell contiene `iq` (no `./iq`), y para bash contiene `iq`.
- [ ] **GREEN**: Revisar templates de skills en `assets/skills/`. Si contienen comandos shell-specific, parametrizarlos.
- [ ] Nota: Si las skills actuales ya son shell-agnostic (solo usan `iq`, `git`, `gh`), este paso puede ser no-op.

### 7.3 Regenerar firmware en init

- [ ] **RED**: Test que verifica: tras `iq init`, el archivo `~/.copilot/agents/inquiry.agent.md` contiene el firmware thin (no el monolito).
- [ ] **GREEN**: Actualizar `InitCommand` y/o `TargetDeployer` para usar el nuevo template de Phase 6.

### 7.4 Test de idempotencia

- [ ] **RED**: Ejecutar `iq init` dos veces → segundo run no falla, resultado idéntico.
- [ ] **GREEN**: El init ya es idempotente; verificar que sigue siéndolo con los cambios.

**Riesgo**: La detección de shell puede fallar en entornos híbridos (WSL, Git Bash en Windows).
**Mitigación**: Fallback a `powershell` en Windows, `bash` en todo lo demás. El usuario puede override en `.inquiry/config.yaml` (futuro, no en scope v0.2.0).

---

## Phase 8 — Integración y cobertura final

**Objetivo**: Verificar que todo funciona end-to-end. Cobertura 100% en lógica FSM y generación de prompts.
**Dependencias**: Todas las fases anteriores.
**TDD**: Tests de integración.

### 8.1 Test end-to-end del scheduler loop

- [ ] Test que simula un ciclo completo:
  1. `iq init` en tmpDir → `.inquiry/` creado, agent deployed
  2. `iq fsm state --json` → estado IDLE, 0 apes, transitions incluye `start_analyze`
  3. `iq fsm transition --event start_analyze` → estado ANALYZE, `.inquiry/state.yaml` actualizado
  4. `iq fsm state --json` → estado ANALYZE, apes incluye socrates
  5. `iq ape prompt socrates` → prompt ensamblado válido
  6. `iq fsm transition --event complete_analysis` → estado PLAN
  7. `iq ape prompt descartes` → prompt ensamblado válido
  8. Continuar hasta EVOLUTION → IDLE

**Test pseudocódigo:**
```
test('full APE cycle from IDLE through all states back to IDLE')
  setup: tmpDir con .git/, transition_contract.yaml, assets/apes/*.yaml
  
  // IDLE → ANALYZE
  initResult = InitCommand(tmpDir).execute()
  stateResult = FsmStateCommand(tmpDir).execute()
  expect stateResult.state == 'IDLE'
  
  transResult = FsmTransitionCommand(tmpDir, event: 'start_analyze').execute()
  expect transResult.nextState == 'ANALYZE'
  
  stateResult = FsmStateCommand(tmpDir).execute()
  expect stateResult.apes[0].name == 'socrates'
  
  promptResult = ApePromptCommand(tmpDir, name: 'socrates').execute()
  expect promptResult.prompt.isNotEmpty
  
  // ANALYZE → PLAN → EXECUTE → END → EVOLUTION → IDLE
  // ... (mismo patrón para cada transición)
```

### 8.2 Cobertura

- [ ] Ejecutar `dart test --coverage` y verificar cobertura ≥ 95% en:
  - `lib/modules/fsm/commands/state.dart`
  - `lib/modules/fsm/commands/transition.dart`
  - `lib/modules/fsm/effect_executor.dart`
  - `lib/modules/ape/commands/prompt.dart`
  - `lib/modules/ape/ape_definition.dart`
  - `lib/fsm_contract.dart`
- [ ] Identificar líneas no cubiertas y agregar tests faltantes.

### 8.3 Verificación manual

- [ ] En un repo real, ejecutar `iq init` → `iq fsm state --json` → verificar JSON legible.
- [ ] Abrir VS Code con Copilot → verificar que el firmware thin activa el scheduler loop.
- [ ] Si el LLM no sigue el loop → documentar hallazgo y proponer iteración del template.

### 8.4 Cleanup

- [ ] Eliminar `inquiry.agent.md.legacy` si el firmware thin está validado.
- [ ] Actualizar `assets/` en `build/assets/` (mantener sincronía per repo memory).
- [ ] Actualizar `README.md` del CLI si la interfaz pública cambió.
- [ ] `dart analyze` — 0 warnings.

**Riesgo**: La prueba manual con LLM puede revelar que el firmware no funciona como esperado.
**Mitigación**: Esto es esperado y aceptable. El firmware es una hipótesis. Si falla, se itera el template sin cambiar la arquitectura subyacente (los comandos CLI son correctos independientemente de si el LLM los usa bien).

---

## Resumen de entregables por fase

| Phase | Entregable principal | Tests nuevos | Archivos nuevos/modificados |
|-------|---------------------|-------------|---------------------------|
| 0 | 2 bugs corregidos | 2 | `doctor.dart`, `init.dart` |
| 1 | Módulo renombrado | 0 (actualizados) | `fsm_builder.dart`, `inquiry_cli.dart` |
| 2 | `iq fsm state --json` | ~5 | `fsm/commands/state.dart` |
| 3 | Effects ejecutados | ~5 | `fsm/effect_executor.dart`, `transition.dart` |
| 4 | 4 YAMLs de sub-agentes | ~4 | `assets/apes/*.yaml`, `ape_definition.dart` |
| 5 | `iq ape prompt <name>` | ~5 | `ape/commands/prompt.dart`, `ape_builder.dart` |
| 6 | Firmware thin | ~1 | `assets/agents/inquiry.agent.md` |
| 7 | Init regenerado | ~3 | `init.dart` |
| 8 | Integración + cobertura | ~2 | (tests only) |

**Total estimado**: ~27 tests nuevos, ~12 archivos nuevos, ~8 archivos modificados.

---

## Criterio de éxito global

La hipótesis se confirma si:
1. `iq fsm state --json` retorna JSON válido en cada estado
2. `iq fsm transition --event <e>` ejecuta effects y muta `.inquiry/`
3. `iq ape prompt <name>` retorna prompt determinístico dado (YAML version + estado)
4. `inquiry.agent.md` tiene < 50 líneas y referencia los 3 comandos
5. `dart test` pasa con 0 fallos y ≥ 95% cobertura en módulos nuevos
6. `iq doctor` reporta skills correctamente
7. `iq init` crea `./cleanrooms/` (no `docs/cleanrooms`)
