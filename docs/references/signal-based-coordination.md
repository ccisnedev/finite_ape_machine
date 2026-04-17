---
id: signal-based-coordination
title: "Signal-based coordination — RTOS event model for agent communication"
date: 2026-04-16
status: active
tags: [architecture, rtos, signals, events, scheduler, coordination]
author: socrates
---

# Signal-Based Coordination

## Problem

Multiple agents run within a single APE phase (e.g., ADA and DIJKSTRA in EXECUTE). They are unaware of each other. Yet DIJKSTRA cannot start until ADA delivers. How do they coordinate?

## RTOS Analogy

In a Real-Time Operating System, tasks don't poll each other. They use **event flags** or **message queues**:

- Task A completes → sets an event flag
- Task B is in a wait queue, blocked on that flag
- The scheduler sees the flag, moves Task B from WAITING to READY
- Task B runs on the next tick

Tasks never reference each other. They only know about events.

## APE Signal Model

### Signals

An agent emits a signal when it completes a meaningful step:

```bash
ape signal <event-name>
```

The agent does not know who (if anyone) listens. It just signals.

### Routing Table (embedded in ape.exe)

The scheduler maintains a routing table that maps signals to agent state changes:

```yaml
# Embedded in ape.exe, NOT in .ape/
signals:
  analyze-complete:
    suggests_transition: PLAN    # Scheduler suggests to human
  execute-stage-complete:
    wakes: dijkstra              # Moves DIJKSTRA from WAITING to READY
  dijkstra-approved:
    wakes: ada                   # Next runbook phase, or signals PR readiness
```

### Agent States in Context

```
IDLE     → Not registered for current phase (not scheduled)
WAITING  → Registered but blocked on a signal (not scheduled)
READY    → Precondition met, will run on next tick
RUNNING  → Currently executing (one per tick)
COMPLETE → Finished work for this phase
```

The scheduler only invokes READY agents. IDLE and WAITING agents are skipped — no wasted ticks.

## Example: EXECUTE Phase with ADA + DIJKSTRA

```
Tick 1: ADA is READY, DIJKSTRA is WAITING(execute-stage-complete)
        → ada_run() → ADA transitions RUNNING → does implementation
Tick 2: ADA emits "ape signal execute-stage-complete"
        → Scheduler routes signal → DIJKSTRA moves WAITING → READY
Tick 3: DIJKSTRA is READY
        → dijkstra_run() → checks contracts, quality
Tick 4: DIJKSTRA emits "ape signal dijkstra-approved"
        → Scheduler routes → ADA WAITING → READY (for next phase)
        OR → all agents COMPLETE → scheduler suggests RETROSPECTIVE
```

From ADA's perspective: it runs, signals, and later gets re-activated. It never knew DIJKSTRA existed.

## Transition Signals

APE state transitions (ANALYZE → PLAN) use the same mechanism but with a human gate:

```
All agents in phase reach COMPLETE
  → Scheduler emits suggestion: "Analysis complete. Approve transition to PLAN?"
  → Human: "ape approve" (or equivalent)
  → Scheduler transitions APE state
  → New phase agents move from IDLE to READY
```

The human's `ape approve` is itself a signal — the highest-priority interrupt.

## Relationship to Existing Specs

The [orchestrator-spec](../../references/orchestrator-spec.md) §3.5 defines a precondition table where each agent checks conditions (e.g., "RED tests exist"). This is **polling** — the agent checks every tick if its condition is met.

The signal model replaces polling with events. Instead of DIJKSTRA checking "do GREEN tests exist?" every tick, it waits for the `execute-stage-complete` signal. This is more efficient and more faithful to the RTOS analogy.

## Open Questions

1. **Signal persistence.** If a signal fires while no agent is waiting on it, is it lost? In RTOS, event flags persist until cleared. Should `.ape/state.yaml` record pending signals?
2. **Error signals.** What happens when ADA emits `execute-stage-blocked` instead of `execute-stage-complete`? The routing table needs error paths.
3. **Human signals.** Beyond `ape approve`, what other signals can the human emit? `ape abort`, `ape retry`, `ape skip`?
