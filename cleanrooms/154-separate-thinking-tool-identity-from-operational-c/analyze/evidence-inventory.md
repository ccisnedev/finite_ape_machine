---
id: evidence-inventory
title: Evidence inventory for identity vs operational separation
date: 2026-05-09
status: active
tags: [evidence, architecture, prompts]
author: socrates
---

# Evidence Inventory

This note consolidates concrete code, runtime, and documentation evidence for issue #154 during the SOCRATES `evidence` sub-phase.

# Evidence That The System Already Respects Part Of The Boundary

## 1. Named sub-agents are documented as thinking tools, not as the scheduler

The repository's canonical documentation already separates cognitive identity from orchestration.

- [docs/thinking-tools.md](docs/thinking-tools.md) defines Thinking Tools as reusable reasoning methods used inside the Inquiry cycle rather than the cycle, methodology, or finite-state system itself.
- [docs/spec/cooperative-multitasking-model.md](docs/spec/cooperative-multitasking-model.md) describes the outer FSM as a scheduler with no intelligence and the sub-agents as phase-specific tasks launched with clean context.
- [docs/spec/agent-lifecycle.md](docs/spec/agent-lifecycle.md) assigns each phase a thinking tool while keeping APE as the scheduler and closure gate.

## 2. FSM mission text already lives in a distinct asset family and is exposed separately at runtime

The phase mission and contract are already modeled outside the APE YAMLs.

- [code/cli/assets/fsm/states/analyze.yaml](code/cli/assets/fsm/states/analyze.yaml) stores ANALYZE `instructions`, `constraints`, and `allowed_actions`.
- [code/cli/lib/modules/fsm/commands/state.dart](code/cli/lib/modules/fsm/commands/state.dart) reads `instructions` from `assets/fsm/states/<state>.yaml` and returns them in `FsmStateOutput`.
- Live runtime observation from this pass confirms the split delivery surface: `iq fsm state --json` returned `state: ANALYZE`, `ape.name: socrates`, `ape.state: evidence`, and a distinct `instructions` field sourced from the FSM state.

## 3. The APE prompt assembler is already a separate composition surface

The current prompt runtime does not simply dump the FSM state YAML into the APE YAML. It has an explicit prompt-composition boundary.

- [code/cli/lib/modules/ape/ape_definition.dart](code/cli/lib/modules/ape/ape_definition.dart) assembles prompts as APE `basePrompt` plus sub-state `prompt`, then optionally appends an `inquiry-context` block.
- [code/cli/lib/modules/ape/commands/prompt.dart](code/cli/lib/modules/ape/commands/prompt.dart) resolves only a narrow context map such as `output_dir`, `confirmed_doc`, `analysis_input`, `plan_file`, or selected command surfaces before calling `assemblePrompt`.
- Live runtime observation from this pass confirms the behavior: `iq ape prompt --name socrates` produced SOCRATES base prompt, the `evidence` sub-state prompt, and the active `inquiry-context` block for the cleanroom analyze directory.

# Evidence That The Current System Violates The Intended Boundary

## 1. SOCRATES still embeds analyze deliverables and documentation protocol in the APE YAML

The SOCRATES YAML still carries operational material that belongs to phase contract or runtime composition rather than to Socratic identity alone.

- [code/cli/assets/apes/socrates.yaml](code/cli/assets/apes/socrates.yaml) requires `diagnosis.md` as the final deliverable.
- The same file embeds mandatory `confirmed.md` update rules, output-directory rules, and index-maintenance protocol.

## 2. DESCARTES still embeds artifact-path semantics and output contract

DESCARTES still mixes planning method with repository-specific plan wiring.

- [code/cli/assets/apes/descartes.yaml](code/cli/assets/apes/descartes.yaml) defines `analysis_input` as a path from inquiry-context and directs output to `plan_file`.
- The same file dictates immutable `plan.md` structure, commit-line requirements, and final-phase release obligations.

## 3. BASHO still embeds execution workflow, reporting rules, and artifact expectations

BASHO is not limited to implementation craft; it also owns operational reporting details.

- [code/cli/assets/apes/basho.yaml](code/cli/assets/apes/basho.yaml) frames input as the current phase from `plan.md`.
- The same file requires test/lint/build execution, validation reporting, retrospective production, and commit behavior.

## 4. DARWIN still embeds repository-specific commands and file procedures

DARWIN is the clearest example of process evaluation being mixed with concrete repository mechanics.

- [code/cli/assets/apes/darwin.yaml](code/cli/assets/apes/darwin.yaml) hardcodes `gh issue` command examples against the Inquiry repository.
- The same file specifies `.inquiry/metrics.yaml` generation rules and concrete field derivations from repository artifacts.

## 5. DEWEY only partially approximates the target separation

DEWEY shows the beginnings of the intended pattern, but it has not completed the separation.

- [code/cli/lib/modules/ape/commands/prompt.dart](code/cli/lib/modules/ape/commands/prompt.dart) injects IDLE create-or-select context dynamically as `triage_objective`, `deterministic_skill`, and `allowed_commands`.
- [code/cli/assets/apes/dewey.yaml](code/cli/assets/apes/dewey.yaml) still embeds deduplication workflow, issue-readiness semantics, and direct `gh issue list --search` usage guidance.

# Synthesis

The evidence does not support a claim that the repository lacks separation mechanisms altogether. It already has three distinct architectural surfaces:

1. canonical documentation that distinguishes thinking-tool identity from scheduler/runtime role,
2. FSM state assets that carry phase mission text, and
3. CLI prompt composition that can inject runtime context at dispatch time.

The current violation is narrower and more concrete: most APE YAMLs still contain phase contract, artifact contract, and repository procedure that should be owned by FSM state assets or CLI prompt composition. Issue #154 therefore concerns relocating operational contract out of APE-authored identity text, not inventing separation from scratch.