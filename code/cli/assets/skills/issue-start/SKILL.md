---
name: issue-start
description: 'Protocol for starting work on a GitHub issue. Creates branch, working directory, and transitions to ANALYZE state.'
---

# issue-start — Infrastructure Creation Protocol

## When to Use

- When the scheduler APE is in IDLE state
- After identifying a GitHub issue to work on (or deciding to create a new one)
- Before transitioning from IDLE to ANALYZE

## Prerequisites

Run `iq doctor` and confirm all checks pass:

- ✓ inquiry version
- ✓ git
- ✓ gh
- ✓ gh auth
- ✓ gh copilot

If any check fails, follow the on-screen instructions to install the missing tool before proceeding.

## Steps

### Step 1: Verify Prerequisites

```bash
iq doctor
```

All checks must pass. Do not proceed if any check fails.

### Step 2: Identify or Create Issue

**If issue number is known:**
```bash
gh issue view <NNN> --json number,title
```

Extract `number` and `title` from the JSON response.

**If no issue exists:**
```bash
gh issue create --title "..." --body "..."
```

The command returns the new issue URL containing the issue number.

### Step 3: Generate Slug

Transform the issue title into a slug:

1. Lowercase the title
2. Replace spaces with hyphens (`-`)
3. Remove special characters (keep only `a-z`, `0-9`, `-`)
4. Limit to 50 characters
5. Trim trailing hyphens

**Examples:**
- "Fix login timeout" → `fix-login-timeout`
- "Add dark mode support!!!" → `add-dark-mode-support`
- "URGENT: Database migration script" → `urgent-database-migration-script`

### Step 4: Create Branch

Format: `<NNN>-<slug>`

```bash
git checkout -b <NNN>-<slug>
```

**Examples:**
- Issue #37 "Fix login timeout" → `git checkout -b 037-fix-login-timeout`
- Issue #142 "Add dark mode" → `git checkout -b 142-add-dark-mode`

Note: Pad issue numbers less than 100 with leading zeros for sort consistency.

### Step 5: Create Working Directory

```bash
mkdir -p cleanrooms/<NNN>-<slug>/analyze/
```

This creates the analysis directory for SOCRATES to work in during ANALYZE phase.

### Step 6: Create index.md

Create `cleanrooms/<NNN>-<slug>/analyze/index.md` with this template:

```markdown
# Analyze Phase — Index

**Issue:** #<NNN> — <title>
**Branch:** <NNN>-<slug>
**Phase:** ANALYZE
**Status:** In progress

---

## Documents

| # | File | Description |
|---|------|-------------|
```

### Step 7: Update state.yaml

Write `.inquiry/state.yaml` with:

```yaml
cycle:
  phase: ANALYZE
  task: "<NNN>"

ready: []
waiting: []
complete: []
```

Use the same raw string write pattern as `inquiry init` does.

### Step 8: Announce Transition

Output the state announcement:

```
[APE: ANALYZE]
```

The scheduler is now in ANALYZE state and should invoke SOCRATES for analysis work.

## Verification

After completing all steps, verify:

- [ ] Branch exists: `git branch --show-current` returns `<NNN>-<slug>`
- [ ] Directory exists: `cleanrooms/<NNN>-<slug>/analyze/index.md`
- [ ] State updated: `.inquiry/state.yaml` shows `phase: ANALYZE`

## Notes

- This skill is executed by the scheduler APE, not by a human
- The scheduler reads this document and executes commands step by step
- If any step fails, the scheduler should report the error and remain in IDLE
