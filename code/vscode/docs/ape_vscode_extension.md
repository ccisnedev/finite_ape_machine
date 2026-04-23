---
id: inquiry-vscode-extension
title: "APE VS Code Extension — Architecture & Specification"
date: 2026-04-19
status: draft
tags: [vscode, extension, architecture, spec]
author: copilot
---

# APE VS Code Extension — Architecture & Specification

> Status note: This document is a historical and aspirational design draft. It does not match the currently published extension manifest in [../package.json](../package.json), which today exposes only `inquiry.init`, `inquiry.toggleEvolution`, and `inquiry.addMutation`, activates on `workspaceContains:.inquiry/`, and publishes the extension under the Inquiry name.
>
> Treat this file as a design archive, not as the authoritative description of current extension behavior. Internal examples here that mention broader command inventories, `ape` vocabulary, or `docs/issues/*/plan.md` paths are historical design assumptions, not current implementation guidance. For the current public entry surface, see [../README.md](../README.md). For the canonical repository doctrine, see [../../docs/index.md](../../docs/index.md), [../../docs/architecture.md](../../docs/architecture.md), and [../../docs/spec/finite-ape-machine.md](../../docs/spec/finite-ape-machine.md).

> Extensión de VS Code para el framework APE (Finite APE Machine).
> Basada en el análisis de la extensión Flutter/Dart-Code (ver `flutter_vscode_extension.md`).
> Lenguaje: TypeScript, empaquetado con webpack, publicada como `.vsix`.

---

## 1. Visión

La extensión APE para VS Code convierte el editor en el **centro de mando** del ciclo APE.
En vez de memorizar comandos CLI, el usuario opera su FSM desde paneles visuales,
status bar, y command palette — sin perder la opción de usar la terminal.

### 1.1 Propuesta de Valor

| Sin extensión | Con extensión |
|---------------|---------------|
| `ape doctor` en terminal | Panel visual con check/fail por prerequisito |
| `ape state transition -e start_analysis` | Click en botón "Start Analysis" |
| Editar `.inquiry/mutations.md` manualmente | Editor inline en sidebar con timestamp |
| No saber en qué estado estás | Status bar permanente: `APE: ANALYZE #42` |
| Instalar `ape.exe` manualmente | Prompt automático: "Install APE CLI?" → un click |
| Leer `plan.md` en otro tab | TreeView con checkboxes del plan |

---

## 2. Estructura del Proyecto

```
inquiry-vscode/
├── package.json                 ← Manifiesto (commands, views, settings, menus)
├── tsconfig.json
├── webpack.config.js            ← Bundle → out/dist/extension.js
├── .vscodeignore
├── CHANGELOG.md
├── README.md
├── LICENSE
│
├── media/
│   ├── ape-icon.svg             ← Activity bar icon (mono)
│   ├── ape-icon-dark.svg        ← Variante dark
│   ├── ape-icon-light.svg       ← Variante light
│   ├── states/                  ← Íconos por estado FSM
│   │   ├── idle.svg
│   │   ├── analyze.svg
│   │   ├── plan.svg
│   │   ├── execute.svg
│   │   ├── end.svg
│   │   └── evolution.svg
│   └── webview/                 ← Assets para WebViews
│       ├── cycle-status.css
│       └── cycle-status.js
│
├── src/
│   ├── extension.ts             ← activate() / deactivate()
│   ├── config.ts                ← Wrapper sobre vscode settings
│   ├── constants.ts             ← Context keys, paths, nombres
│   │
│   ├── cli/                     ← Interacción con ape.exe
│   │   ├── detector.ts          ← Buscar ape.exe (PATH, config, known locations)
│   │   ├── installer.ts         ← Descargar desde GitHub Releases
│   │   ├── runner.ts            ← Ejecutar comandos y parsear output
│   │   └── version.ts           ← Parsear/comparar versiones semver
│   │
│   ├── commands/                ← Implementación de comandos VS Code
│   │   ├── init.ts              ← inquiry.init
│   │   ├── cycle.ts             ← analyze, plan, execute, evolve, end
│   │   ├── mutations.ts         ← add mutation note
│   │   ├── doctor.ts            ← ape.doctor
│   │   ├── install.ts           ← install/update CLI
│   │   ├── target.ts            ← ape target get/clean
│   │   └── state.ts             ← ape state transition wrapper
│   │
│   ├── views/                   ← Sidebar panels
│   │   ├── cycle-status.ts      ← WebviewViewProvider — FSM diagram
│   │   ├── plan-tree.ts         ← TreeDataProvider — plan.md checkboxes
│   │   ├── doctor-tree.ts       ← TreeDataProvider — prerequisite checks
│   │   └── mutations-editor.ts  ← WebviewViewProvider — mutations.md editor
│   │
│   ├── status-bar/
│   │   └── cycle-indicator.ts   ← "APE: IDLE" / "APE: ANALYZE #42"
│   │
│   ├── watchers/
│   │   ├── state-watcher.ts     ← Watch .inquiry/state.yaml → refresh views
│   │   ├── config-watcher.ts    ← Watch .inquiry/config.yaml
│   │   └── plan-watcher.ts      ← Watch docs/issues/*/plan.md
│   │
│   └── utils/
│       ├── fs.ts                ← File system helpers
│       ├── yaml.ts              ← YAML parse/serialize
│       └── github.ts            ← GitHub Releases API (para installer)
│
└── test/
    ├── suite/
    │   ├── detector.test.ts
    │   ├── runner.test.ts
    │   └── version.test.ts
    └── fixtures/
        ├── state.yaml
        └── config.yaml
```

---

## 3. Ciclo de Vida: Activación

### 3.1 Activation Events

```json
{
  "activationEvents": [
    "workspaceContains:.ape",
    "workspaceContains:.inquiry/state.yaml",
    "onCommand:inquiry.init",
    "onCommand:ape.install",
    "onCommand:ape.doctor"
  ]
}
```

La extensión se activa si:
- El workspace contiene `.inquiry/` (proyecto APE existente)
- El usuario ejecuta un comando APE manualmente (init, install, doctor)

### 3.2 Flujo de activate()

```
activate()
│
├─ 1. detectCli()
│     ├─ config.ape.cliPath → check exists
│     ├─ which("ape") → check PATH
│     ├─ ~/.inquiry/bin/ape → known location
│     └─ NOT FOUND → setContext("ape:cliInstalled", false)
│                   → show notification: "Install APE CLI?"
│
├─ 2. detectProject()
│     ├─ search .inquiry/state.yaml in workspace folders
│     ├─ FOUND → parse state.yaml → setContext("ape:projectLoaded", true)
│     │        → setContext("ape:currentState", state.cycle.phase)
│     │        → setContext("ape:currentTask", state.cycle.task)
│     └─ NOT FOUND → setContext("ape:projectLoaded", false)
│
├─ 3. readConfig()
│     ├─ parse .inquiry/config.yaml
│     └─ setContext("ape:evolutionEnabled", config.evolution.enabled)
│
├─ 4. registerCommands()          ← todos los commands
├─ 5. registerViews()             ← sidebar, trees, webviews
├─ 6. registerStatusBar()         ← cycle indicator
├─ 7. registerWatchers()          ← file system watchers
└─ 8. showPrompts()               ← update available, first run, etc.
```

---

## 4. Context Keys

Context keys controlan la visibilidad condicional de toda la UI.

```typescript
// constants.ts

// Detección
"ape:cliInstalled"          // boolean — ape.exe encontrado
"ape:projectLoaded"         // boolean — .inquiry/ encontrado en workspace

// Estado FSM
"ape:currentState"          // string — IDLE | ANALYZE | PLAN | EXECUTE | END | EVOLUTION
"ape:cycleActive"           // boolean — state !== IDLE
"ape:currentTask"           // string — issue number o ""

// Configuración
"ape:evolutionEnabled"      // boolean — config.yaml evolution.enabled

// Archivos
"ape:hasPlan"               // boolean — plan.md existe para el issue actual
"ape:hasDiagnosis"          // boolean — diagnosis.md existe
"ape:hasMutations"          // boolean — mutations.md tiene contenido
```

Se setean así:
```typescript
await vscode.commands.executeCommand("setContext", "ape:currentState", "ANALYZE");
```

---

## 5. Comandos

### 5.1 Tabla de Comandos

| ID | Título | Categoría | When (visible) | Implementación |
|----|--------|-----------|-----------------|----------------|
| `inquiry.init` | Initialize Project | APE | siempre | `ape init` |
| `ape.doctor` | Run Doctor | APE | siempre | `ape doctor` → parse output |
| `ape.version` | Show Version | APE | `ape:cliInstalled` | `ape version` |
| `ape.install` | Install CLI | APE | `!ape:cliInstalled` | GitHub Release download |
| `ape.update` | Update CLI | APE | `ape:cliInstalled` | `ape upgrade` |
| `ape.uninstall` | Uninstall CLI | APE | `ape:cliInstalled` | `ape uninstall` |
| `ape.target.get` | Deploy Agents | APE | `ape:cliInstalled` | `ape target get` |
| `ape.target.clean` | Clean Agents | APE | `ape:cliInstalled` | `ape target clean` |
| `ape.startAnalysis` | Start Analysis | APE Cycle | `ape:projectLoaded && ape:currentState == IDLE` | `ape state transition -e start_analysis` |
| `ape.approveDiagnosis` | Approve Diagnosis | APE Cycle | `ape:currentState == ANALYZE && ape:hasDiagnosis` | `ape state transition -e approve_diagnosis` |
| `ape.approvePlan` | Approve Plan | APE Cycle | `ape:currentState == PLAN && ape:hasPlan` | `ape state transition -e approve_plan` |
| `ape.approveExecution` | Approve Execution | APE Cycle | `ape:currentState == EXECUTE` | `ape state transition -e approve_execution` |
| `ape.createPR` | Create PR | APE Cycle | `ape:currentState == END` | `ape state transition -e create_pr` |
| `ape.abortCycle` | Abort Cycle | APE Cycle | `ape:cycleActive` | `ape state transition -e abort` |
| `ape.returnToAnalysis` | Return to Analysis | APE Cycle | `ape:currentState == PLAN` | `ape state transition -e return_analysis` |
| `ape.evolution.toggle` | Toggle Evolution | APE Config | `ape:projectLoaded` | Edita `config.yaml` |
| `ape.mutations.add` | Add Mutation Note | APE | `ape:projectLoaded` | InputBox → append a `mutations.md` |
| `ape.mutations.open` | Open Mutations | APE | `ape:projectLoaded` | Open `.inquiry/mutations.md` en editor |
| `ape.openPlan` | Open Plan | APE | `ape:hasPlan` | Open `plan.md` en editor |
| `ape.openDiagnosis` | Open Diagnosis | APE | `ape:hasDiagnosis` | Open `diagnosis.md` en editor |

### 5.2 Registro (package.json)

```json
{
  "contributes": {
    "commands": [
      {
        "command": "inquiry.init",
        "title": "Initialize Project",
        "category": "APE"
      },
      {
        "command": "ape.doctor",
        "title": "Run Doctor",
        "category": "APE",
        "icon": "$(checklist)"
      },
      {
        "command": "ape.startAnalysis",
        "title": "Start Analysis",
        "category": "APE Cycle",
        "icon": "$(play)"
      },
      {
        "command": "ape.mutations.add",
        "title": "Add Mutation Note",
        "category": "APE",
        "icon": "$(note)"
      },
      {
        "command": "ape.evolution.toggle",
        "title": "Toggle Evolution",
        "category": "APE Config",
        "icon": "$(symbol-event)"
      }
    ]
  }
}
```

### 5.3 Visibilidad en Command Palette

```json
{
  "menus": {
    "commandPalette": [
      { "command": "inquiry.init" },
      { "command": "ape.doctor" },
      { "command": "ape.install", "when": "!ape:cliInstalled" },
      { "command": "ape.update", "when": "ape:cliInstalled" },
      { "command": "ape.startAnalysis", "when": "ape:projectLoaded && ape:currentState == IDLE" },
      { "command": "ape.approveDiagnosis", "when": "ape:currentState == ANALYZE" },
      { "command": "ape.approvePlan", "when": "ape:currentState == PLAN" },
      { "command": "ape.approveExecution", "when": "ape:currentState == EXECUTE" },
      { "command": "ape.createPR", "when": "ape:currentState == END" },
      { "command": "ape.abortCycle", "when": "ape:cycleActive" },
      { "command": "ape.mutations.add", "when": "ape:projectLoaded" },
      { "command": "ape.evolution.toggle", "when": "ape:projectLoaded" }
    ]
  }
}
```

---

## 6. UI: Activity Bar + Sidebar

### 6.1 View Container

Un solo contenedor en la Activity Bar con el ícono APE:

```json
{
  "viewsContainers": {
    "activitybar": [
      {
        "id": "ape",
        "title": "APE",
        "icon": "media/ape-icon.svg"
      }
    ]
  }
}
```

### 6.2 Views

Cuatro paneles dentro del sidebar APE:

```json
{
  "views": {
    "ape": [
      {
        "id": "apeCycleStatus",
        "type": "webview",
        "name": "Cycle Status",
        "when": "ape:projectLoaded"
      },
      {
        "id": "apePlanTree",
        "name": "Plan",
        "when": "ape:hasPlan"
      },
      {
        "id": "apeDoctorTree",
        "name": "Doctor",
        "when": "ape:cliInstalled"
      },
      {
        "id": "apeMutationsEditor",
        "type": "webview",
        "name": "Mutations",
        "when": "ape:projectLoaded"
      }
    ]
  }
}
```

### 6.3 Panel: Cycle Status (WebView)

El panel principal. Muestra un **diagrama FSM interactivo** con el estado actual resaltado.

```
┌──────────────────────────────────────┐
│  APE Cycle — Issue #42               │
│                                      │
│  ┌──────┐    ┌─────────┐            │
│  │ IDLE │───→│ ANALYZE │ ← current  │
│  └──────┘    └────┬────┘            │
│                   │                  │
│              ┌────▼────┐            │
│              │  PLAN   │            │
│              └────┬────┘            │
│                   │                  │
│              ┌────▼────┐            │
│              │ EXECUTE │            │
│              └────┬────┘            │
│                   │                  │
│              ┌────▼────┐            │
│              │   END   │            │
│              └────┬────┘            │
│                   │                  │
│              ┌────▼─────┐           │
│              │EVOLUTION │           │
│              └──────────┘           │
│                                      │
│  [Approve Diagnosis →]               │
│  [Abort Cycle ✕]                     │
│                                      │
│  Evolution: ● enabled                │
│  Task: #42-refactor-runner           │
│  Branch: 42-refactor-runner          │
└──────────────────────────────────────┘
```

**Funcionalidades:**
- Estado actual resaltado con color (verde=actual, gris=futuro, ✓=completado)
- Botón de acción contextual (la siguiente transición válida)
- Botón de abort siempre visible si hay ciclo activo
- Toggle de evolution inline
- Info del issue/branch actual
- Se actualiza en tiempo real vía file watcher en `state.yaml`

**Implementación:**

```typescript
class CycleStatusProvider implements vscode.WebviewViewProvider {
  private view?: vscode.WebviewView;

  resolveWebviewView(webviewView: vscode.WebviewView) {
    this.view = webviewView;
    webviewView.webview.options = { enableScripts: true };
    webviewView.webview.html = this.render();

    // Recibir mensajes del WebView (clicks en botones)
    webviewView.webview.onDidReceiveMessage(async (msg) => {
      switch (msg.command) {
        case "transition":
          await vscode.commands.executeCommand(`ape.${msg.event}`);
          break;
        case "toggleEvolution":
          await vscode.commands.executeCommand("ape.evolution.toggle");
          break;
      }
    });
  }

  // Llamado por el watcher cuando cambia state.yaml
  refresh(state: ApeState) {
    this.view?.webview.postMessage({ type: "stateUpdate", state });
  }
}
```

### 6.4 Panel: Plan Tree (TreeDataProvider)

Parsea `plan.md` y muestra las fases como un árbol con checkboxes:

```
▼ Phase 1: Setup infrastructure
  ☑ Create config parser
  ☑ Add unit tests
  ☐ Integration test
▼ Phase 2: Implement command
  ☐ Add command handler
  ☐ Wire up routing
  ☐ E2E test
```

**Implementación:**

```typescript
interface PlanItem {
  label: string;
  checked: boolean;
  children: PlanItem[];
  line: number; // línea en plan.md para navigate-to
}

class PlanTreeProvider implements vscode.TreeDataProvider<PlanItem> {
  getTreeItem(item: PlanItem): vscode.TreeItem {
    const ti = new vscode.TreeItem(item.label);
    ti.iconPath = item.checked
      ? new vscode.ThemeIcon("check")
      : new vscode.ThemeIcon("circle-outline");
    ti.command = {
      command: "ape.openPlanAtLine",
      arguments: [item.line],
      title: "Go to Plan"
    };
    ti.collapsibleState = item.children.length > 0
      ? vscode.TreeItemCollapsibleState.Expanded
      : vscode.TreeItemCollapsibleState.None;
    return ti;
  }
}
```

### 6.5 Panel: Doctor Tree (TreeDataProvider)

Ejecuta `ape doctor` y muestra resultados:

```
✓ ape CLI v0.0.14
✓ git 2.44
✓ gh 2.49
✓ gh auth — authenticated
✗ gh copilot — not installed
```

### 6.6 Panel: Mutations Editor (WebView)

Editor inline para `.inquiry/mutations.md` con:
- Textarea para escribir notas rápidas
- Botón "Add" que agrega con timestamp
- Preview del contenido actual
- Enlace para abrir en editor completo

```
┌──────────────────────────────────────┐
│  Mutations — Observations for DARWIN │
│                                      │
│  ┌────────────────────────────────┐  │
│  │ SOCRATES asked redundant      │  │
│  │ questions in round 3...       │  │
│  └────────────────────────────────┘  │
│  [Add Note]  [Open in Editor]        │
│                                      │
│  ── Previous Notes ──                │
│  [2026-04-19 14:30] Plan.md was     │
│  too granular for a small fix...     │
│  [2026-04-19 10:15] Good breakdown  │
│  of the problem space.               │
└──────────────────────────────────────┘
```

---

## 7. Status Bar

### 7.1 Cycle Indicator

Siempre visible cuando `ape:projectLoaded`:

```
APE: ANALYZE #42  │  APE v0.0.14
```

Dos status bar items:

**Item 1 — Estado del ciclo:**
```typescript
const cycleItem = vscode.window.createStatusBarItem(
  vscode.StatusBarAlignment.Left, 100
);
cycleItem.text = "$(symbol-event) APE: ANALYZE #42";
cycleItem.tooltip = "Current APE cycle state. Click for actions.";
cycleItem.command = "ape.showCycleActions";  // QuickPick con transiciones válidas
cycleItem.backgroundColor = new vscode.ThemeColor("statusBarItem.warningBackground");
```

**Colores por estado:**
| Estado | Color | Ícono |
|--------|-------|-------|
| IDLE | default | `$(circle-outline)` |
| ANALYZE | `warningBackground` (naranja) | `$(search)` |
| PLAN | `warningBackground` | `$(list-tree)` |
| EXECUTE | `errorBackground` (rojo) | `$(rocket)` |
| END | `warningBackground` | `$(git-pull-request)` |
| EVOLUTION | `prominentBackground` | `$(sparkle)` |

**Item 2 — Versión CLI:**
```typescript
const versionItem = vscode.window.createStatusBarItem(
  vscode.StatusBarAlignment.Right, 50
);
versionItem.text = "APE v0.0.14";
versionItem.tooltip = "APE CLI version. Click to check for updates.";
versionItem.command = "ape.update";
```

### 7.2 Quick Actions (showCycleActions)

Click en el status bar abre un QuickPick con las transiciones válidas según el estado:

```typescript
async function showCycleActions(state: string) {
  const actions = getValidTransitions(state);
  // Example for ANALYZE state:
  // [
  //   { label: "$(check) Approve Diagnosis", command: "ape.approveDiagnosis" },
  //   { label: "$(close) Abort Cycle", command: "ape.abortCycle" },
  //   { label: "$(note) Add Mutation", command: "ape.mutations.add" },
  //   { label: "$(file) Open Diagnosis", command: "ape.openDiagnosis" },
  // ]
  const picked = await vscode.window.showQuickPick(actions);
  if (picked) await vscode.commands.executeCommand(picked.command);
}
```

---

## 8. CLI Detection & Installation

### 8.1 Cadena de Búsqueda

```typescript
// cli/detector.ts

async function detectCli(): Promise<string | null> {
  // 1. Configuración explícita
  const configured = config.get<string>("ape.cliPath");
  if (configured && existsSync(configured)) return configured;

  // 2. PATH del sistema
  const fromPath = await which("ape");
  if (fromPath) return fromPath;

  // 3. Ubicación conocida (~/.inquiry/bin/)
  const knownPath = path.join(os.homedir(), ".ape", "bin", isWindows ? "ape.exe" : "ape");
  if (existsSync(knownPath)) return knownPath;

  // 4. No encontrado
  return null;
}
```

### 8.2 Auto-Instalación

Cuando `detectCli()` retorna `null`:

```
┌─────────────────────────────────────────────────────┐
│ ⚠ APE CLI not found.                                │
│                                                     │
│ [Install APE CLI]  [Set Path Manually]  [Dismiss]   │
└─────────────────────────────────────────────────────┘
```

**Flujo de "Install APE CLI":**

```typescript
// cli/installer.ts

async function installApeCli(): Promise<boolean> {
  // 1. Obtener latest release de GitHub
  const release = await getLatestRelease("siliconbrainedmachines", "inquiry");

  // 2. Determinar asset según OS
  const asset = release.assets.find(a =>
    a.name.includes(process.platform) && a.name.includes(process.arch)
  );

  // 3. Descargar con progreso
  await vscode.window.withProgress(
    { location: vscode.ProgressLocation.Notification, title: "Installing APE CLI..." },
    async (progress) => {
      progress.report({ increment: 0, message: "Downloading..." });
      const zipPath = await download(asset.browser_download_url, tmpDir);

      progress.report({ increment: 50, message: "Extracting..." });
      await extract(zipPath, installDir);  // ~/.inquiry/bin/

      progress.report({ increment: 90, message: "Verifying..." });
      await verifyInstallation(installDir);
    }
  );

  // 4. Ofrecer agregar a PATH
  await promptAddToPath(installDir);

  return true;
}
```

### 8.3 Actualización

Cuando `ape version` reporta una versión más vieja que la última release:

```
┌─────────────────────────────────────────────────────┐
│ ℹ APE CLI v0.0.15 available (current: v0.0.14)     │
│                                                     │
│ [Update Now]  [Release Notes]  [Later]              │
└─────────────────────────────────────────────────────┘
```

---

## 9. File Watchers

### 9.1 State Watcher

```typescript
// watchers/state-watcher.ts

const stateWatcher = vscode.workspace.createFileSystemWatcher(
  new vscode.RelativePattern(workspaceFolder, ".inquiry/state.yaml")
);

stateWatcher.onDidChange(async () => {
  const state = await parseStateYaml();
  await setAllContextKeys(state);
  cycleStatusView.refresh(state);
  statusBarItem.update(state);
});

stateWatcher.onDidCreate(async () => {
  await vscode.commands.executeCommand("setContext", "ape:projectLoaded", true);
});

stateWatcher.onDidDelete(async () => {
  await vscode.commands.executeCommand("setContext", "ape:projectLoaded", false);
});
```

### 9.2 Config Watcher

```typescript
const configWatcher = vscode.workspace.createFileSystemWatcher(
  new vscode.RelativePattern(workspaceFolder, ".inquiry/config.yaml")
);

configWatcher.onDidChange(async () => {
  const config = await parseConfigYaml();
  await vscode.commands.executeCommand(
    "setContext", "ape:evolutionEnabled", config.evolution?.enabled ?? false
  );
  cycleStatusView.refresh();
});
```

### 9.3 Plan Watcher

```typescript
const planWatcher = vscode.workspace.createFileSystemWatcher(
  new vscode.RelativePattern(workspaceFolder, "docs/issues/*/plan.md")
);

planWatcher.onDidChange(() => planTreeProvider.refresh());
```

---

## 10. Configuración (Settings)

```json
{
  "contributes": {
    "configuration": [
      {
        "title": "APE",
        "properties": {
          "ape.cliPath": {
            "type": ["null", "string"],
            "default": null,
            "markdownDescription": "Path to `ape` executable. If not set, auto-detected from PATH and `~/.inquiry/bin/`.",
            "scope": "machine-overridable"
          },
          "ape.checkForUpdates": {
            "type": "boolean",
            "default": true,
            "description": "Whether to check for APE CLI updates on activation.",
            "scope": "window"
          },
          "ape.showStatusBar": {
            "type": "boolean",
            "default": true,
            "description": "Show APE cycle status in the status bar.",
            "scope": "window"
          },
          "ape.autoRefreshViews": {
            "type": "boolean",
            "default": true,
            "description": "Automatically refresh sidebar views when .inquiry/ files change.",
            "scope": "window"
          },
          "ape.mutationTimestamp": {
            "type": "boolean",
            "default": true,
            "description": "Add timestamp prefix when adding mutation notes.",
            "scope": "window"
          }
        }
      }
    ]
  }
}
```

---

## 11. CLI Runner

### 11.1 Interfaz

```typescript
// cli/runner.ts

interface CliResult {
  exitCode: number;
  stdout: string;
  stderr: string;
}

class ApeRunner {
  constructor(
    private readonly cliPath: string,
    private readonly outputChannel: vscode.OutputChannel,
  ) {}

  async run(args: string[], options?: { cwd?: string; silent?: boolean }): Promise<CliResult> {
    const cwd = options?.cwd ?? getWorkspaceRoot();

    if (!options?.silent) {
      this.outputChannel.appendLine(`> ape ${args.join(" ")}`);
    }

    const result = await execFile(this.cliPath, args, { cwd });

    if (!options?.silent) {
      this.outputChannel.appendLine(result.stdout);
      if (result.stderr) this.outputChannel.appendLine(result.stderr);
    }

    return result;
  }

  async version(): Promise<string> {
    const result = await this.run(["version"], { silent: true });
    return result.stdout.trim();
  }

  async doctor(): Promise<DoctorResult[]> {
    const result = await this.run(["doctor", "--json"]);
    return JSON.parse(result.stdout);
  }

  async transition(event: string): Promise<CliResult> {
    return this.run(["state", "transition", "-e", event]);
  }

  async getState(): Promise<ApeState> {
    // Parse .inquiry/state.yaml directamente (más rápido que ejecutar CLI)
    return parseStateYaml();
  }
}
```

### 11.2 Output Channel

```typescript
const outputChannel = vscode.window.createOutputChannel("APE", { log: true });
// Usage:
outputChannel.info("Running ape doctor...");
outputChannel.error("APE CLI returned exit code 1");
```

---

## 12. Transiciones FSM Válidas (Referencia)

La extensión debe conocer las transiciones para mostrar solo acciones válidas:

```typescript
// constants.ts

const VALID_TRANSITIONS: Record<string, Transition[]> = {
  IDLE: [
    { event: "start_analysis", label: "Start Analysis", icon: "play", target: "ANALYZE" },
  ],
  ANALYZE: [
    { event: "approve_diagnosis", label: "Approve Diagnosis", icon: "check", target: "PLAN" },
    { event: "abort", label: "Abort Cycle", icon: "close", target: "IDLE" },
  ],
  PLAN: [
    { event: "approve_plan", label: "Approve Plan", icon: "check", target: "EXECUTE" },
    { event: "return_analysis", label: "Return to Analysis", icon: "arrow-left", target: "ANALYZE" },
    { event: "abort", label: "Abort Cycle", icon: "close", target: "IDLE" },
  ],
  EXECUTE: [
    { event: "approve_execution", label: "Approve Execution", icon: "check", target: "END" },
    { event: "interrupt", label: "Interrupt → Analysis", icon: "debug-pause", target: "ANALYZE" },
  ],
  END: [
    { event: "create_pr", label: "Create PR", icon: "git-pull-request", target: "EVOLUTION" },
  ],
  EVOLUTION: [
    // Automático, no requiere acción del usuario
  ],
};
```

---

## 13. Dependencias

### 13.1 Runtime

```json
{
  "dependencies": {
    "yaml": "^2.8.0",
    "semver": "^7.7.0"
  }
}
```

### 13.2 Development

```json
{
  "devDependencies": {
    "@types/vscode": "^1.85.0",
    "@types/node": "^22.0.0",
    "@types/semver": "^7.7.0",
    "typescript": "^5.9.0",
    "webpack": "^5.100.0",
    "webpack-cli": "^6.0.0",
    "ts-loader": "^9.5.0",
    "@vscode/test-electron": "^2.5.0"
  }
}
```

### 13.3 Engine

```json
{
  "engines": {
    "vscode": "^1.85.0"
  }
}
```

---

## 14. Fases de Implementación

### Fase 1: Foundation (MVP)
- [ ] Scaffold del proyecto (package.json, webpack, tsconfig)
- [ ] CLI detection (detector.ts)
- [ ] CLI runner (runner.ts, version.ts)
- [ ] Status bar con estado actual
- [ ] Comandos básicos: init, doctor, version
- [ ] Context keys desde state.yaml
- [ ] File watcher para state.yaml
- [ ] Output channel

### Fase 2: Cycle Management
- [ ] Todos los comandos de transición
- [ ] QuickPick de acciones válidas desde status bar
- [ ] Cycle Status WebView (diagrama FSM)
- [ ] Plan TreeView con checkboxes
- [ ] Watchers para plan.md y config.yaml

### Fase 3: Mutations & Evolution
- [ ] Mutations Editor WebView
- [ ] Comando mutations.add con InputBox
- [ ] Toggle evolution desde UI
- [ ] Doctor TreeView

### Fase 4: Installation & Updates
- [ ] CLI installer (GitHub Releases download)
- [ ] Update checker y notificación
- [ ] "Add to PATH" prompt
- [ ] First-run walkthrough

### Fase 5: Polish
- [ ] Íconos SVG para estados
- [ ] Temas dark/light para WebViews
- [ ] Keyboard shortcuts
- [ ] Tests automatizados
- [ ] README con screenshots
- [ ] Publicación en Marketplace

---

## 15. Diferenciadores vs. Flutter Extension

| Aspecto | Flutter (Dart-Code) | APE Extension |
|---------|---------------------|---------------|
| **Instalación CLI** | Solo link a web | Auto-descarga desde GitHub Releases |
| **Estado visual** | Texto en status bar | WebView con diagrama FSM interactivo |
| **Notas del usuario** | No tiene | Editor inline de mutations.md |
| **Toggles en UI** | Solo via Settings JSON | Toggles visuales (evolution on/off) |
| **Acciones contextuales** | Básicas (hot reload) | Transiciones FSM con precondiciones |
| **Complejidad** | 3,880 líneas de package.json | ~300 líneas estimadas |
| **Dependencias** | LSP, DAP, DevTools | Solo CLI wrapper + YAML parser |
