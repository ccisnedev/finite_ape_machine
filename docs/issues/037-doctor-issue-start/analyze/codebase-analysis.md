---
id: codebase-analysis
title: "Codebase analysis for ape doctor and ape issue start"
date: 2026-04-17
status: active
tags: [cli, doctor, issue-start, process, yaml, testing]
author: socrates
---

# Codebase Analysis for v0.0.8

## 1. Process Execution (shelling out to git/gh)

The codebase already uses `Process.run()` and `Process.runSync()`:

- `upgrade.dart` L149–177: `Process.run()` for ZIP extraction and redeployment
- `uninstall.dart` L100–130: `Process.runSync()` for PowerShell registry operations
- `uninstall.dart` L100: `Process.start()` detached for async cleanup

**Pattern:** Async `Process.run()` for commands that capture output. PowerShell invocations use `-NoProfile -Command`.

**For doctor/issue:** Both need to run `git`, `gh`, `gh auth status`. Use `Process.run()` async pattern.

## 2. YAML Handling

**No `yaml` package in pubspec.yaml.** Current state:

- `init.dart` writes `state.yaml` as raw string concatenation (L136–152)
- Tests verify state.yaml content as string equality, not parsed YAML

**Decision needed:** For `ape issue start` we need to UPDATE state.yaml (change `cycle.task` and `cycle.phase`). Two options:

- **A) Add `yaml` + `yaml_edit` packages** — proper parsing, future-proof
- **B) Read as string, regex/replace** — no new dependency, fragile

Recommendation: **Option A** — state.yaml will grow, and string manipulation won't scale.

## 3. Module Registration Pattern

`ape target get/clean` uses `cli.module('target', ...)` in ape_cli.dart L65–85:

```dart
cli.module('target', (m) {
  m.command<TargetGetInput, TargetGetOutput>('get', ...);
  m.command<TargetCleanInput, TargetCleanOutput>('clean', ...);
});
```

`ape issue start` follows the same pattern:

```dart
cli.module('issue', (m) {
  m.command<IssueStartInput, IssueStartOutput>('start', ...);
});
```

## 4. Positional Argument Parsing

**Critical gap:** No existing command uses positional arguments. All `fromCliRequest` factories ignore the `CliRequest` parameter.

`ape issue start 42` needs to extract `42` from the request. The `CliRequest` interface from `cli_router` must be inspected. Options:

- `req.rest` — remaining args after command matching
- `req.args` — raw argument list
- Needs experimentation/source inspection

## 5. Error Handling Pattern

All commands implement `String? validate()`:
- Return `null` = valid
- Return error string = framework displays and exits with `ExitCode.invalidUsage` (64)

Exit codes via `modular_cli_sdk`:
- `ExitCode.ok` (0) for success
- `ExitCode.invalidUsage` (64) for bad input

For doctor: healthy → exit 0, unhealthy → exit 1 with descriptive message.
For issue start: missing init → validate error, missing issue → execute error.

## 6. Testing Strategy

Current test setup:
- `test: ^1.31.0`, no mocking framework
- Filesystem tests use `Directory.systemTemp.createTempSync()` + tearDown cleanup
- No existing pattern for mocking `Process.run()`

**Options for mocking Process:**
- **A) Inject a `ProcessRunner` interface** — clean, testable, no new deps
- **B) Add `mocktail` package** — heavier but conventional
- **C) Only test parsing/validation, not execution** — pragmatic but incomplete

Recommendation: **Option A** — inject a function or interface for running processes. Same pattern used in many Dart CLIs.

## 7. state.yaml Current Schema

```yaml
cycle:
  phase: IDLE
  task: null

ready: []
waiting: []
complete: []
```

`ape issue start 42` should update to:

```yaml
cycle:
  phase: ANALYZE
  task: "42"
```

## 8. docs Directory Detection

`init.dart` L100–112: `_detectDocsDirectory()` prefers `docs/` over `doc/`, creates `docs/` if neither exists.

`ape issue start` must verify `docs/issues/` exists. If not → error "Run `ape init` first."
