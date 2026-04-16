# Finite APE Machine

> Infinite monkeys produce noise. Finite APEs produce software.

A formal framework for AI-assisted software development that models coding agents as cooperative finite state machines. APE imposes structure on the chaos of "vibe coding" through a methodology cycle — **Analyze, Plan, Execute + Learn** — where the value is in the process, not the model.

## What is APE?

APE treats AI coding agents ("apes") as deterministic automata with prompts as transition functions. A cooperative event loop orchestrator — inspired by microcontroller scheduling — coordinates specialized agents (MARCOPOLO, SOCRATES, VITRUVIUS, SUNZI, GATSBY, ADA, DIJKSTRA, BORGES, DARWIN) without any agent being aware of the others. Intelligence emerges from orchestration, not individual capability.

**Core ideas:**

- **Agents as FSMs** — each ape is a finite state machine: δ(state, context) → new_state + output
- **Methodology over model** — a 7B local model following APE's structured runbook beats a frontier model freestyling
- **Memory as Code** — project memory as version-controlled markdown with database-inspired indexing. No vector DB, no cloud dependency
- **DARWIN** — an evolutionary meta-agent that modifies other agents' behavior across three learning levels (project → personal → community)
- **Semantic risk matrix** — human approval only when engineering judgment matters. When APE asks, the question matters
- **@contracts** — language-agnostic traceability from specs to tests

## Status

**Phase: Analyze** — specifications and formal design complete. Implementation has not started.

### What exists

```
doc/
├── finite-ape-machine.md    # Core methodology specification
├── ape-cli-spec.md          # CLI tool specification (Dart)
├── memory-as-code-spec.md   # Memory system specification
├── orchestrator-spec.md     # Cooperative event loop orchestrator
├── lore.md                  # The Apes — names, allegories, and roles
├── adrs.md                  # Architecture Decision Records (6)
└── ape-paper.md             # arXiv-style paper with 36 formal references
```

### What's next

- [x] `ape init` — project scaffolding
- [x] `ape version` — print CLI version
- [x] `ape target get` — deploy APE agents and skills to all AI coding tools
- [x] `ape target clean` — remove deployed APE files from all targets
- [x] `ape upgrade` — download and install the latest APE release
- [ ] `ape memory` — Memory as Code CLI commands
- [ ] `ape task` — GitHub Issues-backed task management
- [ ] Orchestrator prompts for Copilot (first target)
- [ ] BORGES validation engine
- [ ] DARWIN learning loop

## Install (Windows)

```powershell
irm https://ccisnedev.github.io/finite_ape_machine/install.ps1 | iex
```

This downloads the latest release, extracts it to `%LOCALAPPDATA%\ape\`, adds it to PATH, and deploys APE agents/skills to all supported AI coding tools.

To update to the latest version:

```powershell
ape upgrade
```

## The APE Cycle

Every task follows four phases:

**Analyze** → Understand requirements, classify risk, read project memory
**Plan** → Generate a phased runbook with entry criteria and verification conditions
**Execute** → Specialized apes collaborate via TDD (RED → GREEN), interleaved with review, documentation, and human gates
**Learn** → DARWIN extracts lessons, updates memory, improves future runs

## Philosophy

APE is designed to be **antifragile** across AI market scenarios. Cloud models get expensive? APE works with local models. LLMs plateau? DARWIN is the only improvement mechanism left. Models get better? APE amplifies the gains. The framework benefits from disorder.

The collaboration model — **AAD/AAE/AAM** (Agent-Aided Design/Engineering/Manufacturing) — draws from CAD/CAE/CAM: humans design with AI assistance, co-engineer with AI execution, and delegate mechanical tasks to full automation. The risk matrix calibrates where on this spectrum each action falls.

## Tech Stack

- **CLI:** Dart (compiled, cross-platform, single binary)
- **Memory:** Markdown + YAML frontmatter in `.ape/`
- **Tasks:** GitHub Issues via `gh` CLI
- **Orchestrator targets:** Copilot → Claude Code → OpenCode

## License

MIT

## Acknowledgments

Intellectually inspired by [gentle-ai](https://github.com/user/gentle-ai) (Gentleman Programming). No code is shared.
