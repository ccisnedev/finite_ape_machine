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
IDLE → ANALYZE → PLAN → EXECUTE → EVOLUTION
```

The cycle FSM has no intelligence. It tracks which phase is active and dispatches the registered sub-agent for that phase. It does not produce artifacts. APE is the Finite APE Machine — not an ape.

### Level 2: Agent FSMs (the tasks)

Each sub-agent operates within one APE state. Sub-agents are launched with clean context and a specific prompt. They receive the context they need and return results. APE the scheduler does not accumulate sub-agent context — this keeps the scheduler lean and the agents focused.

```c
void ape_tick() {
  switch(ape_state) {
    case IDLE:       ape_triage();         break;  // APE direct + triage skill
    case ANALYZE:    socrates_run();       break;  // Sub-agent: SOCRATES
    case PLAN:       descartes_run();      break;  // Sub-agent: DESCARTES
    case EXECUTE:    basho_run();          break;  // Sub-agent: BASHŌ
    case EVOLUTION:  darwin_run();         break;  // Sub-agent: DARWIN
  }
}
```

### Key Properties

1. **One primary sub-agent per phase.** IDLE uses APE directly (with a skill). ANALYZE→SOCRATES. PLAN→DESCARTES. EXECUTE→BASHŌ. EVOLUTION→DARWIN.
2. **Sub-agents are launched with clean context.** Each invocation receives: the user's input, the relevant artifacts (diagnosis.md, plan.md, etc.), and a phase-specific prompt. The sub-agent does not know about other phases or agents.
3. **Illusion of continuity.** Sub-agents don't persist between ticks. APE reconstructs context from artifacts (`state.yaml`, `diagnosis.md`, `plan.md`) and passes it to the sub-agent on each invocation. The agent experiences continuity; the scheduler provides it.
4. **Agents are unaware of each other.** No agent knows what other agents exist. Communication is through artifacts (files) routed by the scheduler (see [signal-based-coordination](signal-based-coordination.md)).
5. **Event-driven scheduling.** Agents in IDLE or WAITING state are never invoked — only READY agents get CPU time.

## The Four Sub-Agents

| Agent | State | Thinking Tool | Key Artifact |
|-------|-------|---------------|-------------|
| SOCRATES | ANALYZE | Mayéutica (Socratic method) | `diagnosis.md` — rigorous paper with references |
| DESCARTES | PLAN | Method (divide, order, verify, enumerate) | `plan.md` — WBS with checkboxes + test pseudocode |
| BASHŌ | EXECUTE | Techne + 用の美 (functional beauty) | Code + commits per phase |
| DARWIN | EVOLUTION | Natural selection (observe, compare, select) | Issues in APE repo (via `gh`) |

## APE in IDLE (triage)

In IDLE, APE operates directly — no sub-agent. It uses the triage skill, which embodies Aristotle's **phronesis** (practical wisdom): the ability to decide what merits action.

Triage determines:
- Whether the problem merits a formal APE cycle
- Whether a GitHub issue already exists (via `gh issue list --search`)
- Infrastructure preparation: `gh issue create` (if needed) → `ape issue start NNN` (branch + checkout + folder)

The gate to exit IDLE: issue exists + branch created + working directory ready.

## Relationship to Existing Specs

The [orchestrator-spec](../../references/orchestrator-spec.md) §1.2 describes this model with the microcontroller analogy table. This document **updates** that model:

- **EVOLUTION replaces RETROSPECTIVE/REVIEW/DARWIN** as a single state. Product retrospective lives inside EXECUTE's final phase; process introspection is EVOLUTION.
- **Sub-agents replace the multi-agent-per-phase model.** The original vision had multiple agents per phase (e.g., ADA + DIJKSTRA in EXECUTE). The current model simplifies to one sub-agent per phase, with domain skills providing specialized knowledge.
- **Agents never poll** — only the scheduler decides who runs (signal-based model).

## Alignment Notes

The [finite-ape-machine spec](../../references/finite-ape-machine.md) §2.1 describes three loops (inner/middle/outer). The outer loop now aligns:

```
IDLE → ANALYZE → PLAN → EXECUTE → EVOLUTION → IDLE
```

The [lore](../lore.md) describes 10 agents from the original vision. Four are now active (SOCRATES, DESCARTES, BASHŌ, DARWIN). The rest remain as lore/future reference.
