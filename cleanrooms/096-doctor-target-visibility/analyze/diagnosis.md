---
id: diagnosis
title: Technical diagnosis - ape doctor target verification feature
date: 2026-04-20
status: ready-for-plan
tags: [doctor-command, targets, agents, skills, diagnosis]
author: SOCRATES
---

# Technical Diagnosis: ape doctor Target Verification Feature

## Problem Statement

**The Gap:** After a user runs `ape init`, the local APE infrastructure is initialized (`.ape/state.yaml`, `.ape/config.yaml`, `.ape/mutations.md`), but **agents and skills are NOT deployed**. Deployment is the separate responsibility of `ape target get`.

**Missing Feedback:** There is no diagnostic mechanism to verify whether deployment has occurred. Users may believe their setup is complete when the agent remains invisible to Copilot.

**Goal:** Extend `ape doctor` to verify agent and skill visibility in target deployment directories, bridging the gap between `ape init` and `ape target get`.

---

## Current State

### 1. What `ape doctor` Checks Today

Located in `code/cli/lib/modules/global/commands/doctor.dart`:

| Check | Executable | Purpose |
|-------|-----------|---------|
| ape | (internal) | Reports current APE version |
| git | `git --version` | Verifies Git is installed |
| gh | `gh --version` | Verifies GitHub CLI is installed |
| gh auth | `gh auth status` | Verifies GitHub authentication |

**Early Exit:** If any prerequisite fails, doctor stops immediately and returns exit code 1.

**Output Format:**
```
Checking prerequisites...
  ✓ ape 0.0.14
  ✓ git 2.45.1
  ✓ gh 2.51.0
  ✓ gh auth

All checks passed.
```

### 2. What `ape init` Does and Does NOT Do

Located in `code/cli/lib/modules/global/commands/init.dart`:

**Init creates (7 idempotent steps):**
1. Detects or creates `docs/` directory
2. Creates `{docs}/issues/` if missing
3. Adds `.ape/` to `.gitignore`
4. Creates `.ape/state.yaml` with IDLE state
5. Creates `.ape/config.yaml` with defaults
6. Creates `.ape/mutations.md` with header template
7. **Does NOT deploy** — delegated to `ape target get`

### 3. What `ape target get` Deploys and Where

Located in `code/cli/lib/targets/deployer.dart`:

**Skills Deployment:**
- Source: `code/cli/assets/skills/<skillName>/SKILL.md`
- Target: `~/.copilot/skills/<skillName>/SKILL.md`
- Dynamic discovery via `Assets.listDirectory('skills')`

**Agents Deployment:**
- Source: `code/cli/assets/agents/ape.agent.md`
- Target: `~/.copilot/agents/ape.agent.md`

**CopilotAdapter Paths** (`code/cli/lib/targets/copilot_adapter.dart`):
- Base: `~/.copilot/`
- Skills: `~/.copilot/skills/`
- Agents: `~/.copilot/agents/`

---

## Decisions

| # | Decision | Rationale |
|----|----------|-----------|
| **D1** | Existence-only check, no version matching | v0.0.x stage; simplicity reduces risk |
| **D2** | Only active targets (Copilot) | MVP scope; only CopilotAdapter currently deployed |
| **D3** | File existence in deployment dirs | Core question: "Can Copilot see the agent and skills?" |
| **D4** | Passive verification + suggest remedy | flutter doctor pattern: diagnose, never auto-fix |
| **D5** | Missing ~/.copilot/ = failed check | Directory absence is a deployment problem |
| **D6** | Asymmetric verbosity: clean OK, detailed error | Passing = brief; Failure = detailed + remediation |
| **D7** | Dynamic skill discovery from asset tree | No hardcoded list; new skills auto-verified |
| **D8** | Only report missing items, not full tree | Focused error reporting |
| **D9** | Missing target = fatal (exit 1) | Purpose of ape is to serve targets |
| **D10** | No .ape/ → suggest `ape init`; then check targets separately | Two independent diagnostics, both reported |

---

## Expected Behavior

### Scenario A: All Checks Pass

```
Checking prerequisites...
  ✓ ape 0.0.14
  ✓ git 2.45.1
  ✓ gh 2.51.0
  ✓ gh auth
Checking targets...
  ✓ copilot: agent + 4 skills deployed

All checks passed.
```

**Exit Code:** 0

### Scenario B: Target Not Deployed

```
Checking prerequisites...
  ✓ ape 0.0.14
  ✓ git 2.45.1
  ✓ gh 2.51.0
  ✓ gh auth
Checking targets...
  ✗ copilot: agent not deployed
  ✗ copilot: missing skills: issue-start, issue-end, memory-read, memory-write
    → Run 'ape target get' to deploy

Some checks failed.
```

**Exit Code:** 1

### Scenario C: No .ape/ Directory (Init Not Run)

```
Checking prerequisites...
  ✓ ape 0.0.14
  ✓ git 2.45.1
  ✓ gh 2.51.0
  ✓ gh auth
  ✗ ape not initialized
    → Run 'ape init' to initialize
Checking targets...
  ✗ copilot: agent not deployed
  ✗ copilot: missing skills: issue-start, issue-end, memory-read, memory-write
    → Run 'ape target get' to deploy

Some checks failed.
```

**Exit Code:** 1

### Scenario D: Partial Deployment (Agent OK, Some Skills Missing)

```
Checking prerequisites...
  ✓ ape 0.0.14
  ✓ git 2.45.1
  ✓ gh 2.51.0
  ✓ gh auth
Checking targets...
  ✓ copilot: agent deployed
  ✗ copilot: missing skills: memory-read
    → Run 'ape target get' to deploy

Some checks failed.
```

**Exit Code:** 1

---

## Constraints

- Doctor **must not modify files** (read-only diagnostic)
- Doctor **must not create directories** (no implicit init)
- Doctor **must not deploy** (that is `ape target get`'s responsibility)
- Skill list is **dynamic** (discovered from assets, not hardcoded)

## Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| Asset discovery differs between compiled binary and dev mode | Medium | Assets class abstracts discovery; root path injectable for testing |
| Path resolution across OS (~/. on Windows vs Linux vs macOS) | Medium | Use Platform.environment HOME/USERPROFILE; verify in cross-platform tests |
| Race condition during concurrent deployment | Low | Acceptable for v0.0.x diagnostic tool |

## Scope

### IN Scope
- Prerequisite checks (ape, git, gh, gh auth) — already implemented
- `.ape/` directory existence check
- Agent file existence in deployment directory
- Skills file existence in deployment directories
- Dynamic skill discovery from asset tree
- Remediation suggestions
- Exit code 1 on any failure

### OUT of Scope
- Version matching
- Content/frontmatter validation
- Auto-fix or auto-deployment
- Non-Copilot targets (Claude, Codex, Gemini, Crush)

## References

- Issue: #96 — ape doctor: verify agent and skill visibility per target
- Scope Decisions: `docs/issues/096-doctor-target-visibility/analyze/scope-decisions.md`
- Current Doctor: `code/cli/lib/modules/global/commands/doctor.dart`
- Target Adapter: `code/cli/lib/targets/copilot_adapter.dart`
- Deployer: `code/cli/lib/targets/deployer.dart`
- Asset Discovery: `code/cli/lib/assets.dart`
- Tests: `code/cli/test/doctor_test.dart`
