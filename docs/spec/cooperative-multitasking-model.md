---
id: cooperative-multitasking-model
title: "Cooperative multitasking model — two-level FSM architecture"
date: 2026-04-17
status: active
tags: [architecture, fsm, rtos, scheduler, multitasking]
author: socrates
---

# Cooperative Multitasking Model

## Origin

Direct analogy with cooperative multitasking on microcontrollers. The APE cycle is a scheduler; agents are tasks; each agent is an FSM that executes one state per tick and yields.

## The Two-Level FSM

### Level 1: APE Cycle (the scheduler)

```
IDLE → ANALYZE → PLAN → EXECUTE → END → EVOLUTION
```

The cycle FSM has no intelligence. It tracks which phase is active and dispatches the registered sub-agent for that phase. It does not produce artifacts. APE is the Finite APE Machine — not an ape.

### Level 2: Agent FSMs (the tasks)

Each sub-agent operates within one APE state. Sub-agents are launched with clean context and a specific prompt. They receive the context they need and return results. APE the scheduler does not accumulate sub-agent context — this keeps the scheduler lean and the agents focused.

```c
void ape_tick() {
  switch(ape_state) {
    case IDLE:       dewey_run();          break;  // Sub-agent: DEWEY (bounded triage)
    case ANALYZE:    socrates_run();       break;  // Sub-agent: SOCRATES
    case PLAN:       descartes_run();      break;  // Sub-agent: DESCARTES
    case EXECUTE:    basho_run();          break;  // Sub-agent: BASHŌ
    case END:        ape_end();            break;  // APE direct + human gate
    case EVOLUTION:  darwin_run();         break;  // Sub-agent: DARWIN
  }
}
```

### Key Properties

1. **One primary operator per phase.** IDLE→DEWEY. ANALYZE→SOCRATES. PLAN→DESCARTES. EXECUTE→BASHŌ. END→APE + human gate. EVOLUTION→DARWIN.
2. **Sub-agents are launched with clean context.** Each invocation receives: the user's input, the relevant artifacts (diagnosis.md, plan.md, etc.), and a phase-specific prompt. The sub-agent does not know about other phases or agents.
3. **Illusion of continuity.** Sub-agents don't persist between ticks. APE reconstructs context from artifacts (`state.yaml`, `diagnosis.md`, `plan.md`) and passes it to the sub-agent on each invocation. The agent experiences continuity; the scheduler provides it.
4. **Agents are unaware of each other.** No agent knows what other agents exist. Communication is through artifacts (files) routed by the scheduler (see [signal-based-coordination](signal-based-coordination.md)).
5. **Event-driven scheduling.** Agents in IDLE or WAITING state are never invoked — only READY agents get CPU time.

## Current Phase Operators

| Agent | State | Thinking Tool | Key Artifact |
|-------|-------|---------------|-------------|
| DEWEY | IDLE | Deweyan problematization | Selected issue + explicit `issue-start` handoff |
| SOCRATES | ANALYZE | Mayéutica (Socratic method) | `diagnosis.md` — rigorous paper with references |
| DESCARTES | PLAN | Method (divide, order, verify, enumerate) | `plan.md` — WBS with checkboxes + test pseudocode |
| BASHŌ | EXECUTE | Techne + 用の美 (functional beauty) | Code + commits per phase |
| APE + human gate | END | Explicit closure discipline | PR creation and merge gate |
| DARWIN | EVOLUTION | Natural selection (observe, compare, select) | Issues in APE repo (via `gh`) |

## DEWEY in IDLE (triage)

This section explains the intended DEWEY/IDLE architecture; it does not replace the canonical runtime contract. The normative IDLE surfaces are `code/cli/assets/fsm/transition_contract.yaml` for the outer boundary and `code/cli/assets/fsm/states/idle.yaml` for the internal IDLE behavior.

In IDLE, DEWEY owns bounded issue triage. DEWEY determines whether an indeterminate situation merits a formal cycle, whether an issue already exists, and whether that issue is ready for handoff. By default, issue readiness stays within IDLE until the explicit handoff surface is prepared; DEWEY does not itself define the outer exit from IDLE. DEWEY does not perform root-cause analysis, planning, branch preparation, or coding.

Triage determines:
- Whether the problem merits a formal APE cycle
- Whether a GitHub issue already exists (via `gh issue list --search`)
- Whether the issue is ready for explicit handoff into `issue-start`

Infrastructure preparation remains external to DEWEY: `issue-start` performs `gh issue create` (if needed), creates the branch and cleanroom folder, and fires the `start_analyze` transition.

The gate to exit IDLE: issue selected or created, then `issue-start` completes branch creation, workspace setup, and transition readiness.

## Relationship to Existing Specs

The [orchestrator-spec](orchestrator-spec.md) describes an earlier expanded model with the microcontroller analogy table. This document **updates** that model:

- **EVOLUTION replaces RETROSPECTIVE/REVIEW/DARWIN** as a single state. Product retrospective lives inside EXECUTE's final phase; process introspection is EVOLUTION.
- **Sub-agents replace the multi-agent-per-phase model.** The original vision had multiple agents per phase (e.g., ADA + DIJKSTRA in EXECUTE). The current model simplifies to one sub-agent per phase, with domain skills providing specialized knowledge.
- **Agents never poll** — only the scheduler decides who runs (signal-based model).

## Alignment Notes

The [finite-ape-machine spec](finite-ape-machine.md) describes the current three-loop framing (inner, middle, outer). The outer loop now aligns:

```
IDLE → ANALYZE → PLAN → EXECUTE → END → EVOLUTION → IDLE
```

The [lore](../lore.md) describes the broader original roster. The current operational model uses DEWEY, SOCRATES, DESCARTES, BASHŌ, DARWIN, and an explicit END gate governed by APE plus the human.
