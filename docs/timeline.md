# Timeline

How Inquiry came to exist. This document traces the path from a communication problem to a methodology, from a prompt to a CLI, and from a personal tool to a public system.

## Prehistory: the communication gap

**Late 2022.** OpenAI releases ChatGPT to the public. Like millions of others, I started using AI for software development. The promise was immediate: describe what you want, get code back. The reality was different.

The AI assumed things I hadn't said. It misinterpreted ambiguous requests. It produced plausible but wrong solutions with absolute confidence. Most of the time, the fault was mine — I expressed myself with the ambiguity natural to human language and expected the machine to read my intent. It didn't. It read my words.

I also discovered, through trial and error, that the most reliable way to get correct output from an AI was **Test-Driven Development**: when you write tests first, they become a specification the AI can implement against. Tests are unambiguous. Tests don't drift. But to write good tests, you need clear requirements. And to get clear requirements, you need rigorous analysis.

The pattern was forming: **Analyze → Plan → Execute.**

## The Coding Manifesto

**2026-03-10.** The first artifact: a coding manifesto in a personal `ai` repo ([`ccisnedev/ai@a60dee5`](https://github.com/ccisnedev/ai/commit/a60dee5)). A set of principles for how code should be written when collaborating with AI — clarity of intent, readable structure, explicit naming. Not a methodology yet. Just rules for the human side of the conversation.

## The Inquiry repo is born

**2026-03-30.** The `inquiry` repo (then called `finite_ape_machine`) was created with a first commit ([`a1cd601`](https://github.com/SiliconBrainedMachines/inquiry/commit/a1cd601)). Initially it was a documentation-only project: agent role definitions, lore, architecture decision records. No CLI yet — just the intellectual scaffolding for what would become the Finite APE Machine.

## The book begins

**2026-03-31.** A parallel track started: a book. [`philo_sophia`](https://github.com/ccisnedev/philo_sophia) — working title *Philo SophIA* — was created to explore the philosophical foundations of human-AI communication. The core thesis: every failure mode of AI-assisted development maps to a philosophical problem that someone studied centuries ago. The tools to direct the most powerful thinking machine ever built are the oldest tools humanity has.

## APE v0.1.0 — the first prompt

**2026-04-03.** The birth of APE as a concrete artifact. Commit [`ac2da79`](https://github.com/ccisnedev/ai/commit/ac2da79) in the `ai` repo created `agent-prompt.md` v0.1.0 — 112 lines that defined:

- Three states: **ANALYZE**, **PLAN**, **EXECUTE**
- All transitions require explicit user authorization
- Ambiguous approval is not authorization ("Ok", "Sounds good" are NOT transitions)
- The state machine cannot be bypassed by urgency or emotional appeals
- Directory structure convention: `docs/ape/NNN-slug/`

This was the moment APE became operational. A human and an AI agent could now work together under a shared contract. The agent announced its state at every response: `[APE: ANALYZE]`, `[APE: PLAN]`, `[APE: EXECUTE]`.

The prompt lived in the `ai` repo and was deployed to VS Code via a symbolic link to `~/.copilot/`. A manual process — but it worked.

## The Socratic revelation

**2026-04-15.** While refining the ANALYZE phase, I searched for a more rigorous method of questioning. The one I found was twenty-five centuries old: the **Socratic method** — *mayéutica* — the art of drawing knowledge through questions rather than assertions. Commit [`73a4ead`](https://github.com/ccisnedev/ai/commit/73a4ead) introduced SOCRATES as a dedicated sub-agent:

> *"You are SOCRATES, an analysis assistant that uses the Socratic method to help users understand problems deeply."*

This was the turning point. If one ancient thinking tool (Socratic questioning) worked for ANALYZE, were there others? The answer led to:
- **DESCARTES** for PLAN — Cartesian method: divide, order, verify, enumerate
- **BASHŌ** for EXECUTE — techne: minimal, beautiful implementation under constraints
- **DARWIN** for EVOLUTION — natural selection applied to the methodology itself

Each agent embodied a philosophical tradition. Each tradition had been tested for centuries. The realization that philosophy was not a museum but a toolkit for engineering — this was the moment Inquiry became more than a prompt.

## The CLI is born

**2026-04-15.** The same day SOCRATES was defined, the CLI work began. The manual symlink process (copy prompt to `~/.copilot/`) was a friction point. A CLI that automated deployment was the natural next step. Inspired by [gentle-ai](https://github.com/Gentleman-Programming/gentle-ai) (Gentleman Programming) — a project that packaged prompts and skills via a CLI — I started building a Dart CLI on [`modular_cli_sdk`](https://github.com/siliconbrainedmachines/modular_cli_sdk).

Commits [`44150463`](https://github.com/SiliconBrainedMachines/inquiry/commit/44150463) (scaffold) and [`45fba9e`](https://github.com/SiliconBrainedMachines/inquiry/commit/45fba9e) (`ape init` command) landed that day.

## Rapid evolution: v0.0.2 to v0.0.14

**2026-04-16 to 2026-04-18.** In three days, 13 releases:

| Date | Version | Milestone |
|------|---------|-----------|
| Apr 16 | v0.0.2 | `ape target get` — deploy agent + skills to Copilot |
| Apr 16 | v0.0.3 | Install scripts (PowerShell + Bash), GitHub Pages site |
| Apr 16 | v0.0.5 | `ape upgrade`, `ape uninstall` |
| Apr 16 | v0.0.6 | Automated release workflow, Windows Defender workaround |
| Apr 17 | v0.0.7 | `ape doctor` — prerequisite verification |
| Apr 17 | v0.0.9 | `issue-start` skill, IDLE triage |
| Apr 18 | v0.0.10 | Five-state FSM: IDLE → ANALYZE → PLAN → EXECUTE → EVOLUTION |
| Apr 18 | v0.0.11 | END state, transition contract (YAML), `ape state transition` |
| Apr 18 | v0.0.14 | EVOLUTION infrastructure — `config.yaml`, `mutations.md` lifecycle |

From this point on, APE was building APE. Every CLI feature was developed using the APE methodology itself — issue → analysis → plan → execute → PR → evolution. The bootstrap thesis was validated: the system could improve itself.

## Peirce and the philosophical grounding

**2026-04-20.** Research into why APE's three-phase structure worked led to Charles Sanders Peirce's theory of inquiry. Commit [`feat: agregar documentación sobre la teoría de la indagación de Peirce`](https://github.com/SiliconBrainedMachines/inquiry/commit/feat) revealed the mapping:

| Peirce's inquiry | APE phase | Agent |
|------------------|-----------|-------|
| **Abduction** — inference to the best explanation | ANALYZE | SOCRATES |
| **Deduction** — derive consequences from hypotheses | PLAN | DESCARTES |
| **Induction** — test consequences against reality | EXECUTE | BASHŌ |

APE wasn't just a workflow — it was an implementation of the oldest formal theory of structured investigation. The name **Inquiry** was chosen the same day ([`docs(110): analysis complete - inquiry chosen as APE primary noun`](https://github.com/SiliconBrainedMachines/inquiry/commit/docs-110)).

## The VS Code extension

**2026-04-19.** A VS Code extension was created to bring Inquiry into the editor: status bar showing FSM state, commands for `init`, `toggleEvolution`, and `addMutation`. Published to the [VS Code Marketplace](https://marketplace.visualstudio.com/items?itemName=siliconbrainedmachines.inquiry-vscode) the same day. Built entirely using the APE cycle (issue #82).

## The rebrand

**2026-04-21 to 2026-04-22.** The project moved from `ccisnedev/finite_ape_machine` to `SiliconBrainedMachines/inquiry`. The CLI was renamed from `ape` to `iq`. The methodology kept its APE name internally, but the system's public identity became **Inquiry** — a name grounded in Peirce's theory. Version **v0.1.0** marked the rebrand.

## The Finite APE Machine

**2026-04-25 to 2026-04-26.** The architecture underwent its most significant redesign: the monolithic 554-line agent prompt was replaced by a thin **firmware scheduler** (~35 lines) backed by a dual FSM (main + per-APE). Key innovations:

- **`iq fsm state --json`** — structured output for agent consumption
- **`iq ape prompt --name <name>`** — sub-agent prompts assembled from YAML + state
- **`completion_authority`** — per-state field that tells the scheduler whether to ask the user or transition automatically
- **Dispatch model** — the scheduler never performs sub-agent work; it delegates via the `agent` tool

The design principle: **the CLI is the algorithm, the LLM is just the executor**. Version **v0.2.0** landed with the redesign, followed immediately by **v0.2.1** with smoke-test fixes.

## What emerged

The system I built to solve a communication problem — AI assumes things, misinterprets words, acts without authorization — turned out to be something larger. Inquiry forces clarity *before* AI acts. The analysis phase eliminates ambiguity. The plan phase makes the solution explicit. By the time execution starts, the problem is already solved — whether a human or an AI writes the code doesn't change the result.

The unexpected discovery: I recognize the code the AI produces as my own. Not because I wrote it, but because I designed it. Every decision was made during analysis and planning. The AI implemented *my* design, following *my* conventions, under *my* constraints. The methodology doesn't replace the engineer — it amplifies them.

Inquiry is, at its core, a thinking tool. The oldest kind there is.

---

*For the philosophical foundations, see [Philo SophIA](https://github.com/ccisnedev/philo_sophia). For the technical architecture, see [`docs/architecture.md`](architecture.md). For the lore, see [`docs/lore.md`](lore.md).*
