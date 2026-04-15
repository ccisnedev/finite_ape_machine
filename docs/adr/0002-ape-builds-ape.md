# 2. APE Builds APE — Self-Referential Development

Date: 2026-03-30

## Status

Accepted

## Context

Finite APE Machine is a methodology framework for AI-assisted development. The framework itself must be developed. The question is whether to use the APE methodology to build APE, even though the tooling (CLI, agents, Memory as Code) does not yet exist.

This creates a bootstrap problem: the methodology prescribes tools that don't exist yet. However, the methodology is more than its tooling — it is a discipline cycle (Analyze → Plan → Execute + Learn) with principles that can be applied manually before the tools automate them.

## Decision

We will use the APE methodology to develop APE itself, applying the cycle manually where tooling does not yet exist.

Concretely:

- **Analyze** is performed through human-AI conversation (as we are doing now) following the SOCRATES pattern: questions, scope, constraints, risk assessment.
- **Plan** is performed by generating runbooks and task breakdowns manually, following the SUNZI/VITRUVIUS patterns.
- **Execute** follows TDD (GATSBY writes RED, ADA writes GREEN) — this can be done immediately with standard `dart test`.
- **Learn** is captured manually in ADRs and lessons-learned documents until DARWIN is implemented.
- **Architecture decisions** are recorded as ADRs (this file being an example).

As the CLI tooling becomes available (v0.0.x), we progressively replace manual steps with `ape` commands. By v0.1.0, APE should be substantially building itself with its own tools.

This approach serves as the first validation of the methodology: if APE cannot build APE, the methodology has a fundamental problem.

## Consequences

- The development process itself becomes a test case for the methodology
- We gain first-hand experience with the pain points before users encounter them
- Early versions will have manual overhead that later versions automate
- The `experiments/` folder will document this bootstrap process, feeding the experimental paper
- We accept slower initial velocity in exchange for methodology validation
