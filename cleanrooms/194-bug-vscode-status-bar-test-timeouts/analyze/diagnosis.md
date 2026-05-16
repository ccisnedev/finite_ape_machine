---
id: diagnosis
title: "Diagnosis: VS Code status bar integration test timeouts"
date: 2026-05-15
status: active
tags: [integration-testing, vscode, state-yaml, status-bar]
author: socrates
---

# Diagnosis: Issue #194

## Problem defined

The VS Code integration suite was not green because two status bar tests timed out while waiting for the rendered phase text to change from IDLE to the expected issue-bearing state:

- `updateStatusBar con ApeState actualiza text y tooltip del item`
- `dispose limpia el item y el watcher`

The failure mode was deterministic: `waitFor()` exhausted its timeout because the status bar kept rendering the default IDLE state instead of `PLAN #042` or `ANALYZE #042`.

## Decisions taken

### D1. Treat the timeout as a state-fixture contract problem, not as watcher timing

This decision is justified by the owning parser and the live CLI state format:

- [code/vscode/src/parsers.ts](../../code/vscode/src/parsers.ts) parses top-level `state` and `issue` keys.
- [.inquiry/state.yaml](../../.inquiry/state.yaml) in the live repository currently uses the same flat shape.
- [code/cli/test/ape_state_test.dart](../../code/cli/test/ape_state_test.dart) and [code/cli/test/ape_prompt_test.dart](../../code/cli/test/ape_prompt_test.dart) also assert that the CLI persists flat `state` and `issue` keys.

Because the parser returns the default state when `state` is missing, any test fixture using another YAML shape will leave the status bar in IDLE and make `waitFor()` time out even if the watcher is functioning correctly.

### D2. Keep the production parser unchanged and repair the integration fixtures

The parser contract is already aligned with the CLI and with the unit coverage in [code/vscode/test/unit/state-parser.test.ts](../../code/vscode/test/unit/state-parser.test.ts). Changing runtime code would move the extension away from the active Inquiry state contract. The correct repair surface is therefore the integration fixture written by [code/vscode/test/integration/status-bar.test.ts](../../code/vscode/test/integration/status-bar.test.ts).

### D3. Validate the fix first with the narrow status-bar slice, then with the full repo gates

The discriminating check was the status bar integration slice itself. After aligning the fixtures with the real contract, the narrow integration run passed. The same change was then validated through the repository-wide gates required by the active plan:

- `dart pub get`
- `dart analyze`
- `dart test`
- `dart compile exe bin/main.dart -o build/inquiry.exe`
- `npm run test:unit`
- `npm run test:integration`

## Constraints and risks identified

- The extension must remain compatible with the CLI-owned `.inquiry/state.yaml` contract; the VS Code layer is not free to invent a parallel shape.
- The observed failure was easy to misclassify as asynchronous flakiness because it surfaced as a timeout in `waitFor()` rather than as a parser assertion.
- Repo closure for issue #193 was blocked until the VS Code suite was green, so issue #194 had to be treated as a real repository blocker rather than as a local nuisance.

## Scope

### In scope

- Diagnose why the status bar integration tests timed out.
- Identify the owning state-file contract.
- Repair the integration fixtures so they match the real `.inquiry/state.yaml` format.
- Re-run the narrow VS Code slice and the full repository validation gates.

### Out of scope

- Changing the CLI state-file format.
- Changing the status bar parser contract.
- Broad refactors of the VS Code extension unrelated to the failing tests.

## References

- [code/vscode/src/parsers.ts](../../code/vscode/src/parsers.ts)
- [code/vscode/src/status-bar.ts](../../code/vscode/src/status-bar.ts)
- [code/vscode/test/integration/status-bar.test.ts](../../code/vscode/test/integration/status-bar.test.ts)
- [code/vscode/test/integration/helpers.ts](../../code/vscode/test/integration/helpers.ts)
- [code/vscode/test/unit/state-parser.test.ts](../../code/vscode/test/unit/state-parser.test.ts)
- [code/cli/test/ape_state_test.dart](../../code/cli/test/ape_state_test.dart)
- [code/cli/test/ape_prompt_test.dart](../../code/cli/test/ape_prompt_test.dart)
- [.inquiry/state.yaml](../../.inquiry/state.yaml)
