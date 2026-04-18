---
id: diagnosis
title: "Diagnosis: v0.0.8 — ape doctor + skill issue-start + IDLE triage"
date: 2026-04-17
status: active
tags: [diagnosis, v0.0.8, doctor, skill, idle, triage]
author: socrates
---

# Diagnosis: v0.0.8

**Issue:** #37 — v0.0.8: ape doctor + skill issue-start + IDLE triage
**Branch:** 037-doctor-issue-start
**Date:** 2026-04-17

---

## 1. Problem Statement

The APE scheduler operates in a five-state FSM (IDLE → ANALYZE → PLAN → EXECUTE → EVOLUTION). The IDLE state performs **triage**: understanding what the user needs and preparing infrastructure before transitioning to ANALYZE.

Currently:
- The `ape.agent.md` references `ape issue start <NNN>` which **does not exist** as a CLI command
- There is no `ape doctor` command to verify prerequisites
- There is no skill document defining the infrastructure creation process

**v0.0.8 must deliver:**
1. `ape doctor` — CLI command verifying prerequisites
2. `issue-start` skill — Document defining infrastructure creation steps
3. Updated `ape.agent.md` — Fix references to non-existent commands

---

## 2. Scope

### In Scope

| Deliverable | Type | Description |
|-------------|------|-------------|
| `ape doctor` | Dart CLI command | Verify: ape version, git, gh, gh auth, gh copilot |
| `issue-start` skill | Asset (.md) | Steps for: read issue, create branch, create folder, update state.yaml |
| `ape.agent.md` updates | Asset (.md) | Fix IDLE section, remove `ape issue start` refs |

### Out of Scope

- `ape issue start` CLI command (not needed — skill handles it)
- `ape issue create` CLI command (use `gh issue create` directly)
- TUI mode
- state.yaml parsing (reading state.yaml not required in v0.0.8)

---

## 3. Technical Decisions

### D1: Add `yaml` package

**Decision:** Add `yaml` package via `dart pub add yaml`.

**Rationale:** The `issue-start` skill updates `.ape/state.yaml`. While v0.0.8 skill writes raw YAML string (like `init.dart` does), future versions will need to parse state.yaml. Adding the dependency now is forward-compatible.

**Note:** For v0.0.8, the skill instructs the scheduler to write state.yaml as a raw string. No YAML parsing required yet.

### D2: Inject `ProcessRunner` for testability

**Decision:** `DoctorCommand` receives a `ProcessRunner` function via constructor.

**Pattern:**
```dart
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
- Tests inject a fake that returns controlled results
- Production uses default `Process.run`
- No mocking framework dependency (no mocktail/mockito)
- Follows existing codebase patterns (`upgrade.dart`, `uninstall.dart` use Process.run)

### D3: No `ape issue start` CLI command

**Decision:** Infrastructure creation is a **skill**, not a CLI command.

**Rationale:**
- The scheduler APE operates in IDLE state
- It reads skills and executes them step by step
- A CLI command would duplicate what `gh` and `git` already do
- Skills are declarative; the scheduler adapts to context

---

## 4. `ape doctor` Specification

### Command Signature

```bash
ape doctor
```

### Checks (in order)

| # | Check | Command | Success Condition |
|---|-------|---------|-------------------|
| 1 | APE version | (internal) | Always passes, outputs version |
| 2 | git | `git --version` | Exit code 0 |
| 3 | gh | `gh --version` | Exit code 0 |
| 4 | gh auth | `gh auth status` | Exit code 0 |
| 5 | Copilot CLI | `gh copilot --version` | Exit code 0 |

### Output

**Success (all pass):**
```
✓ ape 0.0.8
✓ git 2.43.0
✓ gh 2.45.0
✓ gh auth (authenticated)
✓ gh copilot 1.0.0

All checks passed.
```
Exit code: 0

**Failure (first failure stops):**
```
✓ ape 0.0.8
✓ git 2.43.0
✗ gh not found

Run 'winget install GitHub.cli' to install GitHub CLI.
```
Exit code: 1

### JSON Output

With `--json`:
```json
{
  "checks": [
    {"name": "ape", "passed": true, "version": "0.0.8"},
    {"name": "git", "passed": true, "version": "2.43.0"},
    {"name": "gh", "passed": false, "error": "not found"}
  ],
  "passed": false
}
```

### Files

| File | Purpose |
|------|---------|
| `lib/commands/doctor.dart` | DoctorInput, DoctorOutput, DoctorCommand |
| `lib/ape_cli.dart` | Register `doctor` command |
| `test/doctor_test.dart` | Unit tests with ProcessRunner mock |

---

## 5. `issue-start` Skill Specification

### Location

```
code/cli/assets/skills/issue-start/SKILL.md
```

### Format

Standard skill format with YAML frontmatter:
```yaml
---
name: issue-start
description: 'Protocol for starting work on a GitHub issue. Creates branch, working directory, and transitions to ANALYZE state.'
---
```

### Steps Defined

The skill instructs the scheduler to:

1. **Verify prerequisites**
   - Run `ape doctor` and confirm all checks pass

2. **Identify or create issue**
   - If issue number known: `gh issue view <NNN> --json number,title`
   - If no issue: `gh issue create --title "..." --body "..."`

3. **Generate slug**
   - Take issue title, lowercase, replace spaces with hyphens
   - Limit to 50 characters
   - Remove special characters
   - Example: "Fix login timeout" → `fix-login-timeout`

4. **Create branch**
   - Format: `<NNN>-<slug>` (e.g., `037-fix-login-timeout`)
   - Command: `git checkout -b <NNN>-<slug>`

5. **Create working directory**
   - Path: `docs/issues/<NNN>-<slug>/analyze/`
   - Command: `mkdir -p docs/issues/<NNN>-<slug>/analyze/`

6. **Create index.md**
   - Create `docs/issues/<NNN>-<slug>/analyze/index.md` with standard header

7. **Update state.yaml**
   - Write `.ape/state.yaml`:
     ```yaml
     cycle:
       phase: ANALYZE
       task: "<NNN>"
     
     ready: []
     waiting: []
     complete: []
     ```

8. **Announce transition**
   - Scheduler announces: `[APE: ANALYZE]`

---

## 6. `ape.agent.md` Updates

### Changes Required

| Section | Line(s) | Change |
|---------|---------|--------|
| IDLE | 43 | Remove `ape issue start <NNN>`, reference skill |
| IDLE | 48 | Expand `ape doctor` checks list |
| IDLE | New | Add instruction to read `issue-start` skill |
| Directory Structure | 201 | Remove `ape issue start` reference |
| Transitions | 159 | Add IDLE → ANALYZE effect |

### IDLE Section Rewrite

Replace current step 4:
```markdown
4. Once the issue is identified, prepare infrastructure: `ape issue start <NNN>` (creates branch, checkout, working directory).
```

With:
```markdown
4. Once the issue is identified, read the `issue-start` skill and execute its steps:
   - Create branch: `git checkout -b <NNN>-<slug>`
   - Create folder: `mkdir -p docs/issues/<NNN>-<slug>/analyze/`
   - Create `index.md` with standard header
   - Update `.ape/state.yaml` with `phase: ANALYZE` and `task: "<NNN>"`
```

---

## 7. Dependencies

### New Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `yaml` | ^3.0.0 | Future: parse state.yaml (not used in v0.0.8) |

### Existing Dependencies (no change)

- `modular_cli_sdk: ^0.2.0`
- `cli_router: ^0.0.2`
- `path: ^1.9.1`

---

## 8. Test Strategy

### `ape doctor` Tests

| Test | ProcessRunner Returns | Expected |
|------|----------------------|----------|
| All pass | All exit 0 with versions | Exit 0, all ✓ |
| git missing | git exits 1 | Exit 1, ✗ at git |
| gh missing | gh exits 1 | Exit 1, ✗ at gh |
| gh auth fails | gh auth exits 1 | Exit 1, ✗ at gh auth |
| copilot missing | gh copilot exits 1 | Exit 1, ✗ at copilot |
| JSON mode | All exit 0 | JSON object with checks array |

### Test File

`test/doctor_test.dart` using injected `ProcessRunner`:
```dart
test('fails when git is missing', () async {
  final runner = (String exe, List<String> args, {String? workingDirectory}) async {
    if (exe == 'git') return ProcessResult(1, 1, '', 'not found');
    return ProcessResult(0, 0, 'v1.0.0', '');
  };
  
  final cmd = DoctorCommand(DoctorInput(), runProcess: runner);
  final output = await cmd.execute();
  
  expect(output.passed, isFalse);
  expect(output.checks.first.name, 'ape');
  expect(output.checks[1].passed, isFalse);
});
```

---

## 9. Risks

| Risk | Mitigation |
|------|------------|
| `gh copilot` not installed on user machine | Clear error message with install instructions |
| state.yaml format changes | Use raw string write (same as init.dart) |
| Skill not deployed | Included in `ape target get` deployment |

---

## 10. References

| Document | Purpose |
|----------|---------|
| [scope-v008.md](scope-v008.md) | Scope definition |
| [codebase-analysis.md](codebase-analysis.md) | Existing patterns |
| [decisions.md](decisions.md) | Technical decisions D1-D3 |
| [idle-analysis.md](idle-analysis.md) | Gap analysis of ape.agent.md |
| [ape-cli-spec.md](../../../references/ape-cli-spec.md) | Full CLI specification |

---

## 11. Acceptance Criteria

### `ape doctor`
- [ ] Command registered in ape_cli.dart
- [ ] Checks ape version, git, gh, gh auth, gh copilot
- [ ] Exits 0 on all pass, 1 on first failure
- [ ] Supports `--json` flag
- [ ] Tests pass with ProcessRunner injection

### `issue-start` skill
- [ ] File exists at `assets/skills/issue-start/SKILL.md`
- [ ] Follows standard skill format (YAML frontmatter)
- [ ] Documents all 8 steps
- [ ] Deployed by `ape target get`

### `ape.agent.md` updates
- [ ] No references to `ape issue start`
- [ ] IDLE section references skill
- [ ] `ape doctor` checks list complete
- [ ] IDLE → ANALYZE transition effect documented
