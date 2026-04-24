---
id: finite-ape-machine
title: "Finite APE Machine — current technical overview"
date: 2026-04-22
status: active
tags: [architecture, fsm, scheduler, inquiry, rtos]
author: descartes
---

# Finite APE Machine

## Overview

Finite APE Machine is the engineered realization of the Inquiry methodology as a finite-state, signal-aware control system for software work. Inquiry names the cycle-level process. APE names the orchestrating methodology and scheduler. Finite APE Machine names the technical system that operationalizes that methodology through explicit states, governed transitions, artifacts, and phase-specific agent behavior. [1][2][3]

The point of the system is not to multiply agents indefinitely. It is to make responsibility, transition conditions, and outputs explicit enough that AI-assisted work becomes inspectable and reproducible instead of improvisational. [1][4]

## Current Cycle Model

The current operational model is a six-state cycle with an optional evolutionary pass:

```
IDLE → ANALYZE → PLAN → EXECUTE → END → EVOLUTION → IDLE
```

If evolution is disabled in `.inquiry/config.yaml`, the cycle returns directly from END to IDLE after PR creation and merge preparation. [2][5]

| State | Operator | Purpose | Primary artifact |
|---|---|---|---|
| IDLE | APE | Triage, readiness, and infrastructure preparation | `.inquiry/state.yaml` |
| ANALYZE | SOCRATES | Clarify the problem and produce a rigorous diagnosis | `cleanrooms/<issue>/analyze/diagnosis.md` |
| PLAN | DESCARTES | Design the execution sequence and verification strategy | `cleanrooms/<issue>/plan.md` |
| EXECUTE | BASHO | Implement phase by phase under the plan's constraints | code + commits |
| END | APE + human gate | Create and merge the PR through an explicit closure gate | PR |
| EVOLUTION | DARWIN | Propose improvements to the framework itself | issues/comments in the Inquiry repository |

## Architectural Principles

### APE is the scheduler, not one ape among others

APE is not a peer agent in the roster. It is the orchestrating methodology and dispatch layer that reads state, checks transition conditions, and invokes the appropriate phase behavior. In current repository vocabulary, this is the scheduler/event-loop role. [2][4][5]

### One primary sub-agent per active phase

The current system uses one primary sub-agent per active work phase:

- SOCRATES in ANALYZE
- DESCARTES in PLAN
- BASHO in EXECUTE
- DARWIN in EVOLUTION

IDLE and END are orchestration-heavy states governed directly by APE plus explicit human authorization. Earlier multi-agent rosters remain historically relevant, but they are not the active architectural model. Their documentary home is [../lore.md](../lore.md), not this specification. [4][6]

### Transitions are explicit and CLI-governed

The machine does not rely on implicit conversational drift to change phases. Transitions are checked against a declared contract and executed through the CLI, which is responsible for validating preconditions, applying effects, and updating persisted state. This makes the finite-state structure operational rather than metaphorical. [2][5]

### Artifacts are the coordination surface

The system coordinates through persisted artifacts rather than agent-to-agent hidden memory. At minimum, the cycle relies on:

- `.inquiry/state.yaml` for current phase and task identity
- `.inquiry/config.yaml` for cycle options such as evolution enablement
- `.inquiry/mutations.md` for human observations relevant to DARWIN
- `cleanrooms/<issue>/analyze/diagnosis.md` as the contract between ANALYZE and PLAN
- `cleanrooms/<issue>/plan.md` as the contract between PLAN and EXECUTE

This keeps the orchestration inspectable from the repository itself. [2][5][7]

### RTOS analogy: signal-aware coordination, not literal operating-system identity

Finite APE Machine borrows the RTOS analogy to explain scheduling, waiting, event signaling, and task dispatch. The analogy is architectural, not literal: the system behaves like a scheduler with event-driven coordination, but it is not an operating-system kernel. [3][5]

## Collaboration Model

Finite APE Machine structures collaboration across three recurring perspectives:

| Perspective | Acronym | Dominant states | Practical meaning |
|---|---|---|---|
| Agent-Aided Design | AAD | ANALYZE | Human intention is clarified with AI assistance |
| Agent-Aided Engineering | AAE | PLAN | The work is decomposed, verified, and ordered |
| Agent-Aided Manufacturing | AAM | EXECUTE + END | The approved plan is carried into implementation and delivery |

DARWIN operates after delivery as the meta-learning layer that evaluates the cycle itself instead of the product alone. [1][2]

## Relationship to Supporting Specifications

This document is the primary technical overview of the current finite-state system. Supporting documents elaborate particular aspects of that overview:

- [agent-lifecycle.md](agent-lifecycle.md) defines the current agent registry and state responsibilities.
- [cooperative-multitasking-model.md](cooperative-multitasking-model.md) explains the scheduler/task analogy and two-level FSM model.
- [signal-based-coordination.md](signal-based-coordination.md) explains event and signal routing.
- [../architecture.md](../architecture.md) explains the end-to-end system at repository scale.
- [../research/inquiry/index.md](../research/inquiry/index.md) provides the philosophical home of Inquiry, which this machine operationalizes.

## Historical Boundary

Earlier repository documents described a larger and more granular roster including MARCOPOLO, VITRUVIUS, SUNZI, GATSBY, ADA, DIJKSTRA, BORGES, and HERMES as active architectural roles. That material remains valuable as historical or referential context, but it should not be read as the current active model of the Finite APE Machine. The current model is the sharper scheduler-plus-phase-agent structure described above. [4][6]

## References

[1] Finite APE Machine repository. "Inquiry as Epistemic Foundation of APE." `docs/research/inquiry/index.md`.

[2] Finite APE Machine repository. "Architecture." `docs/architecture.md`.

[3] Finite APE Machine repository. "Signal-based coordination — RTOS event model for agent communication." `docs/spec/signal-based-coordination.md`.

[4] Finite APE Machine repository. "Agent lifecycle — six-state model and confirmed agent registry." `docs/spec/agent-lifecycle.md`.

[5] Finite APE Machine repository. "Cooperative multitasking model — two-level FSM architecture." `docs/spec/cooperative-multitasking-model.md`.

[6] Finite APE Machine repository. "The Apes — Lore." `docs/lore.md`.

[7] Finite APE Machine repository. "Diagnosis for issue #134: justified documentation status map and canonical-home recommendations." `cleanrooms/134-organize-core-documentation/analyze/diagnosis.md`.
