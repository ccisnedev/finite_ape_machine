---
id: diagnosis
title: "Diagnosis for issue #136: structural relocation of cleanrooms/ from docs/ to project root"
date: 2026-04-23
status: active
tags: [diagnosis, cleanrooms, git-mv, path-references, gitignore, refactor]
author: socrates
---

# Diagnosis for Issue #136: Structural Relocation of cleanrooms/ from docs/ to Project Root

## Abstract

Issue #136 is a structural correction, not a conceptual redesign. The repository has been carrying `cleanrooms/` inside `docs/` since its introduction, but cleanrooms are not documentation: they are ephemeral, per-developer, per-issue working artifacts. Keeping them in `docs/` mis-signals their nature — permanence, shareability — in ways that conflict with their actual lifecycle. The evidence now supports a single precise decision: move `cleanrooms/` to the project root and update every reference that assumes the old path. The `git mv` itself was executed on the branch as the first commit (6617c26). The remaining work is mechanical: add `!cleanrooms/` to this repository's `.gitignore`, update all path references across skill files, agent files, CLI source, tests, documentation, and site HTML, and verify the full test suite passes. The behavioral redesign of `iq inquiry start` and `iq init` gitignore management for other repositories is out of scope and delegated to issue #137.

## 1. Problem Defined

### 1.1 Structural Misplacement

The `cleanrooms/` directory historically lived at `cleanrooms/`. That placement was a mistake of convenience — an early decision to co-locate all project-specific artifacts under a single `docs/` tree. Cleanrooms are not documents. They are isolated working environments, one per issue, per developer. Their lifecycle is cycle-scoped: they are created when a cycle starts, written during ANALYZE and PLAN, and optionally archived or discarded after EXECUTE. The analogy is precise: a semiconductor cleanroom is a physically isolated environment used to build something, not a record of the build.

### 1.2 Conflicting Signals

Placing cleanrooms inside `docs/` sent three false signals:

1. **Permanence**: `docs/` implies content that should be retained, reviewed, and referenced. Cleanrooms default to gitignored, which contradicts the presence of their parent directory in `docs/`.
2. **Shareability**: `docs/` implies team-visible content. Cleanrooms are developer-private by default — one developer may be working issue #136 while another works the same issue in their own cleanroom.
3. **Navigability**: `docs/` is a site-buildable, reader-navigable surface. Cleanrooms are not meant for general readership; they are inputs to the AI's analysis, not outputs for human consumption.

### 1.3 Reference Drift

A grep audit across the repository identified 20+ files still referencing `cleanrooms/`. These span:

- Skill files (source and build copies): `issue-start`, `issue-end`
- Agent file (source and build copies): `inquiry.agent.md`
- CLI source: `init.dart` (creates `{docs}/cleanrooms/` during `iq init`)
- CLI tests: `init_command_test.dart` (asserts `cleanrooms/`), `assets_test.dart` (asserts path in SKILL)
- Documentation: `README.md`, `docs/architecture.md`, `docs/lore.md`, `docs/thinking-tools.md`, `docs/spec/finite-ape-machine.md`, `docs/spec/cli-as-api.md`, `docs/spec/agent-lifecycle.md`, `docs/spec/target-specific-agents.md`
- Site HTML: `code/site/ape-builds-ape.html`, `code/site/evolution.html`, `code/site/methodology.html`

No references to `cleanrooms/` were found in `.github/workflows/`. CI is clean.

### 1.4 Current State on Branch

The `git mv cleanrooms/ cleanrooms/` was executed as commit 6617c26 ("move cleanrooms/ to project root"). The filesystem state is correct. `cleanrooms/` no longer exists. `cleanrooms/` is at the project root. All that remains is updating references and the `.gitignore`.

## 2. Decision

**Move `cleanrooms/` to the project root and update all path references that assume `cleanrooms/`.**

Concretely:

1. The `git mv` is done (commit 6617c26). Verify history is preserved with `git log --follow`.
2. Add `!cleanrooms/` to this repository's `.gitignore`.
3. Update all references from `cleanrooms/` → `cleanrooms/` across skill files (source + build), agent files (source + build), CLI source, CLI tests, documentation, and site HTML.
4. Update `init.dart`: change cleanrooms directory creation from `{docs}/cleanrooms/` to `cleanrooms/` at the project root.
5. Run the full test suite and confirm it passes.

## 3. Rationale

### 3.1 Cleanrooms Are Not Documentation

The decisive reason is conceptual, not aesthetic. Documentation belongs in `docs/`. Cleanrooms are working directories. They happen to contain Markdown, but so do scratch pads and journals. The criterion is not file format — it is audience and lifecycle. Documentation is written for a reader and maintained across versions. Cleanrooms are written for the current AI session and are discarded or archived after the cycle ends.

### 3.2 Alignment with the Future Vision

Each cleanroom will eventually become a git worktree: a physically isolated checkout of the repository, checked out to a branch, used as the workspace for one issue cycle. Worktrees live at paths the developer chooses, typically adjacent to the main tree — not inside `docs/`. Establishing `cleanrooms/` at the project root now is consistent with that future without requiring the worktree infrastructure today.

### 3.3 Separation from `docs/` Enables Correct Default Gitignore Behavior

When `iq init` runs in a new repository, cleanrooms should be gitignored by default (developer-private). If cleanrooms lived inside `docs/`, gitignoring `cleanrooms/` would require an exception within an otherwise committed tree — an awkward pattern. With `cleanrooms/` at root, the pattern is clean: add `cleanrooms/` to `.gitignore` by default, add `!cleanrooms/` to opt in to versioning.

### 3.4 This Repository Opts In

This repository is the inquiry repository itself. Its cleanrooms are research artifacts that feed the academic paper and the evolution of the framework. They must be versioned. The `.gitignore` entry `!cleanrooms/` makes this opt-in explicit and protected: `iq init` will never overwrite an explicit `!cleanrooms/` entry.

### 3.5 Separation Keeps This PR Mechanical and Reviewable

The `git mv` and reference updates are a pure rename refactor. No behavior changes are introduced beyond the `init.dart` cleanrooms path (which is the minimal behavioral consequence of the move). Keeping the behavioral redesign of `iq inquiry start` and gitignore management out of scope makes this PR reviewable as a diff of path strings.

## 4. Constraints and Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| `git mv` loses history if done as delete+add | MEDIUM | Verify with `git log --follow cleanrooms/002-ape-init/analyze/index.md`; commit 6617c26 used rename detection |
| References to `cleanrooms/` missed in grep | LOW | Run `git grep "cleanrooms"` after all edits and confirm zero matches |
| `init_command_test.dart` asserts old path and blocks CI | MEDIUM | Update all 8 occurrences as part of the same PR |
| `assets_test.dart` asserts old path in SKILL.md content | LOW | Update line 105 alongside the SKILL.md update |
| Build assets diverge from source assets | MEDIUM | The repo memory rule applies: edit source first, then mirror to `code/cli/build/assets/` |
| `docs/thinking-tools.md` and `docs/spec/target-specific-agents.md` reference specific historical cleanroom file paths | LOW | Update citations to reflect new root location |
| `init.dart` still creates `{docs}/cleanrooms/` for new repos | HIGH | Update Step 2 of `InitCommand.execute()` to create `cleanrooms/` at root directly |

## 5. Scope

### In Scope

1. **Verify git mv history**: `git log --follow cleanrooms/<any-file>` confirms rename tracking.
2. **`.gitignore` update**: add `!cleanrooms/` to the root `.gitignore` of this repository.
3. **CLI source** (`code/cli/lib/modules/global/commands/init.dart`): change cleanrooms directory from `$docsDir/cleanrooms` → `$root/cleanrooms`. Update the Step 2 comment accordingly. The `_detectDocsDirectory` helper is unaffected (it is still used for other purposes — Step 1 remains relevant if docs dir detection is needed elsewhere; otherwise it can be inlined).
4. **CLI tests** (`code/cli/test/init_command_test.dart`): update all 8 occurrences of `cleanrooms` → `cleanrooms`. (`code/cli/test/assets_test.dart`): update line 105 path assertion.
5. **Source skill files**: `code/cli/assets/skills/issue-start/SKILL.md` (3 occurrences), `code/cli/assets/skills/issue-end/SKILL.md` (2 occurrences).
6. **Source agent file**: `code/cli/assets/agents/inquiry.agent.md` (~10 occurrences).
7. **Build skill files** (mirror of source): `code/cli/build/assets/skills/issue-start/SKILL.md`, `code/cli/build/assets/skills/issue-end/SKILL.md`.
8. **Build agent file** (mirror of source): `code/cli/build/assets/agents/inquiry.agent.md`.
9. **Documentation**: `README.md` (2 occurrences), `docs/architecture.md` (1 occurrence), `docs/lore.md` (2 occurrences), `docs/thinking-tools.md` (1 citation), `docs/spec/finite-ape-machine.md` (4+ occurrences), `docs/spec/cli-as-api.md` (1 occurrence), `docs/spec/agent-lifecycle.md` (1 occurrence), `docs/spec/target-specific-agents.md` (1 historical citation).
10. **Site HTML**: `code/site/ape-builds-ape.html` (2 occurrences), `code/site/evolution.html` (4 occurrences), `code/site/methodology.html` (1 occurrence).
11. **Full test suite**: `dart test` in `code/cli/` and `npm run test:unit && npm run test:integration` in `code/vscode/` must pass.

### Out of Scope (delegated to issue #137)

- Redesign of `iq inquiry start` as an operational cycle-start command
- `issue.md` scaffold creation during cycle start
- Selective `.inquiry/` state cleanup on cycle start
- `iq init` gitignore management logic for other repositories (the `cleanrooms.ignore` config key and conditional `.gitignore` writes)
- Git worktree integration
- Any changes to `CHANGELOG.md` for this PR (standard practice: changelog is written at issue-end by DARWIN)

## 6. Contract with PLAN

DESCARTES must implement the following in the order given. Each step is independently verifiable.

### Step 1 — Verify git mv history

```
git log --follow --oneline cleanrooms/002-ape-init/analyze/index.md
```

Confirm the file appears in history under both `cleanrooms/` (before 6617c26) and `cleanrooms/` (after). If rename tracking is broken, stop and raise a deviation.

### Step 2 — Update `.gitignore`

In the root `.gitignore`, append after the existing block:

```
# Inquiry — cleanroom versioning opt-in (this repo tracks cleanrooms as research artifacts)
!cleanrooms/
```

### Step 3 — Update `init.dart` (CLI source)

File: `code/cli/lib/modules/global/commands/init.dart`

- Change the Step 2 comment from `Create {docs}/cleanrooms/ if missing` → `Create cleanrooms/ at project root if missing`
- Change `final issuesDir = Directory('$docsDir/cleanrooms');` → `final issuesDir = Directory('$root/cleanrooms');`
- No other changes to this file. The `_detectDocsDirectory` helper remains for future use but cleanrooms no longer depend on it.

### Step 4 — Update CLI tests

File: `code/cli/test/init_command_test.dart`

Replace all occurrences of `cleanrooms` with `cleanrooms` (8 occurrences across lines 28, 47, 56, 69, 73, 75, 81, 261).

File: `code/cli/test/assets_test.dart`

Line 105: replace `'cleanrooms/<NNN>-<slug>/analyze/'` → `'cleanrooms/<NNN>-<slug>/analyze/'`.

### Step 5 — Update source skill files

File: `code/cli/assets/skills/issue-start/SKILL.md`
- Line 84: `mkdir -p cleanrooms/<NNN>-<slug>/analyze/` → `mkdir -p cleanrooms/<NNN>-<slug>/analyze/`
- Line 91: `cleanrooms/<NNN>-<slug>/analyze/index.md` → `cleanrooms/<NNN>-<slug>/analyze/index.md`
- Line 140: `cleanrooms/<NNN>-<slug>/analyze/index.md` → `cleanrooms/<NNN>-<slug>/analyze/index.md`

File: `code/cli/assets/skills/issue-end/SKILL.md`
- Line 40: `cleanrooms/{slug}/plan.md` → `cleanrooms/{slug}/plan.md`
- Line 45: `cleanrooms/{slug}/plan.md` → `cleanrooms/{slug}/plan.md`

### Step 6 — Update source agent file

File: `code/cli/assets/agents/inquiry.agent.md`

Replace all occurrences of `cleanrooms/` with `cleanrooms/`. Affected lines include (but are not limited to): 49, 52, 72, 98, 103, 121, 174, 234, 509, 510, 511. Use `git grep "cleanrooms"` to confirm the full set before editing.

### Step 7 — Mirror source to build assets

Files:
- `code/cli/build/assets/skills/issue-start/SKILL.md` — apply the same 3 replacements as Step 5
- `code/cli/build/assets/skills/issue-end/SKILL.md` — apply the same 2 replacements as Step 5
- `code/cli/build/assets/agents/inquiry.agent.md` — apply the same replacements as Step 6

### Step 8 — Update documentation

Apply the replacement `cleanrooms/` → `cleanrooms/` in each file:

| File | Occurrences | Notes |
|------|-------------|-------|
| `README.md` | 2 | Lines 85, 95 — inline text and markdown link target |
| `docs/architecture.md` | 1 | ASCII diagram line |
| `docs/lore.md` | 2 | Key artifact references under SOCRATES and DESCARTES |
| `docs/thinking-tools.md` | 1 | Citation [1] referencing a historical cleanroom file |
| `docs/spec/finite-ape-machine.md` | 4+ | State table, artifact paths, and citation [7] |
| `docs/spec/cli-as-api.md` | 1 | Planning route table |
| `docs/spec/agent-lifecycle.md` | 1 | ASCII diagram |
| `docs/spec/target-specific-agents.md` | 1 | Historical citation referencing `cleanrooms/003-ape-init-v2/` |

### Step 9 — Update site HTML

Apply the replacement `cleanrooms/` → `cleanrooms/` in:
- `code/site/ape-builds-ape.html` (2 occurrences)
- `code/site/evolution.html` (4 occurrences — both raw text and HTML-encoded `&lt;issue&gt;` variants)
- `code/site/methodology.html` (1 occurrence)

### Step 10 — Verify zero residual references

```
git grep "cleanrooms"
```

Must return zero matches. If any remain, fix before proceeding.

### Step 11 — Run test suite

```
cd code/cli && dart pub get && dart analyze && dart test
cd code/vscode && npm run test:unit && npm run test:integration
```

Both must pass. `dart test` will fail if `assets_test.dart` or `init_command_test.dart` still assert the old path. Fix any failures before closing the plan.

### Step 12 — Commit

Commit message convention for this repository:
```
refactor: update all cleanrooms → cleanrooms/ path references (#136)
```

Group all reference updates in a single commit. The git mv is already in a separate earlier commit (6617c26) and must not be amended.

## 7. References

[1] GitHub. "Issue #136: Move cleanrooms/ to project root." https://github.com/SiliconBrainedMachines/inquiry/issues/136

[2] GitHub. "Issue #137: iq inquiry start — operational cycle-start command with issue.md scaffold." https://github.com/SiliconBrainedMachines/inquiry/issues/137

[3] Finite APE Machine repository. "Inquiry agent — APE cycle orchestration." `code/cli/assets/agents/inquiry.agent.md`.

[4] Finite APE Machine repository. "issue-start skill." `code/cli/assets/skills/issue-start/SKILL.md`.

[5] Finite APE Machine repository. "issue-end skill." `code/cli/assets/skills/issue-end/SKILL.md`.

[6] Finite APE Machine repository. "InitCommand source." `code/cli/lib/modules/global/commands/init.dart`.

[7] Finite APE Machine repository. "CLI asset sync rule — build/assets must mirror assets/." Repository memory (ccisnedev, 2026).

[8] Finite APE Machine repository. "Cooperative multitasking model — two-level FSM architecture." `docs/spec/cooperative-multitasking-model.md`.
