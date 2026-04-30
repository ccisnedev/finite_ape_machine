---
title: "Extract FSM state instructions into prompt YAML files"
issue: 160
date: 2026-04-29
status: complete
---

# Plan: Issue #160

## Phase 1 — Create state YAML files

**Objective:** Extract hardcoded instructions into `assets/fsm/states/*.yaml`

### Tasks

- [x] 1.1 Create `assets/fsm/states/idle.yaml`
- [x] 1.2 Create `assets/fsm/states/analyze.yaml`
- [x] 1.3 Create `assets/fsm/states/plan.yaml`
- [x] 1.4 Create `assets/fsm/states/execute.yaml`
- [x] 1.5 Create `assets/fsm/states/end.yaml`
- [x] 1.6 Create `assets/fsm/states/evolution.yaml`

### Verification

- All 6 files parse as valid YAML
- Each contains: `name`, `version`, `description`, `instructions`, `constraints`, `allowed_actions`
- `dart test` passes (no regressions)

---

## Phase 2 — Load instructions from YAML in state.dart

**Objective:** Replace `_stateInstructions` with YAML loading

### Tasks

- [x] 2.1 Add `_loadStateInstructions(FsmState)` method that reads from `assets/fsm/states/{state}.yaml`
- [x] 2.2 Fail hard with `CommandException` if YAML missing/malformed, message: `State instructions missing for {state}. Run 'iq doctor --fix' to repair.`
- [x] 2.3 Remove `_stateInstructions` static const
- [x] 2.4 Update `_computeInstructions()` to call new loader
- [x] 2.5 Update existing tests

### Verification

- `iq fsm state --json` returns same instructions as before
- Deleting a YAML file → clear error with remediation message
- `dart test` passes

---

## Phase 3 — Doctor: validate internal assets

**Objective:** Add asset integrity check to `iq doctor`

### Tasks

- [x] 3.1 Add `_checkInternalAssets()` method in `DoctorCommand`
- [x] 3.2 Verify existence of: `apes/*.yaml` (5 files), `fsm/states/*.yaml` (6 files), `skills/*/SKILL.md` (4 files), `fsm/transition_contract.yaml`
- [x] 3.3 Report missing files as failed checks with `remediation: "Run 'iq doctor --fix' to restore"`
- [x] 3.4 Add tests

### Verification

- `iq doctor` shows ✓ when all assets present
- `iq doctor` shows ✗ with remediation when asset missing
- `dart test` passes

---

## Phase 4 — Doctor: version check

**Objective:** Check for new version in `iq doctor` and `iq` bare

### Tasks

- [x] 4.1 Extract version-check logic from `UpgradeCommand` into shared utility (e.g., `lib/src/version_check.dart`)
- [x] 4.2 Add version check to `DoctorCommand.execute()` — non-blocking, silent on network failure
- [x] 4.3 Add version banner to `TuiCommand.execute()` — `"Update available: X → Y — run 'iq upgrade'"`
- [x] 4.4 Add tests (mock HTTP)

### Verification

- `iq doctor` shows "Update available" when newer version exists
- `iq` bare shows banner
- Network failure → no crash, no extra output
- `dart test` passes

---

## Phase 5 — Doctor `--fix`

**Objective:** Execute remediations when `--fix` flag is passed

### Tasks

- [x] 5.1 Add `--fix` flag to `DoctorInput` / `DoctorInput.fromCliRequest`
- [x] 5.2 Wire flag in `global_builder.dart`
- [x] 5.3 Implement fix logic: for missing assets → download zip from `https://github.com/ccisnedev/inquiry/releases/download/v{version}/` and extract `assets/` over installation
- [x] 5.4 Report each remediation step with ✓/✗
- [x] 5.5 Add tests

### Verification

- `iq doctor --fix` with missing asset → downloads and restores
- `iq doctor --fix` with all healthy → "Nothing to fix"
- Network failure during fix → clear error
- `dart test` passes

---

## Phase 6 — IDLE scheduler runs doctor first

**Objective:** Update firmware so IDLE always begins with `iq doctor`

### Tasks

- [x] 6.1 Update `assets/fsm/states/idle.yaml` instructions to include "Run `iq doctor` as first action"
- [x] 6.2 Update `assets/agents/inquiry.agent.md` firmware: in IDLE state, run `iq doctor` before presenting transitions

### Verification

- Scheduler in IDLE runs `iq doctor` first
- If doctor fails, scheduler presents remediation options before proceeding

---

## Dependency Order

```
Phase 1 → Phase 2 (need YAML files before loading them)
Phase 3 → Phase 5 (need checks before --fix can run them)
Phase 4 is independent (can parallel with 3)
Phase 6 depends on Phase 1 (idle.yaml must exist)
```

## Exit Criteria (Phases 1–6)

- All 6 state YAML files exist and are loaded at runtime
- `iq fsm state --json` returns instructions from YAML (not hardcoded)
- `iq doctor` validates asset integrity + checks for updates
- `iq doctor --fix` repairs missing assets
- `iq` bare shows update banner
- All tests pass
- No hardcoded state instructions remain in Dart code

---
---

# Plan: Context Injection + doc-write/doc-read

> Extension of issue #160. The prompt assembly system (`iq ape prompt`) now
> loads instructions from YAML — next step: inject dynamic context so APEs
> know WHERE to write and WHAT to read, and rename skills to reflect their
> true purpose (investigation material, not "memory").

---

## Phase 7 — Rename skills: memory-write → doc-write, memory-read → doc-read

**Objective:** Align skill names with their actual purpose (investigation documentation, not memory)

### Tasks

- [ ] 7.1 Rename `assets/skills/memory-write/` → `assets/skills/doc-write/`
- [ ] 7.2 Rename `assets/skills/memory-read/` → `assets/skills/doc-read/`
- [ ] 7.3 Update SKILL.md frontmatter `name:` field in both
- [ ] 7.4 Update description: "investigation material" not "project memory"
- [ ] 7.5 Update `socrates.yaml` references from `memory-write`/`memory-read` → `doc-write`/`doc-read`
- [ ] 7.6 Update `DoctorCommand` asset manifest (skills list)
- [ ] 7.7 Update `inquiry.agent.md` firmware if it references old names

### Verification

- `iq doctor` passes (recognizes new skill paths)
- No references to `memory-write` or `memory-read` remain in assets/
- `dart test` passes

---

## Phase 8 — Rewrite doc-write skill

**Objective:** doc-write teaches the AI how to fill CLI-generated templates and maintain the index

### Tasks

- [ ] 8.1 Rewrite `doc-write/SKILL.md`:
  - Explain that the CLI creates file templates with frontmatter pre-filled
  - AI's job: fill content sections, never modify frontmatter
  - After every write → update `index_file` (from inquiry-context block)
  - One topic per document rule
  - Schema: universal frontmatter (id, title, date, status, tags, author)
- [ ] 8.2 Add section: "Reading the inquiry-context block" — explains that `output_dir`, `index_file`, etc. are provided at the end of the prompt by the CLI
- [ ] 8.3 Add section: "Index update procedure" — exact format of index table row to add/update

### Verification

- Skill is self-contained (an AI can follow it without external context)
- References `inquiry-context` block as source of paths

---

## Phase 9 — Rewrite doc-read skill

**Objective:** doc-read teaches the AI to read index first from the path in inquiry-context

### Tasks

- [ ] 9.1 Rewrite `doc-read/SKILL.md`:
  - Step 1: Read `index_file` from inquiry-context block
  - Steps 2-4: Filter → Partial read → Full read (unchanged logic)
  - Remove references to ".inquiry/memory/"
- [ ] 9.2 Update description to reference "investigation material"

### Verification

- Protocol still follows index → filter → partial → full
- References `inquiry-context` as path source

---

## Phase 10 — CLI generates `confirmed.md` template on ANALYZE transition

**Objective:** `openAnalysisContext()` creates a pre-filled `confirmed.md` alongside `index.md`

### Tasks

- [ ] 10.1 In `effect_executor.dart` → `openAnalysisContext()`: create `confirmed.md` with frontmatter template
- [ ] 10.2 Template content:
  ```markdown
  ---
  id: confirmed
  title: "Confirmed findings"
  date: <today>
  status: active
  tags: [findings, confirmed]
  author: socrates
  ---

  # Confirmed Findings

  > Living document. Update as findings are confirmed, revised, or invalidated.
  > Format: ## F<N>: <title> — CONFIRMED|REVISED|INVALIDATED
  ```
- [ ] 10.3 Update initial `index.md` content to include `confirmed.md` as first entry
- [ ] 10.4 Add test for new template creation

### Verification

- `iq fsm transition --event start_analyze` creates both `index.md` and `confirmed.md`
- `confirmed.md` has valid frontmatter
- `index.md` lists `confirmed.md`
- `dart test` passes

---

## Phase 11 — Extract git branch utility to shared module

**Objective:** Make branch resolution reusable (needed by `iq ape prompt`)

### Tasks

- [ ] 11.1 Extract `_getCurrentBranch()` from `effect_executor.dart` into `lib/src/git_utils.dart`
- [ ] 11.2 Expose as `String getCurrentBranch(String workingDirectory)`
- [ ] 11.3 Update `effect_executor.dart` to use the shared utility
- [ ] 11.4 Add unit test for `getCurrentBranch()`

### Verification

- `effect_executor` behavior unchanged
- `getCurrentBranch()` importable from prompt command
- `dart test` passes

---

## Phase 12 — Extend `assemblePrompt()` with context injection

**Objective:** The prompt assembly system appends a YAML context block with dynamic paths

### Tasks

- [ ] 12.1 Add optional `Map<String, String>? context` parameter to `ApeDefinition.assemblePrompt()`
- [ ] 12.2 When context is non-null, append:
  ```
  \n\n---\n```yaml\n# --- inquiry-context ---\nkey: value\n...\n```
  ```
- [ ] 12.3 Update `ApePromptCommand.execute()`:
  - Import `getCurrentBranch()`
  - Resolve `output_dir` = `cleanrooms/<branch>/analyze/` (for socrates)
  - Resolve `analysis_input` = `cleanrooms/<branch>/analyze/diagnosis.md` (for descartes)
  - Resolve `index_file` = `cleanrooms/<branch>/analyze/index.md`
  - Resolve `confirmed_doc` = `cleanrooms/<branch>/analyze/confirmed.md` (for socrates)
  - Resolve `plan_file` = `cleanrooms/<branch>/plan.md` (for descartes/basho)
  - Pass context map per APE name
- [ ] 12.4 Add tests: verify context block appears in assembled prompt for socrates and descartes

### Verification

- `iq ape prompt --name socrates` output ends with inquiry-context block containing correct paths
- `iq ape prompt --name descartes` output ends with inquiry-context block containing `analysis_input`
- Paths resolve from current git branch
- `dart test` passes

---

## Phase 13 — Update socrates.yaml Documentation section

**Objective:** SOCRATES prompt references doc-write, confirmed.md obligation, and inquiry-context

### Tasks

- [ ] 13.1 Rewrite `## Documentation` section:
  - "Your output directory is specified in `output_dir` from the inquiry-context block"
  - "You MUST update `confirmed.md` (path in `confirmed_doc`) with every confirmed finding"
  - "Create additional documents for distinct investigation topics using doc-write protocol"
  - "NEVER produce diagnosis.md without at least one finding in confirmed.md"
  - "Use doc-read protocol before creating new files"
- [ ] 13.2 Remove mention of `memory-write` / `memory-read`

### Verification

- Prompt text references inquiry-context, doc-write, doc-read
- No references to memory-write/memory-read remain

---

## Phase 14 — Update descartes.yaml Input section

**Objective:** DESCARTES prompt reads diagnosis.md path from inquiry-context

### Tasks

- [ ] 14.1 Rewrite `## Input` section:
  - "Your primary input is the diagnosis document at the path specified in `analysis_input` from the inquiry-context block below"
  - "You may reference other documents in the same analyze/ directory for deeper context"
- [ ] 14.2 Add mention that `plan_file` in inquiry-context is where the plan goes

### Verification

- Prompt references inquiry-context for input/output paths
- No hardcoded path assumptions

---

## Phase 15 — Update memory-as-code spec

**Objective:** Align spec with implemented reality

### Tasks

- [ ] 15.1 Update Section 1: Replace `.inquiry/memory/` as primary location with `cleanrooms/<branch>/analyze/` for per-cycle investigation
- [ ] 15.2 Update Section 5 (BORGES): Note that schema enforcement is via CLI templates + doc-write skill
- [ ] 15.3 Update agent roster references: memory-write → doc-write, memory-read → doc-read
- [ ] 15.4 Add section on inquiry-context injection pattern
- [ ] 15.5 Note: `.inquiry/memory/` remains reserved for future cross-cycle persistent memory (DARWIN reports, lessons)

### Verification

- Spec matches implementation
- No contradictions between spec and skills/prompts

---

## Dependency Order

```
Phase 7  → Phase 8, 9 (need renamed dirs before rewriting content)
Phase 11 → Phase 12 (need git utility before prompt injection)
Phase 10 is independent (can parallel with 7-9)
Phase 12 → Phase 13, 14 (prompts reference inquiry-context that must exist)
Phase 15 depends on all above (documents final state)
```

## Exit Criteria (Phases 7–15)

- Skills renamed: `doc-write`, `doc-read` (no `memory-*` references in assets)
- `iq fsm transition --event start_analyze` creates `confirmed.md` template
- `iq ape prompt --name socrates` appends inquiry-context with `output_dir`, `confirmed_doc`, `index_file`
- `iq ape prompt --name descartes` appends inquiry-context with `analysis_input`, `plan_file`
- SOCRATES prompt mandates `confirmed.md` updates
- DESCARTES prompt reads `analysis_input` from context block
- Spec updated to reflect reality
- All tests pass
- `iq doctor` validates new asset paths
