---
id: plan
title: "EVOLUTION infrastructure: config.yaml + mutations.md lifecycle"
date: 2026-04-18
status: approved
tags: [evolution, config, mutations, fsm, init]
author: DESCARTES
---

# Plan — Issue #68: EVOLUTION Infrastructure

## Hypothesis

If we add two new files to `ape init` (config.yaml, mutations.md), declare `reset_mutations` as an effect in the transition contract, and update the DARWIN prompt, we will have the minimum infrastructure for EVOLUTION without breaking the declarative/imperative boundary.

## Verified Assumptions (from diagnosis)

1. `init.dart` is imperative: `_ensureGitignore()`, `_ensureStateYaml()` write files directly. New `_ensure*` methods follow the same pattern. ✓
2. `transition.dart` is declarative: returns effects as strings, never writes to disk. `reset_mutations` is just another string label. ✓
3. IDLE→ANALYZE effects are currently `[open_analysis_context]`. Adding `reset_mutations` extends the array. ✓
4. EVOLUTION→IDLE effects are currently `[close_cycle]`. Adding `reset_mutations` extends the array. ✓
5. DARWIN prompt (line 452 of ape.agent.md) lists inputs: diagnosis.md, plan.md, retrospective.md, commit history. mutations.md is absent. ✓
6. Init doc comment says "Five idempotent steps" — must become "Seven". ✓
7. `assertMatrixIsTotal()` validates state×event coverage, not effects content. Adding effects doesn't break existing matrix tests. ✓

---

## Phase 1 — Contract: declare `reset_mutations` effect

**File:** `code/cli/assets/fsm/transition_contract.yaml`

Smallest change. No code logic — only YAML edits to existing transitions.

- [x] 1.1 IDLE→ANALYZE (`start_analyze`): change `effects: [open_analysis_context]` → `effects: [open_analysis_context, reset_mutations]`
- [x] 1.2 EVOLUTION→IDLE (`finish_evolution`): change `effects: [close_cycle]` → `effects: [close_cycle, reset_mutations]`

**Risk:** None. Effects are opaque strings. Existing tests validate transition structure (from/to/allowed), not effect content.

---

## Phase 2 — Agent prompt: add mutations.md to DARWIN input

**File:** `code/cli/assets/agents/ape.agent.md`

Documentation-only change. No runtime impact.

- [x] 2.1 In DARWIN prompt `## Input` section (~line 470), add bullet: `- .ape/mutations.md (human observations about APE's process performance during this cycle)`
- [x] 2.2 In EVOLUTION state description (~line 155), add note: "DARWIN reads `.ape/mutations.md` for human observations about APE's process performance."

**Risk:** None. Agent prompt is read by the LLM at runtime — no compilation, no parsing.

---

## Phase 3 — Init: create config.yaml and mutations.md

**File:** `code/cli/lib/modules/global/commands/init.dart`

Two new `_ensure*` methods following the exact pattern of `_ensureStateYaml()`.

- [x] 3.1 Add `_ensureConfigYaml(String root, List<String> steps)`:
  - Path: `$root/.ape/config.yaml`
  - Guard: `if (!configFile.existsSync())`
  - Content:
    ```yaml
    evolution:
      enabled: false
    ```
  - Append step message: `'Created .ape/config.yaml'`

- [x] 3.2 Add `_ensureMutationsMd(String root, List<String> steps)`:
  - Path: `$root/.ape/mutations.md`
  - Guard: `if (!mutationsFile.existsSync())`
  - Content:
    ```markdown
    # Mutations

    Notes for DARWIN. Write observations about the current cycle here.
    This file is read during EVOLUTION and cleared afterwards.
    ```
  - Append step message: `'Created .ape/mutations.md'`

- [x] 3.3 Call both methods from `execute()`, after `_ensureStateYaml(root, steps)`:
  ```dart
  // Step 5: Create .ape/config.yaml with defaults
  _ensureConfigYaml(root, steps);

  // Step 6: Create .ape/mutations.md with header template
  _ensureMutationsMd(root, steps);
  ```

- [x] 3.4 Update doc comment: "Five idempotent steps" → "Seven idempotent steps", add steps 5 and 6 to list

**Risk:** `.ape/` directory might not exist if state.yaml was already present (created in a prior init run). Mitigation: `_ensureStateYaml` already creates `.ape/` dir — the new methods must also guard `apeDir.existsSync()` or rely on the fact that step 4 always runs first. Since step 4 guarantees `.ape/` exists (either created or pre-existing), steps 5-6 can assume the directory exists. Verify this assumption in tests.

---

## Phase 4 — Tests: validate init changes

**File:** `code/cli/test/init_command_test.dart`

Four new tests in existing test file, following the temp directory pattern.

- [x] 4.1 Test: creates `.ape/config.yaml` with correct content
  ```
  arrange: empty tempDir
  act:     InitCommand(tempDir).execute()
  assert:  File('.ape/config.yaml').existsSync() == true
           content contains 'evolution:'
           content contains 'enabled: false'
  ```

- [x] 4.2 Test: creates `.ape/mutations.md` with header template
  ```
  arrange: empty tempDir
  act:     InitCommand(tempDir).execute()
  assert:  File('.ape/mutations.md').existsSync() == true
           content contains '# Mutations'
           content contains 'Notes for DARWIN'
  ```

- [x] 4.3 Test: idempotent — does not overwrite existing config.yaml
  ```
  arrange: create .ape/config.yaml with 'evolution:\n  enabled: true\n'
  act:     InitCommand(tempDir).execute()
  assert:  content still contains 'enabled: true' (not overwritten to false)
  ```

- [x] 4.4 Test: idempotent — does not overwrite existing mutations.md
  ```
  arrange: create .ape/mutations.md with '# Mutations\n\nSome user notes here\n'
  act:     InitCommand(tempDir).execute()
  assert:  content still contains 'Some user notes here' (not overwritten)
  ```

- [x] 4.5 Update existing idempotency test to also verify config.yaml and mutations.md survive double-init

**Risk:** Tests 4.3 and 4.4 require pre-creating `.ape/` directory. The setUp doesn't create it — each test must create it explicitly (same pattern as the existing state.yaml idempotency test at line 141).

---

## Phase 5 — Verification

- [x] 5.1 `dart analyze` — 0 issues
- [x] 5.2 `dart test` — all tests green (existing + 4-5 new)
- [x] 5.3 Manual smoke: `dart run example/example.dart` (if applicable) to confirm no import breakage

---

## Dependency Graph

```
Phase 1 (contract) ──┐
                      ├── Phase 5 (verify)
Phase 2 (agent)   ──┤
                      │
Phase 3 (init)    ───┤
         │            │
         └── Phase 4 (tests) ─┘
```

Phases 1, 2, and 3 are independent — can be implemented in any order.
Phase 4 depends on Phase 3 (tests validate init code).
Phase 5 depends on all prior phases.

## Out of Scope

- Config.yaml routing (who reads `evolution.enabled` and emits which event) — deferred to #67 (END state)
- `skip_evolution` event — deferred to #67
- Runtime execution of `reset_mutations` effect by the agent — the CLI declares it; the agent implements it
- New CLI commands for mutations management (Option C from diagnosis — rejected)
