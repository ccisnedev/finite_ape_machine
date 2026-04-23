# Analysis Index — Issue #51: Enforce non-execution guardrails in IDLE

## Overview

This analysis examines how IDLE state violated its core constraint by executing code modifications (install.sh, upgrade.dart) without creating associated GitHub issues or following formal APE workflow.

**Goal:** Produce rigorous diagnosis.md that identifies:
1. Root causes of guardrail failure
2. Specific FSM contract violations
3. Tool-level gaps that enabled execution in IDLE
4. Proposed hardening strategies with tradeoffs

## Phases

- [x] **CLARIFICATION**: Define IDLE contract, scope, and terms
- [x] **ASSUMPTIONS**: Challenge what we assume about state machine enforcement
- [x] **EVIDENCE**: Validate root causes with git/code inspection
- [ ] **PERSPECTIVES**: Deferred in this cycle (folded into diagnosis synthesis)
- [ ] **IMPLICATIONS**: Deferred in this cycle (captured in diagnosis risks)
- [ ] **META-REFLECTION**: Deferred in this cycle
- [x] **DIAGNOSIS**: Final rigorous technical document

## Working Documents

| ID | Title | Date | Status | Tags |
|----|-------|------|--------|------|
| clarification | CLARIFICATION Phase — SOCRATES Dialogue | 2026-04-18 | completed | idle, triage, scope |
| assumptions | ASSUMPTIONS Phase — SOCRATES Dialogue | 2026-04-18 | completed | assumptions, guardrails, methodology |
| evidence-raw | EVIDENCE Phase — Raw Facts from Incident | 2026-04-18 | completed | evidence, git, incident |
| evidence-findings | EVIDENCE Phase — Rigorous Analysis | 2026-04-18 | completed | findings, root-cause, validation |
| diagnosis | Diagnostico tecnico del incidente IDLE sin issue-first | 2026-04-18 | completed | idle, fsm, issue-first, guardrails, triage |

## References

- ape.agent.md: Full FSM specification
- Issue #49: Single-task rule (related concern)
- Issue #46-#50: DARWIN evolution analysis
- Cycle #44: Full context and implementation history
