---
id: alcance-v001
title: "Alcance definido para v0.0.1 del CLI ape"
date: 2026-04-15
status: completed
tags: [v0.0.1, alcance, scope, decisiones, ape-init]
author: socrates
---

# Alcance definido para v0.0.1 del CLI ape

## Contexto

Tras cuatro rondas de preguntas socráticas y un análisis completo del stack técnico, se cristaliza el alcance de v0.0.1. Este documento es la referencia canónica de lo que entra, lo que no entra, y bajo qué criterios se evalúa el resultado.

## Lo que SÍ está en v0.0.1

### Comando único: `ape init`

- Ejecutar `ape init` crea el directorio `.ape/` vacío en el directorio de trabajo actual (`cwd`)
- Si `.ape/` ya existe, imprime un mensaje informativo indicando que la carpeta existe (no falla, no destruye)
- Sin contenido dentro de `.ape/` — es un directorio vacío
- Sin flags (`--force`, `--dry-run`, `--target`, etc.)
- Sin prerequisitos (no verifica `git`, `gh`, ni ningún otro tooling)
- Sin prompts interactivos

### Proyecto Dart con modular_cli_sdk

- El proyecto se ubica en `./code/cli/` dentro del repositorio `finite_ape_machine`
- Usa `modular_cli_sdk` como framework de CLI (que a su vez usa `cli_router`)
- Sigue el ciclo de vida `Command<I, O>`: Input → validate → execute → Output
- Un solo comando registrado como root command (no dentro de un módulo)

### Tests

- Tests automatizados que verifican el comportamiento del comando `ape init`
- Caso 1: creación exitosa del directorio `.ape/` cuando no existe
- Caso 2: mensaje informativo cuando `.ape/` ya existe (segunda ejecución)

### Decisiones de diseño activas

| Decisión | Referencia |
|----------|------------|
| `cli_router` = router puro | D1 |
| `modular_cli_sdk` = framework de CLI | D2 |
| No reinventar `package:args` sin buena razón | D3 (P11) |
| `ape init` = crear `.ape/` vacío | D4 |
| Limitaciones de packages diferidas | D5 |
| `--help` per-command deseable | D6 |
| Mensaje informativo si `.ape/` ya existe | D7 |
| v0.0.1 incluye tests | D8 |

## Lo que NO está en v0.0.1

| Excluido | Razón |
|----------|-------|
| Verificación de prerequisitos (`git`, `gh`) | No relevante para el directorio vacío |
| Flags de cualquier tipo | El comando más trivial posible (P12) |
| TUI al ejecutar `ape` sin argumentos | Explícitamente excluido (P-adicional) |
| Contenido dentro de `.ape/` | Solo el directorio vacío (P1) |
| Validación inteligente de flags | `cli_router` no la tiene, no se necesita |
| Help de flags por comando | Sin flags que documentar |
| `package:args` como dependencia | No se necesita para v0.0.1; se evaluará cuando haya flags |
| Múltiples comandos o módulos | Un solo comando |

## Stack técnico

```
Dart (compilado a binario nativo)
  └── modular_cli_sdk v0.2.0 (framework de CLI)
        └── cli_router v0.0.2 (routing de comandos)
```

### Dependencias futuras (no en v0.0.1)

- `package:args` — candidato para declaración y validación de flags cuando el CLI crezca
- TUI framework — cuando se implemente el modo interactivo

## Estructura del proyecto

```
finite_ape_machine/
  code/
    cli/              ← proyecto Dart del CLI ape
      pubspec.yaml
      bin/
        ape.dart      ← entry point
      lib/
        ...           ← comando(s) y DTOs
```

## Criterios de éxito

### Funcional

1. `ape init` ejecutado en un directorio sin `.ape/` → crea `.ape/` → exit code 0
2. `ape init` ejecutado en un directorio con `.ape/` → imprime mensaje → exit code 0
3. El binario se compila sin errores con `dart compile exe`

### De testing

4. Tests automatizados cubren el caso de creación exitosa de `.ape/`
5. Tests automatizados cubren el caso de segunda ejecución (directorio ya existe)
6. Tests pasan sin errores (`dart test`)

### De validación del framework

7. `modular_cli_sdk` es suficiente para implementar el ciclo `Command<I, O>` completo
8. `cli_router` rutea correctamente el comando `init`
9. No se necesitan hacks ni workarounds en los packages para que el comando funcione
10. Se identifican limitaciones concretas de los packages (si existen) para documentarlas

### De estructura

11. El proyecto sigue las convenciones de `modular_cli_sdk` (Input/Output DTOs, Command class, exitCode semánticos)
12. ADR-003 se respeta: `ape init`, no `ape --init`

## Propósito real de v0.0.1

> El comando es el vehículo, no el objetivo.

v0.0.1 tiene un doble propósito (P5):

1. **Construir el CLI mínimo** — tener un artefacto funcional
2. **Validar los packages propios** — determinar si `modular_cli_sdk` y `cli_router` son suficientes para construir un CLI real

El segundo propósito es posiblemente el más importante. Las limitaciones detectadas en el análisis (ver `cli-router-capacidades.md`) no bloquean v0.0.1, pero serán el input para decidir si se extienden los packages o se incorpora `package:args` en versiones futuras.

## Fuentes

- Decisiones cristalizadas: `decisiones-arquitectura.md` (D1–D8)
- Preguntas socráticas: `preguntas-iniciales.md` (P1–P12, MR1–MR3)
- Análisis de modular_cli_sdk: `modular-cli-sdk.md`
- Capacidades de cli_router: `cli-router-capacidades.md`
- Estado actual: `estado-actual.md`
