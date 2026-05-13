---
id: confirmed
title: "Confirmed findings"
date: 2026-05-13
status: active
tags: [findings, confirmed]
author: socrates
---

# Confirmed Findings

> Living document. Update as findings are confirmed, revised, or invalidated.
> Format: ## F<N>: <title> — CONFIRMED|REVISED|INVALIDATED

## F1: plan.yaml lacks full-test-suite mandate — CONFIRMED

`plan.yaml` instructs DESCARTES to "define verification criteria for each phase" but does not require those criteria to include running the full existing test suite. A plan can pass all constraints with only phase-local verification (e.g., "new test passes"), leaving existing regression tests unexecuted.

**Evidence:** E1 in evidence-inventory.md.

## F2: execute.yaml delegates testing scope entirely to plan.md — CONFIRMED

`execute.yaml` says "Each phase must pass its verification criteria before advancing" and allows "Run tests" but does not mandate running the *complete* test suite. The constraint chain is: execute.yaml → plan.md verification criteria → phase-specific tests. If the plan omits a full-suite step, EXECUTE won't compensate.

**Evidence:** E2 in evidence-inventory.md.

## F3: assets_test.dart has a hardcoded skills list that breaks on additions — CONFIRMED

The integration test at line 149 uses `unorderedEquals` with a static list of 6 skill names. Adding `Invoke-ExpertCouncil` in #186 made the actual directory contain 7 entries, breaking this test. The pattern is structurally fragile — every new skill breaks it.

**Evidence:** E5 in evidence-inventory.md.

## F4: doctor_test.dart has a parallel hardcoded list but is self-contained — CONFIRMED

`doctor_test.dart` also has a hardcoded `testSkills` list of 6 entries (line 98). This test seeds its own mock directory, so it doesn't break from real asset changes. However, it's misleading: the list doesn't reflect reality and the "6 skills" string assertion (line 317) is tied to the list length.

**Evidence:** E6 in evidence-inventory.md.

## F5: APE identity YAMLs correctly do not own testing procedure — CONFIRMED

Neither `descartes.yaml` nor `basho.yaml` should contain framework-specific testing mandates (per #154 boundary rules). The gap is in the phase contracts (plan.yaml, execute.yaml), not the APE identities. BASHŌ's test sub-state does mention "Run all tests" but this instruction proved insufficient in practice — the regression shipped anyway.

**Evidence:** E3, E4 in evidence-inventory.md.

## F6: operational_contract.dart delivery mechanism is correct — CONFIRMED

The `OperationalContract.render()` method correctly injects constraints from phase YAMLs into sub-agent prompts. Adding new constraints to plan.yaml or execute.yaml will automatically flow through to DESCARTES and BASHŌ respectively. No code changes needed in the delivery mechanism.

**Evidence:** E7 in evidence-inventory.md.
