---
id: socratic-round-4-meta
title: "Ronda socrática 4: Meta-reflexión — ¿estamos preguntando lo correcto?"
date: 2026-04-18
status: draft
tags: [routing, meta-reflection, help-paradox, scope-creep, socratic-method]
author: socrates
---

# Ronda socrática 4: Meta-reflexión

Llevamos cuatro rondas. El análisis técnico del bug está verificado desde la ronda 1. Las rondas 2 y 3 exploraron soluciones (aliases, root module, global module). Cada ronda amplió el scope en lugar de convergerlo.

Es momento de examinar las preguntas mismas.

---

## I. La paradoja de --help

El acceptance criteria #2 del issue dice:

> `ape --help` muestra lista de comandos disponibles

La propuesta actual dice:

> `ape --help` → se reescribe a `ape global global --help`

Tracemos qué pasa con esa reescritura:

1. `ape --help` llega al dispatch
2. La reescritura transforma `['--help']` en `['global', 'global', '--help']`
3. El dispatch matchea el módulo `global`, el comando `global`, con flag `--help`
4. `--help` decora **ese comando** — muestra la ayuda del comando global (TUI/banner)

El resultado: el usuario ve la ayuda del TUI. **No** ve la lista de todos los comandos disponibles.

Para que `ape --help` muestre la lista de todos los comandos, necesitaría:

- **O** que `--help` sea interceptado **antes** de la reescritura (pero entonces la reescritura no aplica, y necesitamos otro mecanismo)
- **O** que el comando `global` implemente su help como "listar todos los comandos" (pero entonces no es un comando normal — es un meta-comando que necesita conocer el registro completo del CLI)
- **O** que `--help` a nivel raíz **no** se reescriba (caso especial que contradice la regla general)

Cualquiera de las tres opciones introduce complejidad que la propuesta de reescritura no contempla. **La reescritura y el acceptance criteria se contradicen mutuamente.**

Esta pregunta se planteó en la ronda 3, sección I. No fue respondida. Sigue sin responderse. Y no es una pregunta menor — es un criterio de aceptación del issue.

---

## II. ¿Estamos preguntando lo correcto?

Las preguntas que hemos hecho en 4 rondas:

| Ronda | Pregunta central |
|-------|-----------------|
| 1 | ¿Cómo funciona el dispatch y por qué '' es catch-all? |
| 2 | ¿Los aliases resuelven el catch-all? |
| 3 | ¿Un root/global module es la abstracción correcta? |
| 4 (propuesta) | ¿Cómo implementamos el módulo global con reescritura? |

Nota el patrón: cada ronda asume que la solución es **más arquitectura** y pregunta cómo implementarla. Ninguna ronda después de la primera preguntó: **¿cuál es la solución más simple que satisface los 6 criterios de aceptación?**

Los criterios son:

1. Módulos montados (target get, target clean, state transition) son alcanzables
2. `ape --help` muestra lista de comandos disponibles
3. `ape` (sin args) sigue mostrando el banner FSM
4. version.dart y pubspec.yaml sincronizados
5. Doctor solo valida: ape, git, gh, gh auth
6. Tests verdes

Los criterios 4 y 5 son fixes triviales. Están listos desde la ronda 1. El criterio 6 es consecuencia.

Los criterios 1, 2 y 3 son el problema de routing. Pero fíjate: ninguno dice "cli_router debe soportar módulos globales", "el dispatch debe usar reescritura", ni "necesitamos aliases". Los criterios hablan de **comportamiento observable**, no de mecanismo.

La pregunta que no hemos hecho:

> **¿Existe una solución que satisfaga los 3 criterios de routing sin modificar cli_router?**

La ronda 2 (pregunta 4) propuso un contrafactual exactamente sobre esto. No fue evaluado. El análisis pivotó hacia más arquitectura.

---

## III. El patrón de las 4 rondas

Observo algo que vale la pena nombrar:

```
Ronda 1: Identificar el bug          → verificado, claro
Ronda 2: Solución A (aliases)        → demostrada insuficiente
Ronda 3: Solución B (root module)    → pregunta de scope abierta
Ronda 4: Solución C (global module)  → paradoja de --help no resuelta
```

Cada solución propuesta es más elaborada que la anterior. Cada una requiere más cambios a más paquetes. Ninguna ha sido evaluada contra **todos** los criterios de aceptación simultáneamente.

Esto es un antipatrón conocido: **escalada de complejidad sin validación incremental**. La solución crece, pero no se verifica contra los requisitos. Cuando finalmente se verifica (como hice con --help), resulta que no encaja.

No estoy diciendo que la arquitectura del módulo global sea mala idea. Estoy diciendo que no hemos demostrado que sea **necesaria** para resolver el issue #58.

---

## IV. Las preguntas que deberíamos estar haciendo

En lugar de "¿cómo implementamos el módulo global?", propongo:

### 1. ¿Qué es lo mínimo que necesita cambiar para que los 6 criterios pasen?

Concretamente: ¿qué pasa si `ape_cli.dart` simplemente no registra `''` como ruta y maneja `args.isEmpty` antes de llamar a `cli.run()`? ¿Cuántos criterios se satisfacen?

### 2. ¿Quién es responsable de `--help` global?

Esto es anterior a cualquier solución de routing. ¿Es el framework (cli_router/modular_cli_sdk) quien genera el listado de comandos para `--help`, o es ape_cli? Si es el framework, ¿ya lo soporta? Si no, ese es un feature request separado.

### 3. ¿Estamos usando el issue #58 como vehículo para trabajo de diseño que debería ser su propio issue?

El módulo global, la reescritura, los aliases — cada uno de estos es una decisión arquitectural de cli_router que afecta a todos sus consumidores. Mezclarlos con un bugfix de 3 líneas en ape_cli es poner en riesgo ambos: el bugfix se retrasa y el diseño no recibe la atención que merece.

---

## V. El dilema concreto

Estás en una bifurcación:

**Camino A — Fix mínimo (ape_cli solamente):**
- No registrar `''` como ruta
- Manejar args vacíos antes del dispatch
- version.dart: cambiar '0.0.11' → '0.0.12'
- doctor.dart: eliminar checks de copilot
- Criterios 1, 3, 4, 5, 6: satisfechos directamente
- Criterio 2 (--help): depende de qué hace el framework cuando no hay match y hay --help

**Camino B — Rediseño (cli_router + modular_cli_sdk + ape_cli):**
- Implementar concepto de módulo global en cli_router
- Implementar reescritura de entrada
- Resolver la paradoja de --help (mecanismo aún no definido)
- Modificar modular_cli_sdk para exponer la nueva API
- Adaptar ape_cli
- Más código, más riesgo, más paquetes afectados, release cycle más largo

El camino B puede ser el diseño correcto a largo plazo. Pero la pregunta para **este issue** es: ¿necesitas el camino B para cerrar los 6 criterios de aceptación, o estás resolviendo un problema futuro con el presupuesto de un bugfix?

---

## Punto de convergencia

Cuatro rondas es suficiente exploración para un bugfix de 3 problemas concretos. El análisis necesita converger. Sugiero que respondas, en orden:

1. **La paradoja de --help**: ¿Cómo muestra `ape --help` la lista de todos los comandos si se reescribe a `ape global global --help`? Necesito un mecanismo concreto, no una intención.

2. **El contrafactual**: ¿Has evaluado qué pasa si simplemente no registras `''` y manejas el caso vacío fuera del dispatch? ¿Lo descartaste por alguna razón técnica concreta?

3. **La decisión de scope**: ¿Es este issue un bugfix o un rediseño? Ambos son válidos, pero necesitan planes distintos.

Sin respuesta a estas tres preguntas, cualquier plan que escribamos estará construido sobre supuestos no validados.
