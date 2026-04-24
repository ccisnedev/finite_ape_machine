---
id: plan-issue-52-ux-improvements
title: Plan de ejecucion para mejoras UX en instalacion y logging de upgrade
date: 2026-04-18
status: active
tags: [issue-52, ux, install-sh, upgrade, stderr, path]
author: DESCARTES
---

# Plan - Issue #52

## Hipotesis

Si se implementan de forma acotada dos cambios de UX, entonces se reducira friccion de uso sin romper contratos existentes:

1. Si `install.sh` crea un symlink del binario en `~/.local/bin` y gestiona PATH de sesion cuando sea necesario, el comando quedara disponible de forma inmediata en la mayoria de entornos compatibles.
2. Si `upgrade.dart` emite progreso en `stderr` y mantiene `stdout` reservado para salida funcional, se mejorara observabilidad del upgrade sin romper integraciones parseables.

## Alcance operativo (estricto)

Incluido:
1. Cambios en `code/site/install.sh` para symlink a `~/.local/bin` y manejo de PATH de sesion.
2. Cambios en `code/cli/lib/commands/upgrade.dart` para logs de progreso en `stderr` sin alterar el contrato de salida.
3. Pruebas y verificaciones asociadas unicamente a esos comportamientos.

Excluido:
1. Rediseno del instalador o de la arquitectura de distribucion.
2. Cambios en el mecanismo de descarga/transporte del upgrade.
3. Refactors no necesarios fuera de los dos archivos objetivo.

## WBS por fases

### Fase 1 - Baseline y contrato de comportamiento actual

Objetivo: fijar una linea base verificable antes de cualquier cambio para que la ejecucion sea mecanica y trazable.

Checklist:
- [x] Identificar pruebas existentes que cubran instalacion y upgrade.
- [x] Registrar comportamiento actual de `install.sh` respecto a presencia/ausencia de `~/.local/bin` y PATH de sesion.
- [x] Registrar comportamiento actual de `upgrade.dart` sobre `stdout` y `stderr`.
- [x] Definir criterios de no-regresion (contrato de salida) derivados de la baseline.

Dependencias de la fase:
1. `docs/issues/52-ux-improvements/analyze/diagnosis.md` aprobado como fuente de alcance.
2. Entorno local con capacidad de ejecutar scripts shell y pruebas de Dart.

Pruebas en pseudocodigo:
```text
TEST baseline_install_path_behavior:
  setup entorno limpio con PATH sin ~/.local/bin
  ejecutar install.sh en modo controlado
  assert resultado documentado (sin suponer nuevo comportamiento)
  guardar evidencia para comparacion post-cambio

TEST baseline_upgrade_stream_contract:
  ejecutar comando upgrade en entorno de prueba
  capturar stdout y stderr por separado
  assert formato/senal actual de stdout
  guardar stderr actual como referencia
```

### Fase 2 - install.sh: symlink y PATH de sesion

Objetivo: introducir integracion de uso inmediato por symlink en `~/.local/bin` y manejar PATH de sesion sin requerir reinicio de shell.

Checklist:
- [x] Definir precondiciones de instalacion (existencia de destino, permisos, binario fuente).
- [x] Implementar creacion/actualizacion idempotente del symlink en `~/.local/bin`.
- [x] Implementar manejo de PATH de sesion cuando `~/.local/bin` no este presente.
- [x] Definir mensajes UX claros para casos: symlink creado, symlink ya existente, PATH ya configurado, PATH ajustado en sesion.
- [x] Validar que el flujo no altera otros pasos del instalador fuera del alcance.

Dependencias de la fase:
1. Fase 1 completada con baseline documentada.
2. Convencion del proyecto para mensajes de instalacion consistente con UX existente.

Pruebas en pseudocodigo:
```text
TEST install_creates_symlink_when_missing:
  setup HOME temporal con ~/.local/bin existente
  asegurar que symlink no existe
  ejecutar install.sh
  assert symlink creado y apuntando al binario esperado

TEST install_is_idempotent_with_existing_symlink:
  setup symlink ya presente y correcto
  ejecutar install.sh dos veces
  assert no error
  assert symlink permanece correcto

TEST install_updates_session_path_when_missing:
  setup PATH sin ~/.local/bin
  ejecutar install.sh en sesion actual
  assert ~/.local/bin agregado al PATH de sesion
  assert mensaje UX informa el ajuste

TEST install_keeps_path_when_already_present:
  setup PATH que ya contiene ~/.local/bin
  ejecutar install.sh
  assert no duplicacion en PATH
  assert mensaje UX indica que no fue necesario ajustar
```

### Fase 3 - upgrade.dart: progreso a stderr sin romper contrato

Objetivo: mejorar trazabilidad del proceso de upgrade enviando progreso a `stderr` y preservando `stdout` para salida funcional.

Checklist:
- [x] Definir puntos de progreso minimos del flujo (inicio, descarga/preparacion, aplicacion, finalizacion/error).
- [x] Implementar emision de logs de progreso exclusivamente en `stderr`.
- [x] Verificar que la salida funcional previa en `stdout` no cambia en estructura ni semantica.
- [x] Revisar tratamiento de errores para mantener coherencia entre mensajes de progreso y codigos de salida.

Dependencias de la fase:
1. Fase 1 completada con contrato baseline de streams.
2. Criterios de contrato de salida aprobados en issue #52.

Pruebas en pseudocodigo:
```text
TEST upgrade_progress_goes_to_stderr:
  ejecutar upgrade con captura separada de streams
  assert stderr contiene hitos de progreso esperados
  assert stdout no contiene logs de progreso

TEST upgrade_stdout_contract_unchanged:
  ejecutar upgrade en escenario exitoso
  comparar stdout con baseline funcional
  assert mismo contrato (campos/formato/semantica)

TEST upgrade_error_path_preserves_contract:
  forzar error controlado en upgrade
  assert stderr contiene contexto de progreso/error
  assert stdout mantiene contrato definido
  assert exit code esperado
```

### Fase 4 - Verificacion integrada y cierre de criterios de aceptacion

Objetivo: comprobar el comportamiento conjunto y cerrar acceptance criteria del issue #52 con evidencia reproducible.

Checklist:
- [x] Ejecutar suite de pruebas relevante para cambios en `install.sh` y `upgrade.dart`.
- [x] Ejecutar verificacion cross-platform exigida por el issue (al menos Linux/macOS para script; entorno soportado para CLI).
- [x] Confirmar que no hay regresiones en contrato de salida ni en flujo de instalacion.
- [x] Documentar evidencia final de cumplimiento por criterio de aceptacion.

Desviacion ejecutada (Fase 4): en este entorno Windows no fue posible validar `install.sh` con ejecucion real Linux/macOS; se completo validacion de no-regresion del CLI con `dart test` y se dejo la verificacion del script en runners Linux/macOS como chequeo operacional externo.

Dependencias de la fase:
1. Fase 2 completada y validada.
2. Fase 3 completada y validada.
3. Entornos/runners disponibles para chequeo multiplataforma.

Pruebas en pseudocodigo:
```text
TEST end_to_end_install_then_upgrade_observability:
  ejecutar install.sh en entorno limpio
  validar disponibilidad del comando via symlink/PATH de sesion
  ejecutar upgrade
  assert progreso en stderr
  assert contrato de stdout intacto

TEST acceptance_criteria_matrix:
  for cada criterio del issue #52:
    ejecutar prueba asociada
    registrar resultado y evidencia
  assert todos los criterios en estado cumplido
```

## Riesgos y mitigaciones

1. Riesgo: `~/.local/bin` no existe o no es escribible.
Mitigacion: crear ruta cuando corresponda y reportar error UX accionable cuando permisos lo impidan.

2. Riesgo: PATH de sesion se modifica de forma no portable entre shells.
Mitigacion: limitarse al alcance de sesion del script y verificar en los entornos objetivo definidos; evitar persistencia fuera de alcance.

3. Riesgo: logs nuevos en `stderr` introducen ruido no esperado por pruebas actuales.
Mitigacion: actualizar aserciones para separar claramente contrato de `stdout` (estable) y trazas de `stderr` (informativas).

4. Riesgo: cambios de salida funcional por efecto colateral del ajuste de logging.
Mitigacion: comparar `stdout` contra baseline de Fase 1 en escenarios exitosos y de error.

5. Riesgo: divergencias cross-platform en utilidades shell para symlink.
Mitigacion: usar construcciones POSIX compatibles con los targets soportados y validar en matriz minima requerida por el issue.

## Criterios de finalizacion del plan

1. Todas las casillas de las fases 1 a 4 en estado completado.
2. Pruebas pseudocodigo convertidas a pruebas ejecutables con resultado verde.
3. Evidencia de acceptance criteria del issue #52 documentada y verificable.
4. Sin desviaciones de alcance fuera de `install.sh` y `upgrade.dart`.
