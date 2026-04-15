# Orchestrator — Technical Specification

**Finite APE Machine — Cooperative Event Loop Orchestration**
*"The Ghost in the Shell"*

Version: 0.1.0-spec
Date: March 29, 2026
Author: Dev (cacsidev@gmail.com)

---

## 1. Premise

### 1.1 What the Orchestrator Is

The orchestrator is a **meta-prompt** — not an ape. It is the event loop that iterates over apes, not one of the tasks being iterated. It implements a **cooperative multitasking model** inspired by embedded systems programming, where a single event loop dispatches atomic blocks of work to FSM-based tasks communicating through shared state.

The orchestrator does not think, decide requirements, write code, or review anything. It reads state, evaluates preconditions, invokes the next ape, and updates state. It is the scheduler, not the computation.

### 1.2 The Microcontroller Analogy

The design draws directly from cooperative multitasking on 8-bit microcontrollers:

| Embedded System | APE Orchestrator |
|----------------|-----------------|
| `while(true)` event loop | Chat invocations (ticks) |
| Task with `switch(state)` | Ape with FSM (atomic states) |
| Atomic block (`case:`) | Single ape state (RED, GREEN...) |
| Global variables | `status.md` + `.ape/memory/` + source code |
| Hardware interrupt | Human writes in chat |
| Interrupt flag / priority | Risk matrix (decides whether to ask) |
| One core, N tasks | One prompt, N apes |
| Cooperative scheduler | Orchestrator meta-prompt |
| Emergent behavior | "The Ghost in the Shell" |

In a microcontroller, each task has a clear objective and runs one atomic block per tick. Tasks communicate through shared state (global variables). No task knows what the others are doing — yet the system exhibits intelligent behavior that no individual task possesses. The complexity emerges from coordination, not from individual sophistication.

The APE orchestrator replicates this model exactly. Each ape has its FSM with atomic states. The orchestrator iterates over them, giving each a tick when its preconditions are met. Shared state (files) is the communication medium. The emergent behavior — disciplined software development with documentation, testing, review, and evolutionary learning — arises from the coordination of simple, focused agents.

### 1.3 What the Orchestrator Is NOT

- **Not an ape.** It has no FSM of its own. It does not produce artifacts.
- **Not a daemon.** It does not run continuously. Each chat invocation is a tick.
- **Not universal.** Each target tool (Copilot, Claude Code, Cursor, Gemini CLI) gets its own orchestrator variant, because each has different sub-agent invocation mechanisms.
- **Not a task manager.** It operates on ONE task at a time. Task management (which task to work on next) is a human decision informed by the Gantt/WBS.

### 1.4 Design Principles

**Cooperative, not preemptive.** The orchestrator never interrupts an ape mid-state. Each ape completes its atomic block and yields. The orchestrator then evaluates and dispatches the next step.

**Idempotent preconditions.** If an ape's precondition is not met (e.g., ADA (TDD implementation) is invoked but no RED tests exist), the ape does nothing and returns to IDLE. No error, no crash. The orchestrator moves to the next tick. This is critical for resilience — order independence emerges naturally.

**State over memory.** The orchestrator reconstructs its context entirely from `status.md` on each tick. It has no memory between invocations. This means the human can close the terminal, sleep, switch machines, and resume. The orchestrator picks up exactly where it left off.

**Interrupts over polling.** The human writing in chat is an interrupt, not a scheduled event. The orchestrator decides whether to ask the human (based on risk matrix) or proceed autonomously.

---

## 2. Scope

### 2.1 What the Orchestrator Manages

The orchestrator manages the **ape sequence within a single task**. A task is one item from the WBS/Gantt — it maps to one runbook, one branch, and one PR.

```
Requirement (human defines)
  └── Gantt/WBS (VITRUVIUS produces)
       ├── Task 1 ← orchestrator manages this
       ├── Task 2 ← then this
       └── Task 3 ← then this
```

The human chooses which task to work on. The orchestrator takes it from Analyze through PR.

### 2.2 What the Orchestrator Does NOT Manage

- **Cross-task coordination.** If task 2 depends on task 1, the human decides when to start task 2. The orchestrator does not manage the Gantt.
- **Analyze and Plan conversations.** During AAD (Analyze) and early AAE (Plan), the human converses directly with the default agent using skills. The orchestrator's value is in Execute, where the ape sequence is mechanical and delegable.
- **Multiple simultaneous tasks.** One task is active at a time. The human can abort and switch, but the orchestrator does not juggle.

### 2.3 The Orchestrator's Active Zone

```
AAD (Analyze)          → Human + default agent + skills (no orchestrator)
AAE (Plan)             → Human + SUNZI + GATSBY (orchestrator assists)
AAM (Execute)          → Orchestrator drives: ADA ↔ DIJKSTRA ↔ commit cycle
DARWIN (Learn)         → Orchestrator triggers post-cycle
```

The orchestrator's primary value is in the Execute phase, where it manages the TDD cycle across runbook phases. During Plan, it assists by sequencing SUNZI (technical design and runbook generation) → GATSBY (contract definition and RED tests) → human gate. During Analyze, it is largely passive — the human drives.

---

## 3. State Model

### 3.1 The Tick

A **tick** is one invocation of the orchestrator. It can last seconds (reading state, deciding next step) or minutes (an ape executing a full RED or GREEN block). The tick lifecycle:

```
TICK:
  1. READ    — Parse status.md to reconstruct current state
  2. EVAL    — Evaluate preconditions for all registered apes
  3. DECIDE  — Select the next action (invoke ape, ask human, wait)
  4. EXECUTE — Invoke the selected ape or action
  5. UPDATE  — Write updated state to status.md
  6. YIELD   — Return control (to human, to target auto-continue, or to next tick)
```

The target tool determines tick frequency:

| Trigger | Mechanism |
|---------|-----------|
| Human types in chat | Interrupt — orchestrator reads state and responds |
| Target auto-continue | Some targets (Claude Code, Copilot agent mode) auto-invoke the next tick after the ape yields |
| Explicit resume | Human says "continue" or "next" |
| Timer/schedule | Not in v0.x.x. Future: daemon mode |

### 3.2 Status File (`status.md`)

The orchestrator's entire memory between ticks. HERMES (automatic state update hook) maintains it. Schema:

```markdown
# Project Status

> Maintained by HERMES. Orchestrator reads this on every tick.
> Last updated: 2026-03-29T14:32:00

## Active Task

- task_id: task-005
- title: Implement login endpoint
- issue: #42
- branch: task-005/login-endpoint
- risk: high
- spec: spec-001
- runbook: rb-001

## Cycle Phase

- phase: execute                    # analyze | plan | execute | review | darwin | idle
- sub_phase: tdd                    # (phase-specific detail)

## Runbook Progress

- total_phases: 4
- current_phase: 3
- phase_name: API endpoint
- phases:
  - phase: 1 | status: completed | name: Database schema
  - phase: 2 | status: completed | name: Service layer
  - phase: 3 | status: in_progress | name: API endpoint
  - phase: 4 | status: pending | name: Integration tests

## Current Ape State

- ape: ada
- ape_state: GREEN                  # The atomic state within the ape's FSM
- previous_ape: gatsby
- previous_ape_result: tests_written

## Gate Status

- pending_gate: none                # none | human_review_tests | human_review_pr | human_approve_analysis
- gate_risk_level: high
- gates_passed: [analysis, plan, tests_phase_1, tests_phase_2]

## Deviations (Current Task)

- tactical: 1 (dev-001: JWT lib replacement)
- strategic: 0
- escalated: false

## Commit History (Current Branch)

- commits: 4
- last_commit: "task-005 phase 2: Service layer implementation"
- uncommitted_changes: true
```

### 3.3 State Transitions

The orchestrator's decision logic is a state machine over the cycle phases:

```
IDLE
  └─[human selects task]─→ ANALYZE

ANALYZE
  ├─ MARCOPOLO: ingest docs (if needed)
  ├─ SOCRATES: scope + constraints
  ├─ VITRUVIUS: WBS + sizing
  └─[human approves analysis]─→ PLAN

PLAN
  ├─ SUNZI: generate runbook
  ├─ GATSBY: write tests for phase N (RED)
  └─[human approves tests OR risk=low auto-approve]─→ EXECUTE

EXECUTE (per runbook phase)
  ├─ ADA: RED (implement until tests pass)
  ├─ ADA: GREEN (tests passing)
  ├─ ape git commit (mechanical)
  ├─ DIJKSTRA: verify contracts + quality
  ├─[phase complete]─→ next phase → PLAN.GATSBY (tests for phase N+1)
  └─[all phases complete]─→ REVIEW

REVIEW
  ├─ ape git pr (create PR)
  └─[human merges]─→ DARWIN

DARWIN
  ├─ Collect cycle data
  ├─ Compare plan vs actual
  ├─ Generate lessons
  ├─ Update reports
  └─→ IDLE (or next task)
```

### 3.4 Interleaving Detail

The key insight: between any two atomic states of a single ape, the orchestrator may interleave other operations. ADA experiences RED → GREEN as its complete lifecycle. But the orchestrator intercalates:

```
Orchestrator tick sequence for one runbook phase:

  tick 1:  GATSBY → DESIGNING_CONTRACTS
  tick 2:  GATSBY → WRITING_TESTS
  tick 3:  GATSBY → VALIDATING_RED (tests fail = correct)
  tick 4:  [GATE: human approves tests? — depends on risk matrix]
  tick 5:  ADA  → RED (reading tests, understanding contracts)
  tick 6:  ADA  → RED (implementing)
  tick 7:  ADA  → GREEN (tests pass)
  tick 8:  [BORGES: validate memory, ape memory create deviation if needed]
  tick 9:  [ape git commit --phase N]
  tick 10: DIJKSTRA → CHECKING_CONTRACTS
  tick 11: DIJKSTRA → CHECKING_QUALITY
  tick 12: DIJKSTRA → APPROVED (or ISSUES → loop back)
  tick 13: [Advance to next phase or PR]
```

From ADA's perspective, it only did ticks 5-7. It never knew about ticks 1-4 or 8-12. Yet the system as a whole produced: validated tests, human-approved contracts, documented deviations, structured commits, and quality reviews. The intelligence emerged from the coordination.

### 3.5 Precondition Table

Each ape has preconditions. If they are not met, the ape stays IDLE — no error, no crash.

| Ape | Precondition | If Not Met |
|-----|-------------|------------|
| MARCOPOLO (document ingestion and normalization) | Documents to ingest exist | IDLE (nothing to ingest) |
| SOCRATES (conversational requirements understanding) | MARCOPOLO output exists or docs already normalized | IDLE |
| VITRUVIUS (decomposition and structuring) | Approved scope document exists | IDLE |
| SUNZI | Approved WBS exists, task selected | IDLE |
| GATSBY | Runbook phase defined, no RED tests for this phase yet | IDLE |
| ADA | RED tests exist for current phase | IDLE |
| DIJKSTRA (quality gate pre-PR) | GREEN tests exist, uncommitted or un-reviewed changes | IDLE |
| DARWIN | Completed cycle (PR merged or task closed) | IDLE |

This is the order-independence guarantee from the microcontroller model. The orchestrator can attempt to invoke any ape at any time — the ape itself decides whether to act based on its preconditions.

---

## 4. Human Interaction Model

### 4.1 Interrupts, Not Polling

In the microcontroller model, a hardware interrupt fires when an external event occurs (button press, sensor trigger). The ISR (Interrupt Service Routine) sets a flag, and the main loop processes it on the next tick.

In APE, the human writing in the chat is the interrupt. The orchestrator processes it on the current tick:

```
Human writes: "the tests for phase 3 look wrong, redo them"

Orchestrator processes interrupt:
  1. READ status.md → phase 3, GATSBY delivered, pending human gate
  2. INTERPRET interrupt → human rejects tests
  3. UPDATE status.md → gate: rejected, ape: gatsby, ape_state: idle
  4. NEXT TICK → GATSBY re-invoked for phase 3 with human feedback
```

### 4.2 Risk Matrix as Interrupt Priority

Not all phases require human interrupts. The risk matrix determines which gates are active:

| Risk Level | Gates Active | Orchestrator Behavior |
|------------|-------------|----------------------|
| Low | Tests + PR only | GATSBY → ADA → DIJKSTRA → commit, no intermediate human approval. Human reviews at PR. |
| Medium | Analysis + Plan + Tests + PR | Human approves analysis, approves tests, reviews PR. Execute is autonomous. |
| High | All + extended DIJKSTRA | Human approves at every phase transition. DIJKSTRA runs exhaustive checks. |
| Critical | All + per-ape-review | Human reviews after every ape output. Nothing proceeds without explicit approval. |

The orchestrator reads `gate_risk_level` from `status.md` and consults the gate configuration in `ape.yaml` to decide whether to pause for human input or proceed.

### 4.3 The Target's Native Approval Layer

Beyond the orchestrator's risk-based gates, each target tool has its own approval configuration:

- **Claude Code:** `permissions` in settings.json (ask, auto-approve, deny per tool).
- **GitHub Copilot:** Agent mode approval prompts for file edits, command execution.
- **Cursor:** Permission system for file writes, terminal commands.
- **Gemini CLI:** Tool approval configuration.

The orchestrator does NOT manage these. They are a second layer of human control that operates below the orchestrator. This creates defense in depth: even if the orchestrator decides a gate is not needed (low risk), the target tool may still ask for human approval on file edits.

---

## 5. Target-Specific Implementations

### 5.1 Why Target-Specific

Each target tool has a fundamentally different sub-agent invocation mechanism:

| Target | Invocation Mechanism | Agent Definition | Parallelism |
|--------|---------------------|-----------------|-------------|
| GitHub Copilot | `@agent-name` in chat, auto-delegation via description | `.github/agents/{name}.agent.md` | Fleet mode (native parallel) |
| Claude Code | `Task()` tool, `@agent-name`, natural language | `.claude/agents/{name}.md` or inline | Subagents (sequential), Agent Teams (parallel) |
| Cursor | `/agent-name`, auto-detection from description | `.cursor/agents/{name}.md` | Background subagents (`is_background: true`) |
| Gemini CLI | Native subagent scheduler, extensions | `AGENTS.md` or extension commands | Native parallel batching |
| OpenCode | Agent configuration files | `.opencode/agents/{name}.md` | Sequential |

The orchestrator must speak each target's native language. The behavior is identical — the API is different.

### 5.2 Generation Strategy

`ape init` and `ape repo retarget` generate the target-specific orchestrator from the canonical `.ape/agents/orchestrator.md`:

```
.ape/agents/orchestrator.md          # Canonical: behavior, state machine, rules
        │
        ├──[copilot]──→ .github/agents/orchestrator.agent.md
        ├──[claude]───→ .claude/agents/orchestrator.md
        ├──[cursor]───→ .cursor/agents/orchestrator.md
        ├──[gemini]───→ AGENTS.md (orchestrator section)
        └──[opencode]─→ .opencode/agents/orchestrator.md
```

The canonical file contains:
- The state machine definition (Section 3.3)
- The precondition table (Section 3.5)
- The gate rules (Section 4.2)
- The tick lifecycle (Section 3.1)
- The interleaving protocol (Section 3.4)

The target-specific generator translates this into the target's invocation syntax. For example:

**Copilot variant** — uses `@agent-name` syntax:
```markdown
When ADA reaches GREEN state:
1. Run: `ape git commit --phase {N} --task {task_id}`
2. Invoke: @dijkstra to verify contracts and quality
3. Read DIJKSTRA output. If APPROVED, advance phase.
```

**Claude Code variant** — uses `Task()` tool:
```markdown
When ADA reaches GREEN state:
1. Run: `ape git commit --phase {N} --task {task_id}`
2. Use the Agent tool to launch a dijkstra subagent:
   - prompt: "Review changes for phase {N}. Verify @contracts..."
   - subagent_type: general-purpose
3. Read dijkstra result. If approved, advance phase.
```

**Cursor variant** — uses `/agent-name` slash commands:
```markdown
When ADA reaches GREEN state:
1. Run: `ape git commit --phase {N} --task {task_id}`
2. Invoke: /dijkstra to verify contracts and quality
3. Read dijkstra output. If approved, advance phase.
```

### 5.3 Canonical Orchestrator Prompt Structure

```markdown
# ORCHESTRATOR — Cooperative Event Loop

## Identity
You are the orchestrator of the Finite APE Machine framework.
You are NOT an ape — you are the event loop that coordinates apes.
You do not produce artifacts. You read state, decide, invoke, update.

## Tick Lifecycle
On every invocation (tick):
1. Read .ape/status.md to reconstruct current state
2. Evaluate preconditions for the next expected ape
3. Decide: invoke ape, ask human, or wait
4. Execute the decision
5. Update .ape/status.md via HERMES
6. Yield control

## State Machine
[Full state transition diagram from Section 3.3]

## Preconditions
[Table from Section 3.5]

## Gate Rules
Read `risk` from status.md and `gates` from ape.yaml.
If current transition requires a gate at this risk level:
  → Ask the human for approval before proceeding
If no gate required:
  → Proceed autonomously

## Ape Invocation
[TARGET-SPECIFIC SECTION — generated by ape init]

To invoke MARCOPOLO:    [target-specific syntax]
To invoke SOCRATES:  [target-specific syntax]
To invoke VITRUVIUS: [target-specific syntax]
...

## Interrupt Handling
When the human writes in chat:
1. Parse intent (feedback, correction, new instruction, abort)
2. Update status.md with human input
3. Adjust current ape or phase accordingly
4. Continue tick lifecycle

## CLI API
Use `ape` commands for all structured operations:
- `ape memory create ...` for documentation
- `ape task update ...` for task status changes
- `ape git commit ...` for structured commits
- `ape git pr ...` for pull request creation
- `ape memory validate` before completing a phase

## Recovery Protocol
If status.md is missing or corrupted:
1. Read .ape/memory/ indices to reconstruct task state
2. Read git log to determine last commit / branch state
3. Read runbook to determine expected phase
4. Reconstruct status.md and ask human to confirm
```

---

## 6. Ape Atomic States

### 6.1 Granularity of Atomic Blocks

Each ape's FSM defines states that are **atomic from the orchestrator's perspective**. The ape may do significant work within a state, but the orchestrator only sees state transitions.

#### MARCOPOLO
```
IDLE → INGESTING → NORMALIZING → DELIVERING → IDLE
```
Atomic blocks: each state is one tick. INGESTING reads and parses. NORMALIZING converts. DELIVERING produces output.

#### SOCRATES
```
IDLE → UNDERSTANDING → QUESTIONING → CLARIFYING → DOCUMENTING → IDLE
```
Atomic blocks: UNDERSTANDING and QUESTIONING may involve multiple chat exchanges with the human (the orchestrator is passive during Analyze — human drives).

#### VITRUVIUS
```
IDLE → DECOMPOSING → SIZING → SEQUENCING → RISK_ASSESSING → DELIVERING → IDLE
```

#### SUNZI
```
IDLE → READING_CONTEXT → DESIGNING → STAGING → DELIVERING → IDLE
Exception: READING_CONTEXT → CONTEXT_INSUFFICIENT → ESCALATE
```

#### GATSBY
```
IDLE → READING_STAGE → DESIGNING_CONTRACTS → WRITING_TESTS → VALIDATING_RED → DELIVERING → IDLE
```

#### ADA
```
IDLE → RED → GREEN → IDLE
```
This is the most critical simplification. From the orchestrator's view, ADA has exactly two atomic states: RED (implement until tests pass) and GREEN (tests pass, done). Internally, ADA may loop (implement → run tests → fail → fix → run tests → pass), but the orchestrator only sees the RED→GREEN transition.

#### DIJKSTRA
```
IDLE → CHECKING_CONTRACTS → CHECKING_QUALITY → CHECKING_SECURITY →
  ├── APPROVED → IDLE
  └── ISSUES → IDLE (report issues, orchestrator decides next step)
```

#### DARWIN
```
IDLE → COLLECTING → COMPARING → IDENTIFYING_PATTERNS → GENERATING_LESSONS → CREATING_ISSUES → IDLE
```

### 6.2 The Interleaving Principle

Between ADA:RED completing and ADA:GREEN beginning, the orchestrator may insert:
- Nothing (low risk, auto-continue)
- Human gate (high risk, wait for approval)
- DIJKSTRA spot-check (critical risk)
- Memory validation (`ape memory validate`)
- Any corrective action the orchestrator deems necessary

This is the emergent behavior. ADA never knows what happened between its states. The system as a whole exhibits discipline that no individual ape possesses.

---

## 7. Concurrency Model

### 7.1 Single Active Ape (v0.x.x)

In v0.x.x, the orchestrator invokes one ape at a time. This is the cooperative model: one core, sequential execution, shared state without conflicts.

The sequence is deterministic for each runbook phase:
```
GATSBY → [gate?] → ADA:RED → ADA:GREEN → [commit] → DIJKSTRA → [next phase]
```

### 7.2 Parallel Potential (v1.x.x)

Future versions may exploit target-native parallelism:

- **Claude Code Agent Teams:** Launch ADA on phase N while GATSBY writes tests for phase N+1 (pipelining).
- **GitHub Copilot Fleet:** Run DIJKSTRA on phase N-1 while ADA works phase N.
- **Gemini CLI native scheduler:** Batch independent ape invocations.

The precondition table (Section 3.5) already supports this: if GATSBY for phase N+1 has its preconditions met (runbook exists), it can run while ADA works phase N. The orchestrator simply evaluates all apes on each tick and dispatches all whose preconditions are met.

This is the exact model from the microcontroller: the event loop iterates over all tasks, and each task that can advance does advance. The emergent behavior becomes richer with parallelism — correlations between concurrent phases may surface patterns that sequential execution would miss.

### 7.3 Pipelining Example

```
Phase 1:  [GATSBY:1] → [ADA:1 RED] → [ADA:1 GREEN] → [COMMIT:1] → [DIJKSTRA:1]
Phase 2:              [GATSBY:2] → .............. [ADA:2 RED] → [ADA:2 GREEN] → ...
Phase 3:                           [GATSBY:3] → ......................

         ────────────────────── time ──────────────────────→
```

GATSBY for phase N+1 can begin as soon as the runbook for phase N+1 is defined (which it already is — the full runbook was produced by SUNZI). The only hard dependency is that ADA:N cannot start until GATSBY:N delivers RED tests.

---

## 8. Target Implementation Details

### 8.1 GitHub Copilot

**Agent file:** `.github/agents/orchestrator.agent.md`

**Invocation mechanism:**
- Orchestrator is the default agent invoked when the user opens agent mode.
- Sub-apes are invoked via `@agent-name` references in the orchestrator's output.
- Copilot's fleet mode enables parallel sub-agent dispatch when the orchestrator identifies independent work.

**State persistence:**
- `status.md` read/written via standard file operations.
- Human gates implemented as explicit questions in chat output.

**Key adaptation:**
- Copilot auto-delegates based on YAML `description` field in agent files. The orchestrator's description must clearly state it is the coordinator, not a specialist.
- Each ape's `.agent.md` file includes its description for routing.

### 8.2 Claude Code

**Agent file:** `.claude/agents/orchestrator.md`

**Invocation mechanism:**
- Orchestrator launched via `claude --agent orchestrator` or `@orchestrator` in session.
- Sub-apes invoked via the `Agent` tool (`Task()` API) with structured prompts.
- Each ape runs as a subagent with its own context window (fresh context, no pollution).
- Results returned to orchestrator context for evaluation.

**State persistence:**
- `status.md` read via `Read` tool, written via `Edit` tool or `ape` CLI.
- Claude Code's auto-continue (`--yes` flag) enables unattended tick sequences.

**Key adaptation:**
- Claude Code subagents cannot invoke other subagents (no nesting). The orchestrator is always the top-level coordinator.
- Agent Teams mode (v1.x.x) would enable true parallelism with independent sessions.

### 8.3 Cursor

**Agent file:** `.cursor/agents/orchestrator.md`

**Invocation mechanism:**
- Orchestrator invoked via `/orchestrator` slash command or auto-detection.
- Sub-apes invoked via `/agent-name` syntax in the orchestrator's output.
- `is_background: true` flag enables async sub-agent execution.

**State persistence:**
- `status.md` read/written via standard file operations.
- Cursor's rules system (`.cursor/rules/`) provides project-level context to all agents.

**Key adaptation:**
- Cursor's auto-delegation based on `description` field means the orchestrator must have a description that captures all APE workflow scenarios.
- Rules files complement agent prompts with persistent project context.

### 8.4 Gemini CLI

**Agent file:** Orchestrator section in `AGENTS.md` or as extension.

**Invocation mechanism:**
- Gemini CLI's native subagent scheduler dispatches apes.
- Extensions (`/orchestrator:tick`) provide explicit invocation.
- The Conductor pattern (spec.md + plan.md in git) aligns naturally with Memory as Code.

**State persistence:**
- `status.md` and all `.ape/memory/` files are native Markdown — Gemini reads them directly.
- Gemini's native parallel batching enables pipelining when the orchestrator dispatches contiguous agent calls.

**Key adaptation:**
- Gemini CLI's contiguous call batching means the orchestrator should group parallel-safe ape invocations together, separated from non-parallel operations.

### 8.5 OpenCode

**Agent file:** `.opencode/agents/orchestrator.md`

**Invocation mechanism:**
- Standard agent invocation via OpenCode's agent system.
- Sub-apes defined in `.opencode/agents/` and referenced by name.

**State persistence:**
- Same file-based model as other targets.

---

## 9. Recovery and Resilience

### 9.1 State Reconstruction

If `status.md` is lost or corrupted, the orchestrator can reconstruct state from multiple sources:

| Source | What It Reveals |
|--------|----------------|
| `git branch --show-current` | Active task (branch name = `task-NNN/slug`) |
| `git log --oneline` | Completed phases (commit messages = `task-NNN phase M: ...`) |
| `.ape/memory/runbooks/` | Expected phases and their order |
| `.ape/memory/deviations/` | Deviations encountered so far |
| Test runner output | Current test state (RED/GREEN/none) |
| `.ape/memory/*/index.md` | All memory produced so far |

The orchestrator's recovery protocol:
1. Detect missing/corrupted `status.md`.
2. Read all available sources.
3. Reconstruct most likely state.
4. Present reconstruction to human for confirmation.
5. Resume from confirmed state.

### 9.2 Idempotency

Every orchestrator action is idempotent:
- Invoking an ape whose work is already done → ape detects via preconditions, stays IDLE.
- Running `ape git commit` when nothing is staged → no-op.
- Running `ape memory validate` when everything is valid → success, no side effects.
- Updating `status.md` with the same state → no change.

This means the orchestrator can safely retry any tick without side effects.

### 9.3 Abort and Resume

The human can abort the current task at any time:
```
Human: "stop, I need to switch to task-007 instead"

Orchestrator:
1. Update status.md → task-005 suspended at phase 3
2. Commit work in progress (if any green tests)
3. Switch context to task-007
4. Read status.md for task-007 (or initialize if new)
5. Begin tick lifecycle for task-007
```

The previous task's branch and memory remain intact. The human can resume it later.

---

## 10. Workflow Example

### 10.1 Complete Task Lifecycle Through the Orchestrator

```
HUMAN: "Let's work on task-005: implement login endpoint"

TICK 1 — Orchestrator reads status.md: task-005, phase: idle
  → Task exists, runbook rb-001 exists, 4 phases defined
  → Phase 1 has no tests yet
  → DECIDE: invoke GATSBY for phase 1
  → INVOKE: GATSBY with runbook phase 1 context
  → GATSBY produces: 3 test files with @contracts, all RED
  → UPDATE status.md: phase=execute, sub_phase=tdd,
    current_phase=1, ape=gatsby, ape_state=DELIVERING

TICK 2 — Risk is HIGH → gate required for test approval
  → ASK HUMAN: "GATSBY produced 3 tests for phase 1
    (DB schema). Review @contracts and approve?"
  → HUMAN: "approved, but add a test for unique email constraint"
  → UPDATE status.md: gate=passed, human_feedback=recorded

TICK 3 — GATSBY incorporates feedback
  → INVOKE: GATSBY to add the additional test
  → GATSBY adds test, validates RED
  → UPDATE status.md: ape=gatsby, ape_state=VALIDATING_RED

TICK 4 — Tests ready, invoke ADA
  → INVOKE: ADA with RED tests for phase 1
  → ADA implements DB schema, migrations, model
  → All tests pass → GREEN
  → UPDATE status.md: ape=ada, ape_state=GREEN

TICK 5 — Green phase: commit + review
  → RUN: ape memory validate (BORGES check)
  → RUN: ape git commit --phase 1 --task task-005
  → INVOKE: DIJKSTRA for phase 1
  → DIJKSTRA: contracts verified, quality OK, APPROVED
  → UPDATE status.md: current_phase=1 completed

TICK 6 — Advance to phase 2
  → Phase 2 defined in runbook: Service layer
  → INVOKE: GATSBY for phase 2
  → [cycle repeats...]

... [phases 2, 3, 4 proceed similarly] ...

TICK N — All phases complete
  → RUN: ape git pr --task task-005
  → ASK HUMAN: "PR #23 created. Review and merge?"
  → HUMAN merges

TICK N+1 — Post-merge
  → RUN: ape task close task-005
  → INVOKE: DARWIN for end-of-cycle analysis
  → DARWIN produces lessons, updates reports
  → UPDATE status.md: phase=idle, task=none

ORCHESTRATOR: "Task-005 complete. 4 phases, 1 tactical deviation,
  12 tests, 1 lesson generated. Ready for next task."
```

---

## 11. Relationship with Other Specifications

| Document | Relationship to Orchestrator |
|----------|----------------------------|
| **Finite APE Machine** (methodology) | Defines the ape FSMs, the control loop theory, and the AAD/AAE/AAM model that the orchestrator implements |
| **APE CLI Specification** | Defines the `ape` commands that the orchestrator invokes (`ape memory`, `ape task`, `ape git`). The CLI is the orchestrator's programmatic API |
| **Memory as Code Specification** | Defines the shared state structure (`.ape/memory/`, indices, BORGES (schema enforcement, documentation compiler) protocol) that the orchestrator reads to evaluate preconditions and the apes write to communicate results |

The orchestrator is the runtime that connects these three specifications into a working system.

---

## 12. Future Considerations

### 12.1 Daemon Mode (v1.x.x)

A long-running process that auto-ticks without human invocation. Would enable:
- Background execution of low-risk tasks.
- Webhook-driven ticks (PR comment → DIJKSTRA invoked automatically).
- Scheduled DARWIN runs.

### 12.2 Multi-Task Pipelining (v1.x.x)

With parallel target support, the orchestrator could pipeline phases across tasks (not just within a task). This would require extending `status.md` to track multiple active tasks and their states — essentially becoming the full microcontroller event loop with N tasks registered.

### 12.3 Emergent Behavior Exploration

The cooperative event loop model predicts that emergent behavior will appear when:
- Multiple apes operate on shared state over time.
- DARWIN correlates patterns across phases within a task and across tasks.
- Risk patterns evolve based on accumulated deviation data.
- The methodology itself adapts (APE BUILD APE).

This emergence cannot be designed — it must be observed through use. The framework creates the conditions for it; the actual behavior will be discovered empirically.

---

## 13. Glossary

| Term | Definition |
|------|-----------|
| **Tick** | One invocation of the orchestrator: read state → evaluate → decide → execute → update → yield |
| **Atomic block** | A single state within an ape's FSM; the orchestrator does not interrupt mid-block |
| **Precondition** | A condition that must be true for an ape to advance; if not met, the ape stays IDLE |
| **Interleaving** | The orchestrator inserting operations between an ape's atomic states |
| **Interrupt** | Human input in the chat, processed by the orchestrator on the next tick |
| **Gate** | A human approval point, activated or deactivated by the risk matrix |
| **Cooperative scheduling** | Each ape yields control after completing its atomic block; the orchestrator decides next |
| **Shared state** | `status.md`, `.ape/memory/`, source code — the communication medium between apes |
| **Emergent behavior** | System-level intelligence arising from the coordination of simple, focused apes |
| **Meta-prompt** | A prompt that coordinates other prompts; the orchestrator is not an ape, it is the loop |
| **Event loop** | The orchestrator's core pattern: iterate, evaluate, dispatch, repeat |
| **Pipelining** | Future: overlapping phases so GATSBY:N+1 runs while ADA:N executes |

---

*Orchestrator Specification v0.1.0-spec — Finite APE Machine*
*"The Ghost in the Shell"*
