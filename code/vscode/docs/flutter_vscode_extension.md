# Deep Research: Flutter/Dart VS Code Extension (Dart-Code)

> Análisis de la extensión **Dart-Code v3.134** para construir la extensión APE VS Code.
> Repo: `https://github.com/Dart-Code/Dart-Code`
> Lenguaje: TypeScript (~96%), empaquetado con webpack.

---

## 1. Estructura del Proyecto

```
Dart-Code/
├── package.json            ← Manifiesto central (3,880 líneas!)
├── webpack.config.js       ← Build con webpack → out/dist/extension.js
├── src/
│   ├── extension/          ← Código específico de VS Code
│   │   ├── extension.ts    ← Entry point: activate() / deactivate()
│   │   ├── config.ts       ← Wrapper sobre vscode.workspace.getConfiguration
│   │   ├── user_prompts.ts ← Prompts de instalación/actualización
│   │   ├── analytics.ts    ← Telemetría
│   │   ├── analysis/       ← Integración con Dart Analysis Server (LSP)
│   │   ├── commands/       ← Comandos del Command Palette
│   │   ├── providers/      ← Code completion, formatting, etc (legacy, LSP lo reemplaza)
│   │   ├── sdk/            ← SDK Manager, buscador, status bar
│   │   │   ├── sdk_manager.ts         ← Fast SDK switching via QuickPick
│   │   │   ├── flutter.ts             ← Flutter daemon management
│   │   │   ├── status_bar_version_tracker.ts ← Versión en status bar
│   │   │   ├── update_check.ts        ← Chequeo de actualizaciones
│   │   │   └── dev_tools/             ← DevTools integration
│   │   ├── views/          ← Sidebar views (TreeView, WebView)
│   │   │   ├── packages_view.ts       ← Dependency tree (TreeDataProvider)
│   │   │   ├── shared.ts             ← Base classes para views
│   │   │   └── devtools/              ← DevTools webview panels
│   │   ├── flutter/        ← Flutter daemon, device management
│   │   ├── pub/            ← Pub integration
│   │   └── recommendations/← Extension recommendations
│   ├── shared/             ← Código compartido (extension + debug + test)
│   │   ├── constants.ts
│   │   ├── interfaces.ts   ← Tipos/interfaces core (Sdks, Logger, etc.)
│   │   ├── utils/          ← File system, version comparison
│   │   ├── vscode/         ← VS Code utilities compartidas
│   │   └── flutter/        ← Flutter utilities
│   ├── debug/              ← Debug Adapter Protocol (DAP) — out-of-process
│   └── test/               ← Tests automatizados
```

---

## 2. Ciclo de Vida: Activación

### 2.1 Activation Events (package.json)

La extensión se activa cuando VS Code detecta archivos de proyecto:

```json
"activationEvents": [
  "workspaceContains:pubspec.yaml",
  "workspaceContains:*/pubspec.yaml",
  "workspaceContains:*.dart",
  "workspaceContains:.dart_tool",
  "onCommand:_dart.flutter.createSampleProject",
  "onTaskType:dart",
  "onUri",
  "onDebugDynamicConfigurations"
]
```

**Equivalente APE:** Activar cuando se detecte `.ape/` o `ape.yaml`.

```json
"activationEvents": [
  "workspaceContains:.ape",
  "workspaceContains:.ape/config.yaml"
]
```

### 2.2 Entry Point: `extension.ts → activate()`

El flujo es:
1. **Buscar SDKs** — escanea PATH, configuración, directorios conocidos
2. **Validar SDK** — verifica que el ejecutable exista y sea válido
3. **Configurar Context Keys** — `dart-code:anyProjectLoaded`, etc.
4. **Registrar Providers** — commands, views, tree providers, status bar
5. **Mostrar Prompts** — actualización, recomendaciones, instalación

---

## 3. Detección e Instalación del SDK

### 3.1 Búsqueda del SDK

La extensión busca el SDK en múltiples ubicaciones (en orden):

1. **Configuración explícita:** `dart.sdkPath` / `dart.flutterSdkPath`
2. **Comando personalizado:** `dart.getDartSdkCommand` (para asdf, mise, direnv)
3. **Variables de entorno:** `FLUTTER_ROOT`, `DART_SDK`
4. **PATH del sistema:** busca `dart`/`flutter` ejecutable
5. **Ubicaciones conocidas:** `/usr/lib/dart`, `~/flutter`, etc.
6. **Directorios del proyecto:** busca `.dart_tool` recursivamente

### 3.2 SDK Manager (`sdk_manager.ts`)

```typescript
abstract class SdkManager {
  // Configuración
  protected abstract get sdkPaths(): string[];      // Array de paths a buscar
  protected abstract get currentSdk(): string;      // SDK actual
  protected abstract get configuredSdk(): string;   // SDK configurado por usuario
  protected abstract get executablePath(): string;  // Ruta relativa al ejecutable

  // Quick-switch via QuickPick
  public changeSdk() { ... }
  public async searchForSdks(sdkPaths: string[]) { ... }
}
```

El SDK Manager:
- Busca en `sdkPaths` + sus hijos inmediatos (para carpetas con múltiples SDKs)
- Resuelve symlinks para encontrar la versión real
- Muestra un **QuickPick** con las versiones disponibles
- Guarda la selección en workspace o global settings

### 3.3 Prompt de Instalación

Cuando NO encuentra el SDK:
- Muestra un **notification** con opción de descargar
- Para Flutter: enlaza a flutter.dev/get-started
- Para Dart: enlaza a dart.dev/get-dart
- NO descarga automáticamente (solo redirect a web)
- Comando `flutter.addSdkToPath` / `dart.addSdkToPath` para configurar PATH

**Equivalente APE:** Podemos ser más agresivos:

```
1. Buscar ape.exe en PATH
2. Si no existe → ofrecer instalación automática:
   - Windows: descargar release de GitHub → extraer a ~/.ape/bin/
   - Agregar a PATH (vía PowerShell profile o terminal PATH)
3. Si existe pero versión vieja → ofrecer actualización
```

---

## 4. Sistema de Contextos (When Clauses)

### 4.1 Context Keys

Flutter usa context keys para controlar visibilidad de comandos/views:

```typescript
// En constants.contexts.ts
"dart-code:anyProjectLoaded"         // Hay proyecto Dart cargado
"dart-code:anyFlutterProjectLoaded"  // Hay proyecto Flutter
"dart-code:isRunningLocally"         // No es remoto
"dart-code:dtdAvailable"             // Tooling Daemon disponible
```

Se setean con `vscode.commands.executeCommand('setContext', key, value)`.

**Equivalente APE:**

```typescript
"ape:projectLoaded"        // .ape/ detectado
"ape:cliInstalled"         // ape.exe en PATH
"ape:cycleActive"          // Ciclo APE activo (no IDLE)
"ape:evolutionEnabled"     // EVOLUTION habilitado
"ape:currentState"         // IDLE | ANALYZE | PLAN | EXECUTE | EVOLUTION
```

---

## 5. Contribución de UI (package.json)

### 5.1 Views Containers (Activity Bar)

Flutter registra un ícono en la Activity Bar:

```json
"viewsContainers": {
  "activitybar": [
    {
      "id": "flutter",
      "title": "Flutter",
      "icon": "media/icons/sidebar/flutter.svg"
    },
    {
      "id": "sidebarDevToolsContainer",
      "title": "Flutter DevTools",
      "icon": "media/icons/sidebar/devtools.svg"
    }
  ]
}
```

**Equivalente APE:**

```json
"viewsContainers": {
  "activitybar": [
    {
      "id": "ape",
      "title": "APE",
      "icon": "media/ape-icon.svg"
    }
  ]
}
```

### 5.2 Views (Sidebar)

Dentro del container, Flutter registra:

```json
"views": {
  "flutter": [
    {
      "id": "dartFlutterSidebar",
      "type": "webview",          // WebView para contenido rico
      "name": "Flutter Sidebar",
      "when": "dart-code:anyFlutterProjectLoaded"
    },
    {
      "id": "dartFlutterOutline",
      "name": "Outline",          // TreeView para estructura
      "when": "dart-code:anyFlutterProjectLoaded"
    }
  ],
  "explorer": [
    {
      "id": "dartDependencyTree",
      "name": "Dependencies",     // TreeView en el Explorer
      "when": "dart-code:anyProjectLoaded"
    }
  ]
}
```

**Dos tipos de views:**
- **TreeView** (`TreeDataProvider`) — para datos jerárquicos (dependencies, outline)
- **WebView** — para UI rica con HTML/CSS/JS (DevTools, Property Editor, Widget Preview)

**Equivalente APE:**

```json
"views": {
  "ape": [
    {
      "id": "apeCycleStatus",
      "type": "webview",
      "name": "Cycle Status",
      "when": "ape:projectLoaded"
    },
    {
      "id": "apeIssues",
      "name": "Issues",
      "when": "ape:projectLoaded"
    },
    {
      "id": "apeMutations",
      "name": "Mutations Log",
      "when": "ape:projectLoaded"
    }
  ]
}
```

### 5.3 Status Bar

Flutter muestra la versión del SDK en el status bar con click para cambiar SDK.

```typescript
// status_bar_version_tracker.ts
const statusBarItem = vs.window.createStatusBarItem(vs.StatusBarAlignment.Right);
statusBarItem.text = "Flutter 3.22";
statusBarItem.command = "dart.changeFlutterSdk";
statusBarItem.show();
```

**Equivalente APE:**

```typescript
// Status bar items
"APE: IDLE"          → click → command palette de acciones
"APE v1.2.3"         → click → cambiar versión / actualizar
```

---

## 6. Sistema de Comandos

### 6.1 Registro en package.json

```json
"commands": [
  {
    "command": "flutter.createProject",
    "title": "New Project",
    "category": "Flutter"
  },
  {
    "command": "flutter.doctor",
    "title": "Run Flutter Doctor",
    "category": "Flutter"
  }
]
```

### 6.2 Visibilidad condicional (menus)

```json
"menus": {
  "commandPalette": [
    {
      "command": "flutter.doctor",
      "when": "dart-code:anyFlutterProjectLoaded"
    }
  ]
}
```

### 6.3 Implementación

Los comandos se implementan en `src/extension/commands/` y se registran en `extension.ts`:

```typescript
// extension.ts
context.subscriptions.push(
  vs.commands.registerCommand("flutter.doctor", () => runFlutterDoctor())
);
```

**Comandos APE propuestos:**

| Comando | Título | Cuando |
|---------|--------|--------|
| `ape.init` | Initialize APE Project | siempre |
| `ape.status` | Show Cycle Status | `ape:projectLoaded` |
| `ape.analyze` | Start Analysis | `ape:projectLoaded && ape:currentState == IDLE` |
| `ape.plan` | Create Plan | `ape:currentState == ANALYZE` |
| `ape.execute` | Execute Plan | `ape:currentState == PLAN` |
| `ape.evolve` | Run Evolution | `ape:currentState == EXECUTE` |
| `ape.evolution.toggle` | Toggle Evolution | `ape:projectLoaded` |
| `ape.mutations.add` | Add Mutation Note | `ape:projectLoaded` |
| `ape.doctor` | Run APE Doctor | siempre |
| `ape.install` | Install APE CLI | `!ape:cliInstalled` |
| `ape.update` | Update APE CLI | `ape:cliInstalled` |
| `ape.version` | Show Version | `ape:cliInstalled` |

---

## 7. Configuración (Settings)

Flutter usa el sistema nativo de VS Code con JSON Schema en `package.json`:

```json
"configuration": [
  {
    "title": "APE",
    "properties": {
      "ape.cliPath": {
        "type": ["null", "string"],
        "default": null,
        "description": "Path to ape executable. Auto-detected from PATH if not set."
      },
      "ape.autoEvolution": {
        "type": "boolean",
        "default": true,
        "description": "Whether to run EVOLUTION phase automatically after EXECUTE."
      },
      "ape.showStatusBar": {
        "type": "boolean",
        "default": true,
        "description": "Show APE cycle status in the status bar."
      }
    }
  }
]
```

---

## 8. Patrones Clave Reutilizables

### 8.1 Ejecución de CLI como subprocess

Flutter lanza `flutter doctor`, `flutter create`, etc. como child processes:

```typescript
// shared/processes.ts
const process = child_process.spawn(executable, args, { cwd, env });
// Lee stdout/stderr, maneja exit codes
```

**Para APE:** Ejecutar `ape status`, `ape analyze`, `ape init`, etc.

### 8.2 Output Channel

```typescript
const outputChannel = vs.window.createOutputChannel("APE");
outputChannel.appendLine("Running ape doctor...");
outputChannel.show(); // Muestra el panel
```

### 8.3 File Watchers

Flutter observa cambios en `pubspec.yaml` para auto-run `pub get`:

```typescript
const watcher = vs.workspace.createFileSystemWatcher("**/pubspec.yaml");
watcher.onDidChange(() => runPubGet());
```

**Para APE:** Observar `.ape/config.yaml`, `.ape/mutations.md`, `plan.md`.

### 8.4 WebView Provider

Para paneles con UI rica (como el cycle visualizer):

```typescript
class ApeWebviewProvider implements vs.WebviewViewProvider {
  resolveWebviewView(view: vs.WebviewView) {
    view.webview.html = this.getHtmlContent();
    // Comunicación bidireccional:
    view.webview.onDidReceiveMessage(msg => { ... });
    view.webview.postMessage({ type: "update", data: ... });
  }
}
```

### 8.5 TreeDataProvider

Para listas jerárquicas:

```typescript
class ApeIssuesProvider implements vs.TreeDataProvider<ApeIssue> {
  getTreeItem(element: ApeIssue): vs.TreeItem { ... }
  getChildren(element?: ApeIssue): ApeIssue[] { ... }
  // Refresh
  private _onDidChangeTreeData = new vs.EventEmitter<void>();
  readonly onDidChangeTreeData = this._onDidChangeTreeData.event;
  refresh() { this._onDidChangeTreeData.fire(); }
}
```

---

## 9. Dependencias Técnicas

| Paquete | Uso |
|---------|-----|
| `vscode` (API) | Core extension API |
| `vscode-languageclient` | LSP client (no necesario para APE) |
| `@vscode/debugadapter` | DAP (no necesario para APE) |
| `ws` | WebSockets (DevTools communication) |
| `semver` | Version comparison |
| `yaml` | YAML parsing |
| `minimatch` | Glob matching |

**Para APE necesitamos:**

| Paquete | Uso |
|---------|-----|
| `vscode` (API) | Core |
| `semver` | Comparar versiones de ape.exe |
| `yaml` | Parsear `.ape/config.yaml` |
| `node-fetch` o `https` | Descargar releases de GitHub |

---

## 10. Lo que Flutter NO hace (y APE SÍ debería)

| Feature | Flutter | APE |
|---------|---------|-----|
| Auto-instalar CLI | ❌ Solo link a web | ✅ Descargar desde GitHub Releases |
| Panel visual de estado | ❌ Solo texto en status bar | ✅ WebView con FSM visual |
| Editor integrado de notas | ❌ | ✅ Editor de mutations.md |
| Toggle features en panel | ❌ Solo settings | ✅ Toggles para evolution, etc. |
| Visualización de ciclo | ❌ | ✅ Diagrama FSM interactivo |
| Quick actions contextuales | Básico (hotreload) | ✅ Transiciones de estado |

---

## 11. Arquitectura Propuesta para APE Extension

```
ape-vscode/
├── package.json                ← Manifest
├── webpack.config.js
├── tsconfig.json
├── media/
│   ├── ape-icon.svg           ← Activity bar icon
│   └── webview/               ← HTML/CSS/JS para WebViews
│       ├── cycle-status.html
│       └── cycle-status.js
├── src/
│   ├── extension.ts           ← activate() / deactivate()
│   ├── config.ts              ← Wrapper de settings
│   ├── cli/
│   │   ├── detector.ts        ← Buscar ape.exe en PATH
│   │   ├── installer.ts       ← Descargar e instalar desde GitHub
│   │   ├── runner.ts          ← Ejecutar comandos ape
│   │   └── version.ts         ← Parsear y comparar versiones
│   ├── commands/
│   │   ├── init.ts            ← ape init
│   │   ├── cycle.ts           ← analyze, plan, execute, evolve
│   │   ├── mutations.ts       ← add mutation note
│   │   ├── doctor.ts          ← ape doctor
│   │   └── install.ts         ← install/update CLI
│   ├── views/
│   │   ├── cycle-status.ts    ← WebviewViewProvider (FSM diagram)
│   │   ├── issues-tree.ts     ← TreeDataProvider (issues list)
│   │   └── mutations-tree.ts  ← TreeDataProvider (mutations log)
│   ├── status-bar/
│   │   └── cycle-indicator.ts ← "APE: IDLE" in status bar
│   └── watchers/
│       └── config-watcher.ts  ← Watch .ape/ for changes
```

---

## 12. Resumen de Lecciones del Análisis

1. **package.json es el rey** — Todo se declara ahí: commands, views, menus, settings, when-clauses. La extensión de Flutter tiene 3,880 líneas de package.json.

2. **Context keys controlan todo** — `setContext()` + `when` clauses es el mecanismo para mostrar/ocultar UI condicionalmente.

3. **WebView para UI rica, TreeView para listas** — Flutter usa ambos según el caso. Nuestro cycle visualizer será un WebView; las listas de issues/mutations serán TreeViews.

4. **SDK detection es un patrón bien establecido** — PATH → config → env vars → known locations. Nosotros podemos simplificarlo porque solo tenemos un ejecutable.

5. **Output channels para logging** — Todo output de CLI va a un Output Channel dedicado.

6. **File watchers para reactividad** — Observar cambios en archivos para auto-refresh de views.

7. **Status bar items son baratos y efectivos** — Un item en la barra inferior con click-to-action es la forma más simple de dar feedback constante.

8. **No reinventar la rueda** — Usar los extension points nativos de VS Code (TreeView, WebView, StatusBar, Commands, Settings) en vez de inventar UI custom.
