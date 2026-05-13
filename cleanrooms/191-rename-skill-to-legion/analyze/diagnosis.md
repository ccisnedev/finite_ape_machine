---
title: "Diagnosis: Rename Invoke-ExpertCouncil skill to legion"
status: active
tags: [diagnosis, rename, legion, skill]
---

# Diagnosis: Rename Invoke-ExpertCouncil → legion

## Problem Statement

The skill currently named `Invoke-ExpertCouncil` must be renamed to `legion` to align with the framework's naming convention (SOCRATES, DESCARTES, BASHŌ, DARWIN, DEWEY → LEGION). The council-synthesis decision document (`council-synthesis-legion-naming.md`) established that LEGION is the canonical name — the dual-naming approach was rejected in favor of a clean break.

## Scope

**Clean break.** No backward compatibility, no aliases. The project is at 0.x.x which permits breaking changes per semver.

**Post-rename invariant:** The string "Invoke-ExpertCouncil" MUST NOT appear anywhere in the repository outside of:
- Historical cleanroom documents (`cleanrooms/186-*`, `cleanrooms/189-*`, `cleanrooms/191-*/analyze/council-synthesis-legion-naming.md`)
- The cleanroom index reference to the issue title

## Decisions

### D1: Directory rename
`code/cli/assets/skills/Invoke-ExpertCouncil/` → `code/cli/assets/skills/legion/`

Lowercase `legion` (not `LEGION`, not `Legion`) — consistent with other skill directory names: `doc-read`, `doc-write`, `inquiry-install`, `issue-create`, `issue-end`, `issue-start`.

### D2: SKILL.md content update
- Frontmatter `name: Invoke-ExpertCouncil` → `name: Invoke-ExpertCouncil`
- Heading `# Invoke-ExpertCouncil — Council of Experts (LEGION)` → new heading reflecting the unified name

**Decision point:** The `name:` field should become `legion`. The skill name IS now LEGION — there is no separate technique vs. skill distinction anymore.

### D3: Test files — mechanical string replacement
Three hardcoded occurrences in test lists. Straightforward `'Invoke-ExpertCouncil'` → `'legion'`.

### D4: CHANGELOG — record the rename
The existing CHANGELOG entries that mention `Invoke-ExpertCouncil` describe past events. The correct approach:
- Add a new `## [Unreleased]` or version entry documenting the rename
- Do NOT modify past entries (they document what happened at that time)

**Wait — constraint says no version bump.** Then: add `## [Unreleased]` section noting the rename.

### D5: docs/research/legion.md — update documentation
This is active research documentation with 19 occurrences. All references to `Invoke-ExpertCouncil` as the skill name should be updated to `legion`. The document's entire thesis about dual-naming (LEGION = technique, Invoke-ExpertCouncil = skill) is now superseded — LEGION = both.

### D6: Deployed target — handled automatically
`iq target get` deployer reads skill names dynamically. After the asset rename, redeploying will create `~/.copilot/skills/legion/SKILL.md`. The old `Invoke-ExpertCouncil/` directory must be cleaned — the deployer's `_deleteDirectory` on the full skills dir before redeploying handles this.

### D7: No lib/ code changes needed
The Dart lib code (deployer, assets, adapters) uses dynamic directory listing. No hardcoded skill names exist in production code.

## Constraints

| ID | Constraint |
|----|-----------|
| C1 | No backward compat / aliases — clean break |
| C2 | No version bump in this issue |
| C3 | Tests must pass after rename |
| C4 | Historical cleanrooms are frozen — no edits |
| C5 | The `council-synthesis-legion-naming.md` is exempt (documents decision process) |

## Complete File Manifest for Execution

| # | File | Action | Lines |
|---|------|--------|-------|
| 1 | `code/cli/assets/skills/Invoke-ExpertCouncil/` | **Rename directory** → `legion/` | — |
| 2 | `code/cli/assets/skills/legion/SKILL.md` | Update `name:` field and heading | L2, L6 |
| 3 | `code/cli/test/assets_test.dart` | Replace skill name string | L157 |
| 4 | `code/cli/test/doctor_test.dart` | Replace skill name string (2 locations) | L102, L378 |
| 5 | `code/cli/CHANGELOG.md` | Add `[Unreleased]` entry for rename | Top |
| 6 | `docs/research/legion.md` | Replace 19 occurrences of old name | Multiple |
| 7 | Target deployment | Run `iq target get` post-rename | Runtime |

## Risks

| Risk | Mitigation |
|------|-----------|
| Missed reference causes test failure | Full `dart test` run after all edits |
| Deployed target retains old dir | Deployer deletes full skills dir before redeploying |
| User's local `.copilot/skills/Invoke-ExpertCouncil/` persists | `iq target get` cleans and redeploys |

## Verification Criteria

1. `dart test` in `code/cli/` passes (0 failures)
2. `grep -ri "Invoke-ExpertCouncil" --include="*.dart" --include="*.md"` returns ONLY hits in frozen cleanroom docs
3. `code/cli/assets/skills/legion/SKILL.md` exists with `name: legion`
4. `code/cli/assets/skills/Invoke-ExpertCouncil/` does NOT exist
5. After `iq target get`: `~/.copilot/skills/legion/SKILL.md` exists, `~/.copilot/skills/Invoke-ExpertCouncil/` does not
