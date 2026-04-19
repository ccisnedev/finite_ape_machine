# Finite APE Machine: Cooperative FSM Orchestration for AI-Assisted Software Engineering

**Author:** C. Cisneros (ccisnedev)

**Abstract.** We present the Finite APE Machine (APE), a methodology and framework for AI-assisted software development that models AI coding agents as cooperative finite state machines orchestrated by an event loop inspired by embedded systems architectures. APE introduces a structured cycle — Analyze, Plan, Execute + Learn — where specialized agents ("apes") operate as deterministic-in-specification automata with prompts as transition functions. The framework applies known techniques in a novel context, contributing six primary constructs: (1) prompts formalized as FSM transition functions δ; (2) a cooperative event loop orchestrator adapted from microcontroller scheduling; (3) Memory as Code, a persistent project memory system with database-inspired indexing over version-controlled markdown; (4) DARWIN, an evolutionary meta-agent that modifies other agents' transition functions across three learning levels — empirically validated with 9 generated evolution issues; (5) a semantic risk matrix addressing automation complacency through context-aware human gates; and (6) antifragile design across four AI market scenarios. Both the framework and this paper are under active construction — APE is being built using itself (v0.0.14, 131 tests, 69 issues/PRs), providing bootstrap validation through self-construction. We position APE within the existing literature on multi-agent systems, finite automata theory, control theory, and human-AI collaboration.

**Keywords:** AI agents, finite state machines, multi-agent orchestration, software engineering methodology, test-driven development, evolutionary learning, human-AI collaboration

---

## 1. Introduction

The emergence of Large Language Model (LLM)-based coding assistants has produced a paradox: tools of unprecedented capability deployed with minimal methodology. GitHub Copilot increases developer productivity by 26–56% in controlled studies [1, 2], yet the dominant interaction paradigm — "vibe coding," where developers describe intent in natural language and accept generated output with minimal verification — produces fragile, untraceable software. The infinite monkey theorem, formulated by Borel [3], offers a precise metaphor: given unlimited attempts, random generation can produce any text, but the probability of producing *correct* text without structure is vanishingly small.

Current multi-agent frameworks such as MetaGPT [4], AutoGen [5], and CAMEL [6] have demonstrated that role-specialized LLM agents can collaborate on software tasks. However, these systems generally treat orchestration as an implementation detail rather than a formal construct, lack persistent cross-project learning mechanisms, and provide ad hoc human oversight models that either interrupt too frequently (causing approval fatigue) or too rarely (enabling automation complacency [7, 8]).

We present the Finite APE Machine (APE) — a framework built on the premise that *infinite monkeys produce noise; finite APEs produce software*. APE imposes formal structure on AI-assisted development through three interlocking principles:

1. **Agents as automata.** Each agent is a finite state machine (FSM) [9] with a prompt as its transition function δ(state, context) → new_state + output. The orchestrator observes only atomic state transitions, never internal reasoning.

2. **Methodology over model.** The value resides in the process structure — the APE cycle, contracts, memory system, and evolutionary learning — not in any specific model's capability. A 7B parameter local model following APE's structured runbook can produce verifiable software that a frontier model "vibe coding" cannot guarantee.

3. **Antifragile design.** Following Taleb [10], the framework is designed to benefit from disorder in the AI market: model capability regression, cost increases, provider failures, or capability plateaus all activate different strengths of the methodology.

The remainder of this paper is organized as follows. Section 2 surveys related work across six foundational domains. Section 3 presents the APE methodology and its formal model. Section 4 details the cooperative event loop orchestrator. Section 5 describes Memory as Code. Section 6 introduces DARWIN and the three-level learning hierarchy. Section 7 formalizes the human interaction model. Section 8 discusses antifragility properties. Section 9 catalogs original contributions. Section 10 concludes with future work.

---

## 2. Related Work

APE draws on six distinct bodies of knowledge, integrating concepts that have not previously been combined in the context of AI agent orchestration.

### 2.1 Finite Automata and Computational Theory

The modeling of computational processes as finite state machines dates to the foundational work of Hopcroft, Motwani, and Ullman [9]. While FSMs have been applied extensively in hardware design, protocol verification, and game AI, their application to LLM-based agents is recent. Cheng et al. [11] demonstrate FSM extraction from specifications using prompt chaining, and Tanaka et al. [12] show automatic multi-agent system construction based on FSMs. Liu et al. [13] extend the FSM model with variables and guard conditions for mobile GUI agents. APE contributes to this line by treating the *prompt itself* as the transition function — a formalization not present in prior work, where FSMs describe agent behavior but prompts remain informal artifacts.

### 2.2 Control Theory and Cascade Control

Åström and Murray [14] provide the mathematical foundation for feedback systems. The application of control theory to AI agent systems is emerging: Patria et al. [15] formalize agentic decision authority as hierarchical runtime control, and Ngo et al. [16] propose stack-based alignment control hierarchies. APE's orchestrator implements a form of cascade control where the outer loop (orchestrator) manages agent sequencing and the inner loop (each ape) manages task execution, with the risk matrix functioning as the gain adjustment mechanism that determines control authority transfer between human and machine.

### 2.3 Cooperative Multitasking and Real-Time Systems

Liu and Layland's [17] seminal work on scheduling algorithms for hard real-time environments established the theoretical basis for task prioritization. APE's orchestrator draws a direct analogy to cooperative multitasking on 8-bit microcontrollers: a single execution core, N tasks modeled as FSMs sharing state through a common memory space, with each task voluntarily yielding control at defined points. This architecture — well-understood in embedded systems for decades — has not been previously applied to LLM agent orchestration.

### 2.4 Multi-Agent Systems

The field of multi-agent systems (MAS) provides foundational concepts through Wooldridge [18] and Ferber [19]. The BDI (Belief-Desire-Intention) architecture of Rao and Georgeff [20] formalized rational agent reasoning, while Smith's contract net protocol [21] established task allocation patterns. In the LLM era, Wang et al. [22] survey autonomous agent architectures, identifying profile, memory, planning, and action as core modules. Yao et al. [23] introduced ReAct, synergizing reasoning traces with environment actions. APE departs from the BDI tradition by deliberately *reducing* agent autonomy: apes do not reason about goals or negotiate — they execute within constrained state machines, and intelligence emerges from orchestration rather than individual capability.

Table 1 summarizes the architectural differences between APE and the three most prominent LLM-based multi-agent frameworks:

| Dimension | MetaGPT [4] | AutoGen [5] | CAMEL [6] | **APE** |
|-----------|-------------|-------------|-----------|---------|
| **Agent model** | Role-based SOPs | Conversable agents | Role-playing via inception prompting | FSM with prompt as δ |
| **Orchestration** | Assembly line (implicit sequencing) | Multi-agent conversation (ad hoc) | Two-agent role-play loops | Cooperative event loop (explicit tick cycle) |
| **Agent autonomy** | High — agents decide within SOP constraints | High — agents negotiate via conversation | High — agents converse autonomously | Low — apes execute atomic FSM transitions, no negotiation |
| **Persistent memory** | None (session-scoped) | None (session-scoped) | None (session-scoped) | Memory as Code (git-versioned markdown with database indexing) |
| **Cross-project learning** | None | None | None | DARWIN three-level hierarchy (project → methodology → framework) |
| **Human oversight model** | Manual review of intermediate artifacts | Human-in-the-loop as optional agent | Minimal — autonomous completion | Semantic risk matrix (impact × domain calibrated gates) |
| **Spec-to-test traceability** | None | None | None | @contracts (bidirectional spec ↔ test linking) |
| **Formal model** | Informal SOPs encoded as prompt sequences | Conversation protocol | Inception prompting protocol | FSM 5-tuple A = (S, C, δ, s₀, F) |
| **Target domain** | General software tasks | General LLM applications | General task-solving | Software engineering methodology (TDD cycle) |

The key differentiator is architectural philosophy. MetaGPT, AutoGen, and CAMEL grant agents high autonomy and rely on inter-agent communication (conversation, SOPs, role-play) to coordinate behavior. APE inverts this: agents have *minimal* autonomy, no inter-agent communication, and coordination is entirely externalized to the orchestrator through shared state — producing emergent behavior from constrained components rather than negotiated consensus.

### 2.5 Test-Driven Development and Specification

Beck [24] established TDD as a discipline where tests precede implementation. Nagappan et al. [25] demonstrated 40–90% defect reduction in industrial teams using TDD. Meyer's Design by Contract [26] formalized preconditions and postconditions as executable specifications. APE synthesizes these traditions through @contracts — language-agnostic semantic metadata embedded in test comments that create bidirectional traceability between specifications and verification code, and through the RED→GREEN cycle where the ADA (TDD implementation) agent operates strictly within TDD constraints.

### 2.6 Human-AI Collaboration and Automation Complacency

Schemmer et al. [7] review automation bias in human-AI collaboration, finding that humans systematically over-rely on AI recommendations. Hamundu et al. [8] document automation complacency risks where decision-making is effectively abdicated. Cihon et al. [27] propose four actionable properties for meaningful human control. Amershi et al. [28] establish guidelines for human-AI interaction. APE's risk matrix addresses these concerns by implementing *semantic approval* — the system asks questions only when engineering judgment is required, making each approval decision meaningful rather than mechanical. This directly counters the "approve everything" fatigue documented in current AI IDE workflows.

---

## 3. The APE Methodology

### 3.1 Formal Model

An APE agent (ape) is a 5-tuple:

$$A = (S, C, \delta, s_0, F)$$

where S is a finite set of states, C is the context space (project state, memory, specifications), δ: S × C → S × O is the transition function implemented as a prompt, s₀ ∈ S is the initial state, and F ⊆ S is the set of accepting (terminal) states. The output O includes both artifacts (code, documents, tests) and state mutations (memory updates, status changes).

The critical insight is that δ is a *natural language program* — the prompt — which, when combined with an LLM as execution engine, produces deterministic-in-intent behavior. The prompt constrains the LLM's output space to valid transitions, analogous to how a truth table constrains a combinational logic circuit.

A crucial distinction must be made explicit: δ is deterministic in specification but stochastic in execution. The prompt defines the *intended* transition — the correct output given a state and context — but the LLM executing δ is a probabilistic system whose outputs vary across invocations. This is not a deficiency of the model; it is a design parameter. The prompt constrains the output distribution toward valid transitions, and the framework's verification mechanisms — tests, @contracts, DIJKSTRA (quality gate) validation, and BORGES (documentation compiler) schema enforcement — serve as the convergence mechanism that compensates for execution variance. In control theory terms, δ defines the setpoint, the LLM is the plant with stochastic disturbance, and the test suite is the sensor that closes the feedback loop. The system does not require deterministic execution; it requires *convergent* execution — that repeated application of the cycle produces outputs within the acceptance region defined by specifications and tests.

### 3.2 The APE Cycle

The methodology follows a four-phase cycle applied to every development task:

**Analyze.** The SOCRATES (requirements analysis) ape examines requirements, existing code, and project memory to produce a structured analysis. Its states are {IDLE, READING, ANALYZING, COMPLETE}. The output is a scope document with risk classification.

**Plan.** The SOCRATES (in planning mode) or a dedicated PLANNER produces a phased runbook — an ordered sequence of implementation steps, each with entry criteria, deliverables, and verification conditions. This is not a suggestion; it is the execution contract.

**Execute.** Specialized apes collaborate through the orchestrator, each a minimal FSM with defined states. The full design roster includes seven apes; the current implementation (v0.0.14) deploys four — SOCRATES, DESCARTES, BASHŌ, and DARWIN — with additional apes to be introduced as the framework matures and empirical evidence justifies their necessity.

*Current implementation:*
- **SOCRATES** (requirements analysis) decomposes requirements, classifies risk, and produces scope documents. States: {IDLE, READING, ANALYZING, COMPLETE}.
- **DESCARTES** (planning) produces phased runbooks with entry criteria, deliverables, and verification conditions. States: {IDLE, DECOMPOSING, ORDERING, COMPLETE}.
- **BASHŌ** (execution) implements following the plan strictly, operating in TDD when applicable. States: {IDLE, RED, GREEN, REFACTOR}.
- **DARWIN** (evolution) extracts lessons from the execution trace and updates the learning hierarchy (Section 6). States: {IDLE, EVALUATING, COMPLETE}.

*Design roster (future, pending empirical justification):*
- **MARCOPOLO** (document ingestion) ingests external documents and normalizes them into structured markdown.
- **GATSBY** (contract validation) validates test quality, coverage, and @contract compliance independently.
- **DIJKSTRA** (quality gate) performs code review against specifications, conventions, and security criteria.
- **BORGES** (documentation compiler) maintains documentation consistency, enforcing schema on all memory files.

> **Note:** Both this paper and `ape_cli` are under active construction. The agent roster will evolve based on empirical evidence from the bootstrap process. See the public repository for current state: https://github.com/ccisnedev/finite_ape_machine

**Learn (DARWIN).** After task completion, the DARWIN meta-agent extracts lessons from the execution trace and updates the learning hierarchy (Section 6).

### 3.3 The AAD/AAE/AAM Collaboration Model

APE formalizes three modes of human-AI collaboration, drawing an explicit analogy to the CAD/CAE/CAM paradigm [29] that integrated design, simulation, and manufacturing:

- **Agent-Aided Design (AAD):** Human designs with AI assistance. The SOCRATES ape helps decompose problems, identify risks, and structure specifications. The human retains architectural authority.
- **Agent-Aided Engineering (AAE):** Human and AI co-engineer. The ADA, GATSBY, and DIJKSTRA apes execute within specifications while the human validates at semantic gates.
- **Agent-Aided Manufacturing (AAM):** AI executes mechanical tasks autonomously. Commits after green tests, documentation updates, index rebuilding — tasks where human judgment adds no value.

The risk matrix (Section 7) determines which mode applies to each action, creating a continuous spectrum from full human control to full automation calibrated by actual risk.

---

## 4. The Cooperative Event Loop Orchestrator

### 4.1 The Microcontroller Analogy

APE's orchestrator is modeled after cooperative multitasking on resource-constrained microcontrollers [17]. The mapping is precise:

| Microcontroller | APE Orchestrator |
|----------------|-----------------|
| CPU core | LLM inference engine |
| Task (FSM) | Ape (agent as FSM) |
| Shared RAM | Project state (status.md, memory/) |
| Tick cycle | Orchestrator evaluation loop |
| Cooperative yield | Ape state transition completion |
| Interrupt | Human chat message |

A single execution core services N ape-tasks through a tick cycle: READ status → EVALUATE preconditions → DECIDE next ape → EXECUTE ape → UPDATE status → YIELD. No ape is aware of the others; each operates solely on its own state and the shared project state. Intelligence is *emergent* — it arises from the orchestrator's sequencing decisions, not from any individual ape's capability.

This is a deliberate architectural choice. Holland [30] and Kauffman [31] demonstrate that complex adaptive behavior emerges from simple agents following local rules within a shared environment. The orchestrator creates the conditions for emergence without requiring any ape to model the system globally.

### 4.2 Interleaving and the Ghost in the Shell

From ADA's perspective, execution is simple: RED → GREEN → RED → GREEN. But between each atomic state transition, the orchestrator *interleaves* other apes:

```
ADA:RED → [GATSBY validates] → [GATE if high-risk] → ADA:GREEN →
[BORGES updates docs] → [COMMIT] → [DIJKSTRA checks] → [NEXT phase]
```

ADA never observes this interleaving. The orchestrator is "the ghost in the shell" — the coordinating intelligence that is not itself an agent but whose scheduling decisions produce behavior no individual ape could achieve alone. This is analogous to how an operating system's scheduler creates the illusion of parallelism on a single core: the complexity is in the coordination, not the components.

### 4.3 Precondition Idempotency

Each ape defines preconditions for activation. If preconditions are not met, the ape remains IDLE — no error, no crash, no retry logic. This produces **order independence**: the orchestrator can evaluate apes in any sequence, and the system converges to correct behavior because only apes whose preconditions are satisfied will activate. This property, borrowed directly from cooperative scheduling in embedded systems, eliminates an entire class of orchestration bugs.

---

## 5. Memory as Code

### 5.1 Motivation

Existing AI agent memory systems — RAG [32], MemGPT [33], vector databases — solve retrieval over large corpora but introduce external dependencies, are not version-controllable, and create opaque knowledge stores that humans cannot audit. APE introduces Memory as Code: project memory persisted as structured markdown files within the repository, subject to the same version control, review, and audit processes as source code.

### 5.2 Database-Inspired Design

Memory as Code applies three patterns from database theory:

**Primary index.** An `index.md` file serves as the primary index, analogous to a B-tree root. It maps memory entries to their file locations and provides metadata for filtering. This is inspired by Selinger et al.'s [34] access path selection — the index enables the equivalent of a query optimizer choosing between sequential scan (read all files) and index lookup (follow a pointer).

**YAML frontmatter as WHERE clause.** Each memory file carries structured metadata in YAML frontmatter. When an ape needs to query memory (e.g., "all lessons tagged 'authentication' with severity > 3"), the query resolves against frontmatter fields — functioning as a WHERE clause over a document collection.

**BORGES as schema enforcer.** The BORGES ape functions as a documentation compiler: it validates that all memory files conform to their declared schema, that cross-references resolve, and that indices are consistent. This is the equivalent of database constraints — CHECK, FOREIGN KEY, NOT NULL — applied to a markdown-based knowledge store.

### 5.3 Query Optimization

When an ape needs to access memory, a query planner strategy — inspired by database cost-based optimization [34] — selects the most efficient access path: (1) **index scan** — consult index.md for direct pointer lookup; (2) **filtered scan** — match YAML frontmatter fields across a subset of files; (3) **partial read** — load file headers only for metadata matching; (4) **full read** — sequential scan as last resort. Additionally, DARWIN maintains **materialized views** — pre-computed summaries (cycle-summary.md, risk-patterns.md) that aggregate frequently queried patterns, reducing per-tick read overhead.

### 5.4 Properties

Memory as Code provides: (a) full version history through git, enabling temporal queries ("what did we know at commit X?"); (b) human readability — any developer can open `.ape/memory/` and understand the project's accumulated knowledge; (c) zero external dependencies — no database, no vector store, no cloud service; (d) merge conflict resolution through standard git workflows; and (e) portability across all development environments.

---

## 6. DARWIN: Evolutionary Meta-Learning

### 6.1 The Meta-Agent

DARWIN (Development Adaptation and Refinement through Wisdom and Iterative Nurturing) is the only agent in the APE framework whose output modifies other agents' transition functions. Where all other apes produce artifacts (code, tests, documentation), DARWIN produces *lessons* — structured observations that alter the behavior of future ape invocations.

This is a form of meta-learning [35]: the system learns to learn. Constitutional AI [36] demonstrated that AI systems can self-improve through principled self-critique. DARWIN extends this concept to a multi-agent context where the meta-agent observes the *collective* behavior of the system and modifies individual agents' prompts to improve collective outcomes.

### 6.2 Three-Level Learning Hierarchy

DARWIN operates across three levels with decreasing frequency and increasing scope:

**Level 1 — Project.** After each task completion, DARWIN extracts lessons specific to the current project: coding patterns that worked, specifications that were ambiguous, tests that caught real defects. These are stored in `.ape/memory/lessons/` and influence future ape invocations within the same project.

**Level 2 — Methodology.** Periodically, DARWIN aggregates cross-project patterns for the individual developer: which runbook structures produce fewer revisions, which risk classifications correlate with actual defects, which ape configurations are most efficient. This level improves the developer's personal instance of APE.

**Level 3 — Framework.** Optionally and with explicit user consent, anonymized patterns can be contributed to the framework repository. This creates a community learning flywheel — more users → more patterns → smarter defaults → more value — analogous to Holland's [30] classifier systems where successful rules propagate through a population.

### 6.3 Empirical Evidence: DARWIN in Practice

DARWIN is not aspirational — it is deployed and producing observable results. After completing APE cycle #51 ("Enforce non-execution guardrails in IDLE"), DARWIN generated issue [#54](https://github.com/ccisnedev/finite_ape_machine/issues/54): "APE Cycle #51 Evaluation: Process and Pattern Learnings." The issue contains:

- A structured comparison of plan vs. execution (5 phases, 0 deviations)
- Three reusable patterns extracted: (1) Precondition Validation > Tool Gating, (2) FSM Declarativo YAML > Code-Based FSM, (3) Fail-Closed Prompt Registry > Silent Fallback
- An evaluation matrix of the APE process itself (ANALYZE sufficient? PLAN detailed? EXECUTE fluid?)
- Actionable recommendations for future cycles

As of v0.0.14, DARWIN has generated 9 issues labeled `evolution` (see [issue list](https://github.com/ccisnedev/finite_ape_machine/issues?q=label%3Aevolution)). Of these, #51 was closed (its recommendation adopted in a subsequent cycle), demonstrating the complete feedback loop: DARWIN observes → generates issue → maintainer triages → issue is addressed in a future APE cycle.

Currently, DARWIN reads `.ape/mutations.md` (human observations written during the cycle) as additional input. Future versions will also feed automated metrics (test deltas, deviation counts) to enrich DARWIN's analysis.

### 6.4 The Flywheel Effect

The three-level hierarchy creates a compounding improvement mechanism. Unlike static frameworks where capability is fixed at release, APE improves continuously through use. This property is particularly valuable under Scenario C (Section 8) — when the underlying LLM cannot improve, DARWIN remains the only available improvement mechanism.

---

## 7. Human Interaction: The Semantic Risk Matrix

### 7.1 The Problem of Approval Fatigue

Current AI-assisted development tools present a binary choice: either the AI acts autonomously (risking errors in critical decisions) or the human approves every action (causing approval fatigue that degrades oversight quality). Schemmer et al. [7] document that automation bias increases with AI accuracy — the better the tool performs on average, the less critically humans evaluate its outputs. This creates a dangerous equilibrium where the most capable AI tools receive the least human scrutiny.

### 7.2 Semantic Approval

APE's risk matrix classifies every action on two dimensions: **impact** (reversible ↔ irreversible) and **domain** (mechanical ↔ engineering judgment). This produces four quadrants:

- **Low impact, mechanical:** Fully automated. Commits after green tests, documentation formatting, index updates. No human involvement. (AAM mode)
- **Low impact, judgment:** Soft gate. The ape proceeds but flags the decision for human review. Test implementation strategy, naming conventions.
- **High impact, mechanical:** Hard gate with default. The ape proposes and the human confirms. Dependency additions, API changes.
- **High impact, judgment:** Full stop. Architecture decisions, specification changes, security-critical code. The human decides; the ape advises. (AAD mode)

The key insight is that *when APE asks, the question matters*. By reserving human attention for decisions that genuinely require engineering judgment, APE maintains the quality of human oversight — directly addressing the automation complacency problem identified by Cihon et al. [27] in their framework for meaningful human control.

### 7.3 Interrupts, Not Polling

Following the microcontroller analogy, human interaction is modeled as an interrupt, not polling. The orchestrator does not periodically ask "should I continue?" — it proceeds until a gate condition requires human input, then suspends execution and waits. This maps to hardware interrupt semantics: the interrupt (chat message) preempts the current tick, the orchestrator processes it, and execution resumes. The risk matrix determines the interrupt priority level.

---

## 8. Antifragility Across AI Market Scenarios

Taleb [10] defines antifragility as a property of systems that gain from disorder. APE is designed to be antifragile across four identified AI market scenarios:

**Scenario A — Bubble bursts.** Cloud inference becomes prohibitively expensive as venture subsidies end. APE's local-first architecture (no cloud dependencies for memory, CLI runs offline) and model-agnostic agent prompts ensure the framework functions with open-source local models. A 7B model cannot "vibe code" a payment system, but it can follow a structured runbook with RED→GREEN verification at each phase.

**Scenario B — Technology advances.** Models become more capable and cheaper. APE's structured methodology *amplifies* rather than *limits* increased capability — more capable models handle larger phases, subtler analysis, and deeper pattern recognition through DARWIN.

**Scenario C — LLM reasoning plateaus.** The current capability ceiling is reached. The only path to improvement becomes the software wrapping the model: APE's methodology, orchestration, and DARWIN's evolutionary learning provide continuous improvement when the underlying model cannot improve.

**Scenario D — Coexistence.** Frontier cloud models for high-risk tasks, local models for mechanical tasks. The risk matrix can determine not just gate intensity but *which model* each ape uses, enabling cost optimization through intelligent model routing.

Under all four scenarios, APE's value proposition strengthens or remains stable. This is antifragility by design — the framework does not merely survive market volatility; it benefits from it.

---

## 9. Contributions

We identify six primary contributions — applications of known techniques in a novel context — and four derived properties that emerge from their combination:

### Primary contributions

1. **Prompts as transition functions.** Applying FSM formalism to prompt engineering: formalizing LLM prompts as δ in the 5-tuple A = (S, C, δ, s₀, F), treating prompt design as automata design. While prior work [11, 12] uses FSMs to describe agent behavior, APE treats the prompt itself as the mathematical object δ.

2. **Cooperative event loop orchestration for AI agents.** Applying the cooperative multitasking model from 8-bit embedded systems [17] to LLM agent coordination, with apes as FSM tasks sharing state through project memory. The interleaving property — where the orchestrator inserts validation and review steps between an agent's atomic states without the agent's awareness — enables rich workflow behavior from simple agent implementations.

3. **Memory as Code.** A persistent memory system for AI agents that uses version-controlled markdown files with database-inspired indexing (primary index, YAML-as-WHERE-clause, schema enforcement), eliminating external dependencies while maintaining queryability. The schema enforcement agent (BORGES) functions as database DDL enforcement applied to a markdown knowledge base.

4. **DARWIN as evolutionary meta-agent.** A meta-learning agent whose output modifies other agents' transition functions, operating across a three-level hierarchy (project → methodology → framework) that creates compounding improvement. Empirically validated: 9 evolution issues generated as of v0.0.14 (§6.3).

5. **Semantic risk matrix.** A context-aware human gate system that classifies actions by impact × domain to determine approval authority, directly addressing the documented problem of automation complacency [7, 8] by ensuring that human attention is reserved for decisions requiring engineering judgment.

6. **Antifragile framework design.** A deliberate architectural strategy that ensures the framework benefits from AI market disorder across four identified scenarios (§8), achieved through local-first design, model-agnostic prompts, and methodology-over-model prioritization.

### Derived properties

The following emerge from the primary contributions but are not independent innovations:

- **AAD/AAE/AAM collaboration taxonomy.** A framing of human-AI collaboration modes (Agent-Aided Design/Engineering/Manufacturing) adapted from the CAD/CAE/CAM paradigm [29]. This provides vocabulary for describing the control spectrum but is not a technical mechanism.

- **@contracts (proposed).** Language-agnostic semantic metadata for bidirectional spec ↔ test traceability. Not yet implemented; included as design intent for future validation.

- **Interleaving transparency.** A property of contribution #2 (the event loop): agents are unaware of orchestrator-inserted steps between their state transitions.

- **Documentation-as-schema.** A property of contribution #3 (Memory as Code): an agent enforcing structural constraints on the knowledge base, analogous to DDL in relational databases.

---

## 10. Conclusion and Future Work

We present APE as a formal framework and defer empirical validation to the implementation phase, noting that the framework is currently being developed using its own methodology (APE builds APE) as initial validation. This paper establishes the theoretical foundations and architectural design; a companion paper will report empirical results from controlled experiments comparing APE-structured development against unstructured AI-assisted development.

The Finite APE Machine demonstrates that the missing element in AI-assisted software development is not more capable models but more structured methodology. By applying well-understood concepts from automata theory, embedded systems, control theory, and database design to the novel domain of LLM agent orchestration, APE provides a framework where *the whole exceeds the sum of its parts* — emergent intelligent behavior from the coordination of simple, constrained agents.

Future work includes: empirical validation through the aforementioned companion study; extension of the DARWIN learning mechanism to cross-user pattern sharing; formal verification of orchestrator properties (liveness, safety, fairness); and implementation of model-routing optimization for Scenario D (cost-aware per-ape model assignment).

The framework's thesis — that constraint, not freedom, is the path to reliable AI-assisted software engineering — is validated through its own self-constructing development history: 14 versions, 131 tests, 69 issues/PRs, and 9 DARWIN-generated evolution issues, all produced by the methodology describing itself.

---

## References

[1] Peng, S., Kalliamvakou, E., Cihon, P., & Demirer, M. (2023). The impact of AI on developer productivity: Evidence from GitHub Copilot. arXiv:2302.06590.

[2] GitHub (2023). Research: Quantifying GitHub Copilot's impact on developer productivity and happiness. *GitHub Blog*.

[3] Borel, É. (1913). Mécanique statistique et irréversibilité. *Journal de Physique*, 5e série, 3, 189–196. See also: Borel, É. (1914). *Le Hasard*. Félix Alcan.

[4] Hong, S., Zhuge, M., Chen, J., et al. (2023). MetaGPT: Meta programming for a multi-agent collaborative framework. arXiv:2308.00352.

[5] Wu, Q., Bansal, G., Zhang, J., et al. (2023). AutoGen: Enabling next-gen LLM applications via multi-agent conversation. arXiv:2308.08155.

[6] Li, G., Hammoud, H. A. H., Itani, H., Khizbullin, D., & Ghanem, B. (2023). CAMEL: Communicative agents for "mind" exploration of large language model society. *NeurIPS 2023*. arXiv:2303.17760.

[7] Schemmer, M., Mihai, A. V., Zuberbühler, F., Klar, J., & Levine, Y. (2025). Exploring automation bias in human-AI collaboration: A review and implications for explainable AI. *AI & SOCIETY*, Springer Nature.

[8] Hamundu, B., Ayobi, A., & Marshall, J. (2025). Automation complacency: Risks of abdicating medical decision making. *AI and Ethics*, Springer Nature.

[9] Hopcroft, J. E., Motwani, R., & Ullman, J. D. (2006). *Introduction to Automata Theory, Languages, and Computation* (3rd ed.). Pearson/Addison-Wesley.

[10] Taleb, N. N. (2012). *Antifragile: Things That Gain from Disorder*. Random House.

[11] Cheng, X., Lin, H., Deng, R., Gao, W., & Ruan, S. (2025). An agentic flow for finite state machine extraction using prompt chaining. arXiv:2507.11222.

[12] Tanaka, K., et al. (2025). MetaAgent: Automatically constructing multi-agent systems based on finite state machines. *Proc. ICML 2025*.

[13] Liu, S., et al. (2025). Building a stable planner: An extended finite state machine based planning module for mobile GUI agent. arXiv:2505.14141.

[14] Åström, K. J. & Murray, R. M. (2021). *Feedback Systems: An Introduction for Scientists and Engineers* (2nd ed.). Princeton University Press.

[15] Patria, D., et al. (2026). A control-theoretic foundation for agentic systems. arXiv:2603.10779.

[16] Ngo, P., et al. (2026). Why alignment needs formal control theory. arXiv:2506.17846.

[17] Liu, C. L. & Layland, J. W. (1973). Scheduling algorithms for multiprogramming in a hard-real-time environment. *Journal of the ACM*, 20(1), 46–61. DOI: 10.1145/321738.321743.

[18] Wooldridge, M. J. (2009). *An Introduction to MultiAgent Systems* (2nd ed.). Wiley.

[19] Ferber, J. (1999). *Multi-Agent Systems: An Introduction to Distributed Artificial Intelligence*. Addison-Wesley.

[20] Rao, A. S. & Georgeff, M. P. (1991). Modeling rational agents within a BDI-architecture. *Proc. 2nd International Conference on Principles of Knowledge Representation and Reasoning*, 473–484.

[21] Smith, R. G. (1980). The contract net protocol: High-level communication and control in a distributed problem solver. *IEEE Transactions on Computers*, 29(12), 1104–1113.

[22] Wang, L., Ma, C., Feng, X., et al. (2024). A survey on large language model based autonomous agents. *Frontiers of Computer Science*, 18, 186345. arXiv:2308.11432.

[23] Yao, S., Zhao, J., Yu, D., et al. (2022). ReAct: Synergizing reasoning and acting in language models. *ICLR 2023*. arXiv:2210.03629.

[24] Beck, K. (2003). *Test-Driven Development: By Example*. Addison-Wesley.

[25] Nagappan, N., Maximilien, E. M., Bhat, T., & Williams, L. (2008). Realizing quality improvement through test-driven development: Results and experiences of four industrial teams. *Empirical Software Engineering*, 13(3), 289–302. DOI: 10.1007/s10664-008-9062-z.

[26] Meyer, B. (1997). *Object-Oriented Software Construction* (2nd ed.). Prentice Hall.

[27] Cihon, P., Hough, K., & Toner, H. (2022). Meaningful human control: Actionable properties for AI system development. *AI and Ethics*. DOI: 10.1007/s43681-022-00167-3. arXiv:2112.01298.

[28] Amershi, S., Weld, D., Vorvoreanu, M., et al. (2019). Guidelines for human-AI interaction. *CHI 2019*, ACM.

[29] Ross, D. T. (1960). Computer-aided design project. MIT Electronic Systems Laboratory. See also: Bézier, P. (1972). *Numerical Control: Mathematics and Applications*. Wiley. For the integrated CAD/CAE/CAM paradigm: Groover, M. P. & Zimmers, E. W. (1984). *CAD/CAM: Computer-Aided Design and Manufacturing*. Prentice Hall.

[30] Holland, J. H. (1995). *Hidden Order: How Adaptation Builds Complexity*. Oxford University Press. See also: Holland, J. H. (1975/1992). *Adaptation in Natural and Artificial Systems*. MIT Press.

[31] Kauffman, S. A. (1995). *At Home in the Universe: The Search for the Laws of Self-Organization and Complexity*. Oxford University Press.

[32] Lewis, P., Perez, E., Piktus, A., et al. (2020). Retrieval-augmented generation for knowledge-intensive NLP tasks. *NeurIPS 2020*. arXiv:2005.11401.

[33] Packer, C., Wooders, S., Lin, K., et al. (2023). MemGPT: Towards LLMs as operating systems. arXiv:2310.08560.

[34] Selinger, P. G., Astrahan, M. M., Chamberlin, D. D., Lorie, R. A., & Price, T. G. (1979). Access path selection in a relational database management system. *Proc. ACM SIGMOD*, 23–34. DOI: 10.1145/582095.582099.

[35] Bai, Y., Kadavath, S., Kundu, S., et al. (2022). Constitutional AI: Harmlessness from AI feedback. *Anthropic*. arXiv:2212.08073.

[36] Nygard, M. T. (2011). Documenting architecture decisions. *Cognitect Blog*. See also: ADR community standard at adr.github.io.