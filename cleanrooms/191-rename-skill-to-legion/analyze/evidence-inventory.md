---
title: "Evidence Inventory: Rename Invoke-ExpertCouncil → Invoke-ExpertCouncil → legion"
status: active
tags: [evidence, inventory, rename, legion]
---

# Evidence Inventory: All References to "Invoke-ExpertCouncil"

## Category A: Files that MUST be renamed/updated (active code + assets)

### A1. Skill directory and SKILL.md (source of truth)
| File | Line(s) | Content |
|------|---------|---------|
| `code/cli/assets/skills/Invoke-ExpertCouncil/SKILL.md` | 2 | `name: Invoke-ExpertCouncil` |
| `code/cli/assets/skills/Invoke-ExpertCouncil/SKILL.md` | 6 | `# Invoke-ExpertCouncil — Council of Experts (LEGION)` |
| **Directory itself** | — | `code/cli/assets/skills/Invoke-ExpertCouncil/` → `code/cli/assets/skills/Invoke-ExpertCouncil/SKILL.md` |

**Action:** Rename directory to `legion/`. Update frontmatter `name:` to `Invoke-ExpertCouncil` → `legion`. Update heading.

### A2. Test files (hardcoded skill name lists)
| File | Line | Content |
|------|------|---------|
| `code/cli/test/assets_test.dart` | 157 | `'Invoke-ExpertCouncil',` |
| `code/cli/test/doctor_test.dart` | 102 | `'Invoke-ExpertCouncil',` |
| `code/cli/test/doctor_test.dart` | 378 | `'Invoke-ExpertCouncil',` |

**Action:** Replace `'Invoke-ExpertCouncil'` with `'Invoke-ExpertCouncil'` → `'legion'` in all 3 locations.

### A3. CHANGELOG (active history)
| File | Line | Content |
|------|------|---------|
| `code/cli/CHANGELOG.md` | 9 | `added \`Invoke-ExpertCouncil\` to hardcoded skill lists` |
| `code/cli/CHANGELOG.md` | 17 | `**Invoke-ExpertCouncil skill**: new universal SKILL.md implementing the LEGION technique` |

**Action:** Update to reference new name `legion`. The CHANGELOG records what happened — entries should describe the rename.

### A4. Deployed target (runtime artifact)
| Path | Note |
|------|------|
| `~/.copilot/skills/Invoke-ExpertCouncil/SKILL.md` | Deployed by `iq target get`. Will be replaced automatically after rename + redeploy. |

**Action:** Run `iq target get` after rename. The deployer reads skill names dynamically from `assets.listDirectory('skills')` — no hardcoded name in `lib/targets/deployer.dart`. Old target directory must be cleaned (deployer calls `_deleteDirectory` on full skills dir before redeploying).

---

## Category B: Documentation that SHOULD be updated (docs/ — active reference material)

### B1. `docs/research/legion.md`
| Line(s) | Content summary |
|---------|----------------|
| 12, 14, 16, 34, 47, 56, 145, 340, 342 (×2), 360, 372, 376 (×2), 380, 386, 390, 392, 420 | 19 occurrences of `Invoke-ExpertCouncil` — references to old skill name throughout the research document |

**Action:** Replace all `Invoke-ExpertCouncil` references with `legion` (or describe that the skill is now named `legion`). This is active documentation.

---

## Category C: Historical cleanroom documents (EXEMPT from rename)

These are historical records of completed issues. Changing them would rewrite history.

| Directory | Occurrences |
|-----------|------------|
| `cleanrooms/186-invoke-expertcouncil-skill/` (plan.md, analyze/) | ~30+ |
| `cleanrooms/189-plan-execute-enforce-full-test-suite/` (plan.md, analyze/) | ~6 |
| `cleanrooms/191-rename-skill-to-legion/analyze/council-synthesis-legion-naming.md` | ~18 (decision process doc) |
| `cleanrooms/191-rename-skill-to-legion/analyze/index.md` | 1 (issue title reference) |

**Action:** NO CHANGES. These are frozen historical artifacts.

---

## Category D: Variant searches

| Pattern | Results |
|---------|---------|
| `invoke_expertcouncil` (underscore) | 0 matches |
| `invoke-expertcouncil` (lowercase) | Same matches as Category A/B/C (case-insensitive duplicate) |
| JSON files | 0 matches |
| YAML/YML files | 0 matches |
| `code/vscode/` | 0 matches |
| `code/site/` | 0 matches |
| GitHub workflows (`.github/`) | 0 matches |

---

## Category E: Runtime behavior (no hardcoded names)

| File | Mechanism |
|------|-----------|
| `code/cli/lib/targets/deployer.dart` | `assets.listDirectory('skills')` — dynamic. Reads directory names at runtime. |
| `code/cli/lib/assets.dart` | Reads framework assets from disk — directory-driven. |
| All target adapters (copilot, gemini, claude, codex) | `skillsDirectory()` returns path to skills dir. Skill names are NOT hardcoded. |

**Conclusion:** The lib/ code is clean — only tests have hardcoded skill names.

---

## Summary: Actionable File Manifest

| # | File/Directory | Action |
|---|---------------|--------|
| 1 | `code/cli/assets/skills/Invoke-ExpertCouncil/` | Rename dir → `legion/` |
| 2 | `code/cli/assets/skills/legion/SKILL.md` (post-rename) | Update `name:` and heading |
| 3 | `code/cli/test/assets_test.dart` L157 | `'Invoke-ExpertCouncil'` → `'legion'` |
| 4 | `code/cli/test/doctor_test.dart` L102 | `'Invoke-ExpertCouncil'` → `'legion'` |
| 5 | `code/cli/test/doctor_test.dart` L378 | `'Invoke-ExpertCouncil'` → `'legion'` |
| 6 | `code/cli/CHANGELOG.md` L9, L17 | Update references to new name |
| 7 | `docs/research/legion.md` (19 occurrences) | Update all references |
| 8 | Deployed target `~/.copilot/skills/` | Redeploy via `iq target get` |
