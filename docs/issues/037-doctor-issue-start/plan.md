# Plan: v0.0.8

**Issue:** #37 — v0.0.8: ape doctor + skill issue-start + IDLE triage
**Branch:** 037-doctor-issue-start
**Date:** 2026-04-17
**Input:** [diagnosis.md](analyze/diagnosis.md)
**Approach:** Test-Driven Development (RED → GREEN → REFACTOR) where applicable

---

## Phase 1: Doctor Command Implementation (TDD)

**Entry criteria:**
- `pubspec.yaml` exists and is editable
- `lib/commands/` directory exists
- `test/` directory exists with existing test infrastructure

**Approach:** Test-Driven Development (RED → GREEN → REFACTOR)

**Steps:**

- [x] **1.1: Add yaml dependency**
  - Run `dart pub add yaml` in `code/cli/`
  - Verify `pubspec.yaml` updated

- [x] **1.2: Create minimal stubs (compile target)**
  - Create `lib/commands/doctor.dart` with:
    - `ProcessRunner` typedef (empty)
    - `DoctorCheck` class (minimal fields)
    - `DoctorInput` class (minimal, extends Input)
    - `DoctorOutput` class (minimal, extends Output)
    - `DoctorCommand` class (throws UnimplementedError)
  - Purpose: Allow test file to compile

- [x] **1.3: Write tests FIRST (RED phase)**
  - Create `test/doctor_test.dart`
  - Write test: `all checks pass → exit 0`
  - Write test: `git missing → exit 1`
  - Write test: `gh missing → exit 1`
  - Write test: `gh auth fails → exit 1`
  - Write test: `copilot missing → exit 1`
  - Write test: `toJson() returns correct structure`
  - **Run tests → ALL FAIL (RED)**

- [x] **1.4: Implement DoctorCheck (GREEN)**
  - Fields: `name`, `passed`, `version`, `error`
  - Method: `toJson()`
  - **Run tests → still fail (expected)**

- [x] **1.5: Implement DoctorInput (GREEN)**
  - Extends `Input`
  - Factory `fromCliRequest()` → returns `DoctorInput()`
  - Method `toJson()` → empty map
  - **Run tests → still fail (expected)**

- [x] **1.6: Implement DoctorOutput (GREEN)**
  - Extends `Output`
  - Fields: `List<DoctorCheck> checks`, `bool passed`
  - Method `toJson()` → checks array + passed boolean
  - Getter `exitCode` → 0 if passed, 1 otherwise
  - **Run tests → still fail (expected)**

- [x] **1.7: Implement DoctorCommand.execute() (GREEN)**
  - Constructor accepts optional `ProcessRunner` (default: `Process.run`)
  - Method `validate()` → null
  - Method `execute()`:
    1. Check APE version (internal)
    2. Run `git --version`
    3. Run `gh --version`
    4. Run `gh auth status`
    5. Run `gh copilot --version`
  - Stop at first failure, return DoctorOutput
  - **Run tests → ALL PASS (GREEN)**

- [x] **1.8: Refactor if needed (REFACTOR)**
  - Extract version parsing logic
  - Clean up error messages
  - Run `dart format` and `dart analyze`
  - **Run tests → still pass**

**Verification:**
```bash
cd code/cli && dart test test/doctor_test.dart
# Expected: All tests pass (GREEN)
cd code/cli && dart analyze
# Expected: No errors
```

---

## Phase 2: Doctor CLI Registration

**Entry criteria:**
- Phase 1 complete, all tests pass

**Steps:**

- [x] **2.1: Register doctor command in ape_cli.dart**
  - Import doctor command
  - Add `cli.command<DoctorInput, DoctorOutput>('doctor', ...)`
  - Description: 'Verify prerequisites (ape, git, gh, gh auth, gh copilot)'

- [x] **2.2: Manual integration test**
  - Run `dart run bin/main.dart doctor`
  - Verify output format (✓/✗ for each check)
  - Run `dart run bin/main.dart doctor --json`
  - Verify JSON structure

**Verification:**
```bash
dart run bin/main.dart doctor
# Expected: List of checks with ✓ or ✗
dart run bin/main.dart doctor --json
# Expected: {"checks": [...], "passed": true/false}
```

---

## Phase 3: Issue-Start Skill

**Entry criteria:**
- Phase 2 complete
- `code/cli/assets/skills/` directory exists

**Steps:**

- [x] **3.1: Create skill directory**
  - Create `code/cli/assets/skills/issue-start/`

- [x] **3.2: Create SKILL.md with frontmatter**
  - YAML frontmatter with name, description
  - Follow existing skill format (memory-read, memory-write)

- [x] **3.3: Document all 8 steps**
  1. Verify prerequisites (`ape doctor`)
  2. Identify or create issue (`gh issue view/create`)
  3. Generate slug from title
  4. Create branch (`git checkout -b`)
  5. Create working directory (`mkdir -p`)
  6. Create index.md
  7. Update state.yaml
  8. Announce transition (`[APE: ANALYZE]`)

- [x] **3.4: Verify deployment**
  - Check `build.ps1` copies assets recursively
  - Verified: `Copy-Item -Recurse ... 'assets'`

**Verification:**
- File exists: `code/cli/assets/skills/issue-start/SKILL.md`
- YAML frontmatter is valid
- All 8 steps documented

---

## Phase 4: Update ape.agent.md

**Entry criteria:**
- Phase 3 complete

**Steps:**

- [x] **4.1: Replace IDLE step 4**
  - Remove `ape issue start <NNN>` reference
  - Replace with skill reference and inline steps

- [x] **4.2: Expand ape doctor checks list**
  - List all 5 checks: ape, git, gh, gh auth, gh copilot

- [x] **4.3: Add IDLE → ANALYZE transition effect**
  - Document: state.yaml updated, infrastructure created

- [x] **4.4: Remove stale references**
  - Search for `ape issue start` → removed all
  - Updated Directory Structure section
  - Updated assets_test.dart for new skill count

**Verification:**
```bash
grep -n "ape issue start" code/cli/assets/agents/ape.agent.md
# Expected: 0 results
```

---

## Phase 5: Final Verification & Release

**Entry criteria:**
- Phase 4 complete

**Steps:**

- [x] **5.1: Run full test suite**
  - `dart test` → 88 tests pass
  - `dart analyze` → 0 errors

- [x] **5.2: Manual end-to-end test**
  - `dart run bin/main.dart doctor` works
  - `dart run bin/main.dart doctor --json` works
  - Skill file readable and complete
  - ape.agent.md accurate

- [x] **5.3: Commit and push**
  - Commit message: "v0.0.8: ape doctor + issue-start skill + IDLE updates"

- [x] **5.4: Create PR**
  - PR #38 created: https://github.com/ccisnedev/finite_ape_machine/pull/38

**Verification:**
- All tests pass
- PR created and ready for merge

---

## Risk Mitigation

| Risk | Phase | Mitigation |
|------|-------|------------|
| `gh copilot` not installed | 1 | Clear error message with install URL |
| state.yaml format | 3 | Raw string write (same as init.dart) |
| Skill not deployed | 3 | Verify assets.dart includes skill |
| Stale refs in ape.agent.md | 4 | Grep validation |

---

## Test Pseudocode

### Phase 1: Doctor Tests

```dart
group('DoctorCommand', () {
  test('all checks pass', () async {
    final runner = _fakeRunner(all: true);
    final cmd = DoctorCommand(DoctorInput(), runProcess: runner);
    final out = await cmd.execute();
    expect(out.passed, isTrue);
    expect(out.exitCode, 0);
    expect(out.checks.length, 5);
  });

  test('fails when git missing', () async {
    final runner = _fakeRunner(gitFails: true);
    final cmd = DoctorCommand(DoctorInput(), runProcess: runner);
    final out = await cmd.execute();
    expect(out.passed, isFalse);
    expect(out.exitCode, 1);
    expect(out.checks.where((c) => c.name == 'git').first.passed, isFalse);
  });

  test('fails when gh auth fails', () async {
    final runner = _fakeRunner(ghAuthFails: true);
    final cmd = DoctorCommand(DoctorInput(), runProcess: runner);
    final out = await cmd.execute();
    expect(out.passed, isFalse);
    expect(out.checks.where((c) => c.name == 'gh auth').first.passed, isFalse);
  });
});

ProcessRunner _fakeRunner({bool all = false, bool gitFails = false, bool ghAuthFails = false}) {
  return (String exe, List<String> args, {String? workingDirectory}) async {
    if (gitFails && exe == 'git') return ProcessResult(1, 1, '', 'not found');
    if (ghAuthFails && exe == 'gh' && args.contains('auth')) return ProcessResult(1, 1, '', 'not logged in');
    return ProcessResult(0, 0, 'v1.0.0', '');
  };
}
```
