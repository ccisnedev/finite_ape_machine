---
id: agent-lifecycle
title: "Agent lifecycle — confirmed registry and five-state scheduler model"
date: 2026-04-16
status: active
tags: [agents, fsm, lifecycle, registry, socrates]
author: socrates
---

# Agent Lifecycle and States

## Confirmed vs. In Review

### Confirmed States (implemented)

| APE State | Description |
|-----------|-------------|
| ANALYZE | Requirements understanding, scope definition |
| PLAN | Technical design, runbook, test definition |
| EXECUTE | TDD implementation, quality verification |

### In Review States

| APE State | Description | Status |
|-----------|-------------|--------|
| IDLE | No active task | Logical but not yet implemented |
| RETROSPECTIVE | Post-cycle lessons, evolution | Replaces REVIEW + DARWIN from orchestrator-spec |

### Confirmed Agents (implemented)

| Agent | Lives in | Description |
|-------|----------|-------------|
| SOCRATES | ANALYZE | Conversational requirements understanding |

### In Review Agents

| Agent | Lives in | Description |
|-------|----------|-------------|
| MARCOPOLO | ANALYZE | Document ingestion and normalization |
| VITRUVIUS | ANALYZE | Decomposition, WBS, sizing |
| SUNZI | PLAN | Technical design, runbook generation |
| GATSBY | PLAN | Contract definition, RED tests |
| ADA | EXECUTE | TDD implementation |
| DIJKSTRA | EXECUTE | Quality gate pre-PR |
| DARWIN | RETROSPECTIVE | Lessons learned, system evolution |

## The Three-State Simplification → Five-State Scheduler Model

### Decision

Agent states visible to the scheduler are five, grouped in two categories:

```
Not scheduled:  IDLE, WAITING
Scheduled:      READY, RUNNING, COMPLETE
```

Transitions:

```
IDLE ──[phase activated]──→ READY
IDLE ──[phase activated, blocked on signal]──→ WAITING
WAITING ──[signal received]──→ READY
READY ──[scheduler tick]──→ RUNNING
RUNNING ──[step complete]──→ READY | WAITING | COMPLETE
```

From the **agent's perspective**, only three states are visible: it is either not doing anything (IDLE/WAITING), working (READY/RUNNING), or done (COMPLETE). The agent does not know whether it was WAITING or IDLE — that distinction is managed by the scheduler via signals (see [signal-based-coordination](signal-based-coordination.md)).

### Rationale

The [finite-ape-machine spec](../../references/finite-ape-machine.md) §3.2 defines detailed FSMs per agent (e.g., SOCRATES: `idle → understanding → questioning → clarifying → documenting → idle`). These detailed phases are **methodology, not FSM states**.

SOCRATES uses the Socratic method internally (CLARIFICATION → ASSUMPTIONS → EVIDENCE → PERSPECTIVES → IMPLICATIONS → META-REFLECTION), but these are conversation strategies that the AI decides when to apply. They are not rigid state transitions that the scheduler tracks.

The distinction:

| Concept | Visible to scheduler | Visible to agent |
|---------|---------------------|------------------|
| IDLE/WAITING/READY/RUNNING/COMPLETE | Yes — formal FSM | Partially (agent sees idle/working/complete) |
| Internal methodology phases | No — opaque | Yes — embedded in prompt |

### Implications

1. **The scheduler tracks five states per agent** (IDLE, WAITING, READY, RUNNING, COMPLETE), but agents only perceive three (idle, working, complete). This keeps `.ape/state.yaml` manageable while enabling signal-based coordination.
2. **Agent intelligence lives in prompts, not in state machines.** SOCRATES can revisit any Socratic phase at any time — it's the AI's judgment, not a scheduler constraint.
3. **COMPLETE triggers scheduler evaluation.** When all agents in a phase reach COMPLETE, the scheduler may suggest transitioning to the next APE state. The human decides.

## Transition Ownership

- **APE state transitions** (ANALYZE → PLAN): The human decides. The scheduler suggests when all agents are COMPLETE, but never forces.
- **Agent state transitions** (IDLE → RUNNING → COMPLETE): The scheduler manages IDLE → RUNNING (based on signals/preconditions). The agent itself transitions RUNNING → COMPLETE when it judges its work done.

## Contradiction with finite-ape-machine.md

The spec §3.2 defines detailed FSMs per agent that imply the scheduler tracks granular states (e.g., `understanding → questioning → clarifying`). This analysis concludes those are internal methodology, not scheduler-visible states. The spec should be updated to reflect the five-state model (IDLE/WAITING/READY/RUNNING/COMPLETE) where the agent only perceives three (idle/working/complete).
