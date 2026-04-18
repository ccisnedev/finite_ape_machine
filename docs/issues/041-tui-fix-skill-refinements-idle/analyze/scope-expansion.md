---
id: scope-expansion
title: Scope expansion analysis — UX improvements and version decision
date: 2026-04-17
status: active
tags: [scope, analysis, ux, versioning]
author: SOCRATES
---

# Scope Expansion Analysis

User raised several items for consideration. This document analyzes each.

## 1. TUI Text Output Bug (P0 - Confirmed)

**Symptom:**
```
❯ ape
version: 0.0.9
diagram: APE v0.0.9
Finite Ape Machine
...
```

**Root Cause:** Found in `modular_cli_sdk/lib/src/cli_output_text.dart`:
```dart
void writeObject(Map<String, dynamic> object) {
  for (final entry in object.entries) {
    stdout.writeln('${entry.key}: ${entry.value}');
  }
}
```

The SDK iterates over ALL fields in `Output.toJson()` and prints each as `key: value`. This is correct for commands like `version` where `version: 0.0.9` makes sense, but wrong for TUI where we want ONLY the diagram.

**Solution Options:**

| Option | Pros | Cons |
|--------|------|------|
| A. Add `String? toText()` to SDK Output | Clean separation, backwards compatible | Requires SDK change |
| B. Have TuiOutput return only diagram | No SDK change | Loses version info in text mode |
| C. Print directly, bypass Output | Full control | Breaks modular_cli_sdk pattern |

**Recommendation:** Option A (SDK change). Add optional `toText()` to `Output` that overrides the default key:value iteration. This is a non-breaking change.

---

## 2. Doctor Output UX (P1 - New)

**Observation:** User compared `ape doctor` to `flutter doctor`:

```
❯ flutter doctor
Doctor summary (to see all details, run flutter doctor -v):
[√] Flutter (Channel stable, 3.41.6, on Microsoft Windows...)
[√] Windows Version (11 Pro Insider Preview 64-bit...)
[√] Android toolchain - develop for Android devices
...
```

vs current:
```
❯ ape doctor
checks: [{name: ape, passed: true, version: 0.0.9}, ...]
passed: true
```

**Issues with current output:**
1. JSON array format is not human-friendly
2. No checkmarks/visual indicators
3. No animation while checking (flutter has spinner)

**Desired behavior:**
```
Checking prerequisites...
  ✓ ape 0.0.9
  ✓ git 2.45.1
  ✓ gh 2.51.0
  ✓ gh auth (logged in)
  ✓ gh copilot extension

All checks passed.
```

**Implementation:** This is related to issue #1 — need `toText()` method in SDK to format doctor output as checkmarks instead of JSON.

---

## 3. Upgrade Logging UX (P1 - New)

**Observation:** `ape upgrade` currently blocks with no feedback while downloading/upgrading.

**Desired behavior:**
```
❯ ape upgrade
Checking for updates...
Current version: 0.0.9
Latest version:  0.0.10

Downloading ape-windows-x64.exe... done
Replacing binary... done

✓ Upgraded to v0.0.10
```

**Implementation:** Requires streaming output or progress indicators. modular_cli_sdk currently doesn't support this — all output comes at the end via `Output.toJson()`.

**Options:**
1. Use `dart:io` directly for progress output (bypass Output pattern)
2. Add streaming support to SDK (more complex)
3. Print minimal status via stderr during execution

---

## 4. v0.1.0 vs 0.0.x Decision (Critical)

User raises valid concern: **"ape init exists but isn't used"**

### Current State

| Feature | Status | Used? |
|---------|--------|-------|
| `ape init` | Implemented | ❌ Never used |
| `.ape/state.yaml` | Created by init | ❌ Not read by FSM |
| `ape doctor` | Implemented | ✅ Used |
| `ape version` | Implemented | ✅ Used |
| `ape upgrade` | Implemented | ✅ Used |
| `ape target get/clean` | Implemented | ✅ Used |
| `ape` (TUI) | Implemented | ✅ Used (with bugs) |

### What the Spec Expects `.ape/` to Contain

From `ape-cli-spec.md`:
```
.ape/
├── ape.yaml              ← Main config (target, stack, risk defaults)
├── agents/               ← Agent prompts
├── skills/               ← Skills
├── templates/            ← Output templates
├── hooks/                ← Automation hooks
├── memory/               ← Project memory (ADRs, specs, etc.)
└── status.md             ← Current project state
```

### What We Actually Have

- `ape init` creates `.ape/state.yaml` (minimal)
- `.ape/` is not used for anything
- Target files go to `~/.copilot/` or `~/.claude/` (user-level, not repo-level)
- No repo-scoped configuration

### Analysis: Why v0.1.0 is Premature

SemVer defines:
- `0.0.x` — Experimental, unstable, anything can change
- `0.x.y` — Development, API evolving but usable
- `1.x.y` — Stable, backwards-compatible

**We are still 0.0.x because:**

1. **Core feature unused:** `ape init` and `.ape/` infrastructure doesn't affect workflow
2. **No project-level state:** IDLE doesn't know if project is initialized
3. **TUI has bugs:** Cannot confidently show v0.1.0 when basic output is broken
4. **No repo migration path:** If we change `.ape/` structure later, no `ape repo upgrade` exists

**Criteria for v0.1.0:**
- [ ] `ape init` creates useful project config
- [ ] `.ape/` is actually used by APE workflow (or removed)
- [ ] TUI displays correctly
- [ ] IDLE can detect project state
- [ ] All basic commands work without visual bugs

---

## 5. How `.ape/` Could Benefit Us Now

### Option A: Lean `.ape/` (Recommended for v0.0.x)

Minimal repo-level state:
```
.ape/
├── state.yaml     ← Current FSM state (phase, task, branch)
└── config.yaml    ← Target preference (copilot, claude, etc.)
```

IDLE could:
1. Read `.ape/state.yaml` to know current phase
2. Read `.ape/config.yaml` to know preferred target
3. Suggest `ape init` if `.ape/` doesn't exist

### Option B: Full `.ape/` (Deferred to v0.2.0+)

Full spec implementation — agents, skills, memory, etc. in repo. This is a larger architectural change.

### Recommendation

For v0.0.10:
1. **Remove** `ape init` from scope or mark as `[alpha]`
2. **Fix** TUI output (SDK change + TuiOutput.toText())
3. **Fix** doctor output formatting
4. **Add** upgrade progress indicators
5. **Document** that `.ape/` is planned but not active

Then v0.1.0 when:
- All commands display correctly
- `.ape/` structure is finalized
- `ape init` creates useful config

---

## 6. Spec/Roadmap Review

From `ape-cli-spec.md` commands we don't have yet:

| Command | Spec Status | Implemented? | Priority |
|---------|-------------|--------------|----------|
| `ape` (TUI) | v0.2.0-spec | ✅ Yes (buggy) | P0 fix |
| `ape init` | v0.2.0-spec | ✅ Yes (unused) | P2 defer |
| `ape status` | v0.2.0-spec | ❌ No | Future |
| `ape upgrade` | v0.2.0-spec | ✅ Yes (no progress) | P1 fix |
| `ape repo upgrade` | v0.2.0-spec | ❌ No | Future |
| `ape repo doctor` | v0.2.0-spec | ❌ No | Future |
| `ape repo retarget` | v0.2.0-spec | ❌ No | Future |
| `ape memory *` | v0.2.0-spec | ❌ No | Future |
| `ape task *` | v0.2.0-spec | ❌ No | Future |
| `ape git *` | v0.2.0-spec | ❌ No | Future |
| `ape darwin` | v0.2.0-spec | ❌ No | Future |

**Key insight:** The spec is aspirational (v0.2.0). We're currently building the foundation (v0.0.x). Focus on making existing commands work well before adding new ones.

---

## Summary: Revised Scope

### v0.0.10 Scope (Proposed)

| # | Item | Type | Priority |
|---|------|------|----------|
| 1 | SDK: Add `toText()` to Output | Enhancement | P0 |
| 2 | TUI: Use `toText()` for clean display | Bug fix | P0 |
| 3 | Doctor: Formatted checkmark output | Enhancement | P1 |
| 4 | Upgrade: Progress indicators | Enhancement | P1 |
| 5 | Skill issue-end: Clarify PR create = end | Docs | P2 |

### Deferred to v0.1.0

- IDLE auto-transition (needs `.ape/` architecture decision)
- `ape init` usefulness
- `.ape/` structure finalization

### Questions for User

1. Should we continue using `0.0.x` until core UX is solid?
2. Should `ape init` be hidden/alpha until `.ape/` is actually used?
3. Should SDK changes (toText) be part of this cycle or separate?
