---
id: diagnosis
title: Root cause analysis — version bump misses site index.html badge
date: 2026-04-20
status: active
tags: [version-sync, issue-end, skill, site-badge]
author: socrates
---

# Diagnosis — issue-end version bump misses site index.html badge

## Problem Statement

The `issue-end` skill's Step 4 ("Update Version Files") instructs the agent to update **two** files:

1. `code/cli/pubspec.yaml`
2. `code/cli/lib/src/version.dart`

But a **third** file also contains the version and must stay in sync:

3. `code/site/index.html` — `<span class="badge">vX.Y.Z</span>`

The CI test `version_sync_test.dart` already validates all three are equal, so when the badge is missed, CI breaks after merge.

## Observed Failure

PR #98 (v0.0.15) — badge stayed at v0.0.14, broke CI and Release. Fixed by hotfix PR #102.

## Root Cause

The `issue-end` skill (`code/cli/assets/skills/issue-end/SKILL.md`) Step 4 only lists two files. The site badge was added in issue #092 but the skill was never updated to include it.

The same gap exists in the deployed skill at `~/.copilot/skills/issue-end/SKILL.md` (user's machine).

## Version Sources Inventory

| File | Pattern | Current | In skill? |
|------|---------|---------|-----------|
| `code/cli/pubspec.yaml` | `version: X.Y.Z` | 0.0.15 | Yes |
| `code/cli/lib/src/version.dart` | `const String apeVersion = 'X.Y.Z';` | 0.0.15 | Yes |
| `code/site/index.html` | `<span class="badge">vX.Y.Z</span>` | v0.0.15 | **No** |

Note: `code/vscode/package.json` has its own independent version (0.0.6) and is NOT part of CLI version sync.

## Existing Safeguard

`code/cli/test/version_sync_test.dart` has two tests:
1. `version.dart matches pubspec.yaml` — checks dart const vs YAML
2. `site index.html badge matches pubspec.yaml version` — checks HTML badge vs dart const

These tests catch the drift, but only **after** the commit — not during the bump process.

## Options Analysis

The issue proposes three options:

### Option 1: Update the `issue-end` skill only

- Add `code/site/index.html` to Step 4
- Minimal change, quick fix
- Still relies on agent following the skill correctly

### Option 2: Create an `ape version bump` CLI command

- Programmatic — updates all three files atomically
- No version sources can be missed
- Adds code complexity (file I/O, regex replacement)
- Bigger scope

### Option 3: Both — CLI command + skill references it

- Best of both worlds
- Skill calls the command instead of manual edits
- Future-proof: adding a new version source only requires updating the command

## Recommendation

The `issue-end` skill is **generic** — it must remain project-agnostic and should NOT reference project-specific files like `index.html`.

The real gap is **test coverage**:

1. **`code/site/` has zero tests** — no test infrastructure at all. The badge version check lives in `code/cli/test/version_sync_test.dart` with a fragile relative path (`../../code/site/index.html`).

2. **The version sync test only catches drift after commit** — it doesn't prevent the drift during the bump process.

**Proposed approach:**
- Improve test infrastructure for `code/site/` (it currently has none)
- Strengthen version sync tests in `code/cli/`
- Ensure tests are robust enough to catch badge drift reliably in CI
