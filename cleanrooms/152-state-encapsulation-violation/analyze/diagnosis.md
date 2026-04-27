---
id: diagnosis
title: "Diagnosis — Issue #152: State encapsulation violation"
date: 2026-04-27
status: draft
tags: [diagnosis, encapsulation, fsm, idle, triage, firmware, kernel-boundary]
author: socrates
---

# Diagnosis

## Problem statement

The Inquiry scheduler violates its own state encapsulation principle: it lists all FSM states in the firmware, exposes destination states in JSON output, provides escape-route instructions instead of mission descriptions, allows transition to ANALYZE without issue or branch, and has no behavior for IDLE. The result is that agents bypass the method — coding directly, transitioning without prerequisites, or acting without the developer's clear intent.

This is not a theoretical concern. During this analysis session, a frontier model (Claude Opus 4.6, maximum reasoning configuration) violated the kernel boundary by editing `.inquiry/state.yaml` directly. The bug affects all models because it is not a capability problem — it is the absence of guardrails.

## Root cause

The firmware v0.2.0 refactor reduced the agent prompt from 554 lines to ~35. The simplification was correct — the old prompt was too complex. But the refactor cut too deep: it removed IDLE triage behavior entirely and left the firmware as a generic dispatcher that enumerates the full state graph. The sub-agents (SOCRATES, DESCARTES, BASHŌ, DARWIN) are well-encapsulated. The scheduler that orchestrates them is not.

## Violations by layer

| # | Layer | Severity | Location |
|---|-------|----------|----------|
| 1 | Firmware enumerates all 6 states | HIGH | `inquiry.agent.md` line 14 |
| 2 | CLI instructions are escape routes | HIGH | `state.dart` lines 184-199 |
| 3 | JSON exposes `next_state` | MEDIUM | `state.dart` `_computeTransitions` |
| 4 | `start_analyze` has empty prechecks | HIGH | `transition_contract.yaml` lines 30-39 |
| 5 | IDLE has no triage behavior | HIGH | `inquiry.agent.md` line 22 |
| 6 | `issue-start` skill writes `.inquiry/` directly | HIGH | `issue-start/SKILL.md` |
| 7 | Build assets empty | LOW | `build/assets/` |

## What works correctly

- Sub-agent YAMLs: zero cross-state references
- Precondition system: ANALYZE→PLAN, PLAN→EXECUTE, EXECUTE→END all enforced
- `--issue` flag: `iq fsm transition --event start_analyze --issue <N>` works
- `_validatePreconditions()`: validation code exists, only contract declaration missing
- Sub-agent terminal events use `complete`, not state-name-based events

## Prescribed changes

Ordered by risk (low → high). Each group can be tested independently.

### Group A — Low risk, high impact

**A1. Add prechecks to `start_analyze`**
- File: `transition_contract.yaml`
- Change: `prechecks: []` → `prechecks: [issue_selected_or_created, feature_branch_selected]`
- Why: Closes the only destructive bug — prevents transition without issue/branch

**A2. Remove `next_state` from JSON output**
- File: `state.dart`, `_computeTransitions`
- Change: Stop including `next_state` in transition objects
- Why: Agents cannot see destination states. 1 test to update.

**A3. Rewrite `_stateInstructions` to mission descriptions**
- File: `state.dart`, lines 184-199
- Change: Replace escape-route strings with mission descriptions
- Why: Each state describes what it does, not how to leave it

**A4. Update `issue-start` skill to use CLI**
- File: `issue-start/SKILL.md`
- Change: Replace "write `.inquiry/state.yaml`" with "execute `iq fsm transition --event start_analyze --issue <NNN>`"
- Why: Skills must respect the kernel boundary

### Group B — Medium risk, structural

**B1. Enable SOCRATES in IDLE with a triage-mode prompt**
- The original design proposed a new sub-agent (ARISTOTLE). This was invalidated: Aristotle's tools classify what is already determined, but IDLE needs to transform the indeterminate into determinate — that is Dewey's problematization, and SOCRATES already does it.
- Change: `_stateApes` maps IDLE to SOCRATES (same agent, different sub-FSM and prompt)
- SOCRATES in IDLE asks: "Is this a well-scoped problem? Does it already exist as an issue? Is it granular enough?"
- SOCRATES in ANALYZE asks: "What is the root cause?" → produces diagnosis.md
- Sub-FSM for IDLE mode: `evaluate_scope → search_existing → create_or_select → confirm → _DONE`
- This requires the sub-agent system to support **mode-dependent prompts and sub-FSMs** for the same agent name

**B2. Update `_stateApes` mappings for multi-mode model**
- Files: `state.dart`, `prompt.dart`, `effect_executor.dart`
- Current model: each state has exactly one sub-agent (or none)
- New model: sub-agents are cross-cutting capabilities that activate per context:
  - SOCRATES: IDLE (triage) + ANALYZE (diagnosis)
  - DESCARTES: PLAN
  - BASHŌ: EXECUTE + END
  - DARWIN: ALL phases when `evolution=true` (continuous process observer)
- The DARWIN-everywhere pattern solves the problem the developer currently handles manually: noticing process violations during the cycle

**B3. Rewrite firmware `inquiry.agent.md`**
- Principles:
  - Never enumerate states by name
  - Read `iq fsm state --json` for current state, instructions, and transitions
  - If sub-agent active: dispatch via Inner Loop
  - If no sub-agent: follow `instructions` field from JSON
  - The firmware is state-agnostic — it delegates everything to the CLI's output
- Why: Encapsulation at the scheduler level. The firmware becomes a generic dispatch loop.

### Excluded from scope

- **Event renaming** (e.g., `start_analyze` → `begin`): 25+ files affected, deferred to separate issue
- **Build asset sync**: mechanical, done at release time
- **Full DARWIN-everywhere implementation**: confirmed as direction, but requires its own issue for prompt design, config gating, and multi-agent-per-state infrastructure

## Governing principle

> Each state is a complete, self-contained world. It has a mission, a sub-agent, and artifacts. It does not know that other states exist.

This is conviction #4 from `docs/philosophy.md`: **States are worlds**. Encapsulation is not code hygiene — it preserves the integrity of each mode of inference. SOCRATES must not know about PLAN because knowing about PLAN corrupts analysis.

## Evidence summary

| ID | Finding | Source |
|----|---------|--------|
| F1 | Frontier model violated kernel boundary during this session | Session transcript |
| F2 | Thesis is clarity, not model independence | `docs/timeline.md` |
| F3 | `--issue` flag works correctly | Manual verification |
| F4 | `issue-start` skill writes `.inquiry/` directly | `SKILL.md` read |
| F5 | `start_analyze` prechecks empty, validation code exists | `transition_contract.yaml`, `transition.dart` |
| F6 | Event rename deferred — 25+ file blast radius | grep search |
| F7 | ARISTOTLE invalidated — SOCRATES in two modes replaces it | Analysis session |
| F8 | `docs/philosophy.md` created as foundational document | Analysis session |
| F9 | `next_state` removal safe — 1 test to update | grep search |
| F10 | Sub-agent YAMLs clean — violation is firmware/CLI only | YAML file reads |
| F11 | Sub-agents are cross-cutting capabilities, not 1:1 slots | Analysis session |
| F12 | IDLE is Dewey's problematization — "analysis before the analysis" | Peirce/Dewey research docs |
