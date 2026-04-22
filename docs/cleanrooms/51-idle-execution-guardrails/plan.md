---
id: plan
title: Plan de implementacion para robustecer IDLE y transiciones FSM programaticas
date: 2026-04-18
status: completed
tags: [plan, idle, fsm, issue-first, transition-command, skills]
author: github-copilot-ape
---

# Plan de implementacion para robustecer IDLE y transiciones FSM programaticas

## Hipotesis

Si la transicion de estados se ejecuta mediante un comando unico del CLI de APE, con operaciones definidas por estado/evento y con prompt fragments definidos por skill, entonces se evita razonamiento ad hoc en transiciones y se garantiza disciplina de proceso con issue-first y proteccion de rama.

## Principios de diseno

- IDLE no se bloquea para tareas de exploracion.
- Acciones irreversibles requieren precondiciones verificables.
- Cada transicion FSM tiene operaciones programaticas declaradas.
- Cada transicion FSM obtiene prompt fragments desde una fuente definida.
- El scheduler invoca skills/comandos; no decide transiciones por heuristica libre.

## WBS

### Fase 1. Contrato de transicion FSM declarativo

Dependencias: ninguna

#### Entregables

- [x] Definir matriz Estado x Evento con transiciones permitidas e ilegales.
- [x] Definir operaciones por transicion (precheck, efectos, artefactos, commit policy).
- [x] Definir contrato de precondiciones para acciones irreversibles.
- [x] Definir contrato de prompt fragments por transicion.

#### Criterios de aceptacion

- [x] Existe especificacion unica versionada para transiciones.
- [x] Cada transicion tiene lista de operaciones obligatorias.
- [x] Las transiciones ilegales estan explicitamente codificadas.

#### Pruebas (pseudocodigo)

```text
TEST transition_matrix_is_total_for_known_events
  FOR each state in FSM:
    FOR each known event:
      ASSERT transition rule exists (allowed or forbidden)

TEST illegal_transition_is_rejected
  GIVEN state=IDLE, event=go_execute
  WHEN transition requested
  THEN result=ERROR_ILLEGAL_TRANSITION
```

#### Riesgos

- Riesgo: sobre-especificacion inicial.
- Mitigacion: separar contrato minimo viable de extensiones.

### Fase 2. Comando APE de transicion programatica

Dependencias: Fase 1

#### Entregables

- [x] Implementar comando de transicion (por ejemplo ape state transition).
- [x] El comando detecta estado actual, valida evento y ejecuta operaciones declaradas.
- [x] El comando retorna payload estructurado para el scheduler (nuevo estado, operaciones ejecutadas, prompt id).
- [x] El comando aplica prechecks de issue-first y branch policy cuando corresponda.

#### Criterios de aceptacion

- [x] La transicion no depende de razonamiento libre del agente.
- [x] El comando falla con errores accionables si faltan precondiciones.
- [x] Se registran efectos de transicion en salida estructurada.

#### Pruebas (pseudocodigo)

```text
TEST transition_command_requires_issue_for_commit_effects
  GIVEN state=IDLE, event=approve_plan
  AND no issue/branch context
  WHEN command runs
  THEN result=ERROR_PRECONDITION_ISSUE_FIRST

TEST transition_command_returns_prompt_descriptor
  GIVEN state=ANALYZE, event=user_authorizes_plan
  WHEN command runs
  THEN output includes next_state=PLAN and prompt_fragment_id
```

#### Riesgos

- Riesgo: acoplamiento con git y gh en entornos limitados.
- Mitigacion: adapters y fallbacks con mensajes claros.

### Fase 3. Registro de prompt fragments y skills por transicion

Dependencias: Fase 1, Fase 2

#### Entregables

- [x] Crear catalogo de prompt fragments versionado por estado/evento.
- [x] Mapear cada transicion a skill requerida y subagente objetivo.
- [x] Definir merge deterministico de fragmentos (base + estado + fase + constraints).
- [x] Definir validaciones para evitar prompt incompleto.

#### Criterios de aceptacion

- [x] Cada transicion permitida tiene prompt fragment definido.
- [x] El scheduler consume prompt id entregado por el comando.
- [x] Falta de fragmento produce error explicito, no fallback silencioso.

#### Pruebas (pseudocodigo)

```text
TEST prompt_registry_has_entry_for_all_allowed_transitions
  FOR each allowed transition:
    ASSERT prompt_fragment exists

TEST missing_prompt_fragment_fails_closed
  GIVEN allowed transition without prompt
  WHEN scheduler requests fragment
  THEN result=ERROR_PROMPT_FRAGMENT_MISSING
```

#### Riesgos

- Riesgo: duplicacion y deriva de prompts.
- Mitigacion: versionado, ids unicos y validacion en CI.

### Fase 4. Robustez de IDLE y guardrails de compromiso

Dependencias: Fase 1, Fase 2

#### Entregables

- [x] En IDLE, mantener capacidades de exploracion (leer, buscar, analizar, editar).
- [x] Antes de acciones de compromiso, ejecutar checkpoint formal de precondiciones.
- [x] Requerir issue seleccionada/creada y rama asociada para commit/push/PR.
- [x] Mensajes accionables para reparar precondiciones faltantes.

#### Criterios de aceptacion

- [x] IDLE sigue siendo util para triage.
- [x] No hay commits en rama principal desde flujo no autorizado.
- [x] El sistema fuerza trazabilidad via issue y PR.

#### Pruebas (pseudocodigo)

```text
TEST idle_allows_exploration_without_commit
  GIVEN state=IDLE
  WHEN user requests file analysis/edit exploration
  THEN action allowed
  AND no commit side effects

TEST idle_blocks_commit_without_issue_branch
  GIVEN state=IDLE, current_branch=main, no issue selected
  WHEN user requests commit
  THEN result=ERROR_PRECONDITION_ISSUE_OR_BRANCH
```

#### Riesgos

- Riesgo: friccion por prompts de confirmacion excesivos.
- Mitigacion: pedir confirmacion solo en acciones irreversibles.

### Fase 5. Integracion y validacion end-to-end

Dependencias: Fase 2, Fase 3, Fase 4

#### Entregables

- [x] Probar replay del incidente (install.sh y upgrade.dart) con nuevo flujo.
- [x] Probar camino positivo completo IDLE -> ANALYZE -> PLAN -> EXECUTE.
- [x] Probar transiciones ilegales y validar errores esperados.
- [x] Emitir reporte de validacion final.

#### Criterios de aceptacion

- [x] El incidente original no se reproduce como violacion.
- [x] Todas las transiciones autorizadas ejecutan operaciones previstas.
- [x] Las transiciones ilegales fallan de manera cerrada y explicita.

#### Pruebas (pseudocodigo)

```text
TEST incident_replay_is_prevented
  GIVEN user provides code snippet in IDLE
  WHEN no issue/branch context exists
  THEN system classifies as triage input
  AND prevents unauthorized commit flow

TEST full_cycle_uses_transition_command_each_step
  GIVEN valid issue and branch
  WHEN user authorizes transitions sequentially
  THEN each step executed by transition command
  AND prompt fragments resolved from registry
```

#### Riesgos

- Riesgo: cobertura incompleta de eventos reales.
- Mitigacion: tabla de eventos minima + ampliacion incremental.

## Criterio de finalizacion del plan

- [x] Todas las fases cerradas con evidencia de pruebas.
- [x] Ninguna transicion depende de inferencia ad hoc para operaciones criticas.
- [x] El scheduler opera sobre comando de transicion + catalogo de prompts/skills.
- [x] Se preserva objetivo real de IDLE: triage robusto sin romper seguridad de integracion.
