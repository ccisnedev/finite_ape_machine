---
id: diagnosis-175-176
title: "IDLE Contract & Routing — Rigorous Diagnosis"
date: 2026-05-08
status: active
tags: [idle, dewey, issue-start, handoff, routing, contract]
author: socrates
references:
  - code/cli/assets/apes/dewey.yaml
  - code/cli/assets/fsm/states/idle.yaml
  - code/cli/assets/agents/inquiry.agent.md
  - docs/spec/agent-lifecycle.md
  - docs/spec/cooperative-multitasking-model.md
  - code/cli/assets/fsm/transition_contract.yaml
issue: [175, 176]
---

# IDLE Contract & Routing — Rigorous Diagnosis

## Executive Summary

Two related issues reveal systematic documentation and implementation gaps in the IDLE state:

| Issue | Problem | Type | Severity |
|-------|---------|------|----------|
| #175 | DEWEY terminal semantics are wrong and the canonical IDLE model is not centralized in transition_contract.yaml + idle.yaml | Documentation + Contract | High |
| #176 | Fast-path routing for explicit create-or-select requests is encoded in DEWEY instead of IDLE, and lacks canonical IDLE-level tests/spec | Architecture + Testing + Documentation | Medium |

The root causes are:
1. **Wrong terminal semantics in the current asset**: DEWEY uses `confirm -> _DONE` where the intended model requires a reset to initial triage state after issue readiness
2. **Missing canonicalization**: transition_contract.yaml and idle.yaml do not together encode the full intended IDLE behavior
3. **Collapse of two boundaries**: the docs blur together issue readiness and explicit start intent
4. **Misplaced routing**: the fast path for explicit create-or-select requests is encoded in DEWEY instead of the IDLE finite APE machine
5. **Unprotected orchestration**: the fast path has no canonical IDLE-level test coverage or trigger specification

## Problem Definition: Issue #175

### What is Currently Wrong

**The canonical IDLE behavior is not encoded in the two files that should define it:**

1. **DEWEY contract (asset level)** currently encodes the wrong consequence for issue readiness:
   ```yaml
   confirm:
     transitions:
       - event: complete
         to: _DONE
   ```
    ← Under the intended model, creating/selecting an issue should not send DEWEY to `_DONE`; it should reset DEWEY to its initial state so IDLE can immediately triage the next situation.

2. **transition_contract.yaml** correctly models the main FSM edge out of IDLE, but only at that outer level:
   ```yaml
   - from: IDLE
     event: start_analyze
     to: ANALYZE
   ```
   ← This says how the main FSM leaves IDLE. It does not describe how IDLE behaves internally before that event exists.

3. **idle.yaml** should define the internal semantics of IDLE, but currently does not:
   ```yaml
   instructions: |
     Evaluate what work merits inquiry. Understand the problem,
     search for existing issues, create or select an issue.
   ```
   ← This gives mission-level prose, but it does not define TRIAGE vs DONE, DEWEY reset-on-issue-ready, or the explicit trigger for issue-start.

4. **Narrative documents** still carry behavior that should be canonical in runtime assets:
   ```markdown
   DEWEY does not create branches, write diagnosis, plan work, or code.
   The explicit handoff remains external: `issue-start` ...
   ```
   ← Narrative docs are compensating for behavior that should be explicit in transition_contract.yaml + idle.yaml.

### The Specification Gap

**Question 1: What should happen when DEWEY creates or confirms an issue?**
- Answer under the intended model: DEWEY should finish that triage conversation and reset to its initial state.
- Problem: the current asset instead sends DEWEY to `_DONE`.

**Question 2: When should DEWEY reach `_DONE`?**
- Answer under the intended model: only when the user explicitly says they want to begin resolving an issue.
- Problem: the current asset uses `_DONE` for issue readiness instead.

**Question 3: Which file should define the main FSM exit from IDLE?**
- Answer: transition_contract.yaml.
- Problem: it currently defines the outer edge, but the surrounding docs still carry too much semantic weight for canonical behavior.

**Question 4: Which file should define the internal semantics of IDLE?**
- Answer: idle.yaml.
- Problem: it currently does not define the internal TRIAGE/DONE model clearly enough.

**Question 5: Where should the use of issue-start be described canonically?**
- Answer: in idle.yaml, as part of the semantics of DONE inside IDLE.
- Problem: issue-start exists as a skill document, but idle.yaml does not yet define that DONE consumes it and hands off to ANALYZE.

### Impact on Developers

**Scenario: A developer reading DEWEY.yaml to understand IDLE**
1. Reads DEWEY.yaml, sees confirm → _DONE
2. Asks: "Does issue creation finish DEWEY?"
3. Checks idle.yaml, finds mission prose but not the internal state semantics
4. Checks transition_contract.yaml, finds only the outer FSM edge
5. Must infer the missing loop behavior from surrounding docs or discussion
6. **Result:** High risk of implementing `_DONE` too early and triggering operational handoff prematurely

**Scenario: A developer integrating a new agent into IDLE**
1. Assumes issue readiness should end the DEWEY FSM
2. Encodes `_DONE` on issue creation/selection
3. Prevents DEWEY from immediately returning to the initial triage state
4. **Result:** The system loses the intended conversational loop inside IDLE and becomes operational too early

## Problem Definition: Issue #176

### What is Currently Wrong

**The fast path exists today, but in the wrong layer and without canonical protection:**

1. **Routing is currently encoded in DEWEY.yaml:**
   ```yaml
   evaluate_scope:
     transitions:
       - event: skip
         to: create_or_select
   ```
   ← Under the clarified architecture, this is not a success condition. It is evidence that process routing leaked into the methodology layer.

2. **IDLE should own this behavior instead:**
   - IDLE as the finite APE machine should decide when explicit create-or-select intent bypasses search
   - DEWEY should carry methodology/behavior, not process-specific routing, skills, or command knowledge

3. **Because the behavior lives in the wrong layer, it is also unprotected:**
   - there is no canonical IDLE-level test for the fast path
   - there is no canonical IDLE-level trigger specification
   - any DEWEY-only fix would reinforce the wrong ownership boundary

### The Specification Gap

**Question 1: Which layer should own the fast path?**
- Answer: IDLE, not DEWEY
- Impact: keeping it in DEWEY leaks process knowledge into the methodology layer

**Question 2: How should the sub-agent learn that the fast path applies?**
- Answer: Inquiry CLI should enrich the IDLE prompt with the relevant objective, skill, and command context
- Impact: if this stays implicit in DEWEY, the sub-agent must infer orchestration rules from the wrong artifact

**Question 3: What should the test surface protect?**
- Answer: the canonical IDLE fast path and its orchestration boundary
- Impact: DEWEY-only tests would validate an implementation detail that should move out of DEWEY

### Impact on Developers

**Scenario: A developer implementing explicit create_or_select requests from the current assets**
1. Reads Issue #176 requirement: "explicit create_or_select requests avoid unnecessary latency"
2. Checks DEWEY.yaml, sees skip event
3. Concludes that DEWEY should own the routing decision
4. Adds more process-aware logic to the methodology layer
5. Deepens the architectural leak instead of fixing it
6. **Result:** the fast path may work locally, but ownership remains wrong and future orchestration becomes harder to centralize in IDLE

## Key Decisions Required

### Decision 1: Centralize IDLE Boundary Documentation

User clarification on 2026-05-08 resolves the intended model:

- DEWEY/IDLE converses, scopes, splits, and creates/selects issue(s)
- after triage output exists, DEWEY resets to its initial state and the main FSM remains in IDLE by default
- DEWEY reaches `_DONE` only on explicit user intent to begin work on a chosen issue
- only then does `issue-start` prepare branch/cleanroom setup and fire `start_analyze`
- transition_contract.yaml is the canonical source for the main FSM edge out of IDLE
- idle.yaml is the canonical source for the internal behavior of IDLE

**Two options:**

#### Option A: Make transition_contract.yaml + idle.yaml the only normative pair for IDLE behavior
```yaml
transition_contract.yaml
  - defines that the only outer transition from IDLE to ANALYZE is start_analyze
  - keeps all other main-FSM transitions illegal unless explicitly allowed

idle.yaml
  - defines internal IDLE states: TRIAGE and DONE
  - defines that TRIAGE dispatches DEWEY
  - defines that issue readiness resets TRIAGE/DEWEY to the initial state
  - defines that only explicit start intent moves IDLE to DONE
  - defines that DONE consumes issue-start and hands off to ANALYZE
```

**Pros:**
- Clear division of responsibility between outer FSM and inner state semantics
- Removes ambiguity about where canonical behavior lives
- Makes explanatory docs secondary instead of normative

**Cons:**
- Requires rewriting idle.yaml beyond mission prose
- Requires other docs to be demoted to explanatory status

#### Option B: Keep DEWEY.yaml as the primary semantic source for IDLE behavior
```yaml
dewey.yaml
  - directly defines the loop semantics and terminal behavior
```

**Pros:**
- Keeps behavior close to the sub-agent definition

**Cons:**
- Conflicts with the clarified requirement that idle.yaml should be the canonical source for IDLE behavior
- Leaves the main IDLE state under-described

### Decision 2: Clarify issue-start Invocation Responsibility

The clarified trigger is now known: `issue-start` should run only after explicit user intent to begin work on an already selected or created issue.

**Three options:**

#### Option A: Encode in idle.yaml that DONE automatically consumes issue-start after explicit user start intent
Modify inquiry.agent.md so that after the user explicitly asks to begin work, the scheduler:
1. Calls `iq ape issue-start`
2. Then calls `iq fsm transition --event start_analyze`

**Pros:**
- Single clear trigger point
- Respects the default behavior of staying in IDLE after triage
- Guarantees issue/branch exist before FSM transition

**Cons:**
- Adds operational logic to firmware (should firmware invoke skills?)
- Requires an explicit start-intent detection rule

#### Option B: Describe the same behavior only in inquiry.agent.md and leave idle.yaml high-level
After the user says they want to begin work on an issue, explicitly instruct the scheduler to run issue-start.

**Pros:**
- Clear responsibility assignment
- Explicit in firmware
- Easier to test (can verify explicit start intent invokes issue-start)

**Cons:**
- Requires agent participation in operational workflow
- Conflicts with the clarified requirement that idle.yaml should be the canonical place where this behavior is described
- Adds complexity to inner loop

#### Option C: Leave issue-start implicit after user start intent
Leave it implicit that the user (or agent) should invoke issue-start after deciding to begin work.

**Pros:**
- Minimal firmware changes

**Cons:**
- Most error-prone (users forget)
- Leads to unclear error messages when preconditions fail
- **Not recommended**

### Decision 3: Clarify GitHub Issue Creation Responsibility

User clarification resolves the intended ownership:

- IDLE contains the internal substate TRIAGE
- TRIAGE delegates to DEWEY for Deweyan methodology
- when TRIAGE determines that an issue must be created or confirmed, it should consume a deterministic skill for that purpose
- issue-start does not own issue creation as its primary purpose
- issue-start verifies the chosen issue and prepares operational setup for ANALYZE

**Two options:**

#### Option A: Introduce an issue-create skill and remove issue creation from issue-start
Modify the skill model to explicitly state:
```
TRIAGE:
   - decides whether an issue must be created or confirmed
   - consumes issue-create to run deterministic gh commands, templates, labels, and metadata

issue-start:
   - assumes the issue is already selected or created
   - verifies that issue
   - creates branch and workspace
   - fires start_analyze
```

**Pros:**
- Matches the clarified product model
- Preserves separation between triage and operational setup
- Keeps issue creation inside IDLE where the user is still clarifying scope
- Makes GitHub-side side effects deterministic and guided by the CLI instead of freeform LLM behavior
- Leaves DEWEY.yaml focused on Deweyan methodology rather than command details

**Cons:**
- Requires a new skill asset and related documentation
- Requires spec/docs updates where issue-start is still described as issue creator

#### Option B: Keep the old spec model where issue-start creates the issue
This would preserve the current wording in agent-lifecycle.md, but it conflicts with the clarified product definition.

**Pros:**
- Minimal spec churn if the product definition were rejected

**Cons:**
- Contradicts the clarified intended behavior
- Keeps triage completion and operational start entangled

**Naming note:** the repository's existing skill naming convention is object-first (`issue-start`, `issue-end`, `doc-read`, `doc-write`). Under that convention, `issue-create` is the more consistent name than `create-issue`.

### Decision 4: Move fast-path ownership to IDLE and document the trigger there

**Required changes:**

1. **Add fast-path specification to IDLE, not DEWEY:**
   ```yaml
    idle:
       triage_behavior: |
          If the user's intent is already explicit enough to create or select an issue,
          IDLE may bypass the search path and enter the create-or-select path directly.

          Inquiry CLI is responsible for delivering the prompt context that tells the
          sub-agent which objective, skill, and command surface apply.
   ```

2. **Add test case at the canonical layer:**
   ```dart
    test('IDLE fast path bypasses search for explicit create-or-select intent', () async {
       // Setup: IDLE triage with explicit create-or-select request
     // User message: "I've already checked for related issues. Let's create this one."
       // Verify: IDLE takes create-or-select path instead of search path
       // Verify: orchestration context is delivered without teaching process routing to DEWEY
   });
   ```

3. **Keep DEWEY methodology-only:**
   ```
    DEWEY should not be the canonical owner of finite-process routing,
    skill selection, or command knowledge.
   ```

## Constraints and Risks

### Technical Constraints

1. **State Encapsulation Principle** (Issue #152):
   - No FSM state should know that other states exist
   - Any documentation added to DEWEY.yaml should avoid mentioning downstream states by name unless the project explicitly accepts that exception
   - Use generic language like "next phase" instead of explicit state names

2. **Asset Packaging**:
   - Changes to code/cli/assets/*.yaml must be mirrored in code/cli/build/assets/
   - CLI binary must reload assets to reflect changes
   - Tests must validate packaged assets match source

3. **CLI Command Compatibility**:
   - Any firmware changes to inquiry.agent.md must not break existing `iq` commands
   - Precondition validation in StateTransitionCommand must remain unchanged (it's working)
   - issue-start SKILL.md changes must not break existing workflows

### Documentation Risks

1. **Spec Staleness**:
   - state-encapsulation.md is stale as a canonical IDLE contract
   - Its obsolete parts are the ARISTOTLE operator, terminal `_DONE` semantics, and handoff wording
   - Its useful parts are the idea that IDLE is active and may stay in triage indefinitely
   - Developers reading it as current truth will be confused unless it is explicitly marked superseded

2. **Agent-Centric vs. Spec-Centric**:
   - agent-lifecycle.md is the authoritative spec
   - But assets (DEWEY.yaml, idle.yaml) are the runtime contract
   - These two must stay synchronized

3. **Backward Compatibility**:
   - Any changes to IDLE boundary or handoff must not break existing issue-start usage
   - Existing cleanroom cycles may rely on current (implicit) behavior

## Recommended Implementation Order

### Phase 1: Clarification (Spec-only, no code changes)

1. **Supersede and annotate state-encapsulation.md**:
   - Add frontmatter such as `status: superseded` or `superseded_by: agent-lifecycle.md`
   - Add note that the document preserves older ARISTOTLE/TRIAGE thinking and some still-useful IDLE intuition, but it is no longer the canonical runtime contract
   - Explicitly warn that its operator, `_DONE` semantics, and handoff model are outdated

2. **Expand agent-lifecycle.md** with IDLE boundary details:
   - Section: "IDLE triage loop vs explicit work start"
   - Explicitly state: "DEWEY/IDLE is responsible for issue selection or creation"
   - Explicitly state: "issue readiness resets DEWEY to its initial state inside IDLE"
   - Explicitly state: "issue-start SKILL.md is responsible for verification of the chosen issue and operational setup"
   - Explicitly state: "issue-start SKILL.md is responsible for feature branch creation"
   - Explicitly state: "issue-start SKILL.md fires start_analyze event"
   - Mark this doc as explanatory, not canonical, for runtime behavior

3. **Expand cooperative-multitasking-model.md** with confirmation gate details:
   - Clarify: "When DEWEY creates or confirms an issue, it resets to the initial triage state"
   - Clarify: "Only explicit user intent sends DEWEY to _DONE and invokes issue-start + start_analyze"
   - Mark this doc as architectural explanation, not normative runtime contract

### Phase 2: Asset Documentation (Non-breaking)

1. **Update idle.yaml**:
   ```yaml
    internal_states:
       - TRIAGE
       - DONE

    triage_behavior: |
       TRIAGE dispatches DEWEY.
       If an issue is created or confirmed, DEWEY returns to its initial state and
       IDLE remains in TRIAGE by default.

    done_trigger: |
       DONE is reached only when the user explicitly asks to begin resolving an issue.

    done_effect: |
       DONE consumes issue-start, which prepares infrastructure and fires start_analyze.
   ```

 2. **Keep DEWEY.yaml aligned but subordinate to idle.yaml**:
    - DEWEY.yaml should reflect the loop semantics
    - But idle.yaml should be treated as the canonical source for IDLE behavior

### Phase 3: Test Coverage (Non-breaking)

1. **Add test for the IDLE fast path**:
   - prefer a test that protects the canonical IDLE-layer routing rather than a DEWEY-only transition test

2. **Add test for IDLE→ANALYZE with issue/branch**:
   - Ensure explicit user start intent is required before the handoff path is taken

3. **Add integration test for full IDLE cycle** (existing coverage):
   - Verify issue readiness loops DEWEY back to its initial state while staying in IDLE
   - Verify explicit start intent triggers DEWEY `_DONE` then issue-start → ANALYZE

### Phase 4: skill/issue-start Clarification (Non-breaking)

1. **Update issue-start SKILL.md**:
   - Step 2: "Verify selected GitHub issue"
   - Clarify precondition: the issue should already have been selected or created during IDLE
   - Clarify responsibility: issue-start handles operational setup, not default triage output creation

2. **Update idle.yaml allowed_actions**:
   - Preserve clear ownership that GitHub issue creation belongs to IDLE/DEWEY during triage

## References

| Artifact | Purpose | Current State |
|----------|---------|---------------|
| [code/cli/assets/apes/dewey.yaml](code/cli/assets/apes/dewey.yaml) | Runtime DEWEY contract | Incorrect terminal condition for the intended loop; also currently carries fast-path process routing that should live in IDLE |
| [code/cli/assets/fsm/states/idle.yaml](code/cli/assets/fsm/states/idle.yaml) | Canonical internal IDLE contract | Incomplete (does not yet model TRIAGE/DONE or reset-after-issue-ready) |
| [code/cli/assets/agents/inquiry.agent.md](code/cli/assets/agents/inquiry.agent.md) | Runtime firmware | Mentions completion gate but not explicit start-intent trigger |
| [docs/spec/agent-lifecycle.md](docs/spec/agent-lifecycle.md) | Explanatory spec | Should align to assets, not define canonical runtime behavior |
| [docs/spec/cooperative-multitasking-model.md](docs/spec/cooperative-multitasking-model.md) | Explanatory architecture | Should align to assets, not define canonical runtime behavior |
| [code/cli/assets/fsm/transition_contract.yaml](code/cli/assets/fsm/transition_contract.yaml) | FSM contract | Validates preconditions but doesn't create |
| [code/cli/assets/skills/issue-start/SKILL.md](code/cli/assets/skills/issue-start/SKILL.md) | Operational skill | Assumes issue exists, but still needs explicit trigger semantics |
| [docs/spec/state-encapsulation.md](docs/spec/state-encapsulation.md) | Historical design note | Contains useful IDLE-active-state intuition, but obsolete operator/handoff/terminal semantics |

## Conclusion

Issues #175 and #176 reveal a systematic contract gap: the current assets do not centralize the intended IDLE behavior in the two places that should define it. transition_contract.yaml should define the outer FSM edge out of IDLE. idle.yaml should define the internal behavior of IDLE. Today that split is not explicit enough, and the missing semantics leak into explanatory docs.

**Core issue:** IDLE boundary is a **two-boundary, three-layer problem**:
1. **Outer FSM boundary**: only `start_analyze` should move the main FSM out of IDLE
2. **Inner IDLE boundary**: issue readiness should reset TRIAGE; explicit start intent should move IDLE to DONE
3. **Asset layer**: transition_contract.yaml and idle.yaml do not yet encode this split completely
4. **Firmware layer** (inquiry.agent.md): completion gate exists but explicit start trigger is not encoded
5. **Explanatory spec layer**: still carries behavior that should be canonical in assets

The solution is to make transition_contract.yaml and idle.yaml the normative pair for IDLE behavior, then align the explanatory docs behind them.

**Severity:** High for #175 (affects IDLE boundary clarity), Medium for #176 (fast path exists in the wrong layer and lacks canonical protection).

**Effort:** Mostly documentation + test coverage; no breaking changes required.
