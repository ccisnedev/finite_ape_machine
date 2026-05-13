---
id: evidence-inventory
title: "Evidence Inventory"
date: 2026-05-13
status: active
tags: [evidence, inventory]
author: socrates
---

# Evidence Inventory

## E1: plan.yaml — PLAN operational contract

**File:** `code/cli/assets/fsm/states/plan.yaml` (v1.0.0)

**Observations:**
- `instructions` says: "Design an experimental plan from the diagnosis. Divide into phases, order by dependencies, define verification criteria for each phase. Produce plan.md."
- `constraints` include: "Each phase must have verification criteria"
- `allowed_actions` include: "Define verification per phase"
- **No mention** of running tests, requiring test execution, or mandating a "run full test suite" verification step in the plan.
- The contract tells DESCARTES to "define verification criteria" but does not require that verification criteria include running the full project test suite.

**Gap:** A plan can satisfy all constraints without ever mentioning "run all existing tests." DESCARTES can write phase-local verification (e.g., "new test passes") without a global regression gate.

## E2: execute.yaml — EXECUTE operational contract

**File:** `code/cli/assets/fsm/states/execute.yaml` (v1.1.0)

**Observations:**
- `instructions` say: "Each phase produces tested code and a commit."
- `constraints` include: "Each phase must pass its verification criteria before advancing"
- `allowed_actions` include: "Run tests"
- **No explicit mandate** to run the *full* test suite. "Run tests" is allowed but not required. "Pass its verification criteria" only enforces what the plan says — if the plan omits a full-suite run, so does execution.
- The contract chains to plan.md: "Follow plan.md phases in order" — so if the plan lacks a global test step, EXECUTE won't add one.

**Gap:** EXECUTE delegates testing scope entirely to plan.md. If the plan says "run new test," BASHŌ may skip existing tests and still satisfy all constraints.

## E3: descartes.yaml — DESCARTES identity

**File:** `code/cli/assets/apes/descartes.yaml` (v0.2.0)

**Observations:**
- Base prompt is methodological: evidence, division, ordering, enumeration.
- Verification sub-state prompt says: "Define test definitions in pseudocode for each phase. Consider TDD applicability."
- Enumeration sub-state: "Review the plan for completeness. Every phase has entry criteria, steps, verification, and risks."
- **No framework-specific testing instructions** (correct per boundary rules).
- No mention of "run all tests" as an invariant — this is consistent with the identity being methodology-only, but the *phase contract* (plan.yaml) also doesn't supply it.

**Conclusion:** DESCARTES correctly does not own testing instructions. The gap is in plan.yaml, not here.

## E4: basho.yaml — BASHŌ identity

**File:** `code/cli/assets/apes/basho.yaml` (v0.2.0)

**Observations:**
- Implementation: "Execute exactly what the current plan phase specifies."
- Test sub-state: "Run all tests, lint, and build. Report results."
- Commit sub-state: "Mark completed steps in plan.md."
- The test sub-state *does* say "Run all tests" — but this is the APE identity, which per #154 boundary rules should NOT own operational procedure.
- The effective behavior depends on whether the scheduler actually transitions BASHŌ through `implement → test → commit` for every phase, and whether "all tests" is interpreted as "all project tests" or "all tests relevant to this phase."

**Observation:** BASHŌ's test sub-state says "Run all tests" but this instruction lives in the APE identity rather than the phase contract. There's a tension: the execute.yaml contract doesn't mandate full-suite runs, but basho.yaml's sub-state does mention "all tests." In practice, issue #186 showed this was insufficient — the regression shipped anyway.

## E5: assets_test.dart — the failing test

**File:** `code/cli/test/assets_test.dart`, lines 149–162

```dart
test('listDirectory skills returns all skill directories', () {
  final dirs = assets.listDirectory('skills');
  expect(
    dirs,
    unorderedEquals([
      'doc-read',
      'doc-write',
      'inquiry-install',
      'issue-create',
      'issue-end',
      'issue-start',
    ]),
  );
});
```

**Observation:** This is a hardcoded list of 6 skill directories. After #186 added `Invoke-ExpertCouncil/`, the actual directory contains 7 entries. This test fails because `Invoke-ExpertCouncil` is not in the expected list.

**Pattern risk:** This is an exhaustive assertion on a list that grows with features. Every new skill addition will break this test.

## E6: doctor_test.dart — second hardcoded skills list

**File:** `code/cli/test/doctor_test.dart`, lines 98–106

```dart
final testSkills = [
  'doc-read',
  'doc-write',
  'inquiry-install',
  'issue-create',
  'issue-start',
  'issue-end',
];
```

**Observation:** This list is used to seed a mock `Assets` directory and is also used in assertion at line 333 (`unorderedEquals(testSkills)`). Unlike `assets_test.dart`, this test creates its own temp directory and seeds it — so it's self-consistent and doesn't read real assets. However:
- The test at line 317 expects `'✓ copilot: agent + 6 skills deployed'` — this "6" is derived from the `testSkills` length, so it's consistent within the test but divorced from reality.
- The `testSkills` list does NOT include `Invoke-ExpertCouncil` — if someone copies this list or cross-references, it's misleading.

**Risk:** This test won't fail from adding a new skill (it's self-contained), but the hardcoded "6" string match could break if someone updates `testSkills` without updating the assertion string.

## E7: operational_contract.dart — prompt assembly

**File:** `code/cli/lib/modules/ape/operational_contract.dart`

**Observations:**
- Loads `state`, `instructions`, `constraints`, `allowed_actions` from the YAML.
- `render()` produces the "Phase-Owned Operational Contract" block injected into sub-agent prompts.
- The constraints from plan.yaml/execute.yaml flow directly into the prompt as bullet points.
- If a constraint like "Run the full project test suite before committing" were added to execute.yaml, it would automatically appear in BASHŌ's runtime prompt via this render path.

**Conclusion:** The delivery mechanism works correctly. The fix is purely content: adding the right constraints to plan.yaml and execute.yaml.
