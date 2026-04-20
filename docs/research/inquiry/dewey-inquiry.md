# Dewey's Definition of Inquiry as Controlled Transformation

## Context

John Dewey (1859–1952) extended Peirce's pragmatic theory of inquiry into a comprehensive framework in his seminal work *Logic: The Theory of Inquiry* (1938). His definition provides perhaps the most precise characterization of what APE does.

## The Definition

> "Inquiry is the controlled or directed transformation of an indeterminate situation into one that is so determinate in its constituent distinctions and relations as to convert the elements of the original situation into a unified whole." (Dewey, 1938, p. 108)

### Breaking Down the Definition

| Component | Meaning | APE Equivalent |
|-----------|---------|----------------|
| **Controlled or directed** | Not random; follows a method | The FSM enforces state transitions |
| **Transformation** | Something changes fundamentally | An open issue becomes a merged PR |
| **Indeterminate situation** | A problem, doubt, or confusion | A GitHub issue (bug, feature request) |
| **Determinate** | Clear, resolved, understood | Validated code with tests and retrospective |
| **Constituent distinctions and relations** | The parts and their connections are clear | diagnosis.md, plan.md, retrospective.md |
| **Unified whole** | Not just parts but a coherent resolution | The complete cycle: analysis + plan + code + docs |

## Dewey's Pattern of Inquiry

In *How We Think* (1910), Dewey illustrated the pattern of inquiry with everyday examples. His "Rainy Day" example shows five phases:

1. **Suggestion** — An idea springs up as a possible solution (abductive)
2. **Intellectualization** — The difficulty is defined as a problem to solve
3. **Hypothesis** — A guiding idea is formulated
4. **Reasoning** — Consequences of the hypothesis are developed (deductive)
5. **Testing** — The hypothesis is tested by action (inductive)

These five phases compress into Peirce's three modes of inference, which in turn map to APE's three active states (ANALYZE, PLAN, EXECUTE).

## The Social Nature of Inquiry

Dewey and Peirce both emphasized that inquiry is inherently social — it occurs within a **community of inquiry** (Shields, 2003; Seixas, 1993). In APE, this community is instantiated as the sub-agent ensemble:

- **SOCRATES** — the questioner (abductive community member)
- **DESCARTES** — the planner (deductive community member)
- **BASHŌ** — the maker (inductive community member)
- **DARWIN** — the evaluator (meta-inquiry: inquiry about the inquiry process)

The human developer participates as the domain expert who holds tacit knowledge that the agents help extract and formalize.

## Inquiry vs. Documentation

A critical distinction: Dewey's inquiry is **not** documentation. Documentation describes what exists. Inquiry **transforms** what exists. The artifacts produced during inquiry (diagnosis.md, plan.md, retrospective.md) are not descriptions of a system — they are records of an epistemic process, analogous to a laboratory notebook.

## References

- Dewey, J. (1938). *Logic: The Theory of Inquiry*. Henry Holt and Company, New York. Reprinted in *The Later Works*, 1925–1953, Volume 12, Jo Ann Boydston (ed.), Southern Illinois University Press, 1986.
- Dewey, J. (1910). *How We Think*. D.C. Heath, Lexington, MA. Reprinted, Prometheus Books, Buffalo, NY, 1991.
- Shields, P. (2003). "The Community of Inquiry." *Administration & Society*, 35(5), 510–538.
- Seixas, P. (1993). "The Community of Inquiry as a Basis for Knowledge and Learning." *American Educational Research Journal*, 30(2), 305–324.
- Peirce, C.S. (1877). "The Fixation of Belief." *Popular Science Monthly*, 12, 1–15.
