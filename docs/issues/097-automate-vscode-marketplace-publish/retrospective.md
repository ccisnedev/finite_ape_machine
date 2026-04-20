---
type: retrospective
scope: issue
issue: 97
title: Automate VS Code extension publishing to Marketplace
created: 2026-04-20
---

# Retrospective — Issue #097

## Validation Report

### What Was Implemented

1. **PAT expiration tracking** (`code/vscode/.pat-expires` + `test/unit/pat-expiry.test.ts`)
   - File-based expiration date as single source of truth
   - Unit test: warns at 30 days, fails at 7 days or if expired
   - Added to `.vscodeignore` to exclude from packaged `.vsix`

2. **GitHub Actions workflow** (`.github/workflows/vscode-marketplace.yml`)
   - 3-job architecture: `check-version` ∥ `test` → `publish`
   - Version check via `npx @vscode/vsce show` with first-publish fallback
   - Cross-platform test matrix (ubuntu-latest, windows-latest)
   - Conditional publish with PAT expiry guard step
   - Documented header comment following `release.yml` pattern

3. **Infrastructure** (manual, pre-workflow)
   - `VSCE_PAT` secret configured in GitHub Actions
   - `VSCE_PAT_EXPIRES` variable set as backup reference

### How to Verify

1. **Unit tests pass locally:**
   ```
   cd code/vscode && npm run test:unit
   ```
   Confirm `PAT Expiration Tracking` test passes (60 tests, 0 failing).

2. **Workflow triggers on merge:**
   After PR merges to `main`, the workflow runs if `code/vscode/**` changed.
   - If version unchanged → check-version outputs `should_publish=false` → publish skipped → green
   - If version bumped → tests run → publish executes

3. **Manual workflow review:**
   Open `.github/workflows/vscode-marketplace.yml` and verify the 3-job structure.

### Known Limitations

- `npx @vscode/vsce show` text output parsing uses `grep -oP` (Perl regex) — only
  available on GNU grep (Linux runners). Not an issue since check-version runs on
  `ubuntu-latest`, but would break on macOS runners.
- PAT expiry check in the workflow is a string comparison of ISO dates — correct but
  basic. Does not warn in advance (unit test handles that).
- No Open VSX Registry publishing (out of scope, future issue).

## What Went Well

- **TDD for PAT expiry test** — RED→GREEN cycle confirmed the test catches missing files
  before the file was created. Clean verification.
- **Plan structure** — 7 phases executed sequentially with no blocking deviations.
  Each phase produced a clean commit.
- **Existing patterns** — `release.yml`, `ci.yml`, and `pages.yml` provided clear
  templates for the workflow structure and conventions.
- **PAT setup during analysis** — Identifying the PAT gap during PLAN review and
  returning to ANALYZE prevented a blocked EXECUTE phase.

## What Deviated from the Plan

- **Phase 1 was a no-op** — the `.vsix` file was already untracked on this branch.
  The plan anticipated this possibility ("may be a no-op verification").
- **`.vscodeignore` update needed** — Phase 2.3 discovered `.pat-expires` would be
  packaged into the `.vsix` (`.vscodeignore` uses an exclude list, not allowlist).
  Added `.pat-expires` to `.vscodeignore`. Minor deviation, handled in-phase.
- **`vsce show --json` not used** — Plan noted the `--json` flag as primary approach.
  Execution used text output parsing with `grep -oP` instead. The `--json` flag behavior
  was uncertain; text parsing is reliable and simpler.

## What Surprised

- **PAT management complexity** — The analysis phase needed to return from PLAN to
  investigate PAT creation, Azure DevOps organization settings, and secret configuration.
  This was not anticipated in the initial triage but was essential.
- **`.vscodeignore` is an exclude list** — Initial assumption was allowlist patterns.
  This affected how `.pat-expires` would be packaged.

## Spawn Issues

None identified.
