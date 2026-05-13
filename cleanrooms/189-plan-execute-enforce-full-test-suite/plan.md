# Plan: Enforce Full Test Suite in PLAN and EXECUTE Contracts

**Issue:** #189  
**Diagnosis:** [diagnosis.md](analyze/diagnosis.md)  
**Decisions referenced:** D1 (fix phase contracts), D2 (fix assets_test resilience), D3 (framework-agnostic)

---

## Phase 1 — Fix `assets_test.dart` hardcoded skill list

**Objective:** Unbreak CI by adding `Invoke-ExpertCouncil` to the skill list assertion.

### Entry Criteria
- `code/cli/test/assets_test.dart` contains a `listDirectory skills` test with a hardcoded 6-entry `unorderedEquals` list (line ~149).
- The actual `code/cli/assets/skills/` directory contains 7 entries (including `Invoke-ExpertCouncil`).

### Steps
1. In `code/cli/test/assets_test.dart`, add `'Invoke-ExpertCouncil'` to the `unorderedEquals` list in the `listDirectory skills` test.

### Verification
- [x] `dart test` in `code/cli/` passes the `listDirectory skills returns all skill directories` test.
- [x] The list in the test matches the actual contents of `code/cli/assets/skills/`.

### Risk
- None. One-liner fix with no side effects.

---

## Phase 2 — Update `doctor_test.dart` hardcoded skill list

**Objective:** Align the parallel hardcoded `testSkills` list so the mock environment reflects reality (per D2, F4).

### Entry Criteria
- Phase 1 complete.
- `code/cli/test/doctor_test.dart` contains a `testSkills` list of 6 entries (~line 98) and a string assertion referencing "6 skills" (~line 317).

### Steps
1. Add `'Invoke-ExpertCouncil'` to the `testSkills` list in `doctor_test.dart`.
2. Update the "6 skills" string assertion to "7 skills" (or whatever count results from the addition).

### Verification
- [x] `dart test` in `code/cli/` passes all doctor-related tests.
- [x] The `testSkills` list length matches the assertion string.

### Risk
- The "N skills" string may appear in multiple assertions. Verify all occurrences are updated.

---

## Phase 3 — Add full-test-suite invariant to `plan.yaml`

**Objective:** Require DESCARTES to include a full project test suite run in every plan's verification criteria (per D1, D3).

### Entry Criteria
- Phase 2 complete.
- `code/cli/assets/fsm/states/plan.yaml` does not currently mandate full-suite test execution.

### Steps
1. Add a new constraint to `plan.yaml`'s `constraints` list:
   - The constraint must state that every plan must include a final verification step that runs the full project test suite (all existing tests, not just phase-specific ones).
   - Language must be framework-agnostic: "full project test suite," not "dart test" or any tool-specific command.
2. The constraint must be placed prominently in the list (not buried at the bottom) to reduce risk of sub-agent skipping it (per diagnosis Risk #2).

### Verification
- [x] `plan.yaml` parses correctly (valid YAML).
- [x] The new constraint text does not reference any specific language, framework, or test runner.
- [x] `dart test` in `code/cli/` passes `assets_test.dart` (particularly the YAML content assertions that check for framework-specific markers).

### Risk
- Prompt length increase is negligible (one additional constraint sentence).

---

## Phase 4 — Add full-test-suite mandate to `execute.yaml`

**Objective:** Independently require BASHŌ to run the full project test suite before any commit, regardless of what the plan says (per D1 defense-in-depth).

### Entry Criteria
- Phase 3 complete.
- `code/cli/assets/fsm/states/execute.yaml` delegates test scope entirely to plan.md verification criteria (per F2).

### Steps
1. Add a new constraint to `execute.yaml`'s `constraints` list:
   - The constraint must state that the full project test suite must pass before any commit, independent of plan.md verification criteria.
   - Language must be framework-agnostic.
2. Place the constraint prominently (near the top of the constraints list).

### Verification
- [x] `execute.yaml` parses correctly (valid YAML).
- [x] The new constraint text does not reference any specific language, framework, or test runner.
- [x] `dart test` in `code/cli/` passes all YAML content assertions in `assets_test.dart`.

### Risk
- Same negligible prompt length increase as Phase 3.
- BASHŌ compliance risk mitigated by prominent placement per diagnosis recommendation.

---

## Phase 5 — Full test suite verification

**Objective:** Confirm that all changes from Phases 1–4 do not break any existing test.

### Entry Criteria
- Phases 1–4 complete and committed.

### Steps
1. Run the full project test suite from `code/cli/`.
2. Confirm zero failures across all test files.

### Verification
- [x] Full test suite passes with zero failures.
- [x] No warnings or skipped tests that were previously passing.

### Risk
- If any pre-existing test fails, it must be diagnosed as a pre-existing issue vs. a regression from this change. Only regressions from Phases 1–4 are in scope.

---

## Version Bump

**Type:** patch  
**Rationale:** Content-only changes to phase contract assets and a test fix. No public API or CLI behavior changes.

---

## Summary

| Phase | Files Changed | Change Type |
|-------|--------------|-------------|
| 1 | `code/cli/test/assets_test.dart` | Test fix |
| 2 | `code/cli/test/doctor_test.dart` | Test fix |
| 3 | `code/cli/assets/fsm/states/plan.yaml` | Contract content |
| 4 | `code/cli/assets/fsm/states/execute.yaml` | Contract content |
| 5 | (none — verification only) | Verification |
