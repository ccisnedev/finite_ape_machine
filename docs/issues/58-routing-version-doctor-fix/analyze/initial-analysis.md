---
id: initial-analysis
title: Análisis inicial — routing catch-all, version desync, doctor scope
date: 2026-04-18
status: draft
tags: [routing, catch-all, version, doctor, cli-router, dispatch]
author: socrates
---

# Análisis inicial — Issue #58

## Verificación de hechos reportados

### Bug 1: Empty route como catch-all

**Verificado en código.** La cadena de causalidad es:

1. `ape_cli.dart:34` registra `cli.command<TuiInput, TuiOutput>('', ...)` — ruta vacía.
2. `_PathPattern.parse('')` produce `segments = []` (0 segmentos).
3. `_PathPattern.matches([], outParams)` retorna `true` — 0 segmentos == 0 tokens.
4. En `_dispatch`, el loop `for (int j = maxRouteTokens; j >= 0; j--)` siempre llega a `j=0`.
5. Con `j=0`, `candidate = args.take(0) = []`, que matchea `''`.
6. La ruta vacía captura TODO antes de que se evalúen los mounts (paso 3 del dispatch).

**Caso `ape target get`:**
- `maxRouteTokens = 2` (no hay flags)
- j=2 → `['target', 'get']` → no match (no hay ruta registrada con ese nombre)
- j=1 → `['target']` → no match
- j=0 → `[]` → match con `''` → ejecuta TUI → módulos inalcanzables ✓

**Caso `ape --help`:**
- `flagStart = 0` (primer arg empieza con `-`)
- `maxRouteTokens = 0`
- j=0 → `[]` → match con `''` → TUI inmediato ✓

### Bug 2: version.dart desync

**Verificado.** `pubspec.yaml` dice `0.0.12`, `version.dart` dice `'0.0.11'`.

### Bug 3: Doctor checks

**Verificado.** `doctor.dart` incluye:
- Check 5: `gh copilot --version` (L161-169)
- Check 6: `_checkVsCodeCopilot()` que ejecuta `code --list-extensions` (L183-210)

## Preguntas abiertas

### P1: ¿Dónde vive el fix del routing — cli_router o ape_cli?

El bug es una **interacción emergente** entre dos decisiones independientes:
- cli_router: el dispatch prueba j=0 (candidato vacío) antes de evaluar mounts
- ape_cli: registra `''` como ruta válida

Opciones identificadas:
- **A) Fix en cli_router**: Cambiar prioridad del dispatch — evaluar mounts antes de probar j=0
- **B) Fix en ape_cli**: No registrar `''` como ruta; manejar "sin argumentos" de otra forma
- **C) Fix mixto**: Ambos cambios

Cada opción tiene trade-offs no explorados aún.

### P2: ¿Qué semántica debería tener la ruta vacía '' en cli_router?

Actualmente `''` es un patrón válido que matchea "cero tokens". Pero el dispatch no distingue entre:
- "El usuario no pasó argumentos" (caso legítimo para banner/TUI)
- "El dispatch agotó candidatos y cayó a j=0" (caso espurio)

¿Es la ruta vacía un concepto que cli_router debería soportar, o es un accidente de implementación?

### P3: ¿Qué principio define el scope de doctor?

El usuario dice "solo ape, git, gh, gh auth" — pero ¿por qué exactamente esos? ¿El criterio es "herramientas que APE invoca directamente en su ejecución normal"? Si APE evoluciona para usar más herramientas, ¿se agregan a doctor?

## Estado

Análisis técnico verificado contra código fuente. Quedan decisiones de diseño abiertas que afectan la solución.
