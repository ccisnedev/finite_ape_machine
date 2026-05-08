---
id: diagnosis
title: "Diagnosis — Issue #177: Rebuild IDLE Around Dewey"
date: 2026-05-07
status: final
tags: [diagnosis, idle, dewey, runtime, operator, architecture]
author: socrates
---

# Diagnosis

## Problem defined

Issue #177 is not diagnosing a mismatch between Deweyan inquiry and the repository's intended IDLE mission. That mission is already largely stable across user intent, state-level instructions, and supporting process assets. The actual contradiction is narrower and more architectural: the declared model says IDLE is bounded issue triage with externalized handoff, while the runtime still hardcodes a sub-agent named socrates-idle as the active operator for that state.

This produces two incompatible truths at once. On one side, IDLE is described as a phase that only clarifies, creates, confirms, or comments on issues and does not know downstream phases. On the other, the CLI control plane auto-activates a specific IDLE ape and exposes that operator through prompt resolution, state reporting, doctor checks, and tests. The issue therefore concerns operator binding and system contract coherence, not the philosophical legitimacy of Deweyan IDLE.

## Decisions taken with justification

### D1. Treat the mission of IDLE as already confirmed, not as open design space

The evidence supports a consistent mission boundary: IDLE exists to move from an indeterminate situation to a well-formed issue, possibly by confirming an existing issue and adding clarifying comments. The user states this explicitly. The state instructions in code/cli/assets/fsm/states/idle.yaml enforce the same boundary by allowing issue work and forbidding root-cause analysis, solution proposals, and branch preparation. The existing issue-start skill also assumes that infrastructure setup and transition to ANALYZE happen after issue selection, not inside IDLE itself.

Because that mission is already coherent, the redesign should not spend its force redefining what IDLE is for. It should preserve the bounded Deweyan role and focus on the remaining contradiction.

### D2. Diagnose the core defect as runtime/operator inconsistency

The current runtime binds IDLE to socrates-idle in multiple truth surfaces. code/cli/lib/modules/fsm/effect_executor.dart auto-activates socrates-idle when entering IDLE. code/cli/lib/modules/ape/commands/prompt.dart only recognizes socrates-idle as the valid ape for IDLE. Existing confirmed findings also record parallel exposure through state reporting, doctor validation, and tests.

This means the live system does not implement a neutral or merely declarative IDLE. It implements an explicit operator choice. Since the user's target says the IDLE operator should be named dewey and should remain ignorant of ANALYZE, PLAN, and EXECUTE, issue #177 must be framed as a runtime contract reconciliation: either remove the dedicated runtime binding in favor of truly direct IDLE operation, or replace the hardcoded socrates-idle contract with dewey while preserving the same bounded mission and external handoff. In either case, the problem is the binding layer.

### D3. Preserve externalized handoff as a non-negotiable constraint

The user states that a separate skill like issue-start must perform the explicit handoff from IDLE to ANALYZE. The repository already supports this separation. code/cli/assets/skills/issue-start/SKILL.md performs issue verification or creation, branch setup, cleanroom setup, and the transition command. code/cli/assets/fsm/transition_contract.yaml confirms that IDLE does not directly jump into later work: it may start analysis through the FSM contract or remain blocked, but it cannot approve plans, finish execution, or skip ahead.

That means the redesign should not move transition knowledge back into IDLE. The correct architectural posture is to keep IDLE mission-bound and let the protocol own explicit advancement.

## Constraints and risks identified

## Constraints

- The redesign must remain coherent with the current model rather than replacing the model wholesale.
- IDLE must stay encapsulated: it cannot know that ANALYZE, PLAN, or EXECUTE exist as destinations.
- IDLE must remain limited to issue creation, issue confirmation, and clarifying comments.
- The explicit handoff out of IDLE must stay externalized in a skill/protocol layer rather than being embedded as IDLE behavior.
- Any operator change must account for all runtime truth surfaces, not just the ape YAML asset.

## Risks

- A prompt-only rename would leave the hardcoded runtime contract intact and preserve the contradiction.
- A partial runtime rename would create a second inconsistency if effect execution, prompt resolution, doctor checks, state reporting, build assets, and tests are not updated together.
- Reframing #177 as a mission rewrite would broaden scope unnecessarily and risk destabilizing behavior that is already aligned.
- If the repository keeps documenting APE-direct IDLE while executing socrates-idle, contributors will continue to receive conflicting explanations of the same state.

## Scope

In scope for diagnosis: identifying what contradiction actually exists, what is already coherent, and what architectural decision #177 must force. This includes the relation among user intent, state instructions, issue-start protocol, transition contract, and runtime ape binding.

Out of scope for diagnosis: selecting the final implementation strategy between a truly direct IDLE and a renamed dedicated operator, enumerating every file change needed for implementation, or rewriting the larger APE philosophy. Those are planning concerns that follow from this diagnosis.

## References

- cleanrooms/177-rebuild-idle-around-dewey/analyze/confirmed.md
- cleanrooms/177-rebuild-idle-around-dewey/analyze/idle-perspectives-contrast.md
- cleanrooms/177-rebuild-idle-around-dewey/analyze/idle-operator-implications.md
- code/cli/assets/fsm/states/idle.yaml
- code/cli/assets/skills/issue-start/SKILL.md
- code/cli/assets/fsm/transition_contract.yaml
- code/cli/assets/apes/socrates-idle.yaml
- code/cli/lib/modules/fsm/effect_executor.dart
- code/cli/lib/modules/ape/commands/prompt.dart
- code/cli/assets/agents/inquiry.agent.md
- docs/architecture.md