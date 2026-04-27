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
| [violation-inventory.md](violation-inventory.md) | active | Complete inventory of all encapsulation violations across 7 layers |
| [assumptions-challenge.md](assumptions-challenge.md) | active | Assumptions challenge for 4 key decisions — risk and blast radius |

## Specs produced

| Document | Description |
|----------|-------------|
| [docs/spec/state-encapsulation.md](../../../docs/spec/state-encapsulation.md) | State encapsulation principle, system analogies, issue granularity rules, TRIAGE sub-agent design |

## Key findings

- `--issue` flag on `iq fsm transition` works correctly — verified manually
- `issue-start` SKILL.md violates kernel space principle (instructs agents to write state.yaml)
- Event rename (Decision 2) deferred to separate issue — blast radius too high
- TRIAGE sub-agent proposed as ARISTOTLE (phronesis + categories)
