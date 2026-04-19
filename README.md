# Finite APE Machine

> Infinite monkeys produce noise. Finite APEs produce software.

A framework for AI-assisted software development that models coding agents as a cooperative finite state machine. APE replaces "vibe coding" with a deterministic methodology cycle — **Analyze → Plan → Execute → End → [Evolution] → Idle** — where the value is in the process, not the model.

**Status:** `v0.0.14` · 131 tests · 12 GitHub releases · Windows + Linux · Single-target MVP (Copilot)

## What is APE?

APE treats coding agents ("apes") as states of a finite state machine. Each state has one specialized agent in charge, a declarative transition contract, and pre/post-conditions enforced by the CLI. Intelligence emerges from orchestration and memory, not from any single agent's capability.

**Core ideas:**

- **Agents as FSM states** — each phase has one ape; transitions are declarative, total, and validated (`code/cli/assets/transition_contract.yaml`)
- **Methodology over model** — a smaller model following APE's runbook beats a frontier model freestyling
- **Memory as Code** — project memory as version-controlled markdown in `.ape/` and `docs/`. No vector DB, no cloud dependency
- **DARWIN** — an evolutionary meta-agent that proposes mutations to APE itself after each cycle
- **Semantic risk matrix** — human approval only when engineering judgment matters

## Quick start

### Install (Windows)

```powershell
irm https://www.ccisne.dev/finite_ape_machine/install.ps1 | iex
```

### Install (Linux)

```bash
curl -fsSL https://www.ccisne.dev/finite_ape_machine/install.sh | bash
```

The installer downloads the latest release, places `ape` on `PATH`, and verifies prerequisites.

### Initialize a repository

```bash
ape doctor               # verify ape, git, gh, gh auth
ape target get           # deploy APE agent + skills to ~/.copilot
cd your-repo
ape init                 # create .ape/{state,config,mutations}
ape                      # show TUI banner with current FSM state
```

## Available commands

| Command | Purpose |
|---|---|
| `ape` | TUI banner with current FSM state and diagram |
| `ape init` | Idempotent scaffolding of `.ape/` (state.yaml, config.yaml, mutations.md) |
| `ape doctor` | Verify prerequisites: `ape`, `git`, `gh`, `gh auth` |
| `ape version` | Print CLI version |
| `ape upgrade` | Download and install latest release |
| `ape uninstall` | Remove `ape` binary and deployed assets |
| `ape target get` | Deploy APE agent and skills to active AI tool (Copilot) |
| `ape target clean` | Remove deployed APE files from all known targets |
| `ape state transition --event <e>` | Execute a deterministic FSM transition with prechecks/effects |

## The APE cycle

```
IDLE ──start_analyze──▶ ANALYZE ──complete_analysis──▶ PLAN
                          │                              │
                          │                       approve_plan
                          │                              ▼
                          └────── start_analyze ──── EXECUTE
                                                        │
                                                  finish_execute
                                                        ▼
                          IDLE ◀── finish_end ──── END (PR gate)
                            ▲                          │
                            │                    finish_end
                            │                          ▼
                            └─── finish_evolution ── EVOLUTION
                                  (when enabled)
```

| State | Agent | Function | Output |
|---|---|---|---|
| **ANALYZE** | SOCRATES | Mayéutica — clarify requirements via dialog | `diagnosis.md` |
| **PLAN** | DESCARTES | Method — divide, order, verify, enumerate | `plan.md` |
| **EXECUTE** | BASHŌ | Techne — minimal, beautiful implementation under tests | code + commits |
| **END** | — | PR gate — `gh pr create` + `gh pr merge` | merged PR |
| **EVOLUTION** | DARWIN | Natural selection — propose APE mutations | issues in this repo |

EVOLUTION is opt-in (`evolution.enabled` in `.ape/config.yaml`) and one-shot: if interrupted, the cycle simply returns to IDLE.

## Architecture

- **CLI:** Dart, compiled to a single cross-platform binary, built on top of [`modular_cli_sdk`](https://github.com/ccisnedev/modular_cli_sdk)
- **Modules:** `global` (init, doctor, version, upgrade, uninstall, tui), `target` (get, clean), `state` (transition)
- **FSM:** declarative `transition_contract.yaml` parsed into `FsmContract` — every (state, event) pair is total (allowed or explicitly illegal)
- **Targets:** Copilot only in v0.0.x per [ADR D20](docs/spec/target-specific-agents.md). Adapters for Claude/Codex/Crush/Gemini exist for cleanup but are deferred until MVP
- **Memory:** `.ape/` (per-cycle runtime), `docs/issues/NNN-slug/` (per-cycle artifacts), `docs/spec/` (canonical specs)

## Documentation

- **[`docs/spec/`](docs/spec/index.md)** — canonical specifications (FSM, CLI, Memory as Code, orchestrator, target-specific agents)
- **[`docs/research/ape_builds_ape/`](docs/research/ape_builds_ape/index.md)** — research papers and methodology (APE building APE — empirical bootstrap)
- **[`docs/adr/`](docs/adr/)** — Architecture Decision Records
- **[`docs/issues/`](docs/issues/)** — per-cycle work artifacts (analysis, plan, metrics)
- **[`docs/lore.md`](docs/lore.md)** — the apes' nomenclature and historical vision
- **[`roadmap.md`](roadmap.md)** — where APE is going next

## Philosophy

APE is designed to be **antifragile** across AI market scenarios. If cloud models get expensive, APE runs on local models. If frontier models plateau, DARWIN is the only improvement mechanism left. If models keep improving, APE amplifies the gains. The methodology benefits from disorder.

The collaboration model — **AAD/AAE/AAM** (Agent-Aided Design/Engineering/Manufacturing) — draws from CAD/CAE/CAM: humans design with AI assistance, co-engineer with AI execution, and delegate mechanical work to automation. The risk matrix calibrates where each action falls on that spectrum.

## License

MIT

## Related work

The idea of a CLI that **installs prompts and skills** into whatever AI coding agent you use — instead of keeping custom agents and skills scattered across each tool's config — comes from [gentle-ai](https://github.com/Gentleman-Programming/gentle-ai) (Gentleman Programming). APE takes that packaging idea in a different direction: a single-target deterministic FSM contract enforced by the CLI, with the methodology itself as the durable artifact.
