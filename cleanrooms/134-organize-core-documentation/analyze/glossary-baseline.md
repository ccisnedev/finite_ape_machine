---
id: glossary-baseline
title: "Baseline glossary for issue #134"
date: 2026-04-22
status: active
tags: [glossary, definitions, terminology, inquiry, ape]
author: socrates
---

# Baseline Glossary for Issue #134

## Abstract

This glossary is the first-pass lexical control instrument for issue #134. It is not a full encyclopedia and does not yet settle every downstream documentation decision. Its purpose is narrower: provide clear, independent definitions for the core terms whose boundaries must remain stable while documentation canonicity is reorganized. The entries below are intentionally concise and neutral. They answer what the term is in current project vocabulary without trying to absorb all historical, comparative, or implementation detail. [1][2][3][4][5]

## Terms

| Term | Baseline definition | Primary evidence surfaces |
|---|---|---|
| Inquiry | The structured cycle by which a software task is clarified, planned, and executed as an instance of inquiry. | `docs/research/inquiry/`; `taxonomy-and-scope-clarification.md` |
| APE | The orchestrating methodology and scheduler that assigns specialized agent behavior to the phases of the Inquiry cycle. | `docs/architecture.md`; `docs/spec/agent-lifecycle.md`; `docs/lore.md` |
| Finite APE Machine | The engineered realization of APE as a finite-state, signal-driven control system for running an Inquiry cycle. | `docs/spec/cooperative-multitasking-model.md`; `docs/spec/signal-based-coordination.md`; `docs/architecture.md` |
| Thinking Tools | The reusable reasoning methods or working disciplines employed within phases or embodied by agents. | `docs/lore.md`; `taxonomy-and-scope-clarification.md` |
| FSM | A finite state machine: a model in which the system occupies one state at a time and changes state through declared transitions. | `docs/spec/cooperative-multitasking-model.md`; `docs/architecture.md` |
| RTOS | Real-time operating system; in current project vocabulary, an analogical frame for signal-based coordination, scheduling, and event handling rather than a claim that Inquiry is literally an OS kernel. | `docs/spec/signal-based-coordination.md`; `docs/architecture.md` |

## Notes on Use

These definitions are first-pass controls, not final doctrinal prose. They should be used to evaluate canonicity, duplication, and drift across the documentation set. When a later document appears to define one of these terms differently, the disagreement should be examined explicitly rather than absorbed silently into broader narrative text. [1][2][3]

## References

[1] Finite APE Machine repository. "Taxonomy and scope clarification for issue #134." `cleanrooms/134-organize-core-documentation/analyze/taxonomy-and-scope-clarification.md`.

[2] Finite APE Machine repository. "Expansion triggers, initial-pass inclusion of architecture and lore, and independent glossary definitions for issue #134." `cleanrooms/134-organize-core-documentation/analyze/expansion-triggers-and-independent-glossary-definitions.md`.

[3] Finite APE Machine repository. "Diagnosis for issue #134: justified documentation status map and canonical-home recommendations." `cleanrooms/134-organize-core-documentation/analyze/diagnosis.md`.

[4] Finite APE Machine repository. "Inquiry as Epistemic Foundation of APE." `docs/research/inquiry/index.md`; "Architecture." `docs/architecture.md`; "The Apes — Lore." `docs/lore.md`.

[5] Finite APE Machine repository. "Cooperative multitasking model — two-level FSM architecture." `docs/spec/cooperative-multitasking-model.md`; "Signal-based coordination — RTOS event model for agent communication." `docs/spec/signal-based-coordination.md`.