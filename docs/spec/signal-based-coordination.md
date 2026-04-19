---
id: signal-based-coordination
title: "Signal-based coordination — RTOS event model for agent communication"
date: 2026-04-17
status: active
tags: [architecture, rtos, signals, events, scheduler, coordination]
author: socrates
---

# Signal-Based Coordination

## Problem

APE state transitions must be mechanical and deterministic. Each transition has preconditions (artifacts exist, user approves) and effects (commit, branch, folder creation). How does the scheduler coordinate transitions and agent dispatch?

## RTOS Analogy

In a Real-Time Operating System, tasks don't poll each other. They use **event flags** or **message queues**:

- Task A completes → sets an event flag
- Task B is in a wait queue, blocked on that flag
- The scheduler sees the flag, moves Task B from WAITING to READY
- Task B runs on the next tick

Tasks never reference each other. They only know about events.

## APE Signal Model

### Signals

A signal is emitted when a meaningful step completes:

```bash
ape signal <event-name>
```

The emitter does not know who (if anyone) listens. It just signals.

### Routing Table (embedded in ape.exe)

The scheduler maintains a routing table that maps signals to state changes:

```yaml
# Embedded in ape.exe, NOT in .ape/
signals:
  issue_ready:
    transition: IDLE → ANALYZE
    effects: [verify_branch, verify_folder]
  analysis_approved:
    transition: ANALYZE → PLAN
    effects: [git_commit_analysis]
  plan_approved:
    transition: PLAN → EXECUTE
    effects: [git_commit_plan]
  execution_approved:
    transition: EXECUTE → EVOLUTION
    effects: [git_commit, git_push, gh_pr_create]
  cycle_complete:
    transition: EVOLUTION → IDLE
    effects: [close_issue_if_applicable]
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

## Example: Full APE Cycle

```
IDLE:
  APE uses triage skill → user defines problem
  User: "ape issue start 42" → creates branch + folder
  Signal: issue_ready → transition to ANALYZE

ANALYZE:
  SOCRATES invoked with clean context + analyze/index.md
  SOCRATES explores, questions, documents
  SOCRATES produces diagnosis.md
  User approves → signal: analysis_approved
  Effects: git commit analysis docs → transition to PLAN

PLAN:
  DESCARTES invoked with diagnosis.md
  DESCARTES decomposes into WBS, defines test pseudocode
  DESCARTES produces plan.md
  User approves → signal: plan_approved
  Effects: git commit plan.md → transition to EXECUTE

EXECUTE:
  BASHŌ invoked with plan.md + codebase context
  BASHŌ implements phase by phase, commit per phase
  Final phase: product retrospective + validation report
  User approves → signal: execution_approved
  Effects: git commit, git push, gh pr create → transition to EVOLUTION

EVOLUTION:
  DARWIN invoked with full cycle artifacts
  DARWIN evaluates APE process
  DARWIN: gh issue list --repo finite_ape_machine --search "keyword"
  DARWIN: creates/comments on issues
  Automatic → signal: cycle_complete → transition to IDLE
```

## Transition Signals

APE state transitions use signals with a human gate:

```
Sub-agent reaches COMPLETE
  → Scheduler emits suggestion: "Analysis complete. Approve transition to PLAN?"
  → Human: explicit authorization (not "ok" or "sounds good")
  → Scheduler executes transition effects (commit, etc.)
  → New phase sub-agent moves from IDLE to READY
```

The human's explicit approval is itself a signal — the highest-priority interrupt.

**Exception:** EVOLUTION → IDLE is automatic (no human gate). DARWIN runs and completes. This can be disabled via `.ape/config.yaml` (`evolution.enabled: false`).

## Relationship to Existing Specs

The [orchestrator-spec](../../references/orchestrator-spec.md) §3.5 defines a precondition table where each agent checks conditions (e.g., "RED tests exist"). This is **polling** — the agent checks every tick if its condition is met.

The signal model replaces polling with events. Instead of checking preconditions every tick, agents wait for signals. This is more efficient and more faithful to the RTOS analogy.

## Open Questions

1. **Signal persistence.** If a signal fires while no agent is waiting on it, is it lost? In RTOS, event flags persist until cleared. Should `.ape/state.yaml` record pending signals?
2. **Error signals.** What happens when BASHŌ emits `execute-blocked` instead of completing? The routing table needs error paths that return to ANALYZE.
3. **Human signals.** Beyond approval, what other signals can the human emit? `ape abort`, `ape retry`, `ape skip`?
