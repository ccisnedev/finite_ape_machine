---
id: diagnosis
title: "Diagnosis — Issue #154: Separate thinking-tool identity from operational contract"
date: 2026-05-09
status: final
tags: [diagnosis, prompts, architecture, thinking-tools, runtime]
author: socrates
---

# Diagnosis

## Problem defined

Issue #154 is no longer diagnosing whether Inquiry lacks any separation between thinking-tool identity and runtime procedure. The repository already has meaningful partial separation: the canonical documentation describes named sub-agents as thinking tools, FSM state assets already carry phase mission and contract text, and Inquiry CLI already assembles prompts through a dedicated runtime surface.

The live contradiction is narrower and more architectural. Named APEs are supposed to encode method, stance, and sub-state modulation, but the effective prompt still depends on APE YAML prose to carry phase mission details, artifact contracts, command surfaces, and documentation protocol. The right diagnosis question is therefore not "how do we rewrite the agent prose?" but "how should Inquiry deliver the operational contract at prompt assembly time so that APE YAMLs can contract toward thinking-tool identity without changing behavior?"

## Decisions taken with justification

### D1. Treat the core defect as prompt-delivery ownership, not as missing architectural surfaces

The evidence does not support a theory that Inquiry needs an entirely new architectural concept in order to separate identity from operation. The repository already exposes three relevant surfaces: doctrine that defines named APEs as thinking tools, FSM state assets that describe phase mission and constraints, and a runtime prompt assembler that composes the effective prompt. What remains misallocated is ownership of operational contract inside APE-authored prose.

### D2. Preserve the boundary: FSM states own phase mission, APE YAMLs own thinking-tool identity, Inquiry CLI owns composition

The repository's own doctrine already points to this boundary, and the current runtime partially implements it. Planning should therefore preserve, not replace, that division of responsibility. Phase mission, allowed actions, and operational contract should not remain primarily embedded in named APE YAMLs. By the same logic, the refactor should not hollow out APE prompts into generic shells; their legitimate responsibility is to preserve cognitive identity, method, tone, and sub-state modulation.

### D3. Make the migration additive first, because current behavior still depends on operational prose in APE YAMLs

The effective prompt currently consists of APE base prompt, active sub-state prompt, and a narrow inquiry-context block. That means live behavior still depends on operational material embedded in SOCRATES, DESCARTES, BASHO, DEWEY, and DARWIN YAMLs today. Planning must therefore introduce a replacement operational-contract layer before trimming APE prose. Otherwise the repository would ship a prompt regression disguised as architecture cleanup.

### D4. Keep the assembled prompt inspectable as a first-class contract

Once operational ownership moves further into Inquiry CLI, the assembled prompt becomes the critical debugging and trust surface. The architecture should continue to expose the exact effective prompt through iq ape prompt or an equivalent surface. If prompt composition becomes hidden runtime glue, the refactor would solve one layering problem by creating another.

### D5. Constrain DARWIN to an abstract-process exception, not a repository-procedure exception

DARWIN is the only named APE with a plausible need for ideal-process knowledge, because it evaluates actual cycles against an abstract standard. That nuance is legitimate but narrow. It does not justify concrete ownership of repository-specific gh issue procedures, .inquiry file mechanics, or metrics-generation rules. Planning should preserve methodology knowledge while externalizing implementation-specific procedure.

### D6. Leave carrier-shape selection to planning without reopening the diagnosis

The diagnosis does not need to decide whether the replacement operational layer is delivered as raw FSM instruction text, normalized injected fields, or a hybrid composition model. That is a planning concern. What is now fixed is the boundary any implementation must preserve: no duplicate operational ownership across FSM and APE layers, no hidden prompt glue, and no behavior regression during migration.

## Constraints and risks identified

## Constraints

- Preserve current effective behavior during migration.
- Keep the final assembled prompt inspectable.
- Avoid duplicating responsibility across FSM state assets, CLI composition, and APE YAMLs.
- Preserve the legible thinking-tool identity of each named APE after separation.
- Treat DARWIN's exception, if any, as abstract methodology knowledge only.

## Risks

- A subtractive YAML cleanup would remove live operational constraints before a replacement layer exists.
- A CLI-owned operational layer could become opaque if not surfaced explicitly in assembled prompt output and documentation.
- Partial refactoring across only some APEs would leave the architecture in a mixed and unstable state.
- Injecting operational material without prompt discipline could preserve ownership but degrade prompt quality.
- Leaving no abstract process surface outside DARWIN would encourage exception creep back into the DARWIN YAML.

## Scope

In scope for this diagnosis: identifying the true defect in the current architecture, fixing the ownership boundary conceptually, and defining the constraints any implementation plan must satisfy.

Out of scope for this diagnosis: selecting the final runtime carrier format, enumerating file-by-file implementation edits, or drafting the concrete migration sequence. Those belong to planning, provided the chosen plan preserves single ownership of operational contract, prompt inspectability, and materially equivalent behavior.

## References

- cleanrooms/154-separate-thinking-tool-identity-from-operational-c/analyze/confirmed.md
- cleanrooms/154-separate-thinking-tool-identity-from-operational-c/analyze/identity-vs-operational-boundary.md
- cleanrooms/154-separate-thinking-tool-identity-from-operational-c/analyze/architectural-assumptions.md
- cleanrooms/154-separate-thinking-tool-identity-from-operational-c/analyze/evidence-inventory.md
- cleanrooms/154-separate-thinking-tool-identity-from-operational-c/analyze/perspectives-and-objections.md
- cleanrooms/154-separate-thinking-tool-identity-from-operational-c/analyze/implications-and-consequences.md
- code/cli/lib/modules/ape/ape_definition.dart
- code/cli/lib/modules/ape/commands/prompt.dart
- code/cli/assets/fsm/states/analyze.yaml
- code/cli/assets/fsm/states/evolution.yaml
- code/cli/assets/apes/socrates.yaml
- code/cli/assets/apes/descartes.yaml
- code/cli/assets/apes/basho.yaml
- code/cli/assets/apes/dewey.yaml
- code/cli/assets/apes/darwin.yaml