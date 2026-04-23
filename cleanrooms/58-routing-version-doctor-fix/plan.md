---
id: plan
title: "Plan — fix routing catch-all, version desync, doctor checks"
date: 2026-04-18
status: draft
tags: [routing, catch-all, version-desync, doctor, cli-router, plan]
author: descartes
---

# Plan — Issue #58

## Hypothesis

If we (1) guard the empty-route match in cli_router's `_dispatch` so `''` only matches when `args` is genuinely empty, (2) synchronize version.dart with pubspec.yaml and add a regression test, and (3) remove the two unsolicited doctor checks — in that order, respecting the dependency chain — then all six acceptance criteria will be satisfied.

## Scope

### In scope

- cli_router: guard empty-route match in `_dispatch`
- cli_router: tests for the empty-route guard
- cli_router: version bump + publish
- ape_cli: bump cli_router dependency
- ape_cli: sync version.dart ↔ pubspec.yaml to 0.0.13
- ape_cli: add version-sync regression test
- ape_cli: remove doctor checks 5 (gh copilot) and 6 (vscode copilot)
- ape_cli: update doctor tests
- ape_cli: PR for issue #58

### Out of scope

- Global module concept (future enhancement)
- cli_router alias system (future enhancement)
- Any refactoring beyond the three bugs
- Changes to modular_cli_sdk

## Phases

### Phase 1 — cli_router: fix empty-route catch-all

**Entry criteria:** cli_router repo clean, `dart test` green.

**Dependency:** None. This is the foundation — ape_cli depends on the fixed cli_router.

#### 1.1 Create branch

- [ ] `git checkout -b fix/empty-route-catchall` in `cli_router/`

#### 1.2 Write failing tests (TDD red)

- [ ] Add test file `test/empty_route_test.dart` in cli_router
- [ ] Test: empty route with empty args → matches (exit 0, handler runs)
- [ ] Test: empty route with flag-only args `['--help']` → does NOT match (exit 64)
- [ ] Test: empty route with positional args `['target', 'get']` → does NOT match (exit 64)
- [ ] Test: empty route registered alongside mount → mount is reachable for `['target', 'get']`
- [ ] Run `dart test` → confirm new tests fail

```
// Pseudocode for tests
test('empty route matches when args is empty', () {
  router.cmd('', handler(() => banner()));
  router.cmd('help', handler(() => help()));
  exit = router.run([]);
  expect(exit, 0);  // handler ran
});

test('empty route does NOT match when args has flags', () {
  router.cmd('', handler(() => banner()));
  exit = router.run(['--help']);
  expect(exit, 64);  // no match → usage error
});

test('empty route does NOT match when args has positionals', () {
  router.cmd('', handler(() => banner()));
  exit = router.run(['target', 'get']);
  expect(exit, 64);  // no match
});

test('mount is reachable when empty route is registered', () {
  router.cmd('', handler(() => banner()));
  sub = CliRouter()..cmd('get', handler(() => getTarget()));
  router.mount('target', sub);
  exit = router.run(['target', 'get']);
  expect(exit, 0);  // mount handler ran, not banner
});
```

#### 1.3 Implement fix (TDD green)

- [ ] In `cli_router/lib/src/cli_router.dart`, method `_dispatch`, inside the loop:
  - When `j == 0` AND the original `args` is not empty, **skip** the `_matchRoute` call
  - This prevents `''` from matching `['--help']`, `['target', 'get']`, etc.
  - The empty route only matches when `args.isEmpty` (which means `maxRouteTokens == 0` AND no flags)

```dart
// Current (line ~113-118):
for (int j = maxRouteTokens; j >= 0; j--) {
  final candidate = args.take(j).toList();
  final match = _matchRoute(candidate);
  if (match != null) { ... }
}

// Fixed:
for (int j = maxRouteTokens; j >= 0; j--) {
  if (j == 0 && args.isNotEmpty) continue;  // ← guard
  final candidate = args.take(j).toList();
  final match = _matchRoute(candidate);
  if (match != null) { ... }
}
```

- [ ] Run `dart test` → all tests green (new + existing)
- [ ] Run `dart analyze` → no issues

#### 1.4 Version bump

- [ ] Bump `pubspec.yaml` version: `0.0.2` → `0.0.3`
- [ ] Update CHANGELOG.md with fix description

#### 1.5 Publish

- [ ] Commit: `fix: empty route must not act as catch-all (#issue)`
- [ ] Create PR, review, merge
- [ ] `dart pub publish`

**Exit criteria:** cli_router 0.0.3 published on pub.dev with the fix. All tests green.

---

### Phase 2 — ape_cli: bump cli_router dependency

**Entry criteria:** Phase 1 complete (cli_router 0.0.3 published).

**Dependency:** Phase 1.

#### 2.1 Create branch

- [ ] `git checkout -b fix/58-routing-version-doctor` in ape_cli repo

#### 2.2 Bump dependency

- [ ] In `code/cli/pubspec.yaml`, change `cli_router: ^0.0.2` → `cli_router: ^0.0.3`
- [ ] Run `dart pub get`

#### 2.3 Verify routing fix propagates

- [ ] Run existing tests: `dart test` — modules should now be reachable if there are integration tests
- [ ] Manual smoke test: `dart run bin/ape.dart target get` should NOT show banner
- [ ] Manual smoke test: `dart run bin/ape.dart` (no args) should still show banner

**Exit criteria:** cli_router 0.0.3 resolved in ape_cli. Routing fix confirmed working.

---

### Phase 3 — ape_cli: fix version desync + regression test

**Entry criteria:** Phase 2 complete (branch exists, dependency bumped).

**Dependency:** Phase 2 (same branch).

#### 3.1 Sync version constants

- [ ] `code/cli/lib/src/version.dart`: change `'0.0.11'` → `'0.0.13'`
- [ ] `code/cli/pubspec.yaml`: change `0.0.12` → `0.0.13`

#### 3.2 Add version-sync regression test

- [ ] In `code/cli/test/version_test.dart`, add a test that reads `pubspec.yaml` and compares to `apeVersion`

```
// Pseudocode
test('version.dart matches pubspec.yaml', () {
  pubspec = File('pubspec.yaml').readAsString();
  yamlVersion = loadYaml(pubspec)['version'];
  expect(apeVersion, equals(yamlVersion));
});
```

- [ ] Run `dart test test/version_test.dart` → green

**Exit criteria:** version.dart == pubspec.yaml == 0.0.13. Regression test prevents future desync.

---

### Phase 4 — ape_cli: remove unwanted doctor checks

**Entry criteria:** Phase 3 complete (same branch).

**Dependency:** Phase 3 (same branch).

#### 4.1 Remove checks from doctor.dart

- [ ] Remove Check 5 block: `gh copilot --version` (lines ~159-169)
- [ ] Remove Check 6 block: `_checkVsCodeCopilot()` call and the entire method (lines ~171-210)
- [ ] Remove `_extractCopilotVersion` helper if it exists and is now unused
- [ ] Update file docstring (line 3): remove `gh copilot, vscode copilot extension`
- [ ] Verify `execute()` returns after Check 4 (gh auth) with `passed: allPassed`

#### 4.2 Update doctor tests

- [ ] In `code/cli/test/doctor_test.dart`:
  - Remove `copilotFails` and `vscodeFails` parameters from `fakeRunner`
  - Remove the `gh copilot` branch from the fake runner
  - Remove the `code --list-extensions` branch from the fake runner
  - Remove any tests specific to copilot/vscode checks
  - Verify "all pass" test expects exactly 4 checks: ape, git, gh, gh auth
- [ ] Run `dart test test/doctor_test.dart` → green

#### 4.3 Run full test suite

- [ ] `dart analyze` → no issues
- [ ] `dart test` → all green

**Exit criteria:** Doctor validates only: ape, git, gh, gh auth. No references to copilot/vscode remain. All tests green.

---

### Phase 5 — ape_cli: PR and merge

**Entry criteria:** Phases 2-4 complete. All tests green. `dart analyze` clean.

**Dependency:** Phase 4.

#### 5.1 Final verification

- [ ] `dart analyze` clean
- [ ] `dart test` all green
- [ ] Manual smoke tests:
  - `ape` (no args) → banner
  - `ape --help` → command list
  - `ape target get` → target module responds (not banner)
  - `ape doctor` → 4 checks only
  - `ape version` → 0.0.13

#### 5.2 Commit and PR

- [ ] Commit changes with message: `fix(#58): routing catch-all, version sync, doctor cleanup`
- [ ] Push branch, create PR referencing issue #58
- [ ] PR description lists the three fixes and acceptance criteria

#### 5.3 Merge

- [ ] Review PR
- [ ] Merge and delete branch
- [ ] Verify issue #58 acceptance criteria:
  - [AC1] Mounted modules reachable
  - [AC2] `ape --help` shows command list
  - [AC3] `ape` (no args) shows banner
  - [AC4] version.dart and pubspec.yaml synchronized at 0.0.13
  - [AC5] Doctor validates: ape, git, gh, gh auth only
  - [AC6] Tests green

**Exit criteria:** PR merged. Issue #58 closeable.

---

## Risk notes

| Risk | Impact | Mitigation |
|------|--------|------------|
| cli_router 0.0.3 publish breaks other consumers relying on `''` as catch-all | Low — `''` matching non-empty args is objectively a bug | The fix is a bugfix, not a breaking change. No consumer should depend on broken behavior. |
| `dart pub publish` blocked (auth, score) | Medium — blocks Phase 2+ | Ensure pub.dev credentials are valid before starting. Pre-check with `dart pub publish --dry-run`. |
| Existing ape_cli tests depend on the old routing behavior | Medium — tests may break in unexpected ways | Run full test suite immediately after bumping cli_router (Phase 2.3). |
| ESET/Defender deletes dart.exe mid-execution | Low — known issue on this machine | Verify `dart --version` before each phase. Restore from backup if needed. |
| Version 0.0.13 collides with a hotfix release | Low | Check that no release branch exists for 0.0.13 before starting Phase 3. |

## Dependencies graph

```
Phase 1 (cli_router fix + publish)
    │
    ▼
Phase 2 (ape_cli: bump cli_router)
    │
    ▼
Phase 3 (ape_cli: version sync)  ─── can run in parallel with Phase 4
    │                                  but sequential is safer on same branch
    ▼
Phase 4 (ape_cli: doctor cleanup)
    │
    ▼
Phase 5 (ape_cli: PR + merge)
```

Phases 3 and 4 are independent in code (different files) but share the same branch. Sequential execution is preferred to keep commits atomic and reviewable.
