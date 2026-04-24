# Plan — Issue #136: Move cleanrooms/ to project root

**Phase:** PLAN  
**Issue:** #136 — `cleanrooms/` → `cleanrooms/` at project root  
**Branch:** `136-move-cleanrooms-to-project-root`  
**Diagnosis:** `cleanrooms/136-move-cleanrooms-to-project-root/analyze/diagnosis.md`

---

## Hypothesis

If we delete `_detectDocsDirectory()` from `init.dart`, redirect cleanrooms creation to `$root/cleanrooms`, delete the docs-detection test group, update all path references in assets/docs/site, and add `!cleanrooms/` to `.gitignore`, then `git grep "cleanrooms"` will return zero matches and the full test suite will pass.

---

## Phase 1 — Verify git mv history

**Entry criteria:** Branch `136-move-cleanrooms-to-project-root` is checked out.

- [x] Confirm `cleanrooms/` exists at project root and `cleanrooms/` is gone:
  ```
  git ls-files cleanrooms/ | head -5
  git ls-files cleanrooms/ | head -5
  ```
  Expected: first command returns paths, second returns nothing.
- [x] Confirm git tracks the rename (not a delete+add):
  ```
  git log --diff-filter=R --name-status --oneline | head -20
  ```
  Expected: at least one `R` entry showing `cleanrooms/... → cleanrooms/...`

**Verification:** Both commands produce expected output.  
**Risk:** If `cleanrooms/` still appears in `git ls-files`, the rename was done by copy+delete, losing history. Do not proceed — revert and re-do with `git mv`.

---

## Phase 2 — Update `.gitignore`

**Entry criteria:** Phase 1 complete. Working tree is clean.

- [x] Append `!cleanrooms/` to root `.gitignore`:
  ```
  # Inquiry — cleanroom versioning opt-in (this repo tracks cleanrooms as research artifacts)
  !cleanrooms/
  ```

**Verification:**
```
git diff .gitignore
```
Expected: shows `+!cleanrooms/` in the diff.

---

## Phase 3 — Update `init.dart`

**Entry criteria:** Phase 2 complete. `dart analyze` passes before this phase.

### 3a — Delete `_detectDocsDirectory` and its call site

- [x] Delete the `// Step 1: Detect docs directory` comment and the line:
  ```dart
  final docsDir = _detectDocsDirectory(root);
  ```
- [x] Update `// Step 2: Create {docs}/cleanrooms/ if missing` comment → `// Step 1: Create cleanrooms/ at project root if missing`
- [x] Change:
  ```dart
  final issuesDir = Directory('$docsDir/cleanrooms');
  ```
  to:
  ```dart
  final issuesDir = Directory('$root/cleanrooms');
  ```
- [x] Renumber remaining `// Step N:` comments: old 3→2, 4→3, 5→4, 6→5, 7→6
- [x] Delete the entire `_detectDocsDirectory` method (including its doc comment)
- [x] Update the library-level doc comment: remove step 1, renumber steps, update cleanrooms path description

### 3b — Verify

- [x] Run `dart analyze`:
  ```
  cd code/cli && dart analyze
  ```
  Expected: zero issues.
- [x] Confirm method is gone:
  ```
  git grep "_detectDocsDirectory" code/cli/lib/
  ```
  Expected: no output.

**Verification:** `dart analyze` exits 0.  
**Risk (expected):** `dart test` is RED after this phase — test group deleted in Phase 4.

---

## Phase 4 — Update CLI tests

**Entry criteria:** Phase 3 complete. `dart analyze` GREEN. `dart test` RED (expected).

### 4a — Delete "docs directory detection" group

- [x] In `code/cli/test/init_command_test.dart`, delete the entire `group('docs directory detection', () { … })` block including its separator comment.
  - Removes 4 tests: `uses existing docs/`, `uses existing doc/`, `prefers docs/ when both exist`, `creates docs/ when neither exist`

### 4b — Update "cleanrooms/ directory" group

- [x] Test name: `'creates {docs}/cleanrooms/ if it does not exist'` → `'creates cleanrooms/ at root if it does not exist'`
- [x] Remove setup line `Directory('${tempDir.path}/docs').createSync();`
- [x] Change assertion: `Directory('${tempDir.path}/cleanrooms').existsSync()` → `Directory('${tempDir.path}/cleanrooms').existsSync()`
- [x] Test name: `'skips {docs}/cleanrooms/ creation if already exists'` → `'skips cleanrooms/ creation if already exists'`
- [x] Change setup: `Directory('${tempDir.path}/cleanrooms').createSync(recursive: true)` → `Directory('${tempDir.path}/cleanrooms').createSync(recursive: true)`
- [x] Change marker file path: `cleanrooms/marker.md` → `cleanrooms/marker.md` (both create and assert)

### 4c — Update "idempotency" group

- [x] Change assertion: `Directory('${tempDir.path}/cleanrooms').existsSync()` → `Directory('${tempDir.path}/cleanrooms').existsSync()`

### 4d — Verify

- [x] Run `dart test`:
  ```
  cd code/cli && dart test
  ```
  Expected: all tests pass (GREEN).
- [x] Confirm docs-detection group is gone:
  ```
  git grep "docs directory detection" code/cli/test/
  ```
  Expected: no output.
- [x] Confirm no `cleanrooms` in tests:
  ```
  git grep "cleanrooms" code/cli/test/
  ```
  Expected: no output.

**Verification:** `dart test` exits 0. All tests GREEN.

---

## Phase 5 — Update source skill and agent files

**Entry criteria:** Phase 4 complete. `dart test` GREEN.

### 5a — `code/cli/assets/agents/inquiry.agent.md`

- [x] Global find-and-replace `cleanrooms` → `cleanrooms` (≈11 occurrences). Confirm with grep before editing:
  ```
  git grep -n "cleanrooms" code/cli/assets/agents/inquiry.agent.md
  ```

### 5b — `code/cli/assets/skills/issue-start/SKILL.md`

- [x] Replace 3 occurrences of `cleanrooms` → `cleanrooms`

### 5c — `code/cli/assets/skills/issue-end/SKILL.md`

- [x] Replace 2 occurrences of `cleanrooms` → `cleanrooms`

### 5d — Verify

- [x] Confirm zero matches in source assets:
  ```
  git grep "cleanrooms" code/cli/assets/
  ```
  Expected: no output.

---

## Phase 6 — Mirror to build assets

**Entry criteria:** Phase 5 complete. Source assets clean.

- [x] Copy `inquiry.agent.md`:
  ```
  Copy-Item code\cli\assets\agents\inquiry.agent.md code\cli\build\assets\agents\inquiry.agent.md
  ```
- [x] Copy `issue-start/SKILL.md`:
  ```
  Copy-Item code\cli\assets\skills\issue-start\SKILL.md code\cli\build\assets\skills\issue-start\SKILL.md
  ```
- [x] Copy `issue-end/SKILL.md`:
  ```
  Copy-Item code\cli\assets\skills\issue-end\SKILL.md code\cli\build\assets\skills\issue-end\SKILL.md
  ```

**Verification:**
```
git grep "cleanrooms" code/cli/build/assets/
```
Expected: no output.

**Risk:** Confirm build assets are tracked by git before staging:
```
git ls-files code/cli/build/assets/agents/inquiry.agent.md
```

---

## Phase 7 — Update documentation

**Entry criteria:** Phase 6 complete.

- [x] Run grep first to confirm occurrences before editing:
  ```
  git grep -n "cleanrooms" README.md docs/
  ```
- [x] `README.md`: update link text and target (`cleanrooms/` → `cleanrooms/`, all occurrences)
- [x] `docs/architecture.md`: update directory path label in ASCII diagram
- [x] `docs/lore.md`: update 2 path references
- [x] `docs/thinking-tools.md`: update bibliographic citation [1]
- [x] `docs/spec/finite-ape-machine.md`: update 4+ occurrences including citation [7]
- [x] `docs/spec/cli-as-api.md`: update planning route table
- [x] `docs/spec/agent-lifecycle.md`: update artifacts tree in ASCII diagram
- [x] `docs/spec/target-specific-agents.md`: update historical cross-reference

**Verification:**
```
git grep "cleanrooms" docs/ README.md
```
Expected: no output.

---

## Phase 8 — Update site HTML

**Entry criteria:** Phase 7 complete.

- [x] Run grep first:
  ```
  git grep -n "cleanrooms" code/site/
  ```
- [x] `code/site/ape-builds-ape.html`: update 2 occurrences
- [x] `code/site/evolution.html`: update 4 occurrences (including HTML-encoded `&lt;issue&gt;` variants)
- [x] `code/site/methodology.html`: update 1 occurrence

**Verification:**
```
git grep "cleanrooms" code/site/
```
Expected: no output.

---

## Phase 9 — Zero residual references audit

**Entry criteria:** Phases 2–8 complete.

- [x] Run full workspace grep:
  ```
  git grep "cleanrooms"
  ```
  Expected: **zero matches**.
- [x] If any match appears, fix it and re-run.
- [x] Spot-check new path appears where expected:
  ```
  git grep "cleanrooms/" code/cli/assets/ docs/ README.md | Measure-Object -Line
  ```
  Expected: ≥ 20 lines.

**Verification:** `git grep "cleanrooms"` returns no output.

---

## Phase 10 — Full test suite

**Entry criteria:** Phase 9 complete. Zero residual references.

- [x] CLI suite:
  ```
  cd code/cli && dart pub get && dart analyze && dart test
  ```
  Expected: all exit 0, zero failures.
- [x] VS Code unit tests:
  ```
  cd code/vscode && npm run test:unit
  ```
  Expected: all pass.
- [x] VS Code integration tests:
  ```
  cd code/vscode && npm run test:integration
  ```
  Expected: all pass.

**Verification:** All three commands exit 0.

---

## Phase 11 — Commit

**Entry criteria:** Phase 10 complete. All tests GREEN.

- [x] Stage all changes: `git add -A`
- [x] Verify staging area: `git status` — only expected files
- [x] Commit:
  ```
  git commit -m "refactor(#136): move cleanrooms/ to project root

  - Remove _detectDocsDirectory() from init.dart (deprecated)
  - init now creates cleanrooms/ at project root directly
  - Delete docs-detection test group from init_command_test.dart
  - Update cleanrooms/ assertions in remaining tests
  - Replace cleanrooms → cleanrooms in all assets, docs, and site HTML
  - Add !cleanrooms/ to .gitignore"
  ```
- [x] Verify: `git show --stat HEAD`

**Verification:** `git log --oneline -1` shows the commit. `git show --stat HEAD` lists all expected files.

---

## Risks (global)

| Risk | Severity | Mitigation |
|------|----------|------------|
| `dart analyze` flags residual issues after Phase 3 | HIGH | Verify immediately after Phase 3 before touching tests |
| Tests reference `cleanrooms` in non-obvious strings | MEDIUM | Run `git grep "cleanrooms" code/cli/test/` as final check in Phase 4 |
| Build assets not tracked by git | MEDIUM | `git ls-files code/cli/build/assets/` before mirroring in Phase 6 |
| HTML entities (`&lt;`, `&gt;`) mask occurrences in grep | LOW | Phase 8 prescribes grepping `code/site/` explicitly; HTML entities still contain `cleanrooms` literal |
| `docs/spec/` files have more occurrences than listed | LOW | Phase 7 prescribes running grep before editing — use actual output, not assumed line numbers |

---

## Summary

| Phase | Action | Gate |
|-------|--------|------|
| 1 | Verify git mv history | `git log --diff-filter=R` shows renames |
| 2 | Add `!cleanrooms/` to `.gitignore` | `git diff` shows the addition |
| 3 | Delete `_detectDocsDirectory`, redirect path | `dart analyze` → 0 issues |
| 4 | Delete docs-detection tests, update assertions | `dart test` → all GREEN |
| 5 | Update source assets | `git grep "cleanrooms" code/cli/assets/` → 0 |
| 6 | Mirror to build assets | `git grep "cleanrooms" code/cli/build/assets/` → 0 |
| 7 | Update docs | `git grep "cleanrooms" docs/ README.md` → 0 |
| 8 | Update site HTML | `git grep "cleanrooms" code/site/` → 0 |
| 9 | Zero residual audit | `git grep "cleanrooms"` → 0 (entire repo) |
| 10 | Full test suite | All commands exit 0 |
| 11 | Single commit | `git show --stat HEAD` lists expected files |
