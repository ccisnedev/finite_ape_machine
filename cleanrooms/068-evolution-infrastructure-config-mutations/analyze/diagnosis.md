---
id: diagnosis
title: "EVOLUTION infrastructure: declarative/imperative boundary and config routing"
date: 2026-04-18
status: draft
tags: [evolution, config, mutations, fsm, architecture]
author: SOCRATES
---

# Diagnosis — Issue #68: EVOLUTION Infrastructure

## 1. Problem Defined

The EVOLUTION state exists in the FSM contract and `fsm_contract.dart`, but has no runtime infrastructure. Specifically:

1. `.ape/config.yaml` is never created — no mechanism to enable/disable EVOLUTION
2. `.ape/mutations.md` (human scratchpad for DARWIN) doesn't exist
3. No lifecycle management for mutations.md across FSM cycles
4. DARWIN prompt references artifacts that aren't managed

The issue proposes adding both files to `ape init` and managing mutations.md lifecycle through transition effects.

## 2. Key Architectural Tension: Declarative vs Imperative

### 2.1 Current Architecture

The codebase has a clear but undocumented separation of concerns:

| Component | Behavior | Evidence |
|-----------|----------|----------|
| `init.dart` | **Imperative** — creates files on disk | `_ensureStateYaml()`, `_ensureGitignore()` directly write files |
| `transition.dart` | **Declarative** — validates and returns effects | `execute()` returns `StateTransitionOutput` with `operationsExecuted` list but writes nothing |
| Agent (APE scheduler) | **Imperative** — executes effects | Reads transition output and performs actions (implicit, not in CLI code) |

The `transition.dart` `execute()` method (lines 100–170) reads the contract, checks preconditions, and returns an output containing the effects list. It does NOT:
- Write to `state.yaml`
- Execute any effects listed in the transition
- Modify any file on disk

The effects field (`effects: [open_analysis_context]`, `effects: [finalize_execution]`, etc.) are **string labels** returned to the caller. The APE scheduler is responsible for interpreting and executing them.

### 2.2 The Tension

The issue proposes `reset_mutations` as a transition effect in the contract. Given the current architecture:

- **If `reset_mutations` is a declarative effect**: The CLI adds the string to the transition output. The agent reads it and performs the file reset. The CLI never touches mutations.md (beyond init creating it). This is consistent with the existing architecture.

- **If the CLI should execute `reset_mutations`**: That means `transition.dart` gains imperative behavior — writing files as a side effect of validation. This breaks the current separation where the CLI is a pure query.

**Decision required:** Should the CLI remain a pure query (declarative) or gain side effects (imperative)?

### 2.3 Analysis of Options

**Option A: CLI stays declarative (recommended)**

- `transition.dart` continues to return effects as strings
- `reset_mutations` is just another effect label in the contract
- The agent reads the effect list and calls appropriate actions
- Consistent with existing architecture — no refactor needed
- Risk: the agent must correctly implement every effect; there's no CLI-side guarantee

**Option B: CLI becomes imperative**

- `transition.dart` gains a "post-validation" phase that executes effects
- Requires reading config.yaml, writing mutations.md, etc.
- Breaks the current pure-query design
- Creates coupling between the CLI and file management
- Benefit: effects are guaranteed to execute — no reliance on agent implementation

**Option C: New imperative commands**

- Add commands like `ape state reset-mutations`, `ape state write-state`
- The agent calls these commands after reading the transition output
- CLI gains imperative capabilities but in separate commands, not in transition
- Maintains separation: transition = query, new commands = mutations
- Risk: proliferation of small commands

## 3. The Config Routing Problem

### 3.1 Current Contract

The transition contract hardcodes:

```yaml
- from: EXECUTE
  event: finish_execute
  to: EVOLUTION
  allowed: true
```

There is exactly one path from EXECUTE: `finish_execute → EVOLUTION`. There is no `finish_execute → IDLE` alternative.

### 3.2 The Routing Question

If `config.yaml` contains `evolution.enabled: false`, what happens?

**Sub-question A: Does the contract support conditional transitions?**

No. `FsmTransition` maps `(FsmState, FsmEvent) → FsmTransition` as a 1:1 lookup. There is no mechanism for runtime conditions on transitions. Adding one would be a significant architectural change to `fsm_contract.dart` and the contract YAML schema.

**Sub-question B: Can the agent choose a different event?**

The agent could read `config.yaml` and:
- If `evolution.enabled: true` → send `finish_execute` (→ EVOLUTION)
- If `evolution.enabled: false` → send `block` (→ IDLE, but semantically wrong)

This is a workaround, not a design. `block` means "pause/interrupt", not "skip EVOLUTION".

**Sub-question C: Should a new event exist?**

A `skip_evolution` event from EXECUTE → IDLE would cleanly express the intent:
- `finish_execute` → EVOLUTION (evolution enabled)
- `skip_evolution` → IDLE (evolution disabled)

This requires adding a new event to the contract, which means updating:
- `transition_contract.yaml` (new event + 5 × ILLEGAL entries for other states)
- `FsmEvent` enum in `fsm_contract.dart`
- Test matrix (grows from 5×7=35 to 5×8=40 entries)

**Sub-question D: Does this depend on Issue #67 (END state)?**

The issue body says config.yaml is "Read by APE scheduler at END state." But END state is proposed in issue #67 and does not exist. Two paths:

1. **Implement #68 without #67**: Use current EXECUTE → EVOLUTION path. Config.yaml is read by the agent at EXECUTE completion. No END state needed yet.
2. **Wait for #67**: Implement config.yaml routing alongside END state. Cleaner design but creates a dependency chain.

### 3.3 Recommendation

Implement config.yaml creation in `ape init` now (no dependency on #67). The routing decision (who reads config.yaml and what event to emit) can be deferred to #67 or a follow-up issue. The config file's existence is orthogonal to who reads it.

## 4. mutations.md Lifecycle Analysis

### 4.1 Proposed Lifecycle

```
ANALYZE (start)   → create/reset mutations.md
ANALYZE..EXECUTE  → human writes observations
EVOLUTION         → DARWIN reads, then cleans
IDLE              → mutations.md exists but empty
```

### 4.2 Questions

**Q1: What happens when EVOLUTION is disabled?**

If `evolution.enabled: false`, DARWIN does not run and mutations.md is not read. However, it IS cleaned at the next ANALYZE start (`reset_mutations` effect). There is no indefinite accumulation — each new cycle resets it.

**Clarification from user:** "Evolution no lo lee, pero sí lo limpia." When EVOLUTION is disabled, the notes simply wait unused until the next ANALYZE resets them.

**Q2: Is "reset at ANALYZE start" correct?**

The lifecycle says mutations.md is reset when ANALYZE begins. But what if the user writes mutations during IDLE (before ANALYZE)? Those notes are lost.

Counter-argument: IDLE is "no active cycle", so observations during IDLE have no cycle context. Resetting at ANALYZE is correct because it marks the start of a new cycle.

**Q3: Does DARWIN actually need mutations.md?**

The existing artifacts available to DARWIN are:
- `diagnosis.md` (analysis output — about the issue)
- `plan.md` (planning output — about the issue)
- `retrospective.md` (execution output — about the issue)

**Clarification from user:** These artifacts are all about the issue being worked on. `mutations.md` is about **APE's own performance** — its subagents, skills, ape.exe, etc. It's the human→DARWIN channel for process observations, not issue observations.

Examples of mutations.md content:
- "SOCRATES asked too many questions before acting"
- "The plan was too granular for a simple refactor"
- "BASHŌ should run tests before committing"
- "The issue-start skill missed a step"

**Q4: Should mutations.md be a managed artifact or a convention?**

- **Managed**: CLI creates it, resets it at transitions, validates its existence
- **Convention**: Documented in ape.agent.md, humans create/manage it, DARWIN reads it if it exists

A convention approach is lighter and doesn't require CLI changes beyond init.

### 4.3 Recommendation

Start with the minimal approach:
1. `ape init` creates mutations.md with header template (imperative, consistent with init pattern)
2. Add `reset_mutations` as a declarative effect in the contract for `start_analyze` transitions
3. The agent interprets `reset_mutations` and overwrites mutations.md with the header template
4. If EVOLUTION is disabled, mutations.md is reset at next ANALYZE anyway — no indefinite accumulation

## 5. Scope

### In Scope

| Item | Rationale |
|------|-----------|
| `ape init` creates `.ape/config.yaml` | Core requirement, imperative (consistent with init pattern) |
| `ape init` creates `.ape/mutations.md` | Core requirement, imperative |
| Idempotency for both files | Consistent with existing init behavior |
| `reset_mutations` effect in contract | Declarative label for agent to interpret |
| Contract entry for `evolution.enabled` config | Schema definition only |
| Tests for init changes | Required |
| DARWIN prompt update in `ape.agent.md` | Add mutations.md to DARWIN input list |
| `finish_evolution` adds `reset_mutations` effect | Clean mutations.md after DARWIN reads it |

### Out of Scope

| Item | Rationale |
|------|-----------|
| END state (#63) | Separate issue, not a dependency for config/mutations creation |
| Routing logic (who reads config.yaml) | Depends on #63 or follow-up |
| `skip_evolution` event | Requires #63 context for clean design |
| Agent-side effect execution | Agent is outside CLI codebase |
| Imperative mutation commands (Option C) | Premature — evaluate after #63 |

**Note:** Everything in `.ape/` is gitignored. config.yaml is local per-developer configuration, not project-level.

### Deferred (explicit)

| Item | Defer To |
|------|----------|
| Config.yaml routing decision | #67 (END state) |
| Conditional transitions in contract | Architecture decision, separate issue |
| mutations.md consumption by DARWIN | Agent-side implementation |

## 6. Constraints and Risks

### C1: Declarative/Imperative Consistency

The CLI must not gain imperative side effects in `transition.dart`. If mutations.md needs runtime management beyond init, it should be through the agent interpreting declarative effects, not through the CLI executing them. Violating this creates two imperative paths (init + transition) with no clear boundary.

### C2: Contract Schema Stability

Adding `reset_mutations` as an effect is safe — effects are opaque strings. But adding conditional transitions or new events has matrix implications (total matrix assertion in `assertMatrixIsTotal()`). Any new event requires N×1 new entries (one per state).

### C3: Dependency Risk with #67

If #68 is implemented without #67, the routing question remains open. The config.yaml file will exist but no one reads it programmatically. This is acceptable only if the follow-up is tracked explicitly.

### C4: Test Isolation

Current tests use temp directories and write state/context files manually. New tests for config.yaml and mutations.md must follow the same pattern. No test should depend on the real `.ape/` directory.

## 7. Decisions Taken

### D1: CLI remains declarative for transition effects

`transition.dart` does not gain side effects. `reset_mutations` is a string label in the contract, interpreted by the agent. Justification: consistency with existing architecture (§2.1).

### D2: `ape init` creates config.yaml and mutations.md (imperative)

Both files are created by init.dart with idempotent semantics (don't overwrite if exists). This is consistent with the existing pattern for state.yaml. Justification: init is already imperative (§2.1).

### D3: config.yaml routing is deferred to #67

The file is created but the routing decision (who reads it, what event to emit) is deferred. Justification: clean routing requires END state or new events, both of which are #67 scope (§3.3).

### D4: `reset_mutations` added as declarative effect

Added to `start_analyze` transitions (IDLE→ANALYZE, ANALYZE→ANALYZE, PLAN→ANALYZE, EXECUTE→ANALYZE). The contract declares it; the agent executes it. Justification: consistent with existing effect pattern (§4.3).

### D5: No new events or conditional transitions

The contract schema is not extended with conditional logic or new events. This avoids matrix expansion and keeps the issue focused. Justification: scope control (§5).

## 8. References

- [init.dart](../../../../code/cli/lib/modules/global/commands/init.dart) — current imperative init implementation
- [transition.dart](../../../../code/cli/lib/modules/state/commands/transition.dart) — declarative transition command
- [transition_contract.yaml](../../../../code/cli/assets/fsm/transition_contract.yaml) — FSM contract with effects
- [fsm_contract.dart](../../../../code/cli/lib/fsm_contract.dart) — contract parser and types
- [state-persistence.md](../../021-ape-structure/analyze/state-persistence.md) — state.yaml as reconstructible cache
- [diagnosis.md (issue #44)](../../044-fsm-fix-linux-support-crossplatform-audit/analyze/diagnosis.md) — D5: END state + EVOLUTION optional
- Issue #67 — Add END state to FSM transition contract (dependency for routing)
