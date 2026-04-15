---
id: modular-cli-sdk
title: "Análisis de modular_cli_sdk y su relación con package:args"
date: 2026-04-15
status: active
tags: [modular-cli-sdk, cli-router, package-args, framework, dependencias]
author: socrates
---

# Análisis de modular_cli_sdk y su relación con package:args

## Hallazgo principal

`cli_router` implementa su propio parser de flags — **no depende de `package:args`**. La cadena de dependencias es:

```
modular_cli_sdk v0.2.0
  └── cli_router v0.0.2  (única dependencia de runtime)
        └── (sin dependencias de runtime — dependencies: comentado en pubspec)
```

`package:args` aparece en el árbol de dependencias SOLO como transitiva de `test` (vía `coverage` y `test_core`). No hay relación funcional con `cli_router`.

## Cómo funciona cli_router

`cli_router` es un router de CLI inspirado en `shelf_router` (HTTP). Usa espacios como separadores de segmento en lugar de `/`.

### Parsing de flags (implementación propia)

`cli_router` implementa `_parseFlags()` que soporta:

- `--key value` y `--key=value` (long flags)
- `-k value` y `-k=value` (short flags)
- `-abc` → `{a: true, b: true, c: true}` (packed booleans)
- `--no-key` → `{key: false}` (negación GNU)
- `--` como terminador de flags

### CliRequest expone helpers tipados

```dart
req.flagString('name')         // String?
req.flagBool('json')           // bool (con aliases)
req.flagInt('limit')           // int?
req.param('id')                // String? (de rutas dinámicas)
req.positionals                // List<String>
```

### Diferencia filosófica con package:args

| Aspecto | package:args | cli_router |
|---------|-------------|------------|
| Declaración de flags | Explícita (`addFlag`, `addOption`) | Implícita (se lee lo que llega) |
| Validación de flags | Parser rechaza flags desconocidos | No hay validación — toda flag se acepta |
| Routing | `CommandRunner` + `Command` class | Router de espacios con `mount()` |
| Help automático | Sí (generado desde declaración) | Básico (solo rutas + descriptions) |
| Dependencias | Ninguna | Ninguna |

## Cómo funciona modular_cli_sdk

Se ubica sobre `cli_router` y agrega:

1. **Ciclo de vida de Command:** `factory(CliRequest) → validate() → execute() → format output`
2. **Input/Output DTOs:** Contratos tipados para entrada y salida
3. **Output formatting:** `--json` → JSON, default → texto plano
4. **Errores estructurados:** `CommandException` con código, mensaje, exit code
5. **Módulos:** Agrupación de commands bajo un prefijo (`cli.module('ticket', ...)`)

### Setup mínimo (de los ejemplos del SDK)

```dart
final cli = ModularCli();
cli.command<FooInput, FooOutput>(
  'init',
  (req) => InitCommand(InitInput.fromCliRequest(req)),
  description: 'Initialize workspace',
);
await cli.run(args);
```

## ¿Son incompatibles package:args y modular_cli_sdk?

**No técnicamente, pero sí funcionalmente.**

- Se puede agregar `package:args` como dependencia y usarlo dentro de un `Command.execute()` para algún propósito secundario.
- Sin embargo, `cli_router` ya cubre el parsing de argumentos y el routing. Usar ambos significaría tener dos sistemas de parsing en el mismo CLI.

Escenarios posibles:

| Escenario | ¿Funciona? | Problema |
|-----------|-----------|----------|
| Solo `modular_cli_sdk` | Sí | Ninguno — es autosuficiente |
| Solo `package:args` | Sí | No aprovecha el framework modular |
| Ambos para el mismo comando | Técnicamente sí | Dos parsers interpretando los mismos args — confusión |
| `modular_cli_sdk` para routing + `package:args` para validación de flags | Posible | Redundante — `validate()` ya cubre validación |

## Implicaciones para ape init

Usar `modular_cli_sdk` implica:

1. **Descarte de `package:args`** como parser principal — `cli_router` lo reemplaza completamente
2. **Adopción del patrón `Command<I, O>`** — cada comando es una clase con Input, Output, validate, execute
3. **Routing por espacios** — `ape init` se registra como `command('init', ...)` (root) o `module('ape', (m) => m.command('init', ...))` según la estructura deseada
4. **Flags implícitas** — no se declaran flags por adelantado; se leen en `fromCliRequest`

## Lo que aún no está claro

1. ¿`cli_router` genera help text con descripción de flags? (Parece que no — solo describe rutas)
2. ¿Cómo se manejan flags obligatorias si el parser acepta todo? (En `validate()`)
3. ¿La spec dice `package:args` con CommandRunner — ¿es una decisión de diseño de la spec o una suposición por defecto?
4. ¿El usuario eligió `modular_cli_sdk` deliberadamente como reemplazo de `package:args` o no habían evaluado la relación?

## Fuentes consultadas

- `modular_cli_sdk` v0.2.0: código fuente completo (`lib/`, `example/`, `pubspec.yaml`, `doc/architecture.md`)
- `cli_router` v0.0.2: código fuente desde pub cache (`lib/src/`, `pubspec.yaml`)
- Spec APE CLI v0.2.0: Sección 2 (Technology Stack)
- `dart pub deps` sobre `modular_cli_sdk`
