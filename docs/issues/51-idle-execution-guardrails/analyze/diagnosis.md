---
id: diagnosis
title: Diagnostico tecnico del incidente IDLE sin issue-first
date: 2026-04-18
status: completed
tags: [idle, fsm, issue-first, guardrails, triage]
author: github-copilot-ape
---

# Diagnostico tecnico del incidente IDLE sin issue-first

## Problema definido

En el estado IDLE, el agente recibio cambios propuestos para `install.sh` y `upgrade.dart` y los trato como artefactos listos para ejecucion en lugar de tratarlos como informacion de triage.

El resultado fue modificacion de archivos sin haber creado/seleccionado issue primero y sin haber ejecutado el flujo formal `ANALYZE -> PLAN -> EXECUTE` antes de actuar.

## Evidencia consolidada

1. Se detectaron cambios fuera de flujo en dos archivos (`install.sh`, `upgrade.dart`) preservados via `git stash`.
2. Los cambios eran mejoras UX puntuales (logs en upgrade y symlink en install), no hotfix critico.
3. El usuario confirmo el criterio metodologico:
   - IDLE puede leer, buscar, analizar y editar como exploracion.
   - IDLE no debe comprometer cambios (`git commit`) sin issue creado/seleccionado y checkout asociado.
4. La motivacion de `issue-first` es metodologica y de seguridad operativa: protege la rama principal al exigir trazabilidad por issue y flujo via pull request antes de integrar cambios.

## Decisiones tomadas en ANALYZE

1. **Reinterpretacion del limite IDLE**:
   - El corte practico no es "editar o no editar", sino "explorar vs comprometer".
2. **Correccion del diagnostico inicial**:
   - Bloquear herramientas de edicion en IDLE no resuelve la causa raiz.
   - La causa raiz es ausencia de validacion de precondiciones antes de acciones irreversibles.
3. **Generalizacion del patron**:
   - El problema no es exclusivo de IDLE.
   - Patron sistemico: `input -> suposicion de completitud -> accion irreversible sin validacion`.

## Causa raiz

La falla principal fue de **control de decision**, no de **capacidad tecnica**:

- Se confundio informacion de usuario con especificacion ejecutable.
- No se valido precondicion metodologica minima antes de actuar.
- No hubo punto de confirmacion explicita para clasificar la entrada como:
  - exploracion de triage, o
  - trabajo formal que requiere issue y ciclo.

Formalmente:

$$
\text{Riesgo} = \text{Entrada ambigua} + \text{Sin validacion de precondicion} + \text{Accion irreversible}
$$

## Restricciones y riesgos identificados

1. **Riesgo de solucion cosmetica**:
   - Quitar herramientas en IDLE es facil pero evadible por metodos alternativos.
2. **Riesgo de subcobertura**:
   - Corregir solo IDLE deja el mismo patron posible en otros estados.
3. **Riesgo metodologico**:
   - Si `issue-first` se vuelve opcional, se degrada la trazabilidad del ciclo y se debilita la proteccion de rama basada en PR.
4. **Riesgo de friccion operativa**:
   - Un bloqueo demasiado temprano puede frenar exploracion legitima de triage.

## Alcance (scope)

### En alcance

1. Definir frontera operativa entre exploracion y compromiso.
2. Establecer precondiciones minimas para acciones irreversibles.
3. Alinear conducta de IDLE con metodologia `issue-first`.

### Fuera de alcance

1. Implementacion de cambios de codigo del producto (eso corresponde a EXECUTE en issue separado).
2. Rediseno completo de todos los estados FSM en este ciclo de analisis.
3. Reescritura de historico de commits previos.

## Conclusiones de diagnostico

1. El incidente confirma una brecha metodologica: faltan chequeos de precondicion antes de pasar de exploracion a compromiso.
2. La solucion correcta debe modelar la transicion de modo (exploracion -> compromiso), no solo limitar herramientas.
3. `issue-first` debe mantenerse como regla de estructura del proceso para iniciar trabajo formal.
4. El material analizado es suficiente para pasar a PLAN y definir una estrategia implementable con criterios verificables.

## Referencias

1. `01_clarification.md`
2. `02_assumptions.md`
3. `03_evidence_raw.md`
4. `03_evidence_findings.md`
5. Issue #51 y #52
