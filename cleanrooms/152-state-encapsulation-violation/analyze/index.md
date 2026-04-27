---
id: index
title: "Analysis index — Issue #152: State encapsulation violation"
date: 2026-04-27
status: active
tags: [encapsulation, fsm, idle, triage, firmware]
author: socrates
---

# Issue #152 — State Encapsulation Violation

## Documents

| Document | Status | Description |
|----------|--------|-------------|
| [confirmed-findings.md](confirmed-findings.md) | active | **Living document** — all confirmed findings, updated as analysis progresses |
| [violation-inventory.md](violation-inventory.md) | active | Complete inventory of all encapsulation violations across 7 layers |
| [assumptions-challenge.md](assumptions-challenge.md) | active | Assumptions challenge for 4 decisions — risk and blast radius |

## Specs produced

| Document | Description |
|----------|-------------|
| [docs/spec/state-encapsulation.md](../../../docs/spec/state-encapsulation.md) | State encapsulation principle, system analogies, issue granularity rules, TRIAGE sub-agent design |

## Key findings

- **F1:** The bug is real and ongoing — even a frontier model violated kernel boundary during this session
- **F2:** Thesis corrected from "method over model" to "clarity through method" — matched to project origin
- **F3:** `--issue` flag on `iq fsm transition` works correctly — verified manually
- **F4:** `issue-start` SKILL.md violates kernel space principle (instructs agents to write state.yaml)
- **F5:** `start_analyze` prechecks empty — validation code exists, contract declaration missing
- **F6:** Event rename deferred to separate issue — blast radius too high (25+ files)
- **F7:** ~~ARISTOTLE~~ invalidated — SOCRATES in two modes (triage + diagnosis) replaces it
- **F8:** `docs/philosophy.md` created as foundational document — governs all specs
- **F9:** `next_state` removal from JSON is safe — 1 test to update
- **F10:** Sub-agent YAMLs are clean — violation is in firmware and CLI only
- **F11:** Sub-agents are cross-cutting capabilities, not 1:1 state slots — DARWIN everywhere when evolution=true
- **F12:** IDLE is Dewey's problematization — "analysis before the analysis" is inherent, not a bug
