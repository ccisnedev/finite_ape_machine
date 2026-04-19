# Architecture

> How APE orchestrates AI coding agents through a finite state machine.

## The system in one diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│  Human (developer)                                                  │
│    ↕ authorizes transitions, writes mutations.md, reviews PRs       │
└──────────────────────────────────┬──────────────────────────────────┘
                                   │
┌──────────────────────────────────▼──────────────────────────────────┐
│  ape CLI                                                            │
│                                                                     │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │  FSM Engine (transition_contract.yaml)                        │  │
│  │                                                               │  │
│  │  (state, event) → allowed? → prechecks → effects → new state  │  │
│  │                                                               │  │
│  │  Total matrix: every (state × event) pair is explicit         │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌──────────────┐    ┌──────────────────────────────────────────┐   │
│  │ .ape/        │    │ Target Deployer                          │   │
│  │  state.yaml  │    │                                          │   │
│  │  config.yaml │    │  ape target get → copies to ~/.copilot/  │   │
│  │  mutations.md│    │    agents/ape.agent.md                   │   │
│  └──────────────┘    │    skills/{issue-start,issue-end,...}    │   │
│                      └──────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                          deploys agent + skills
                                   │
┌──────────────────────────────────▼──────────────────────────────────┐
│  AI Coding Tool (Copilot, future: Claude/Crush/Gemini/Codex)        │
│                                                                     │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │  ape.agent.md (orchestrator)                                  │  │
│  │                                                               │  │
│  │  Reads .ape/state.yaml → knows current FSM state              │  │
│  │  Activates the agent for that state:                          │  │
│  │                                                               │  │
│  │    ANALYZE  → SOCRATES  (mayéutica, produces diagnosis.md)    │  │
│  │    PLAN     → DESCARTES (method, produces plan.md)            │  │
│  │    EXECUTE  → BASHŌ     (techne, produces code + commits)     │  │
│  │    END      → (PR gate: gh pr create + gh pr merge)           │  │
│  │    EVOLUTION→ DARWIN    (mutations, produces issues)          │  │
│  │                                                               │  │
│  │  Invokes skills as needed:                                    │  │
│  │    issue-start  → IDLE → ANALYZE protocol                     │  │
│  │    issue-end    → EXECUTE → END → IDLE protocol               │  │
│  │    memory-read  → structured doc retrieval                    │  │
│  │    memory-write → structured doc creation                     │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  The agent has NO knowledge of other states' agents.                │
│  It only sees: current state + transition contract + memory.        │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                          reads/writes
                                   │
┌──────────────────────────────────▼──────────────────────────────────┐
│  Repository (Memory as Code)                                        │
│                                                                     │
│  .ape/state.yaml        ← current FSM state (IDLE, ANALYZE, etc.)   │
│  .ape/config.yaml       ← cycle config (evolution.enabled, etc.)    │
│  .ape/mutations.md      ← human notes for DARWIN                    │
│  docs/issues/NNN-slug/  ← per-cycle artifacts (plan.md, metrics)    │
│  docs/spec/             ← canonical specifications                  │
└─────────────────────────────────────────────────────────────────────┘
```

## FSM: the transition contract

The core of APE is a **declarative, total** finite state machine. "Total" means every `(state, event)` pair has an explicit entry — no implicit behavior.

```yaml
# transition_contract.yaml (excerpt)
- from: IDLE
  event: start_analyze
  to: ANALYZE
  allowed: true
  operations:
    prechecks: []
    effects: [open_analysis_context, reset_mutations]
    artifacts: [analysis/index.md]
    commit_policy: none
    prompt_fragment_id: idle_to_analyze

- from: IDLE
  event: approve_plan
  to: ILLEGAL
  allowed: false
  reason: "IDLE cannot approve plan directly"
```

Each allowed transition carries:

| Field | Purpose |
|---|---|
| `prechecks` | Conditions that must be true before transition fires |
| `effects` | Side effects to execute (reset_mutations, open_analysis_context) |
| `artifacts` | Files that this transition should produce |
| `commit_policy` | When to commit (none, after_effects, after_artifacts) |
| `prompt_fragment_id` | Links to agent prompt section for this transition |

The CLI enforces this via `ape state transition --event <e>`: reads `.ape/state.yaml`, looks up `(current_state, event)` in the contract, validates prechecks, applies effects, writes new state.

## Agent architecture

There is **one agent file** (`ape.agent.md`) that acts as orchestrator. It is NOT 4 separate agents — it is one prompt that **behaves differently depending on FSM state**:

```
ape.agent.md
├── Reads .ape/state.yaml → determines active phase
├── IDLE: waits for user to invoke issue-start skill
├── ANALYZE: becomes SOCRATES (asks questions, writes diagnosis.md)
├── PLAN: becomes DESCARTES (decomposes, writes plan.md with phases)
├── EXECUTE: becomes BASHŌ (implements, tests, commits)
├── END: executes PR creation protocol
└── EVOLUTION: becomes DARWIN (reads mutations.md, proposes issues)
```

The agent **never decides** state transitions on its own. Transitions are authorized by:
1. The human (explicitly)
2. A skill protocol (issue-start, issue-end)
3. The CLI contract (prechecks must pass)

## Skills as protocols

Skills are **step-by-step protocols** invoked by the agent at specific moments:

| Skill | When | Does |
|---|---|---|
| `issue-start` | Human says "start working on issue #N" | Creates branch, reads issue, transitions IDLE → ANALYZE |
| `issue-end` | All plan checkboxes complete | Pushes, creates PR, merges, transitions → END → IDLE |
| `memory-read` | Agent needs project context | Index scan → filter → partial read → full read |
| `memory-write` | Agent produces documentation | YAML frontmatter, one topic per doc, index maintenance |

Skills are **shared across targets** (same SKILL.md for Copilot, Claude, etc.). The agent file is **target-specific** (prompt format differs per tool).

## Deployment model

```
ape target get
    │
    ├── Reads bundled assets/ from alongside the ape binary
    ├── Cleans ~/.copilot/{agents,skills}/  (idempotent reset)
    ├── Copies ape.agent.md → ~/.copilot/agents/
    └── Copies skills/ → ~/.copilot/skills/
         ├── issue-start/SKILL.md
         ├── issue-end/SKILL.md
         ├── memory-read/SKILL.md
         └── memory-write/SKILL.md
```

Only **Copilot** is active in v0.0.x ([ADR D20](spec/target-specific-agents.md)). Adapters for Claude, Codex, Crush, and Gemini exist but are deferred — they only participate in `ape target clean` (removes orphaned files from previous multi-target deploys).

## Cycle lifecycle

A complete APE cycle from issue to merge:

```
1. Human creates GitHub issue with requirements
2. Human invokes issue-start skill
3. CLI: IDLE → ANALYZE (start_analyze event)
4. Agent (SOCRATES): asks clarifying questions, produces diagnosis.md
5. Human authorizes: ANALYZE → PLAN (complete_analysis)
6. Agent (DESCARTES): writes plan.md with phased checkboxes
7. Human authorizes: PLAN → EXECUTE (approve_plan)
8. Agent (BASHŌ): implements phase by phase, commits, marks checkboxes
9. Human invokes issue-end skill when plan complete
10. CLI: EXECUTE → END (finish_execute) → git push + gh pr create
11. PR merged → END → EVOLUTION or END → IDLE (per config)
12. If EVOLUTION: DARWIN reads mutations.md, proposes improvement issues
13. CLI: EVOLUTION → IDLE (finish_evolution), resets mutations.md
```

## Key design decisions

| Decision | Choice | Why |
|---|---|---|
| **One agent, many behaviors** | Single ape.agent.md, state-driven | Simpler deployment, no inter-agent coordination needed |
| **Total FSM** | Every (state,event) explicit | No undefined behavior, contract is auditable |
| **CLI enforces, agent proposes** | Transitions go through CLI | Agent can't corrupt state; human is gate |
| **Skills are protocols** | Step-by-step markdown, not code | Portable across any LLM that reads markdown |
| **Memory in repo** | .ape/ + docs/, no external DB | Version-controlled, survives any infrastructure change |
| **Single target until MVP** | Copilot only (D20) | Prove methodology on one tool before fragmenting |
| **EVOLUTION is opt-in** | config.yaml flag | Self-modification is powerful but must be conscious |