---
id: idle-analysis
title: "Analysis of current IDLE state implementation in ape.agent.md"
date: 2026-04-17
status: active
tags: [idle, triage, ape-agent, gap-analysis]
author: socrates
---

# IDLE State Analysis

## Current State in ape.agent.md

Lines 36-48 define IDLE:

```markdown
### IDLE — Triage

You operate directly in this state (no sub-agent). Your function is **triage**...

1. Understand what the user needs — conversational, exploratory.
2. If the problem merits a cycle, determine if a GitHub issue already exists: `gh issue list --search "keyword"`.
3. If no issue exists, guide the user to create one: `gh issue create --title "..."`.
4. Once the issue is identified, prepare infrastructure: `ape issue start <NNN>` (creates branch, checkout, working directory).
5. When infrastructure is ready (issue + branch + `docs/issues/NNN-slug/analyze/`), suggest transitioning to ANALYZE.
```

## Issues Found

### 1. Reference to non-existent `ape issue start <NNN>`

**Location:** Line 43, Line 201

**Problem:** `ape issue start` is not a CLI command. It doesn't exist.

**Fix:** Replace with skill reference. The IDLE state (scheduler) should read the `issue-start` skill and execute the steps manually:
- `git checkout -b NNN-slug`
- `mkdir -p docs/issues/NNN-slug/analyze/`
- Create `index.md`
- Update `.ape/state.yaml`

### 2. `ape doctor` checks incomplete

**Location:** Line 48

**Current:** "Verify prerequisites: `ape doctor` confirms git, gh, and gh auth are available."

**Should be:** `ape doctor` verifies:
- ape version
- git
- gh
- gh auth status
- GitHub Copilot CLI (`gh copilot --version`)

### 3. Missing skill reference

**Problem:** IDLE section doesn't mention reading the `issue-start` skill.

**Fix:** Add instruction to read `skills/issue-start/SKILL.md` when preparing infrastructure.

### 4. Transition effect missing for IDLE → ANALYZE

**Location:** Line 159 shows transition effects for other states but not for IDLE → ANALYZE.

**Fix:** Add that IDLE → ANALYZE requires:
- Issue identified (number + title)
- Branch created
- Folder created
- state.yaml updated

## Proposed Changes

The `ape.agent.md` needs updates in:

1. **IDLE section** — Replace `ape issue start` with manual steps per `issue-start` skill
2. **IDLE section** — Expand `ape doctor` checks list
3. **IDLE section** — Add: "Read `skills/issue-start/SKILL.md` for infrastructure creation steps"
4. **Transitions section** — Add effect for IDLE → ANALYZE
5. **Directory Structure section** — Remove `ape issue start` reference

## Impact

These changes are **documentation only**. No Dart code changes for IDLE.

The `ape doctor` command IS code — needs implementation in v0.0.8.
