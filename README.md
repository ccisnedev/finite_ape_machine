# Inquiry

**Analyze. Plan. Execute.**

A methodology for AI-assisted software development that models coding agents as a cooperative finite state machine — **Analyze → Plan → Execute → End → [Evolution] → Idle** — where the value is in the process, not the model.

**Status:** `v0.3.1` · Windows + Linux · Single-target MVP (Copilot)

This README is the public entry surface. For the repository's canonical documentation map, start at [`docs/index.md`](docs/index.md).

## What is Inquiry?

Inquiry is a structured methodology that turns AI coding assistants into disciplined engineering partners. Instead of letting an LLM freestream solutions, Inquiry forces a cycle: understand the problem first (Analyze), design the solution second (Plan), then implement mechanically (Execute). Each phase has constraints, artifacts, and a clear exit condition.

The insight: **a smaller model following a rigorous process beats a frontier model freestyling.** Method is the durable asset; models are replaceable.

### Key principles

- **Methodology over model** — the process produces quality, not the model's size or temperature
- **Memory as Code** — project memory lives as version-controlled markdown, readable by both humans and AI. No vector DB, no cloud dependency
- **Agents as FSM states** — each phase activates one specialized agent; transitions are declarative, total, and validated
- **CLI carries methodology** — the CLI resolves paths, injects context, and enforces constraints; the AI focuses on reasoning
- **Antifragile by design** — if models plateau, the methodology is the only improvement lever left; if models improve, the methodology amplifies gains

## The Inquiry cycle

| State | Agent | Method | Artifact |
|---|---|---|---|
| **IDLE** | DEWEY | Deweyan problematization — scope, deduplicate, prepare issue handoff | selected issue + `issue-start` handoff |
| **ANALYZE** | SOCRATES | Socratic questioning — clarify, challenge, evidence | `confirmed.md` → `diagnosis.md` |
| **PLAN** | DESCARTES | Scientific method — divide, order, verify, enumerate | `plan.md` |
| **EXECUTE** | BASHŌ | Wabi-sabi — minimal, beautiful implementation under tests | code + commits |
| **END** | — | PR gate — review, merge | merged PR |
| **EVOLUTION** | DARWIN | Natural selection — propose methodology mutations | issues on this repo |

DEWEY stays bounded to issue triage in IDLE. Branch preparation and the `start_analyze` transition remain in the `issue-start` protocol.

Each agent receives a prompt assembled by the CLI that includes:
- Its philosophical mandate (from YAML definitions)
- Its current sub-state within the phase
- An `inquiry-context` block with resolved paths (where to write, what to read)

The agent never guesses where things go. The CLI tells it.

## Documentation as investigation

During ANALYZE, SOCRATES writes investigation material to `cleanrooms/<branch>/analyze/`:

- **`confirmed.md`** — living document of confirmed findings (mandatory)
- **Topic documents** — one per investigation thread (`root-cause.md`, `prior-art.md`, etc.)
- **`diagnosis.md`** — final synthesis that references all findings

Every document follows a strict YAML frontmatter schema. An index is maintained after every write. DESCARTES reads `diagnosis.md` as its sole input for planning.

This ensures that analysis survives context windows, session resets, and model swaps. The investigation is in the files, not in the chat.

## Philosophy

### AAD / AAE / AAM

The collaboration model draws from manufacturing: **Agent-Aided Design, Engineering, and Manufacturing.** Humans design with AI assistance, co-engineer with AI execution, and delegate mechanical work to automation. A semantic risk matrix calibrates where each action falls on that spectrum.

### DARWIN and antifragility

EVOLUTION is an optional phase where DARWIN — a meta-agent — reviews the completed cycle and proposes mutations to the methodology itself. Bad cycles produce lessons; lessons produce better methodology. The system improves from failure, not despite it.

### Why a finite state machine?

An FSM eliminates ambiguity. At any point, the system is in exactly one state, with a finite set of valid transitions. There is no "figure out what to do next." The agent reads its state, receives its mandate, and executes within constraints. This is not a limitation — it is the source of reliability.

## Quick start

```bash
# Install (Windows)
irm https://inquiry.ccisne.dev/install.ps1 | iex

# Install (Linux)
curl -fsSL https://inquiry.ccisne.dev/install.sh | bash

# Setup
iq doctor               # verify prerequisites
iq target get           # deploy agent + skills to Copilot
cd your-repo
iq init                 # scaffold .inquiry/
iq                      # show current state
```

For the full command reference, see [`docs/index.md`](docs/index.md).

## Architecture

- **CLI:** Dart, single cross-platform binary, built on [`modular_cli_sdk`](https://github.com/ccisnedev/modular_cli_sdk)
- **FSM:** declarative `transition_contract.yaml` — every (state, event) pair is total
- **Context injection:** `iq ape prompt` assembles base prompt + sub-state + dynamic paths as fenced YAML
- **Skills:** `doc-write`, `doc-read`, `issue-start`, `issue-end`, `inquiry-install` — protocols the AI follows
- **Memory:** `.inquiry/` (runtime state), `cleanrooms/` (per-cycle artifacts), `docs/spec/` (specifications)
- **Target:** Copilot only at present. Multi-target deferred until reactivation

## Documentation

| Document | Purpose |
|----------|---------|
| [`docs/index.md`](docs/index.md) | Top-level navigation |
| [`docs/architecture.md`](docs/architecture.md) | APE as orchestrating methodology |
| [`docs/spec/finite-ape-machine.md`](docs/spec/finite-ape-machine.md) | Technical FSM specification |
| [`docs/spec/memory-as-code-spec.md`](docs/spec/memory-as-code-spec.md) | Memory architecture (v0.2.0) |
| [`docs/thinking-tools.md`](docs/thinking-tools.md) | Thinking Tools in the model |
| [`docs/research/inquiry/index.md`](docs/research/inquiry/index.md) | Philosophical home |
| [`docs/roadmap.md`](docs/roadmap.md) | Strategic direction |
| [`docs/lore.md`](docs/lore.md) | Nomenclature and allegory |

## License

MIT

## Related work

The idea of a CLI that **installs prompts and skills** into whatever AI coding agent you use — instead of keeping custom agents and skills scattered across each tool's config — comes from [gentle-ai](https://github.com/Gentleman-Programming/gentle-ai) (Gentleman Programming). Inquiry takes that packaging idea in a different direction: a single-target deterministic FSM contract enforced by the CLI, with the methodology itself as the durable artifact.
