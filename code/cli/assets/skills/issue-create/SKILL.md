---
name: issue-create
description: 'Protocol for deterministically selecting or creating a GitHub issue during IDLE TRIAGE.'
---

# issue-create - TRIAGE Issue Selection Protocol

## When to Use

- When the scheduler APE is in IDLE/TRIAGE
- When work needs a GitHub issue to be confirmed or created
- Before explicit start intent and before issue-start

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

### Step 2: Search for an Existing Issue

**If the issue number is already known:**
```bash
gh issue view <NNN> --json number,title,state
```

Confirm the issue already exists and extract `number` and `title` from the JSON response.

**If the issue number is not yet known:**
```bash
gh issue list --state open --search "<keywords>" --limit 20
```

Use the results to confirm whether an existing issue already captures the work.

### Step 3: Create the Issue if No Match Exists

```bash
gh issue create --title "..." --body "..."
```

Record the new issue number and title from the returned URL or follow-up lookup.

### Step 4: Confirm the Selected or Created Issue

```bash
gh issue view <NNN> --json number,title,state
```

Use this response as the canonical issue identity for the later operational handoff.

### Step 5: Stop in IDLE/TRIAGE

Report `issue_selected_or_created` with the confirmed issue number and title.
Do not create a branch or cleanroom.
Do not fire `start_analyze`; that belongs to `issue-start` after explicit start intent.

## Verification

After completing all steps, verify:

- [ ] `gh issue view <NNN> --json number,title,state` succeeds
- [ ] The issue number and title are confirmed for handoff
- [ ] No branch or cleanroom was created

## Notes

- This skill is executed by the scheduler APE, not by a human
- The scheduler remains in IDLE/TRIAGE after issue readiness
- If any step fails, the scheduler should report the error and remain in IDLE