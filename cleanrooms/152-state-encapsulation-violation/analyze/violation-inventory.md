---
id: violation-inventory
title: "Complete inventory of state encapsulation violations"
date: 2026-04-27
status: active
tags: [encapsulation, fsm, idle, triage, firmware, cli]
author: socrates
---

# State Encapsulation Violation Inventory

## Principle

> No state knows that other states exist — not their name, not their transition event.

Established for sub-agents in `docs/spec/cooperative-multitasking-model.md` property #4. Never applied to the FSM main states or CLI output.

## Layer 1: Firmware enumerates all 6 states (HIGH)

**File:** `code/cli/assets/agents/inquiry.agent.md` line 14

```
state: current FSM state (IDLE, ANALYZE, PLAN, EXECUTE, END, EVOLUTION)
```

IDLE doesn't need to know PLAN exists. Each state should only know about itself.

## Layer 2: CLI instructions are escape routes, not missions (HIGH)

**File:** `code/cli/lib/modules/fsm/commands/state.dart` lines 184-199

| State | Current (escape) | Proposed (mission) |
|-------|-----------------|-------------------|
| IDLE | "No active cycle. Use `iq fsm transition --event start_analyze` to begin." | "Evaluate what work merits formal inquiry. Use phronesis: understand the problem, verify/create an issue, prepare infrastructure." |
| ANALYZE | "socrates is investigating. Produce diagnosis.md, then `iq fsm transition --event complete_analysis`." | "SOCRATES explores the problem through Socratic dialogue. Challenge assumptions. Document findings. Produce diagnosis.md." |
| PLAN | "descartes is structuring the plan. Produce plan.md, then `iq fsm transition --event approve_plan`." | "DESCARTES structures an experimental design. Divide complexity into phases. Define tests. Order by dependencies. Produce plan.md." |
| EXECUTE | "basho is implementing. Complete the work, then `iq fsm transition --event finish_execute`." | "BASHŌ implements phase by phase under the plan's formal constraints. Each phase produces a commit." |
| END | "basho is finalizing. Create PR with `iq fsm transition --event pr_ready`." | "Review the execution report. Authorize closure." |
| EVOLUTION | "darwin is reviewing mutations.md. Complete with `iq fsm transition --event finish_evolution`." | "DARWIN evaluates the APE process. Observe, compare, select. Create self-improvement issues." |

## Layer 3: JSON exposes next_state (MEDIUM)

**File:** `code/cli/lib/modules/fsm/commands/state.dart` `_computeTransitions`

```json
"transitions": [{"event": "start_analyze", "next_state": "ANALYZE"}]
```

The agent doesn't need to know the destination. Options:
- Remove `next_state` from JSON entirely
- Keep it but don't expose in prompts (internal use)

## Layer 4: Transition contract enumerates all states (ACCEPTABLE)

**File:** `code/cli/assets/fsm/transition_contract.yaml`

The contract IS the state graph — enumeration is by design. But this data must not leak into agent prompts. The `reason` fields in illegal transitions reinforce state knowledge: "IDLE cannot complete analysis before ANALYZE".

## Layer 5: IDLE has no triage behavior (HIGH)

**File:** `code/cli/assets/agents/inquiry.agent.md` line 22

Current: `If ape is null (IDLE): present transitions[] to user and wait for choice`

Expected (from legacy and specs):
1. Classify intent (consultation vs modification)
2. Search for existing issues (`gh issue list --search`)
3. Guide issue creation if needed
4. Execute `issue-start` skill
5. Never mention ANALYZE, PLAN, or EXECUTE

## Layer 6: start_analyze has no prechecks (HIGH)

**File:** `code/cli/assets/fsm/transition_contract.yaml` lines 30-39

```yaml
prechecks: []  # ← EMPTY
```

Should be: `[issue_selected_or_created, feature_branch_selected]`

The validation code ALREADY EXISTS in `_validatePreconditions()` in `transition.dart`. Only the contract declaration is missing.

## Layer 7: Build assets empty (LOW)

`code/cli/build/assets/` is empty. Expected to be populated on build. Pre-release OK.

## What works correctly

- Sub-agent YAMLs (socrates, basho, descartes, darwin) — zero references to other FSM states
- Precondition system — ANALYZE→PLAN, PLAN→EXECUTE, EXECUTE→END all have proper prechecks
- Sub-agent terminal transitions use `complete` event, not state-name-based events
