---
id: socratic-inquiry-02
title: "Segunda indagación: pivote de alcance y supuestos no examinados"
date: 2025-07-18
status: active
tags: [socratic, analysis, metrics, scope-pivot, assumptions]
author: socrates
---

# Segunda Indagación Socrática — Issue #72

## Contexto

Esta indagación procesa las respuestas del usuario a las 5 lagunas identificadas en `socratic-inquiry.md`. Las respuestas revelan un **pivote de alcance significativo** que cambia la naturaleza de lo que este issue entrega.

## Decisiones del usuario

### D1: Issues sin directorio (#55, #61, #67)

> "Siempre existirán. Debemos poder operar con los existentes."

**Implicación:** Solo se generan métricas para issues que tienen directorio. No se crean directorios retroactivamente. Esto reduce los 7 issues de los acceptance criteria a 4 con artefactos existentes (#51, #58, #66, #68).

### D2: Umbral mínimo de calidad

> "No lo sabemos. El objetivo mismo de la métrica es ir aprendiendo y mejorando."

**Implicación:** No definir un umbral mínimo a priori. La métrica se define iterativamente. El acto de recolectar enseñará qué campos son útiles.

### D3: Convención de nombres (NNN)

> "Es placeholder, pero a partir de ahora sería bueno tener una norma rígida."

**Implicación:** `NNN` en la documentación es placeholder. Se debe definir una norma para nombres de directorio going forward. Los existentes se aceptan tal como están.

### D4: tests.before/after — origen de datos

> "No lo sé. Tal vez debemos ir documentando a medida que se hace. Cuando .ape/evolution = true podemos hacer que todo eso se registre a medida que va ocurriendo."

**Implicación:** No intentar extraer datos históricos de tests. En su lugar, integrar la recolección en el proceso del ciclo APE. Condicionar la recolección a `evolution: enabled: true` en `.ape/config.yaml`.

### D5: delta_failures retroactivo

> "No nos preocupemos hacia atrás, sino hacia adelante. Los nuevos issues."

**Implicación:** No fabricar datos históricos. Toda la energía va hacia la recolección prospectiva.

## Pivote detectado

El issue #72 propone 3 fases:

1. **Fase 1:** Métricas retroactivas (issues históricos)
2. **Fase 2:** Proceso de recolección prospectiva
3. **Fase 3:** Automatización CLI

Las respuestas D1, D4 y D5 **depriorizan radicalmente la Fase 1**. El usuario dice "hacia adelante, no hacia atrás" en tres contextos diferentes. Esto transforma el entregable: de "generar 7 archivos metrics.yaml" a "construir el mecanismo de recolección para ciclos futuros".

Sin embargo, los **acceptance criteria del issue siguen pidiendo 7 metrics.yaml específicos**. Hay una tensión no resuelta entre lo que el usuario quiere ahora y lo que el issue dice que se necesita.

## Supuestos no examinados

### S1: "Recolectar y aprender" presupone un momento de recolección

El usuario dice "el objetivo es ir aprendiendo y mejorando" — pero **¿cuándo exactamente se recolecta?** Hoy, el skill `issue-end` tiene 9 pasos:

1. Verificar fase EXECUTE
2. Verificar plan completo
3. Determinar version bump
4. Actualizar archivos de versión
5. Actualizar CHANGELOG
6. Commit
7. Push
8. Crear PR
9. Transición a EVOLUTION

**Ninguno de estos pasos menciona métricas.** Si no se añade un paso explícito "generar metrics.yaml", la recolección prospectiva no ocurre. "Ir documentando a medida que se hace" requiere que alguien defina *cuándo* en el flujo se hace.

### S2: La recolección depende de evolution, pero evolution está deshabilitada

El usuario vincula la recolección a `evolution: enabled: true`. Pero `ape init` crea `.ape/config.yaml` con `evolution: enabled: false` por defecto. Esto significa:

- Proyectos nuevos no recolectan métricas por defecto
- El propio `finite_ape_machine` no tiene `config.yaml` visible (solo `state.yaml` en `.ape/`)
- Si métricas depende de evolution, y evolution está off, **las métricas no existen**

¿Son las métricas realmente una función de evolution? ¿O son una función del ciclo base (IDLE → EXECUTE → END) que debería ocurrir siempre?

### S3: Los acceptance criteria no reflejan el pivote

El issue pide:
> `metrics.yaml exists for issues #51, #55, #58, #61, #66, #67, #68`

Pero las decisiones del usuario dicen:
- #55, #61, #67 no tienen directorio → no se generan (D1)
- No fabricar datos históricos → no generar delta_failures ni tests (D4, D5)
- Foco prospectivo → la energía va al mecanismo, no a los archivos (D5)

**Si cerramos el issue con solo métricas parciales para 4 issues y un proceso documentado, ¿cumple los acceptance criteria?** ¿O hay que actualizar los criteria para reflejar el nuevo alcance?

## Preguntas socráticas

### P1: ¿Cuándo exactamente ocurre la recolección?

Dices "ir documentando a medida que se hace." Pero el protocolo `issue-end` actual tiene 9 pasos y ninguno toca métricas. Si nadie añade un paso 9.5 ("generar metrics.yaml"), el mecanismo prospectivo no existe — es solo una intención.

**¿En qué momento del ciclo APE se crea el archivo?** ¿Antes del commit de release? ¿Después del PR? ¿Durante EVOLUTION? Cada respuesta tiene consecuencias diferentes:
- Antes del commit → las métricas viajan en el mismo PR
- Después del PR → requiere un commit adicional en main
- Durante EVOLUTION → solo existe si evolution está habilitada

### P2: ¿Métricas son función de evolution o del ciclo base?

Vinculas la recolección a `evolution: enabled: true`. Pero la motivación del issue dice que las métricas son para el paper de investigación y para "reproducibility". La reproducibilidad es una propiedad del proceso base, no de la capa evolutiva.

**Si un equipo usa APE sin evolution (el default), ¿no merecen métricas?** ¿O estás diciendo que evolution es prerequisito para cualquier tipo de autoobservación? Si es así, ¿qué significa eso para la adopción del framework?

### P3: ¿Debemos actualizar los acceptance criteria antes de planificar?

El issue pide 7 metrics.yaml. Tus decisiones reducen eso a ~4 archivos parciales + un proceso documentado. Hay dos caminos:

1. **Planificar contra los criteria originales** → forzar la generación de 7 archivos (contradiciendo D1, D4, D5)
2. **Actualizar los criteria** → reflejar el pivote antes de pasar a PLAN

Si planificamos sin resolver esta tensión, ¿cómo sabremos cuándo el issue está "done"?
