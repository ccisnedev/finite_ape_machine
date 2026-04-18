---
id: scope-and-audit-overview
title: "Scope overview and cross-platform audit findings for v0.0.11"
date: 2026-04-18
status: draft
tags: [scope, audit, cross-platform, fsm, linux, doctor]
author: socrates
---

# Scope Overview and Cross-Platform Audit Findings

## Scope as Stated

Issue #44 (v0.0.11) agrupa tres bundles:

| Bundle | Contenido | Issues relacionadas |
|--------|-----------|---------------------|
| A: FSM Fix | END state, EVOLUTION opcional, retrospectiva post-EXECUTE, Git workflow | #43, #30, #32 |
| B: Linux Support | Release Linux, install.sh, web tabs, auditoría cross-platform | — |
| C: Doctor Enhancement | Check de extensión VS Code Copilot vía `code --list-extensions` | — |

Adicionalmente: revisión de issues abiertos para cerrar los ya resueltos por PRs previos.

## Audit Findings

### Código crítico (Windows-only)

1. **upgrade.dart** — `ape-windows-x64.zip` hardcoded, PowerShell `Expand-Archive`, lógica `.bak`, nombre `ape.exe`
2. **uninstall.dart** — `cmd /c timeout`, PowerShell `System.Environment` para PATH
3. **install.ps1** — check explícito Windows en línea 16, `%LOCALAPPDATA%`, registro Windows para PATH
4. **build.ps1** — solo PowerShell, output `ape.exe`
5. **release.yml** — solo `windows-latest`, workaround Defender, solo `ape-windows-x64.zip`
6. **init.dart línea 78** — `path.replaceFirst('$root\\', '')` usa backslash literal

### Código portable (sin cambios)

- `doctor.dart`, `version.dart`, `target_get.dart`, `target_clean.dart`
- `deployer.dart` — usa paquete `path`
- Todos los adapters (copilot, claude, codex, crush, gemini) — rutas `~/.tool/`
- `assets.dart` — usa paquete `path`
- `ape_cli.dart` — fallback correcto: `USERPROFILE ?? HOME ?? ''`

## Issues abiertos pendientes

| Issue | Tema | ¿En scope v0.0.11? |
|-------|------|---------------------|
| #43 | END state en FSM, EVOLUTION opcional | Sí (Bundle A) |
| #33 | Agente especializado para fase PLAN | No |
| #32 | Integrar Git workflow en ciclo APE | Sí (Bundle A) |
| #31 | Mecanismo spawn issue y trazabilidad | No |
| #30 | Formalizar retrospectiva post-EXECUTE | Sí (Bundle A) |
| #29 | Implementar linter/gate de documentos | No |
| #28 | Formalizar dos rutas de entrada al ciclo APE | No |
| #27 | Riesgos deben ser artefactos analizados | No |

## Preguntas abiertas

- ¿Qué relación tiene Bundle A (FSM) con Bundle B (Linux)? ¿Son independientes o hay dependencias ocultas?
- ¿El cambio en release.yml para Linux (Bundle B) colisiona con el workaround de Defender (Bundle A hereda el workflow actual)?
- ¿Qué significa "cross-platform" para upgrade y uninstall? ¿Abstracción compartida o implementaciones separadas por OS?
- ¿El doctor check de VS Code (Bundle C) funciona igual en Linux? ¿Existe `code` en PATH en entornos Linux típicos?
- ¿init.dart línea 78 es el único punto con separador hardcoded, o hay más que la auditoría no capturó?
