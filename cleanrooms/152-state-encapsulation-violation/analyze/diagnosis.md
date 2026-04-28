---
id: diagnosis
title: "Diagnosis — Issue #152: State encapsulation violation"
date: 2026-04-27
status: final
tags: [diagnosis, encapsulation, fsm, idle, firmware, kernel-boundary]
author: socrates
---

# Diagnosis

## Problem

The firmware and CLI leak state knowledge to agents. Agents see destination states, receive escape-route instructions, and can transition to ANALYZE without an issue or branch. IDLE has no behavior — agents fall through to coding directly. The `issue-start` skill instructs agents to write `.inquiry/state.yaml`, violating the kernel boundary.

Observed during this session: a frontier model edited `.inquiry/state.yaml` directly. The bug is not a capability problem — it is the absence of guardrails.

## Root cause

The v0.2.0 firmware refactor simplified the agent prompt from 554 to ~35 lines. The simplification was correct, but it removed IDLE triage and left the firmware enumerating the full state graph. The firmware should be a generic dispatch loop that delegates all Inquiry-specific knowledge to the CLI.

## Architecture (confirmed)

Two layers, clean separation:

- **Firmware** — generic dispatch loop. Reads `iq fsm state --json`, dispatches sub-agents via `iq ape prompt`, presents transitions. Knows nothing about Inquiry, states, or phases.
- **CLI** — Inquiry kernel. Knows states, transitions, prechecks, sub-agents, context. Injects all Inquiry-specific knowledge through its output.

No additional layer is needed. The fix is to purify this boundary.

## What this issue fixes

### A1. Add prechecks to `start_analyze`

- **File:** `transition_contract.yaml`
- **Change:** `prechecks: []` → `prechecks: [issue_selected_or_created, feature_branch_selected]`
- Prevents transition without issue/branch. Validation code already exists in `_validatePreconditions()`.

### A2. Remove `next_state` from JSON output

- **File:** `state.dart`, `_computeTransitions`
- **Change:** Remove `next_state` key from transition objects
- 1 test to update (`fsm_state_test.dart`). Nothing reads this field for routing.

### A3. Rewrite `_stateInstructions` as mission descriptions

- **File:** `state.dart`, lines 184-199
- **Change:** Each state describes its mission, not how to leave it
- Example: IDLE goes from "Use `iq fsm transition --event start_analyze` to begin" to a description of the triage mission.

### A4. Update `issue-start` skill to respect kernel boundary

- **File:** `issue-start/SKILL.md`
- **Change:** Replace "write `.inquiry/state.yaml`" with "execute `iq fsm transition --event start_analyze --issue <NNN>`"

### B1. Activate SOCRATES in IDLE

- **Files:** `_stateApes` mappings in `state.dart`, `prompt.dart`, `effect_executor.dart`
- **Change:** Map IDLE to SOCRATES with a triage-mode sub-FSM
- SOCRATES in IDLE: "Is this well-scoped? Does it exist? Is it granular?" → produces an issue
- SOCRATES in ANALYZE: "What is the root cause?" → produces diagnosis.md
- Same thinking tool, different mission per state. Requires mode-dependent sub-FSMs for the same agent name.

### B2. Rewrite firmware `inquiry.agent.md`

- Never enumerate states by name
- Read `iq fsm state --json` for state, instructions, and transitions
- If sub-agent active → dispatch via Inner Loop
- If no sub-agent → follow `instructions` from JSON
- The firmware is state-agnostic — a generic dispatch loop

## What this issue does NOT fix

| Concern | Reason | Tracking |
|---------|--------|----------|
| Event renaming (`start_analyze` → `begin`) | 25+ files, high blast radius | Future issue |
| Sub-agent YAMLs contain infrastructure | Different principle (agent purity vs state encapsulation) | #154 |
| DARWIN active in all phases | Requires config gating and multi-agent-per-state infrastructure | Future issue |
| Build asset sync | Mechanical, done at release | N/A |

## Governing principle

> Each state is a complete, self-contained world. It has a mission, a sub-agent, and artifacts. It does not know that other states exist.

Conviction #4 from `docs/philosophy.md`: **States are worlds**.
