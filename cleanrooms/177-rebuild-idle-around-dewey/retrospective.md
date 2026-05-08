---
type: retrospective
scope: issue
issue: 177
title: Rebuild IDLE Around Dewey
created: 2026-05-07
---

# Retrospective - Issue #177

## Validation Report

### What Was Implemented

1. Release metadata for #177 was bumped to 0.3.5 across the CLI version surfaces required by the repository's version-sync checks.
2. `code/cli/CHANGELOG.md` now records DEWEY as the active IDLE operator across runtime, prompt resolution, doctor validation, and public roster surfaces.
3. Phase 5 validation passed end to end: `dart analyze`, `dart test`, temp-workspace IDLE smoke for `iq fsm state --json`, temp-workspace smoke for `iq ape prompt --name dewey`, `iq doctor`, and a manual review of the updated site roster pages.

### How to Verify

1. From `code/cli`, run `dart analyze`.
2. From `code/cli`, run `dart test`.
3. From `code/cli`, compile `build/bin/inquiry.exe`, create a temp workspace, run `inquiry.exe init`, then run `inquiry.exe fsm state --json` and confirm the only active IDLE ape is `dewey`.
4. In that same temp workspace, run `inquiry.exe ape prompt --name dewey` and confirm prompt assembly succeeds.
5. From `code/cli`, run `build/bin/inquiry.exe doctor` and confirm the output includes a passing assets check.
6. Review `code/site/index.html`, `code/site/agents.html`, and `code/site/methodology.html` and confirm DEWEY appears on the live roster surfaces and no page still claims only four active apes.
7. Inspect `code/cli/pubspec.yaml` and `code/cli/CHANGELOG.md` and confirm the release record is 0.3.5 with the DEWEY IDLE operator change.

### Known Limitations

- Smoke validation used the freshly compiled local `build/bin/inquiry.exe` plus the repository's bundled `build/assets`; it did not validate an installer-produced release artifact.

## What Went Well

- The version-sync test exposed the full release metadata surface before a partial bump could ship.
- Recompiling the local binary and validating in a fresh temp workspace produced deterministic smoke evidence for IDLE.
- Both full post-metadata validation passes stayed GREEN: `dart analyze` reported no issues and `dart test` passed all 309 tests.

## What Deviated from the Plan

- The checklist named `code/cli/pubspec.yaml` explicitly, but the repository's release contract also required updating `code/cli/lib/src/version.dart` and the `code/site/index.html` version badge. This deviation was resolved in Phase 5 and did not require reopening earlier phases.

## What Surprised

- `iq ape prompt --name dewey` succeeded in an `init`-created IDLE workspace without any extra state mutation because the active-operator check is derived from the FSM state.
- `iq doctor` passed cleanly with the rebuilt binary and confirmed the bundled assets already contained DEWEY.

## Spawn Issues

None identified.