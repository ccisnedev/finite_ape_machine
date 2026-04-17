---
id: scope
title: "Scope and decisions — #22 Copilot-only target"
date: 2026-04-16
status: active
tags: [scope, copilot, target-adapter, subsumption, decisions]
author: socrates
---

# Scope: #22 Copilot-only target

## Problem

`ape target get` deploys identical agent files to all target directories. When subsumption (D19) skips the Copilot deploy because `~/.claude/` exists, Copilot loses visibility of the agent — each AI tool only reads from its own config directory.

### Root cause

`CopilotAdapter.subsumedBy => ['claude']` prevents deployment to `~/.copilot/` when `~/.claude/` exists. But Copilot only reads agents from `~/.copilot/`, not `~/.claude/`.

### Confirmed facts (Socratic verification)

1. **Duplication confirmed:** Copilot reads from both `~/.copilot/` and `~/.claude/` when both contain agent files → duplicate agent visibility.
2. **Problem is location:** The agent file format (`tools:` frontmatter) is already Copilot-native. No content transformation needed.
3. **Multi-target is premature for MVP:** Supporting 5 targets adds complexity without value at this stage.

## Decisions

### D20: Single-target development until MVP

Deploy exclusively to GitHub Copilot (`~/.copilot/`) for v0.0.x. Other targets (Claude, Codex, Gemini, Crush) added post-MVP.

### D22: Subsumption (D19) removed from CopilotAdapter

Remove `subsumedBy => ['claude']` from `CopilotAdapter`. The `subsumedBy` mechanism stays in the `TargetAdapter` base class (zero cost, available for future use).

### D23: Adapter code preserved, registration limited

All 5 adapter files remain in `lib/targets/`. Only `CopilotAdapter` is registered in `allAdapters` for deploy. `clean()` uses all adapters for backward compatibility (cleans orphaned files from previous deploys).

## Scope of changes

### Production code

| File | Change |
|------|--------|
| `lib/targets/copilot_adapter.dart` | Remove `subsumedBy` override |
| `lib/targets/all_adapters.dart` | Export two lists: `allAdapters` (all 5, for clean) and `deployAdapters` (Copilot only) |
| `lib/targets/deployer.dart` | Accept separate `adapters` (for clean) and `deployAdapters` (for deploy) — OR — simpler: accept one list, caller controls what to pass |
| `lib/ape_cli.dart` | Pass `deployAdapters` to deployer for deploy, `allAdapters` for clean/uninstall |

### Alternative (simpler): Two deployer instances

Instead of changing the deployer API, create two deployers:
- `deployer` with `adapters: deployAdapters` for `target get`
- `cleanDeployer` with `adapters: allAdapters` for `target clean` and `uninstall`

### Chosen approach: Single deployer, two adapter lists

The deployer already has the dual mechanism (`adapters` for clean, `effectiveAdapters` for deploy). The simplest change:
1. `allAdapters` stays as-is (5 adapters) — used for `clean()`
2. `effectiveAdapters` changes: instead of subsumption logic, it returns only adapters marked as active
3. For v0.0.x, only `CopilotAdapter` is active

**Simplest implementation:** Remove `effectiveAdapters` subsumption logic. Replace with a direct filter on a new `activeTargets` property or just pass different lists from `ape_cli.dart`.

### Tests

| File | Change |
|------|--------|
| `test/targets_test.dart` | Update `allAdapters` count assertion. Remove `copilot subsumedBy` group. |
| `test/deployer_test.dart` | Remove `effectiveAdapters — coexistence filtering` group (4 tests). Remove `_PrimaryAdapter`, `_SubsumedAdapter` helper classes. |
| `test/target_commands_test.dart` | No change (uses `FakeAdapter`, unaffected). |
| `test/uninstall_test.dart` | No change (uses deployer with fakes). |

### No changes needed

| File | Reason |
|------|--------|
| `lib/targets/claude_adapter.dart` | Kept, not registered |
| `lib/targets/codex_adapter.dart` | Kept, not registered |
| `lib/targets/crush_adapter.dart` | Kept, not registered |
| `lib/targets/gemini_adapter.dart` | Kept, not registered |
| `lib/targets/target_adapter.dart` | `subsumedBy` stays in base class |
| `lib/assets.dart` | Unaffected |
| All command files | Unaffected |

## Out of scope

- Target-specific agent file transformation (future: deployer as compiler)
- Agent format differences between tools (deferred to multi-target phase)
- New `ape init` structure (#21 — separate issue)
