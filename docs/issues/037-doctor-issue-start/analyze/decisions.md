---
id: decisions
title: "Architecture decisions for ape doctor and ape issue start"
date: 2026-04-17
status: active
tags: [decisions, yaml, testing, cli-router, process-runner]
author: socrates
---

# Architecture Decisions

## D1: YAML Parsing — Use `yaml` package

**Decision:** Add `yaml` package via `dart pub add yaml`.

**Context:** `ape issue start` must read and update `.ape/state.yaml` (change `cycle.phase` and `cycle.task`). Currently `init.dart` writes state.yaml as a raw string. No YAML parsing exists in the codebase.

**Rationale:**
- state.yaml will evolve (more fields, nested structures)
- String manipulation (regex/replace) is fragile and error-prone
- `yaml` is a mature, well-maintained Dart package
- The spec (ape-cli-spec.md §2) already lists `yaml` / `yaml_edit` as planned dependencies

**Note:** For writing, we may also need `yaml_edit` if we want to preserve comments and formatting. For v0.0.8, simple read + rewrite may suffice.

## D2: Process Mocking — Inject `ProcessRunner`

**Decision:** Inject a `ProcessRunner` function/interface into command constructors that shell out.

**Context:** Both `ape doctor` and `ape issue start` need to run external commands (`git`, `gh`). Tests must be deterministic without requiring git/gh installed.

**Pattern:**
```dart
/// Function type for running processes.
typedef ProcessRunner = Future<ProcessResult> Function(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
});

class DoctorCommand implements Command<DoctorInput, DoctorOutput> {
  final ProcessRunner runProcess;

  DoctorCommand(this.input, {ProcessRunner? runProcess})
      : runProcess = runProcess ?? Process.run;
}
```

**Rationale:**
- No new dependencies (no mocktail/mockito needed)
- Clean separation of concerns
- Default to `Process.run` in production, inject fake in tests
- Consistent with Dart community patterns (e.g., `package:process`)

**Existing precedent:** `upgrade.dart` and `uninstall.dart` already use `Process.run()` directly but are not unit-tested for process execution. This new pattern improves testability.

## D3: No `ape issue start` CLI command

**Decision:** There is no `ape issue start` command in v0.0.8.

**Context:** The work of creating branch + folder + updating state.yaml is done by the scheduler APE in IDLE state, not by a CLI command.

**Implementation:** A skill document (`skills/issue-start/SKILL.md`) defines the process. The scheduler (Copilot agent) reads and executes it.

**Note:** The `cli_router` dynamic segments (`<param>`) work correctly and can be used in future versions if needed. Investigation confirmed:
- `cli_router` supports `cmd('start <number>', handler)` → `req.param('number')`
- `modular_cli_sdk` passes route strings directly to `cli_router`
- No changes to either package required
