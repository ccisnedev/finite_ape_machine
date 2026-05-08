---
id: confirmed
title: "Confirmed findings"
date: 2026-05-07
status: active
tags: [findings, confirmed]
author: socrates
---

# Confirmed Findings

> Living document. Update as findings are confirmed, revised, or invalidated.
> Format: ## F<N>: <title> — CONFIRMED|REVISED|INVALIDATED

## F1: IDLE tiene una mision exclusiva de issue triage - CONFIRMED

- El usuario define que la mision de IDLE no es escribir codigo ni documentacion.
- IDLE debe usar la metodologia de investigacion de Dewey para entender la situacion indeterminada del usuario y convertirla en un entendimiento determinado que deba formalizarse como una issue.
- IDLE debe crear una issue nueva o confirmar que la issue ya existe y agregar comentarios cuando corresponda.

## F2: IDLE debe permanecer encapsulado respecto de otros estados - CONFIRMED

- El usuario explicita que IDLE no debe saber que existen ANALYZE, PLAN o EXECUTE.
- IDLE tampoco debe operar con la intencion de escribir codigo.

## F3: El agente de IDLE debe llamarse dewey - CONFIRMED

- El usuario pide que, para esta mision, el agente asociado a IDLE se llame dewey.

## F4: La salida operativa de IDLE debe vivir en una skill dedicada - CONFIRMED

- Debe existir una skill tipo issue-start para atender la issue.
- Esa skill, y no IDLE, es la que realiza el paso desde IDLE hacia ANALYZE.

## F5: El rediseño debe conservar coherencia con el modelo actual - CONFIRMED

- El objetivo explicito es lograr este cambio manteniendo coherencia con el modelo actual.

## F6: El runtime actual de IDLE ya coincide con una mision de triage Deweyano - CONFIRMED

- code/cli/assets/fsm/states/idle.yaml define IDLE como triage e issue formulation: entender el problema, buscar issues existentes y crear o seleccionar una issue.
- El mismo archivo prohibe root-cause analysis, solution proposals y branch preparation, por lo que IDLE no invade ANALYZE, PLAN o EXECUTE.
- code/cli/assets/apes/socrates-idle.yaml describe la tarea como Dewey's problematization: convertir una situacion indeterminada en un problema bien formulado.

## F7: El handoff desde IDLE ya esta externalizado en una skill dedicada - CONFIRMED

- code/cli/assets/skills/issue-start/SKILL.md hace la preparacion operativa: verificar o crear la issue, crear la branch, crear el cleanroom y ejecutar iq fsm transition --event start_analyze --issue <NNN>.
- docs/architecture.md describe el mismo reparto: IDLE espera la issue-start skill y luego el CLI realiza la transicion a ANALYZE.

## F8: Existe una incoherencia vigente entre la especificacion y el runtime sobre quien opera IDLE - CONFIRMED

- docs/spec/cooperative-multitasking-model.md y docs/spec/agent-lifecycle.md dicen que IDLE opera como APE directo con triage skill y sin sub-agent.
- Pero code/cli/lib/modules/fsm/effect_executor.dart, code/cli/lib/modules/fsm/commands/state.dart y code/cli/lib/modules/ape/commands/prompt.dart fijan socrates-idle como agente activo en IDLE.
- code/cli/test/fsm_state_test.dart y code/cli/test/effect_executor_test.dart verifican ese binding de socrates-idle en las pruebas.

## F9: La fundamentacion Deweyana ya es canonica en Inquiry - CONFIRMED

- docs/philosophy.md define cada ciclo como la transformacion Deweyana de una situacion indeterminada en una determinada.
- Ese marco vuelve coherente que la mision de IDLE se formule alrededor de la problematizacion previa a la issue.

## F10: La tension de la issue #177 esta en el operador de IDLE, no en la mision de IDLE - CONFIRMED

- La perspectiva conceptual del usuario y la perspectiva declarada en docs/spec coinciden en que IDLE se limita a formular o confirmar la issue y delega el handoff a una skill dedicada.
- code/cli/assets/fsm/states/idle.yaml tambien mantiene esa mision acotada: triage, issue creation/selection y comentarios, sin root-cause analysis ni solution proposals.
- La divergencia vigente aparece en runtime: code/cli/lib/modules/fsm/effect_executor.dart y code/cli/lib/modules/ape/commands/prompt.dart siguen activando socrates-idle como sub-agent de IDLE.
- Por eso, el trabajo de #177 es resolver una diferencia de operador y binding, no reescribir desde cero la finalidad de IDLE.

## F11: El operador de IDLE esta codificado como un contrato transversal del CLI - CONFIRMED

- code/cli/lib/modules/fsm/effect_executor.dart autoactiva socrates-idle cuando el FSM entra en IDLE.
- code/cli/lib/modules/ape/commands/prompt.dart solo reconoce socrates-idle como APE activo en IDLE.
- code/cli/lib/modules/fsm/commands/state.dart reporta socrates-idle como RUNNING en IDLE.
- code/cli/lib/modules/global/commands/doctor.dart exige que exista el asset apes/socrates-idle.yaml y code/cli/test/effect_executor_test.dart, code/cli/test/fsm_state_test.dart y code/cli/test/doctor_test.dart fijan ese contrato en pruebas.

## F12: La incoherencia sobre el operador de IDLE ya es visible en superficies publicas del sistema - CONFIRMED

- docs/spec/cooperative-multitasking-model.md y docs/spec/agent-lifecycle.md dicen que en IDLE no hay sub-agent y que la operacion es APE-direct con triage skill.
- Pero el CLI expone socrates-idle como operador activo tanto al inspeccionar el estado como al resolver prompts validos para IDLE.
- La contradiccion no queda encerrada en implementacion interna: ya forma parte de lo que el sistema declara y de lo que el sistema ejecuta.

## F13: El contrato de transicion preserva que IDLE no salte directamente a fases posteriores - CONFIRMED

- code/cli/assets/fsm/transition_contract.yaml solo permite desde IDLE el evento start_analyze hacia ANALYZE o block para permanecer en IDLE.
- El mismo contrato marca como ILLEGAL que IDLE complete analysis, approve plan, finish execute, cree PR o salte directo a EXECUTE.
- Esto confirma que el handoff fuera de IDLE ya existe como protocolo del FSM y que el problema de #177 no es agregar una nueva salida, sino alinear quien opera IDLE con ese contrato.
