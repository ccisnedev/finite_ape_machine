---
id: diagnosis
title: "Diagnóstico final — routing catch-all, version desync, doctor checks"
date: 2026-04-18
status: active
tags: [routing, catch-all, version-desync, doctor, cli-router, dispatch, diagnosis]
author: socrates
---

# Diagnóstico final — Issue #58

Resultado de 6 rondas de análisis socrático sobre los tres bugs reportados en issue #58.

## Bug 1 — Routing catch-all rompe módulos y --help

### Síntoma

La ruta vacía `''` registrada para el banner/TUI actúa como catch-all. Ningún módulo montado es alcanzable. `ape --help` muestra el banner en vez de la lista de comandos.

### Causa raíz

En `cli_router/lib/src/cli_router.dart`, el método `_dispatch` itera:

```dart
for (int j = maxRouteTokens; j >= 0; j--)
```

Cuando `j` llega a `0`, el candidato `[]` (0 segmentos) siempre hace match con la ruta vacía `''`. Esto ocurre **antes** de evaluar los mounts, por lo que:

- `ape target get` → match con `''` → banner (en vez del módulo `target`)
- `ape --help` → flags se extraen, `maxRouteTokens=0`, match inmediato con `''` → banner
- Ningún mount es alcanzable porque `''` intercepta todo

### Fix decidido

En `cli_router`, la ruta vacía `''` debe hacer match **solo** cuando `args` está genuinamente vacío (`args.isEmpty`). Cuando args no está vacío pero el loop llega a `j=0`, la ruta vacía **no** debe hacer match. Es un fix de una condición en `_dispatch`.

### Dónde vive el fix

En **cli_router** (no en ape_cli). La ruta vacía actuando como catch-all es objetivamente un bug en la lógica de dispatch. cli_router es parte del ecosistema y debe corregirse en origen.

## Bug 2 — version.dart desincronizado

### Síntoma

`pubspec.yaml` dice `0.0.12` pero `lib/src/version.dart` tiene `'0.0.11'`. El binario compilado reporta versión incorrecta. `ape upgrade` descarga correctamente pero el binario nuevo muestra `0.0.11`.

### Causa raíz

Al hacer bump a `0.0.12`, `lib/src/version.dart` no fue actualizado. Omisión en el proceso de release.

### Fix decidido

Sincronizar ambos archivos. Bump a `0.0.13` ya que esta corrección constituye una nueva release.

## Bug 3 — Doctor checks no solicitados

### Síntoma

`ape doctor` valida `gh copilot` y VS Code Copilot. El check de VS Code ejecuta `code --list-extensions` que abre VS Code innecesariamente y la detección no funciona correctamente.

### Causa raíz

Ambos checks fueron añadidos sin haberlos solicitado. No cumplen el criterio de alcance.

### Fix decidido

Eliminar ambos checks. Criterio de alcance: **doctor valida solo herramientas que APE invoca directamente**: `ape`, `git`, `gh`, `gh auth`.

## Decisiones de diseño

1. **`--help` es un modificador** (ADR-0003), no output independiente — no requiere ruta propia
2. **Criterio de alcance de doctor**: "herramientas que APE invoca directamente"
3. **El fix vive en cli_router**, no es un parche en ape_cli — es un bug real en la lógica de dispatch
4. **El concepto de "módulo global"** fue explorado pero **no es necesario** para este fix — es un enhancement futuro separado

## Orden de ejecución (cadena de dependencias)

### Fase 1 — cli_router

1. Crear issue en repo `macss-dev/cli_router`
2. Fix con TDD (testear comportamiento de ruta vacía con args vacíos y no vacíos)
3. Bump versión de cli_router
4. Crear PR, merge, publicar en pub.dev

### Fase 2 — ape_cli

1. Bump dependencia de cli_router
2. Corregir `version.dart`
3. Eliminar checks de doctor (`gh copilot` + VS Code Copilot)
4. Bump a `0.0.13`
5. Tests
6. PR, merge, compilar + release

## Alcance

### Dentro del alcance

- cli_router: guard para ruta vacía en dispatch
- ape_cli: sincronizar `version.dart`
- ape_cli: eliminar checks de doctor (gh copilot + vscode copilot)
- Tests para todos los cambios
- Version bumps y releases

### Fuera del alcance

- Concepto de módulo global (enhancement futuro, issue separado)
- Sistema de aliases para cli_router (enhancement futuro)
- Cualquier refactoring más allá de los 3 bugs
- Cambios en modular_cli_sdk (no necesario — el fix de cli_router es transparente)

## Riesgos

| Riesgo | Mitigación |
|--------|------------|
| cli_router publish rompe otros consumidores que dependan de `''` matching en j=0 | `''` matcheando args no vacíos es objetivamente un bug (catch-all no intencionado) |
| Coordinación de version bumps entre cli_router y ape_cli | Ejecución secuencial: cli_router primero, ape_cli después |

## Criterios de aceptación (issue #58)

- [ ] Módulos montados (`target get`, `target clean`, `state transition`) son alcanzables
- [ ] `ape --help` muestra lista de comandos disponibles
- [ ] `ape` (sin args) sigue mostrando el banner FSM
- [ ] `version.dart` y `pubspec.yaml` sincronizados
- [ ] Doctor solo valida: `ape`, `git`, `gh`, `gh auth`
- [ ] Tests verdes

## Referencias

| Archivo | Relevancia |
|---------|------------|
| `cli_router/lib/src/cli_router.dart` (líneas 110-185) | Dispatch loop donde vive el bug |
| `code/cli/lib/ape_cli.dart` | Registro de rutas y módulos |
| `code/cli/lib/src/version.dart` | Constante de versión desincronizada |
| `code/cli/lib/commands/doctor.dart` | Checks a eliminar |
| `docs/adr/0003-subcommands-over-flags-for-output.md` | `--help` como modificador |
