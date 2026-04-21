---
id: adi-ape-software-mapping
title: "ADI→APE Mapping: Peirce's Inquiry as the Foundation of Analyze-Plan-Execute"
date: 2026-04-20
status: active
tags: [peirce, dewey, ape, inquiry, abduction, deduction, induction, software-development]
author: socrates
---

# ADI → APE: The Structural Isomorphism

## Thesis

**The conceptual framework that justifies APE's three-phase structure (Analyze→Plan→Execute) is Peirce's theory of inquiry. APE does not arbitrarily sequence three phases — it instantiates the three modes of inference that Peirce proved are necessary and sufficient for any complete act of inquiry.**

## The Core Mapping

| Peirce | Mode of Inference | APE Phase | Agent | What Happens |
|--------|-------------------|-----------|-------|--------------|
| Abduction | Hypothesis generation | ANALYZE | SOCRATES | Examine issue, question assumptions, generate diagnosis |
| Deduction | Consequence derivation | PLAN | DESCARTES | Take diagnosis as premise, derive necessary steps |
| Induction | Empirical testing | EXECUTE | BASHŌ | Implement plan, run tests, verify hypothesis against reality |

## Does ADI Apply to Software Development?

**Yes** — because software issues exhibit exactly the epistemic structure Peirce identified:

### Software Issues ARE Indeterminate Situations (Dewey)

A GitHub issue is a textual description of an indeterminate situation: something is wrong, unclear, or missing. It becomes determinate only when a merged PR resolves it into a unified whole.

```
GitHub issue (indeterminate) → Analysis + Planning + Implementation → Merged PR (determinate)
```

This IS Dewey's transformation pattern applied to code.

### Diagnosis IS Abductive

When SOCRATES examines an issue, the reasoning is abductive:
- The surprising fact C is observed (bug report, feature gap)
- If hypothesis A were true (root cause, design approach), C would follow
- Hence we suspect A — and structure subsequent work around testing A

### Planning IS Deductive

When DESCARTES derives a plan, the reasoning is deductive:
- IF the diagnosis is correct (premise from ANALYZE)
- THEN these specific steps necessarily follow (file changes, test additions)
- The plan is a chain of necessary consequences from the accepted hypothesis

### Implementation IS Inductive

When BASHŌ executes the plan, the reasoning is inductive:
- We test the hypothesis by implementing it
- Tests pass or fail — empirical feedback
- If tests pass: hypothesis confirmed (belief fixed)
- If tests fail: return to ANALYZE (new abduction cycle)

## Additional APE States in the Framework

| APE State | Pragmatist Equivalent |
|-----------|----------------------|
| IDLE | "The irritation of doubt" — awaiting a problematic situation (Peirce CP 5.374) |
| END | Peer review — communal validation before belief fixation |
| EVOLUTION | Meta-inquiry — inquiry ABOUT the inquiry process itself |

## The Dewey Transformation in APE

```
Indeterminate situation    →  Determinate unified whole
─────────────────────────     ────────────────────────
GitHub issue               →  Merged PR
Vague problem description  →  Working, tested code
Doubt                      →  Fixed belief (until next doubt)
```

## Why This Matters for Naming

If APE's core operation is performing Peircean inquiry on software issues, then the **noun** that names this operation should reflect that. Each `ape XXX start` initiates a complete cycle of abduction→deduction→induction applied to a specific indeterminate situation.

The operation is not merely "work" or "task" or "cycle" — it is **inquiry** in the precise, technical, pragmatist sense.

---

*Synthesis from: Peirce CP 5.189, 2.267, 6.526, 2.775, 5.374; Dewey (1938) Logic: The Theory of Inquiry, p.108.*
