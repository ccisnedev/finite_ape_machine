---
id: plan
title: "DESCARTES Plan: Implement ape doctor target verification (Issue #096)"
date: 2026-04-20
status: ready-for-execution
phases: 10
author: DESCARTES
references:
  - diagnosis: docs/issues/096-doctor-target-visibility/analyze/diagnosis.md
  - decisions: D1-D10 in diagnosis.md
  - scenarios: A-D in diagnosis.md
  - source: code/cli/lib/modules/global/commands/doctor.dart
---

# Experimental Plan: ape doctor Target Verification Feature

## Hypothesis

> If we extend DoctorOutput to capture target deployment checks, inject testable filesystem access, implement file-existence verification for agents/skills, discover skills dynamically from Assets, format asymmetric output, and integrate into DoctorCommand.execute(), then doctor will verify target visibility and accurately diagnose when deployment has NOT occurred.

---

## Dependency Graph

```
Phase 1: Data Model
    │
    ├── Phase 2: FS Abstraction
    ├── Phase 3: Init Check
    └── Phase 4: Skill Discovery
            │
        Phase 5: Target Verification Logic
            │
        Phase 6: Output Formatting
            │
        Phase 7: Command Integration
            │
        Phase 8: Tests (RED → GREEN)
            │
        Phase 9: Cross-Platform Validation
            │
        Phase 10: Retrospective
```

---

## Phase 1: Data Model Extension

**Purpose:** Extend `DoctorOutput` to capture target deployment results alongside prerequisite checks.

- [ ] Step 1.1: Create `TargetCheck` value class in `doctor.dart`
  - Fields: `targetName: String`, `agentExists: bool`, `missingSkills: List<String>`, `error: String?`
  - Add `toJson()` method
- [ ] Step 1.2: Extend `DoctorOutput`
  - Add field: `targetChecks: List<TargetCheck>`
  - Update `toJson()` to include targetChecks
  - Update `passed` logic: `passed = prereqPassed && targetChecksPassed`
- [ ] Step 1.3: Verify JSON serialization

**Test pseudocode:**
```dart
test('TargetCheck.toJson() includes missingSkills') {
  final check = TargetCheck(targetName: 'copilot', agentExists: true, missingSkills: ['memory-read']);
  expect(check.toJson()['missingSkills'], ['memory-read']);
}
```

**Risk:** None — pure data model.

---

## Phase 2: Filesystem Abstraction for Testability

**Purpose:** Injectable interface for file operations so target verification can be unit-tested.

- [ ] Step 2.1: Create `FileSystemOps` abstract interface
  - Methods: `fileExists(path)`, `directoryExists(path)`, `homeDirectory()`
  - Location: `code/cli/lib/targets/file_system_ops.dart`
- [ ] Step 2.2: Create `RealFileSystemOps` implementation
  - `homeDirectory()`: `Platform.environment['HOME']` (Unix) or `USERPROFILE` (Windows)
  - Use `dart:io` for existence checks
- [ ] Step 2.3: Create `MockFileSystemOps` for tests
  - Configurable file/dir existence via setters
- [ ] Step 2.4: Update `DoctorCommand` to accept `FileSystemOps`
  - Constructor parameter with default `RealFileSystemOps()`

**Test pseudocode:**
```dart
test('RealFileSystemOps.homeDirectory() returns valid path') {
  expect(RealFileSystemOps().homeDirectory(), isNotEmpty);
}
```

**Risk:** Medium — cross-platform path resolution. Mitigation: use `package:path`.

---

## Phase 3: Init Directory Check

**Purpose:** Verify `.ape/` directory exists (implies `ape init` has run).

- [ ] Step 3.1: Add `_checkInitialization()` method to `DoctorCommand`
  - Check `directoryExists('.ape')` in cwd
  - Return `({bool exists, String? remediation})`
- [ ] Step 3.2: If missing, add failed check with remediation `→ Run 'ape init'`

**Test pseudocode:**
```dart
test('Doctor detects missing .ape/ and suggests ape init (Scenario C)') {
  mock.setDirectoryExists('.ape', false);
  final output = await cmd.execute();
  expect(output.toText(), contains('ape not initialized'));
  expect(output.toText(), contains("Run 'ape init'"));
}
```

**Risk:** Low.

---

## Phase 4: Dynamic Skill Discovery

**Purpose:** Discover expected skills from asset tree (D7: no hardcoded list).

- [ ] Step 4.1: Inject `Assets` into `DoctorCommand`
  - Constructor parameter with default from resolved executable
- [ ] Step 4.2: Create `_getExpectedSkills()` method
  - Calls `assets.listDirectory('skills')`
  - Handles exception gracefully (returns empty list)
- [ ] Step 4.3: Add test setup with temporary asset structure

**Test pseudocode:**
```dart
test('DoctorCommand discovers skills dynamically from Assets') {
  final skills = cmd._getExpectedSkills();
  expect(skills, contains('issue-start'));
}
```

**Risk:** Medium — asset root path detection at runtime.

---

## Phase 5: Target Verification Logic

**Purpose:** Core logic — check if agent and skills exist in deployment directories.

- [ ] Step 5.1: Create `_verifyTargetDeployment(adapter, fs, expectedSkills)` method
- [ ] Step 5.2: Implement verification logic
  - Check agent: `fs.fileExists(agentPath)`
  - For each skill: `fs.fileExists(skillPath)`
  - Collect missing skills
  - Return `TargetCheck`
- [ ] Step 5.3: Use `package:path` for cross-platform path joins
- [ ] Step 5.4: Error handling (try-catch for permission denied, etc.)

**Test pseudocode:**
```dart
test('Scenario D: agent OK, skill missing') {
  mock.setFileExists('agents/ape.agent.md', true);
  mock.setFileExists('skills/memory-read/SKILL.md', false);
  final check = await cmd._verifyTargetDeployment(adapter, mock, ['memory-read']);
  expect(check.agentExists, true);
  expect(check.missingSkills, ['memory-read']);
}
```

**Risk:** Medium — cross-platform paths.

---

## Phase 6: Output Formatting (Asymmetric Verbosity)

**Purpose:** Format target results per D6 — clean when OK, detailed when error.

- [ ] Step 6.1: Implement `TargetCheck.toText(totalSkills)`
  - Success: `✓ copilot: agent + N skills deployed`
  - Failure: `✗ copilot: agent not deployed` / `✗ copilot: missing skills: x, y`
  - Remediation: `  → Run 'ape target get' to deploy`
- [ ] Step 6.2: Update `DoctorOutput.toText()` to include `Checking targets...` section
- [ ] Step 6.3: Add init remediation line: `✗ ape not initialized → Run 'ape init'`

**Test pseudocode:**
```dart
test('Scenario A output is clean') {
  expect(output.toText(), contains('✓ copilot: agent + 4 skills deployed'));
  expect(output.toText(), contains('All checks passed.'));
}
test('Scenario B output shows remediation') {
  expect(output.toText(), contains("Run 'ape target get' to deploy"));
}
```

**Risk:** Low.

---

## Phase 7: Command Integration

**Purpose:** Wire target checks into `DoctorCommand.execute()`.

- [ ] Step 7.1: Add init check to prerequisites section
- [ ] Step 7.2: Add target verification loop after prerequisites
  - Iterate active adapters (only CopilotAdapter per D2)
  - Discover skills, verify deployment, collect results
- [ ] Step 7.3: Construct `DoctorOutput` with targetChecks
- [ ] Step 7.4: Handle scenario where .ape/ missing but targets still checked (D10)

**Test pseudocode:**
```dart
test('Scenario A: full success → exit 0') {
  // All prereqs + all targets pass
  expect(output.passed, true);
  expect(output.exitCode, 0);
}
test('Scenario C: no init + no deploy → exit 1') {
  expect(output.passed, false);
  expect(output.toText(), contains('ape not initialized'));
  expect(output.toText(), contains('agent not deployed'));
}
```

**Risk:** Medium — init check naming (use 'ape init' to avoid conflict with 'ape' version check).

---

## Phase 8: Complete Test Suite (RED → GREEN)

**Purpose:** Comprehensive tests covering all 4 scenarios + edge cases.

- [ ] Step 8.1: Write test stubs for Scenarios A-D (RED)
- [ ] Step 8.2: Run tests, observe failures
- [ ] Step 8.3: Implement test bodies (GREEN)
- [ ] Step 8.4: Add edge case tests
  - Permission denied on .copilot/
  - Asset root invalid
  - Empty skills directory
- [ ] Step 8.5: Test output formatting matches expected
- [ ] Step 8.6: Test JSON output includes targetChecks

---

## Phase 9: Cross-Platform Validation

**Purpose:** Verify on Windows, Linux, macOS.

- [ ] Step 9.1: Run tests on Windows
- [ ] Step 9.2: Run tests on Linux
- [ ] Step 9.3: Manual test on developer machine
- [ ] Step 9.4: Document platform gotchas

**Risk:** Medium — CI filesystem permissions.

---

## Phase 10: Retrospective & Documentation

- [ ] Step 10.1: Review against hypothesis
- [ ] Step 10.2: Document lessons learned
- [ ] Step 10.3: Prepare changelog entry
- [ ] Step 10.4: Produce retrospective.md

---

## Risk Matrix

| Phase | Risk | Severity | Mitigation |
|-------|------|----------|-----------|
| 2 | Windows path handling | Medium | Use `package:path` |
| 4 | Asset root discovery | Medium | Inject Assets; fallback |
| 5 | Race condition during deploy | Low | Acceptable for v0.0.x |
| 7 | Init check naming conflict | Medium | Use 'ape init' |

## TDD Applicability

- **RED→GREEN:** Phase 5 (core logic), Phase 8 (test suite)
- **No TDD:** Phase 1 (data model), Phase 2 (infrastructure), Phase 6 (UI)
