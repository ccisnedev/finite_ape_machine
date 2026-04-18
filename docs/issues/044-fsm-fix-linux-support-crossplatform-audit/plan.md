---
id: plan
title: "Plan — v0.0.11: FSM fix + Linux support + cross-platform audit"
date: 2026-04-18
status: active
tags: [plan, v0.0.11, fsm, linux, cross-platform, release, ci, platformops]
author: descartes
---

# Plan — v0.0.11: FSM fix + Linux support + cross-platform audit

## Hypothesis

If we implement Track A (FSM documentation fix) and Track B (cross-platform code changes) in the ordered phases below, we will deliver v0.0.11 with a corrected APE state machine, Linux release support, CI safety net, and all cross-platform abstractions — closing issues #43, #30, and #32.

If any phase's verification fails, the experiment returns to analysis.

## Cross-Platform Validation Strategy

WSL is available with Dart SDK 3.11.5 on `linux_x64`. Every TDD phase runs tests on **both** environments:

- **Windows:** `dart test` (native, from PowerShell)
- **Linux:** `wsl -e bash -c "cd /mnt/c/.../finite_ape_machine/code/cli && dart test"` (WSL)

This dual validation catches platform-specific regressions during development, before code reaches CI. CI (`ci.yml`) with `ubuntu-latest` + `windows-latest` remains the definitive gate.

---

## Track A — FSM Fix (ape.agent.md)

Track A is documentation-only. No code compilation, no tests. It modifies the APE agent prompt to reflect decisions D5, D6, D7.

### Phase A1: Rewrite ape.agent.md

**Entry criteria:**
- `diagnosis.md` is committed and approved.
- Branch `044-fsm-fix-linux-support-crossplatform-audit` exists and is checked out.

**Steps:**

- [x] A1.1 — Add END state between EXECUTE and EVOLUTION in the States section.
  - END description: user gate for PR creation.
  - Entry condition: EXECUTE report approved by user.
  - Exit action: user authorizes `gh pr create`.
  - BASHŌ no longer runs `gh pr create` — that moves to END.

- [x] A1.2 — Make EVOLUTION optional.
  - Add rule: if `.ape/config.yaml` has `evolution.enabled: false` (default OFF), skip EVOLUTION and go directly from END → IDLE.
  - Update EVOLUTION section to document this behavior.

- [x] A1.3 — Update Transitions table.
  - Remove: `EXECUTE → EVOLUTION` with PR effect.
  - Add: `EXECUTE → END` (user approves execution report, effect: `git commit`, `git push`).
  - Add: `END → EVOLUTION` (user authorizes PR, effect: `gh pr create`). If EVOLUTION disabled: `END → IDLE`.
  - Add: `END → IDLE` (if EVOLUTION is disabled, after PR).
  - Update illegal transitions if needed.

- [x] A1.4 — Update State Announcement section.
  - Add `[APE: END]` to the list of announcements.

- [x] A1.5 — Formalize retrospective in EXECUTE.
  - In BASHŌ's "Final phase" subsection, specify that BASHŌ produces `retrospective.md` with:
    - What went well.
    - What deviated from the plan.
    - What surprised.
    - Spawn issues identified.
  - `retrospective.md` becomes input for DARWIN alongside `diagnosis.md` and `plan.md`.

- [x] A1.6 — Add git workflow conventions.
  - New section "Git Conventions" (or add to existing rules):
    - Branch: `NNN-slug`
    - Commits: `type(NNN): description`
    - PR: `gh pr create --title "NNN: slug" --body "Closes #NNN"`

- [x] A1.7 — Update DARWIN input list.
  - Add `retrospective.md` to the list of documents DARWIN receives.

**Verification:**
- Read the modified file end-to-end. The FSM has 6 states: IDLE → ANALYZE → PLAN → EXECUTE → END → [EVOLUTION] → IDLE.
- No reference to `gh pr create` exists in EXECUTE or BASHŌ sections.
- `gh pr create` only appears in END state.
- EVOLUTION section documents the `evolution.enabled` config key.
- Retrospective is documented as BASHŌ's final-phase output.
- Git conventions section exists with branch, commit, PR patterns.

**Risk notes:**
- Verify that the SOCRATES, DESCARTES, and BASHŌ sub-prompts embedded in the file are not broken by the structural changes.

---

### Phase A2: Sync build copy

**Entry criteria:**
- Phase A1 verified.

**Steps:**

- [x] A2.1 — Copy `code/cli/assets/agents/ape.agent.md` to `code/cli/build/assets/agents/ape.agent.md`.

**Verification:**
- `diff` between the two files returns no differences.

---

### Phase A3: Commit Track A

**Entry criteria:**
- A1 and A2 verified.

**Steps:**

- [x] A3.1 — `git add code/cli/assets/agents/ape.agent.md code/cli/build/assets/agents/ape.agent.md`
- [x] A3.2 — `git commit -m "feat(044): rewrite FSM — add END state, optional EVOLUTION, retrospective, git conventions"`

**Verification:**
- `git log --oneline -1` shows the commit with correct conventional format.

---

## Track B — Cross-Platform + Enhancements

Track B involves code changes. TDD applies where indicated: write failing test (RED), implement (GREEN), refactor if needed.

### Phase B1: PlatformOps abstract class + FakePlatformOps (TDD)

**Entry criteria:**
- Track A committed (or can run in parallel — no file overlap).
- `dart pub get` succeeds.

**Decisions implemented:** D2.

**Steps:**

- [x] B1.1 — RED: Create `code/cli/test/platform_ops_test.dart` with contract tests.
  ```pseudo
  group('PlatformOps contract') {
    test('FakePlatformOps implements all methods')
    test('binaryName returns non-empty string')
    test('assetName returns non-empty string')
    test('expandArchive is callable')
    test('getEnvVariable returns value or null')
    test('setEnvVariable completes without error')
    test('selfReplace completes without error')
    test('runPostInstall completes without error')
  }
  ```
- [x] B1.2 — RED: Verify `dart test test/platform_ops_test.dart` fails (files don't exist yet).

- [x] B1.3 — GREEN: Create `code/cli/lib/targets/platform_ops.dart`.
  - Abstract class `PlatformOps` with:
    - `String get binaryName`
    - `String get assetName`
    - `Future<void> expandArchive(String archivePath, String destDir)`
    - `String? getEnvVariable(String name)`
    - `Future<void> setEnvVariable(String name, String value)`
    - `Future<void> selfReplace(String newBinaryPath, String currentBinaryPath)`
    - `Future<void> runPostInstall(String installDir)`
  - Factory `PlatformOps.current()` that returns `WindowsPlatformOps()` or `LinuxPlatformOps()` based on `Platform.isWindows`.

- [x] B1.4 — GREEN: Create `FakePlatformOps` in the test file (or a test helper).
  - Implements `PlatformOps`.
  - All methods are no-ops or return configurable values.
  - Records method calls for verification.

- [x] B1.5 — GREEN: Verify `dart test test/platform_ops_test.dart` passes (Windows).

- [x] B1.6 — GREEN: Verify tests pass on WSL: `wsl -e bash -c "cd /mnt/c/.../finite_ape_machine/code/cli && dart test test/platform_ops_test.dart"`.

- [x] B1.7 — Verify `dart analyze` has no errors in the new files.

**Verification:**
- All contract tests pass.
- `dart analyze` clean.
- `PlatformOps` is abstract and cannot be instantiated directly.

**Risk notes:**
- R2: Keep methods at exactly ~7. Do not add convenience methods. PlatformOps wraps shell operations only, not path manipulation (D2 boundary).

---

### Phase B2: WindowsPlatformOps implementation (TDD)

**Entry criteria:**
- Phase B1 verified. `PlatformOps` abstract class exists.

**Steps:**

- [x] B2.1 — RED: Add Windows-specific tests to `platform_ops_test.dart`.
  ```pseudo
  group('WindowsPlatformOps') {
    test('binaryName is ape.exe')
    test('assetName is ape-windows-x64.zip')
    test('expandArchive calls PowerShell Expand-Archive')
    test('setEnvVariable calls setx')
  }
  ```
  Note: tests that require real shell calls should use `FakePlatformOps` or be marked `@TestOn('windows')`.

- [x] B2.2 — GREEN: Create `code/cli/lib/targets/windows_platform_ops.dart`.
  - `class WindowsPlatformOps extends PlatformOps`
  - Extract existing PowerShell logic from `upgrade.dart` into the methods.
  - `binaryName` → `'ape.exe'`
  - `assetName` → `'ape-windows-x64.zip'`
  - `expandArchive()` → PowerShell `Expand-Archive`
  - `setEnvVariable()` → `setx`
  - `selfReplace()` → rename-then-replace pattern (existing logic from upgrade.dart)

- [x] B2.3 — GREEN: Verify tests pass (Windows).
- [x] B2.4 — GREEN: Verify tests pass on WSL: `wsl -e bash -c "cd ... && dart test test/platform_ops_test.dart"`.
- [x] B2.5 — Verify `dart analyze` clean.

**Verification:**
- `WindowsPlatformOps` passes all contract tests + Windows-specific tests.
- No Windows-specific code remains that should be in PlatformOps.

---

### Phase B3: LinuxPlatformOps implementation (TDD)

**Entry criteria:**
- Phase B1 verified. `PlatformOps` abstract class exists.
- Can run in parallel with B2 (no file overlap except shared test file — coordinate).

**Steps:**

- [x] B3.1 — RED: Add Linux-specific tests to `platform_ops_test.dart`.
  ```pseudo
  group('LinuxPlatformOps') {
    test('binaryName is ape')
    test('assetName is ape-linux-x64.tar.gz')
    test('expandArchive calls tar')
    test('setEnvVariable documents PATH guidance')
  }
  ```

- [x] B3.2 — GREEN: Create `code/cli/lib/targets/linux_platform_ops.dart`.
  - `class LinuxPlatformOps extends PlatformOps`
  - `binaryName` → `'ape'`
  - `assetName` → `'ape-linux-x64.tar.gz'`
  - `expandArchive()` → `tar xzf`
  - `setEnvVariable()` → guidance/echo (Linux env vars differ from Windows)
  - `selfReplace()` → `mv` or `cp` + `chmod +x`

- [x] B3.3 — GREEN: Verify tests pass (Windows).
- [x] B3.4 — GREEN: Verify tests pass on WSL: `wsl -e bash -c "cd ... && dart test test/platform_ops_test.dart"`.
- [x] B3.5 — Verify `dart analyze` clean.

**Verification:**
- `LinuxPlatformOps` passes all contract tests + Linux-specific tests.

---

### Phase B4: Refactor upgrade.dart to PlatformOps DI (TDD)

**Entry criteria:**
- Phases B1, B2, B3 verified. Both OS implementations exist.

**Decisions implemented:** D2, D8.

**Steps:**

- [x] B4.1 — RED: Create/update `code/cli/test/upgrade_test.dart`.
  ```pseudo
  group('UpgradeCommand') {
    test('uses PlatformOps.assetName for download URL')
    test('calls PlatformOps.expandArchive with correct paths')
    test('calls PlatformOps.selfReplace to swap binary')
    test('handles missing asset gracefully — no crash, clear message')  // D8
    test('calls PlatformOps.runPostInstall after upgrade')
  }
  ```
  All tests use `FakePlatformOps`.

- [x] B4.2 — GREEN: Modify `code/cli/lib/commands/upgrade.dart`.
  - Add `PlatformOps` as constructor parameter (DI).
  - Replace hardcoded `_assetName = 'ape-windows-x64.zip'` with `platformOps.assetName`.
  - Replace inline PowerShell `Expand-Archive` with `platformOps.expandArchive()`.
  - Replace inline binary swap with `platformOps.selfReplace()`.
  - Add graceful handling when release asset is missing (D8): detect HTTP 404 or `gh` error, return informative `UpgradeOutput` instead of crashing.
  - Update `UpgradeInput.fromCliRequest` or command registration to inject `PlatformOps.current()`.

- [x] B4.3 — GREEN: Verify `dart test test/upgrade_test.dart` passes (Windows).
- [x] B4.4 — GREEN: Verify tests pass on WSL: `wsl -e bash -c "cd ... && dart test test/upgrade_test.dart"`.
- [x] B4.5 — Verify `dart analyze` clean.
- [x] B4.6 — Verify existing behavior on Windows is preserved (manual smoke test or existing tests).

**Verification:**
- No `Platform.isWindows` branches remain in `upgrade.dart`.
- No hardcoded Windows asset names remain.
- `FakePlatformOps` tests cover the upgrade flow.
- Missing-asset scenario returns a clear error, not a crash.

**Risk notes:**
- R4: The missing-asset handling (D8) is critical. `ape upgrade` during the release window (asset still uploading) must not crash.

---

### Phase B5: Refactor uninstall.dart to PlatformOps DI (TDD)

**Entry criteria:**
- Phases B1, B2, B3 verified.

**Steps:**

- [x] B5.1 — RED: Update `code/cli/test/uninstall_test.dart`.
  ```pseudo
  group('UninstallCommand') {
    test('uses PlatformOps.getEnvVariable to find install path')
    test('calls OS-appropriate removal via PlatformOps')
  }
  ```

- [x] B5.2 — GREEN: Modify `code/cli/lib/commands/uninstall.dart`.
  - Add `PlatformOps` as constructor parameter.
  - Replace inline platform branches with PlatformOps method calls.

- [x] B5.3 — GREEN: Verify `dart test test/uninstall_test.dart` passes (Windows).
- [x] B5.4 — GREEN: Verify tests pass on WSL: `wsl -e bash -c "cd ... && dart test test/uninstall_test.dart"`.
- [x] B5.5 — Verify `dart analyze` clean.

**Verification:**
- No `Platform.isWindows` branches remain in `uninstall.dart`.
- `FakePlatformOps` tests cover the uninstall flow.

---

### Phase B6: init.dart path fix (TDD)

**Entry criteria:**
- `dart pub get` succeeds (no new dependencies needed — `package:path` already in pubspec).

**Decisions implemented:** D3.

**Steps:**

- [x] B6.1 — RED: Update `code/cli/test/init_command_test.dart`.
  ```pseudo
  group('init _relative fix') {
    test('relative path works with forward slashes')
    test('relative path works with backslashes')
    test('relative path works with mixed separators')
  }
  ```

- [x] B6.2 — GREEN: Modify `code/cli/lib/commands/init.dart`.
  - Replace the `_relative(String root, String path)` method (currently at ~L147):
    ```dart
    // BEFORE:
    String _relative(String root, String path) =>
        path.replaceFirst('$root/', '').replaceFirst('$root\\', '');
    
    // AFTER:
    String _relative(String root, String path) => p.relative(path, from: root);
    ```
  - Verify `import 'package:path/path.dart' as p;` already exists (it does in the file).

- [x] B6.3 — GREEN: Verify `dart test test/init_command_test.dart` passes (Windows).
- [x] B6.4 — GREEN: Verify tests pass on WSL: `wsl -e bash -c "cd ... && dart test test/init_command_test.dart"`.
- [x] B6.5 — Verify `dart analyze` clean.

**Verification:**
- `_relative` method body is a single call to `p.relative()`.
- Tests pass on both Windows and Linux path formats.

---

### Phase B7: doctor.dart — VS Code Copilot check

**Entry criteria:**
- No dependency on other phases.

**Steps:**

- [x] B7.1 — Read existing `doctor.dart` to understand current check pattern and DI approach (`_runProcess`).
- [x] B7.2 — Add a check for VS Code Copilot Chat extension.
  - Use `code --list-extensions` or equivalent to check for `GitHub.copilot-chat`.
  - Follow the existing `_runProcess` DI pattern for testability.
- [x] B7.3 — Verify `dart analyze` clean.
- [x] B7.4 — Manual smoke test: `dart run bin/ape.dart doctor` shows the new check.

**Verification:**
- `ape doctor` output includes a line for VS Code Copilot Chat.
- The check follows the same DI pattern as existing checks.

---

### Phase B8: CI workflow — ci.yml

**Entry criteria:**
- No dependency on code phases (can run in parallel).

**Decisions implemented:** D4.

**Steps:**

- [x] B8.1 — Create `.github/workflows/ci.yml`.
  - Trigger: `pull_request` + `push` to `main`.
  - Path filter: `code/cli/**`.
  - Matrix: `[ubuntu-latest, windows-latest]`.
  - Steps: checkout → `dart-lang/setup-dart@v1` → `dart pub get` → `dart analyze` → `dart test`.
  - Working directory: `code/cli`.

- [x] B8.2 — Review: no secrets required, no publish step, no compile step.

**Verification:**
- YAML is valid (`yamllint` or manual review).
- Matrix produces 2 jobs (ubuntu, windows).
- Triggers only on `code/cli/**` changes and workflow file itself.

**Risk notes:**
- R1: ci.yml does NOT need the Windows Defender workaround because it does not run `dart compile exe`. Only `release.yml` needs it.

---

### Phase B9: release.yml — 3-job ripgrep pattern

**Entry criteria:**
- Phase B8 done (ci.yml exists as reference for matrix syntax).
- PlatformOps phases done (asset names are finalized).

**Decisions implemented:** D1, D8.

**Steps:**

- [x] B9.1 — Read current `release.yml` fully to understand existing logic.
- [x] B9.2 — Restructure to 3 jobs:
  - **Job 1: `check-version`** (ubuntu-latest) — keep existing version check logic.
  - **Job 2: `create-release`** (ubuntu-latest, needs: check-version) — `gh release create v$VERSION --verify-tag --title "v$VERSION" --generate-notes`. Published immediately (NOT draft, per D8).
  - **Job 3: `build`** (matrix, needs: create-release) — build + upload per OS.
    - Matrix `include`:
      - `{ os: windows-latest, asset: ape-windows-x64.zip, build_script: scripts/build.ps1 }`
      - `{ os: ubuntu-latest, asset: ape-linux-x64.tar.gz, build_script: scripts/build.sh }`
    - Steps: checkout → setup-dart → pub get → compile exe → package → `gh release upload`.

- [x] B9.3 — **CRITICAL (R1):** Preserve Windows Defender workaround in the `build` job for the Windows matrix entry ONLY.
  - The workaround (clean `C:\hostedtoolcache\windows\dart`, clean temp zip, re-run `setup-dart`) MUST remain.
  - Add a conditional: `if: runner.os == 'Windows'` on the Defender cleanup steps.
  - Verify the workaround comment block is preserved for future maintainers.

- [x] B9.4 — Replace `softprops/action-gh-release@v2` with `gh` CLI calls.

- [x] B9.5 — Verify the tag is created from `check-version` output and propagated to `create-release` and `build` jobs via `needs` outputs.

**Verification:**
- YAML is valid.
- 3 jobs: `check-version` → `create-release` → `build` (dependency chain).
- `build` matrix produces 2 entries (Windows, Linux).
- Windows Defender workaround is present ONLY in Windows matrix entry.
- No `softprops/action-gh-release` reference remains.
- `gh release create` uses `--verify-tag` (not draft).

**Risk notes:**
- R1 (CRITICAL): If the Defender workaround is removed or misplaced, Windows builds will fail silently. The `dart compile exe` step will error with "dart not recognized" even though earlier steps succeeded. This is documented in repo memory and the workflow header comment.

---

### Phase B10: install.sh + build.sh + index.html

**Entry criteria:**
- Asset names finalized (from B2, B3).
- release.yml structure finalized (from B9).

**Steps:**

- [x] B10.1 — Create `code/site/install.sh`.
  - Download latest release asset `ape-linux-x64.tar.gz` from GitHub.
  - Extract to `~/.ape/bin/`.
  - Add to PATH (print guidance for `.bashrc` / `.zshrc`).
  - `chmod +x`.
  - Verify with `ape --version`.

- [x] B10.2 — Create `code/cli/scripts/build.sh`.
  - Mirror logic of existing `build.ps1` but for bash.
  - `dart pub get` → `dart compile exe` → package as `.tar.gz`.

- [x] B10.3 — Modify `code/site/index.html`.
  - Add Windows/Linux tabs for install instructions.
  - Windows tab: existing PowerShell install command.
  - Linux tab: `curl -fsSL ... | bash` pointing to `install.sh`.

- [x] B10.4 — Verify `install.sh` has `#!/bin/bash` shebang and is parseable (`bash -n install.sh` or shellcheck).
- [x] B10.5 — Verify `build.sh` has shebang and is parseable.
- [x] B10.6 — Verify `index.html` renders correctly (open in browser, check tab switching).

**Verification:**
- `install.sh` exists, is executable, downloads correct asset name.
- `build.sh` exists, mirrors `build.ps1` flow.
- `index.html` shows OS tabs with correct install commands.

---

### Phase B11: Commit Track B

**Entry criteria:**
- All B phases verified.
- `dart analyze` clean across entire project.
- `dart test` passes all tests.

**Steps:**

- [x] B11.1 — Run full test suite on Windows: `dart test` from `code/cli/`.
- [x] B11.2 — Run full test suite on WSL: `wsl -e bash -c "cd /mnt/c/.../finite_ape_machine/code/cli && dart test"`.
- [x] B11.3 — Run `dart analyze` from `code/cli/`.
- [x] B11.4 — Stage and commit in logical groups:
  - `git add` PlatformOps files → `git commit -m "feat(044): add PlatformOps abstraction with Windows and Linux implementations"`
  - `git add` upgrade + uninstall refactors → `git commit -m "refactor(044): upgrade and uninstall use PlatformOps DI"`
  - `git add` init fix → `git commit -m "fix(044): init.dart use p.relative() for cross-platform paths"`
  - `git add` doctor → `git commit -m "feat(044): doctor checks VS Code Copilot extension"`
  - `git add` ci.yml → `git commit -m "ci(044): add ci.yml with ubuntu + windows matrix"`
  - `git add` release.yml → `git commit -m "ci(044): release.yml 3-job ripgrep pattern with Linux support"`
  - `git add` install.sh, build.sh, index.html → `git commit -m "feat(044): install.sh, build.sh, and OS tabs in index.html"`

**Verification:**
- `git log --oneline` shows conventional commits with `(044)` scope.
- No uncommitted changes remain.

---

## Final Phase — Release Preparation

### Phase F1: Version bump + CHANGELOG

**Entry criteria:**
- Track A and Track B committed.
- All tests pass.

**Decisions implemented:** D9.

**Steps:**

- [x] F1.1 — Bump version in `code/cli/pubspec.yaml`: `0.0.10` → `0.0.11`.
- [x] F1.2 — Update `code/cli/CHANGELOG.md` with v0.0.11 entry:
  - **Added:** END state in FSM, optional EVOLUTION, retrospective, git conventions, PlatformOps, Linux support, ci.yml, install.sh, build.sh, OS tabs, doctor Copilot check.
  - **Changed:** release.yml to 3-job pattern, upgrade.dart and uninstall.dart to PlatformOps DI.
  - **Fixed:** init.dart cross-platform path handling.
- [x] F1.3 — `git commit -m "chore(044): bump version to 0.0.11 + CHANGELOG"`

**Verification:**
- `grep 'version:' code/cli/pubspec.yaml` shows `0.0.11`.
- CHANGELOG has a `## 0.0.11` section.

---

### Phase F2: Open issues review

**Entry criteria:**
- Version bump committed.

**Steps:**

- [x] F2.1 — Run `gh issue list --repo ccisnedev/finite_ape_machine --state open` to get current open issues.
- [x] F2.2 — Verify the following issues are addressed by this PR and will be closed:
  - **#43** — END state + EVOLUTION optional → addressed by Track A (ape.agent.md rewrite).
  - **#32** — Git workflow integration → addressed by Track A (git conventions section).
  - **#30** — Post-EXECUTE retrospective → addressed by Track A (retrospective formalization).
- [x] F2.3 — Verify the following issues remain open (NOT addressed by this PR):
  - **#33** — PLAN specialized agent (out of scope).
  - **#31** — Spawn issue mechanism (deferred).
  - **#29** — Document linter/gate (deferred).
  - **#28** — Two entry paths (deferred).
  - **#27** — Risks as artifacts (deferred).
- [x] F2.4 — Check if any OTHER open issues are incidentally addressed by v0.0.11 changes (e.g., cross-platform issues, CI issues). If found, add them to the PR body.
- [x] F2.5 — Prepare PR body text:
  ```
  ## v0.0.11 — FSM fix + Linux support + cross-platform audit

  ### Track A: FSM Fix
  - Added END state with explicit user gate for PR creation
  - Made EVOLUTION optional (default OFF via .ape/config.yaml)
  - Formalized retrospective as BASHŌ output
  - Codified git workflow conventions (branch, commit, PR)

  ### Track B: Cross-Platform
  - Added PlatformOps abstraction (Windows + Linux)
  - Refactored upgrade and uninstall to use PlatformOps DI
  - Fixed init.dart cross-platform path handling
  - Added doctor check for VS Code Copilot
  - Restructured release.yml to 3-job pattern with Linux matrix
  - Added ci.yml with ubuntu + windows matrix
  - Added install.sh and build.sh for Linux
  - Added OS tabs to install page

  Closes #43, #30, #32
  ```

**Verification:**
- PR body lists all three issues to close.
- No open issue that should be closed is missed.
- No closed issue is listed that shouldn't be.

---

### Phase F3: Final validation + push (END state gate)

**Entry criteria:**
- All phases complete and committed.
- Version bumped. CHANGELOG updated. Issues reviewed.

**Steps:**

- [x] F3.1 — Run `dart analyze` one final time.
- [x] F3.2 — Run `dart test` on Windows one final time.
- [x] F3.3 — Run `dart test` on WSL one final time: `wsl -e bash -c "cd /mnt/c/.../finite_ape_machine/code/cli && dart test"`.
- [x] F3.3 — Review `git log --oneline` for the full commit sequence. Verify conventional format.
- [x] F3.4 — `git push origin 044-fsm-fix-linux-support-crossplatform-audit`.
- [x] F3.5 — **END STATE GATE:** User authorizes PR creation.
  - `gh pr create --title "044: FSM fix + Linux support + cross-platform audit" --body "<F2.5 text>" --base main`
  - This is the END state action per the new FSM (D5). BASHŌ does NOT create the PR — the user gates it.

**Verification:**
- PR is created and links to issues #43, #30, #32.
- CI (ci.yml) triggers on the PR and passes on both ubuntu and windows.
- PR merge will trigger release.yml, which creates v0.0.11 tag and builds both OS binaries.

---

## Dependency Graph

```
Track A: A1 → A2 → A3
                       \
                        → F1 → F2 → F3
                       /
Track B: B1 → B2 ─┐
              B3 ─┤
                   ├→ B4 → B5 ─┐
         B6 ──────────────────┤
         B7 ──────────────────┤
         B8 ──────────────────┤
         B8 → B9 → B10 ──────┤
                               └→ B11
```

- Track A and Track B are independent (no file overlap).
- B2 and B3 depend on B1 (abstract class).
- B4 and B5 depend on B1+B2+B3 (need all implementations).
- B6, B7, B8 are independent of each other and of B2/B3.
- B9 depends on B8 (matrix syntax reference) and B2/B3 (asset names).
- B10 depends on B9 (release structure) and B2/B3 (asset names).
- B11 depends on all B phases.
- F1-F3 depend on both tracks being complete.

---

## Risk Register

| Risk | Phase | Mitigation |
|------|-------|------------|
| R1: Windows Defender deletes dart.exe | B9 | Preserve workaround with `if: runner.os == 'Windows'` conditional. Comment block MUST remain. |
| R2: PlatformOps scope creep | B1 | Hard rule: ~7 methods, shell ops only. No path manipulation. Review in B1 before proceeding. |
| R3: WSL ≠ real Linux | B3, B8 | CI with `ubuntu-latest` is the definitive Linux validation. Never trust WSL alone. |
| R4: Missing asset during upgrade | B4 | Explicit test: `handles missing asset gracefully`. HTTP 404 → clear message, not crash. |
| R5: 14 implementations burden | B2, B3 | `FakePlatformOps` reduces test burden to contract tests. Real OS tests are CI-only. |
| R6: Large scope | All | Two independent tracks. Commit per logical unit. Deviation → return to ANALYZE. |

---

## TDD Summary

| Phase | TDD? | Justification |
|-------|------|---------------|
| A1-A3 | No | Documentation only, no code to test. |
| B1 | Yes | Abstract class + contract = pure TDD. |
| B2 | Yes | Implementation against contract. |
| B3 | Yes | Implementation against contract. |
| B4 | Yes | Refactor with behavior change (DI + missing asset). |
| B5 | Yes | Refactor with DI. |
| B6 | Yes | Bug fix — classic RED→GREEN. |
| B7 | No | Follows existing DI pattern. Manual smoke test sufficient. |
| B8 | No | YAML config, not testable code. |
| B9 | No | YAML config. Validated by CI run on PR. |
| B10 | No | Scripts + HTML. Shell syntax check + visual review. |
