# Analyze Phase — Index

**Issue:** #41 — v0.0.10: UX fixes + SDK enhancement
**Branch:** 041-tui-fix-skill-refinements-idle
**Phase:** ANALYZE
**Status:** In progress

## Documents

| ID | Title | Date | Status | Tags |
|----|-------|------|--------|------|
| scope-expansion | Scope expansion analysis — UX improvements and version decision | 2026-04-17 | active | scope, analysis, ux, versioning |
| diagnosis | Diagnosis — v0.0.10 UX fixes + SDK enhancement | 2026-04-17 | active | diagnosis, sdk, ux, tui, doctor, upgrade |

## Revised Scope Items (v0.0.10)

| # | Item | Type | Priority | Decided |
|---|------|------|----------|---------|
| 1 | SDK: Add `toText()` to Output | Enhancement | P0 | ✓ |
| 2 | TUI: Use `toText()` for clean display | Bug fix | P0 | ✓ |
| 3 | Doctor: Formatted checkmark output | Enhancement | P1 | ? |
| 4 | Upgrade: Progress indicators | Enhancement | P1 | ? |
| 5 | Skill issue-end: Clarify PR create = end | Docs | P2 | ✓ |

## Deferred Items

| # | Item | Reason |
|---|------|--------|
| D1 | IDLE auto-transition | Needs `.ape/` architecture decision |
| D2 | `ape init` usefulness | Needs `.ape/` structure finalization |
| D3 | v0.1.0 release | UX bugs must be fixed first |

## Key Findings

1. **TUI bug cause:** `modular_cli_sdk` iterates over all `toJson()` fields as `key: value`
2. **SDK fix needed:** Add optional `toText()` method to `Output` class
3. **Version decision:** Stay at `0.0.x` until core UX is solid
4. **`.ape/` status:** Created by `ape init` but never used — defer architectural decision

## Questions for User

1. Should SDK changes (`toText`) be part of this cycle or separate repo?
2. Should `ape init` be hidden/alpha until `.ape/` is actually used?
3. Approve revised scope (5 items vs original 3)?
