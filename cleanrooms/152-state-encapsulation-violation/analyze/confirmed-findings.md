---
id: confirmed-findings
title: "Confirmed findings — living document"
date: 2026-04-27
status: active
tags: [findings, confirmed, socrates, living-document]
author: socrates
---

# Confirmed Findings

> This is a living document. SOCRATES updates it as findings are confirmed, revised, or invalidated during analysis. Each entry records WHAT was confirmed, WHEN, and any EVIDENCE.

## F1: The bug is real and ongoing — CONFIRMED

The state encapsulation violation is not theoretical. During this very analysis session, the agent (Claude Opus 4.6, frontier model, max reasoning) violated the kernel boundary by editing `.inquiry/state.yaml` directly instead of using `iq fsm transition --issue 152`. This proves:

- The bug occurs **even with frontier models and maximum configuration**
- Inquiry is not just useful — it is **necessary**
- The problem is not AI capability, it is the absence of guardrails that enforce the method

**Evidence:** Session transcript — agent wrote `.inquiry/state.yaml` directly, then corrected via `iq fsm transition --event start_analyze --issue 152`.

## F2: The thesis is clarity, not model independence — CONFIRMED (revised)

Original draft of `docs/philosophy.md` stated "method over model" — that a small model with good process beats a frontier model without. This was **an unsubstantiated claim** that does not match the project's origin.

The actual thesis, per the timeline and project history:
> **The bottleneck in AI-assisted development is not AI capability — it is human clarity.**

The AI reads words, not intent. Inquiry forces the developer to externalize their thinking into unambiguous artifacts before the AI acts. The goal is that the developer recognizes the AI's output as their own design.

**Evidence:** `docs/timeline.md` — "The AI assumed things I hadn't said", "I recognize the code the AI produces as my own."

## F3: `--issue` flag works correctly — CONFIRMED

`iq fsm transition --event start_analyze --issue 152` correctly writes the issue number to `.inquiry/state.yaml` without the agent touching the file.

**Evidence:** Manual verification in terminal during this session.

## F4: `issue-start` skill violates kernel space — CONFIRMED

`code/cli/assets/skills/issue-start/SKILL.md` instructs agents to write `.inquiry/state.yaml` directly. Must be changed to use `iq fsm transition --event start_analyze --issue <NNN>`.

**Evidence:** Read of SKILL.md during analysis.

## F5: `start_analyze` has empty prechecks — CONFIRMED

`code/cli/assets/fsm/transition_contract.yaml` declares `prechecks: []` for `start_analyze`. The validation code for `issue_selected_or_created` and `feature_branch_selected` already exists in `_validatePreconditions()` — only the contract declaration is missing.

**Evidence:** Read of transition_contract.yaml and transition.dart during analysis.

## F6: Event rename deferred — CONFIRMED

Renaming events from state-specific names (e.g., `start_analyze`) to generic names (e.g., `begin`) has too high blast radius (25+ files). Deferred to a separate issue.

**Evidence:** grep search during assumptions challenge showed 8 cleanroom plans, tests, site HTML all reference current names.

## F7: TRIAGE sub-agent design — CONFIRMED (direction, not details)

IDLE will get an ARISTOTLE sub-agent using phronesis (practical wisdom) + categories (systematic classification). Internal states: `classify_intent → scope_problem → search_issues → create_or_select → confirm → _DONE`. 

**Open question:** Exact YAML structure, completion behavior, scheduler integration details still need PLAN phase work.

## F8: `docs/philosophy.md` is the foundational document — CONFIRMED

Created during this analysis as the document that governs all other specs. Five convictions:
1. Clarity through method (NOT "method over model")
2. Memory as code
3. The kernel boundary
4. States are worlds
5. Evolution is built-in

Design invariant test #4 is: "Does it force clarity before action?" (NOT "Does it work with any model?")

## F9: `next_state` removal is safe — CONFIRMED

No firmware or agent reads `next_state` for routing. Only 1 test file to update (`fsm_state_test.dart`). Zero external dependencies.

**Evidence:** grep search during assumptions challenge.

## F10: Sub-agent YAMLs are clean — CONFIRMED

`socrates.yaml`, `basho.yaml`, `descartes.yaml`, `darwin.yaml` — zero references to other FSM main states. The encapsulation violation is in the firmware and CLI, not in the sub-agents.

**Evidence:** Read of all sub-agent YAML files during analysis.

---

*Last updated: 2026-04-27 — SOCRATES assumptions phase*
