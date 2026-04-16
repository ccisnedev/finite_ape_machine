---
id: decisiones
title: "Decisiones vigentes para v0.0.2"
date: 2026-04-16
status: draft
tags: [decisiones, v002, targets, assets, build, distribucion, global, adapter-pattern, target-module]
author: socrates
---

# Decisiones vigentes para v0.0.2

Solo decisiones vigentes. Formato conciso: decisión + justificación.

## D4: El binario (con assets en disco) es la fuente de verdad

Los archivos `.md` de agentes y skills del framework viven junto al binario en una carpeta `assets/`, no en el repo del usuario. El binario + `assets/` forman la unidad de distribución. La versión canónica vive en el repositorio `finite_ape_machine`.

**Justificación:** Modelo Flutter — el SDK lleva los templates. No hay intermediario `.ape/` canónico.

## D5: Assets como archivos en disco (clase Assets)

Los assets son archivos `.md` reales junto al ejecutable compilado. Una clase `Assets` los lee en runtime:

```dart
class Assets {
  static final String _root = p.dirname(p.dirname(Platform.resolvedExecutable));
  
  static String path(String relativePath) =>
      p.join(_root, 'assets', relativePath);

  static String loadString(String relativePath) =>
      File(path(relativePath)).readAsStringSync();
}
```

**Justificación:** La solución más simple. Archivos reales, legibles, diffeables. Sin codegen, sin paquetes adicionales.

## D6 + D17: Generar todos los targets, sin selección

`ape target get` despliega a los 5 targets siempre. Sin flags de selección. Sin interacción.

**Justificación:** YAGNI. No hay caso de uso para selección parcial en v0.0.2.

## D8: Estructura de build

```
build/
├── bin/
│   └── ape.exe
└── assets/
    ├── agents/
    │   └── ape.agent.md
    └── skills/
        ├── memory-read/
        │   └── SKILL.md
        └── memory-write/
            └── SKILL.md
```

Build: `dart compile exe` + copiar `assets/`. La clase `Assets` resuelve navegando un nivel arriba desde el ejecutable.

## D11: Distribución = GitHub Release + install.ps1 (Windows-only)

Canal único. El release contiene un `.zip` con la estructura de D8. Script PowerShell:

```
irm https://raw.githubusercontent.com/ccisnedev/finite_ape_machine/main/install.ps1 | iex
```

Descarga, extrae, agrega al PATH. No se necesita dominio.

## D12: APE es herramienta global

`ape target get` escribe a paths **globales** del sistema (`~/.copilot/`, `~/.claude/`, etc.), no dentro del repositorio. Los archivos generados son del usuario, regenerables, no se comitean.

**Justificación:** Elimina tensiones de ownership per-repo. Modelo idéntico a gentle-ai.

## D13: 5 targets

| Target | Path global (por verificar) |
|--------|---------------------------|
| GitHub Copilot (VS Code) | `~/.copilot/` |
| Claude Code | `~/.claude/` |
| Codex | `~/.config/codex/` |
| Crush (ex OpenCode) | `~/.config/crush/` |
| Gemini CLI | `~/.config/gemini/` |

Los paths exactos y capacidades por target se verifican durante implementación.

## D14: Adapter pattern

Cada target es un adapter que encapsula: paths globales, estrategia de inyección, capacidades soportadas. Sin switch statements en la lógica de negocio.

**Justificación:** 5 targets distintos. Patrón validado por gentle-ai (11 targets).

## D15 + D19: Tres módulos, nombre `target`

| Módulo | Responsabilidad | v0.0.2 |
|--------|----------------|--------|
| `target` | Desplegar/limpiar agentes y skills en paths globales | **En alcance** |
| `bin` | Gestión del binario (upgrade, uninstall) | Diferido |
| `repo` | Operaciones per-repo (.ape/, memoria) | Diferido |

Nombre `target`: sustantivo singular, describe el destino de la operación.

## D16: Install script ejecuta `ape target get`

`install.ps1` ejecuta `ape target get` tras instalar el binario. El usuario obtiene un sistema funcional sin pasos adicionales.

## D18: `ape target get` es idempotente (clean + redeploy)

Cada ejecución limpia lo desplegado y vuelve a desplegar desde cero. Sin distinción entre "primera vez" y "refresh".

## Elementos diferidos

| Elemento | Razón |
|----------|-------|
| `.ape/` per-repo (`ape repo init`) | Sin contenido útil para v0.0.2 |
| `ape bin upgrade` / `ape bin uninstall` | Módulo `bin` diferido |
| Modelo clon del repo | Aspiración futura |
| Soporte macOS/Linux | Windows-only en v0.0.2 |
| TUI, memory, tasks, git, darwin | Pertenecen a spec v0.2.0 |
