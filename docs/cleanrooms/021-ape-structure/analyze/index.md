---
id: index
title: "Analysis index — #21 APE structure and .ape/ directory"
date: 2026-04-16
status: completed
tags: [index, analysis, ape-structure, init, architecture]
author: socrates
---

# Analysis: #21 APE Structure

Analysis of the APE runtime model, state persistence, and directory structure. These documents capture architectural decisions made during conversation, including contradictions found with existing specs that need resolution.

## Documents (in this issue)

| ID | Title | Date | Status | Tags |
|----|-------|------|--------|------|
| state-persistence | State persistence — .ape/ as cache, docs/ as source of truth | 2026-04-16 | active | architecture, state, persistence, gitignore, docs, resumability |
| ape-init-scope | ape init — minimal idempotent scope | 2026-04-17 | active | cli, init, scope, idempotent, docs-detection |

## Documents (moved to docs/references/ for future work)

| ID | Title | New Location |
|----|-------|-------------|
| cooperative-multitasking-model | Cooperative multitasking model — two-level FSM architecture | [docs/references/](../../references/cooperative-multitasking-model.md) |
| agent-lifecycle | Agent lifecycle — confirmed registry and five-state scheduler model | [docs/references/](../../references/agent-lifecycle.md) |
| cli-as-api | CLI as API — skills instruct, commands execute | [docs/references/](../../references/cli-as-api.md) |
| signal-based-coordination | Signal-based coordination — RTOS event model for agent communication | [docs/references/](../../references/signal-based-coordination.md) |

## Contradictions Found with Existing Specs

| Spec | Section | Issue |
|------|---------|-------|
| finite-ape-machine.md | §2.1 | RETROSPECTIVE not a formal FSM state; uses REVIEW + DARWIN separately |
| finite-ape-machine.md | §3.2 | Detailed per-agent FSMs imply scheduler tracks granular states; should be IDLE/RUNNING/COMPLETE |
| orchestrator-spec.md | §3.2 | status.md treated as source of truth; should be a reconstructible cache |
| orchestrator-spec.md | §3.3 | Uses REVIEW → DARWIN as separate phases; should be RETROSPECTIVE as single state |
| orchestrator-spec.md | §3.5 | Precondition polling model; should be signal-based |

## Resolved Questions

1. **Directory naming**: `docs/issues/{NNN-slug}/` — each APE cycle starts with an issue and ends with a PR. The slug matches the branch name. Decided 2026-04-17.
2. **Project structure**: `ape init` only creates what APE needs (`.ape/`, `docs/issues/`, `.gitignore` entry, agent deploy). Project scaffolding is a separate future command (`ape scaffold`). Decided 2026-04-17.
3. **ADR directory**: NOT part of `ape init` — it's opinionated and not directly related to APE operation. Belongs in `ape scaffold`. Decided 2026-04-17.

## Open Questions

1. Signal persistence: should pending signals survive in `.ape/state.yaml`?
2. `doc/` vs `docs/`: `ape init` detects which exists; if both or neither, prefers `docs/`. Needs implementation detail.
