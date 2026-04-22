---
id: plan-022
title: "Execution plan — #22 Copilot-only target"
date: 2026-04-16
status: completed
tags: [plan, copilot, target-adapter, subsumption, v0.0.6]
---

# Execution plan — #22 Copilot-only target

## Reference

- Scope: `analyze/scope.md`
- Decisions: D20 (Copilot-only), D22 (revert subsumption), D23 (preserve adapter code)
- Reference: `docs/references/target-specific-agents.md`

## Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| Orphaned files in other targets from previous deploys | Low — users can manually delete | `clean()` still uses all adapters |
| Tests that reference 5 adapters break | Blocking | Update assertions in Phase 2 |

---

## Phase 1 — Tests first (RED)

Write tests that describe the new behavior before changing production code.

### Steps

- [x] 1.1 In `targets_test.dart`: add test `deployAdapters returns exactly 1 adapter (copilot)`. Add test `deployAdapters only contains copilot`. → **RED** (deployAdapters doesn't exist yet)
- [x] 1.2 In `targets_test.dart`: remove `copilot subsumedBy` group (2 tests — dead behavior)
- [x] 1.3 In `deployer_test.dart`: remove entire `effectiveAdapters — coexistence filtering` group (4 tests) and helper classes `_PrimaryAdapter`, `_SubsumedAdapter` (dead behavior)
- [x] 1.4 `dart test` — new tests fail (RED), remaining tests still pass

**No commit — RED state**

---

## Phase 2 — Production code changes (GREEN)

Make the new tests pass. Remove subsumption, split adapter lists, simplify deployer.

### Steps

- [x] 2.1 Remove `subsumedBy` override from `CopilotAdapter` (delete the 2-line override)
- [x] 2.2 In `all_adapters.dart`: keep `allAdapters` (all 5), add `deployAdapters` with only `CopilotAdapter`
- [x] 2.3 In `deployer.dart`: remove `effectiveAdapters` getter and its subsumption logic. `deploy()` uses `adapters` directly (no filtering)
- [x] 2.4 In `ape_cli.dart`: create two deployers — one with `deployAdapters` (for `target get`), one with `allAdapters` (for `target clean` and `uninstall`)
- [x] 2.5 Update command descriptions: `target get` → "Deploy APE agents and skills to Copilot"
- [x] 2.6 Bump version in `pubspec.yaml`: 0.0.5 → 0.0.6
- [x] 2.7 `dart test` — all 69 tests pass (GREEN)
- [x] 2.8 `dart analyze` — zero issues

**Commit:** `fix(cli): #22 revert subsumption, deploy only to Copilot`

---

## Phase 3 — Validation

- [x] 3.1 Build: `dart compile exe bin/main.dart -o build/bin/ape.exe`
- [x] 3.2 Run `ape target get` — verified files only in `~/.copilot/`
- [x] 3.3 Run `ape target clean` — verified files cleaned from `~/.copilot/` AND orphans in `~/.claude/`
- [x] 3.4 Verify Copilot recognizes the agent (start new chat, confirm APE agent is available)

> Deviation: `target get` output message said "deployed to all targets" — corrected to "deployed to Copilot". Amended into fix commit.

**Commit:** (no commit — validation only)
