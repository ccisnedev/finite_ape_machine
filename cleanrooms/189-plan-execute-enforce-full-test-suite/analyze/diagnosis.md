---
id: diagnosis
title: "Diagnosis: PLAN and EXECUTE phases must enforce full test suite execution"
date: 2026-05-13
status: final
tags: [diagnosis, testing, phase-contracts]
author: socrates
issue: 189
---

# Diagnosis: PLAN and EXECUTE Phases Must Enforce Full Test Suite Execution

## Problem Defined

Issue #186 added `Invoke-ExpertCouncil` SKILL.md to `code/cli/assets/skills/`. A test in `assets_test.dart` has a hardcoded list of skill directories. The EXECUTE phase (BASHŌ) did not run `dart test` before committing, so the regression shipped to main and broke CI + Release.

The root cause is structural: neither the PLAN phase contract (`plan.yaml`) nor the EXECUTE phase contract (`execute.yaml`) mandates running the full project test suite. The constraint chain `execute.yaml → plan.md → phase verification` creates a path where only phase-local tests run, allowing pre-existing regression tests to go unexecuted.

## Decisions Taken

### D1: Fix the phase contracts, not the APE identities

The PLAN contract must require that every plan includes a "run full project test suite" verification step. The EXECUTE contract must independently mandate full-suite execution before any commit, regardless of what the plan says. This creates defense-in-depth: even if a plan omits the step, EXECUTE still catches it.

**Rationale:** Per #154 boundary rules, operational procedure belongs in phase contracts, not APE identity YAMLs. DESCARTES and BASHŌ should remain methodology-focused.

### D2: Fix `assets_test.dart` to be resilient to asset additions

The hardcoded `unorderedEquals` assertion must be replaced with a pattern that doesn't break every time a new skill is added. Options include: asserting a minimum set with `containsAll`, or dynamically reading the directory and comparing to a reference.

**Rationale:** A test that breaks on every legitimate feature addition is a maintenance burden and a source of false negatives in the process (developers learn to ignore it or patch it without thinking).

### D3: Constraints must be framework-agnostic

The new constraints must say "run the full project test suite" or "run all existing tests, lint, and build," not "run `dart test`." The CLI supports arbitrary project types; the contracts must not assume Dart.

**Rationale:** User's explicit scope requirement. APE prompts are framework-agnostic by design.

## Constraints and Risks

### Constraints

1. **No APE identity changes** — descartes.yaml and basho.yaml are out of scope per #154 boundary.
2. **Framework-agnostic language** — contracts cannot reference Dart, npm, or any specific tool.
3. **Backward compatible** — existing cleanroom plans that already work should not be invalidated.
4. **Content-only changes** — `operational_contract.dart` delivery mechanism works correctly; no code changes needed there.

### Risks

1. **Prompt length increase** — Adding constraints to plan.yaml and execute.yaml increases the token count in sub-agent prompts. Impact: negligible (a few sentences).
2. **BASHŌ compliance** — Even with the constraint, a sub-agent might skip the full suite if the prompt is long and the instruction is buried. Mitigation: place the constraint prominently in the constraints list, not buried in instructions prose.
3. **Test fragility pattern** — The `assets_test.dart` fix must balance two tensions: (a) detecting accidentally deleted skills and (b) not breaking on new additions. A pure `containsAll` loses detection of deletions; a pure `unorderedEquals` breaks on additions.

## Scope

### In Scope

| Item | File | Change Type |
|------|------|-------------|
| PLAN contract: require full-suite verification step in plans | `code/cli/assets/fsm/states/plan.yaml` | Content edit |
| EXECUTE contract: mandate full-suite run before commits | `code/cli/assets/fsm/states/execute.yaml` | Content edit |
| Fix hardcoded skills list in integration test | `code/cli/test/assets_test.dart` (~line 149) | Test fix |
| Update `doctor_test.dart` hardcoded list for consistency | `code/cli/test/doctor_test.dart` (~line 98) | Test fix |

### Out of Scope

- Changes to `descartes.yaml` or `basho.yaml` (APE identity boundary)
- New CLI commands or infrastructure
- Changes to `operational_contract.dart` (delivery mechanism is correct)
- Changes to the `Assets` class or `listDirectory` implementation

## References

| Document | Path |
|----------|------|
| Evidence Inventory | `cleanrooms/189-plan-execute-enforce-full-test-suite/analyze/evidence-inventory.md` |
| Confirmed Findings | `cleanrooms/189-plan-execute-enforce-full-test-suite/analyze/confirmed.md` |
| Issue #186 (causal) | GitHub issue #186 |
| Issue #154 (boundary rules) | GitHub issue #154 |
| plan.yaml | `code/cli/assets/fsm/states/plan.yaml` |
| execute.yaml | `code/cli/assets/fsm/states/execute.yaml` |
| assets_test.dart | `code/cli/test/assets_test.dart` |
| doctor_test.dart | `code/cli/test/doctor_test.dart` |
| operational_contract.dart | `code/cli/lib/modules/ape/operational_contract.dart` |
