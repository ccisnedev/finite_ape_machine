# Mapping Peirce's Inquiry Cycle to APE's FSM States

## The Isomorphism

The following table demonstrates the structural isomorphism between Peirce's three modes of inference in the inquiry cycle and APE's finite state machine:

| Peirce's Mode | Type of Reasoning | APE State | APE Agent | Artifact Produced |
|---|---|---|---|---|
| **Abduction** | Hypothesis generation | ANALYZE | SOCRATES | `diagnosis.md` |
| **Deduction** | Consequence derivation | PLAN | DESCARTES | `plan.md` |
| **Induction** | Empirical testing | EXECUTE | BASHŌ | Code + tests + `retrospective.md` |

## Additional APE States and Their Epistemic Roles

APE extends beyond Peirce's three-phase cycle with additional states that serve meta-epistemic functions:

| APE State | Epistemic Function | Philosophical Precedent |
|---|---|---|
| **IDLE** | Problem recognition — the moment doubt arises | Peirce's "irritation of doubt" (CP 5.374) |
| **ANALYZE** | Abduction — hypothesis generation | Peirce's abductive inference |
| **PLAN** | Deduction — experimental design | Descartes' four rules of method |
| **EXECUTE** | Induction — empirical verification | Bashō's *yō no bi* (functional beauty) |
| **END** | Judgment — accepting or rejecting results | Peer review in scientific community |
| **EVOLUTION** | Meta-inquiry — improving the inquiry process itself | Darwin's natural selection applied to methodology |

## The Cycle as a Whole

Peirce insisted that the three modes of inference form an inseparable cycle:

> "The purpose of abduction is to generate guesses of a kind that deduction can explicate and that induction can evaluate." (Peirce, CP 2.775)

This constraint is enforced structurally in APE:
- **ANALYZE → PLAN** is mandatory (abduction must precede deduction)
- **PLAN → EXECUTE** is mandatory (deduction must precede induction)
- **ANALYZE → EXECUTE** is illegal (skipping deduction breaks the cycle)
- **EXECUTE → ANALYZE** is allowed (falsification returns to abduction)

The last point — returning to ANALYZE when execution falsifies the hypothesis — is directly Popperian (Popper, 1959) and consistent with Peirce's view that inquiry is self-correcting.

## Dewey's Transformation Applied

Each APE cycle performs Dewey's "controlled transformation":

```
INDETERMINATE SITUATION          DETERMINATE SITUATION
(GitHub issue: bug/feature)  →   (Merged PR: tested code + docs)
         │                                  ▲
         ▼                                  │
    ┌─────────┐    ┌──────┐    ┌─────────┐  │
    │ ANALYZE │───▶│ PLAN │───▶│ EXECUTE │──┘
    │(abduce) │    │(duce)│    │(induce) │
    └─────────┘    └──────┘    └─────────┘
```

The GitHub issue represents Dewey's "indeterminate situation" — a problem not yet understood. The merged PR represents the "determinate unified whole" — a solution validated by tests, documented by analysis, and verified by retrospective.

## Implications for Naming

If APE's primary activity is performing instances of inquiry in the Peircean/Deweyan sense, then the directory structure `docs/inquiry/<issue-slug>/` would accurately describe its contents: each folder is a record of one complete inquiry cycle.

However, it should be noted that in common English usage, "inquiry" often connotes:
1. A formal investigation (legal/governmental inquiry)
2. A question or request for information
3. Academic/philosophical investigation

The technical Peircean usage — a structured process of abduction, deduction, and induction that transforms indeterminacy into determinacy — is more specific than any of these common uses.

## References

- Peirce, C.S. (1931–1958). *Collected Papers of Charles Sanders Peirce*. Harvard University Press. Cited as CP volume.paragraph.
- Dewey, J. (1938). *Logic: The Theory of Inquiry*. Henry Holt and Company.
- Dewey, J. (1910). *How We Think*. D.C. Heath.
- Popper, K. (1959). *The Logic of Scientific Discovery*. Routledge.
- Descartes, R. (1637). *Discours de la méthode*. Ian Maire, Leiden.
