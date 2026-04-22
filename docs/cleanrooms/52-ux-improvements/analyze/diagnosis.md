---
id: diagnosis-issue-52
title: Diagnostico final del analisis para mejoras UX en install.sh y upgrade
date: 2026-04-18
status: completed
tags: [issue-52, ux, install-sh, upgrade, diagnosis]
author: SOCRATES
---

# Diagnostico final - Issue #52

## 1. Problema definido

El issue #52 busca resolver dos fricciones de experiencia de uso en el flujo de instalacion y actualizacion del CLI:

1. `code/site/install.sh` hoy deja la integracion de PATH parcialmente delegada al usuario; se requiere integracion mas directa mediante symlink en `~/.local/bin`.
2. `code/cli/lib/commands/upgrade.dart` ejecuta el upgrade sin trazas de progreso suficientes para el usuario final; se requiere logging de progreso en `stderr`.

No quedan bloqueos de clarificacion: el usuario confirmo explicitamente que todo esta claro y solicito pasar a diagnosis final.

## 2. Decisiones tomadas (con justificacion)

1. Integrar PATH en `install.sh` via symlink a `~/.local/bin`.
Justificacion: reduce pasos manuales, alinea con practicas comunes de CLI en Linux/macOS y mejora la primera ejecucion.

2. Emitir logs de progreso del upgrade a `stderr` en `upgrade.dart`.
Justificacion: preserva `stdout` para salida funcional/parseable y mejora observabilidad del proceso sin alterar el contrato de salida principal.

3. Mantener el alcance estrictamente acotado a UX.
Justificacion: el issue define mejoras de experiencia, no cambios de arquitectura del instalador ni del mecanismo de transporte de upgrade.

## 3. Restricciones y riesgos

1. Dependencia de entorno: `~/.local/bin` puede no estar en PATH en algunos sistemas.
Riesgo: instalacion funcional pero comando no visible inmediatamente.

2. Compatibilidad de pruebas: nuevos mensajes en `stderr` pueden requerir ajustes en tests existentes.
Riesgo: falsos negativos en test suites si asumen silencio en `stderr`.

3. Consistencia cross-platform: los criterios de aceptacion exigen verificaciones multiplataforma.
Riesgo: diferencias de shell/runners en manejo de PATH y streams.

## 4. Alcance (in/out)

In:
1. Symlink a `~/.local/bin` en flujo de `install.sh` con comportamiento UX esperado.
2. Logging de progreso del upgrade a `stderr` en `upgrade.dart`.
3. Validacion con pruebas y chequeos cross-platform definidos por issue #52.

Out:
1. Rediseno completo de arquitectura del instalador.
2. Cambios del transporte/protocolo de descarga o estrategia de upgrade.
3. Refactors no necesarios fuera de los dos archivos objetivo.

## 5. Evidencia disponible

1. Confirmacion explicita de usuario: "todos claro, pasa a diagnosis".
2. Alcance fijado en dos objetivos concretos (install.sh PATH + upgrade.dart stderr).
3. Implementacion candidata ya recuperada en working tree en:
   - `code/site/install.sh`
   - `code/cli/lib/commands/upgrade.dart`
4. Criterios de aceptacion del issue #52 incluyen pruebas y chequeos cross-platform.
5. Documento de contexto de transicion y evidencia inicial: `idle-to-analyze-context.md`.

## 6. Criterios de salida a PLAN

1. Problema, alcance y decisiones estan definidos sin ambiguedad operativa.
2. Riesgos principales fueron identificados y son tratables en plan de ejecucion.
3. Existe evidencia tecnica suficiente para descomponer trabajo en fases ejecutables.
4. No quedan bloqueos de clarificacion pendientes.

Conclusion: la fase ANALYZE queda cerrada para issue #52 y esta lista para PLAN.

## 7. Referencias

1. `docs/issues/52-ux-improvements/analyze/index.md`
2. `docs/issues/52-ux-improvements/analyze/idle-to-analyze-context.md`
3. `code/site/install.sh`
4. `code/cli/lib/commands/upgrade.dart`