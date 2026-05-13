---
title: "Plan: Rename Invoke-ExpertCouncil skill to legion"
status: active
tags: [plan, rename, legion, skill]
---

# Plan: Rename Invoke-ExpertCouncil → legion

**Issue:** #191  
**Decision Reference:** [diagnosis.md](analyze/diagnosis.md)  
**Evidence Manifest:** [evidence-inventory.md](analyze/evidence-inventory.md)

---

## Overview

This plan executes a clean break rename of the skill directory from `Invoke-ExpertCouncil` to `legion`. The scope is precisely bounded:
- 1 directory rename
- 2 files with 3 string replacements (test files)
- 2 files with 19+ string replacements (CHANGELOG, docs/research/legion.md)
- 1 file with 2 metadata updates (SKILL.md)
- No lib/ code changes (deployer reads skill names dynamically)

**Critical constraint:** After rename, the string "Invoke-ExpertCouncil" must NOT appear in active code/docs — only in frozen cleanroom artifacts.

---

## Phase 1: Asset Directory and Metadata

**Entry Criteria:**
- Branch created from issue #191
- Diagnosis approved and decisions D1–D2 understood

**Steps:**

- [ ] **1.1** Rename directory:
  - Source: `code/cli/assets/skills/Invoke-ExpertCouncil/`
  - Target: `code/cli/assets/skills/legion/`
  - Ensure contents (SKILL.md) move completely

- [ ] **1.2** Update `code/cli/assets/skills/legion/SKILL.md` frontmatter:
  - Line 2: `name: Invoke-ExpertCouncil` → `name: legion`

- [ ] **1.3** Update `code/cli/assets/skills/legion/SKILL.md` heading:
  - Heading reflects unified `legion` identity

**Verification:**
- [ ] File exists at: `code/cli/assets/skills/legion/SKILL.md`
- [ ] Frontmatter `name:` field reads `legion`
- [ ] No directory at `code/cli/assets/skills/Invoke-ExpertCouncil/` remains
- [ ] Heading reflects new unified naming

---

## Phase 2: Test File Updates

**Entry Criteria:**
- Phase 1 complete
- Assets renamed successfully

**Steps:**

- [ ] **2.1** Update `code/cli/test/assets_test.dart`:
  - Change: `'Invoke-ExpertCouncil',` → `'legion',`

- [ ] **2.2** Update `code/cli/test/doctor_test.dart` (first occurrence):
  - Change: `'Invoke-ExpertCouncil',` → `'legion',`

- [ ] **2.3** Update `code/cli/test/doctor_test.dart` (second occurrence):
  - Change: `'Invoke-ExpertCouncil',` → `'legion',`

**Verification:**
- [ ] All 3 test string replacements applied
- [ ] No syntax errors in test files

---

## Phase 3: Documentation Updates

**Entry Criteria:**
- Phase 2 complete

**Steps:**

- [ ] **3.1** Update `code/cli/CHANGELOG.md`:
  - Add `## [Unreleased]` entry documenting the rename

- [ ] **3.2** Update `docs/research/legion.md`:
  - Replace all 19 occurrences of `Invoke-ExpertCouncil` with `legion`
  - Rationale: dual-naming thesis is now superseded; LEGION = both technique and skill

**Verification:**
- [ ] CHANGELOG.md has new entry documenting the rename
- [ ] All occurrences in legion.md replaced

---

## Phase 4: Full Verification

**Entry Criteria:**
- Phase 3 complete

**Steps:**

- [ ] **4.1** Run full test suite:
  - Command: `cd code/cli && dart test`
  - Expected: 0 failures

- [ ] **4.2** Verify string absence:
  - `grep -ri "Invoke-ExpertCouncil"` in `code/` and `docs/`
  - Expected: ZERO hits (only frozen cleanroom artifacts allowed)

- [ ] **4.3** Verify asset structure:
  - `code/cli/assets/skills/legion/SKILL.md` exists
  - `code/cli/assets/skills/Invoke-ExpertCouncil/` does not exist
  - Frontmatter `name: legion` is correct

- [ ] **4.4** (Optional) Redeploy target:
  - `iq target get` → verify `~/.copilot/skills/legion/SKILL.md` exists

**Exit Criteria:**
- All tests pass
- No active-code references to old name remain
- Asset directory renamed and metadata updated
- Documentation reflects new naming
- Ready for PR and merge

---

## Dependencies

| Phase | Depends On | Reason |
|-------|-----------|--------|
| 2 | 1 | Tests reference asset directory path |
| 3 | 2 | Documentation independent but sequenced for clarity |
| 4 | 3 | Final verification after all changes |

**No backward compatibility:** 0.x.x allows clean break. No aliases or migration.  
**Historical cleanrooms frozen:** #186, #189 artifacts unchanged.  
**Deployer is self-healing:** reads skill names dynamically from filesystem.
