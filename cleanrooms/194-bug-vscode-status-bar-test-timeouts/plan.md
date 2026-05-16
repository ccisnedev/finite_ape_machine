---
id: plan
issue: 194
title: "Plan: Fix VS Code status bar integration test timeouts"
status: active
phase: decomposition
owner: descartes
date: 2026-05-15
---

# Plan - Issue #194 (decomposition)

## Goal
Restore repo-green validation by aligning the VS Code status bar integration fixtures with the real `.inquiry/state.yaml` contract, then proving the repair with the narrow failing slice first and the full repository gates last.

## Scope Guardrails
- [x] Keep work limited to the status bar integration timeout defect diagnosed in #194.
- [x] Keep the production `.inquiry/state.yaml` contract unchanged.
- [x] Keep the runtime parser contract unchanged; repair the failing integration surface instead.
- [x] Use TDD where the failure is directly reproducible: RED on the status bar integration slice, GREEN on the fixture alignment.
- [x] Treat this artifact as PLAN-only; no implementation details beyond execution-ready steps.

## Diagnosis Decision Traceability (Mandatory)
- [x] D1 (fixture/state contract problem, not watcher flakiness) is preserved by prioritizing fixture audit and narrow reproduction.
- [x] D2 (production parser remains unchanged) is preserved by explicit scope exclusions and diff audit.
- [x] D3 (narrow validation first, then full repo gates) is preserved by phase ordering and final verification gates.

## Ordering Contract
- [x] Execute phases strictly in order: Phase 1 -> Phase 2 -> Phase 3.
- [x] A later phase may start only when the verification checklist of the previous phase is green.
- [x] If any new dependency or contradictory evidence appears, execution must stop and return to ANALYZE instead of widening scope ad hoc.

## Phase 1 - Reproduce and Align the Fixture Contract

### Entry Criteria
- [ ] `diagnosis.md` is available and accepted as source of truth for #194.
- [ ] The failing surface is still the VS Code status bar integration slice.
- [ ] The active parser contract has been rechecked in `code/vscode/src/parsers.ts` and the live `.inquiry/state.yaml` file.

### Steps
- [ ] Reproduce the RED state with the narrow status bar integration slice.
- [ ] Inspect `code/vscode/test/integration/status-bar.test.ts` and identify every fixture write that populates `.inquiry/state.yaml` for the failing tests.
- [ ] Confirm the canonical state-file shape from `code/vscode/src/parsers.ts`, `.inquiry/state.yaml`, `code/cli/test/ape_state_test.dart`, and `code/cli/test/ape_prompt_test.dart`.
- [ ] Replace any non-canonical integration fixture shape with the flat `state` / `issue` shape used by the CLI contract.
- [ ] Keep `code/vscode/src/parsers.ts` unchanged.

### Verification
- [ ] The RED reproduction fails for the same two status bar tests described in the diagnosis.
- [ ] The updated fixtures now match the flat top-level `state` / `issue` keys exactly.
- [ ] No runtime parser logic changes are introduced.
- [ ] Diff remains limited to the failing integration surface during this phase.

### Pseudotests
- [ ] PseudoTest P1.1: "Given a fixture without top-level `state`, the parser falls back to IDLE and the status bar wait loop times out."
- [ ] PseudoTest P1.2: "Given a fixture with top-level `state: PLAN` and `issue: \"042\"`, the status bar can render `Inquiry: PLAN #042`."
- [ ] PseudoTest P1.3: "Parser source diff for this phase is empty; only test fixture data changes."

### Risk Notes
- [ ] Risk: Timeout symptoms are misread as asynchronous flakiness and lead to unnecessary runtime edits.
- [ ] Mitigation: Force the first comparison against the parser and CLI-owned state-file contract.
- [ ] Risk: Additional fixture writes in the same file are missed.
- [ ] Mitigation: Audit every `.writeFileSync(...state.yaml...)` occurrence in the touched integration slice.

### Dependencies
- [ ] Depends on diagnosis decisions D1 and D2.
- [ ] Must not introduce dependencies beyond the diagnosed parser/state-file contract.

## Phase 2 - Validate the Narrow Fix with TDD

### Entry Criteria
- [ ] Phase 1 fixture alignment is complete.
- [ ] The edited surface remains limited to the narrow status bar integration slice.

### Steps
- [ ] Re-run only the status bar integration slice immediately after the fixture edit.
- [ ] Confirm the formerly failing tests now pass:
- [ ] `updateStatusBar con ApeState actualiza text y tooltip del item`
- [ ] `dispose limpia el item y el watcher`
- [ ] If the narrow validation still fails, repair only that same slice and re-run the same focused validation before expanding scope.
- [ ] Once the narrow slice passes, run the full VS Code integration suite.

### Verification
- [ ] The first post-edit check is the narrow status bar slice, not a broad suite.
- [ ] The narrow slice passes without timeout.
- [ ] The full VS Code integration suite passes after the narrow slice is green.
- [ ] No additional VS Code runtime files needed changes to satisfy the diagnosis.

### Pseudotests
- [ ] PseudoTest P2.1: "RED -> GREEN is observable on the narrow status bar slice with the same test names referenced in the diagnosis."
- [ ] PseudoTest P2.2: "After the narrow fix is green, `npm run test:integration` passes for the full VS Code extension suite."
- [ ] PseudoTest P2.3: "If another failure appears outside the touched status bar slice, execution stops and reassesses scope instead of patching broadly."

### Risk Notes
- [ ] Risk: The focused fix masks a second integration drift in adjacent helpers.
- [ ] Mitigation: Run the full VS Code integration suite immediately after the narrow slice turns green.
- [ ] Risk: Residual environment noise (e.g. VS Code mutex messages) obscures the real verdict.
- [ ] Mitigation: Judge success by process exit code and test pass/fail output, not by incidental harness noise.

### Dependencies
- [ ] Depends on Phase 1 completion.
- [ ] Depends on diagnosis decision D3 for validation order.

## Phase 3 - Full Repository Validation and Closure Gate

### Entry Criteria
- [ ] Phase 2 is green.
- [ ] The repo still contains the already prepared #193 changes that depend on this blocker being cleared.

### Steps
- [ ] Run the required CLI validation block:
- [ ] `dart pub get`
- [ ] `dart analyze`
- [ ] `dart test`
- [ ] `dart compile exe bin/main.dart -o build/inquiry.exe`
- [ ] Run the required VS Code validation block:
- [ ] `npm run test:unit`
- [ ] `npm run test:integration`
- [ ] Audit the final diff to confirm #194 stayed constrained to the diagnosed integration surface and did not alter the production parser contract.
- [ ] Record closure evidence in the cleanroom artifacts so #193 can truthfully claim repo-green status.

### Verification
- [ ] All required CLI commands pass.
- [ ] All required VS Code commands pass.
- [ ] The final diff confirms D2: no parser-contract change was introduced.
- [ ] The final evidence supports D1-D3 simultaneously: right root cause, right repair surface, right validation order.

### Pseudotests
- [ ] PseudoTest P3.1: "If the status bar slice passes but `npm run test:integration` fails elsewhere, the issue is not closed as green."
- [ ] PseudoTest P3.2: "If CLI analyze/test/compile fail after the VS Code fix, the repository blocker is not actually resolved."
- [ ] PseudoTest P3.3: "Closure evidence includes both the narrow status bar pass and the final full-suite pass."

### Risk Notes
- [ ] Risk: Repo-green is claimed from targeted checks only.
- [ ] Mitigation: Keep the full repository validation block as a mandatory terminal gate.
- [ ] Risk: #194 closes without restoring the blocked closure path for #193.
- [ ] Mitigation: Record explicit evidence that the previously blocked repo-wide gates now pass.

### Dependencies
- [ ] Depends on Phase 2 completion.
- [ ] Depends on diagnosis decisions D1-D3 remaining valid through final diff audit.

## Completion Criteria
- [x] The plan preserves D1-D3 explicitly.
- [x] The plan encodes TDD for the narrow failing slice.
- [x] The final phase mandates the full repository validation block, not only local tests.
- [x] The plan keeps the parser/state-file contract unchanged and scopes the repair to integration fixtures.
- [x] Every phase includes Entry Criteria, Steps, Verification, Pseudotests, Risk Notes, and Dependencies.
