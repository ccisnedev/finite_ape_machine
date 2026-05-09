---
type: retrospective
scope: issue
issue: 175
title: Clarify IDLE Create-or-Select Contract
created: 2026-05-08
---

# Retrospective - Issue #175

## Validation Report

### What Was Implemented

1. Inquiry CLI release metadata for #175 was bumped to 0.3.6 across `code/cli/pubspec.yaml`, `code/cli/lib/src/version.dart`, and `code/site/index.html`.
2. `code/cli/CHANGELOG.md` now records the clarified IDLE boundary, the dedicated `issue-create` TRIAGE skill, and the relocation of explicit create-or-select routing into IDLE/Inquiry CLI orchestration for #175 and the required routing support from #176.
3. Final P6 validation passed on 2026-05-08: `dart analyze` reported no issues and the targeted regression suite for the IDLE contract, prompt assembly, firmware, assets, doctor validation, and version sync passed with `00:04 +141: All tests passed!`.

### How to Verify

1. From `code/cli`, run `dart analyze`.
2. From `code/cli`, run `dart test test/ape_transition_test.dart test/fsm_state_test.dart test/fsm_contract_test.dart test/fsm_transition_test.dart test/fsm_transition_integration_test.dart test/firmware_agent_test.dart test/assets_test.dart test/doctor_test.dart test/ape_prompt_test.dart test/version_sync_test.dart`.
3. Inspect `code/cli/pubspec.yaml`, `code/cli/lib/src/version.dart`, and `code/site/index.html` and confirm all three version surfaces read `0.3.6`.
4. Inspect the top entry in `code/cli/CHANGELOG.md` and confirm it records the clarified IDLE contract, `issue-create`, and IDLE-owned fast-path routing.

### Known Limitations

- This final validation reran the approved P6 gate only. It did not repeat broader smoke flows or installer-style packaging checks because those were not required by the approved phase plan.

## What Went Well

- The P6 gate covered the contract, prompt, firmware, asset, doctor, and version-sync surfaces without reopening earlier phases.
- The release metadata changes remained confined to the repository's enforced version surfaces plus the changelog entry.

## What Deviated from the Plan

- The approved P6 checklist did not enumerate the prompt-required final retrospective artifact. Following repository convention, the final validation record is captured here in `retrospective.md` without changing the release scope.

## What Surprised

- The targeted final regression suite stayed GREEN after the 0.3.6 release bump, which confirmed that the version-sync surface and the clarified IDLE contract remained aligned.

## Spawn Issues

None identified.