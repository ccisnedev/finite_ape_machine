---
id: idle-perspectives-contrast
title: "Perspective contrast: user concept, declared IDLE architecture, and runtime binding"
date: 2026-05-07
status: active
tags: [idle, dewey, perspectives, architecture, runtime]
author: socrates
---

# Question

What contrast is actually at stake between the user's Deweyan target for IDLE, the declared architecture/specs, and the current runtime?

# Perspectives

## 1. User conceptual perspective

The user's target model is narrow and mission-bound. In IDLE, dewey should only help formulate or confirm an issue and may add comments when that clarifies scope or preserves context. IDLE must not know ANALYZE, PLAN, or EXECUTE as downstream destinations, and the handoff out of IDLE belongs to issue-start rather than to IDLE itself.

This perspective treats IDLE as inquiry before commitment: the problem is still being determined, and the output is an issue boundary, not a diagnosis, plan, or code change.

## 2. Current declared architecture/spec perspective

The declared specs largely agree with that conceptual model. docs/spec/cooperative-multitasking-model.md says IDLE uses APE directly with a triage skill and explicitly says there is no sub-agent in IDLE. docs/spec/agent-lifecycle.md repeats that IDLE is APE's default state, that triage decides whether formal inquiry is warranted, and that infrastructure preparation plus the transition to ANALYZE happen through the protocol rather than through an IDLE sub-agent.

The state contract in code/cli/assets/fsm/states/idle.yaml is also consistent with this scope. IDLE is defined as triage and issue formulation, with allowed actions limited to issue work, conversation, read-only search, and doctor checks. Root-cause analysis, solution proposals, and branch preparation are explicitly excluded.

## 3. Current runtime and implementation perspective

The runtime still encodes a different operator model even though its mission text remains Deweyan. code/cli/lib/modules/fsm/effect_executor.dart auto-activates socrates-idle when the FSM enters IDLE, and code/cli/lib/modules/ape/commands/prompt.dart only recognizes socrates-idle as the active IDLE ape. The runtime therefore does not implement "APE direct + triage skill"; it implements "IDLE sub-agent bound to socrates-idle."

That binding is not incidental. The existing runtime asset code/cli/assets/apes/socrates-idle.yaml already frames the work as Dewey's problematization, so the philosophical mission is mostly aligned. The mismatch is structural: the operator identity and activation path still hardcode socrates-idle where the declared architecture says IDLE should be direct or, under the user's redesign, should be reified as dewey without downstream knowledge.

# Contrast That Matters

The main contrast is not user concept versus repository philosophy. On mission, all three perspectives are already close: IDLE is for triage, issue formulation, and clarifying comments, not for downstream delivery work. The real contrast is between two operator models:

- User concept: dewey performs bounded issue inquiry and remains ignorant of later phases.
- Declared architecture: APE operates IDLE directly with a triage skill and externalized handoff.
- Runtime: a hardcoded sub-agent named socrates-idle is activated in IDLE.

This means issue #177 is not primarily a question of whether Deweyan IDLE fits the system. It already does. The unresolved design question is whether to make runtime match the declared APE-direct model or to explicitly move the runtime/operator binding from socrates-idle to dewey while preserving the same bounded mission and external handoff.

# Conclusion

The perspectives subphase yields a stable contrast worth preserving. The user's conceptual direction is coherent with the repository's current mission boundaries and with the declared handoff discipline. The pressure point is the implementation's operator binding, which still materializes IDLE as socrates-idle even though the specs describe IDLE as direct triage.