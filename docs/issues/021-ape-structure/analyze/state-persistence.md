---
id: state-persistence
title: "State persistence — .ape/ as cache, docs/ as source of truth"
date: 2026-04-16
status: active
tags: [architecture, state, persistence, gitignore, docs, resumability]
author: socrates
---

# State Persistence Architecture

## The Three Layers

```
ape.exe (immutable between releases)
├── Agent prompts (SOCRATES, ADA, etc.) — embedded
├── Signal routing table
├── Valid states per agent
├── CLI commands (ape memory write, ape signal, etc.)
└── Document templates

.ape/ (transient, .gitignore)
├── state.yaml — runtime state cache
└── Reconstructed on-demand from docs/

docs/ (persistent, git-versioned)
├── issues/{NNN-slug}/analyze/ — analysis artifacts
├── issues/{NNN-slug}/plan.md — plan with checklist
├── adr/ — architecture decision records (not managed by ape init)
└── references/ — specs, papers
```

## Design Decisions

### D1: `.ape/` is gitignored

The `.ape/` directory is a **runtime cache**, not a source of truth. If deleted, `ape.exe` reconstructs it from `docs/`. If the repo is cloned on a new machine, `.ape/` does not exist and is rebuilt.

**Rationale:** The state that matters (analysis documents, plans with checklists, ADRs) already lives in `docs/` and is committed. `.ape/` only accelerates what could be derived.

### D2: docs/ is the source of truth for resumability

Resuming work does NOT depend on `.ape/`. It depends on:

- `docs/issues/{NNN-slug}/analyze/` — what analysis was done
- `docs/issues/{NNN-slug}/plan.md` — checklist showing execution progress
- Git history — what was committed

Any AI tool (Copilot, Claude, Codex, Gemini) can read `docs/` and understand where work left off. No `.ape/` required.

### D3: ape.exe is self-contained

Agent prompts, signal routing, state definitions, and document templates are **embedded in the binary**. Updating an agent requires a new ape.exe release.

**Rationale:** Atomic releases. `ape 0.0.7` has a tested SOCRATES prompt. No drift between CLI version and prompt version. Like firmware — you update everything together.

### D4: Sub-agents are ephemeral, not deployed

Only the scheduler agent (`ape.agent.md`) is deployed to `~/.copilot/agents/`. Sub-agents (SOCRATES, ADA, etc.) are **instantiated by ape.exe at runtime** with clean context. They execute, produce artifacts in `docs/`, and disappear.

**Rationale:** The AI tool (Copilot) only needs to see the scheduler. The scheduler delegates to sub-agents via ape.exe. The sub-agent's prompt is embedded in the binary; its output goes to `docs/`.

## state.yaml Schema

```yaml
# .ape/state.yaml — cache, reconstructible from docs/
cycle:
  phase: ANALYZE          # IDLE | ANALYZE | PLAN | EXECUTE | RETROSPECTIVE
  task: "022-copilot-only" # Active task (issue slug)

ready:
  - name: socrates
    state: READY            # READY | RUNNING

waiting: []                   # agents blocked on signals

complete: []                  # agents that finished
```

## Reconstruction Flow

```
repo cloned / .ape/ missing
  │
  ▼
ape status (or ape init)
  │
  ├── Scan docs/issues/ for active tasks
  ├── Read plan.md checklists for execution state
  ├── Determine current phase from artifacts
  └── Write .ape/state.yaml
```

## Relationship to Existing Specs

The [orchestrator-spec](../../references/orchestrator-spec.md) §3.2 defines `status.md` as the orchestrator's memory between ticks. This analysis **replaces** `status.md` with `state.yaml` in `.ape/` and moves the persistent state to `docs/`. The orchestrator-spec's `status.md` conflates runtime state with persistent record — this separation resolves that.

## Contradiction with orchestrator-spec

The orchestrator-spec §3.2 puts `status.md` in `.ape/memory/` and treats it as the single source of truth. This analysis determines that `status.md` should be a **reconstructible cache**, not a source of truth. The source of truth is `docs/`. The spec needs to be updated.
