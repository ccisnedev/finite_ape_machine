---
id: agent-lifecycle
title: "Agent lifecycle — six-state model and confirmed agent registry"
date: 2026-04-17
status: active
tags: [agents, fsm, lifecycle, registry, socrates, descartes, basho, darwin]
author: socrates
---

# Agent Lifecycle and States

## APE Cycle States (confirmed)

The Finite APE Machine operates as a six-state FSM:

```
IDLE → ANALYZE → PLAN → EXECUTE → END → EVOLUTION
```

| APE State | Function | Operator | Thinking Tool |
|-----------|----------|----------|---------------|
| IDLE | Triage — classify, prepare infrastructure | APE + triage skill | Phronesis (Aristotle) — practical wisdom |
| ANALYZE | Deep understanding via Socratic method | SOCRATES (sub-agent) | Mayéutica — draw truth through questions |
| PLAN | Experimental design, WBS, test definition | DESCARTES (sub-agent) | Method — divide, order, verify, enumerate |
| EXECUTE | Implementation under constraints | BASHŌ (sub-agent) | Techne + 用の美 (yō no bi) — functional beauty |
| END | Explicit closure gate before evolution or return to idle | APE + human gate | Human judgment under explicit authorization |
| EVOLUTION | Evaluate APE process, create improvement issues | DARWIN (sub-agent) | Natural selection — observe, compare, select |

### State descriptions

**IDLE** — APE's default state. The user converses freely. APE uses the triage skill to evaluate whether the problem merits a formal cycle. If so, the protocol guides infrastructure preparation: verify or create the GitHub issue, create the branch and working directory, and transition to ANALYZE. APE operates directly in this state — no sub-agent.

**ANALYZE** — SOCRATES conducts Socratic analysis. Explores the problem through questions, challenges assumptions, documents findings. Produces `diagnosis.md` — a rigorous technical document (paper-style, with references) that serves as the sole input for the planning phase. The user approves the diagnosis before transitioning.

**PLAN** — DESCARTES applies the scientific method: the plan is an experimental design. Decomposes complexity into phases (WBS), defines tests in pseudocode, sequences by dependencies. Produces `plan.md` as an immutable checklist. The plan must be detailed enough that EXECUTE is mechanical — following instructions, not inventing them. The user approves the plan before transitioning.

**EXECUTE** — BASHŌ implements the plan phase by phase, like a haiku master working within formal constraints (the plan's restrictions = the 5-7-5 form). Each phase produces a commit. The final phase includes product retrospective: an implementation report with validation instructions for the user. If a deviation is detected, returns to ANALYZE (like falsifying a hypothesis in the scientific method). The user approves the execution report before transitioning to END.

**END** — APE presents the execution summary and waits for explicit authorization to create the PR and pass into EVOLUTION or return to IDLE if evolution is disabled. This keeps delivery and merge preparation as a distinct closure gate rather than an implicit side effect of EXECUTE.

**EVOLUTION** — DARWIN reads the complete cycle (diagnosis, plan, commits, deviations) and evaluates APE's own process. Searches for existing issues in the Inquiry repository (`gh issue list --search`), comments on matches or creates new issues. Automatic, no user approval required. Opt-out via `.inquiry/config.yaml` (`evolution.enabled: false`).

## Agent Registry

### Confirmed Agents (v0.0.8 target)

| Agent | Namesake | State | Herramienta | Description |
|-------|----------|-------|-------------|-------------|
| SOCRATES | Sócrates (470–399 BC) | ANALYZE | Mayéutica | Conversational understanding, produces `diagnosis.md` |
| DESCARTES | René Descartes (1596–1650) | PLAN | Método | Experimental design, WBS, test pseudocode |
| BASHŌ | Matsuo Bashō (1644–1694) | EXECUTE | Techne/用の美 | Implementation as functional art under constraints |
| DARWIN | Charles Darwin (1809–1882) | EVOLUTION | Selección natural | Process evaluation, self-improvement issues |

### APE (the scheduler)

APE is NOT an ape. It is the Finite APE Machine — the scheduler, the event loop, the RTOS. It has no personality, no namesake. It reads state, evaluates conditions, dispatches sub-agents, and updates state. It operates directly in IDLE (with the triage skill) and delegates to sub-agents in all other states.

### Lore Agents (future/referential)

The [lore](../lore.md) describes additional agents from the original vision. These remain as reference for future expansion:

| Agent | Original Role | Current Status |
|-------|--------------|----------------|
| MARCOPOLO | Document ingestion | Future — SOCRATES handles this via skills |
| VITRUVIUS | WBS/decomposition | Absorbed by DESCARTES |
| SUNZI | Strategic planning | Replaced by DESCARTES |
| GATSBY | RED tests/@contracts | Absorbed by DESCARTES (test pseudocode in plan) |
| ADA | TDD implementation | Replaced by BASHŌ |
| DIJKSTRA | Quality gate | Future — may be a skill within EXECUTE |
| BORGES | Schema enforcement | Future — may be a CLI validation layer |
| HERMES | State updates | Future — may be `ape state transition` command |

## Agent Scheduling Model

### Five agent states (scheduler-visible)

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

From the **agent's perspective**, only three states are visible: idle, working, or done. The IDLE/WAITING distinction is managed by the scheduler via signals (see [signal-based-coordination](signal-based-coordination.md)).

### Key principle

Agent intelligence lives in prompts, not in state machines. SOCRATES uses Socratic phases (CLARIFICATION → ASSUMPTIONS → EVIDENCE → PERSPECTIVES → IMPLICATIONS → META-REFLECTION) as conversation strategies, not scheduler-tracked states. DESCARTES applies the 4 rules of the Method internally. BASHŌ selects the appropriate domain skill per phase. These are opaque to the scheduler.

| Concept | Visible to scheduler | Visible to agent |
|---------|---------------------|------------------|
| IDLE/WAITING/READY/RUNNING/COMPLETE | Yes — formal FSM | Partially (agent sees idle/working/complete) |
| Internal methodology phases | No — opaque | Yes — embedded in prompt |

## Transition Mechanics

All APE state transitions are mechanical, executed via skill → CLI chain:

| Transition | Event | Effects |
|-----------|-------|---------|
| IDLE → ANALYZE | `issue_ready` | Verify rama + carpeta exist |
| ANALYZE → PLAN | `analysis_approved` | `git commit` analysis docs |
| PLAN → EXECUTE | `plan_approved` | `git commit` plan.md |
| EXECUTE → END | `execution_approved` | `git commit` execution artifacts |
| END → EVOLUTION | `pr_ready` | `git push`, `gh pr create` |
| END → IDLE | `pr_ready_no_evolution` | `git push`, `gh pr create` |
| EVOLUTION → IDLE | `cycle_complete` | Close issue if applicable |

**Illegal transitions:**
- IDLE → PLAN (no analysis)
- IDLE → EXECUTE (no plan)
- ANALYZE → EXECUTE (skipping plan)
- EXECUTE → PLAN (must go through ANALYZE)
- EXECUTE → EVOLUTION (must go through END)

### Transition ownership

- **APE state transitions** (ANALYZE → PLAN): The human decides. The scheduler suggests when the agent reaches COMPLETE, but never forces.
- **Agent state transitions** (IDLE → RUNNING → COMPLETE): The scheduler manages dispatch. The agent itself transitions to COMPLETE when it judges its work done.

## Artifacts per State

```
cleanrooms/NNN-<slug>/
├── analyze/
│   ├── index.md              ← navigation
│   ├── *.md                  ← working documents (exploration, discards)
│   └── diagnosis.md          ← final output: rigorous paper with references
└── plan.md                   ← WBS with checkboxes, test pseudocode
```

- `NNN` matches the GitHub issue number
- `<slug>` matches the branch name
- `diagnosis.md` is the contract between ANALYZE and PLAN
- `plan.md` is the contract between PLAN and EXECUTE
