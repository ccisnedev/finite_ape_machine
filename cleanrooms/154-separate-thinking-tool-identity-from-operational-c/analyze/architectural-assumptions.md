---
id: architectural-assumptions
title: Surfaced assumptions behind the identity and operational split
date: 2026-05-09
status: active
tags: [assumptions, architecture, prompts]
author: socrates
---

# Assumptions Surfaced

This note records the hidden assumptions beneath the current framing for issue #154 after the clarification pass.

## A1: FSM state contracts can become the operational prompt layer

The current framing assumes the phase mission and operational contract can live outside the named APE YAMLs because those contracts already exist in FSM state assets. However, the live prompt assembler still delivers only APE-authored prompt text plus an inquiry-context block.

Why this matters:
- Removing operational text from APE YAMLs is not sufficient by itself.
- Some richer runtime carrier must deliver state instructions, constraints, and allowed actions to the sub-agent.

Evidence:
- code/cli/assets/fsm/states/analyze.yaml stores instructions, constraints, and allowed actions for ANALYZE.
- code/cli/assets/fsm/states/evolution.yaml does the same for EVOLUTION.
- code/cli/assets/agents/inquiry.agent.md treats FSM `instructions` as authoritative scheduler input.
- code/cli/lib/modules/ape/commands/prompt.dart currently resolves only a narrow context map before assembly.
- code/cli/lib/modules/ape/ape_definition.dart assembles prompts as base prompt + APE sub-state prompt + inquiry-context.

## A2: Thinking-tool identity remains coherent after artifact and command text is removed

The intended split assumes each named APE still has a stable cognitive core after repository-specific outputs, paths, and command surfaces are stripped away. That assumption is plausible in the repository doctrine, but the current APE YAMLs have not yet been factored enough to prove it mechanically.

Why this matters:
- The refactor must preserve method-specific mindset and questioning style.
- It should move only the phase contract, not hollow out the thinking tool itself.

## A3: DARWIN needs abstract process knowledge, not concrete repository procedure

The clarified DARWIN nuance depends on a narrower exception than the other APEs. DARWIN appears to need a model of the ideal process in order to compare an actual cycle against it, but that does not imply that DARWIN should own repository-specific commands, folder paths, or file-writing rules.

Why this matters:
- If there is no abstract process representation outside the YAML, DARWIN will keep reabsorbing operational detail.
- The real boundary is between methodology knowledge and implementation-specific procedure, not between process awareness and total ignorance.

Evidence:
- code/cli/assets/fsm/states/evolution.yaml expresses EVOLUTION as a generic evaluation mission.
- code/cli/assets/apes/darwin.yaml mixes that evaluation role with concrete `gh issue` commands and `.inquiry/metrics.yaml` mechanics.

## A4: Inquiry CLI prompt engineering is a first-class architectural surface

The current framing assumes prompt composition in Inquiry CLI is part of the architecture, not incidental glue. If that assumption is false, externalizing operational context into CLI-owned prompt layers would itself become a layering violation.

Why this matters:
- Issue #154 is not just a YAML cleanup.
- The prompt-composition boundary becomes a place that needs explicit contracts, documentation, and tests.

# Conclusion From This Pass

The clarified architecture is internally coherent, but it depends on delivery assumptions that are not yet fully materialized in the runtime. The most important hidden premise is that Inquiry CLI will become the place where FSM mission text, operational contract, and APE identity are recomposed cleanly at dispatch time.