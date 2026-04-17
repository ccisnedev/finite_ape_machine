---
id: cooperative-multitasking-model
title: "Cooperative multitasking model — two-level FSM architecture"
date: 2026-04-16
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
IDLE → ANALYZE → PLAN → EXECUTE → RETROSPECTIVE → IDLE
```

The cycle FSM has no intelligence. It tracks which phase is active and which agents are registered for that phase. It does not produce artifacts.

### Level 2: Agent FSMs (the tasks)

Each agent has its own FSM with internal states. Agents run sequentially within a phase, one step per tick, round-robin.

```c
void ape_tick() {
  switch(ape_state) {
    case IDLE:           break;
    case ANALYZE:        socrates_run(); break;
    case PLAN:           /* TBD agents */ break;
    case EXECUTE:        ada_run(); dijkstra_run(); break;
    case RETROSPECTIVE:  /* TBD agents */ break;
  }
}
```

### Key Properties

1. **Multiple agents per phase.** Each APE state hosts 1 or more agents. All run sequentially.
2. **Agents are unaware of each other.** No agent knows what other agents exist. Communication is through signals routed by the scheduler (see [signal-based-coordination](signal-based-coordination.md)).
3. **Event-driven scheduling with round-robin among READY agents.** Each READY agent executes one state transition and yields. Like a microcontroller, each agent has the illusion of running continuously, but only gets one time slice per tick. Agents in IDLE or WAITING state are never invoked — only READY agents get CPU time (see [signal-based-coordination](signal-based-coordination.md)).

## Relationship to Existing Specs

The [orchestrator-spec](../../references/orchestrator-spec.md) §1.2 already describes this model with the microcontroller analogy table. This document **confirms** that model and adds:

- **RETROSPECTIVE as a first-class state** (not in orchestrator-spec, which uses REVIEW → DARWIN as separate phases).
- **Agents never poll** — only the scheduler decides who runs (refined from orchestrator-spec §3.5 precondition table into a signal-based model).

## Contradiction with finite-ape-machine.md

The [finite-ape-machine spec](../../references/finite-ape-machine.md) §2.1 describes three loops (inner/middle/outer) but the outer loop says "Analyze → Plan → Execute → Learn" without making Learn (RETROSPECTIVE) a formal FSM state. The orchestrator-spec uses REVIEW and DARWIN as separate phases. Both need alignment to the confirmed model:

```
IDLE → ANALYZE → PLAN → EXECUTE → RETROSPECTIVE → IDLE
```

Where REVIEW (DIJKSTRA) is an agent within EXECUTE, and DARWIN is an agent within RETROSPECTIVE.
