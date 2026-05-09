---
id: state-encapsulation
title: "State Encapsulation — historical note on the architectural principle"
date: 2026-04-27
status: superseded
tags: [architecture, fsm, encapsulation, triage, analogies, kernel]
author: socrates
issue: 152
---

# State Encapsulation

> Superseded for canonical IDLE behavior. This document remains useful as historical architecture and for the encapsulation principle, but the normative runtime contract now lives in `code/cli/assets/fsm/transition_contract.yaml` for the outer IDLE boundary and `code/cli/assets/fsm/states/idle.yaml` for internal IDLE behavior.
>
> Historical note: the operator naming below, the proposed TRIAGE flow ending at `_DONE`, and the older handoff semantics are preserved as context only and may be stale relative to the live runtime assets.

## Principle

> No state knows that other states exist — not their name, not their transition event.

Each FSM state has a **mission**. It describes what to do HERE, never how to escape. The state's completeness triggers the transition; the state itself does not choose where to go. The scheduler reads completeness and routes accordingly.

This principle was established for sub-agents in the cooperative multitasking model [1] (property #4: "Agents are unaware of each other"). Issue #152 extends it to the FSM states themselves and to the CLI output.

## System Analogies

### 1. `.inquiry/` as `/proc` (Linux kernel)

`.inquiry/` is **kernel space**. Agents are **userspace processes**. Just as Linux processes do not write to `/proc/self/status` — the kernel manages that state — agents do not write to `.inquiry/state.yaml`. All mutations go through `iq` commands (system calls).

| Linux | Inquiry |
|-------|---------|
| `/proc/` | `.inquiry/` |
| Kernel | `iq` CLI |
| Userspace process | Agent / Sub-agent |
| System call (`write()`, `ioctl()`) | `iq fsm transition --event <e>` |
| `/proc/self/status` (read-only for processes) | `.inquiry/state.yaml` (read-only for agents) |

**Implication:** Skills and agent prompts must NEVER instruct agents to write `.inquiry/` files. All state mutations go through `iq` commands.

### 2. States as process address spaces

Each state operates in its own **address space**. It can see its own memory (mission, artifacts, sub-agent) but cannot see other states' memory. The scheduler is the kernel that context-switches between them.

| OS concept | Inquiry FSM |
|-----------|------------|
| Process address space | State's mission + artifacts |
| Cannot read other process memory | Cannot know other states exist |
| IPC (pipes, signals) | Artifacts (diagnosis.md → plan.md) |
| Context switch | FSM transition |
| Scheduler (kernel) | APE scheduler |

### 3. FSM transitions as hardware interrupts

When a state's work is complete, it does not call the next state. It **raises an interrupt** (the completion event). The scheduler (interrupt handler) evaluates the event and routes to the appropriate next state. The completed state never learns where the interrupt was routed.

| Hardware | Inquiry FSM |
|----------|------------|
| IRQ raised by device | Completion event raised by state |
| Interrupt handler | Scheduler evaluates `completion_authority` |
| Handler routes to ISR | Scheduler routes to next state |
| Device doesn't know which ISR runs | State doesn't know which state follows |

### 4. Issue granularity as the Linux patch rule

The Linux kernel enforces a fundamental principle for patches [2]:

> **Separate each logical change into a separate patch.**
> If your changes include both bug fixes and performance enhancements for a single driver, separate those changes into two or more patches.
> On the other hand, if you make a single change to numerous files, group those changes into a single patch.
> **Thus a single logical change is contained within a single patch.**

This maps directly to issue granularity in Inquiry:

| Linux kernel | Inquiry |
|-------------|---------|
| Patch | Issue |
| One logical change per patch | One logical objective per issue |
| Patch series (ordered) | Related issues with dependency notes |
| `bisect`-safe: every patch builds/runs | Every issue produces a mergeable PR |
| Maintainer reviews each patch independently | Each APE cycle is self-contained |

### 5. Completion authority as privilege levels (x86 rings)

The `completion_authority` field maps to hardware privilege rings:

| Ring | Inquiry | Who decides completion |
|------|---------|----------------------|
| Ring 0 (kernel) | `automatic` | CLI decides — no human needed |
| Ring 3 (user) | `user` | Human must confirm |

States with `completion_authority: automatic` (END, EVOLUTION) are kernel-mode: the CLI transitions without asking. States with `completion_authority: user` (IDLE, ANALYZE, PLAN, EXECUTE) are user-mode: the human confirms that the mission is complete.

## Issue Granularity Rules

Derived from Linux kernel patch submission guidelines [2] and adapted for the Inquiry methodology:

### What makes a good issue

1. **Single logical objective** — one problem, one feature, one refactor
2. **Self-contained** — can be analyzed, planned, executed, and merged independently
3. **Verifiable** — has clear criteria for "done" (tests, behavior, artifact)
4. **Bisect-safe** — the resulting PR can be reverted without affecting unrelated features

### What makes a bad issue

1. **Multiple unrelated objectives** — "fix login AND add dark mode" → split into two issues
2. **Scope creep** — "while I'm here, let me also refactor..." → create a separate issue
3. **Vague outcome** — "improve performance" without measurable criteria
4. **Dependency soup** — requires completing 5 other issues first (simplify or reorder)

### "Sufficiently related" test

Multiple objectives belong in the same issue IF AND ONLY IF:

1. **They share a single logical change** — removing one objective breaks the others
2. **They modify the same conceptual surface** — e.g., renaming a function and updating its callers
3. **They cannot be meaningfully reviewed in isolation** — the reviewer needs both changes to understand either

If objectives can be independently reviewed and independently reverted, they are separate issues.

This mirrors the kernel rule: "if you make a single change to numerous files, group those changes into a single patch." The grouping criterion is **logical unity**, not file proximity.

## Historical IDLE State Mission: Triage

This section is historical rather than normative. It preserves an earlier explanation of the IDLE mission and still-valid architectural intuition, but the canonical runtime definition belongs to `transition_contract.yaml` plus `idle.yaml`.

IDLE is the only state where the scheduler operates directly (via the TRIAGE sub-agent). Its mission is **phronesis** (Aristotle's practical wisdom) — the ability to decide what merits formal inquiry.

IDLE is not a waiting room. It is an active state whose output is **well-defined issues**. Someone can remain in IDLE indefinitely, creating issues without ever entering ANALYZE. The transition to the next phase is a side effect of successful triage, not the goal of triage.

### TRIAGE sub-agent

| Property | Value |
|----------|-------|
| Name | ARISTOTLE |
| Thinking Tool | **Phronesis** (φρόνησις) — practical wisdom [3] |
| Phase | IDLE |
| Mission | Convert chaos into order: classify user intent, decompose vague requests into well-defined issues |

**Why ARISTOTLE:** Phronesis — the intellectual virtue of knowing what to do in particular circumstances — is Aristotle's contribution to practical reasoning. Unlike theoretical wisdom (sophia), phronesis is about action in context. TRIAGE is exactly this: evaluating whether something merits action, what kind of action, and how to scope it. Aristotle's Categories (Κατηγορίαι) also introduced the first systematic taxonomy — classification of things into genera and species — which maps to the TRIAGE mission of classifying unstructured user input into well-scoped issues.

**Why not another philosopher:** SOCRATES asks questions but doesn't classify. DESCARTES decomposes but assumes the problem is already defined. ARISTOTLE bridges: he classifies WHAT the problem is before anyone starts solving it.

### TRIAGE internal states (proposed)

```
classify_intent → scope_problem → search_issues → create_or_select → confirm → _DONE
```

| State | Mission |
|-------|---------|
| `classify_intent` | Is this a consultation (answer directly, stay in IDLE) or a modification (needs an issue)? |
| `scope_problem` | Decompose the request. Is it one issue or multiple? Apply the "sufficiently related" test. |
| `search_issues` | `gh issue list --search "..."` — does an issue already exist for this? |
| `create_or_select` | Create new issue(s) via `gh issue create` or select existing one. User confirms. |
| `confirm` | Present the selected/created issue to the user. User confirms readiness. |
| `_DONE` | Terminal. Scheduler evaluates: if issue confirmed → `iq fsm transition --event ready --issue <NNN>`. If blocked → `iq fsm transition --event block`. |

### Completion authority compatibility

IDLE has `completion_authority: user`. This means:
- TRIAGE reaches `_DONE` → scheduler asks user: "¿Consideras que el triage está completo?"
- User confirms → scheduler executes transition with the selected issue
- User declines → stays in IDLE, TRIAGE can restart

This is compatible with the existing model. TRIAGE never auto-transitions the main FSM.

## References

[1] `docs/spec/cooperative-multitasking-model.md` — Property #4: "Agents are unaware of each other."

[2] Linux kernel documentation. "Submitting patches: the essential guide to getting your code into the kernel." Section: "Separate your changes." https://www.kernel.org/doc/html/latest/process/submitting-patches.html

[3] Aristotle. *Nicomachean Ethics*, Book VI. Phronesis as practical wisdom distinct from theoretical wisdom (sophia) and technical knowledge (techne).

[4] `docs/spec/agent-lifecycle.md` — IDLE state description and triage function.

[5] `code/cli/assets/agents/inquiry.agent.md` — Firmware v0.2.0 (current, missing triage behavior).

[6] `code/cli/assets/archive/inquiry.agent.md.legacy` — Legacy firmware with full triage behavior (lines 36-63).
