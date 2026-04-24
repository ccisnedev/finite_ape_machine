# The Apes — Lore

> This document is the repository's nomenclature, allegory, and historical-context companion for the named agents. For the current canonical explanation of Thinking Tools, see [thinking-tools.md](thinking-tools.md). For the current system-level explanation of APE as orchestrating methodology, see [architecture.md](architecture.md).

> Historical naming note: APE was the project's initial working name. Inquiry is the current system name and public identity. The individual sub-agents remain "apes" here as a lore and avatar convention, and the phrase "APE builds APE" is preserved only as historical bootstrap wording from that earlier phase.

> Every ape in the Finite APE Machine carries two identities: a **name** drawn from history and literature that embodies its essence, and a **function** expressed as a CLI command that describes what it does. The name is the soul; the command is the hand.

---

## Active Model (v0.0.8+)

The current APE cycle uses four sub-agents, each embodying a thinking tool from a different discipline, era, and culture, plus an explicit END gate before EVOLUTION:

```
IDLE ──→ ANALYZE ──→ PLAN ──→ EXECUTE ──→ END ──→ EVOLUTION
```

APE is NOT an ape — it is the Finite APE Machine, the scheduler, the RTOS event loop. It has no personality and no namesake. It operates directly in IDLE and at the END gate; the four sub-agents below are the thinking tools it dispatches in the other states.

---

## SOCRATES

**State:** ANALYZE
**Function:** `analyst` — Conversational Requirements Understanding
**Thinking tool:** Mayéutica — draw truth through questions

**The allegory.** Socrates (c. 470–399 BC) never wrote a word. His method was the question — not to instruct, but to draw truth out of the interlocutor. The Socratic method assumes that the person being questioned already holds the knowledge; the philosopher's role is to make it explicit through structured interrogation.

**The ape.** SOCRATES explores problems through conversation. It asks questions, identifies ambiguities, maps the domain, challenges assumptions. It produces `diagnosis.md` — a rigorous paper with references that serves as the sole input for the planning phase. Like its namesake, it does not tell the human what the requirements are — it asks until the human discovers them.

**Key artifact:** `cleanrooms/<task>/analyze/diagnosis.md`

---

## DESCARTES

**State:** PLAN
**Function:** `planner` — Experimental Design and WBS Generation
**Thinking tool:** The Method — divide, order, verify, enumerate

**The allegory.** René Descartes (1596–1650) wrote the *Discours de la Méthode*, establishing four rules that remain the clearest algorithm for systematic thinking: (1) accept nothing without evidence, (2) divide each difficulty into parts, (3) order thoughts from simple to complex, (4) enumerate so completely that nothing is omitted. His method IS the scientific method's operational core.

**The ape.** DESCARTES takes `diagnosis.md` and designs an experiment. The plan is a hypothesis: "if we implement these phases in this order, we will solve the diagnosed problem." It decomposes complexity into a WBS with checkable phases, defines tests in pseudocode as verification criteria, and sequences by dependency. The plan must be detailed enough that EXECUTE is mechanical — following instructions, not inventing them. If EXECUTE detects a deviation, the system returns to ANALYZE — like falsifying a hypothesis in the scientific method. Like its namesake, DESCARTES does not build — it designs the experiment from which others build.

**Key artifact:** `cleanrooms/<task>/plan.md`

---

## BASHŌ

**State:** EXECUTE
**Function:** `artisan` — Implementation as Functional Art
**Thinking tool:** Techne + 用の美 (yō no bi) — the beauty of use

**The allegory.** Matsuo Bashō (松尾芭蕉, 1644–1694) was the master of haiku. His art: maximum meaning in minimum expression, under strict formal constraints (5-7-5 syllables). His masterwork *Oku no Hosomichi* (奥の細道, "The Narrow Road to the Deep North") is a travel journal where each stop produces a haiku — each phase of the journey IS the work.

```
furu ike ya          the old pond
kawazu tobikomu      a frog jumps in
mizu no oto          sound of water
```

17 syllables. Not one wasted. Each carries meaning. The kigo (seasonal word) provides context. The kireji (cutting word) separates concerns. The 5-7-5 constraint does not limit — it reveals.

**The ape.** BASHŌ implements DESCARTES' plan phase by phase, like composing haiku at each stop of a journey. The plan's restrictions are the 5-7-5 form — they constrain, and from that constraint beauty emerges. Each phase produces a commit. BASHŌ does not invent — it receives the plan's constraints and creates within them. As Bashō himself said: *"Do not follow in the footsteps of the ancients; seek what they sought."* The goal is not to mechanically follow the plan, but to find the most elegant implementation that satisfies it.

**Key mapping:**

| Haiku | Code |
|-------|------|
| 5-7-5 (formal constraint) | Plan phases, TDD, lint, types |
| Kigo (seasonal context) | Domain context, naming |
| Kireji (cutting word) | Separation of concerns, interfaces |
| Wabi-sabi (beauty in simplicity) | YAGNI, no over-engineering |
| Each stop = one haiku | Each phase = one commit |
| The journey IS the work | The implementation process IS the artifact |

**Key artifact:** Code + commits per phase + validation report

---

## DARWIN

**State:** EVOLUTION
**Function:** `evolve` — Evolutionary Meta-Learning
**Thinking tool:** Natural selection — observe, compare, select

**The allegory.** Charles Darwin (1809–1882) did not invent evolution — he discovered its mechanism: natural selection. Organisms do not improve by design; they improve because variants that survive reproduce, and variants that fail do not. The insight is that *the system improves itself through its own operation*, without a designer directing the improvement.

**The ape.** DARWIN is the only agent whose output targets APE itself. After each completed cycle, it reads the full artifacts (diagnosis.md, plan.md, commits, deviations), evaluates APE's process performance, and generates improvement proposals as GitHub issues. Before creating a new issue, DARWIN searches for existing ones (`gh issue list --repo finite_ape_machine --search "keyword"`) and comments on matches instead of duplicating. DARWIN is automatic and requires no user approval. It can be disabled via `.inquiry/config.yaml` (`evolution.enabled: false`). Like its namesake, DARWIN does not design improvements — it observes what worked, what failed, and what mutated, then *selects* the adaptations that make the system fitter.

**Key artifact:** Issues/comments in the `finite_ape_machine` repository

---

## Extended Lore (future/referential)

> The following agents are part of APE's original vision. They remain as reference for future expansion. In the current model (v0.0.8+), their functions have been absorbed by the four active agents or are planned as skills/CLI features.

### MARCOPOLO

**Original function:** `scout` — Document Ingestion and Normalization
**Current status:** Future — SOCRATES handles document ingestion via skills

**The allegory.** Marco Polo (1254–1324) traveled to lands no European had documented, observed with discipline, and returned with *Il Milione* — a structured report of everything he witnessed. He did not conquer, interpret, or judge. He explored and brought back intelligible accounts of the unknown.

### VITRUVIUS

**Original function:** `architect` — Decomposition and Structuring
**Current status:** Absorbed by DESCARTES (WBS decomposition is part of the plan)

**The allegory.** Marcus Vitruvius Pollio (c. 80–15 BC) authored *De Architectura*. His three principles — *firmitas, utilitas, venustas* (strength, utility, beauty) — established that structure is not mere assembly but intentional composition.

### SUNZI

**Original function:** `strategist` — Technical Design and Runbook Generation
**Current status:** Replaced by DESCARTES (the Method is more explicit than strategic metaphor)

**The allegory.** Sunzi (孫子, c. 544–496 BC) wrote *The Art of War*: "Every battle is won before it is ever fought." The general who plans thoroughly does not improvise under fire.

### GATSBY

**Original function:** `contracts` — Contract Definition and RED Tests
**Current status:** Absorbed by DESCARTES (test pseudocode is defined in plan.md)

**The allegory.** Jay Gatsby stares at the green light across the bay — the future he reaches for but has not yet grasped. Every test GATSBY writes is a declaration: *this is what must be true*.

### ADA

**Original function:** `coder` — TDD Implementation
**Current status:** Replaced by BASHŌ (implementation as functional art under constraints)

**The allegory.** Augusta Ada King, Countess of Lovelace (1815–1852), was the first to translate abstract mathematical intention into executable procedure.

### DIJKSTRA

**Original function:** `reviewer` — Quality Gate Pre-PR
**Current status:** Future — may become a skill within EXECUTE

**The allegory.** Edsger W. Dijkstra (1930–2002) was the conscience of computer science. "Testing shows the presence, not the absence of bugs." He insisted that correctness must be demonstrated, not merely tested.

### BORGES

**Original function:** `scribe` — Schema Enforcement and Documentation Compilation
**Current status:** Future — may become a CLI validation layer (`iq doctor --memory`)

**The allegory.** Jorge Luis Borges (1899–1986) — librarian, author of *The Library of Babel*. The value of a library is not in its contents but in its order.

### HERMES

**Original function:** `tracker` — Automatic State Update (hook, not an ape)
**Current status:** Future — may become `iq state transition` command

**The allegory.** Hermes (Ἑρμῆς), messenger of the gods, moved between worlds carrying information without altering it. Pure communication: ensuring every realm knew the state of the others.

---

## Quick Reference

### Active Agents (v0.0.8+)

| Name | State | Thinking Tool | Era/Culture | Key Artifact |
|------|-------|--------------|-------------|-------------|
| SOCRATES | ANALYZE | Mayéutica | Greece, 470 BC | `diagnosis.md` |
| DESCARTES | PLAN | Scientific Method | France, 1596 | `plan.md` |
| BASHŌ | EXECUTE | Techne / 用の美 | Japan, 1644 | Code + commits |
| DARWIN | EVOLUTION | Natural Selection | England, 1809 | Issues in APE repo |

### Extended Lore (future)

| Name | Original Role | Current Status |
|------|--------------|----------------|
| MARCOPOLO | Document ingestion | Future (SOCRATES + skills) |
| VITRUVIUS | WBS/decomposition | Absorbed by DESCARTES |
| SUNZI | Strategic planning | Replaced by DESCARTES |
| GATSBY | RED tests/@contracts | Absorbed by DESCARTES |
| ADA | TDD implementation | Replaced by BASHŌ |
| DIJKSTRA | Quality gate | Future (skill in EXECUTE) |
| BORGES | Schema enforcement | Future (CLI validation) |
| HERMES | State updates | Future (`iq state transition`) |
