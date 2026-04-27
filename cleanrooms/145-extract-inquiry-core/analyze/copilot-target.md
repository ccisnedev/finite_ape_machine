# Copilot Target Architecture — Capacidades completas

**Issue:** #145
**Branch:** release/0.2.0
**Status:** En análisis — referencia técnica

---

## Analogía: Copilot es el "procesador"

Si inquiry_core es un "compilador de instrucciones para AI", necesitamos conocer la arquitectura del procesador destino. Este documento mapea TODAS las capacidades de GitHub Copilot como target.

---

## Tipos de archivos de personalización

### 1. Instrucciones repository-wide (siempre activas)
- **Archivo:** `.github/copilot-instructions.md`
- **Scope:** Se aplica a TODA interacción en el contexto del repo
- **Formato:** Markdown libre, sin frontmatter requerido
- **Límite:** ~2 páginas

### 2. Instrucciones path-specific (applyTo patterns)
- **Archivo:** `.github/instructions/<NAME>.instructions.md`
- **Scope:** Se aplica SOLO cuando Copilot trabaja con archivos que matchean el glob
- **Frontmatter requerido:**
  ```yaml
  ---
  applyTo: "**/*.dart"
  ---
  ```
- **Glob syntax:**
  - `*` → archivos en directorio actual
  - `**` o `**/*` → todos los archivos recursivamente
  - `*.py` → archivos .py en directorio actual
  - `**/*.py` → archivos .py recursivamente
  - `src/**/*.py` → archivos .py bajo src/
  - `**/*.ts,**/*.tsx` → múltiples patterns separados por coma
- **Campo opcional:** `excludeAgent: "code-review"` o `"cloud-agent"`
- **Combinación:** Si aplican path-specific + repository-wide, AMBAS se usan

### 3. Custom Agents
- **Archivo repo:** `.github/agents/<name>.agent.md`
- **Archivo user-level:** `~/.copilot/agents/<name>.agent.md`
- **Frontmatter:**
  ```yaml
  ---
  name: inquiry
  description: 'Inquiry — Analyze. Plan. Execute.'
  tools: [vscode, execute, read, agent, edit, search, web, browser, todo]
  ---
  ```
- **Invocación:** `@agent-name` en chat, o auto-delegación por description
- **Cada agente define:** persona, herramientas disponibles, modelo preferido

### 4. Skills
- **Archivo user-level:** `~/.copilot/skills/<name>/SKILL.md`
- **Frontmatter:**
  ```yaml
  ---
  name: issue-start
  description: 'Protocol for starting work on GitHub issue...'
  ---
  ```
- **Función:** Procesos multi-paso, workflows reutilizables
- **Invocación:** Referenciadas por nombre en el agent prompt o por Copilot auto-detection

### 5. Prompt Files (plantillas reutilizables)
- **Archivo:** `.github/prompts/<name>.prompt.md`
- **Función:** Tareas repetibles (scaffolding, review, etc.)
- **Invocación:** Como comandos reutilizables en chat

### 6. AGENTS.md (alternativa a .agent.md)
- **Archivo:** `AGENTS.md` en cualquier directorio del repo
- **Función:** Instrucciones para agentes AI
- **Precedencia:** El `AGENTS.md` más cercano en el árbol de directorios toma precedencia
- **Alternativas:** También soporta `CLAUDE.md`, `GEMINI.md` en la raíz

### 7. Hooks (lifecycle events)
- **Función:** Ejecutar shell commands en puntos clave
- **Eventos:** PreToolUse, PostToolUse
- **Ejemplo:** Correr formatter después de cada edit, enforcing security policies

### 8. MCP Servers (Model Context Protocol)
- **Función:** Dar acceso a bases de datos, APIs, servicios externos
- **Configuración:** En settings de VS Code

### 9. Agent Plugins (preview)
- **Función:** Bundles pre-empaquetados de customizaciones
- **Contenido:** slash commands, skills, custom agents, hooks, MCP servers
- **Distribución:** Marketplace

---

## Jerarquía de prioridad

```
1. Personal instructions (usuario)          ← mayor prioridad
2. Repository instructions (.github/)
3. Organization instructions
4. Path-specific instructions (applyTo)     ← se combinan con repo-wide
```

## Descubrimiento de archivos

- VS Code busca customizations en workspace abierto
- Setting `chat.useCustomizationsInParentRepositories` permite descubrir en parent repo (monorepo)
- Camina hacia arriba hasta encontrar `.git`

## Debugging

- Menu `...` en Chat view → **Show Agent Debug Logs**
- `/create-prompt`, `/create-instruction`, `/create-skill`, `/create-agent`, `/create-hook` para generar con AI

---

## Implicaciones para inquiry_core

### Lo que Copilot soporta nativamente y que podemos aprovechar:

| Capacidad | Cómo la usa inquiry_core |
|-----------|--------------------------|
| `applyTo` patterns | Instrucciones específicas para archivos Dart, YAML, etc. |
| Path-specific instructions | Reglas distintas para `code/cli/`, `cleanrooms/`, `docs/` |
| Custom agents via `.agent.md` | El scheduler `inquiry.agent.md` |
| Skills via `SKILL.md` | Sub-agente skills (issue-start, memory-read, etc.) |
| User-level deploy (`~/.copilot/`) | `iq target get` despliega aquí |
| Hooks | Post-edit validation, auto-format |
| AGENTS.md | Alternativa más simple para repos que adopten Inquiry |

### Lo que inquiry_core GENERA:

```
methodology/          → inquiry_core generator →  ~/.copilot/agents/inquiry.agent.md
  agents/socrates/*                                ~/.copilot/skills/*/SKILL.md
  cycle/analyze.md                                 .github/copilot-instructions.md (?)
  skills/memory-read/*                             .github/instructions/*.instructions.md (?)
```

### Insight: inquiry_core conoce la "ISA" de Copilot

El generador NO concatena archivos ciegamente. Conoce:
- Qué frontmatter fields soporta cada tipo de archivo
- Qué tools están disponibles
- Qué patterns de glob usar para applyTo
- Límites de tamaño
- Jerarquía de prioridad

Es un **compilador que conoce la arquitectura del procesador destino**.

### Multi-target futuro

Cada target tiene su propia "ISA":

| Target | Agent file | Skills | Instructions | Formato |
|--------|-----------|--------|-------------|---------|
| Copilot | `.agent.md` YAML frontmatter | `SKILL.md` | `.instructions.md` + applyTo | Markdown |
| Claude Code | `CLAUDE.md` | (inline) | (inline) | Markdown |
| Cursor | `.cursorrules` | (rules) | (rules) | Markdown |
| Gemini | `GEMINI.md` | (extensions) | (inline) | Markdown |

El generador tendría un "backend" por target — como GCC tiene backends para x86, ARM, RISC-V.
