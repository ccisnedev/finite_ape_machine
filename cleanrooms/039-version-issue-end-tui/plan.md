---
id: plan
title: Plan v0.0.9 - Version fix, skill issue-end, TUI
date: 2026-04-17
status: draft
tags: [plan, v0.0.9, version, tui, skill]
author: descartes
---

# Plan: v0.0.9

**Issue:** #39 — v0.0.9: fix version inconsistency + skill issue-end + TUI ape  
**Branch:** 039-version-issue-end-tui  
**Date:** 2026-04-17  
**Input:** [diagnosis.md](analyze/diagnosis.md), [scope-analysis.md](analyze/scope-analysis.md)  
**Approach:** Test-Driven Development (RED → GREEN → REFACTOR)

---

## Hypothesis

If we implement these phases in order—retroactive docs, version SSoT, TUI command, skill issue-end, release—we will resolve all diagnosed inconsistencies and deliver the three features.

---

## Phase 0: Retroactive Documentation (v0.0.8)

**Purpose:** Establish historical accuracy before proceeding.

**Entry criteria:**
- CHANGELOG.md exists
- v0.0.8 code merged to main (PR #38)

**Steps:**

- [x] **0.1: Document what v0.0.8 actually shipped**
  - Add CHANGELOG entry for v0.0.8 between 0.0.7 and the upcoming 0.0.9
  - Content:
    ```markdown
    ## [0.0.8]
    ### Added
    - `ape doctor` command — verifies prerequisites (ape, git, gh, gh auth, gh copilot)
    - Skill `issue-start` — 8-step protocol for transitioning IDLE → ANALYZE
    ### Changed
    - Updated `ape.agent.md` with doctor checks and issue-start skill reference
    ```

**Verification:**
```bash
grep -A5 "\[0.0.8\]" CHANGELOG.md
# Expected: Shows Added and Changed sections
```

**Risk:** None. Documentation only.

---

## Phase 1: Version Single Source of Truth (TDD)

**Purpose:** Eliminate version duplication. Currently:
- `pubspec.yaml`: 0.0.7
- `lib/commands/version.dart`: `apeVersion = '0.0.7'`
- `lib/commands/doctor.dart`: `apeVersion = '0.0.8'` (inconsistent!)

**Entry criteria:**
- Phase 0 complete
- `lib/src/` directory exists (or can be created)

**Steps:**

- [x] **1.1: Create version constant file**
  - Create `lib/src/version.dart`:
    ```dart
    /// Single source of truth for APE CLI version.
    const String apeVersion = '0.0.9';
    ```

- [x] **1.2: Write version consistency tests FIRST (RED)**
  - Create `test/version_test.dart`:
    ```dart
    // Test: apeVersion constant is exported
    // Test: VersionCommand.execute() returns apeVersion
    // Test: DoctorCommand shows correct version in checks
    // Test: version matches pattern X.Y.Z (semver)
    ```
  - **Run tests → FAIL (RED)** — imports won't resolve yet

- [x] **1.3: Update version.dart to import shared constant (GREEN)**
  - Remove local `const String apeVersion = '0.0.7';`
  - Add `import 'package:ape_cli/src/version.dart';`
  - Export the constant: `export 'package:ape_cli/src/version.dart';`
  - **Run tests → some may pass**

- [x] **1.4: Update doctor.dart to import shared constant (GREEN)**
  - Remove default parameter `apeVersion = '0.0.8'`
  - Import shared constant
  - Update constructor:
    ```dart
    DoctorCommand(
      this.input, {
      ProcessRunner? runProcess,
      String? apeVersionOverride,
    }) : _runProcess = runProcess ?? Process.run,
         apeVersion = apeVersionOverride ?? apeVersionImported;
    ```
  - **Run tests → ALL PASS (GREEN)**

- [x] **1.5: Update existing doctor tests**
  - Ensure `doctor_test.dart` uses version override for isolation
  - **Run tests → still pass**

- [x] **1.6: Refactor and verify (REFACTOR)**
  - `dart format lib/src/version.dart lib/commands/version.dart lib/commands/doctor.dart`
  - `dart analyze`
  - **Run all tests**

**Verification:**
```bash
dart test test/version_test.dart
dart test test/doctor_test.dart
dart analyze
# Expected: All pass, no errors
```

**Test Definitions (Pseudocode):**
```
test_version_constant_exported:
  import version.dart
  assert apeVersion is String
  assert apeVersion matches r'^\d+\.\d+\.\d+$'

test_version_command_returns_constant:
  cmd = VersionCommand(VersionInput())
  output = await cmd.execute()
  assert output.version == apeVersion

test_doctor_shows_correct_version:
  cmd = DoctorCommand(DoctorInput(), runProcess: mockSuccess)
  output = await cmd.execute()
  apeCheck = output.checks.first
  assert apeCheck.name == 'ape'
  assert apeCheck.version == apeVersion
```

**Risk:** Existing tests may hardcode '0.0.8'. Search and update.

---

## Phase 2: TUI Command (TDD)

**Purpose:** Display FSM diagram when `ape` invoked without arguments.

**Entry criteria:**
- Phase 1 complete
- Version constant available for import

**Dependency:** Requires Phase 1 because TUI displays version.

**Steps:**

- [x] **2.1: Write TUI tests FIRST (RED)**
  - Create `test/tui_test.dart`:
    ```dart
    // Test: TuiInput.fromCliRequest() parses successfully
    // Test: TuiOutput contains version string
    // Test: TuiOutput contains FSM diagram markers
    // Test: TuiCommand.execute() returns TuiOutput
    // Test: TuiOutput.exitCode is 0
    // Test: TuiOutput.toJson() has expected structure
    ```
  - **Run tests → FAIL (RED)** — file doesn't exist

- [x] **2.2: Create minimal stubs (compile target)**
  - Create `lib/commands/tui.dart`:
    ```dart
    class TuiInput extends Input { ... }
    class TuiOutput extends Output { ... }
    class TuiCommand implements Command<TuiInput, TuiOutput> {
      @override
      Future<TuiOutput> execute() async => throw UnimplementedError();
    }
    ```
  - **Run tests → compile, but fail at runtime**

- [x] **2.3: Implement TuiInput (GREEN)**
  - Empty input (no flags required)
  - Factory `fromCliRequest()` returns `TuiInput()`

- [x] **2.4: Implement TuiOutput (GREEN)**
  - Fields: `String version`, `String diagram`
  - Method `toJson()` → `{'version': version, 'diagram': diagram}`
  - Getter `exitCode` → `ExitCode.ok`

- [x] **2.5: Implement TuiCommand.execute() (GREEN)**
  - Import `apeVersion` from shared constant
  - Build FSM diagram string (ASCII art):
    ```
    APE v0.0.9
    Finite Ape Machine
    
           ╭──────────────────────────╮
    IDLE → │ Analyze → Plan → Execute │ → EVOLUTION
           ╰──────────────────────────╯
    
    Commands: init, doctor, version
    Run: ape --help
    ```
  - Return `TuiOutput(version: apeVersion, diagram: diagram)`
  - **Run tests → ALL PASS (GREEN)**

- [x] **2.6: Register TUI as empty route**
  - In `lib/ape_cli.dart`, add BEFORE other commands:
    ```dart
    cli.command<TuiInput, TuiOutput>(
      '', // empty route = no args
      (req) => TuiCommand(TuiInput.fromCliRequest(req)),
      description: 'Display APE status and FSM diagram',
    );
    ```

- [x] **2.7: Refactor (REFACTOR)**
  - Extract diagram to separate function or constant
  - `dart format lib/commands/tui.dart lib/ape_cli.dart`
  - `dart analyze`

**Verification:**
```bash
dart test test/tui_test.dart
dart run bin/main.dart
# Expected: FSM diagram with version displayed
dart run bin/main.dart --json
# Expected: {"version": "0.0.9", "diagram": "..."}
```

**Test Definitions (Pseudocode):**
```
test_tui_input_parses:
  req = CliRequest(path: '', flags: {})
  input = TuiInput.fromCliRequest(req)
  assert input != null

test_tui_output_contains_version:
  cmd = TuiCommand(TuiInput())
  output = await cmd.execute()
  assert output.version == apeVersion
  assert output.diagram.contains(apeVersion)

test_tui_output_contains_fsm:
  cmd = TuiCommand(TuiInput())
  output = await cmd.execute()
  assert output.diagram.contains('IDLE')
  assert output.diagram.contains('ANALYZE')
  assert output.diagram.contains('PLAN')
  assert output.diagram.contains('EXECUTE')
  assert output.diagram.contains('EVOLUTION')

test_tui_exit_code:
  output = TuiOutput(version: '0.0.9', diagram: '...')
  assert output.exitCode == 0
```

**Risk:** Empty route registration order matters. Must be registered first to catch "no args" case. Verify cli_router behavior.

---

## Phase 3: Skill issue-end

**Purpose:** Counterpart to `issue-start`. Guides cycle completion.

**Entry criteria:**
- Phases 1-2 complete
- `assets/skills/` directory exists

**Steps:**

- [x] **3.1: Create skill directory**
  - `mkdir -p assets/skills/issue-end/`

- [x] **3.2: Create SKILL.md with frontmatter**
  - File: `assets/skills/issue-end/SKILL.md`
  - YAML frontmatter:
    ```yaml
    ---
    name: issue-end
    description: 'Protocol for ending an APE cycle. Use when: all plan.md checkboxes are complete, ready to release. Guides: version bump, changelog, commit, PR, EVOLUTION transition.'
    ---
    ```

- [x] **3.3: Document preconditions section**
  - State must be EXECUTE
  - All plan.md checkboxes must be checked
  - All tests must pass

- [x] **3.4: Document Step 1 — Verify EXECUTE phase**
  ```markdown
  ## Step 1: Verify Phase
  
  Read `.ape/state.yaml` and confirm:
  - `phase: EXECUTE`
  
  If not EXECUTE, abort with message:
  "Cannot end cycle: current phase is {phase}, expected EXECUTE"
  ```

- [x] **3.5: Document Step 2 — Verify plan completion**
  ```markdown
  ## Step 2: Verify Plan Completion
  
  Read `docs/issues/{slug}/plan.md` and verify:
  - All checkboxes `- [x]` are now `- [x]`
  
  If incomplete checkboxes remain, list them and abort.
  ```

- [x] **3.6: Document Step 3 — Determine version bump**
  ```markdown
  ## Step 3: Determine Version Bump
  
  Ask user to confirm semver bump type:
  - PATCH: bug fixes only
  - MINOR: new features, backward compatible
  - MAJOR: breaking changes
  
  Calculate new version from current `apeVersion`.
  ```

- [x] **3.7: Document Step 4 — Update version files**
  ```markdown
  ## Step 4: Update Version
  
  Update both files with new version:
  1. `pubspec.yaml`: `version: X.Y.Z`
  2. `lib/src/version.dart`: `const String apeVersion = 'X.Y.Z';`
  ```

- [x] **3.8: Document Step 5 — Update CHANGELOG**
  ```markdown
  ## Step 5: Update CHANGELOG
  
  Add entry at top of CHANGELOG.md:
  ```
  ## [X.Y.Z]
  ### Added
  - {list new features}
  ### Changed
  - {list changes}
  ### Fixed
  - {list bug fixes}
  ```
  
  Derive content from plan.md phases.
  ```

- [x] **3.9: Document Step 6 — Commit**
  ```markdown
  ## Step 6: Commit Release
  
  ```bash
  git add -A
  git commit -m "vX.Y.Z: {summary from issue title}"
  ```
  
  Commit message format: `vX.Y.Z: <issue-title-summary>`
  ```

- [x] **3.10: Document Step 7 — Push**
  ```markdown
  ## Step 7: Push Branch
  
  ```bash
  git push -u origin {branch}
  ```
  ```

- [x] **3.11: Document Step 8 — Create PR**
  ```markdown
  ## Step 8: Create Pull Request
  
  ```bash
  gh pr create \
    --title "vX.Y.Z: {issue-title}" \
    --body "Closes #{issue-number}
  
  ## Summary
  {brief summary of changes}
  
  ## Checklist
  - [x] All tests pass
  - [x] CHANGELOG updated
  - [x] Version bumped
  "
  ```
  ```

- [x] **3.12: Document Step 9 — Transition to EVOLUTION**
  ```markdown
  ## Step 9: Transition to EVOLUTION
  
  Update `.ape/state.yaml`:
  ```yaml
  phase: EVOLUTION
  issue: {issue-number}
  branch: {branch}
  version: X.Y.Z
  ```
  
  Announce: `[APE: EVOLUTION]`
  
  EVOLUTION phase runs automatically after PR approval.
  When PR is merged, cycle terminates → IDLE.
  ```

- [x] **3.13: Update assets_test.dart**
  - Increment expected skill count from 3 to 4
  - Add test for `issue-end` skill existence

**Verification:**
```bash
test -f assets/skills/issue-end/SKILL.md && echo "Skill exists"
dart test test/assets_test.dart
# Expected: All asset tests pass
```

**Risk:** Skill is documentation only, no code execution. User must follow steps manually.

---

## Phase 4: Release Preparation (v0.0.9)

**Purpose:** Finalize and ship.

**Entry criteria:**
- Phases 0-3 complete
- All tests pass

**Steps:**

- [x] **4.1: Add CHANGELOG entry for v0.0.9**
  ```markdown
  ## [0.0.9]
  ### Added
  - `ape` TUI — displays FSM diagram when invoked without arguments
  - Skill `issue-end` — 9-step protocol for completing APE cycles
  ### Fixed
  - Version inconsistency: unified to single source of truth in `lib/src/version.dart`
  ### Changed
  - `ape doctor` now imports shared version constant
  - `ape version` now imports shared version constant
  ```

- [x] **4.2: Update pubspec.yaml version**
  - Change `version: 0.0.7` to `version: 0.0.9`

- [x] **4.3: Run full test suite**
  ```bash
  dart pub get
  dart analyze
  dart test
  ```
  - All tests must pass

- [x] **4.4: Manual smoke test**
  ```bash
  dart run bin/main.dart
  # Expected: TUI with FSM diagram, version 0.0.9
  
  dart run bin/main.dart version
  # Expected: 0.0.9
  
  dart run bin/main.dart doctor
  # Expected: ape check shows 0.0.9
  
  dart run bin/main.dart --json
  # Expected: JSON with version and diagram
  ```

**Verification:**
```bash
grep "version: 0.0.9" pubspec.yaml
grep "0.0.9" lib/src/version.dart
grep "\[0.0.9\]" CHANGELOG.md
dart test
# Expected: All assertions true, all tests pass
```

---

## Dependency Graph

```
Phase 0 (Docs)
    │
    ▼
Phase 1 (Version SSoT) ──────┐
    │                        │
    ▼                        │
Phase 2 (TUI) ◀──────────────┘
    │           (needs version)
    ▼
Phase 3 (Skill)
    │
    ▼
Phase 4 (Release)
```

---

## Summary

| Phase | Deliverable | Tests | Risk |
|-------|-------------|-------|------|
| 0 | CHANGELOG v0.0.8 | N/A | None |
| 1 | `lib/src/version.dart` | version_test.dart | Hardcoded versions in tests |
| 2 | `lib/commands/tui.dart` | tui_test.dart | Route order |
| 3 | `assets/skills/issue-end/` | assets_test.dart | None (docs only) |
| 4 | Release v0.0.9 | Full suite | None |

**Total estimated test files:** 2 new (version_test.dart, tui_test.dart), 2 modified (doctor_test.dart, assets_test.dart)

---

## Exit Criteria

Plan is complete when:
1. All phases have checkmarks
2. `dart test` passes (0 failures)
3. `dart analyze` passes (0 errors)
4. Manual smoke tests pass
5. Version shows 0.0.9 in all locations
