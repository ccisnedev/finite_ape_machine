# Analysis Index — Issue #51: Enforce non-execution guardrails in IDLE

## Overview

This analysis examines how IDLE state violated its core constraint by executing code modifications (install.sh, upgrade.dart) without creating associated GitHub issues or following formal APE workflow.

**Goal:** Produce rigorous diagnosis.md that identifies:
1. Root causes of guardrail failure
2. Specific FSM contract violations
3. Tool-level gaps that enabled execution in IDLE
4. Proposed hardening strategies with tradeoffs

## Phases

- [ ] **CLARIFICATION**: Define IDLE contract, scope, and terms
- [ ] **ASSUMPTIONS**: Challenge what we assume about state machine enforcement
- [ ] **EVIDENCE**: Validate root causes with git/code inspection
- [ ] **PERSPECTIVES**: Consider how different roles experience this violation
- [ ] **IMPLICATIONS**: Project consequences of allowing/forbidding different fixes
- [ ] **META-REFLECTION**: Validate analysis direction
- [ ] **DIAGNOSIS**: Final rigorous technical document

## Working Documents

(To be populated as analysis progresses)

## References

- ape.agent.md: Full FSM specification
- Issue #49: Single-task rule (related concern)
- Issue #46-#50: DARWIN evolution analysis
- Cycle #44: Full context and implementation history
