---
id: diagnosis
title: "Diagnosis: v0.0.9 — version fix + issue-end skill + TUI"
date: 2026-04-17
status: active
tags: [diagnosis, v0.0.9, version, skill, tui]
author: socrates
---

# Diagnosis: v0.0.9

**Issue:** #39 — v0.0.9: fix version inconsistency + skill issue-end + TUI ape
**Branch:** 039-version-issue-end-tui
**Date:** 2026-04-17
**Target Version:** 0.0.9

---

## 1. Problem Statement

v0.0.8 was released without:
- Version bump in pubspec.yaml (still 0.0.7)
- CHANGELOG entry
- Consistent version constant across commands

Additionally, the APE cycle lacks:
- A skill for ending cycles (counterpart to `issue-start`)
- A TUI when `ape` is invoked without arguments

---

## 2. Scope

### In Scope

| # | Deliverable | Type | Priority |
|---|-------------|------|----------|
| 1 | Fix version inconsistency | Bug fix | P0 |
| 2 | Add CHANGELOG for v0.0.8 retroactively | Docs | P0 |
| 3 | Skill `issue-end` | Feature | P0 |
| 4 | TUI `ape` (no args) | Feature | P1 |
| 5 | Bump to v0.0.9 | Release | P0 |

### Out of Scope (deferred to v0.0.10)

| # | Item | Reason |
|---|------|--------|
| 1 | IDLE auto-transition | Changes FSM philosophy, needs more design |

---

## 3. Technical Design

### 3.1 Version Single Source of Truth

**Create `lib/src/version.dart`:**
```dart
/// Single source of truth for APE CLI version.
/// 
/// Update this constant when bumping version in pubspec.yaml.
/// Both are kept in sync manually to avoid build-time complexity.
const String apeVersion = '0.0.9';
```

**Update `lib/commands/version.dart`:**
```dart
import '../src/version.dart';
// Remove: const String apeVersion = '0.0.7';
// Use imported apeVersion
```

**Update `lib/commands/doctor.dart`:**
```dart
import '../src/version.dart';
// Change constructor default: this.apeVersion = apeVersion,
```

### 3.2 Skill `issue-end`

**Location:** `assets/skills/issue-end/SKILL.md`

**Steps:**
1. Verify EXECUTE phase in state.yaml
2. Verify all plan.md checkboxes checked
3. Determine semver bump (user confirms)
4. Update version: pubspec.yaml + lib/src/version.dart
5. Update CHANGELOG.md
6. Commit: `git add -A && git commit -m "vX.Y.Z: [summary]"`
7. Push: `git push -u origin <branch>`
8. Create PR: `gh pr create --title "vX.Y.Z: [title]" --body "..."`
9. Transition state.yaml to EVOLUTION

### 3.3 TUI `ape`

**Behavior:** When `ape` is invoked without arguments, display:

```
╔════════════════════════════════════════════════════════════╗
║                    APE CLI v0.0.9                          ║
╠════════════════════════════════════════════════════════════╣
║                                                            ║
║   IDLE ──→ ANALYZE ──→ PLAN ──→ EXECUTE ──→ EVOLUTION     ║
║    │         │          │         │            │           ║
║   APE     SOCRATES   DESCARTES  BASHŌ       DARWIN        ║
║                                                            ║
╠════════════════════════════════════════════════════════════╣
║  Commands:                                                 ║
║    ape init      Initialize workspace                      ║
║    ape doctor    Verify prerequisites                      ║
║    ape version   Show version                              ║
║    ape --help    Show all commands                         ║
╚════════════════════════════════════════════════════════════╝
```

**Implementation:**
- Create `lib/commands/tui.dart` with TuiInput, TuiOutput, TuiCommand
- Register as empty route: `cli.command<TuiInput, TuiOutput>('', ...)`

---

## 4. CHANGELOG Updates

### v0.0.8 (retroactive)

```markdown
## [0.0.8]
### Added
- `ape doctor` command: verifies prerequisites (ape, git, gh, gh auth, gh copilot)
- `issue-start` skill: infrastructure creation protocol for IDLE → ANALYZE
### Changed
- `ape.agent.md` IDLE section: references skill instead of non-existent command
- Five-state FSM: IDLE → ANALYZE → PLAN → EXECUTE → EVOLUTION
```

### v0.0.9

```markdown
## [0.0.9]
### Added
- `issue-end` skill: PR creation protocol for EXECUTE → EVOLUTION
- TUI display when `ape` invoked without arguments
### Fixed
- Version inconsistency: single source of truth in `lib/src/version.dart`
```

---

## 5. Files Changed

| File | Action | Description |
|------|--------|-------------|
| `lib/src/version.dart` | CREATE | Single source of truth |
| `lib/commands/version.dart` | MODIFY | Import shared constant |
| `lib/commands/doctor.dart` | MODIFY | Import shared constant |
| `lib/commands/tui.dart` | CREATE | TUI command |
| `lib/ape_cli.dart` | MODIFY | Register TUI command |
| `test/tui_test.dart` | CREATE | TUI tests |
| `assets/skills/issue-end/SKILL.md` | CREATE | New skill |
| `pubspec.yaml` | MODIFY | Bump to 0.0.9 |
| `CHANGELOG.md` | MODIFY | Add v0.0.8 + v0.0.9 entries |

---

## 6. Test Strategy

### TUI Tests
- Test: `ape` with no args returns TUI output
- Test: Output contains version string
- Test: Output contains FSM diagram

### Version Tests
- Test: `apeVersion` constant matches pubspec.yaml
- Test: `ape version` output matches `apeVersion`
- Test: `ape doctor` first check shows correct version

---

## 7. Acceptance Criteria

### Version Fix
- [ ] Single `apeVersion` constant in `lib/src/version.dart`
- [ ] `version.dart` imports and uses shared constant
- [ ] `doctor.dart` imports and uses shared constant
- [ ] pubspec.yaml shows `0.0.9`

### Skill `issue-end`
- [ ] File exists at `assets/skills/issue-end/SKILL.md`
- [ ] Documents 9 steps
- [ ] Follows YAML frontmatter format

### TUI
- [ ] `ape` with no args displays FSM diagram
- [ ] Output includes version
- [ ] Exit code 0

### Release
- [ ] CHANGELOG has v0.0.8 entry
- [ ] CHANGELOG has v0.0.9 entry
- [ ] All tests pass

---

## 8. References

| Document | Purpose |
|----------|---------|
| [scope-analysis.md](scope-analysis.md) | Initial analysis |
| [issue-start SKILL.md](../../../code/cli/assets/skills/issue-start/SKILL.md) | Reference for issue-end |
