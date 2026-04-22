---
id: alcance-v002
title: "Alcance v0.0.2: herramienta global con módulo target y cinco targets"
date: 2026-04-16
status: draft
tags: [alcance, v002, global, targets, assets, distribucion, adapter-pattern, target-module]
author: socrates
---

# Alcance v0.0.2

APE v0.0.2 es una herramienta global que despliega agentes y skills del framework a los paths globales de 5 AI coding tools.

## Qué entra

### 1. Clase Assets + archivos .md fuente

Clase `Assets` en el proyecto CLI que lee archivos `.md` del disco resolviendo rutas relativas al ejecutable (D5). Los archivos fuente viven en `assets/` dentro del proyecto:

| Artefacto | Archivo fuente | Origen actual (a migrar) |
|-----------|---------------|--------------------------|
| Agente APE | `assets/agents/ape.agent.md` | `ccisnedev/ai → ape/ape.agent.md` |
| Skill memory-read | `assets/skills/memory-read/SKILL.md` | `ccisnedev/ai → skills/memory-read/SKILL.md` |
| Skill memory-write | `assets/skills/memory-write/SKILL.md` | `ccisnedev/ai → skills/memory-write/SKILL.md` |

### 2. Adapter pattern (5 targets)

Cada target implementa un adapter (D14) que encapsula paths globales y capacidades:

| Target | Path global (por verificar) |
|--------|---------------------------|
| GitHub Copilot | `~/.copilot/` |
| Claude Code | `~/.claude/` |
| Codex | `~/.config/codex/` |
| Crush | `~/.config/crush/` |
| Gemini CLI | `~/.config/gemini/` |

Skills se copian idénticas a todos los targets (evidencia gentle-ai). Agentes pueden requerir adaptación por target (formato de frontmatter, estrategia de inyección).

### 3. Módulo `target` con comandos `get` y `clean`

```
ape target get      # Despliega a TODOS los 5 targets (idempotente: clean + redeploy)
ape target clean    # Elimina archivos desplegados de todos los targets
ape version         # Ya existe
```

- Sin selección de target (D6 + D17)
- Idempotente (D18)
- Sin interacción

### 4. Script install.ps1 + GitHub Release

- GitHub Release con `.zip` conteniendo `bin/ape.exe` + `assets/` (D8, D11)
- Script PowerShell que descarga, extrae, agrega al PATH
- El script ejecuta `ape target get` al finalizar (D16)
- Windows-only para v0.0.2

## Entregables

| # | Entregable | Depende de |
|---|-----------|------------|
| E1 | Clase `Assets` + archivos `.md` fuente en `assets/` | — |
| E2 | Adapter pattern (interfaz + 5 implementaciones) | — |
| E3 | Módulo `target` (`get` + `clean`) | E1 + E2 |
| E4 | Script `install.ps1` + GitHub Release | E3 |

E1 y E2 pueden desarrollarse en paralelo. E3 depende de ambos. E4 depende de E3.

## Qué no entra

| Excluido | Razón |
|----------|-------|
| `.ape/` per-repo | Sin contenido útil, diferido a `ape repo init` |
| `ape bin upgrade/uninstall` | Módulo `bin` diferido |
| Soporte macOS/Linux | Windows-only simplifica v0.0.2 |
| TUI, memory, tasks, hooks | Spec v0.2.0 |

## Preguntas abiertas (implementación)

### B. Formato de agentes por target

¿El agente se copia idéntico o se transforma? VS Code requiere YAML frontmatter (`name`, `description`, `tools`). Claude y otros pueden diferir. Se resuelve durante implementación investigando cada target.

### C. Capacidades dispares entre targets

¿Todos soportan skills como archivos separados? ¿Todos soportan sub-agentes? El adapter pattern absorbe las diferencias, pero los datos concretos se obtienen durante implementación.
