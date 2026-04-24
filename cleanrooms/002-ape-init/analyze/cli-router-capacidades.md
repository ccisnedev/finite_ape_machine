---
id: cli-router-capacidades
title: "Capacidades reales de cli_router vs package:args"
date: 2026-04-15
status: active
tags: [cli-router, package-args, evidencia, capacidades, gaps]
author: socrates
---

# Capacidades reales de cli_router vs package:args

## Contexto

El usuario preguntó: "¿Entonces cli_router necesita tener package:args?" (P6). Para responder con evidencia, se revisó el código fuente completo de `cli_router` v0.0.2.

## Inventario de capacidades de cli_router

### Lo que cli_router SÍ tiene

| Capacidad | Ubicación | Evidencia |
|-----------|-----------|-----------|
| Parsing de flags GNU | `_parseFlags()` | `--key value`, `--key=value`, `-k value`, `-abc` (packed bools), `--no-key` (negación), `--` terminador |
| Helpers tipados | `CliRequest` | `flagString()`, `flagBool()`, `flagInt()`, `flagDouble()` con aliases |
| Detección de `--help` / `-h` | `CliRequest.isHelpRequested` | Getter que verifica `flagBool('help', aliases: ['h'])` o positional `help` |
| Routing por segmentos de espacio | `CliRouter.cmd()` | Patrones con literales, params dinámicos `<id>`, wildcard `*` |
| Subrouters (mount) | `CliRouter.mount()` | Montaje de otro `CliRouter` bajo un prefijo |
| Middleware shelf-like | `CliRouter.use()` | `CliMiddleware = CliHandler Function(CliHandler next)` |
| Listado de comandos | `listCommands()` | Retorna `List<ListedCommand>` con comando y descripción |
| Help básico (rutas) | `printHelp()` | Imprime comandos registrados con sus descripciones, alineados |
| Manejo de "command not found" | `_dispatch()` | Imprime error + help automáticamente cuando no hay match, retorna exit code 64 |

### Lo que cli_router NO tiene

| Capacidad faltante | Qué significa en la práctica | ¿package:args lo tiene? |
|--------------------|------------------------------|-------------------------|
| Declaración explícita de flags | No hay forma de decir "este comando acepta `--force` (bool) y `--target` (string, obligatorio)" | Sí — `addFlag()`, `addOption()` |
| Validación de flags desconocidas | `--typo` se acepta silenciosamente; no hay error por flags no declaradas | Sí — parser rechaza flags no registradas |
| Help text con descripción de flags | `printHelp()` solo muestra rutas y sus descriptions, no las flags que acepta cada comando | Sí — genera texto con cada flag, tipo, default, descripción |
| Valores por defecto declarados | No hay mecanismo para declarar defaults; se manejan ad-hoc en `flagBool(defaultValue:)` | Sí — `defaultsTo` en `addOption()` |
| Flags obligatorias | No hay concepto de "flag requerida" — todo es opcional | Sí — `mandatory: true` |
| Enumeraciones / valores permitidos | No hay restricción de valores; `--color red` acepta cualquier string | Sí — `allowed: ['red', 'green', 'blue']` |
| Abbreviations y negación declarativa | Los aliases se manejan en cada `flagBool()` call, no centralizados | Sí — `abbr`, `negatable` en la declaración |

## Análisis de la pregunta: ¿cli_router necesita package:args?

### La pregunta implica dos interpretaciones

1. **¿Necesita depender de package:args como dependencia?** — No necesariamente. `cli_router` podría implementar estas capacidades internamente.

2. **¿Necesita las *capacidades* que package:args ofrece?** — Depende de qué tan sofisticado sea el CLI que se quiere construir.

### Evidencia sobre cuándo importan los gaps

Para `ape init` en v0.0.1 (sin flags, sin prerequisitos):
- **Ningún gap es relevante.** No hay flags que declarar, validar, o documentar.

Para `ape init` con `--force`, `--dry-run`, `--target` (spec v0.2.0):
- **Los gaps empiezan a importar.** Un usuario que escriba `--forse` no recibiría error. `--help` no mostraría las flags disponibles.

Para un CLI maduro con múltiples módulos y comandos:
- **Los gaps son significativos.** Sin help de flags, sin validación de typos, sin flags obligatorias, la experiencia de usuario se degrada.

### Las opciones no son solo dos

| Opción | Descripción | Implicación |
|--------|-------------|-------------|
| A | Agregar `package:args` como dependencia de `cli_router` | `cli_router` internamente usa ArgParser para parsing — cambio de arquitectura |
| B | Reimplementar las capacidades faltantes en `cli_router` | Más trabajo, pero mantiene independencia — el parser propio evoluciona |
| C | Agregar un sistema de "flag schema" en `modular_cli_sdk` | La capa de SDK declara flags; `cli_router` sigue sin saber de schemas — separación de concerns |
| D | No hacer nada — manejar validación en `validate()` de cada Command | Funciona pero la carga recae en cada comando; no hay help automático |

### Observación clave

`cli_router` ya detecta `--help` (`CliRequest.isHelpRequested`), pero no hace nada con esa información — la detección existe pero no hay respuesta. Esto sugiere que la intención de help per-command estaba considerada pero no implementada.

## Lo que NO sabemos

1. ¿El usuario (autor de cli_router) considera los gaps como features pendientes o como diseño intencional?
2. ¿La filosofía "acepta todo, valida después" es una decisión deliberada o una simplificación temporal?
3. ¿El criterio de v0.0.1 ("que funcione") means estos gaps son aceptables por ahora, o deberían resolverse antes de escribir el primer comando?

## Fuentes

- `cli_router` v0.0.2: `lib/src/cli_router.dart`, `flags_parser.dart`, `cli_request.dart`, `cli_types.dart`, `path_pattern.dart`, `route_entry.dart`
- `modular_cli_sdk` v0.2.0: `lib/src/modular_cli.dart`, `lib/src/module_builder.dart`
- `pubspec.yaml` de ambos paquetes
