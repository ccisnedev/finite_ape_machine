---
title: "Extract FSM state instructions into prompt YAML files"
issue: 160
date: 2026-04-29
status: complete
---

# Plan: Issue #160

## Phase 1 — Create state YAML files

**Objective:** Extract hardcoded instructions into `assets/fsm/states/*.yaml`

### Tasks

- [x] 1.1 Create `assets/fsm/states/idle.yaml`
- [x] 1.2 Create `assets/fsm/states/analyze.yaml`
- [x] 1.3 Create `assets/fsm/states/plan.yaml`
- [x] 1.4 Create `assets/fsm/states/execute.yaml`
- [x] 1.5 Create `assets/fsm/states/end.yaml`
- [x] 1.6 Create `assets/fsm/states/evolution.yaml`

### Verification

- All 6 files parse as valid YAML
- Each contains: `name`, `version`, `description`, `instructions`, `constraints`, `allowed_actions`
- `dart test` passes (no regressions)

---

## Phase 2 — Load instructions from YAML in state.dart

**Objective:** Replace `_stateInstructions` with YAML loading

### Tasks

- [x] 2.1 Add `_loadStateInstructions(FsmState)` method that reads from `assets/fsm/states/{state}.yaml`
- [x] 2.2 Fail hard with `CommandException` if YAML missing/malformed, message: `State instructions missing for {state}. Run 'iq doctor --fix' to repair.`
- [x] 2.3 Remove `_stateInstructions` static const
- [x] 2.4 Update `_computeInstructions()` to call new loader
- [x] 2.5 Update existing tests

### Verification

- `iq fsm state --json` returns same instructions as before
- Deleting a YAML file → clear error with remediation message
- `dart test` passes

---

## Phase 3 — Doctor: validate internal assets

**Objective:** Add asset integrity check to `iq doctor`

### Tasks

- [x] 3.1 Add `_checkInternalAssets()` method in `DoctorCommand`
- [x] 3.2 Verify existence of: `apes/*.yaml` (5 files), `fsm/states/*.yaml` (6 files), `skills/*/SKILL.md` (4 files), `fsm/transition_contract.yaml`
- [x] 3.3 Report missing files as failed checks with `remediation: "Run 'iq doctor --fix' to restore"`
- [x] 3.4 Add tests

### Verification

- `iq doctor` shows ✓ when all assets present
- `iq doctor` shows ✗ with remediation when asset missing
- `dart test` passes

---

## Phase 4 — Doctor: version check

**Objective:** Check for new version in `iq doctor` and `iq` bare

### Tasks

- [x] 4.1 Extract version-check logic from `UpgradeCommand` into shared utility (e.g., `lib/src/version_check.dart`)
- [x] 4.2 Add version check to `DoctorCommand.execute()` — non-blocking, silent on network failure
- [x] 4.3 Add version banner to `TuiCommand.execute()` — `"Update available: X → Y — run 'iq upgrade'"`
- [x] 4.4 Add tests (mock HTTP)

### Verification

- `iq doctor` shows "Update available" when newer version exists
- `iq` bare shows banner
- Network failure → no crash, no extra output
- `dart test` passes

---

## Phase 5 — Doctor `--fix`

**Objective:** Execute remediations when `--fix` flag is passed

### Tasks

- [x] 5.1 Add `--fix` flag to `DoctorInput` / `DoctorInput.fromCliRequest`
- [x] 5.2 Wire flag in `global_builder.dart`
- [x] 5.3 Implement fix logic: for missing assets → download zip from `https://github.com/ccisnedev/inquiry/releases/download/v{version}/` and extract `assets/` over installation
- [x] 5.4 Report each remediation step with ✓/✗
- [x] 5.5 Add tests

### Verification

- `iq doctor --fix` with missing asset → downloads and restores
- `iq doctor --fix` with all healthy → "Nothing to fix"
- Network failure during fix → clear error
- `dart test` passes

---

## Phase 6 — IDLE scheduler runs doctor first

**Objective:** Update firmware so IDLE always begins with `iq doctor`

### Tasks

- [x] 6.1 Update `assets/fsm/states/idle.yaml` instructions to include "Run `iq doctor` as first action"
- [x] 6.2 Update `assets/agents/inquiry.agent.md` firmware: in IDLE state, run `iq doctor` before presenting transitions

### Verification

- Scheduler in IDLE runs `iq doctor` first
- If doctor fails, scheduler presents remediation options before proceeding

---

## Dependency Order

```
Phase 1 → Phase 2 (need YAML files before loading them)
Phase 3 → Phase 5 (need checks before --fix can run them)
Phase 4 is independent (can parallel with 3)
Phase 6 depends on Phase 1 (idle.yaml must exist)
```

## Exit Criteria

- All 6 state YAML files exist and are loaded at runtime
- `iq fsm state --json` returns instructions from YAML (not hardcoded)
- `iq doctor` validates asset integrity + checks for updates
- `iq doctor --fix` repairs missing assets
- `iq` bare shows update banner
- All tests pass
- No hardcoded state instructions remain in Dart code
