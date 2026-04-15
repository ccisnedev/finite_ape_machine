---
id: estado-actual
title: Estado actual del proyecto y contexto
date: 2026-04-15
status: active
tags: [ape-init, contexto, decisiones]
author: socrates
---

# Estado actual del proyecto y contexto

## Decisiones confirmadas

- **Lenguaje:** Dart
- **Ubicación en repo:** `./code/cli/`
- **Binario nativo:** sin dependencias de runtime
- **Primer comando:** `ape init`
- **ADR-002:** APE se construye con la metodología APE (bootstrap manual)
- **ADR-003:** Subcomandos sobre flags para output independiente (`ape version`, no `ape --version`)

## Estado del código

- `code/` está vacío — nada existe aún
- `modular_cli_sdk` está en el workspace como SDK para CLIs modulares en Dart
- La spec referencia `package:args` como parser, pero `modular_cli_sdk` usa `cli_router`
- `cli_router` NO depende de `package:args` — implementa su propio parser de flags GNU
- Ver análisis completo en `modular-cli-sdk.md`

## Lo que dice la spec sobre `ape init`

La spec (v0.2.0) define `ape init` como un comando que:

1. Verifica prerequisitos (`git`, `gh` en PATH, `gh auth status`)
2. Aborta si `.ape/` ya existe (salvo `--force`)
3. Solicita interactivamente: target, stack, risk level
4. Crea `.ape/` con estructura completa (~30 archivos)
5. Genera archivos target-specific (`.github/agents/`, `.claude/`, etc.)
6. Soporta flags: `--target`, `--stack`, `--risk`, `--force`, `--dry-run`

## Lo que el usuario propone

Un `ape init` mínimo que:

- Ejecutar `ape init` → crea `.ape/` vacío en el directorio actual
- Sin prerequisitos (git, gh)
- Sin flags (--force, --dry-run)
- Sin contenido dentro de `.ape/`
- **El valor real es el ejercicio de crear el proyecto Dart con `modular_cli_sdk`**, no lo que hace el comando

## Tensiones identificadas

1. ~~**Alcance:** spec v0.2.0 vs "solo crear .ape/" — ¿dónde está la línea?~~ → Resuelto: `.ape/` vacío
2. ~~**Contenido:** ¿carpeta vacía, estructura de directorios, o archivos mínimos?~~ → Resuelto: vacío
3. ~~**Prerequisitos:** la spec dice verificar git/gh — ¿aplica en v0.0.1?~~ → Resuelto: no
4. **Framework:** `modular_cli_sdk` (disponible) vs `package:args` (en la spec) — analizado en `modular-cli-sdk.md`
5. **Criterio de éxito:** el usuario lo define como "que se cree `.ape/`", pero ¿es realmente ese el criterio? Ver preguntas ronda 2
