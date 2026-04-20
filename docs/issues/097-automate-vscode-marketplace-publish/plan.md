---
type: plan
scope: issue
issue: 97
title: Automate VS Code extension publishing to Marketplace
created: 2026-04-20
updated: 2026-04-20
diagnosis: docs/issues/097-automate-vscode-marketplace-publish/analyze/diagnosis.md
---

# Plan — Automate VS Code Extension Publishing to Marketplace

## Hypothesis

If we create a GitHub Actions workflow with three jobs (check-version → test → publish),
triggered on pushes to `main` that touch `code/vscode/**`, gated by a Marketplace
version comparison, **and protected by a unit test that fails when the PAT is about to
expire**, then every version bump merged to `main` will automatically publish the
extension — without manual intervention, without interfering with existing workflows,
without publishing duplicate versions, and without silent PAT expiration failures.

---

## Phase 1 — Repository Hygiene: Remove Tracked `.vsix` Artifact

**Rationale:** Clean the repository before adding automation. A committed build artifact
signals a broken process; removing it first ensures the new workflow starts from a clean
state.

**Entry criteria:** Branch `097-automate-vscode-marketplace-publish` checked out.

**Dependencies:** None.

- [x] 1.1 Verify whether `ape-vscode-0.0.6.vsix` is still tracked by git
  - Run `git ls-files "*.vsix"` in repository root
  - If no files returned → artifact already untracked, skip to 1.3
  - **Result: no files returned — already untracked**
- [x] 1.2 ~~If tracked: run `git rm`~~ SKIPPED — already untracked
- [x] 1.3 Verify `code/vscode/.gitignore` contains `*.vsix` entry (already confirmed: line 3)
- [x] 1.4 ~~Commit~~ SKIPPED — no-op, no changes to commit

**Verification:**
```pseudo
assert git_ls_files("*.vsix") == []
assert file_contains("code/vscode/.gitignore", "*.vsix")
```

**Risk:** None. The `.vsix` is already untracked on this branch. This phase may be a
no-op verification, but it must be explicitly confirmed before proceeding.

---

## Phase 2 — PAT Expiration Tracking: File and Unit Test (TDD)

**Rationale:** The PAT expires silently. A unit test that reads a committed expiration
date file provides early warning to developers locally and blocks CI when expiration is
imminent. This phase uses TDD: write the test first (RED — file doesn't exist yet),
then create the file to make it pass (GREEN). This must precede the workflow phases
because the test job (Phase 4) runs `npm run test:unit`, which will execute this test.

**Entry criteria:** Phase 1 complete.

**Dependencies:** Phase 1. Existing test infrastructure (`test:unit` script, mocha,
`tsconfig.json` compiling `test/unit/**/*.test.ts`).

- [x] 2.1 **RED — Write the unit test** `code/vscode/test/unit/pat-expiry.test.ts`:
  - [x] 2.1.1 Test reads `code/vscode/.pat-expires` file (resolve path relative to
    workspace root using `path.resolve(__dirname, '../../../.pat-expires')`)
  - [x] 2.1.2 Test parses the file content as a `YYYY-MM-DD` date string (single line,
    trimmed)
  - [x] 2.1.3 Test calculates days until expiration: `expirationDate - today`
  - [x] 2.1.4 Behavior:
    - If expired (days ≤ 0): `assert.fail('VSCE PAT has expired on <date>. Rotate immediately.')`
    - If expires within 7 days: `assert.fail('VSCE PAT expires in <N> days (<date>). Rotate now.')`
    - If expires within 30 days: `console.warn('⚠ VSCE PAT expires in <N> days (<date>). Plan rotation.')` — test PASSES
    - If expires in >30 days: test PASSES silently
  - [x] 2.1.5 If `.pat-expires` file is missing or unparseable: `assert.fail('Missing or invalid .pat-expires file')`
  - [x] 2.1.6 Verify test FAILS when run now (RED) — confirmed
- [x] 2.2 **GREEN — Create the expiration tracking file** `code/vscode/.pat-expires`:
  - [x] 2.2.1 File content: single line `2026-12-31` (matches current PAT expiration)
  - [x] 2.2.2 No trailing newline required, but tolerate one in the test
  - [x] 2.2.3 Run `npm run test:unit` — 60 passing, 0 failing (GREEN)
  - [x] 2.2.4 Verify console warns if within 30 days (won't happen now — 255 days remain)
- [x] 2.3 `.pat-expires` added to `.vscodeignore` — confirmed absent from `vsce ls` output
- [x] 2.4 Commit: `feat(097): add PAT expiration tracking file and unit test`

**Verification:**
```pseudo
GIVEN .pat-expires contains "2026-12-31"
  AND today is 2026-04-20
THEN pat-expiry.test.ts passes (255 days remaining, no warn threshold)

GIVEN .pat-expires contains today's date minus 1
THEN pat-expiry.test.ts fails with "PAT has expired"

GIVEN .pat-expires contains today's date plus 5
THEN pat-expiry.test.ts fails with "expires in 5 days"

GIVEN .pat-expires contains today's date plus 20
THEN pat-expiry.test.ts passes AND console.warn is emitted

GIVEN .pat-expires file is missing
THEN pat-expiry.test.ts fails with "Missing or invalid"
```

**Risk:**
- Path resolution in compiled JS (`out/test/unit/pat-expiry.test.js`) must resolve
  correctly back to `code/vscode/.pat-expires`. Use `__dirname` + relative path, NOT
  `process.cwd()` (which varies by how mocha is invoked).
- Date comparison must be timezone-safe. Use UTC midnight for both dates to avoid
  off-by-one errors near day boundaries.

---

## Phase 3 — Create Workflow File: Job Structure and Version Check

**Rationale:** The workflow skeleton and the version-check job are the foundation.
Everything else depends on a correct idempotency gate. This is the most architecturally
significant phase — get it right before adding test and publish jobs.

**Entry criteria:** Phase 2 complete.

**Dependencies:** Phase 2.

- [x] 3.1 Create `.github/workflows/vscode-marketplace.yml` with workflow metadata
- [x] 3.2 Implement `check-version` job on `ubuntu-latest`:
  - [x] 3.2.1 Step: Checkout with `actions/checkout@v4`
  - [x] 3.2.2 Step: Read local version from `code/vscode/package.json` using `node -p`
  - [x] 3.2.3 Step: Query Marketplace via `npx @vscode/vsce show` with text grep fallback
  - [x] 3.2.4 Step: Compare versions and set `should_publish` output
  - [x] 3.2.5 Declare job outputs: `should_publish`, `local_version`
- [x] 3.3 Commit: `ci(097): add vscode-marketplace workflow with version check job`

**Verification:**
```pseudo
GIVEN workflow file exists at .github/workflows/vscode-marketplace.yml
  AND check-version job reads version from code/vscode/package.json
  AND check-version job queries Marketplace for current version
  AND check-version job outputs should_publish = "true" when versions differ
  AND check-version job outputs should_publish = "false" when versions match
THEN the idempotency gate is correct
```

**Risk:**
- `npx @vscode/vsce show` may not support `--json` flag in all versions. Verify the
  exact CLI invocation during execution. Fallback: parse text output with `grep`/`awk`.
- If the extension has never been published, `vsce show` may return a non-zero exit
  code. Handle this as "not yet published → should_publish=true".

---

## Phase 4 — Add Test Job with Cross-Platform Matrix

**Rationale:** Tests must pass before publishing. The test job runs in parallel with
the version check (no dependency), but the publish job depends on both. The
`pat-expiry.test.ts` written in Phase 2 runs here as part of `npm run test:unit`.

**Entry criteria:** Phase 3 complete (workflow file exists).

**Dependencies:** Phase 3 (workflow file exists). Phase 2 (test file + `.pat-expires` exist).

- [x] 4.1 Add `test` job to the workflow:
  - [x] 4.1.1 Runs on matrix: `[ubuntu-latest, windows-latest]`
  - [x] 4.1.2 Set `defaults.run.working-directory: code/vscode`
  - [x] 4.1.3 Steps: checkout, setup-node@v4, npm ci, npm run test:unit
- [x] 4.2 Verify the test job has NO dependency on `check-version` (runs in parallel)
- [x] 4.3 Commit: `ci(097): add cross-platform test job to vscode-marketplace workflow`

**Verification:**
```pseudo
GIVEN test job exists in vscode-marketplace.yml
  AND test job uses matrix [ubuntu-latest, windows-latest]
  AND test job runs npm ci && npm run test:unit in code/vscode/
  AND test job has no needs: clause (runs in parallel with check-version)
  AND pat-expiry.test.ts is included in the test:unit glob (out/test/unit/**/*.test.js)
THEN cross-platform validation is correct
```

**Risk:**
- `npm run test:unit` runs `tsc && mocha out/test/unit/**/*.test.js`. Ensure `tsc`
  compiles successfully on CI (no missing types). The `compile` script uses webpack,
  but `test:unit` uses `tsc` directly — these are independent compilation paths.
- `.pat-expires` path resolution must work on both Linux and Windows. Use `path.resolve`
  with forward-slash-agnostic logic.

---

## Phase 5 — Add Publish Job with Conditional Execution and PAT Expiry Check

**Rationale:** The publish job is the final piece. It depends on both `check-version`
(for the `should_publish` gate) and `test` (tests must pass). It runs only on
`ubuntu-latest` and uses the `VSCE_PAT` secret. A redundant PAT expiry check step
reads `.pat-expires` directly in the workflow as defense-in-depth.

**Entry criteria:** Phase 4 complete (test job exists).

**Dependencies:** Phase 4 (and transitively, Phases 2 and 3).

- [x] 5.1 Add `publish` job to the workflow:
  - [x] 5.1.1 Set `needs: [check-version, test]`
  - [x] 5.1.2 Set `if: needs.check-version.outputs.should_publish == 'true'`
  - [x] 5.1.3 Runs on `ubuntu-latest`
  - [x] 5.1.4 Set `defaults.run.working-directory: code/vscode`
  - [x] 5.1.5 Steps: checkout, setup-node, npm ci, PAT expiry check, npm run compile, vsce publish
- [x] 5.2 Verify publish job skips gracefully when `should_publish == 'false'`
- [x] 5.3 Commit: `ci(097): add conditional publish job with PAT expiry guard`

**Verification:**
```pseudo
GIVEN publish job exists in vscode-marketplace.yml
  AND publish job needs [check-version, test]
  AND publish job has if: condition on should_publish == 'true'
  AND publish job runs on ubuntu-latest
  AND publish job checks .pat-expires BEFORE running vsce publish
  AND publish job runs npm ci, npm run compile, npx vsce publish --no-dependencies
  AND publish job uses VSCE_PAT secret
THEN conditional publishing with PAT guard is correct

GIVEN .pat-expires contains a past date
THEN publish job fails at PAT expiry check step with ::error annotation

GIVEN should_publish == 'false'
THEN publish job is skipped AND workflow exits green
```

**Risk:**
- `VSCE_PAT` secret not configured → publish step fails with authentication error.
  This is expected on the first run if the secret hasn't been set up yet. The error
  message from `vsce` is clear enough.
- `vsce publish --no-dependencies` flag must match the `vsce package --no-dependencies`
  used in the `package` script. Diagnosis confirms this is correct for an extension
  bundled with webpack.
- The PAT expiry check uses `date -u` (bash on ubuntu-latest). String comparison of
  ISO dates works correctly for chronological ordering.

---

## Phase 6 — Workflow Review and Documentation

**Rationale:** Final review of the complete workflow file for correctness, consistency
with existing repository patterns, and documentation of the manual prerequisites
(`VSCE_PAT` secret, `.pat-expires` maintenance).

**Entry criteria:** Phase 5 complete (all three jobs exist in the workflow).

**Dependencies:** Phase 5.

- [x] 6.1 Review the complete `vscode-marketplace.yml`:
  - [x] 6.1.1 Correct trigger configuration (push to main, path filter)
  - [x] 6.1.2 Job dependency graph: check-version ∥ test → publish
  - [x] 6.1.3 Consistent use of `actions/checkout@v4` and `actions/setup-node@v4`
  - [x] 6.1.4 No permissions block needed (no GITHUB_TOKEN usage beyond default read)
  - [x] 6.1.5 Working directory set correctly on jobs that need it
  - [x] 6.1.6 PAT expiry check step present in publish job before `vsce publish`
- [x] 6.2 Header comment block added (following `release.yml` pattern)
- [x] 6.3 Verified: no git tags, no releases, no cli/site mods, no write perms
- [x] 6.4 Commit: `ci(097): finalize vscode-marketplace workflow with documentation`

**Verification:**
```pseudo
GIVEN the complete workflow file
THEN it contains exactly 3 jobs: check-version, test, publish
  AND trigger is push to main with paths ['code/vscode/**', '.github/workflows/vscode-marketplace.yml']
  AND no permissions block exists (or only default read)
  AND no git tag or GitHub release steps exist
  AND header comment documents VSCE_PAT setup and .pat-expires maintenance
  AND publish job includes PAT expiry check step
```

---

## Phase 7 — Product Retrospective

**Entry criteria:** All previous phases complete. All checkboxes checked.

**Dependencies:** Phase 6.

- [x] 7.1 Validation report produced in retrospective.md
- [x] 7.2 Retrospective produced: what went well, deviations, surprises, spawn issues
- [x] 7.3 Final commit: `docs(097): execution retrospective`

---

## Job Dependency Graph

```
  ┌──────────────┐     ┌────────────┐
  │ check-version │     │    test     │
  │ (ubuntu-only) │     │ (matrix)   │
  └──────┬───────┘     └─────┬──────┘
         │                    │
         └───────┬────────────┘
                 │
          ┌──────▼───────┐
          │   publish     │
          │ (ubuntu-only) │
          │ if: should_   │
          │   publish     │
          │ ┌───────────┐ │
          │ │PAT expiry │ │
          │ │  check    │ │
          │ └───────────┘ │
          └──────────────┘
```

## Deliverables Summary

| Deliverable | Path |
|-------------|------|
| PAT expiration file | `code/vscode/.pat-expires` |
| PAT expiry unit test | `code/vscode/test/unit/pat-expiry.test.ts` |
| Workflow file | `.github/workflows/vscode-marketplace.yml` |
| Removed artifact | `ape-vscode-0.0.6.vsix` (if still tracked) |
| Retrospective | `docs/issues/097-automate-vscode-marketplace-publish/retrospective.md` |
