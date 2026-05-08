---
id: idle-dewey-coherence
title: "Evidence: IDLE mission and handoff are already partly Deweyan in the current model"
date: 2026-05-07
status: active
tags: [idle, dewey, coherence, handoff, runtime]
author: socrates
---

# Question

Is the proposed redesign of IDLE around Deweyan inquiry coherent with the current model in the repository?

# Evidence

## 1. The current IDLE mission is already issue triage, not downstream delivery

The runtime state instructions in code/cli/assets/fsm/states/idle.yaml define IDLE as "Triage and issue formulation": understand the problem, search for existing issues, and create or select an issue. The same file forbids root-cause analysis, solution proposals, and branch preparation. That matches the user's framing that IDLE should stay with the indeterminate situation until it becomes a determined issue.

The dedicated IDLE APE definition in code/cli/assets/apes/socrates-idle.yaml reinforces the same scope. Its description calls the work "Dewey's problematization" and its behavior is limited to scope evaluation, deduplication, issue creation or selection, and confirmation that the issue is ready.

## 2. The handoff out of IDLE is already externalized

The operational handoff from IDLE to ANALYZE is already handled outside IDLE's own mission. code/cli/assets/skills/issue-start/SKILL.md performs the infrastructure work: verify or create the issue, generate the branch slug, create the cleanroom directory, create analyze/index.md, and execute iq fsm transition --event start_analyze --issue <NNN>.

This split is also described in docs/architecture.md, which says IDLE waits for the issue-start skill and shows the cycle as: human invokes issue-start, then the CLI performs IDLE -> ANALYZE. The proposed redesign therefore aligns with an existing separation between inquiry in IDLE and transition mechanics in a dedicated skill.

## 3. Deweyan framing is already canonical in the repository

docs/philosophy.md states that every development cycle is inquiry in Dewey's sense: a controlled transformation of an indeterminate situation into a determinate unified whole. It then maps an open GitHub issue to the indeterminate situation and a merged pull request to the determinate whole. Rebuilding IDLE around Dewey is therefore consistent with the repository's own philosophical center, not an imported reinterpretation.

## 4. The main incoherence is in current operator binding, not in the mission

There is a live mismatch between specification and runtime about who operates IDLE. docs/spec/cooperative-multitasking-model.md and docs/spec/agent-lifecycle.md describe IDLE as APE operating directly with a triage skill and explicitly say there is no sub-agent in IDLE.

But the runtime code binds IDLE to a sub-agent named socrates-idle in code/cli/lib/modules/fsm/effect_executor.dart, code/cli/lib/modules/fsm/commands/state.dart, and code/cli/lib/modules/ape/commands/prompt.dart. The test suite locks that behavior in place in code/cli/test/fsm_state_test.dart and code/cli/test/effect_executor_test.dart. This means the repository already supports the Deweyan mission and the external handoff, but it still contains a spec-versus-runtime decision that must be resolved explicitly.

# Conclusion

The evidence says the proposed redesign is coherent with the current model at the level of mission, philosophy, and handoff structure. The unresolved question is not whether Deweyan IDLE fits, but whether IDLE should remain APE-direct as the specs say or continue as a dedicated sub-agent whose binding would then need to move from socrates-idle to dewey.