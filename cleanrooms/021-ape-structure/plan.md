# Plan: #21 — ape init structure

## Scope

Implement the new `ape init` as defined in the analysis. Move analysis documents
that describe future architecture (not implemented in this issue) to `docs/references/`
so they become part of the specification for future work.

## Out of Scope

- Signal mechanism (`ape signal`)
- State reconstruction from docs/ (`ape status`)
- `ape memory write` command
- `ape scaffold` command
- Updates to orchestrator-spec.md or finite-ape-machine.md (separate issue)

---

## Phase 0: Documentation — move future specs

Move analysis documents not addressed in this issue to `docs/references/`
as specification material for future work.

- [x] Move `cooperative-multitasking-model.md` → `docs/references/cooperative-multitasking-model.md`
- [x] Move `agent-lifecycle.md` → `docs/references/agent-lifecycle.md`
- [x] Move `signal-based-coordination.md` → `docs/references/signal-based-coordination.md`
- [x] Move `cli-as-api.md` → `docs/references/cli-as-api.md`
- [x] Update `analyze/index.md` to reflect moved documents
- [x] Commit: "docs: move future architecture specs to references"

## Phase 1: RED — tests for new ape init behavior

Write failing tests for each of the 5 steps defined in `ape-init-scope.md`.

- [x] Test: detects existing `docs/` directory and uses it
- [x] Test: detects existing `doc/` directory and uses it
- [x] Test: when both `doc/` and `docs/` exist, prefers `docs/`
- [x] Test: when neither exists, creates `docs/`
- [x] Test: creates `{docs}/issues/` if it does not exist
- [x] Test: skips `{docs}/issues/` creation if already exists
- [x] Test: creates `.gitignore` with `.ape/` if no `.gitignore` exists
- [x] Test: appends `.ape/` to existing `.gitignore` that lacks it
- [x] Test: does not modify `.gitignore` if `.ape/` already present
- [x] Test: creates `.ape/state.yaml` with initial IDLE state
- [x] Test: skips `.ape/state.yaml` if already exists
- [ ] Test: deploys `ape.agent.md` to active target (existing behavior preserved)
- [x] Test: full idempotency — running init twice produces same result
- [x] Verify all new tests FAIL (RED state) — 9 fail, 4 pass
- [x] Commit: "test: RED — ape init new behavior tests"

## Phase 2: GREEN — implement new ape init

Modify `InitCommand` to implement the 5 steps. Make all tests pass.

- [x] Refactor `InitInput` to accept docs directory detection
- [x] Implement docs directory detection logic (doc/ vs docs/)
- [x] Implement `{docs}/issues/` creation
- [x] Implement `.gitignore` management (create or append)
- [x] Implement `.ape/state.yaml` creation with IDLE state
- [x] Integrate deploy step (call existing `TargetDeployer`)
> Deviation: deploy is not duplicated in init — remains in `ape target get`
- [x] Update `InitOutput` to report all steps performed
- [x] Verify all tests PASS (GREEN state) — 13/13
- [x] `dart analyze` — zero issues
- [x] Commit: "feat: implement new ape init (#21)"

## Phase 3: Integration and cleanup

- [x] Run full test suite — all tests pass (80/80)
- [x] Build: `dart compile exe`
- [x] Manual test: run `ape init` in a temp directory, verify all 5 steps
- [x] Manual test: run `ape init` again — verify idempotency
- [x] Bump version to 0.0.7
- [x] Update CHANGELOG.md
- [x] Commit: "chore: bump to 0.0.7, update CHANGELOG"
- [x] Push branch, create PR — https://github.com/ccisnedev/finite_ape_machine/pull/34

---

## Risk Assessment

- **Low risk.** Mostly extending existing working code.
- `InitCommand` already exists and is tested — we're expanding it.
- `TargetDeployer` already works — we're integrating it into init.
- No changes to external dependencies.

## TDD Pseudocode

```dart
// Phase 1 — key test patterns

test('detects docs/ when it exists', () {
  Directory('${tmp}/docs').createSync();
  final cmd = InitCommand(InitInput(workingDirectory: tmp));
  await cmd.execute();
  expect(Directory('${tmp}/docs/issues').existsSync(), isTrue);
});

test('prefers docs/ when both exist', () {
  Directory('${tmp}/doc').createSync();
  Directory('${tmp}/docs').createSync();
  final cmd = InitCommand(InitInput(workingDirectory: tmp));
  await cmd.execute();
  expect(Directory('${tmp}/docs/issues').existsSync(), isTrue);
  expect(Directory('${tmp}/doc/issues').existsSync(), isFalse);
});

test('creates .gitignore with .ape/ entry', () {
  final cmd = InitCommand(InitInput(workingDirectory: tmp));
  await cmd.execute();
  final content = File('${tmp}/.gitignore').readAsStringSync();
  expect(content, contains('.ape/'));
});

test('creates state.yaml with IDLE phase', () {
  final cmd = InitCommand(InitInput(workingDirectory: tmp));
  await cmd.execute();
  final yaml = File('${tmp}/.ape/state.yaml').readAsStringSync();
  expect(yaml, contains('phase: IDLE'));
});
```
