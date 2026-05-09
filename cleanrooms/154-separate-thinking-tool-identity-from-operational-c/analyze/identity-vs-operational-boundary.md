---
id: identity-vs-operational-boundary
title: Clarified boundary between thinking-tool identity and operational context
date: 2026-05-09
status: active
tags: [clarification, architecture, prompts]
author: socrates
---

# Clarification Target

This note clarifies what issue #154 is separating, using the current repository architecture and live prompt-composition code as the reference point.

# Terms Clarified

## Thinking-tool identity

In this repository, a named sub-agent is supposed to embody a reasoning method, not a workflow container. The canonical role descriptions define DEWEY, SOCRATES, DESCARTES, BASHO, and DARWIN by the cognitive method each one brings to a phase: problematization, Socratic questioning, Cartesian method, constrained implementation craft, and natural selection.

Relevant sources:
- docs/thinking-tools.md
- docs/spec/agent-lifecycle.md
- code/cli/assets/agents/inquiry.agent.md

## Operational context

Operational context is the phase-specific machinery needed to make that reasoning useful inside Inquiry. In the current runtime, that includes mission framing, artifact paths, output contracts, allowed commands, deterministic skills, and workflow guardrails.

Concrete examples from the live system:
- analyze/ output locations and confirmation documents for SOCRATES
- diagnosis.md and plan.md path contracts for DESCARTES
- plan execution, commit, and retrospective requirements for BASHO
- GitHub issue commands and .inquiry metrics surfaces for DARWIN
- issue-create fast-path objective and allowed command surface for DEWEY

# Boundary Clarified

The intended boundary is:

- FSM state defines the mission and operational contract of the phase.
- The named APE/sub-agent defines the way of thinking applied inside that mission.
- Inquiry CLI composes the effective prompt by combining those layers at dispatch time.

This boundary is already consistent with the repository's architectural doctrine. The docs describe the scheduler as dispatching thinking tools with clean context, and the live CLI already reconstructs and injects some runtime context at prompt assembly time.

# What The Current Runtime Actually Does

The current composition path in code/cli/lib/modules/ape/commands/prompt.dart loads an APE YAML, resolves some dynamic context, and asks ApeDefinition.assemblePrompt to concatenate:

1. the APE base prompt
2. the active APE sub-state prompt
3. an optional inquiry-context block

This is an important clarification: the composition mechanism already exists, but it currently composes around APE-authored prompt text that still includes a large amount of operational material. The separation problem is therefore not whether composition exists. The problem is that the composed layers are not yet cleanly factored by responsibility.

# Scope Clarified For Issue 154

Issue #154 is not merely about moving a few file paths out of YAML. The broader clarification is that current APE definitions often conflate at least two layers:

1. cognitive identity: how the agent should think
2. operational contract: what this phase may touch, produce, or invoke

Repository evidence shows this is systemic across the current active APE set:

- SOCRATES embeds diagnosis deliverable and documentation protocol rules.
- DESCARTES embeds plan-file contracts and planning output invariants.
- BASHO embeds plan execution mechanics, commit behavior, and retrospective obligations.
- DARWIN embeds repository command usage and .inquiry metrics behavior.
- DEWEY partially externalizes create_or_select context, but still mixes thinking style with issue-triage workflow text.

# Darwin Nuance

The clarified nuance for DARWIN is narrower than a total removal of process awareness. DARWIN may legitimately need abstract knowledge of the ideal process so it can compare actual cycles against that ideal. What it should not need is direct knowledge of concrete command surfaces, repository folders, or implementation-specific operational handles. That distinction preserves DARWIN as a comparative thinking tool rather than making it the owner of runtime procedure.

# Residual Clarification Questions

The following questions remain open after this clarification pass, but they are now sharper:

1. Which operational constraints belong in FSM state files versus CLI-side prompt injection versus reusable skills?
2. Should the effective prompt eventually include explicit FSM-state instruction text, or should the CLI translate that contract into inquiry-context fields only?
3. How much abstract process knowledge does DARWIN need before it stops being a thinking tool and starts becoming an operational controller?

# Interim Conclusion

The architectural intent and the repository's own doctrine already agree: sub-agents are thinking tools, and the scheduler/runtime owns operational delivery. The current mismatch is that the live APE YAMLs still carry a large share of the operational contract. That gives issue #154 a clarified scope: separate identity from operation without removing the CLI's role as the structured prompt composer.