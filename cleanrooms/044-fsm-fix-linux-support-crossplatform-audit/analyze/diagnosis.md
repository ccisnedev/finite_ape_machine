---
id: diagnosis
title: "Diagnosis — v0.0.11: FSM fix + Linux support + cross-platform audit"
date: 2026-04-18
status: final
tags: [diagnosis, v0.0.11, fsm, linux, cross-platform, release, ci, platformops]
author: socrates
---

# Diagnosis — v0.0.11: FSM fix + Linux support + cross-platform audit

## 1. Problem Statement

Issue #44 encompasses two independent tracks within a single release cycle:

- **Track A: FSM Fix** — Issues #43, #30, #32. Changes confined to `ape.agent.md` (prompt/documentation). Introduces an END state to the APE finite state machine, formalizes the retrospective phase, and codifies git workflow conventions.
- **Track B: Cross-Platform + Enhancements** — Linux release support, install.sh, PlatformOps abstraction, ci.yaml, doctor VS Code check, web install tabs, and init.dart path fix.

Both tracks are independent in implementation but ship together as v0.0.11.

---

## 2. Decisions

### D1: Release workflow — ripgrep 3-job pattern, no draft

**Context:** The current `release.yml` uses `softprops/action-gh-release@v2` with a single-job structure. A multi-OS release requires matrix builds uploading to the same release.

**Decision:** Adopt the ripgrep 3-job pattern:

1. **Job `create-release`** (ubuntu-latest) — `gh release create $VERSION --verify-tag` (published immediately, NOT draft).
2. **Job `build`** (matrix with `include`) — each OS builds its binary and uploads via `gh release upload`.
3. Version validation reuses the existing `check-version` job logic — PR triggers the workflow, release only fires when the version in `pubspec.yaml` changes.

**Justification:** `softprops/action-gh-release@v2` is replaced by `gh` CLI calls for transparency and control. No draft stage because the user identified no scenario where manual inspection adds value beyond CI validation.

**Source:** Q1, P4, P7.

### D2: PlatformOps — abstract class with DI by constructor

**Context:** `upgrade.dart` and `uninstall.dart` contain inline `Platform.isWindows` branches with shell-specific code (`PowerShell`, `tar`, environment variables). This blocks Linux support and makes testing impossible without real OS calls.

**Decision:** Introduce an abstract class `PlatformOps` with two concrete implementations (`WindowsPlatformOps`, `LinuxPlatformOps`) and approximately 7 methods:

| Method | Purpose |
|--------|---------|
| `expandArchive()` | Extract archive (PowerShell vs tar) |
| `getEnvVariable()` | Read environment variable |
| `setEnvVariable()` | Write environment variable |
| `selfReplace()` | Replace running binary |
| `binaryName` | `ape.exe` vs `ape` |
| `assetName` | `ape-windows-x64.zip` vs `ape-linux-x64.tar.gz` |
| `runPostInstall()` | OS-specific post-install steps |

**Boundaries:**
- `package:path` remains SEPARATE — it is already cross-platform by design. PlatformOps wraps SHELL operations only.
- Constructor injection (not global singleton). Factory `PlatformOps.current()` for production, `FakePlatformOps` for tests.
- Extends doctor.dart's existing DI pattern (`_runProcess`) to all commands.

**Justification:** DI enables unit testing with fakes. The abstract class provides a clear contract for each OS. The ~7 methods cover all current shell-dependent operations without over-abstraction.

**Source:** Q2, P5, P8, P10.

### D3: init.dart fix — use p.relative(), not PlatformOps

**Context:** `init.dart` line 147 uses `path.replaceFirst('$root/', '').replaceFirst('$root\\', '')` to compute relative paths. This is fragile across separators.

**Decision:** Replace with `p.relative(path, from: root)` using `package:path`.

**Justification:** This is a path-manipulation concern, not a shell-operation concern. `package:path` already handles separator differences cross-platform.

**Source:** Q3, P5.

### D4: ci.yaml — Level 1 safety net

**Context:** No CI pipeline exists. WSL is used for development but is not a substitute for native OS validation.

**Decision:** Create `.github/workflows/ci.yml`:
- **Trigger:** PR + push to main.
- **Matrix:** `[ubuntu-latest, windows-latest]`.
- **Steps:** `dart pub get` → `dart analyze` → `dart test`.

**Justification:** WSL is a development environment; CI with `ubuntu-latest` is the definitive Linux validation. No integration tests or smoke tests in v0.0.11 — this is a Level 1 safety net.

**Source:** P6, P9, P11.

### D5: FSM — Add END state, EVOLUTION optional

**Context:** The current FSM has EXECUTE creating PRs as a transition effect, with no explicit user gate. EVOLUTION runs automatically, which is undesired in most cycles.

**Decision:**
- New FSM: `IDLE → ANALYZE → PLAN → EXECUTE → END → [EVOLUTION] → IDLE`.
- **END state:** User gate for PR creation. Entry condition = EXECUTE report approved. Exit action = user authorizes `gh pr create`.
- **EVOLUTION:** Optional via `.ape/config.yaml` with `evolution.enabled: false` (default OFF).
- PR creation moves from transition effect to END state action.

**Justification:** END state gives the user explicit control over the PR creation moment. Making EVOLUTION optional prevents unnecessary overhead in routine cycles.

**Source:** #43, P12.

### D6: Retrospective formalization

**Context:** Post-EXECUTE learning is ad-hoc. No structured output feeds into EVOLUTION.

**Decision:** BASHŌ produces `retrospective.md` as part of EXECUTE's final phase. Contents:
- What went well.
- What deviated from the plan.
- What surprised.
- Spawn issues identified.

`retrospective.md` becomes input for DARWIN alongside `diagnosis.md` and `plan.md`.

**Justification:** Structured retrospectives enable DARWIN to make informed evolution decisions rather than relying on implicit patterns.

**Source:** #30, P12.

### D7: Git workflow conventions

**Context:** No codified convention for branches, commits, or PR titles.

**Decision:**
- **Branch:** `NNN-slug`
- **Commits:** conventional format — `type(NNN): description`
- **PR:** `gh pr create --title "NNN: slug" --body "Closes #NNN"`
- Issue closed automatically by PR merge.

**Justification:** Consistent naming enables traceability from issue to branch to commits to PR to release.

**Source:** #32, P12.

### D8: No draft release, auto-publish

**Context:** Draft releases require manual promotion, adding a step with no identified value beyond CI.

**Decision:** Release is published immediately on tag push. `ape upgrade` must handle gracefully the case where the release exists but the asset is not yet uploaded (matrix build still running).

**Justification:** No scenario identified where manual draft inspection adds value beyond CI validation.

**Source:** P7.

### D9: Version bump timing

**Context:** Need to define when version bumps and changelog updates occur within the APE cycle.

**Decision:** Version is determined in ANALYZE, set in PLAN, and physically updated in EXECUTE. Specifically:
- `pubspec.yaml` version bump happens during EXECUTE.
- `CHANGELOG.md` updates happen during EXECUTE.
- Spawn issue creation happens during EXECUTE.
- PR to main triggers `release.yml`, which checks if version changed.

**Justification:** EXECUTE is the implementation phase — all file modifications belong there.

**Source:** P13.

### D10: Single cycle, two tracks in plan.md

**Context:** v0.0.11 contains both FSM fixes (Track A) and cross-platform work (Track B).

**Decision:** One APE cycle with two parallel tracks in the plan. Track A and Track B are independent but released together.

**Justification:** The tracks have no code dependencies (Track A is documentation, Track B is code). Splitting into two cycles would duplicate overhead without benefit.

**Source:** P14.

---

## 3. Files Affected

### Track A — FSM Fix (ape.agent.md only)

| File | Action | Changes |
|------|--------|---------|
| `code/cli/assets/agents/ape.agent.md` | MODIFY | Add END state, update transitions, update BASHŌ final phase, update DARWIN input, add git conventions, add state announcement |
| `code/cli/build/assets/agents/ape.agent.md` | MODIFY | Same as above (build copy) |

### Track B — Cross-Platform + Enhancements

| File | Action | Changes |
|------|--------|---------|
| `code/cli/lib/targets/platform_ops.dart` | CREATE | Abstract class `PlatformOps` + factory `PlatformOps.current()` |
| `code/cli/lib/targets/windows_platform_ops.dart` | CREATE | `WindowsPlatformOps` implementation |
| `code/cli/lib/targets/linux_platform_ops.dart` | CREATE | `LinuxPlatformOps` implementation |
| `code/cli/lib/commands/upgrade.dart` | MODIFY | Refactor to accept `PlatformOps` via constructor DI |
| `code/cli/lib/commands/uninstall.dart` | MODIFY | Refactor to accept `PlatformOps` via constructor DI |
| `code/cli/lib/commands/init.dart` | MODIFY | Fix L147: replace `replaceFirst` with `p.relative()` |
| `code/cli/lib/commands/doctor.dart` | MODIFY | Add VS Code Copilot extension check |
| `.github/workflows/release.yml` | MODIFY | Restructure to 3-job pattern with matrix builds |
| `.github/workflows/ci.yml` | CREATE | `dart analyze` + `dart test` in `[ubuntu-latest, windows-latest]` matrix |
| `code/site/install.sh` | CREATE | Bash install script for Linux |
| `code/site/index.html` | MODIFY | Add Windows/Linux tabs for install instructions |
| `code/cli/scripts/build.sh` | CREATE | Bash equivalent of `build.ps1` |

### Tests (Track B)

| File | Action | Changes |
|------|--------|---------|
| `code/cli/test/platform_ops_test.dart` | CREATE | Test `PlatformOps` contract with `FakePlatformOps` |
| `code/cli/test/upgrade_test.dart` | CREATE/MODIFY | Use `FakePlatformOps` for upgrade command tests |
| `code/cli/test/uninstall_test.dart` | MODIFY | Update to use `FakePlatformOps` |
| `code/cli/test/init_command_test.dart` | MODIFY | Verify `p.relative()` fix |

---

## 4. Constraints and Risks

| # | Risk | Impact | Likelihood | Mitigation |
|---|------|--------|------------|------------|
| R1 | Windows Defender workaround must be preserved in `release.yml` | Build failure — `dart compile exe` fails silently | High (known bug) | Isolate Defender cleanup in Windows-only steps within the matrix. Documented in repo memory. |
| R2 | PlatformOps scope creep beyond shell operations | Over-engineering, blurred boundary with `package:path` | Medium | Clear rule: PlatformOps wraps shell ops only, not path manipulation. |
| R3 | WSL ≠ real Linux | False confidence in Linux support | Medium | CI with `ubuntu-latest` is the definitive validation, not WSL. |
| R4 | Release window with missing assets | `ape upgrade` downloads incomplete release | Low-Medium | `ape upgrade` must detect missing asset and report gracefully. |
| R5 | 7 methods × 2 OS = 14 implementations | Test burden | Low | `FakePlatformOps` reduces testing to interface contract, not each implementation. |
| R6 | Large scope for single cycle | Cycle fatigue, context loss | Medium | Two independent tracks can be parallelized. Track A is documentation-only. |

---

## 5. Scope

### In scope — v0.0.11

**Track A (FSM Fix — Issues #43, #30, #32):**
- END state in FSM with explicit user gate for PR creation
- EVOLUTION made optional via `.ape/config.yaml` (default OFF)
- `retrospective.md` as BASHŌ output in EXECUTE final phase
- Git workflow conventions (branch, commit, PR naming)
- State announcement on phase entry

**Track B (Cross-Platform + Enhancements):**
- `PlatformOps` abstract class with Windows and Linux implementations
- `upgrade.dart` and `uninstall.dart` refactored to use `PlatformOps` via DI
- `init.dart` path fix with `p.relative()`
- `doctor.dart` VS Code Copilot extension check
- `release.yml` restructured to 3-job ripgrep pattern with matrix
- `ci.yml` created with `[ubuntu-latest, windows-latest]` matrix
- `install.sh` for Linux
- `index.html` with OS-specific tabs
- `build.sh` for Linux builds

**Release operations:**
- Version bump to 0.0.11 in `pubspec.yaml`
- `CHANGELOG.md` update
- Review open issues for closure

### Out of scope

| Item | Reason |
|------|--------|
| #33 — Specialized PLAN agent | Independent enhancement, not required for v0.0.11 |
| #31 — Spawn issue mechanism | Deferred to future cycle |
| #29 — Document linter/gate | Deferred to future cycle |
| #28 — Two entry paths | Deferred to future cycle |
| #27 — Risks as artifacts | Deferred to future cycle |
| macOS support | No macOS runner or demand yet |
| Integration tests in CI | Level 1 safety net only for v0.0.11 |
| Branch protection rules | Organizational policy, not code |

---

## 6. Open Issues Review

Issues to close with the v0.0.11 PR:

| Issue | Title | Current Status | Action |
|-------|-------|----------------|--------|
| #43 | END state + EVOLUTION optional | Open | **Close** with v0.0.11 PR |
| #32 | Git workflow integration | Open | **Close** with v0.0.11 PR |
| #30 | Post-EXECUTE retrospective | Open | **Close** with v0.0.11 PR |

Issues remaining open (not in scope):

| Issue | Title | Reason |
|-------|-------|--------|
| #33 | PLAN specialized agent | Independent enhancement |
| #31 | Spawn issue mechanism | Deferred |
| #29 | Document linter/gate | Deferred |
| #28 | Two entry paths | Deferred |
| #27 | Risks as artifacts | Deferred |

---

## 7. References

| # | Document | Content |
|---|----------|---------|
| 1 | [scope-and-audit-overview.md](scope-and-audit-overview.md) | Initial scope definition and cross-platform codebase audit |
| 2 | [decisiones-tecnicas.md](decisiones-tecnicas.md) | Technical decisions Q1–Q3: matrix strategy, PlatformOps design, TDD approach |
| 3 | [investigacion-patrones.md](investigacion-patrones.md) | Pattern research P4–P6: ripgrep release, SwiftFormat PlatformOps, path semantics, ci.yaml |
| 4 | [implicaciones-decisiones.md](implicaciones-decisiones.md) | Decision implications P7–P9: no-draft release, DI pattern, CI scope |
| 5 | [fsm-fix-analysis.md](fsm-fix-analysis.md) | FSM analysis P10–P12: END state, retrospective formalization, git workflow |

---

## 8. Handoff to DESCARTES

This document is the **sole required input** for the PLAN phase. DESCARTES should:

1. Read this diagnosis in full.
2. Produce `plan.md` with two parallel tracks (A and B) and ordered tasks.
3. Use the files-affected list as the basis for task decomposition.
4. Incorporate risk mitigations as explicit plan steps where applicable.
5. Include the issue review table for PR body construction during EXECUTE.
