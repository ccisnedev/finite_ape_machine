# Análisis del Estado Actual — Finite APE Machine (Inquiry)

**Fecha:** Abril 22, 2026  
**Versión:** 0.1.2

---

## Resumen Ejecutivo

**Inquiry** es una metodología de desarrollo asistido por IA que modela el proceso de codificación como una **máquina de estados finita (FSM)** de 5 estados: `IDLE → ANALYZE → PLAN → EXECUTE → END → EVOLUTION → IDLE`.

El proyecto consta de tres componentes principales:
1. **CLI** (Dart) — motor de la metodología, orquesta transiciones de estado
2. **Sitio web** (HTML/CSS/JS) — landing page, documentación, descargas
3. **Extensión VS Code** (TypeScript) — interfaz visual integrada en el editor

**Estado:** MVP funcional en v0.1.2 con **131 tests**, cross-platform (Windows + Linux), single-target (Copilot) por decisión arquitectónica (ADR D20).

---

## 1. La Metodología (en `docs/`)

### 1.1 Fundamentos filosóficos

La metodología se basa en la **teoría de la investigación de Peirce** (Abducción → Deducción → Inducción):

| Fase APE | Ape | Función | Salida | Mapeo Peirce |
|----------|-----|---------|--------|-------------|
| **ANALYZE** | SOCRATES | Aclarar el problema mediante diálogo (mayéutica) | `diagnosis.md` | Abducción |
| **PLAN** | DESCARTES | Descomponer, ordenar, verificar, enumerar | `plan.md` | Deducción |
| **EXECUTE** | BASHŌ | Implementación mínima y hermosa bajo restricciones de tests | código + commits | Inducción |
| **END** | — | Gate de PR: crear y mergear | PR merged | — |
| **EVOLUTION** | DARWIN | Selección natural: proponer mutaciones | issues en repo APE | Metaaprendizaje |

### 1.2 Principios clave

**1. Metodología > Modelo**
- Apostar que un modelo pequeño siguiendo un runbook estructurado supera a un modelo frontier improvisando
- La metodología es el artefacto duradero, no el modelo de IA

**2. Memory as Code**
- Conocimiento del proyecto versionado en el repo, no en DBs vectoriales en la nube
- Queryable, reproducible, agnóstico de infraestructura

**3. Antifragilidad**
- Cada ciclo debe dejar APE mediblemente mejor
- DARWIN propone mutaciones basadas en evidencia (metrics.yaml, issues de evolución)

**4. AAD/AAE/AAM**
- **AAD** (Agent-Aided Design): ANALYZE — soberanía humana
- **AAE** (Agent-Aided Engineering): PLAN + test definition — colaboración profunda
- **AAM** (Agent-Aided Manufacturing): EXECUTE — IA dominante, humano supervisa

### 1.3 Documentación de la metodología

```
docs/
├── spec/
│   ├── finite-ape-machine.md          ← Manifesto + teoría de control
│   ├── agent-lifecycle.md             ← Ciclo de vida del agente
│   ├── memory-as-code-spec.md         ← Arquitectura de memoria
│   ├── cli-as-api.md                  ← Principio: skills → comandos CLI
│   ├── target-specific-agents.md      ← Estrategia de deployment multi-target
│   └── index.md                       ← Índice de specs
├── research/
│   ├── ape_builds_ape/                ← Bootstrap empírico (APE construyendo APE)
│   ├── inquiry/                       ← Fundamentación de Peirce
│   └── swebok/                        ← Referencias de ingeniería
├── adr/                               ← Architecture Decision Records (Nygard format)
│   ├── 0001-record-architecture-decisions.md
│   ├── 0002-ape-builds-ape.md
│   └── ...
├── cleanrooms/                        ← Por-ciclo work-in-progress
│   ├── 002-ape-init/
│   ├── 003-ape-init-v2/
│   └── ...
└── roadmap.md                         ← Dirección futura (v0.1.x → v0.5.0 → v1.0+)
```

**Estado:** La metodología está **bien documentada** en `docs/spec/`. Cada decisión arquitectónica tiene respaldo en `docs/adr/`. El bootstrap empírico está en marcha en `docs/research/ape_builds_ape/`.

---

## 2. Componente 1: CLI (Dart)

### 2.1 Qué es

Ejecutable multiplataforma (`inquiry.exe` en Windows, `inquiry` en Linux) que orquesta el FSM. Es el **motor central** de la metodología.

### 2.2 Estructura

```
code/cli/
├── lib/
│   ├── fsm_contract.dart              ← Máquina de estados declarativa
│   ├── inquiry_cli.dart               ← Entry point
│   ├── modules/                       ← Modularización (global, target, state)
│   │   ├── global/                    ← Comandos globales (init, doctor, version)
│   │   ├── target/                    ← Deployment (target get/clean)
│   │   └── state/                     ← Transiciones de estado FSM
│   ├── src/                           ← Utilidades (YAML parsing, efectos, prechecks)
│   └── targets/                       ← Adapters para múltiples herramientas
├── bin/
│   └── main.dart                      ← CLI entry
├── test/                              ← 131 tests
├── pubspec.yaml
├── analysis_options.yaml
├── CHANGELOG.md
└── README.md
```

### 2.3 Módulos principales

| Módulo | Responsabilidad |
|--------|-----------------|
| **global** | `iq init`, `iq doctor`, `iq version`, `iq upgrade`, `iq uninstall`, `iq` (TUI) |
| **target** | `iq target get` (deploy agents/skills a Copilot), `iq target clean` |
| **state** | `iq state transition --event <e>` (cambios de estado determinísticos) |

### 2.4 Dependencias

- `cli_router` — enrutamiento puro de comandos
- `modular_cli_sdk` — framework para CLI (orchestration, DTO, output)
- `yaml` — parsing de `state.yaml`, `config.yaml`, transition_contract.yaml
- Dart SDK 3.8.1+

### 2.5 Compilación y distribución

**Build:**
- Windows: `dart compile exe bin/main.dart -o inquiry.exe`
- Linux/macOS: `dart compile exe bin/main.dart -o inquiry`
- Multiplatform via GitHub Actions (Windows + Linux + macOS Intel/ARM)

**Distribución:**
- GitHub Releases (binarios precompilados)
- Scripts de instalación: `install.ps1` (Windows), `install.sh` (Linux)
- Almacenamiento en `~/.inquiry/bin/` (con fallback a `%LOCALAPPDATA%\inquiry\`)

### 2.6 Comandos actuales (v0.1.2)

```bash
iq                              # TUI banner con estado FSM actual
iq init                         # Crear .inquiry/ (idempotente)
iq doctor                       # Verificar prerequisitos (git, gh, gh auth)
iq version                      # Mostrar versión
iq upgrade                      # Descargar última release
iq uninstall                    # Remover CLI
iq target get                   # Desplegar agent + skills a Copilot
iq target clean                 # Limpiar archivos desplegados
iq state transition --event <e> # Ejecutar transición FSM con prechecks/efectos
```

### 2.7 Comandos planeados (roadmap)

- `iq memory query` — busca indexadas en `docs/`
- `iq memory validate` — validación de schema YAML
- `iq memory write` — creación guiada de documentos
- `iq task` — wrapper en `gh issue/pr create/merge` con prechecks

### 2.8 Estado actual

✅ **Estable**: Transiciones FSM, deployment de targets, TUI, doctor  
🟡 **En desarrollo**: `memory-*` commands, metrics collection (issue #72)  
⏳ **Planeado**: Multi-target wiring (ADR D20 — deferred), local-first (v1.0)

---

## 3. Componente 2: Sitio Web

### 3.1 Qué es

Landing page, documentación visual, y scripts de instalación. Punto de entrada público.

### 3.2 Estructura

```
code/site/
├── index.html                         ← Landing principal
├── agents.html                        ← Presentación de los 4 apes
├── methodology.html                   ← Explicación de FSM + AAD/AAE/AAM
├── ape-builds-ape.html                ← Bootstrap empírico
├── evolution.html                     ← DARWIN y mutaciones
├── install.ps1                        ← Script de instalación (Windows)
├── install.sh                         ← Script de instalación (Linux/macOS)
├── CNAME                              ← inquiry.si14bm.com
├── css/
│   ├── shared.css
│   ├── landing.css
│   └── ...
├── js/
│   └── main.js
├── img/
│   ├── fsm.svg                        ← Diagrama de la máquina de estados
│   ├── favicon.svg
│   └── ...
└── docs/                              ← Redirecciones a GitHub docs/
```

### 3.3 Características

- **Responsive design** (mobile-first)
- **Copy-paste install commands** por OS (Windows → PowerShell, Linux → Bash)
- **FSM diagram interactivo** (SVG)
- **Links a metodología, roadmap, spec**
- **Meta tags** para SEO (og:, twitter:)

### 3.4 Hosting

- Dominio: `inquiry.si14bm.com`
- Hosteado en GitHub Pages (rama `main` + CNAME)
- Build: estático (sin SSG, pure HTML/CSS/JS)

### 3.5 Estado actual

✅ **Completo**: Landing, copy-paste installs, links a documentación  
🟡 **Pendiente**: Deep-dive pages (agents, methodology, evolution) — existen pero necesitan más pulido

---

## 4. Componente 3: Extensión VS Code

### 4.1 Qué es

Plugin de VS Code que proporciona interfaz visual (sidebar, command palette, status bar) para la metodología APE. **No es obligatoria** — la CLI es suficiente.

### 4.2 Visión

Convertir VS Code en el "centro de mando" del ciclo APE sin sacrificar la opción de usar la terminal.

| Sin extensión | Con extensión |
|---------------|---------------|
| `iq doctor` en terminal | Panel visual con checks/fails |
| `iq state transition -e start_analysis` en terminal | Click en botón |
| Editar `.inquiry/mutations.md` manualmente | Editor inline con timestamp |
| Desconocer el estado actual | Status bar: `APE: ANALYZE #42` |

### 4.3 Estructura

```
code/vscode/
├── package.json                       ← Manifiesto (v0.1.2, 25 comandos, 3 views)
├── tsconfig.json
├── webpack.config.js                  ← Build: TS → JS → out/dist/extension.js
├── CHANGELOG.md
├── README.md
│
├── src/
│   ├── extension.ts                   ← activate() / deactivate()
│   ├── config.ts                      ← Wrapper sobre vscode.workspace.getConfiguration
│   ├── constants.ts                   ← Context keys, paths, nombres
│   │
│   ├── cli/
│   │   ├── detector.ts                ← Buscar inquiry.exe en PATH
│   │   ├── installer.ts               ← Descargar desde GitHub Releases
│   │   ├── runner.ts                  ← Ejecutar comandos CLI y parsear output
│   │   └── version.ts                 ← Semver compare
│   │
│   ├── commands/                      ← Implementación de comandos VS Code
│   │   ├── init.ts
│   │   ├── cycle.ts                   ← analyze, plan, execute, evolve, end
│   │   ├── mutations.ts
│   │   ├── doctor.ts
│   │   ├── install.ts
│   │   ├── target.ts
│   │   └── state.ts
│   │
│   ├── views/                         ← Sidebar panels
│   │   ├── cycle-status.ts            ← WebView — FSM diagram
│   │   ├── plan-tree.ts               ← TreeView — plan.md checkboxes
│   │   ├── doctor-tree.ts             ← TreeView — prerequisite checks
│   │   └── mutations-editor.ts        ← WebView — mutations.md editor
│   │
│   ├── status-bar/
│   │   └── cycle-indicator.ts         ← "APE: IDLE" / "APE: ANALYZE #42"
│   │
│   ├── watchers/
│   │   ├── state-watcher.ts           ← Watch .inquiry/state.yaml → refresh
│   │   ├── config-watcher.ts
│   │   └── plan-watcher.ts
│   │
│   └── utils/
│       ├── fs.ts, yaml.ts, github.ts
│
├── media/
│   ├── ape-icon.svg
│   ├── states/                        ← Íconos por estado FSM
│   └── webview/
│
├── test/
└── docs/
    ├── ape_vscode_extension.md        ← Especificación
    └── flutter_vscode_extension.md    ← Análisis de Flutter extension (referencia)
```

### 4.4 Activation Events

```json
"activationEvents": [
  "workspaceContains:.inquiry/",
  "onCommand:inquiry.init",
  "onCommand:ape.install",
  "onCommand:ape.doctor"
]
```

Activa cuando:
- El workspace contiene `.inquiry/` (proyecto APE existente)
- Usuario ejecuta manualmente un comando APE

### 4.5 Context Keys (cuando clauses)

Control condicional de UI mediante contexto:

```
"ape:cliInstalled"       → visibility de comandos
"ape:projectLoaded"      → visibility de sidebar
"ape:currentState"       → qué botones mostrar
"ape:cycleActive"        → habilitar/deshabilitar transiciones
"ape:evolutionEnabled"   → mostrar panel de evolution
```

### 4.6 Comandos principales

| Comando | Categoría | Cuando |
|---------|-----------|--------|
| `inquiry.init` | Setup | siempre |
| `ape.doctor` | Setup | siempre |
| `ape.install` / `ape.update` | Setup | si no instalado / versión vieja |
| `ape.target.get` | Setup | si instalado |
| `ape.startAnalysis` | Ciclo | IDLE + proyecto cargado |
| `ape.approveDiagnosis` | Ciclo | ANALYZE + diagnosis.md existe |
| `ape.approvePlan` | Ciclo | PLAN + plan.md existe |
| `ape.approveExecution` | Ciclo | EXECUTE |
| `ape.createPR` | Ciclo | END |
| `ape.abortCycle` | Ciclo | cualquier estado activo |
| `ape.returnToAnalysis` | Ciclo | PLAN o EXECUTE (transiciones backward) |
| `ape.evolution.toggle` | Config | proyecto cargado |

### 4.7 Views (Sidebar)

- **Cycle Status** — WebView con diagrama FSM interactivo
- **Plan Tree** — TreeView con checkboxes del plan.md
- **Doctor Tree** — TreeView con estado de prerequisitos
- **Mutations Editor** — WebView para editar mutations.md

### 4.8 State actual

🟡 **En desarrollo** (v0.1.2): Estructura definida, no todos los comandos/views implementados  
⏳ **Prioritario**: Completar panels de sidebar, watchers de archivo, UX de installer

---

## 5. Capas Transversales

### 5.1 `.inquiry/` — Runtime per-ciclo

```
.inquiry/
├── state.yaml                         ← Estado FSM actual (IDLE, ANALYZE, etc.)
├── config.yaml                        ← Configuración (evolution.enabled, etc.)
└── mutations.md                       ← Notas para DARWIN (evol. phase)
```

**Responsabilidad:**
- Estado actual persiste aquí
- CLI lee esto para saber qué transición es válida
- Agent + skills consultan para saber la fase actual

### 5.2 Agentes Desplegados

```
~/.copilot/agents/
└── inquiry.agent.md                   ← Orquestador single (léase: "multiple conductas")

~/.copilot/skills/
├── issue-start/SKILL.md               ← Protocolo: crear rama, iniciar análisis
├── issue-end/SKILL.md                 ← Protocolo: crear PR, mergear
├── memory-read/SKILL.md               ← Protocolo: query indexada en docs/
└── memory-write/SKILL.md              ← Protocolo: crear docs con YAML frontmatter
```

**Nota importante:** No son 4 agentes separados. Es **un solo `inquiry.agent.md`** que se comporta diferente según el estado en `.inquiry/state.yaml`. El design simplifica coordination.

### 5.3 `docs/issues/NNN-slug/` — Artifacts por ciclo

```
docs/issues/
├── 001-nombre-primer-issue/
│   ├── analysis/
│   │   └── index.md (SOCRATES output)
│   ├── plan.md (DESCARTES output + checkboxes)
│   ├── metrics.yaml (DARWIN input para evolución #72)
│   └── evolution/
│       └── mutations.md (qué cambios propone DARWIN)
├── 002-segundo-issue/
│   └── ...
```

---

## 6. Estado General del Proyecto

### 6.1 Versión Actual

**v0.1.2** (Abril 2026)
- 131 tests
- 12 GitHub releases
- Cross-platform (Windows + Linux; macOS future)
- Single-target MVP (solo Copilot, per ADR D20)

### 6.2 Hito de Completitud

| Componente | Estado | Completitud |
|------------|--------|-------------|
| **Metodología** | ✅ Documentada | 90% |
| **CLI Core** | ✅ Estable | 85% |
| **CLI Commands** | 🟡 Parcial | 70% (memory-* pending) |
| **Sitio Web** | ✅ Funcional | 75% |
| **VS Code Ext** | 🟡 WIP | 50% (estructura, no UI complete) |
| **Tests** | ✅ Buena cobertura | 80% |

### 6.3 Roadmap

**v0.1.x (Near-term):**
- ✅ 5-state FSM completo
- ✅ Comandos globales + target deployment
- 🟡 #47–#49: Cycle memory infrastructure
- 🟡 #46: Subagent delegation (ANALYZE phase)
- 🟡 #72: `metrics.yaml` collection (reproducibility)

**v0.5.0 (Mid-term):**
- `iq memory` CLI (query, validate, write)
- `iq task` CLI (wrapper en gh issue/pr)
- Multi-target reactivation (Claude, Crush, Gemini)
- Antifragility validation harness

**v1.0+ (Long-term):**
- Local-first APE (Gemma, Qwen, etc.)
- Bootstrap-validation paper
- DARWIN community-level learning
- Risk-matrix-driven UX

---

## 7. Decisiones Arquitectónicas Clave

| ID | Decisión | Estado |
|----|----------|--------|
| **D1** | One agent, many behaviors (state-driven) | ✅ Implementado |
| **D2** | Total FSM (every state×event explicit) | ✅ Implementado |
| **D3** | CLI enforces, agent proposes | ✅ Implementado |
| **D4** | Skills as step-by-step protocols (markdown) | ✅ Implementado |
| **D5** | Memory in repo (no external vector DB) | ✅ Implementado |
| **D6** | Single target until MVP (Copilot only) | ✅ Implementado |
| **D7** | EVOLUTION opt-in (config.yaml flag) | ✅ Implementado |
| **D20** | Target-specific agents (ADR) | ✅ Deferred multi-target |

---

## 8. Necesidades Identificadas

### 8.1 Documentación

✅ **Bien cubierta:**
- Metodología (docs/spec/)
- ADRs (docs/adr/)
- Bootstrap empírico (docs/research/ape_builds_ape/)

🟡 **Mejorables:**
- Guía de usuario (README en sitio web es bueno, pero falta "cómo usar APE paso a paso")
- Troubleshooting (qué hacer si algo falla)
- Developer guide (cómo extender APE)

### 8.2 Funcionalidad

✅ **Completo:**
- FSM core
- Target deployment (Copilot)
- Doctor + version

🟡 **Pendiente (roadmap):**
- `memory-*` commands (query, write, validate)
- Metrics collection (#72)
- VS Code extension UI (solo estructura exist, falta implementación)
- Multi-target wiring

### 8.3 Testing

✅ **131 tests** con buen coverage  
🟡 **Pendiente:**
- Integration tests (CLI + agent interacción)
- E2E tests (full cycle: init → analyze → plan → execute → merge)

---

## 9. Conclusión

**Inquiry** es un proyecto **bien estructurado y documentado** en su componente metodológico. El CLI es **estable y funcional** como motor central. El sitio web es **adecuado para difusión**. La extensión VS Code es **conceptualmente sólida** pero está en fase de implementación.

El proyecto está en una **posición de madurez media**:
- ✅ La metodología está clara y tiene respaldo teórico
- ✅ El CLI funciona y es confiable
- 🟡 Algunos comandos importantes aún faltan (memory-*)
- 🟡 La extensión VS Code es WIP
- ⏳ Multi-target es future work (consciente, por ADR)

**Próximos pasos sugeridos:**
1. Completar VS Code extension UI (sidebar views, watchers)
2. Implementar `memory-*` commands en CLI
3. Agregar `metrics.yaml` collection para recolección de datos empíricos (#72)
4. Escribir guía de usuario paso-a-paso
5. Iniciar multi-target wiring (Claude, Crush) en v0.2.0+
