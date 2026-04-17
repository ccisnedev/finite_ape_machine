---
id: decisiones-arquitectura
title: "Decisiones de arquitectura cristalizadas del análisis"
date: 2026-04-15
status: completed
tags: [arquitectura, decisiones, cli-router, modular-cli-sdk, v0.0.1, help, testing]
author: socrates
---

# Decisiones de arquitectura cristalizadas del análisis

## Contexto

Tras tres rondas de preguntas socráticas, una meta-reflexión final, el análisis de código fuente de `cli_router` y `modular_cli_sdk`, y la revisión de `ape-cli-spec.md`, las siguientes decisiones quedaron explícitas.

## D1: cli_router = router puro

**Origen:** Respuesta a P9
**Decisión:** `cli_router` es exclusivamente un router de comandos por segmentos de espacio. No es responsable de declarar flags, validar argumentos, ni generar help de flags.
**Analogía:** Es el equivalente de `shelf_router` para HTTP — rutea, no procesa.
**Implicación:** Toda lógica que vaya más allá de routing (validación, help inteligente, flag schemas) pertenece a otra capa.

## D2: modular_cli_sdk = framework de CLI

**Origen:** Respuesta a P9, P4
**Decisión:** `modular_cli_sdk` es el framework completo. Orquesta el ciclo de vida `Command<I, O>`, los DTOs de entrada/salida, el formateo de output, y el manejo de errores.
**Implicación:** Las extensiones futuras (flag schemas, help extendido, TUI) se agregan en `modular_cli_sdk`, no en `cli_router`.

## D3: package:args como complemento compatible, no como reemplazo

**Origen:** Respuesta a P9, clarificada en P11
**Decisión:** `cli_router` debería poder usarse importando `package:args` junto a él. La inteligencia de flags puede venir de `package:args` o de una capa en `modular_cli_sdk`.
**Principio rector (P11):** No reinventar la rueda sin justificación. Si `package:args` ya tiene lo necesario, no se reescribe código que lo reemplace a menos que haya una buena razón concreta.
**Estado:** No implementado en v0.0.1. Es una directriz de diseño para evolución futura.
**Tensión detectada:** Actualmente `cli_router` tiene su propio parser de flags. Usar `package:args` junto a él requiere definir cómo conviven dos parsers (ver sección "Preguntas abiertas"). Sin embargo, el principio de P11 sugiere que la convivencia se justifica solo si `package:args` aporta algo que no se puede lograr sin él.

## D4: v0.0.1 = `ape init` crea `.ape/`, nada más

**Origen:** Respuestas a P1, P2, P5, P7
**Decisión:** El alcance de v0.0.1 es: ejecutar `ape init` → se crea el directorio `.ape/` vacío en el `cwd`. Sin prerequisitos, sin validaciones, sin `--force`, sin verificación de existencia previa.
**Propósito real:** Validar que `modular_cli_sdk` y `cli_router` son suficientes para construir un CLI. El comando es el vehículo, no el objetivo.

## D5: Limitaciones de packages diferidas

**Origen:** Respuesta a P6
**Decisión:** Las limitaciones detectadas en `cli_router` (falta de declaración de flags, validación de flags desconocidas, help de flags) se documentan en la spec como referencia, pero no se resuelven en v0.0.1.
**Justificación:** Para `ape init` sin flags, ningún gap es relevante. Las limitaciones se convierten en relevantes cuando se agreguen comandos con flags (`--force`, `--target`, etc.).
**Referencia:** Ver `cli-router-capacidades.md` para el inventario completo de gaps.

## D6: `--help` per-command — deseable, no contradice la spec

**Origen:** Respuesta a P8 + revisión de `ape-cli-spec.md`
**Hallazgo:** La spec v0.2.0 **no menciona `--help` en ninguna parte**. No lo requiere ni lo prohíbe. Es un vacío en la spec, no una contradicción.
**Decisión del usuario:** Mantener `--help` per-command como parte del diseño del CLI.
**Estado de implementación:**
- `cli_router` ya detecta `--help` vía `CliRequest.isHelpRequested` — la detección existe.
- `cli_router.printHelp()` muestra rutas y descripciones — help básico de routing existe.
- Lo que falta: help de flags por comando (qué flags acepta, tipos, defaults, descripción).
**Implicación para v0.0.1:** `ape init --help` podría mostrar la descripción del comando (ya soportado por `printHelp()`), pero no las flags del comando (porque no hay flags en v0.0.1 y no existe el mecanismo de declaración).

## D7: `ape init` imprime mensaje si `.ape/` ya existe

**Origen:** Respuesta a P10
**Decisión:** Si `.ape/` ya existe al ejecutar `ape init`, el comando imprime un mensaje informativo indicando que la carpeta ya existe. No falla, no aborta con error, no destruye.
**Relación con D4:** Modifica ligeramente D4 que decía "sin verificación de existencia previa". Ahora sí se verifica, pero la respuesta es informativa, no un error.
**Comportamiento:** Idempotencia informativa — el comando no produce efectos secundarios si ya se ejecutó antes, solo notifica.

## D8: v0.0.1 incluye tests

**Origen:** Respuesta a MR3 (meta-reflexión)
**Decisión:** v0.0.1 incluye tests automatizados que verifican el comportamiento del comando `ape init`.
**Casos de test:**
- Creación exitosa del directorio `.ape/` cuando no existe
- Mensaje informativo cuando `.ape/` ya existe (segunda ejecución)
**Justificación:** Si el propósito real de v0.0.1 es validar los frameworks (`modular_cli_sdk`, `cli_router`), los tests son parte natural de esa validación — no solo "funciona" sino que "se puede verificar que funciona".

## Preguntas abiertas

Estas preguntas surgieron del análisis pero no se resolvieron. No bloquean v0.0.1, pero serán relevantes en versiones futuras.

1. **Convivencia de parsers:** Si `package:args` se usa junto a `cli_router`, ¿quién parsea primero? ¿Se reemplaza `_parseFlags()` de `cli_router` o conviven?
2. **Flag schemas en modular_cli_sdk:** ¿La declaración de flags pertenece al `Input`, al `Command`, o a la registración en `ModuleBuilder`?
3. **Help de flags:** ¿`--help` per-command debería generar help automático desde un schema, o el desarrollador lo escribe manualmente?
4. **Filosofía de `cli_router`:** ¿"Acepta todo, valida después" es diseño intencional o simplificación temporal del autor?

## Fuentes

- Preguntas socráticas Rondas 1–4 y meta-reflexión: `preguntas-iniciales.md`
- Análisis de modular_cli_sdk: `modular-cli-sdk.md`
- Capacidades de cli_router: `cli-router-capacidades.md`
- Spec APE CLI v0.2.0: `docs/references/ape-cli-spec.md`
