# Plan: APE VS Code Extension v0.0.1

**Issue:** #082
**Branch:** `082-ape-vscode-extension`
**Date:** 2026-04-19
**Input:** [diagnosis.md](analyze/diagnosis.md)
**Approach:** TDD (RED → GREEN → REFACTOR)

---

## Hipótesis

Si implementamos estas 6 fases en orden, obtendremos una extensión publicable que:
1. Se activa solo cuando `.ape/` existe en el workspace
2. Muestra el estado FSM en la status bar en tiempo real
3. Permite toggle de `evolution.enabled` en config.yaml
4. Permite agregar notas a mutations.md desde el command palette

Si alguna fase falla su verificación, el experimento se detiene y regresa a análisis.

## Regla de frontera

Si requiere ejecutar el binario `ape`, está FUERA de v0.0.1. Esta extensión solo lee y escribe archivos.

---

## Phase 1: Scaffold — Compilar, testear, empaquetar

**Entry criteria:** Node.js ≥ 18, directorio `code/vscode/` existe
**Dependencias:** ninguna

**Steps:**

- [x] **1.1** Crear `package.json` con: name `ape-vscode`, displayName `APE`, publisher `ccisnedev`, version `0.0.1`, engines `vscode ^1.85.0`, main `./out/extension.js`, activationEvents `workspaceContains:.ape/`
- [x] **1.2** Crear `tsconfig.json`: target ES2022, module Node16, strict true, outDir `./out`, rootDir `./src`, sourceMap true
- [x] **1.3** Crear `webpack.config.js`: entry `./src/extension.ts`, output `./out/extension.js`, target node, externals `vscode`, ts-loader
- [x] **1.4** Crear `src/extension.ts` con `activate()` y `deactivate()` vacíos
- [x] **1.5** Instalar devDependencies: `typescript`, `webpack`, `webpack-cli`, `ts-loader`, `@types/vscode`, `@types/mocha`, `@types/node`, `mocha`, `@vscode/test-electron`, `@vscode/vsce`
- [x] **1.6** Crear scripts npm: `compile`, `watch`, `test:unit` (mocha puro para lógica), `test:integration` (@vscode/test-electron), `package`
- [x] **1.7** Crear `test/unit/smoke.test.ts`: **TEST** "extension module exports activate and deactivate" — importar el módulo compilado y verificar que las funciones existen
- [x] **1.8** Crear `.vscodeignore` (excluir src/, test/, webpack.config.js, tsconfig.json, node_modules/) y `.gitignore` (out/, node_modules/, *.vsix)

**Verificación:**
```bash
npm run compile        # → 0 errors
npm run test:unit      # → 1 test pass
npx vsce package --no-dependencies  # → ape-vscode-0.0.1.vsix
```

**Riesgo:** webpack config incorrecta puede producir bundle que VS Code no carga. Verificar con `code --extensionDevelopmentPath=.` antes de avanzar.

---

## Phase 2: Lógica pura — YAML y Markdown (TDD)

**Entry criteria:** Phase 1 completa, build y test:unit pasan
**Dependencias:** Phase 1

Esta es la fase más importante. Todo lo que la extensión hace en v0.0.1 se reduce a leer/escribir 3 archivos. La lógica es pura (sin VS Code API) y se testea con mocha directo — rápido y sin overhead de test-electron.

### 2A: Parsear state.yaml

- [x] **2A.1** Instalar dependencia `yaml` (`npm install yaml`)
- [x] **2A.2** Crear fixtures: `test/fixtures/state-analyze.yaml`, `test/fixtures/state-idle.yaml`, `test/fixtures/state-empty.yaml`
  ```yaml
  # state-analyze.yaml
  cycle:
    phase: ANALYZE
    task: "042"
  ```
  ```yaml
  # state-idle.yaml
  cycle:
    phase: IDLE
    task: ""
  ```
- [x] **2A.3** Crear `test/unit/state-parser.test.ts` — RED:
  - **TEST** "parseState con ANALYZE y task 042 retorna {phase: 'ANALYZE', task: '042'}"
  - **TEST** "parseState con IDLE retorna {phase: 'IDLE', task: ''}"
  - **TEST** "parseState con string vacío retorna defaults {phase: 'IDLE', task: ''}"
  - **TEST** "parseState con YAML inválido retorna defaults"
  - **TEST** "parseState con phase desconocido retorna el string tal cual"
- [x] **2A.4** Crear `src/parsers.ts` e implementar `parseState(content: string): ApeState` — GREEN
- [x] **2A.5** Definir `interface ApeState { phase: string; task: string }` en `src/types.ts`

### 2B: Leer/escribir config.yaml

- [x] **2B.1** Crear fixtures: `test/fixtures/config-enabled.yaml`, `test/fixtures/config-disabled.yaml`, `test/fixtures/config-missing.yaml` (vacío)
  ```yaml
  # config-enabled.yaml
  evolution:
    enabled: true
  ```
- [x] **2B.2** Crear `test/unit/config-parser.test.ts` — RED:
  - **TEST** "parseConfig con evolution.enabled=true retorna {evolutionEnabled: true}"
  - **TEST** "parseConfig con evolution.enabled=false retorna {evolutionEnabled: false}"
  - **TEST** "parseConfig con string vacío retorna {evolutionEnabled: false}"
  - **TEST** "parseConfig con YAML inválido retorna {evolutionEnabled: false}"
  - **TEST** "serializeConfig({evolutionEnabled: true}) produce YAML válido con evolution.enabled: true"
  - **TEST** "serializeConfig({evolutionEnabled: false}) produce YAML válido con evolution.enabled: false"
- [x] **2B.3** Implementar `parseConfig` y `serializeConfig` en `src/parsers.ts` — GREEN

### 2C: Append a mutations.md

- [x] **2C.1** Crear `test/unit/mutations.test.ts` — RED:
  - **TEST** "formatMutation con texto retorna '- <texto>\n'"
  - **TEST** "formatMutation con texto y timestamp retorna '- [YYYY-MM-DD HH:mm] <texto>\n'"
  - **TEST** "formatMutation escapa caracteres que romperían el markdown (|, newlines)"
- [x] **2C.2** Implementar `formatMutation(text: string, withTimestamp: boolean): string` en `src/parsers.ts` — GREEN

### 2D: REFACTOR

- [x] **2D.1** Revisar naming, extraer types si necesario. `npm run compile && npm run test:unit`

**Verificación:**
```bash
npm run test:unit  # → todos los tests de parsers pasan (~13 tests)
```

---

## Phase 3: Status Bar — Estado FSM en tiempo real (TDD)

**Entry criteria:** Phase 2 completa
**Dependencias:** Phase 2 (usa `parseState`)

### 3A: Formateo del status bar (lógica pura)

- [ ] **3A.1** Crear `test/unit/status-format.test.ts` — RED:
  - **TEST** "formatStatus('IDLE', '') retorna {text: '$(circle-outline) APE: IDLE', tooltip: 'APE: IDLE'}"
  - **TEST** "formatStatus('ANALYZE', '042') retorna {text: '$(search) APE: ANALYZE #042', tooltip: 'APE: ANALYZE — Task #042'}"
  - **TEST** "formatStatus('PLAN', '042') retorna {text: '$(list-ordered) APE: PLAN #042', ...}"
  - **TEST** "formatStatus('EXECUTE', '042') retorna {text: '$(rocket) APE: EXECUTE #042', ...}"
  - **TEST** "formatStatus('EVOLUTION', '') retorna {text: '$(sparkle) APE: EVOLUTION', ...}"
  - **TEST** "formatStatus con phase desconocido retorna el text tal cual con ícono default"
- [ ] **3A.2** Implementar `formatStatus(phase: string, task: string): StatusBarData` en `src/status-bar.ts` — GREEN
- [ ] **3A.3** Definir mapa de phase → codicon icon en el mismo archivo

### 3B: StatusBarItem + FileSystemWatcher (integración VS Code)

- [ ] **3B.1** Crear `test/integration/status-bar.test.ts` — RED:
  - **TEST** "createStatusBar crea un StatusBarItem visible"
  - **TEST** "updateStatusBar con ApeState actualiza text y tooltip del item"
  - **TEST** "dispose limpia el item y el watcher"
- [ ] **3B.2** Implementar `createStatusBar`, `updateStatusBar`, `disposeStatusBar` en `src/status-bar.ts` — GREEN
  - `createStatusBar()`: llama `vscode.window.createStatusBarItem(StatusBarAlignment.Left)`
  - Lee `.ape/state.yaml` inicial → `parseState` → `formatStatus` → asigna al item
  - Crea `FileSystemWatcher` para `.ape/state.yaml` → en onChange/onCreate relee y actualiza
  - Retorna `{item, watcher}` como disposables
- [ ] **3B.3** REFACTOR — verificar que el watcher no filtra eventos válidos

**Verificación:**
```bash
npm run test:unit         # → tests de formatStatus pasan
npm run test:integration  # → tests de status bar pasan
```

**Riesgo:** `FileSystemWatcher` en Windows puede disparar eventos dobles. El handler debe ser idempotente (releer siempre el archivo, no mantener diffing).

---

## Phase 4: Comandos — Toggle Evolution + Add Mutation (TDD)

**Entry criteria:** Phase 3 completa
**Dependencias:** Phase 2 (usa `parseConfig`, `serializeConfig`, `formatMutation`)

### 4A: Toggle evolution

- [ ] **4A.1** Crear `test/integration/toggle-evolution.test.ts` — RED:
  - **TEST** "toggleEvolution lee config.yaml, invierte enabled, escribe el nuevo valor"
  - **TEST** "toggleEvolution crea config.yaml con enabled=true si no existe"
  - **TEST** "toggleEvolution muestra notification con el nuevo estado"
- [ ] **4A.2** Implementar `toggleEvolution(workspaceFolder: string)` en `src/commands.ts` — GREEN
  - Lee `.ape/config.yaml` (o defaults si no existe)
  - `parseConfig` → flip `evolutionEnabled` → `serializeConfig` → escribe
  - `vscode.window.showInformationMessage("Evolution ${enabled ? 'enabled' : 'disabled'}")`

### 4B: Add mutation

- [ ] **4B.1** Crear `test/integration/add-mutation.test.ts` — RED:
  - **TEST** "addMutation muestra InputBox y appends texto a mutations.md"
  - **TEST** "addMutation crea mutations.md si no existe"
  - **TEST** "addMutation con cancel (undefined) no modifica archivo"
- [ ] **4B.2** Implementar `addMutation(workspaceFolder: string)` en `src/commands.ts` — GREEN
  - `vscode.window.showInputBox({prompt: "Mutation note", placeHolder: "What changed?"})`
  - Si el usuario escribe texto: `formatMutation(text, true)` → append a `.ape/mutations.md`
  - Si cancel: no-op

### 4C: REFACTOR

- [ ] **4C.1** Revisar error handling (solo en boundaries: archivo no legible, workspace no abierto). `npm run compile && npm run test:unit && npm run test:integration`

**Verificación:**
```bash
npm run test:integration  # → tests de commands pasan
```

---

## Phase 5: Integración — activate() + package.json contributes

**Entry criteria:** Phases 1–4 completas
**Dependencias:** todas las anteriores

- [ ] **5.1** Completar `src/extension.ts` → `activate()`:
  1. Obtener workspaceFolder (si no hay, salir silenciosamente)
  2. Crear StatusBar con `createStatusBar()`
  3. Registrar comando `ape.toggleEvolution` → `toggleEvolution()`
  4. Registrar comando `ape.addMutation` → `addMutation()`
  5. Push todos los disposables a `context.subscriptions`
- [ ] **5.2** Completar `package.json` → `contributes`:
  ```json
  {
    "commands": [
      {"command": "ape.toggleEvolution", "title": "APE: Toggle Evolution"},
      {"command": "ape.addMutation", "title": "APE: Add Mutation Note"}
    ]
  }
  ```
- [ ] **5.3** Verificar activación condicional: extensión se activa solo con `workspaceContains:.ape/`
- [ ] **5.4** Crear `test/integration/activation.test.ts`:
  - **TEST** "extensión se activa en workspace con .ape/"
  - **TEST** "extensión exporta activate y deactivate"
- [ ] **5.5** Smoke test manual:
  - Abrir workspace con `.ape/` → status bar muestra estado
  - Editar `.ape/state.yaml` → status bar se actualiza
  - Cmd+Shift+P → "APE: Toggle Evolution" → config.yaml cambia
  - Cmd+Shift+P → "APE: Add Mutation Note" → mutations.md se actualiza
  - Abrir workspace sin `.ape/` → extensión no se activa

**Verificación:**
```bash
npm run compile           # → 0 errors
npm run test:unit         # → all pass
npm run test:integration  # → all pass
npx vsce package --no-dependencies  # → ape-vscode-0.0.1.vsix
```

---

## Phase 6: Marketplace — README, empaquetar, publicar

**Entry criteria:** Phase 5 completa, smoke test manual OK
**Dependencias:** Phase 5

- [ ] **6.1** Escribir `README.md` para Marketplace:
  - Qué es APE (una línea)
  - Qué hace esta extensión (4 bullet points = las 4 features)
  - Screenshot de la status bar mostrando estado
  - Requisitos: VS Code ≥ 1.85, directorio `.ape/` en workspace
  - Link al repo de APE CLI
- [ ] **6.2** Escribir `CHANGELOG.md`:
  - `## [0.0.1] - 2026-XX-XX` con las 4 features
- [ ] **6.3** Agregar `icon` en package.json (reusar o crear SVG 128×128 mínimo)
- [ ] **6.4** Agregar campos Marketplace en package.json: `repository`, `categories` (`["Other"]`), `keywords` (`["ape", "cli", "fsm"]`)
- [ ] **6.5** Empaquetar: `npx vsce package --no-dependencies`
- [ ] **6.6** Publicar: `npx vsce publish` (con PAT de ccisnedev)

**Verificación:**
- [ ] La extensión aparece en marketplace.visualstudio.com
- [ ] El README se renderiza correctamente como landing page
- [ ] Instalar desde Marketplace en VS Code limpio → funciona

---

## Resumen

| Phase | Tests unit | Tests integración | Entregable |
|-------|-----------|-------------------|------------|
| 1. Scaffold | 1 (smoke) | — | Proyecto que compila y empaqueta |
| 2. Parsers | ~13 | — | Lógica pura para state, config, mutations |
| 3. Status bar | ~6 | ~3 | Status bar con FSM state en tiempo real |
| 4. Commands | — | ~6 | Toggle evolution + add mutation |
| 5. Integración | — | ~2 | activate() wiring, smoke test manual |
| 6. Marketplace | — | — | README, CHANGELOG, .vsix publicado |
| **Total** | **~20** | **~11** | **Extensión publicada v0.0.1** |

## Notas

- **Tests unitarios vs integración:** La lógica pura (parsers, formateo) se testea con mocha directo — rápido, sin overhead. Solo la interacción con VS Code API (status bar, commands, file watcher) necesita @vscode/test-electron.
- **config.yaml puede no existir:** `parseConfig` con string vacío retorna defaults. `toggleEvolution` crea el archivo si no existe.
- **state.yaml schema:** Solo leemos `cycle.phase` y `cycle.task`. Si el formato cambia, solo `parseState` necesita actualizarse.
- **Sin CLI:** Esta extensión no ejecuta `ape`. Si en v0.0.2 queremos CLI integration, será un nuevo issue.

## Risk Mitigation

| Riesgo | Mitigación |
|--------|-----------|
| webpack config incorrecta | Verificar con extensionDevelopmentPath antes de avanzar de Phase 1 |
| FileSystemWatcher eventos dobles (Windows) | Handler idempotente: siempre releer archivo completo |
| config.yaml no existe | parseConfig con defaults, toggleEvolution crea el archivo |
| state.yaml schema cambia | Solo parseState necesita actualizarse, tests lo validan |
| Marketplace rechaza .vsix | Publisher verificado, seguir guías existentes |
