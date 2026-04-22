---
id: socratic-round-2
title: "Ronda socrática 2: ¿Los aliases resuelven el dispatch, o lo renombran?"
date: 2026-04-18
status: draft
tags: [routing, aliases, dispatch, socratic-method]
author: socrates
---

# Ronda socrática 2: ¿Los aliases resuelven el dispatch, o solo lo renombran?

## Recapitulación del modelo propuesto

Tu propuesta:
- Registrar un "root module" con `''` como alias y `tui` como nombre primario.
- Dentro de él, un comando `tui` con `''` como alias.
- `ape` (sin args) → match root module `''` → match command `''` → TUI.
- `ape target get` → no match root module → pasa a mount `target` → funciona.

Es un modelo elegante conceptualmente. Pero necesitamos ser rigurosos sobre **qué evidencia tenemos de que funciona a nivel de dispatch**.

---

## Pregunta 1: ¿El alias cambia el loop, o solo cambia el nombre del patrón?

Tracemos el dispatch actual con tu propuesta implementada. El loop central es ([cli_router.dart L113-L118](../../../../../../../Code/macss-dev/cli_router/lib/src/cli_router.dart#L113-L118)):

```dart
for (int j = maxRouteTokens; j >= 0; j--) {
  final candidate = args.take(j).toList();
  final match = _matchRoute(candidate);
  if (match != null) { ... }
}
```

Caso `ape target get`:
- `maxRouteTokens = 2`
- j=2 → `['target', 'get']` → ¿match?
- j=1 → `['target']` → ¿match?
- j=0 → `[]` → ¿match?

**Pregunta concreta:** En tu modelo de aliases, ¿qué hay registrado en `_routes` y `_mounts` cuando el dispatch evalúa estos candidatos?

Si `''` es un **alias** de `tui`, hay dos interpretaciones posibles:

### Interpretación A: `''` se registra como ruta independiente que delega a `tui`

Entonces `_routes` contiene una entrada con `_PathPattern.parse('')` → `segments = []`. El dispatch llega a j=0, `candidate = []`, `_matchRoute([])` matchea contra `segments = []` → **true**. El catch-all persiste idénticamente.

**Los aliases no resolvieron nada. El patrón vacío sigue matcheando todo a j=0.**

### Interpretación B: Solo `tui` se registra como ruta; `''` es un lookup que redirige a `tui`

Entonces `_routes` contiene una entrada con `_PathPattern.parse('tui')` → `segments = ['tui']`. El dispatch llega a j=0, `candidate = []`, `_matchRoute([])` busca match contra `['tui']` (1 segmento ≠ 0 tokens) → **false**. No hay catch-all. Los mounts se evalúan. `target get` funciona.

**Pero entonces — ¿cómo llega `ape` (sin argumentos) a TUI?**

- `args = []`, `maxRouteTokens = 0`
- j=0 → `candidate = []` → `_matchRoute([])` → no matchea `'tui'` → **false**
- No hay mounts que matcheen `[]`
- Resultado: **"Command not found"** → exit 64

El alias necesitaría que el router, al recibir `[]`, lo transforme en `['tui']` antes de hacer dispatch. Es decir, **el alias no es un atributo del patrón, sino una regla de reescritura de la entrada**. Eso es un concepto fundamentalmente distinto de "aliases para comandos".

---

## Pregunta 2: ¿Qué problema estamos resolviendo realmente?

Reformulemos. El problema no es de **nomenclatura** (cómo se llama la ruta), sino de **prioridad de evaluación**:

> Cuando el dispatch llega a j=0, ¿debería intentar rutas antes de mounts?

El código actual dice sí: el paso 2 (rutas, j=maxRouteTokens..0) se agota completamente antes del paso 3 (mounts). Esto significa que cualquier ruta que matchee `[]` actúa como catch-all, porque j=0 siempre se alcanza.

**La pregunta que los aliases no contestan:** ¿Cuál debería ser la semántica de j=0?

Hay al menos tres lecturas posibles:

| Lectura | Semántica de j=0 | Implicación |
|---------|-------------------|-------------|
| **"Default route"** | j=0 es una ruta legítima para "sin argumentos" | Requiere que no capture tráfico destinado a mounts |
| **"Fallback"** | j=0 solo se intenta si no hay mounts | Cambia la prioridad del dispatch |
| **"Prohibido"** | j=0 no debería existir; rutas vacías son inválidas | Rompe el caso de uso de TUI |

Tu propuesta de aliases parece asumir la lectura "default route" pero quiere resolver el problema que solo se resuelve con la lectura "fallback".

---

## Pregunta 3: ¿Hay evidencia de que el alias funcione sin cambiar la lógica del loop?

Busco en tu modelo un mecanismo concreto que evite que j=0 matchee cuando hay mounts disponibles. Encuentro tres posibilidades:

1. **Reescritura de entrada** (`[] → ['tui']`): Funciona, pero no es un sistema de "aliases" — es un sistema de redirects/rewrites al estilo de servidores HTTP. El costo es alto: necesitas una tabla de reescritura evaluada antes del loop, con reglas de precedencia propias.

2. **El alias expande los candidatos** (j=0 prueba `[]` y también `['tui']`): Esto podría funcionar para el TUI, pero no cambia que `[]` siga matcheando. Además, ¿a j=2 se expande `['target', 'get']` a todas las combinaciones de alias? La complejidad combinatoria explota.

3. **El alias solo aplica a la ruta vacía como caso especial**: Entonces no es un sistema de aliases — es un hack para el caso vacío disfrazado de feature general.

**¿Cuál de estos mecanismos es el que tenías en mente?** Sin especificarlo, no podemos evaluar si la propuesta resuelve el problema.

---

## Pregunta 4: ¿Existe un fix más simple que no requiera cambiar cli_router?

Contrafactual: ¿qué pasa si **no registramos `''` como ruta** y manejamos "sin argumentos" de otra forma?

```
# Pseudocódigo — sin ruta vacía
if (args.isEmpty || args.every((a) => a.startsWith('-'))) {
  return tui(args);
}
return cli.run(args);
```

Esto resolvería los tres síntomas:
- `ape` → TUI (por el check previo)
- `ape --help` → pasa a `cli.run(['--help'])` → no hay ruta vacía → no hay match → help se muestra correctamente *(si el framework maneja --help)*
- `ape target get` → pasa a `cli.run(...)` → mount `target` → funciona

**No requiere cambios a cli_router. No introduce aliases. No cambia la semántica del dispatch.**

La pregunta incómoda: **¿por qué necesitamos un sistema de aliases si el problema se puede resolver sin registrar la ruta vacía?**

---

## Pregunta 5: ¿Estamos resolviendo el bug de hoy o diseñando la arquitectura de mañana?

Esta es la pregunta más importante.

- Si el objetivo es **resolver el bug #58**, el fix más simple y verificable es no registrar `''` como ruta, y manejar el caso vacío antes del dispatch.
- Si el objetivo es **que cli_router soporte aliases como feature del framework**, eso es una decisión arquitectural que merece su propio issue, con sus propios criterios de aceptación y tests.

Mezclar ambos objetivos en un solo cambio introduce riesgo: el alias resuelve (quizás) el bug, pero también modifica cli_router para todos sus consumidores, con implicaciones no exploradas (colisiones de aliases, prioridad de resolución, interacción con wildcards y parámetros).

---

## Resumen de lagunas identificadas

| # | Laguna | Estado |
|---|--------|--------|
| 1 | Mecanismo concreto por el cual el alias evita el catch-all a j=0 | Sin especificar |
| 2 | Qué lectura de "j=0" asume el modelo de aliases | Implícita, no explícita |
| 3 | Cómo interactúan aliases con wildcards, params, y mounts existentes | No explorado |
| 4 | Si el bug se puede resolver sin cambiar cli_router | Contrafactual viable, no evaluado |
| 5 | Si aliases es un requisito del bug o una preferencia arquitectural | No distinguido |

---

## Preguntas para la siguiente ronda

1. **Mecanismo**: De las tres interpretaciones (reescritura, expansión, caso especial), ¿cuál describe mejor tu intención con aliases? ¿O hay una cuarta que no estoy viendo?

2. **Contrafactual**: Si pudiéramos resolver el catch-all sin tocar cli_router (manejando args vacíos antes del dispatch), ¿seguirías queriendo aliases? ¿Por qué?

3. **Scope**: ¿Estamos en el issue #58 (fix del bug) o estamos abriendo un issue nuevo (aliases como feature de cli_router)?
