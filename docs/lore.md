# The Apes — Lore

> Every ape in the Finite APE Machine carries two identities: a **name** drawn from history and literature that embodies its essence, and a **function** expressed as a CLI command that describes what it does. The name is the soul; the command is the hand.

---

## MARCOPOLO

**Function:** `scout` — Document Ingestion and Normalization

**The allegory.** Marco Polo (1254–1324) traveled to lands no European had documented, observed with discipline, and returned with *Il Milione* — a structured report of everything he witnessed. He did not conquer, interpret, or judge. He explored and brought back intelligible accounts of the unknown.

**The ape.** MARCOPOLO receives heterogeneous documents — PDFs, Word files, spreadsheets, emails, images, repositories — and produces structured markdown. It does not analyze, decide, or recommend. It makes the illegible legible. Like its namesake, it crosses the boundary between the uncharted and the known, returning with reports others can act on.

**FSM:** `idle → ingesting → normalizing → delivering → idle`

---

## SOCRATES

**Function:** `analyst` — Conversational Requirements Understanding

**The allegory.** Socrates (c. 470–399 BC) never wrote a word. His method was the question — not to instruct, but to draw truth out of the interlocutor. The Socratic method assumes that the person being questioned already holds the knowledge; the philosopher's role is to make it explicit through structured interrogation.

**The ape.** SOCRATES takes MARCOPOLO's output and processes it through conversation. It asks questions, identifies ambiguities, maps the domain, challenges assumptions. It produces the scope document and constraints. Like its namesake, it does not tell the human what the requirements are — it asks until the human discovers them.

**FSM:** `idle → understanding → questioning → clarifying → documenting → idle`

---

## VITRUVIUS

**Function:** `architect` — Decomposition and Structuring

**The allegory.** Marcus Vitruvius Pollio (c. 80–15 BC) authored *De Architectura*, the oldest surviving treatise on architecture. His three principles — *firmitas, utilitas, venustas* (strength, utility, beauty) — established that structure is not mere assembly but intentional composition where every part bears a relationship to the whole.

**The ape.** VITRUVIUS takes the scope defined by SOCRATES and decomposes it. Work Breakdown Structure, Gantt charts, task sizing, dependency analysis, execution order. It decides when a task is small enough to pass to planning and when it must be subdivided further. Like its namesake, it does not build — it designs the plan from which others build.

**FSM:** `idle → decomposing → sizing → sequencing → risk_assessing → delivering → idle`

---

## SUNZI

**Function:** `strategist` — Technical Design and Runbook Generation

**The allegory.** Sunzi (孫子, c. 544–496 BC) wrote *The Art of War*, a treatise where victory is decided before battle through preparation, terrain knowledge, and strategic sequencing. "Every battle is won before it is ever fought." The general who plans thoroughly does not improvise under fire.

**The ape.** SUNZI takes a single task from VITRUVIUS's WBS and generates a phased runbook: which patterns to use, which components to touch, implementation order, entry criteria, verification conditions. It verifies that analysis documentation exists and is sufficient — if not, it halts and escalates. Like its namesake, SUNZI plans the campaign so that execution becomes a matter of following the plan, not inventing one under pressure.

**FSM:** `idle → reading_context → designing → staging → delivering → idle`

---

## GATSBY

**Function:** `contracts` — Contract Definition and RED Tests

**The allegory.** Jay Gatsby, from F. Scott Fitzgerald's *The Great Gatsby* (1925), stands at the edge of his dock staring at the green light across the bay — a symbol of the future he reaches for but has not yet grasped. The green light is the promise; the distance is the work that remains.

**The ape.** GATSBY defines what each piece of code must become before it exists. It writes @contract blocks and executable tests — all in RED state, all failing, all reaching toward a green light that ADA will make real. Every test GATSBY writes is a declaration: *this is what must be true*. Like its namesake, GATSBY defines the destination with absolute clarity. It never arrives — that is not its role.

**FSM:** `idle → reading_stage → designing_contracts → writing_tests → validating_red → delivering → idle`

---

## ADA

**Function:** `coder` — TDD Implementation

**The allegory.** Augusta Ada King, Countess of Lovelace (1815–1852), wrote what is recognized as the first computer program — an algorithm for Charles Babbage's Analytical Engine. She saw that the machine could do more than calculate; it could compose music, produce graphics, manipulate symbols. She was the first to translate abstract mathematical intention into executable procedure.

**The ape.** ADA takes GATSBY's RED tests and turns them GREEN. Pure TDD: read the failing test, implement the minimum code to pass it, run the suite, repeat. ADA does not question the tests — it fulfills them. Tactical deviations (different library, adjusted pattern) are resolved and documented. Strategic deviations (spec contradictions, architectural blockers) are escalated. Like its namesake, ADA translates intention into working machinery.

**FSM:** `idle → reading_tests → implementing → running_tests → green|red|blocked → idle`

---

## DIJKSTRA

**Function:** `reviewer` — Quality Gate Pre-PR

**The allegory.** Edsger W. Dijkstra (1930–2002) was the conscience of computer science. His rigor was legendary: "Testing shows the presence, not the absence of bugs." He conceived structured programming, argued against GOTO, and insisted that correctness must be demonstrated, not merely tested. His handwritten EWD manuscripts set a standard for clarity and precision that few have matched.

**The ape.** DIJKSTRA reviews code before it reaches the human. It verifies coherence between @contracts, tests, and implementation. It checks code smells, validates tactical deviations, runs static analysis, scans for security issues. Its intensity scales with risk: lightweight for low-risk, exhaustive for critical. Like its namesake, DIJKSTRA does not care whether the code works — it cares whether the code is *correct*.

**FSM:** `idle → reading_changes → checking_contracts → checking_quality → checking_security → approved|issues → idle`

---

## BORGES

**Function:** `scribe` — Schema Enforcement and Documentation Compilation

**The allegory.** Jorge Luis Borges (1899–1986) was a writer, but more relevantly, he was a librarian — director of the Biblioteca Nacional de Argentina. His short story *The Library of Babel* (1941) describes a universe consisting of an infinite library containing every possible book: every truth, every falsehood, every variation. The library is complete but useless — without a catalog, without an index, without a schema to separate meaning from noise, its infinity is indistinguishable from chaos.

**The ape.** BORGES is the documentation compiler. It enforces that every memory file conforms to its declared schema, that cross-references resolve, that indices are consistent, that frontmatter is valid. Without BORGES, Memory as Code degrades into the Library of Babel: a collection of documents that contains everything but reveals nothing. Like its namesake, BORGES understands that the value of a library is not in its contents but in its order.

**FSM:** `idle → validating → writing → complete → idle`

---

## DARWIN

**Function:** `learn` — Evolutionary Meta-Learning

**The allegory.** Charles Darwin (1809–1882) did not invent evolution — he discovered its mechanism: natural selection. Organisms do not improve by design; they improve because variants that survive reproduce, and variants that fail do not. The insight is that *the system improves itself through its own operation*, without a designer directing the improvement.

**The ape.** DARWIN is the only agent whose output modifies other agents' transition functions. After each completed cycle, it collects execution data, compares plan versus actual, identifies patterns, and generates lessons that alter future behavior. DARWIN operates across three levels: project (immediate lessons), methodology (cross-project patterns), and framework (community evolution). Like its namesake, DARWIN does not design improvements — it observes what worked, what failed, and what mutated, then *selects* the adaptations that make the system fitter.

**FSM:** `idle → collecting_cycle_data → comparing_plan_vs_actual → identifying_patterns → generating_lessons → creating_issues → idle`

---

## HERMES

**Function:** `tracker` — Automatic State Update (hook, not an ape)

**The allegory.** Hermes (Ἑρμῆς), messenger of the Olympian gods, moved between worlds carrying information without altering it. He did not decide, fight, or create — he delivered. He was the only god permitted to cross freely between Olympus, the mortal world, and the underworld. His role was pure communication: ensuring that every realm knew the state of the others.

**The mechanism.** HERMES is not an ape — it has no FSM, no prompt, no autonomous behavior. It is a lightweight hook that fires automatically each time an ape completes a state transition. It updates `status.md` with the current task, runbook progress, completed phases, and pending work. The orchestrator and every ape read this file. Like its namesake, HERMES ensures that every agent knows where the system stands, without being one of the agents himself.

---

## Quick Reference

| Name | Command | Role | Stage | Type |
|------|---------|------|-------|------|
| MARCOPOLO | `scout` | Document ingestion and normalization | Analyze | Ape |
| SOCRATES | `analyst` | Conversational requirements understanding | Analyze | Ape |
| VITRUVIUS | `architect` | Decomposition, WBS, Gantt, sizing | Analyze | Ape |
| SUNZI | `strategist` | Technical design and runbook generation | Plan | Ape |
| GATSBY | `contracts` | @contract definition and RED tests | Plan | Ape |
| ADA | `coder` | TDD implementation (RED → GREEN) | Execute | Ape |
| DIJKSTRA | `reviewer` | Quality gate, code review pre-PR | Execute | Ape |
| BORGES | `scribe` | Schema enforcement, documentation compiler | Cross-cutting | Ape |
| DARWIN | `learn` | Evolutionary meta-learning | Meta | Ape |
| HERMES | `tracker` | Automatic state update | Cross-cutting | Hook |
