---
id: confirmed
title: "Confirmed findings"
date: 2026-05-15
status: active
tags: [findings, confirmed]
author: socrates
---

# Confirmed Findings

> Living document. Update as findings are confirmed, revised, or invalidated.
> Format: ## F<N>: <title> — CONFIRMED|REVISED|INVALIDATED

## F1: The VS Code status bar parser consumes flat `state` and `issue` keys — CONFIRMED

- [code/vscode/src/parsers.ts](../../code/vscode/src/parsers.ts) reads `doc.state` and `doc.issue`.
- The live repository state file [.inquiry/state.yaml](../../.inquiry/state.yaml) uses the same flat shape.
- CLI tests in [code/cli/test/ape_state_test.dart](../../code/cli/test/ape_state_test.dart) and [code/cli/test/ape_prompt_test.dart](../../code/cli/test/ape_prompt_test.dart) reinforce the same contract.

## F2: The timeouts were caused by fixture shape mismatch, not by watcher flakiness — CONFIRMED

- The failing integration tests in [code/vscode/test/integration/status-bar.test.ts](../../code/vscode/test/integration/status-bar.test.ts) originally wrote a nested `cycle.phase` / `cycle.task` shape.
- When `state` is absent, the parser falls back to `{ phase: 'IDLE', task: '' }`, which leaves `waitFor()` polling until timeout.

## F3: Aligning the fixtures with the real state-file contract resolves the blocker — CONFIRMED

- After changing the integration fixtures to use flat `state` / `issue`, the focused status bar integration tests passed.
- The full required validation gates also passed: CLI analyze/test/compile plus VS Code unit and integration suites.
