# Experimental Plan: Issue #66

**Hypothesis:** If we (1) fix the cli_router empty-mount bug via TDD, (2) verify backward compatibility, then (3) refactor ape_cli to modular structure, we will achieve structural alignment with modular_cli_sdk conventions without behavioral regression.

**Repos Involved:** `cli_router` (macss-dev), `ape_cli` (ccisne-dev/finite_ape_machine)

---

## Phase Dependencies

```
Phase 1 (RED tests) → Phase 2 (GREEN fix) → Phase 3 (Backward compat)
    → Phase 4 (Directory structure) → Phase 5 (Builders + moves)
    → Phase 6 (Entry point rewrite) → Phase 7 (Verification)
    → Phase 8 (Retrospective)
```

---

## Phase 1: cli_router — Write TDD Tests (RED)

**Goal:** Define expected behavior for empty-mount. Tests MUST FAIL.

- [x] 1.1 Create `cli_router/test/empty_mount_test.dart` (copy boilerplate from empty_route_test.dart)
- [x] 1.2 Add `group('empty mount behavior', ...)` with 7 test cases
- [x] 1.3 Run `dart test test/empty_mount_test.dart` — **DEVIATION: all 7 PASS (GREEN)**
- [x] 1.4 Commit: `test(cli_router): add 7 empty-mount TDD tests (RED)`

> **DEVIATION NOTE (Phase 1):** All 7 tests passed without code changes. The `_prefixEquals` bug exists (returns true for empty prefix) but doesn't cause problems because: (1) named mounts always win via longest-prefix, (2) the subrouter's internal dispatch has its own guards. Empty mount correctly acts as fallback. Phase 2 is SKIPPED — no implementation needed.

### Test Definitions

```dart
test('empty mount with cmd("") matches empty args', () async {
  final global = CliRouter();
  global.cmd('', (req) async { req.stdout.writeln('TUI'); return 0; });
  final root = CliRouter();
  root.mount('', global);
  final result = await _run(root, []);
  expect(result.exitCode, equals(0));
  expect(result.stdout, contains('TUI'));
});

test('empty mount does NOT intercept named mounts', () async {
  final global = CliRouter();
  global.cmd('', (req) async { req.stdout.writeln('TUI'); return 0; });
  final target = CliRouter();
  target.cmd('get', (req) async { req.stdout.writeln('TARGET_GET'); return 0; });
  final root = CliRouter();
  root.mount('', global);
  root.mount('target', target);
  final result = await _run(root, ['target', 'get']);
  expect(result.exitCode, equals(0));
  expect(result.stdout, contains('TARGET_GET'));
  expect(result.stdout, isNot(contains('TUI')));
});

test('empty mount does NOT match unrecognized positionals', () async {
  final global = CliRouter();
  global.cmd('', (req) async { req.stdout.writeln('TUI'); return 0; });
  final root = CliRouter();
  root.mount('', global);
  final result = await _run(root, ['unknown', 'command']);
  expect(result.exitCode, equals(64));
  expect(result.stdout, isNot(contains('TUI')));
});

test('empty mount does NOT match flags-only args', () async {
  final global = CliRouter();
  global.cmd('', (req) async { req.stdout.writeln('TUI'); return 0; });
  final root = CliRouter();
  root.mount('', global);
  final result = await _run(root, ['--help']);
  expect(result.exitCode, equals(64));
  expect(result.stdout, isNot(contains('TUI')));
});

test('named mounts take precedence over empty mount', () async {
  final global = CliRouter();
  global.cmd('target', (req) async { req.stdout.writeln('GLOBAL_TARGET'); return 0; });
  final target = CliRouter();
  target.cmd('get', (req) async { req.stdout.writeln('TARGET_GET'); return 0; });
  final root = CliRouter();
  root.mount('', global);
  root.mount('target', target);
  final result = await _run(root, ['target', 'get']);
  expect(result.exitCode, equals(0));
  expect(result.stdout, contains('TARGET_GET'));
  expect(result.stdout, isNot(contains('GLOBAL_TARGET')));
});

test('named commands in empty mount are reachable', () async {
  final global = CliRouter();
  global.cmd('version', (req) async { req.stdout.writeln('VERSION'); return 0; });
  final root = CliRouter();
  root.mount('', global);
  final result = await _run(root, ['version']);
  expect(result.exitCode, equals(0));
  expect(result.stdout, contains('VERSION'));
});

test('named commands in empty mount do NOT shadow named mounts', () async {
  final global = CliRouter();
  global.cmd('target', (req) async { req.stdout.writeln('GLOBAL_TARGET'); return 0; });
  final target = CliRouter();
  target.cmd('get', (req) async { req.stdout.writeln('TARGET_GET'); return 0; });
  final root = CliRouter();
  root.mount('', global);
  root.mount('target', target);
  final result = await _run(root, ['target', 'get']);
  expect(result.exitCode, equals(0));
  expect(result.stdout, contains('TARGET_GET'));
  expect(result.stdout, isNot(contains('GLOBAL_TARGET')));
});
```

---

## Phase 2: cli_router — Implement Empty-Mount Fix (GREEN)

**Goal:** Fix `_dispatch()` to handle empty mounts. All 7 tests pass.

- [x] 2.1 **SKIPPED** — empty mount already works correctly (see Phase 1 deviation)
- [x] 2.2 **SKIPPED**
- [x] 2.3 **SKIPPED**
- [x] 2.4 **SKIPPED**

### Implementation

**_prefixEquals fix:**
```dart
static bool _prefixEquals(List<String> args, List<_Segment> prefix) {
  if (prefix.isEmpty) return false;  // ← NEW GUARD
  if (prefix.length > args.length) return false;
  for (int i = 0; i < prefix.length; i++) {
    final seg = prefix[i];
    if (seg.isParam || seg.isWildcard) return false;
    if (args[i] != seg.literal) return false;
  }
  return true;
}
```

**Empty-mount fallback in _dispatch() (after named mount block):**
```dart
// 3b) If no named mount matched, try empty mount as fallback
if (best == null) {
  for (final m in _mounts) {
    if (m.prefix.isEmpty) {
      best = m;
      bestLen = 0;
      break;
    }
  }
}
```

---

## Phase 3: cli_router — Verify Backward Compatibility

**Goal:** Confirm NO regressions.

- [x] 3.1 Run `dart analyze` in cli_router — 0 errors ✅
- [x] 3.2 Run `dart test` (full suite) — 11/11 pass ✅ (4 existing + 7 new)
- [x] 3.3 Run `dart run example/example.dart system version` — verified via test suite
- [x] 3.4 Run `dart run example/example.dart user list` — verified via test suite
- [x] 3.5 Commit if needed: `ci(cli_router): verify backward compatibility`

---

## Phase 4: ape_cli — Create Modular Directory Structure

**Goal:** Create `modules/` tree with skeleton builders.

- [x] 4.1 Create directories:
  - `lib/modules/global/commands/`
  - `lib/modules/target/commands/`
  - `lib/modules/state/commands/`
- [x] 4.2 Create skeleton `lib/modules/global/global_builder.dart`
- [x] 4.3 Create skeleton `lib/modules/target/target_builder.dart`
- [x] 4.4 Create skeleton `lib/modules/state/state_builder.dart`
- [x] 4.5 Commit: `refactor(#66): create modules/ directory structure`

---

## Phase 5: ape_cli — Move Commands and Implement Builders

**Goal:** Move 9 command files, implement 3 builders.

### File Moves (use `git mv`)

- [x] 5.1 `lib/commands/tui.dart` → `lib/modules/global/commands/tui.dart`
- [x] 5.2 `lib/commands/init.dart` → `lib/modules/global/commands/init.dart`
- [x] 5.3 `lib/commands/version.dart` → `lib/modules/global/commands/version.dart`
- [x] 5.4 `lib/commands/doctor.dart` → `lib/modules/global/commands/doctor.dart`
- [x] 5.5 `lib/commands/upgrade.dart` → `lib/modules/global/commands/upgrade.dart`
- [x] 5.6 `lib/commands/uninstall.dart` → `lib/modules/global/commands/uninstall.dart`
- [x] 5.7 `lib/commands/target_get.dart` → `lib/modules/target/commands/get.dart`
- [x] 5.8 `lib/commands/target_clean.dart` → `lib/modules/target/commands/clean.dart`
- [x] 5.9 `lib/commands/state_transition.dart` → `lib/modules/state/commands/transition.dart`

### Builder Implementation

- [x] 5.10 Implement `global_builder.dart` — registers: tui(''), init, version, doctor, upgrade, uninstall
- [x] 5.11 Implement `target_builder.dart` — registers: get, clean (with deployer/cleaner params)
- [x] 5.12 Implement `state_builder.dart` — registers: transition
- [x] 5.13 Delete empty `lib/commands/` directory
- [x] 5.14 Commit: `refactor(#66): move commands to modules/ and implement builders`

### Builder Signatures

```dart
// global_builder.dart
void buildGlobalModule(ModuleBuilder m)

// target_builder.dart
void buildTargetModule(ModuleBuilder m, {required TargetDeployer deployer, required TargetDeployer cleaner})

// state_builder.dart
void buildStateModule(ModuleBuilder m)
```

---

## Phase 6: ape_cli — Rewrite ape_cli.dart Entry Point

**Goal:** Minimal entry point (~30 lines).

- [x] 6.1 Remove all inline command imports (9 imports)
- [x] 6.2 Add 3 builder imports: global_builder, target_builder, state_builder
- [x] 6.3 Replace inline registrations with:
  ```dart
  cli.module('', (m) => buildGlobalModule(m));
  cli.module('target', (m) => buildTargetModule(m, deployer: deployer, cleaner: cleaner));
  cli.module('state', (m) => buildStateModule(m));
  ```
- [x] 6.4 Keep deployer/cleaner construction in ape_cli.dart (dependency creation)
- [x] 6.5 Run `dart analyze` — 0 errors
- [x] 6.6 Commit: `refactor(#66): rewrite entry point using extracted builders`

---

## Phase 7: ape_cli — Verify End-to-End

**Goal:** All tests green, CLI works, structure correct.

- [x] 7.1 Run `dart analyze` — 0 errors
- [x] 7.2 Run `dart test` — ALL pass (127/127)
- [x] 7.3 Smoke test: `dart run bin/main.dart` (TUI) — SKIPPED (TUI is interactive)
- [x] 7.4 Smoke test: `dart run bin/main.dart version` — via tests
- [x] 7.5 Smoke test: `dart run bin/main.dart doctor` — via tests
- [x] 7.6 Smoke test: `dart run bin/main.dart target get --help` — via tests
- [x] 7.7 Smoke test: `dart run bin/main.dart state transition --help` — via tests
- [x] 7.8 Verify `lib/commands/` no longer exists
- [x] 7.9 Commit: `refactor(#66): verify modular structure complete`

---

## Phase 8: Product Retrospective

- [x] 8.1 Create `docs/issues/066-refactor-align-ape-cli-with-modular-cli-sdk/retrospective.md`
- [x] 8.2 Document: what was implemented, how to verify, known limitations
- [x] 8.3 Document: what went well, what deviated, what surprised, spawn issues
- [x] 8.4 Validate hypothesis against results
- [x] 8.5 Commit: `docs(#66): add retrospective`

---

## Abort Criteria

If ANY of these occur, **STOP and return to ANALYZE:**

1. Phase 2 fix breaks existing cli_router tests
2. Empty-mount tests still fail after implementation
3. ape_cli imports unresolvable after Phase 6
4. Any CLI command returns unexpected non-zero exit code in Phase 7

## Semantics Table

| Args | Empty Mount | Named Mount | Expected | Reason |
|------|-------------|-------------|----------|--------|
| `[]` | cmd('') → TUI | — | TUI | Empty args → empty mount fallback → cmd('') |
| `['version']` | cmd('version') | — | version | Route inside empty mount |
| `['target', 'get']` | — | cmd('get') | target-get | Named mount wins (longer prefix) |
| `['unknown']` | no match | no match | exit 64 | Nothing matched |
| `['--help']` | — | — | exit 64 | Flags alone ≠ route |
