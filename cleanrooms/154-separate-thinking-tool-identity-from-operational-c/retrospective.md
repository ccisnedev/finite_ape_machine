---
type: retrospective
scope: issue
issue: 154
title: Separate Thinking-Tool Identity from Operational Contract
created: 2026-05-09
---

# Retrospective - Issue #154

## Validation Report

### What Was Implemented

1. Prompt-boundary doctrine was aligned across `docs/architecture.md`, `docs/thinking-tools.md`, `docs/spec/agent-lifecycle.md`, `docs/spec/finite-ape-machine.md`, and `docs/spec/target-specific-agents.md` so those surfaces now describe APE YAMLs as identity surfaces, FSM state assets as phase-owned operational-contract sources, `iq ape prompt` as the explicit assembler, and DARWIN as the bounded abstract-process exception.
2. The final release/doc delta now records the shipped state as `0.4.0`: `code/cli/assets/agents/inquiry.agent.md`, `code/cli/CHANGELOG.md`, and `docs/timeline.md` reflect the final runtime wording, and the release metadata was bumped across `code/cli/pubspec.yaml`, `code/cli/lib/src/version.dart`, and `code/site/index.html`.
3. Final delta validation passed on 2026-05-09: targeted `test/version_sync_test.dart` plus `test/firmware_agent_test.dart` passed 21 tests, `dart analyze` reported no issues, `dart test` passed 329 tests, and the required `rg` verification surfaced the updated prompt-boundary wording in the targeted docs, timeline, and firmware.

### How to Verify

1. From `code/cli`, run `dart analyze`.
2. From `code/cli`, run `dart test`.
3. From `code/cli`, run `dart test test/version_sync_test.dart`.
4. From `code/cli`, run `dart test test/firmware_agent_test.dart`.
5. From `code/cli`, run `rg "thinking-tool identity|phase-owned operational contract|iq ape prompt|inquiry-context|v0.4.0" ..\..\docs assets\agents`.
6. Review `docs/architecture.md`, `docs/thinking-tools.md`, `docs/spec/agent-lifecycle.md`, `docs/spec/finite-ape-machine.md`, `docs/spec/target-specific-agents.md`, `docs/timeline.md`, `code/cli/assets/agents/inquiry.agent.md`, and the `0.4.0` release entry in `code/cli/CHANGELOG.md`.

### Known Limitations

- This final validation reran the approved P6 gate only. It did not rebuild installer artifacts or compile a fresh release binary because the approved phase did not require packaging smoke.

## What Went Well

- The validated runtime boundary was already stable, so the final delta stayed confined to doctrine, firmware wording, release metadata, one historical doc sync, and verification.
- The version-sync test continued to enforce all three release surfaces and caught the necessary metadata alignment immediately.

## What Deviated from the Plan

- `dart analyze` exposed a preexisting unused import in `code/cli/lib/modules/ape/operational_contract.dart`; removing it was necessary to satisfy the approved release-readiness gate.
- The approved P6 checklist did not enumerate the final retrospective artifact, so the validation record is captured here without widening the release scope.

## What Surprised

- The full 336-test suite stayed GREEN after the doctrine and release-surface edits, which confirmed that the remaining drift was documentary rather than behavioral.

## Spawn Issues

None identified.