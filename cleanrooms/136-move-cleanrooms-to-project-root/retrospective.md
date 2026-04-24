# Retrospective — #136: Move cleanrooms/ to project root

## What went well

- The refactor was structurally clean: a single commit covered all 33 modified files with a coherent scope.
- `_detectDocsDirectory()` and its test group were deleted without hesitation — no dead-code debt left behind.
- All three test suites passed on first run after the change (160 dart, 60 unit, 12 integration), with zero `dart analyze` issues.
- The `.gitignore` update (`!cleanrooms/`) correctly excluded build artifacts while preserving the new root location.
- Build assets (non-git-tracked) were found on disk and updated anyway — no manual follow-up needed.

## What deviated from the plan

- **Phase 9 audit scope was underestimated.** The plan did not anticipate that working documents inside `cleanrooms/134-*` and `cleanrooms/136-*`, plus `CHANGELOG.md`, would contain `docs/cleanrooms` references. Fifteen additional files were updated during the audit phase.
- The plan assumed the audit would only touch source code and assets, not the cleanroom corpus itself.

## What surprised

- Historical cleanroom documents reference their own parent path. Because cleanrooms are versioned narrative artifacts, their internal references needed to be consistent with the new location — something not obvious from a pure code refactor perspective.
- Build assets were not git-tracked but were present on disk and correct to update. The distinction between "tracked" and "present" required a deliberate check rather than relying on `git status`.

## Spawn issues identified

- **#137** — `iq inquiry start` operational cycle-start command redesign (already created).
