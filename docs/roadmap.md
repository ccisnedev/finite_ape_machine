# Roadmap

> Status note: This roadmap is a strategic and partially historical planning document. It preserves backlog framing from earlier releases and should not be used as the authoritative description of the current operational model. For the current canonical explanation, see [architecture.md](architecture.md), [spec/finite-ape-machine.md](spec/finite-ape-machine.md), and [thinking-tools.md](thinking-tools.md).

> Where APE is going next. For where APE is today, see [../README.md](../README.md).

> Live roster note: DEWEY now owns bounded IDLE triage in the current contract; `issue-start` remains the explicit handoff into ANALYZE.

This roadmap is **descriptive, not prescriptive**: it reflects the open issues currently in the backlog and the long-running theses that motivate the project. Anything not backed by an issue is exploratory.

## Vision

APE aims to be a **methodology that survives any AI market scenario**. Three theses guide every decision:

1. **Methodology > model.** A small local model following a structured runbook should outperform a frontier model freestyling. If true, APE generalizes.
2. **Memory as code.** Project knowledge belongs in the repo, version-controlled, queryable by any agent — not in a cloud-hosted vector DB.
3. **Antifragility.** Each cycle should leave APE measurably better. DARWIN turns operational friction into improvements to the framework itself.

The end-state is an **APE that builds APE**: a self-improving framework where every cycle generates evidence (in `metrics.yaml`, in evolution issues, in mutations.md) that feeds the next cycle.

## Historical planning snapshot (v0.0.14)

- 5-state FSM with declarative transition contract (IDLE / ANALYZE / PLAN / EXECUTE / EVOLUTION)
- 9 working CLI commands across 3 modules (`global`, `target`, `state`)
- Single-target deployment (Copilot) per [ADR D20](spec/target-specific-agents.md)
- Active roster at that snapshot: SOCRATES, DESCARTES, BASHŌ, DARWIN
- 131 tests, cross-platform (Windows + Linux), 12 GitHub releases
- Empirical bootstrap underway: APE is being built using APE (see [bootstrap-validation](research/ape_builds_ape/bootstrap-validation.md))

## Near-term (v0.0.x → v0.1.0)

Open issues actively being worked or queued. Grouped by theme.

### FSM completeness
- **#62** — Add `END` state to transition contract (PR gate between EXECUTE and EVOLUTION)
- **#63** — Backward transitions: `PLAN → ANALYZE`, `EXECUTE → ANALYZE`; mark `EVOLUTION + block` illegal

### Cycle memory infrastructure
- **#47** — `evolution_notes.md` lifecycle in `.inquiry/`
- **#48** — `.inquiry/` as cycle memory accessible to subagents
- **#49** — Single-task-per-cycle rule (one issue → one cycle, no scope drift)
- **#57** — EVOLUTION fully internal (no human intervention required during DARWIN's pass)

### Subagent delegation
- **#46** — Delegate research to subagent during ANALYZE (reduces SOCRATES context window pressure)

### Cross-cycle features
- **#60** — Cross-repo dependency chains (when an APE cycle modifies an upstream dependency)
- **#50** — Dual language config (es/en outputs depending on user preference)

### Research data collection
- **#72** — `metrics.yaml` per cycle (foundation for the empirical paper; reproducibility currently scored 2/10)

## Mid-term (v0.1.x → v0.5.0)

Larger features that require infrastructure from the near-term to land first. Not yet split into discrete issues.

### `iq memory` CLI
First-class commands for the Memory-as-Code spec:
- `iq memory query` — index-aware lookup over `docs/`
- `iq memory validate` — schema enforcement (this is where **BORGES** materializes as a skill, not a separate agent)
- `iq memory write` — guided creation of new memory artifacts

### `iq task` CLI
Replace the manual `gh issue create / gh pr create / gh pr merge` dance with a single command per FSM transition. Currently the agent calls `gh` directly; `iq task` would wrap that with prechecks (issue exists, branch matches issue number, no scope drift per #49).

### Multi-target reactivation
The deferred half of [ADR D20](spec/target-specific-agents.md). Adapters already exist for Claude Code, Crush, Codex, and Gemini — they just aren't wired into `iq target get`. Reactivation requires:
1. Stable agent prompt API (so the same APE methodology runs identically across hosts)
2. A test matrix that runs the same APE cycle against multiple targets
3. The metrics system from #72 to compare targets quantitatively

### Antifragility validation harness
A test rig that runs N identical APE cycles against M targets (Copilot, Crush, local Gemma) and aggregates `metrics.yaml` to validate or refute the **methodology > model** thesis.

## Long-term (v1.0+)

Theses that take the project beyond a CLI tool.

### Local-first APE
A reference deployment running entirely on local models (Gemma, Qwen, etc.) with no cloud dependency. This is the hardest test of thesis #1: if APE makes a 7B local model competitive with a frontier cloud model on real cycles, the framework's value is proven.

### Bootstrap-validation paper
Publish the empirical paper on APE-builds-APE. Requires the full metrics dataset from #72 and at least 30 cycles of clean data. Plan: [research/ape_builds_ape/bootstrap-validation.md](research/ape_builds_ape/bootstrap-validation.md).

### DARWIN community-level learning
Currently DARWIN proposes mutations only to *this* repo's APE. The long-term vision is a community-level DARWIN that aggregates evolution issues across many APE-using projects to propose changes upstream to the framework itself.

### Risk-matrix-driven UX
The semantic risk matrix exists in spec but not yet in CLI behavior. End-state: `iq fsm transition` automatically gates on human approval only when the risk class warrants it, and silently proceeds otherwise.

## Lore vs reality

The original [lore.md](lore.md) sketched 9+ apes. After two months of building APE with APE, the roster collapsed to a smaller live set. In the current contract, DEWEY owns IDLE triage alongside SOCRATES, DESCARTES, BASHŌ, and DARWIN. This is honest accounting, not a roadmap commitment to revive deferred ones — most other roles were absorbed by simpler operators that turned out to do the job better.

| Lore agent | Status | What happened |
|---|---|---|
| **DEWEY** | ✅ Active | IDLE — bounded issue triage and explicit handoff to `issue-start` |
| **SOCRATES** | ✅ Active | ANALYZE — implemented as the mayéutica agent |
| **DESCARTES** | ✅ Active | PLAN — replaces SUNZI's strategy + VITRUVIUS's WBS in one Cartesian Method |
| **BASHŌ** | ✅ Active | EXECUTE — replaces ADA's TDD with techne (functional beauty under constraints) |
| **DARWIN** | ✅ Active | EVOLUTION — implemented; produces concrete evidence (e.g. issue #54) |
| **MARCOPOLO** | Absorbed | Document ingestion handled by SOCRATES + the `memory-read` skill |
| **VITRUVIUS** | Absorbed | WBS / decomposition is part of DESCARTES's plan phase |
| **SUNZI** | Replaced | DESCARTES's Method is more explicit and testable than strategic prose |
| **GATSBY** | Absorbed | Test pseudocode lives in `plan.md` written by DESCARTES |
| **ADA** | Replaced | BASHŌ's techne replaces explicit TDD as a separate phase |
| **DIJKSTRA** | Future skill | Quality-gate becomes a `pre-pr-review` skill inside END, not a separate agent |
| **BORGES** | Future skill | Schema validation becomes `iq memory validate`, not a standalone ape |
| **HERMES** | Materialized | State transitions are now `iq fsm transition` (CLI command, not an agent) |

The lesson: **the framework wants fewer, sharper agents, not more**. Each absorption was driven by a real cycle where two agents were doing what one could do better.

## How this roadmap is updated

- **Near-term** items are GitHub issues in the backlog. They appear and disappear as DARWIN proposes and the maintainer accepts/rejects.
- **Mid-term** items become near-term once split into concrete issues with acceptance criteria.
- **Long-term** items are theses, not commitments. They move forward only when evidence justifies the investment.

If you want the absolute current state, run `gh issue list --state open` and `gh release list`.
