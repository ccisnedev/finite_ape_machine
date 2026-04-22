---
id: scope-analysis
title: "Scope analysis for v0.0.9"
date: 2026-04-17
status: active
tags: [scope, version, tui, skill, semver]
author: socrates
---

# Scope Analysis for v0.0.9

## 1. Version Inconsistency

### Current State

| Location | Value | Status |
|----------|-------|--------|
| `pubspec.yaml` | `0.0.7` | Official |
| `lib/commands/version.dart` | `0.0.7` | Matches |
| `lib/commands/doctor.dart` | `0.0.8` | **INCONSISTENT** |

### Root Cause

`DoctorCommand` has `apeVersion = '0.0.8'` as default parameter. This was set during v0.0.8 development but the official version in pubspec was never bumped.

### Solution: Shared Constant (Option A)

Create `lib/src/version.dart`:
```dart
/// Single source of truth for APE CLI version.
/// Update this when bumping version in pubspec.yaml.
const String apeVersion = '0.0.9';
```

Import in both `version.dart` and `doctor.dart`.

### Alternatives Considered

- **Build-time generation**: Requires `build_runner`, adds complexity
- **Runtime parsing**: Already have `yaml` package, but adds runtime overhead

### Recommendation

Option A — simple, zero dependencies, Dart idiomatic.

## 2. Skill `issue-end`

### Purpose

Mirror of `issue-start` — closes the APE cycle by creating PR and transitioning to EVOLUTION.

### Steps (5 total)

1. **Verify state** — Confirm in EXECUTE phase
2. **Verify completion** — All plan checkboxes checked
3. **Determine semver** — Based on changes (breaking/feature/fix)
4. **Update version** — pubspec.yaml + version constant + CHANGELOG
5. **Create PR** — `gh pr create` with structured body
6. **Transition** — Update state.yaml to EVOLUTION

### CHANGELOG Format

Follow Keep a Changelog:
```markdown
## [X.Y.Z]
### Added
- Feature description (#issue)
### Changed
- Change description
### Fixed
- Fix description
```

## 3. TUI `ape` (no arguments)

### Current Behavior

When `ape` is invoked with no args:
- cli_router finds no matching route
- Falls through to `printHelp()`
- Outputs: "Command not found or invalid usage."

### Proposed Behavior

Display FSM diagram + version + quick reference:

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
║    ape init      Initialize workspace                     ║
║    ape doctor    Verify prerequisites                     ║
║    ape version   Show version                             ║
║    ape --help    Show all commands                        ║
╚════════════════════════════════════════════════════════════╝
```

### Implementation

Register empty route in `ape_cli.dart`:
```dart
cli.command<TuiInput, TuiOutput>(
  '',
  (req) => TuiCommand(TuiInput.fromCliRequest(req)),
  description: 'Display APE FSM diagram',
);
```

## 4. IDLE Auto-transition

### Original Proposal

"Identifying an issue = authorization to start ANALYZE"

### Analysis

Current APE design emphasizes **explicit human gates**. Changing this:
- Alters the fundamental philosophy of the FSM
- Requires updating ape.agent.md significantly
- May cause unintended transitions

### Recommendation

**DEFER to v0.0.10**. For now, keep explicit "start analysis" confirmation.

Document the intent and revisit after v0.0.9 is stable.

## 5. Semver Determination

### Changes in v0.0.9

| Type | Change |
|------|--------|
| FEATURE | `issue-end` skill |
| FEATURE | TUI display |
| FIX | Version inconsistency |
| DOCS | CHANGELOG update |

### Classification

- No breaking changes → not 1.0.0
- Multiple features → minor bump candidate
- Still in 0.0.x bootstrap phase → **0.0.9** is appropriate

### Target Version: **0.0.9**
