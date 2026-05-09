---
id: confirmed
title: "Confirmed findings"
date: 2026-05-08
status: active
tags: [findings, confirmed]
author: socrates
---

# Issue #175 & #176: Confirmed Findings

> Socratic investigation using methodical artifact analysis. Each finding cites evidence.
> Format: ## F<N>: <title> — CONFIRMED|REVISED|INVALIDATED

## F1: Current DEWEY terminal condition does not match the intended IDLE loop — REVISED

**Finding:**
The previous formulation was still too broad. Your clarified product definition is stricter:

- when DEWEY creates or confirms the issue, it should finish that triage conversation and return to its initial state
- the main FSM should remain in IDLE by default
- DEWEY should be immediately ready to triage a new situation
- DEWEY should reach `_DONE` only when the user explicitly asks to begin resolving an issue
- only after that `_DONE` should `issue-start` run and hand off to ANALYZE

The current DEWEY.yaml contract does not encode that model. It currently specifies:
```yaml
confirm:
  description: "Confirm the issue is ready to be tracked"
  transitions:
    - event: complete
      to: _DONE
```

That means the current asset sends DEWEY to `_DONE` too early for the intended design.

**Evidence:**
- [code/cli/assets/apes/dewey.yaml](code/cli/assets/apes/dewey.yaml#L75-L82): confirm state with complete event
- [code/cli/assets/apes/dewey.yaml](code/cli/assets/apes/dewey.yaml#L5): DEWEY already has a defined initial state that could receive the next triage loop
- [code/cli/assets/fsm/transition_contract.yaml](code/cli/assets/fsm/transition_contract.yaml): `start_analyze` is a distinct FSM event, separate from DEWEY's internal `complete`
- [code/cli/assets/skills/issue-start/SKILL.md](code/cli/assets/skills/issue-start/SKILL.md): operational setup belongs to a separate skill, not to DEWEY's triage loop

**Implication:** The current DEWEY contract encodes the wrong terminal condition for the intended product model. Issue readiness should reset DEWEY inside IDLE; `_DONE` should be reserved for explicit start intent. ❌

---

## F2: The canonical IDLE behavior is not centralized in transition_contract.yaml and idle.yaml — REVISED

**Finding:**
The intended source of truth is now clearer:

1. **transition_contract.yaml** should define the main FSM only: IDLE stays in IDLE by default and exits only through `start_analyze`
2. **idle.yaml** should define the internal semantics of IDLE: TRIAGE vs DONE, DEWEY dispatch, reset-after-issue-ready, and issue-start handoff after explicit start intent
3. Other documents may explain the model, but they should not be required to reconstruct the canonical behavior

**Problem:**
- [code/cli/assets/fsm/transition_contract.yaml](code/cli/assets/fsm/transition_contract.yaml) currently defines the external transition out of IDLE, but not the normal internal loop behavior inside IDLE
- [code/cli/assets/fsm/states/idle.yaml](code/cli/assets/fsm/states/idle.yaml) currently describes IDLE only at a high level and does not encode TRIAGE vs DONE, DEWEY reset semantics, or the precise trigger for `issue-start`
- Developers still need explanatory documents to infer the intended behavior, which means the canonical model is not actually centralized where it should be

**Evidence:**
- [code/cli/assets/fsm/transition_contract.yaml](code/cli/assets/fsm/transition_contract.yaml#L33-L41): only explicit main-FSM exit from IDLE is `start_analyze`
- [code/cli/assets/fsm/transition_contract.yaml](code/cli/assets/fsm/transition_contract.yaml#L80-L89): IDLE remains in IDLE on `block`
- [code/cli/assets/fsm/states/idle.yaml](code/cli/assets/fsm/states/idle.yaml#L1-L20): describes mission/constraints/actions but not the internal IDLE state machine
- [docs/spec/agent-lifecycle.md](docs/spec/agent-lifecycle.md#L31): still used as narrative explanation for behavior that should be canonical in runtime assets

**Implication:** F2 is not just “documentation is spread out”. The real problem is that the canonical IDLE model is not fully encoded in the two files that should define it: transition_contract.yaml and idle.yaml. ❌

---

## F3: issue-start invocation is not documented in any runtime contract — CONFIRMED

**Finding:**
`issue-start` is documented as an existing skill, but the canonical IDLE contract still does not specify that DONE consumes `issue-start` and hands off automatically to ANALYZE.

What is missing is not the existence of the skill. What is missing is the normative description of its use from inside IDLE.

IDLE should specify:
- that `issue-start` runs only after explicit user intent to begin resolving an issue
- that DONE consumes `issue-start`
- that consuming `issue-start` is part of the behavior the Inquiry CLI exposes for IDLE
- that this consumption produces the handoff to ANALYZE

**Evidence:**
- [code/cli/assets/skills/issue-start/SKILL.md](code/cli/assets/skills/issue-start/SKILL.md): The skill exists and its operational steps are documented
- [code/cli/assets/fsm/states/idle.yaml](code/cli/assets/fsm/states/idle.yaml): Does not currently describe DONE consuming `issue-start`
- [code/cli/assets/agents/inquiry.agent.md](code/cli/assets/agents/inquiry.agent.md): Does not currently make that IDLE behavior explicit either

**Where issue-start IS mentioned:**
- [docs/spec/agent-lifecycle.md](docs/spec/agent-lifecycle.md#L31): mentions an explicit handoff
- [code/cli/assets/skills/issue-start/SKILL.md](code/cli/assets/skills/issue-start/SKILL.md#L8): Described as protocol and operational sequence

**Implication:** The problem is not that `issue-start` is undocumented. The problem is that `idle.yaml` does not yet document when DONE consumes `issue-start` and therefore the canonical IDLE behavior is still incomplete. ❌

---

## F4: TRIAGE should consume a deterministic issue-create skill, but current docs still mix that responsibility into issue-start — REVISED

**Finding:**
The clarified model is now more precise than simple ownership-by-agent:

1. **IDLE** is the main state and internally contains `TRIAGE` and `DONE`
2. **TRIAGE** delegates to DEWEY for Deweyan methodology
3. **When TRIAGE determines that an issue must be created or confirmed, it should consume a deterministic skill for that purpose**
4. **issue-start** should not own issue creation; it should begin work on an already selected or created issue

This produces a clearer split:

- DEWEY focuses on clarification, scoping, splitting, and deciding whether one or more issues are needed
- TRIAGE consumes a deterministic issue-creation skill to execute `gh` commands, templates, labels, and other GitHub-side mechanics
- `issue-start` remains the operational handoff after DONE

Current documents still mix these responsibilities and therefore do not match the intended design.

**Evidence:**
- [code/cli/assets/fsm/states/idle.yaml](code/cli/assets/fsm/states/idle.yaml#L13-L17): Allows "Create GitHub issues"
- [code/cli/assets/skills/issue-start/SKILL.md](code/cli/assets/skills/issue-start/SKILL.md#L28-L39): Still mixes issue identification/creation with operational setup
- [docs/spec/agent-lifecycle.md](docs/spec/agent-lifecycle.md#L31): Still attributes issue creation to issue-start
- Existing repository naming pattern is object-first: `issue-start`, `issue-end`, `doc-read`, `doc-write`, so `issue-create` is the consistent name if this skill is introduced

**Implication:** The remaining gap is not just contradictory ownership. The design needs a deterministic `issue-create`-style skill under TRIAGE, leaving DEWEY focused on methodology and leaving `issue-start` focused on operational start. ❌

---

## F5: Preconditions for start_analyze are split across IDLE and issue-start but the sequencing is undocumented — CONFIRMED

**Finding:**
FSM transition requires preconditions, but the current documents do not separate which phase produces each one:

```yaml
- from: IDLE
  event: start_analyze
  prechecks: [issue_selected_or_created, feature_branch_selected]
```

Preconditions are **checked** by StateTransitionCommand, not **created**.
Under the clarified model, they come from different moments:

- `issue_selected_or_created` is satisfied during IDLE triage
- `feature_branch_selected` is satisfied by `issue-start` only after explicit user intent to begin work

**Evidence:**
- [code/cli/assets/fsm/transition_contract.yaml](code/cli/assets/fsm/transition_contract.yaml#L40-41): Lists prechecks
- [code/cli/test/fsm_transition_test.dart](code/cli/test/fsm_transition_test.dart#L155-L174): Tests verify preconditions exist but don't show creation

**The documentation gap:**
1. DEWEY creates/selects the issue and should reset to its initial state inside IDLE
2. Main FSM should still remain in IDLE unless the user explicitly asks to begin work
3. Only then should DEWEY reach `_DONE`
4. Only after that should `issue-start` create branch/cleanroom setup
5. Current docs do not clearly encode that sequencing

**Implication:** Precondition creation is split across phases, but the current documentation does not describe that split. ❌

---

## F6: state-encapsulation.md is no longer a canonical spec for IDLE — REVISED

**Finding:**
[docs/spec/state-encapsulation.md](docs/spec/state-encapsulation.md#L122) is stale as a canonical contract, but not every idea inside it is wrong.

What is obsolete:

1. **Operator mismatch**:
  - [docs/spec/state-encapsulation.md](docs/spec/state-encapsulation.md#L128) names ARISTOTLE as the IDLE operator
  - [code/cli/lib/modules/fsm/effect_executor.dart](code/cli/lib/modules/fsm/effect_executor.dart#L36) maps IDLE to DEWEY at runtime

2. **Terminal semantics mismatch**:
  - [docs/spec/state-encapsulation.md](docs/spec/state-encapsulation.md#L144-L152) treats issue confirmation as the path to `_DONE`
  - under the clarified model, issue readiness should reset TRIAGE/DEWEY to its initial state, while `_DONE` is reserved for explicit user intent to begin work

3. **Handoff mismatch**:
  - [docs/spec/state-encapsulation.md](docs/spec/state-encapsulation.md#L152) describes a different terminal handoff shape
  - the current outer FSM uses `start_analyze` as the explicit boundary out of IDLE in [code/cli/assets/fsm/transition_contract.yaml](code/cli/assets/fsm/transition_contract.yaml#L33-L41)

What remains structurally valuable:

1. [docs/spec/state-encapsulation.md](docs/spec/state-encapsulation.md#L124) correctly treats IDLE as an active state, not a waiting room
2. [docs/spec/state-encapsulation.md](docs/spec/state-encapsulation.md#L125) correctly allows staying in IDLE indefinitely while creating/selecting issues
3. The idea that IDLE has internal structure is still useful, but it now belongs in the canonical IDLE contract with the clarified TRIAGE/DONE semantics rather than in this older ARISTOTLE document

**Status:** state-encapsulation.md should be marked as superseded for canonical behavior, while preserving any still-valid architectural intuition.

**Implication:** The risk is not just a naming mismatch. Developers can inherit the wrong operator, the wrong `_DONE` condition, and the wrong handoff semantics if they treat this document as current truth. ❌

---

## F7: The fast path currently exists in DEWEY, but that is the wrong architectural layer — REVISED

**Finding:**
The previous formulation treated the current routing as evidence that Issue #176 was already solved at the right layer. Your architectural clarification changes that conclusion.

Under the intended model:

1. **DEWEY** should carry Deweyan methodology and conversational behavior only
2. **IDLE** as the finite APE machine state should own routing, goals, skills, commands, and explicit fast-path behavior
3. **Inquiry CLI** should orchestrate rich, state-specific prompts so the sub-agent only learns which skill or command applies at prompt-delivery time

The current implementation instead encodes this routing inside DEWEY:

```yaml
evaluate_scope:
  transitions:
    - event: next
      to: search_existing
    - event: skip
      to: create_or_select
```

That means the fast path does exist today, but it exists in the wrong layer. It is architectural leakage from IDLE into DEWEY, not a correct resolution of #176.

**Evidence:**
- [code/cli/assets/apes/dewey.yaml](code/cli/assets/apes/dewey.yaml#L40-L48): currently contains process routing for `search_existing` and `create_or_select`
- [code/cli/assets/fsm/states/idle.yaml](code/cli/assets/fsm/states/idle.yaml#L1-L19): describes IDLE mission and allowed actions, but does not yet own the internal fast-path routing that should live there

**Implication:** F7 is not "routing already exists correctly." The correct finding is that the fast path is currently implemented in DEWEY when it should belong to IDLE. ❌

---

## F8: The fast path has no canonical IDLE-level test coverage — REVISED

**Finding:**
No test currently protects the intended architecture where **IDLE** owns the fast path for explicit create-or-select requests.

There are two separate gaps:

1. There is no test at the canonical layer proving that IDLE can bypass the search path when appropriate
2. Even the current leaked implementation inside DEWEY is not protected by a dedicated transition test

**Search results:**
- 0 test matches for `skip.*dewey` or `skip.*evaluate_scope`
- [code/cli/test/ape_prompt_test.dart](code/cli/test/ape_prompt_test.dart#L132-L145): covers DEWEY prompt loading, not fast-path routing behavior
- [code/cli/test/ape_state_test.dart](code/cli/test/ape_state_test.dart#L72-L79): inspects available events for SOCRATES, not IDLE fast-path execution

**Implication:** #176 is unverified at the layer that should canonically own the behavior, and any test strategy centered only on DEWEY would reinforce the wrong ownership model. ❌

---

## F9: Fast-path trigger criteria are undocumented at the IDLE orchestration layer — REVISED

**Finding:**
The missing specification is not just "what triggers skip in DEWEY." Under the clarified architecture, the real gap is that IDLE and the Inquiry CLI do not yet define:

- when an explicit create-or-select request should bypass search
- how the CLI should enrich the prompt with the relevant objective, skill, and command context
- which parts belong to IDLE orchestration versus Deweyan conversational behavior

Today the only visible trigger surface is the transition leaked into DEWEY, so agents must infer intent from the wrong layer.

**Evidence:**
- [code/cli/assets/apes/dewey.yaml](code/cli/assets/apes/dewey.yaml#L40-L48): currently exposes the fast-path transition but not the orchestration rule
- [code/cli/assets/fsm/states/idle.yaml](code/cli/assets/fsm/states/idle.yaml#L4-L19): does not yet define internal fast-path routing or the orchestration semantics that should live in IDLE

**Implication:** The missing trigger criteria are fundamentally an IDLE/CLI orchestration problem, not a Deweyan methodology problem. ❌

---

## Summary Table

| Finding | Status | Severity | Issue |
|---------|--------|----------|-------|
| F1: Current DEWEY terminal condition does not match the intended IDLE loop | ❌ BROKEN | High | #175 |
| F2: IDLE boundary documentation is fragmented | ❌ BROKEN | High | #175 |
| F3: issue-start invocation is undocumented | ❌ BROKEN | High | #175 |
| F4: Contradiction: who creates GitHub issue | ❌ BROKEN | Critical | #175 |
| F5: Preconditions validated but not created | ❌ BROKEN | Critical | #175 |
| F6: Old spec (ARISTOTLE) vs. current (DEWEY) | ⚠️ STALE | Medium | #175 |
| F7: Fast path is encoded in DEWEY instead of IDLE | ❌ BROKEN | High | #176 |
| F8: Fast path lacks canonical IDLE-level test coverage | ❌ BROKEN | Medium | #176 |
| F9: Fast-path trigger criteria are undocumented at the IDLE layer | ❌ BROKEN | Medium | #176 |
