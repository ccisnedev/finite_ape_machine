---
id: ape-init-scope
title: "ape init — minimal idempotent scope"
date: 2026-04-17
status: active
tags: [cli, init, scope, idempotent, docs-detection]
author: socrates
---

# ape init — Minimal Idempotent Scope

## What `ape init` Does

Five steps, all idempotent (running twice changes nothing):

### 1. Detect docs directory

Scan project root for `doc/` and `docs/`:
- If only `doc/` exists → use `doc/`
- If only `docs/` exists → use `docs/`
- If both exist → prefer `docs/`
- If neither exists → create `docs/`

### 2. Create `{docs}/issues/`

If `{docs}/issues/` does not exist, create it. This is where APE cycle artifacts live, organized by issue slug matching the branch name.

### 3. Add `.ape/` to `.gitignore`

If `.gitignore` exists and does not contain `.ape/`, append it. If `.gitignore` does not exist, create it with `.ape/`.

### 4. Create `.ape/` directory

Create `.ape/state.yaml` with initial state:

```yaml
cycle:
  phase: IDLE
  task: null

ready: []
waiting: []
```

### 5. Deploy scheduler agent

Deploy `ape.agent.md` to the active target (e.g., `~/.copilot/agents/`). This is the only agent visible to the AI tool. Sub-agents are embedded in `ape.exe`.

## What `ape init` Does NOT Do

- Does NOT create `docs/adr/` — opinionated, belongs in future `ape scaffold`
- Does NOT create `code/`, `.github/`, `.vscode/` — project structure is not APE's concern
- Does NOT modify existing files (except appending to `.gitignore`)
- Does NOT create README.md, CHANGELOG.md, or any project-level files

## Idempotency Contract

| Step | If already done |
|------|----------------|
| Detect docs | Uses existing directory |
| Create issues/ | Skips (directory exists) |
| .gitignore entry | Skips (entry already present) |
| .ape/ directory | Overwrites state.yaml only if missing |
| Deploy agent | Overwrites agent file (ensures latest version) |

## Future: `ape scaffold`

A separate command for opinionated project structure:

```bash
ape scaffold ./my-project
```

Would create: `code/`, `docs/adr/`, `.github/workflows/`, per-project README/CHANGELOG, etc. This is explicitly out of scope for `ape init`.

## Relationship to Skills

A future skill will instruct the AI agent: "If the APE structure is not detected, run `ape init` before proceeding." Because `ape init` is idempotent, this is safe to execute defensively.
