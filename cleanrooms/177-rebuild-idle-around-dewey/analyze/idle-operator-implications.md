---
id: idle-operator-implications
title: "Implications of the current IDLE operator mismatch"
date: 2026-05-07
status: active
tags: [idle, dewey, implications, runtime, operator]
author: socrates
---

# Question

What follows if IDLE's mission is already Deweyan and its handoff is already externalized, but the runtime still materializes IDLE as socrates-idle?

# Implications

## 1. Issue #177 is now a control-plane reconciliation, not a mission rewrite

The current repository already aligns on the bounded mission of IDLE: issue triage, issue confirmation or creation, and clarifying comments. The remaining disagreement is over who operates that mission at runtime. That means a change limited to wording, philosophy, or prompt content would leave the actual mismatch intact.

## 2. The operator decision is a system contract, not a single asset rename

The active IDLE operator is encoded in multiple CLI truth surfaces. code/cli/lib/modules/fsm/effect_executor.dart auto-activates socrates-idle on entry to IDLE, code/cli/lib/modules/ape/commands/prompt.dart only allows socrates-idle as the valid IDLE ape, code/cli/lib/modules/fsm/commands/state.dart reports socrates-idle as RUNNING, and code/cli/lib/modules/global/commands/doctor.dart expects the socrates-idle asset to exist. The test suite locks the same assumption in place. Any decision to make IDLE APE-direct or to rename the operator to dewey therefore requires synchronized contract changes, not just a YAML edit.

## 3. If nothing changes, the repository will keep exposing contradictory truths about IDLE

The declared architecture says IDLE has no sub-agent and externalizes handoff, while the runtime and CLI continue to present socrates-idle as the active operator. This contradiction is already user-visible through state inspection and prompt resolution, so it is not merely internal technical debt. Leaving it unresolved means contributors and operators will keep receiving two incompatible explanations of how IDLE works.

## 4. Inaction deepens the wrong maintenance seam

As long as socrates-idle remains the live runtime contract, every incremental change around tests, doctor checks, and prompt tooling reinforces the old operator identity. That makes later reconciliation more expensive because more surfaces will need to be unwound together. The cost of waiting is therefore structural drift, not only naming inconsistency.

# Conclusion

The strongest consequence of the confirmed findings is that issue #177 must make an explicit operator-model decision and carry it through every CLI truth surface. Otherwise the repository will continue to document one IDLE architecture while executing another.