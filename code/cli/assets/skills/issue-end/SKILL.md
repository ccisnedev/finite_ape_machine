---
name: issue-end
description: 'Protocol for ending an APE cycle. Use when: all plan.md checkboxes are complete, ready to release. Guides: version bump, changelog, commit, PR, EVOLUTION transition.'
---

# issue-end — Cycle Completion Protocol

## When to Use

- When the scheduler APE is in EXECUTE state
- After all plan.md checkboxes are checked `- [x]`
- After all tests pass
- Ready to release and create PR

## Prerequisites

- Phase must be EXECUTE
- All plan.md checkboxes must be complete
- All tests must pass (`dart test` or equivalent)
- `dart analyze` must pass with no errors

## Steps

### Step 1: Verify Phase

Confirm current phase is EXECUTE:

```bash
# Check state (if using .inquiry/state.yaml)
cat .inquiry/state.yaml
```

Expected: `phase: EXECUTE`

If not EXECUTE, abort with message:
> "Cannot end cycle: current phase is {phase}, expected EXECUTE"

### Step 2: Verify Plan Completion

Read `docs/cleanrooms/{slug}/plan.md` and verify:
- All checkboxes `- [ ]` are now `- [x]`

```bash
# Count incomplete checkboxes
grep -c "\- \[ \]" docs/cleanrooms/{slug}/plan.md
```

Expected: 0 incomplete checkboxes.

If incomplete checkboxes remain, list them and abort.

### Step 3: Determine Version Bump

Ask user to confirm semver bump type:

| Type | When to Use |
|------|-------------|
| PATCH | Bug fixes only, no new features |
| MINOR | New features, backward compatible |
| MAJOR | Breaking changes |

Calculate new version from current `apeVersion` in `lib/src/version.dart`:

```bash
# Read current version
grep "inquiryVersion" lib/src/version.dart
```

**Examples:**
- Current: 0.0.8, PATCH → 0.0.9
- Current: 0.0.9, MINOR → 0.1.0
- Current: 0.1.0, MAJOR → 1.0.0

### Step 4: Update Version Files

Update both files with the new version:

**1. `pubspec.yaml`:**
```yaml
version: X.Y.Z
```

**2. `lib/src/version.dart`:**
```dart
const String inquiryVersion = 'X.Y.Z';
```

### Step 5: Update CHANGELOG

Add entry at top of `CHANGELOG.md` (after header):

```markdown
## [X.Y.Z]
### Added
- {list new features from plan.md phases}
### Changed
- {list changes from plan.md phases}
### Fixed
- {list bug fixes from plan.md phases}
```

Derive content from plan.md phases. Only include sections that apply.

### Step 6: Commit Release

```bash
git add -A
git commit -m "vX.Y.Z: {summary from issue title}"
```

Commit message format: `vX.Y.Z: <issue-title-summary>`

**Examples:**
- `v0.0.9: fix version inconsistency + skill issue-end + TUI ape`
- `v0.1.0: add authentication module`

### Step 7: Push Branch

```bash
git push -u origin {branch}
```

### Step 8: Create Pull Request

```bash
gh pr create \
  --title "vX.Y.Z: {issue-title}" \
  --body "Closes #{issue-number}

## Summary
{brief summary of changes from diagnosis.md}

## Checklist
- [ ] All tests pass
- [ ] CHANGELOG updated
- [ ] Version bumped
"
```

**Important:** PR creation = APE cycle completion. The APE cycle ends here.

- PR merge is an **external event** (happens later, possibly with CI checks)
- DARWIN collects retrospective data from this cycle
- Do not wait for PR merge to transition to EVOLUTION

### Step 9: Transition to EVOLUTION

Update `.inquiry/state.yaml` (if using state tracking):

```yaml
phase: EVOLUTION
issue: {issue-number}
branch: {branch}
version: X.Y.Z
```

Announce state change:
> `[APE: EVOLUTION]`

## After PR Merge

When the PR is merged:
1. The APE cycle terminates
2. State returns to IDLE
3. DARWIN may run process evaluation (if enabled)

## Quick Reference

```
1. Verify EXECUTE phase
2. Verify plan completion (all checkboxes checked)
3. Determine semver bump (PATCH/MINOR/MAJOR)
4. Update version files (pubspec.yaml + lib/src/version.dart)
5. Update CHANGELOG.md
6. Commit: git add -A && git commit -m "vX.Y.Z: ..."
7. Push: git push -u origin {branch}
8. Create PR: gh pr create --title "vX.Y.Z: ..."
9. Transition to EVOLUTION
```
