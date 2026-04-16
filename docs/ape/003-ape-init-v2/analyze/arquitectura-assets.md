---
id: arquitectura-assets
title: "Arquitectura de assets v0.0.2"
date: 2026-04-16
status: draft
tags: [arquitectura, assets, build, targets, global]
author: socrates
---

# Arquitectura de assets v0.0.2

## Modelo de distribución

```
finite_ape_machine/code/cli/assets/   → archivos .md fuente (repo)
build/bin/ape.exe                     → binario compilado
build/assets/                         → copia de los .md fuente (distribución)
~/.copilot/, ~/.claude/, etc.         → archivos desplegados por ape target get
```

## Qué vive junto al binario

Assets del framework — definidos por el equipo de APE, no por el usuario.

| Asset | Ruta en build/ |
|-------|---------------|
| Agente APE | `assets/agents/ape.agent.md` |
| Skill memory-read | `assets/skills/memory-read/SKILL.md` |
| Skill memory-write | `assets/skills/memory-write/SKILL.md` |

Versionados con el binario. Se actualizan cuando el usuario obtiene una nueva versión.

## Qué se genera por target

`ape target get` lee los assets del disco y los despliega a los paths globales de cada target.

| Target | Directorio global | Skills | Agente |
|--------|------------------|--------|--------|
| Copilot | `~/.copilot/` | `~/.copilot/skills/` | Por verificar |
| Claude | `~/.claude/` | `~/.claude/skills/` | Por verificar |
| Codex | `~/.config/codex/` | Por verificar | Por verificar |
| Crush | `~/.config/crush/` | Por verificar | Por verificar |
| Gemini | `~/.config/gemini/` | Por verificar | Por verificar |

**Skills:** se copian idénticas a todos los targets (evidencia gentle-ai). Solo cambia el path.

**Agentes:** pueden requerir adaptación por target. El adapter encapsula la estrategia de inyección.

## Mecanismo de acceso

```dart
class Assets {
  static final String _root = p.dirname(p.dirname(Platform.resolvedExecutable));
  
  static String loadString(String relativePath) =>
      File(p.join(_root, 'assets', relativePath)).readAsStringSync();
}
```

Resolución: ejecutable en `build/bin/`, un nivel arriba → raíz de `build/`, luego `assets/`.
