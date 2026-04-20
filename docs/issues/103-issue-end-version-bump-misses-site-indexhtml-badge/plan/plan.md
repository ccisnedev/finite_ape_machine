# Plan — #103 issue-end version bump misses site index.html badge

**Issue:** #103
**Branch:** 103-issue-end-version-bump-misses-site-indexhtml-badge
**Phase:** PLAN

## Diagnosis Summary

The `issue-end` skill is generic and must NOT reference project-specific files.
The root cause is insufficient CI coverage: `ci.yml` only triggers on `code/cli/**`,
so `code/site/` changes alone never run `version_sync_test.dart`. The site has zero tests.

## Phases

### Phase 1: Expand CI trigger paths

Add `code/site/**` to the `ci.yml` paths filter so that any change to the site
triggers the full CLI test suite (which includes `version_sync_test.dart`).

- [x] 1.1 Add `code/site/**` to `ci.yml` push and pull_request paths

### Phase 2: Improve version sync test robustness

Make the existing `version_sync_test.dart` more robust and its error messages
more actionable.

- [x] 2.1 Improve error messages to tell the developer exactly which file and line to fix
- [x] 2.2 Add test that all three version sources are mutually consistent (triangular check)

### Phase 3: Add site validation tests

Create a dedicated site test file in `code/cli/test/` that validates
`code/site/` HTML structure beyond just the version badge.

- [x] 3.1 Create `site_test.dart` with HTML structure validations (required elements, meta tags, links)
- [x] 3.2 Add install script existence checks (install.ps1, install.sh must exist and be non-empty)

## Out of Scope

- Modifying the `issue-end` skill (it's generic, project-agnostic)
- Creating an `ape version bump` CLI command (separate enhancement)
- Adding a full HTML test framework for site/
