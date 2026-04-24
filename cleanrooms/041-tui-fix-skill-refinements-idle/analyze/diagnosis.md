---
id: diagnosis
title: Diagnosis — v0.0.10 UX fixes + SDK enhancement
date: 2026-04-17
status: active
tags: [diagnosis, sdk, ux, tui, doctor, upgrade]
author: SOCRATES
---

# Diagnosis — v0.0.10

## Problem Statement

APE CLI v0.0.9 has UX issues in text output formatting. Commands display raw JSON field names instead of human-readable output. The root cause is in `modular_cli_sdk` which lacks a mechanism for custom text formatting.

## Scope (Approved)

| # | Item | Type | Priority | Owner |
|---|------|------|----------|-------|
| 1 | SDK: Add `toText()` to Output | Enhancement | P0 | modular_cli_sdk |
| 2 | TUI: Use `toText()` for clean display | Bug fix | P0 | finite_ape_machine |
| 3 | Doctor: Formatted checkmark output | Enhancement | P1 | finite_ape_machine |
| 4 | Upgrade: Progress indicators | Enhancement | P1 | finite_ape_machine |
| 5 | Skill issue-end: Clarify PR create = end | Docs | P2 | finite_ape_machine |

## Deferred (Explicitly)

| Item | Reason |
|------|--------|
| IDLE auto-transition | `.ape/` utility not yet clear |
| `ape init` usefulness | Let utility emerge organically |
| v0.1.0 release | UX must be solid first |

## Root Cause Analysis

### TUI Bug

**Location:** `modular_cli_sdk/lib/src/cli_output_text.dart`

```dart
void writeObject(Map<String, dynamic> object) {
  for (final entry in object.entries) {
    stdout.writeln('${entry.key}: ${entry.value}');
  }
}
```

The SDK iterates ALL `toJson()` fields as `key: value`. This works for simple outputs like `version: 0.0.9` but fails for TUI where we want ONLY the diagram.

**Fix:** Add optional `String? toText()` to `Output`. If present, use it instead of iterating `toJson()`.

### Doctor Output

Same root cause. `DoctorOutput.toJson()` returns:
```json
{"checks": [...], "passed": true}
```

Which renders as:
```
checks: [{name: ape, passed: true, ...}, ...]
passed: true
```

**Fix:** `DoctorOutput.toText()` returns formatted checkmarks.

### Upgrade Progress

Different issue. The command blocks during HTTP download with no feedback.

**Fix:** Use `stdout` directly for progress messages during execution, return final result via `Output`.

## Technical Design

### SDK Change (modular_cli_sdk ^0.2.1)

```dart
// lib/src/output.dart
abstract class Output {
  Map<String, dynamic> toJson();
  int get exitCode;
  
  /// Override for custom text formatting.
  /// If null, TextCliOutput iterates toJson() fields.
  String? toText() => null;  // NEW
}
```

```dart
// lib/src/cli_output_text.dart
void writeObject(Map<String, dynamic> object, {String? textOverride}) {
  if (textOverride != null) {
    stdout.writeln(textOverride);
    return;
  }
  // ... existing iteration logic
}
```

### APE CLI Changes (finite_ape_machine v0.0.10)

```dart
// TuiOutput
@override
String? toText() => _buildDiagram(version);

// DoctorOutput  
@override
String? toText() => _formatChecks(checks, passed);

// UpgradeCommand
// Print progress via stdout during execute(), return final result
```

## Execution Plan (High-Level)

### Phase 1: SDK Enhancement
1. Create issue in modular_cli_sdk repo
2. Implement `toText()` with TDD
3. Bump to ^0.2.1
4. Publish to pub.dev

### Phase 2: APE CLI Updates
1. Update pubspec.yaml to modular_cli_sdk ^0.2.1
2. Implement TuiOutput.toText()
3. Implement DoctorOutput.toText()
4. Add progress to UpgradeCommand
5. Update skill issue-end docs

### Phase 3: Release
1. Bump to v0.0.10
2. Update CHANGELOG
3. Create PR, merge, release

## Risks

| Risk | Mitigation |
|------|------------|
| pub.dev publish fails | Test with `dart pub publish --dry-run` first |
| SDK change breaks consumers | Non-breaking: `toText()` defaults to null |
| Progress output interferes with --json | Progress goes to stderr, result to stdout |

## Success Criteria

- [ ] `ape` displays clean diagram (no "version:", "diagram:" labels)
- [ ] `ape doctor` displays checkmarks like flutter doctor
- [ ] `ape upgrade` shows progress messages
- [ ] modular_cli_sdk ^0.2.1 published on pub.dev
- [ ] All tests pass (SDK + CLI)

## References

- [scope-expansion.md](scope-expansion.md) — Full analysis with options
- [modular_cli_sdk](https://pub.dev/packages/modular_cli_sdk) — Current v0.2.0
- [ape-cli-spec.md](../../../references/ape-cli-spec.md) — CLI specification
