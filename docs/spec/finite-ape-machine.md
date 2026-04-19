# Finite APE Machine

**AI-Aided Development Framework**
*"Infinite monkeys produce noise. Finite APEs produce software."*

Version: 1.0-draft
Date: March 28, 2026
Author: Dev (ccisnedev@gmail.com)

---

## 1. Manifesto

### 1.1 What is Finite APE Machine?

Finite APE Machine (APE) is a methodology and agent architecture for AI-Aided Development. It brings the principles of CAD/CAE/CAM to software engineering by structuring the collaboration between a human and AI agents into a disciplined, iterative control loop.

Each AI agent in the system — called an **ape** — is modeled as a **Finite State Machine (FSM)** where the prompt defines the transition function. Given a current state and an input (context, task, human gate), each ape produces a deterministic transition to a new state with a defined output. There is no ambiguity about what an ape is doing, when it has finished, or when it is blocked.

The name is a deliberate counterpoint to the Infinite Monkey Theorem: infinite monkeys typing at random eventually produce Shakespeare. Finite APE Machine inverts this premise — a finite number of specialized agents with defined states and controlled transitions produce quality software not by chance, but by design.

### 1.2 Why APE Exists

The AI-assisted development landscape in 2026 has split into two poles:

- **Vibe coding**: fast, unstructured, suitable for prototypes and throwaway projects. The human prompts, the AI generates, nobody verifies systematically.
- **Spec-Driven Development (SDD)**: structured, formal, suitable for production systems. Specifications are the source of truth from which code, tests, and documentation are derived.

APE occupies a specific position: it adopts SDD principles but operationalizes them through a control-loop architecture where the human retains cognitive sovereignty and the AI assumes operational load. It is neither the chaos of vibe coding nor the rigidity of waterfall. It is engineering.

### 1.3 Core Principle: APE BUILD APE

The system is self-improving. Each completed cycle feeds the evolutionary agent (DARWIN) with lessons learned, which proposes mutations to the system itself. APE builds APE. The methodology evolves through its own application.

---

## 2. Theoretical Model

### 2.1 The Control Loop

APE is modeled as a feedback control loop with nested inner loops, analogous to cascade control in control theory:

```
Reference (Spec/Objective)
    │
    ▼
┌─────────────────────────────────────────────────┐
│  CONTROLLER (Orchestrator + Human Gates)        │
│                                                 │
│   ┌─────────┐   ┌──────┐   ┌─────────┐        │
│   │ ANALYZE │──▶│ PLAN │──▶│ EXECUTE │        │
│   └────┬────┘   └──┬───┘   └────┬────┘        │
│        │           │            │               │
│        ▼           ▼            ▼               │
│   Human Gate  Human Gate   Human Gate           │
│                                                 │
└───────────────────────┬─────────────────────────┘
                        │
                        ▼
                   ┌─────────┐
                   │ SENSOR  │ (Tests + Verification)
                   └────┬────┘
                        │
                        ▼
                   Error Signal (Expected vs. Obtained)
                        │
                        ▼
                   ┌─────────┐
                   │ DARWIN  │ (Adaptive Controller)
                   └─────────┘
```

**Inner loop (fast):** Execute: test-red → implement → test-green. This is the TDD micro-cycle.

**Middle loop (medium):** Plan → Execute → Verify for each task. This is the runbook cycle.

**Outer loop (slow):** Analyze → Plan → Execute → Learn across tasks and projects. This is the methodology evolution cycle.

Each loop has its own time constant and its own sensor. If the inner loop is unstable (bad tests), the outer loop cannot compensate. Tests as well-defined contracts are literally the stability of the system.

### 2.2 AAD → AAE → AAM: The Collaboration Model

Inspired by CAD/CAE/CAM in manufacturing, APE defines three perspectives of the same process:

| Perspective | Acronym | APE Stages | Sovereignty |
|-------------|---------|------------|-------------|
| Agent-Aided Design | AAD | Analyze | Human dominates, AI assists |
| Agent-Aided Engineering | AAE | Plan + Test Definition | Deep human-AI collaboration |
| Agent-Aided Manufacturing | AAM | Execute + Delivery | AI dominates, human supervises |

**AAD** = Define the problem, scope, constraints. The human's domain expertise is irreplaceable.

**AAE** = Architecture, task planning, simulation via tests. Tests are simulations — they verify system behavior before it exists, exactly as a finite element analysis validates a part "../../doc/references"before manufacturing.

**AAM** = Implement, integrate, verify mechanically, deliver. The AI operates the TDD loop; the human reviews the PR and decides on merge.

**DARWIN** operates *between* AAD→AAE→AAM cycles. It is the evolutionary process that improves the machinery itself.

### 2.3 The Human's Non-Delegable Functions

The human retains four functions that cannot be transferred to the AI:

**1. Intention**

- What problem is actually being solved.
- What must not be touched.
- What trade-offs are acceptable.

**2. Criteria**

- What counts as a correct solution.
- What tests validate the change.
- What non-functional constraints apply.

**3. Orchestration**

- Which agent to use.
- In what mode to run it.
- When to transition from analysis to implementation.
- When to open parallel work.

**4. Closure**

- Accept or reject the change.
- Merge, release, rollback.
- Assume accountability.

### 2.4 The AI's Operational Functions

The AI assumes four operational functions:

**1. Explore**

- Read codebase.
- Map impact.
- Locate dependencies.
- Generate hypotheses.

**2. Structure**

- Convert objective into plan.
- Propose sequence.
- Build checklists and verification.

**3. Execute**

- Edit files.
- Run commands.
- Iterate on errors.
- Fix tests.
- Produce diffs or PRs.

**4. Verify Mechanically**

- Build.
- Lint.
- Test.
- Static analysis.
- Automated initial review.

---

## 3. Agent Architecture

### 3.1 What is an Ape?

An **ape** is a specialized AI sub-agent dispatched by the APE scheduler. Each ape has:

- **A prompt** that defines its behavior: given context and a task, produce structured output.
- **A set of skills** (tools it can invoke: memory, file operations, terminal, search, etc.).
- **A defined role** with explicit boundaries and termination conditions.
- **Clean context** on each instantiation — apes are reutilizable but stateless between invocations. They receive their task and the context they need.

Apes are invoked via `runSubagent`. The scheduler (APE) never performs analysis, planning, or implementation — sub-agents do.

### 3.2 The Apes of Finite APE Machine

#### ANALYZE Stage

##### MARCOPOLO — Document Ingestion and Normalization

**Role:** MARCOPOLO (document ingestion and normalization) receives heterogeneous documents (PDF, Word, Excel, PowerPoint, emails, images, repos) and produces structured markdown. Does not make decisions — makes the illegible legible.

**Skills:** markitdown (microsoft/markitdown), codebase reading, DB schema extraction, email parsing, image OCR.

**FSM:**
```
idle → ingesting → normalizing → delivering → idle
```

**Input:** Raw documents, files, URLs, repository references.
**Output:** Structured .md files ready for SOCRATES consumption.

##### SOCRATES — Conversational Requirements Understanding

**Role:** SOCRATES (conversational requirements understanding) is the primary conversational ape of Analyze. Takes MARCOPOLO's output and processes it: asks questions, identifies ambiguities, maps the domain, challenges assumptions. Produces the scope document and constraints. Conducts the Socratic conversation with the human to refine intention.

**Skills:** Memory consultation (project + framework), mermaid generation (domain diagrams, context diagrams), spec writing.

**FSM:**
```
idle → understanding → questioning → clarifying → documenting → idle
```

**Input:** Normalized .md documents from MARCOPOLO, human conversation.
**Output:** Scope document, constraints, domain model, risk assessment.

**Human Gate:** Approves the analysis before proceeding to VITRUVIUS.

##### VITRUVIUS — Decomposition and Structuring

**Role:** VITRUVIUS (decomposition and structuring) takes the scope defined by SOCRATES and decomposes it into a Work Breakdown Structure (WBS) with tasks. Evaluates complexity, identifies dependencies, proposes execution order, generates Gantt chart. Decides when a task is "small enough" to pass to Plan. If a task is too large, subdivides it. If it detects technical risk, flags it.

**Skills:** Mermaid generation (Gantt, WBS), estimation, dependency analysis, framework memory consultation (to estimate better based on past projects).

**FSM:**
```
idle → decomposing → sizing → sequencing → risk_assessing → delivering → idle
```

**Input:** Scope document, constraints, domain model from SOCRATES.
**Output:** WBS, Gantt, task list with sizing and dependencies, risk register.

**Human Gate:** Approves the WBS and task decomposition. Each task that passes to Plan must be a vertical slice (db-api-ui at most one flow).

#### PLAN Stage

##### SUNZI — Technical Design and Runbook Generation

**Role:** SUNZI (technical design and runbook generation) takes a single task from the WBS and generates a phased runbook. Defines the technical strategy: which patterns to use, which components to touch (db/api/ui), implementation order. Verifies that Analyze documentation exists and is sufficient — if not, alerts to return to Analyze.

**Skills:** @contract reading (existing contracts), project memory consultation, codebase analysis.

**FSM:**
```
idle → reading_context → designing → staging → delivering → idle

Exception: reading_context → context_insufficient → escalate_to_analyze
```

**Input:** Single task from WBS, Analyze documentation.
**Output:** runbook.md with phased implementation stages.

**Alert Condition:** If documentation is insufficient, transitions to `escalate_to_analyze` and blocks.

##### GATSBY — Contract Definition and Red Tests

**Role:** GATSBY (contract definition and RED tests) takes each runbook stage and defines concrete tests. Writes @contract blocks. Produces executable tests in RED state. Converts intention into a verifiable contract. Does not implement — only specifies what must be true.

**Skills:** Test writing (dart/ts/python depending on stack), @contract generation, memory consultation for test pattern reuse.

**FSM:**
```
idle → reading_stage → designing_contracts → writing_tests → validating_red → delivering → idle
```

**Input:** Runbook stage from SUNZI.
**Output:** Test files with @contract metadata, all in RED state (failing).

**Human Gate:** Confirms or modifies tests before Execute proceeds.

#### EXECUTE Stage

##### ADA — TDD Implementation

**Role:** ADA (TDD implementation) is the pure TDD implementer. Takes tests in red and turns them green. Follows the runbook stage by stage. If it encounters a tactical deviation, resolves and documents it. If it encounters a strategic deviation, escalates. Does not question the tests — fulfills them.

**Skills:** Stack implementation (dart/ts/python), command execution, lint, types, @contract reading.

**FSM:**
```
idle → reading_tests → implementing → running_tests →
    ├── green → documenting → delivering → idle
    ├── red → fixing → running_tests (loop)
    └── blocked → escalating → idle
```

**Input:** Test files in RED, runbook stage.
**Output:** Implementation code, all tests GREEN, deviation log.

**Deviation Handling:**

- *Tactical deviation* (change library, adjust data structure, use different pattern): Resolve and document. These are alternative means to the same end.
- *Strategic deviation* (objective unachievable as defined, spec contradiction, architectural change needed): Escalate to human. These change the contract with the human.

##### DIJKSTRA — Quality Gate Pre-PR

**Role:** DIJKSTRA (quality gate pre-PR) reviews code produced by ADA before the PR. Verifies coherence between @contracts, tests, and implementation. Checks code smells, validates that documented tactical deviations are reasonable, runs static analysis. Configurable intensity: lightweight for low-risk tasks, exhaustive for high-risk.

**Skills:** Static analysis, @contract reading, security scanning, project memory consultation.

**FSM:**
```
idle → reading_changes → checking_contracts → checking_quality →
    checking_security →
    ├── approved → delivering → idle
    └── issues → reporting → idle
```

**Input:** Code changes, test files, @contracts, deviation log.
**Output:** Review report, approval or issues list.

**Human Gate:** Reviews the PR with DIJKSTRA's report, decides on merge.

#### META Process

##### DARWIN — Evolutionary Agent

**Role:** Operates after each completed APE cycle. Compares plan vs. actual execution, catalogs deviations, extracts patterns, generates issues to the Finite APE Machine repository with improvement proposals. Does not produce code — produces evolution.

**Skills:** Comparative analysis, issue writing, access to all three memory layers (working, project, framework), statistical pattern analysis.

**FSM:**
```
idle → collecting_cycle_data → comparing_plan_vs_actual →
    identifying_patterns → generating_lessons → creating_issues → idle
```

**Input:** Complete cycle data: runbook, deviation logs, test results, timing data.
**Output:** Lessons learned document, issues on the APE framework repository.

**Invocation:** Automatically after cycle closure, or manually by the human.

#### Cross-Cutting Mechanism

##### HERMES — Automatic State Update Hook

**Role:** HERMES (automatic state update hook) is not an ape — it is a lightweight hook that executes automatically each time an ape completes a state transition. Updates a project state file (status.md) with: current task, runbook stage progress, completed apes, pending work. The orchestrator and any ape can read this file.

**Mechanism:** Hook (automatic, does not consume an agent session).

**Output:** Updated status.md file.

### 3.3 Agent Summary

| Stage | Ape | Role | Thinking Mode |
|-------|-----|------|---------------|
| Analyze | MARCOPOLO | Ingest and normalize documents | Mechanical-selective |
| Analyze | SOCRATES | Conversation, scope, constraints | Socratic-exploratory |
| Analyze | VITRUVIUS | WBS, Gantt, sizing, dependencies | Structural-analytical |
| Plan | SUNZI | Phased runbook, technical design | Tactical-sequential |
| Plan | GATSBY | @contract tests in red | Contractual-verifiable |
| Execute | ADA | TDD implementation | Operative-iterative |
| Execute | DIJKSTRA | Quality gate pre-PR, contract verification | Critical-evaluative |
| Meta | DARWIN | Lessons learned, system evolution | Evolutionary-comparative |
| Cross | HERMES | Automatic state update | Automatic (not an ape) |

**Total: 7 apes + 1 hook + DARWIN = 8 specialized agents + 1 automatic mechanism.**

---

## 4. Infrastructure

### 4.1 Memory Architecture

Three-level hierarchical memory, inspired by human cognition and implemented as a cache hierarchy:

#### Working Memory (Session)

The context of the current task. Discarded on completion. Equivalent to RAM.

- Scope: single ape invocation.
- Contains: task definition, relevant @contracts, runbook stage, immediate context.
- Lifecycle: created at ape instantiation, destroyed at completion.

#### Project Memory (Repository)

ADRs, project-specific lessons learned, @contract blocks, deviation history. Persistent in the repository as files. Equivalent to project hard drive.

- Scope: single repository/project.
- Contains: ADRs, @contracts, deviation logs, runbook history, status.md.
- Lifecycle: lives with the project.
- Access: any ape can read; ADA, DIJKSTRA, and DARWIN can write.

#### Framework Memory (APE)

Patterns extracted from multiple projects. The issues generated by DARWIN. Equivalent to accumulated professional experience.

- Scope: across all projects using APE.
- Contains: cross-project patterns, common failure modes, estimation baselines, methodology improvements.
- Lifecycle: permanent, grows with each DARWIN cycle.
- Access: any ape can read (via context provider); DARWIN writes.

#### Context Provider

When a sub-agent needs more context than its working memory provides:

1. First consults **project memory** (cheap, local — .md files in the repo).
2. If insufficient, consults **framework memory** (issues and PRs in the APE repo).
3. The context provider serves relevant information without the ape needing to know where it came from.

Implementation: **Memory as Code** — structured .md files treated analogously to a relational database. Issues and PRs serve as the canonical record of what has been built and why. Reading a PR tells the agent what was actually constructed; reading an issue tells it what was intended.

### 4.2 @contract Blocks — Semantic Test Metadata

Every test carries structured metadata that connects specifications with verification, navigable by agents, language-agnostic:

```
/// @contract
/// spec: SPEC-042 - Cancel order within 24h window
/// risk: financial | severity: high
/// touches: orders.service, payments.refund
/// rationale: Ensures refund policy compliance
```

This format works identically in Dart (`///`), Python (`"""`), and TypeScript (`/** */`). It does not depend on any language's type system or decorator support. Agents read it as structured natural language — exactly where LLMs are strongest.

**Purpose:**

- Each test is a self-descriptive node in the dependency graph.
- The agent does not need an external graph — the test itself carries its relationships.
- Enables impact analysis: when code changes, the agent can identify which @contracts are affected.
- DIJKSTRA uses @contracts to verify semantic coherence between spec, test, and implementation.
- DARWIN uses @contracts to trace failure patterns back to specifications.

### 4.3 Risk Matrix

Evolution of the binary `skipReview` flag into a calibrated risk assessment:

**Assessment:** The orchestrator (or the agent in Analyze) evaluates the change scope and proposes a risk level.

**Confirmation:** The human confirms or adjusts the proposed level.

**Gate calibration:** Risk level determines which gates are active and how intensely each ape operates.

| Risk Level | Active Gates | DIJKSTRA Intensity | Example |
|------------|-------------|-------------------|---------|
| Low | Tests + PR | Lightweight (contracts only) | UI label change |
| Medium | All 4 standard gates | Standard | New API endpoint |
| High | All gates + extended DIJKSTRA | Exhaustive (security, performance) | Payment flow change |
| Critical | All gates + mandatory human review at each ape transition | Full audit | Auth system modification |

Dimensions for risk assessment: financial impact, attack surface, technical complexity, reversibility, blast radius (how many components affected).

### 4.4 Deviation Handling

#### Tactical Deviations

- **Definition:** Alternative means to the same end (change library, adjust data structure, use different pattern).
- **Handling:** The ape resolves and documents in the deviation log.
- **Requirement:** The objective must be clear — if it is not, the agent cannot evaluate whether its action contradicts the plan.

#### Strategic Deviations

- **Definition:** Changes that affect the contract with the human (objective unachievable, spec contradiction, architectural change needed).
- **Handling:** The ape escalates to the human gate. A new plan is generated.
- **Principle:** The original plan is preserved as historical record (for DARWIN). A revised version reflects reality. The diff between original and executed plan is the raw material for Learn.

---

## 5. The Learn Mechanism (DARWIN)

### 5.1 Three Levels of Learning

**Level 1 — Project (Immediate):** Library X doesn't support Y → fix now, document in ADR, update code. This is operational and handled within the APE cycle.

**Level 2 — Methodology (The Loop):** Why didn't we detect library X's limitation in Analyze? → Improve specs to include dependency validation, perhaps add tests that verify library capabilities before use. This transcends the current project and improves the APE process itself.

**Level 3 — Framework (Meta):** After N projects, what failure patterns recur? → Third-party libraries are consistently the source of deviations → This becomes a rule in the APE framework: "every external dependency requires a validation spike in Analyze."

### 5.2 DARWIN's Feedback Mechanism

After each completed APE cycle, DARWIN:

1. Collects cycle data: runbook, deviation logs, test results, timing, DIJKSTRA reports.
2. Compares plan vs. actual execution.
3. Identifies patterns (Level 2 and Level 3).
4. Generates a lessons-learned document for the project (Level 1 and 2).
5. Creates an issue on the Finite APE Machine repository with complete context, proposed improvements, and classification (Level 3).

This creates a **distributed continuous improvement mechanism**. Every project using APE contributes (opt-in) to the framework's evolution. The repository receives issues like:

*"In 47 projects using library X with pattern Y, 68% had tactical deviations in Execute. Proposal: add X+Y compatibility validation in Analyze phase."*

### 5.3 The Evolutionary Principle

DARWIN is the only agent whose output modifies the transition functions of other apes. It does not change states — it changes the *rules*. In control theory terms, it is the adaptive controller. In evolutionary biology terms, it is natural selection. In APE's narrative: it is evolution itself.

---

## 6. Workflow

### 6.1 Complete Flow for a Feature

```
1. SDD Spec: Define objective and scope
2. ANALYZE
   ├── MARCOPOLO: Ingest and normalize all relevant documents
   ├── SOCRATES: Understand domain, ask questions, produce scope document
   │   └── [Human Gate: approve analysis]
   └── VITRUVIUS: Decompose into WBS, Gantt, sized tasks
       └── [Human Gate: approve WBS and task decomposition]

3. For each task in WBS:
   ├── PLAN
   │   ├── SUNZI: Generate phased runbook for this task
   │   └── GATSBY: Define @contract tests in RED for each phase
   │       └── [Human Gate: confirm or modify tests]
   │
   ├── EXECUTE
   │   ├── ADA: Implement TDD, phase by phase
   │   │   ├── Tactical deviations: resolve + document
   │   │   └── Strategic deviations: escalate → new plan
   │   └── DIJKSTRA: Quality gate, contract verification
   │       └── [Human Gate: review PR + merge decision]
   │
   └── HERMES: Updates status automatically at each transition

4. DARWIN: Analyze cycle, extract lessons, generate issues
5. Delivery + Monitoring + Feedback to specs/tests
```

### 6.2 Gate Calibration with Risk Matrix

Before entering the cycle, the orchestrator proposes a risk level based on the task scope. The human confirms or adjusts. Gates activate accordingly:

- **skipReview = true** (Low risk): Gates collapse. SOCRATES produces minimal scope, GATSBY writes focused tests, ADA proceeds without intermediate approvals.
- **Standard** (Medium risk): All 4 human gates active. Standard ape intensity.
- **Full audit** (High/Critical risk): All gates active + DIJKSTRA in exhaustive mode + mandatory human verification at each ape transition.

### 6.3 Parallel Execution Model

A single orchestrator manages one feature/project. Nothing prevents the human from launching N independent orchestrators on N different repositories. They never communicate with each other.

Within a single orchestrator, apes within the same stage can work in parallel when tasks are independent (e.g., ADA working on two independent vertical slices simultaneously).

---

## 7. Technical Environment

### 7.1 Supported Environments

APE is designed to work in two primary environments:

- **IDE (VS Code + GitHub Copilot):** Plan mode maps to Analyze+Plan. Agent mode maps to Execute. Custom agents (Runbook) bridge the gap.
- **Terminal (Claude Code):** Plan mode, subagents, and agent teams provide the orchestration primitives. Swarm mode enables parallel execution.

VS Code as multi-agent hub (since January 2026) allows running Claude, Codex, and Copilot in parallel within the same editor, each in its own session.

### 7.2 Native Mode Mapping

| APE Stage | VS Code / Copilot | Claude Code |
|-----------|-------------------|-------------|
| Analyze | Custom agent (conversational) | Interactive session with plan mode |
| Plan | Plan mode (enhanced) | Plan mode with subagent delegation |
| Execute | Agent mode (Runbook) | Execution with agent teams |
| DARWIN | Custom agent (post-cycle) | Dedicated session post-cycle |

### 7.3 Technology Stack

APE is stack-agnostic but has been designed and tested with:

- **Languages:** Dart, TypeScript, Python.
- **Framework:** Modular API (implementations in all three languages).
- **Document processing:** Microsoft MarkItDown (PDF, Word, Excel, PowerPoint → Markdown).
- **Memory:** Engram or equivalent (SQLite + FTS5, MCP server).
- **Diagrams:** Mermaid (Gantt, WBS, architecture, sequence diagrams).
- **CI/CD:** Standard pipelines with security, lint, types, test runners.

---

## 8. Glossary

| Term | Definition |
|------|-----------|
| **APE** | Analyze, Plan, Execute — the core operational cycle |
| **Ape** | A specialized AI sub-agent modeled as a Finite State Machine |
| **Finite APE Machine** | The complete framework: methodology + agent architecture + evolutionary mechanism |
| **DARWIN** | The evolutionary agent that operates on the meta-level, improving the system itself |
| **HERMES** | Cross-cutting hook that automatically updates project state |
| **@contract** | Semantic metadata block in tests connecting specs with verification |
| **AAD** | Agent-Aided Design (Analyze phase) |
| **AAE** | Agent-Aided Engineering (Plan + Test Definition phases) |
| **AAM** | Agent-Aided Manufacturing (Execute + Delivery phases) |
| **FSM** | Finite State Machine — the model for each ape's behavior |
| **Tactical deviation** | Alternative means to the same end; resolved by the ape |
| **Strategic deviation** | Change to the contract with the human; requires escalation |
| **Working memory** | Session-scoped context, discarded after task completion |
| **Project memory** | Repository-scoped persistent knowledge (ADRs, @contracts, deviations) |
| **Framework memory** | Cross-project accumulated patterns and lessons |
| **Risk matrix** | Calibrated assessment that determines gate activation and ape intensity |
| **WBS** | Work Breakdown Structure — decomposition of scope into tasks |
| **APE BUILD APE** | The self-improvement principle: the system evolves through its own application |

---

## 9. References and State of the Art

### Spec-Driven Development

- [Spec-Driven Development Is Eating Software Engineering (30+ frameworks)](https://medium.com/@visrow/spec-driven-development-is-eating-software-engineering-a-map-of-30-agentic-coding-frameworks-6ac0b5e2b484)
- [GitHub Spec Kit](https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/)
- [Thoughtworks — Spec-Driven Development Unpacking](https://www.thoughtworks.com/en-us/insights/blog/agile-engineering-practices/spec-driven-development-unpacking-2025-new-engineering-practices)

### Test-Driven Development with AI

- [TDAD: Test-Driven Agentic Development (arXiv)](https://arxiv.org/abs/2603.17973)
- [Why TDD Works So Well In AI-Assisted Programming](https://codemanship.wordpress.com/2026/01/09/why-does-test-driven-development-work-so-well-in-ai-assisted-programming/)
- [AI Agents, meet TDD (Latent Space)](https://www.latent.space/p/anita-tdd)

### Multi-Agent Orchestration

- [The Code Agent Orchestra — Addy Osmani](https://addyosmani.com/blog/code-agent-orchestra/)
- [Claude Code Agent Teams](https://code.claude.com/docs/en/agent-teams)
- [VS Code Multi-Agent Development Hub](https://code.visualstudio.com/blogs/2026/02/05/multi-agent-development)

### Human-AI Collaboration

- [Addy Osmani — My LLM Coding Workflow 2026](https://addyo.substack.com/p/my-llm-coding-workflow-going-into)
- [Martin Fowler — Humans and Agents in Software Engineering Loops](https://martinfowler.com/articles/exploring-gen-ai/humans-and-agents.html)
- [The Uncomfortable Truth About Vibe Coding (Red Hat)](https://developers.redhat.com/articles/2026/02/17/uncomfortable-truth-about-vibe-coding)

### Related Frameworks

- [Gentleman-Programming/gentle-ai](https://github.com/Gentleman-Programming/gentle-ai)
- [Gentleman-Programming/engram](https://github.com/Gentleman-Programming/engram)
- [Gentleman-Programming/agent-teams-lite](https://github.com/Gentleman-Programming/agent-teams-lite)

---

*Finite APE Machine v1.0-draft — "Infinite monkeys produce noise. Finite APEs produce software."*
