# Retrospective: Issue #66

**Issue:** refactor: align ape_cli structure with modular_cli_sdk conventions
**Branch:** `066-refactor-align-ape-cli-with-modular-cli-sdk`
**Date:** 2025-07-17

---

## What Was Implemented

### cli_router (macss-dev)
- 7 regression tests for empty-mount behavior (`test/empty_mount_test.dart`)
- Tests verify: empty-args dispatch, named-mount priority, unrecognized args → exit 64, flags-only → exit 64, named commands reachable via empty mount

### ape_cli (finite_ape_machine)
- Created modular directory structure: `lib/modules/{global,target,state}/commands/`
- Moved 9 command files from flat `lib/commands/` to domain-grouped modules
- Extracted 3 builder functions: `buildGlobalModule`, `buildTargetModule`, `buildStateModule`
- Rewrote `ape_cli.dart` from 117 → 49 lines (3 `cli.module()` registrations)
- Updated 10 test file imports to new paths
- Deleted empty `lib/commands/` directory

### How To Verify

```bash
cd code/cli
dart analyze        # 0 issues
dart test           # 127/127 pass
```

Structure verification:
```
lib/modules/
├── global/
│   ├── global_builder.dart
│   └── commands/
│       ├── tui.dart       → cmd('')
│       ├── init.dart      → cmd('init')
│       ├── version.dart   → cmd('version')
│       ├── doctor.dart    → cmd('doctor')
│       ├── upgrade.dart   → cmd('upgrade')
│       └── uninstall.dart → cmd('uninstall')
├── target/
│   ├── target_builder.dart
│   └── commands/
│       ├── get.dart       → cmd('get')
│       └── clean.dart     → cmd('clean')
└── state/
    ├── state_builder.dart
    └── commands/
        └── transition.dart → cmd('transition')
```

### Known Limitations

- `modules/global/` with `cli.module('', ...)` is an intentional deviation from SDK convention (`ModuleBuilder` typically expects a non-empty module name). This works because cli_router's dispatch correctly handles empty-prefix mounts.
- Dependency injection remains manual (deployer/cleaner constructed in `ape_cli.dart`). Deferred to future issue.

---

## What Went Well

1. **TDD-first approach validated the foundation.** Writing cli_router tests before touching ape_cli gave confidence that the empty-mount pattern works correctly. This prevented wasted effort on an unnecessary fix.

2. **Surgical file moves with `git mv`.** Git tracked all 9 renames, preserving history. The import fixups were mechanical.

3. **Builder extraction pattern.** Extracting `buildGlobalModule`, `buildTargetModule`, `buildStateModule` as top-level functions kept the entry point minimal and each module self-contained.

4. **127 tests passed without regression.** The full test suite — unit + integration — validated the refactoring end-to-end.

---

## What Deviated From The Plan

| Phase | Expected | Actual | Impact |
|-------|----------|--------|--------|
| 1 | Tests RED (7 failing) | Tests GREEN (7 passing) | Phase 2 skipped entirely — no cli_router fix needed |
| 2 | Implement `_prefixEquals` fix + fallback | SKIPPED | Zero changes to cli_router source code |
| 4-6 | Three separate commits | One combined commit | Cleaner git history — phases were interdependent |
| 7 | Manual smoke tests for TUI, version, doctor | Relied on test suite (127 tests) | Interactive TUI not testable in CI context |

**Root cause of Phase 1 deviation:** The `_prefixEquals` bug (returns true for empty prefix) doesn't manifest because: (1) named mounts always win via longest-prefix matching, (2) the subrouter's internal dispatch has its own guards. The theoretical bug is neutralized by the dispatch layering.

---

## What Surprised

1. **cli_router's dispatch is more robust than analyzed.** The Socratic analysis correctly identified the `_prefixEquals` edge case, but underestimated the layered dispatch architecture. The "bug" only exists in isolation — in context, the system self-corrects.

2. **Export vs import.** `version.dart` had both an `import` and an `export` for `../src/version.dart`. The automated import fix caught the `import` but missed the `export` — discovered only via `dart analyze`.

3. **Test imports outnumbered source imports.** 10 test files needed import updates vs 8 source files. The test surface was larger than anticipated.

---

## Spawn Issues

1. **cli_router: `_prefixEquals` returns true for empty prefix** — Not harmful today, but should be documented or guarded for clarity. Low priority.

2. **ape_cli: DI mechanism** — deployer/cleaner construction in `ape_cli.dart` is the last remaining coupling. A future issue could introduce a simple DI container or factory.

3. **barrel exports** — `modular_cli_sdk.dart` re-exports all public types. ape_cli's `modules/` could benefit from a barrel file (`modules.dart`) for cleaner imports in tests. Optional.
