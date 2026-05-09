---
id: confirmed
title: "Confirmed findings"
date: 2026-05-09
status: active
tags: [findings, confirmed]
author: socrates
---

# Confirmed Findings

> Living document. Update as findings are confirmed, revised, or invalidated.
> Format: ## F<N>: <title> — CONFIRMED|REVISED|INVALIDATED

## F1: Named sub-agents are architecturally defined as thinking tools, not as the scheduler or phase runtime — CONFIRMED

The repository's canonical architecture already distinguishes the named operators from the orchestrating system. Thinking Tools are described as reusable reasoning methods that are dispatched through phases, while Inquiry, APE, and the Finite APE Machine are explicitly described as the cycle, scheduler, and state machine rather than thinking tools.

Evidence:
- docs/thinking-tools.md defines Thinking Tools as intellectual instruments used inside the cycle, not the cycle or scheduler.
- docs/spec/cooperative-multitasking-model.md states that the FSM has no intelligence and that sub-agents are launched with clean context and a phase-specific prompt.
- code/cli/assets/agents/inquiry.agent.md describes Inquiry as the scheduler that dispatches sub-agents as thinking tools.

## F2: The live CLI prompt composition currently combines APE-authored prompt text with injected runtime context, but the APE YAML still carries substantial operational content — CONFIRMED

The runtime assembles the effective prompt by concatenating the APE base prompt, the active APE sub-state prompt, and an optional inquiry-context block. Because the current composition path does not inject FSM mission text into the APE prompt, operational responsibilities, artifacts, and guardrails are currently encoded inside the APE YAML itself.

Evidence:
- code/cli/lib/modules/ape/ape_definition.dart assembles prompts as basePrompt + state.prompt + inquiry-context.
- code/cli/lib/modules/ape/commands/prompt.dart resolves operational context such as output_dir, confirmed_doc, analysis_input, plan_file, and allowed command surfaces before assembly.

## F3: The responsibility mix is systemic across current APE YAMLs; DEWEY only partially approximates the intended separation — CONFIRMED

SOCRATES, DESCARTES, BASHO, and DARWIN all embed concrete deliverables, repository artifacts, or command surfaces directly in their YAML definitions. DEWEY is the closest partial approximation because the create_or_select sub-state can consume injected triage objective, deterministic skill, and allowed command surface, but DEWEY still embeds issue-triage workflow and command examples in its own YAML.

Evidence:
- code/cli/assets/apes/socrates.yaml embeds diagnosis.md and documentation protocol details.
- code/cli/assets/apes/descartes.yaml embeds analysis_input and plan output semantics.
- code/cli/assets/apes/basho.yaml embeds plan.md, retrospective.md, commit behavior, and validation reporting.
- code/cli/assets/apes/darwin.yaml embeds gh issue commands, .inquiry paths, and metrics.yaml generation rules.

## F4: The intended separation already assumes FSM state files, not APE YAMLs, are the natural home for phase mission and contract — CONFIRMED

The repository already stores phase instructions, constraints, and allowed actions in FSM state assets, and the scheduler firmware treats state `instructions` as authoritative. At the same time, the live APE prompt assembler does not yet deliver that state contract to sub-agents; it only assembles APE-authored prompt text and a narrow inquiry-context block. This confirms that issue #154 is not merely subtractive: removing operational content from APE YAMLs will require a richer runtime delivery layer for the phase contract.

Evidence:
- code/cli/assets/fsm/states/analyze.yaml defines ANALYZE instructions, constraints, and allowed actions.
- code/cli/assets/fsm/states/evolution.yaml defines EVOLUTION instructions, constraints, and allowed actions.
- code/cli/assets/agents/inquiry.agent.md instructs the scheduler to read FSM `instructions` and operate from them.
- code/cli/lib/modules/ape/commands/prompt.dart resolves only a limited context map before prompt assembly.
- code/cli/lib/modules/ape/ape_definition.dart assembles prompts as APE base prompt + APE sub-state prompt + inquiry-context.

## F5: DARWIN's valid exception depends on separating abstract process knowledge from concrete repository procedure — CONFIRMED

DARWIN's legitimate role is to evaluate a completed cycle against an ideal process, which makes some abstract process awareness acceptable. But the current DARWIN YAML mixes that evaluative identity with concrete repository-specific commands and `.inquiry` file mechanics. This confirms that the Darwin nuance is real: the refactor must preserve abstract methodology knowledge while externalizing command surfaces, folder paths, and implementation-specific procedures.

Evidence:
- code/cli/assets/fsm/states/evolution.yaml describes EVOLUTION as a generic evaluation and improvement mission.
- code/cli/assets/apes/darwin.yaml embeds concrete `gh issue` commands and `.inquiry/metrics.yaml` generation rules.

## F6: Backwards-compatible separation requires additive prompt delivery, not immediate prompt subtraction — CONFIRMED

Because the current prompt runtime assembles only the APE base prompt, active sub-state prompt, and a narrow inquiry-context block, live agent behavior still depends on operational text embedded in the APE YAMLs. Removing that text before a replacement operational layer is delivered would create an immediate behavior regression. This confirms that issue #154 must preserve effective prompt semantics during migration rather than treating YAML cleanup as behavior-neutral.

Evidence:
- code/cli/lib/modules/ape/ape_definition.dart assembles prompts as basePrompt + state.prompt + inquiry-context.
- code/cli/lib/modules/ape/commands/prompt.dart injects only a limited context map for current APEs.
- code/cli/assets/apes/socrates.yaml, code/cli/assets/apes/descartes.yaml, code/cli/assets/apes/basho.yaml, and code/cli/assets/apes/darwin.yaml still embed operational instructions that affect live behavior.

## F7: The analysis is now asking the right architectural question for planning — CONFIRMED

The investigation no longer needs to ask whether Inquiry conceptually distinguishes thinking-tool identity from operational runtime. That distinction already exists in doctrine and in parts of the implementation. The right planning question is now how Inquiry CLI should deliver the phase contract at prompt-assembly time so that named APE YAMLs can contract toward identity and sub-state modulation while preserving current behavior and inspectability.

Evidence:
- cleanrooms/154-separate-thinking-tool-identity-from-operational-c/analyze/evidence-inventory.md shows that doctrine, FSM state assets, and prompt assembly already exist as distinct runtime surfaces.
- cleanrooms/154-separate-thinking-tool-identity-from-operational-c/analyze/implications-and-consequences.md shows that the necessary change is an additive prompt-delivery refactor rather than prose cleanup.
- code/cli/lib/modules/ape/commands/prompt.dart and code/cli/lib/modules/ape/ape_definition.dart show that the remaining defect sits at prompt delivery and ownership, not at the existence of a composition mechanism.
