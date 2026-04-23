---
id: scope-v008
title: "Scope definition for v0.0.8"
date: 2026-04-17
status: active
tags: [scope, doctor, skill, idle, triage]
author: socrates
---

# Scope v0.0.8

## 1. IDLE Triage (scheduler behavior)

El estado IDLE del scheduler APE debe funcionar correctamente. Su función es **triage** (phronesis):

- Entender lo que el usuario necesita — conversacional, exploratorio
- Identificar si hay una issue existente que atender (`gh issue list --search "keyword"`)
- O entender que hay que crear una nueva issue (`gh issue create --title "..."`)
- Clarificar el propósito antes de pasar a ANALYZE

**Requisito:** Cuando el usuario dice "pasar a ANALYZE", ya debe estar claro:
- Qué issue específica se va a atender (número + título)
- O que se debe crear una nueva issue con propósito claro

**Deliverable:** El documento `ape.agent.md` ya tiene las instrucciones de IDLE. Verificar que son suficientes.

## 2. `ape doctor` (comando CLI Dart)

Comando que verifica prerequisites del sistema:

| Check | Comando | Éxito |
|-------|---------|-------|
| APE version | `ape version` | Cualquier output válido |
| git | `git --version` | Exit code 0 |
| gh | `gh --version` | Exit code 0 |
| gh auth | `gh auth status` | Exit code 0 |
| Copilot CLI | `gh copilot --version` | Exit code 0 |

**Output:**
- Exit 0 si todos pasan
- Exit 1 con mensaje descriptivo en el primer fallo

**Testabilidad:** Inyectar `ProcessRunner` para mockear comandos externos.

## 3. Skill `issue-start`

Documento `.md` en `code/cli/assets/skills/issue-start/SKILL.md` que se despliega con `ape target get`.

Define el proceso que el scheduler APE ejecuta cuando el usuario autoriza transición IDLE → ANALYZE:

1. Si no hay issue: `gh issue create --title "..." --body "..."`
2. Leer issue: `gh issue view <NNN> --json title,number`
3. Generar slug del título
4. Crear branch: `git checkout -b <NNN>-<slug>`
5. Crear carpeta: `mkdir -p docs/issues/<NNN>-<slug>/analyze/`
6. Crear `index.md` inicial
7. Actualizar `.ape/state.yaml` → `cycle.phase: ANALYZE`, `cycle.task: "<NNN>"`

**No es código Dart.** Es instrucciones que el agente IA lee y ejecuta.

## NO está en scope v0.0.8

- Comando `ape issue start` (no existe como CLI)
- Comando `ape issue create` (wrapper innecesario de `gh issue create`)
- TUI mode
- Otros comandos de la spec futura

## Cambios al codebase

| Tipo | Archivo | Descripción |
|------|---------|-------------|
| CLI | `lib/commands/doctor.dart` | Nuevo comando |
| CLI | `lib/ape_cli.dart` | Registrar `doctor` |
| CLI | `test/doctor_test.dart` | Tests con ProcessRunner mock |
| Asset | `assets/skills/issue-start/SKILL.md` | Nueva skill |
| Asset | `assets/agents/ape.agent.md` | Verificar/refinar IDLE |
| Dep | `pubspec.yaml` | Agregar `yaml` si es necesario |
