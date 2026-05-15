---
id: diagnosis
title: "Diagnosis: Deep-Research Skill with Staged Web Investigation"
date: 2026-05-15
status: active
tags: [diagnosis, deep-research, skills, context-isolation, citations]
author: socrates
issue: [193]
---

# Diagnosis: Deep-Research Skill with Staged Web Investigation

## Executive Summary

Issue #193 is not primarily a scraping problem. It is a context-isolation problem.

The repository already contains the root complaint: when APE or SOCRATES performs external investigation directly, the active phase context gets polluted with raw search material and loses analytical sharpness. The missing capability is a reusable producer of documented research that can be invoked before analysis or planning consumes that material. The proper object to introduce is therefore a skill, not a new phase agent: a universal deep-research protocol that gathers external evidence and returns a paper-style artifact with verifiable citations.

The core architectural decision is to separate producer and consumer:

- The deep-research skill produces a durable research artifact.
- SOCRATES, DESCARTES, DARWIN, or the user consume that artifact without inheriting the raw search process.

## 1. Problem Defined

The problem to solve is:

**How can Inquiry obtain rigorous external research with verifiable references without forcing APE or phase agents to carry raw web-search context inside their own operational prompts?**

This problem is already visible in repository history. The note in [cleanrooms/044-fsm-fix-linux-support-crossplatform-audit/analyze/notas_para_evolution.md](../../../044-fsm-fix-linux-support-crossplatform-audit/analyze/notas_para_evolution.md) states directly that APE investigating the internet by itself is not ideal because it pollutes the cycle context, and that a separate deep-research agent producing a paper-style file with references would preserve analytical cleanliness. The roadmap later captures the same pressure as issue #46: delegate research to a subagent during ANALYZE to reduce SOCRATES context-window pressure. See [docs/roadmap.md](../../../docs/roadmap.md).

The user request in #193 is therefore aligned with an existing architectural need, not a new convenience feature.

## 2. Decisions Taken

### D1: Deep research should be a skill, not a thinking tool or new APE

**Decision:** The new capability should be modeled as a skill.

**Justification:** The current architecture distinguishes phase-bound thinking tools from reusable protocols. `legion` is the direct precedent: it is a universal skill because it can be invoked by any phase or by the user outside the FSM. The same reasoning applies here. Deep research is a trans-phase capability, not a new epistemological phase with its own warrant. It may be used by SOCRATES during ANALYZE, by DESCARTES during PLAN, by DARWIN during EVOLUTION, or directly by the user. That ubiquity is the signature of a skill rather than an APE.

**References:** [docs/thinking-tools.md](../../../docs/thinking-tools.md), [docs/research/legion.md](../../../docs/research/legion.md), [docs/research/council_of_experts.md](../../../docs/research/council_of_experts.md)

### D2: The architectural problem is producer-consumer isolation

**Decision:** The diagnosis is framed around an explicit producer-consumer boundary.

**Justification:** The repository evidence does not point to “missing web search” in the abstract. It points to contaminated operational context. The deep-research skill is the producer; SOCRATES and other consumers receive only the research artifact, not the raw search session. This is the real boundary PLAN must preserve.

**References:** [cleanrooms/044-fsm-fix-linux-support-crossplatform-audit/analyze/notas_para_evolution.md](../../../044-fsm-fix-linux-support-crossplatform-audit/analyze/notas_para_evolution.md), [docs/roadmap.md](../../../docs/roadmap.md)

### D3: The v1 output contract is a single paper-style markdown artifact

**Decision:** The primary output for v1 should be one durable markdown report.

**Justification:** The immediate need is a clean handoff artifact that another phase can read without replaying the search. A single report is consistent with existing repository practice: `diagnosis.md`, `plan.md`, `retrospective.md`, and LEGION’s persisted `.md` synthesis. Introducing a multi-file bundle as the default would expand the problem from “clean analytical handoff” to “artifact packaging system.” That is not required to solve the current issue.

The artifact must be paper-style: clear problem statement, research method, findings, source notes, and bibliography.

**References:** [docs/research/legion.md](../../../docs/research/legion.md), [docs/research/ape_builds_ape/ape-paper.md](../../../docs/research/ape_builds_ape/ape-paper.md), [docs/research/inquiry/bibliography.md](../../../docs/research/inquiry/bibliography.md)

### D4: The default citation standard for v1 should be BibTeX-compatible references embedded in the report

**Decision:** v1 should standardize on BibTeX-compatible bibliography entries as the canonical citation surface.

**Justification:** The user explicitly asked for a paper-like result with references “como bibtex o algun estandar”. The repository has research documents with manually curated references, but no canonical operational format. A default must be chosen now to avoid downstream ambiguity. BibTeX is widely recognized, machine-parseable, and compatible with paper-oriented workflows. Choosing a single default for v1 prevents every invocation from inventing a different reference style.

This does **not** mean the report must become a separate `.bib` bundle in v1. The required contract is simpler: the markdown report contains a bibliography section with BibTeX-compatible entries and stable source identifiers that the narrative can reference.

**References:** [docs/research/inquiry/bibliography.md](../../../docs/research/inquiry/bibliography.md), [docs/research/ape_builds_ape/ape-paper.md](../../../docs/research/ape_builds_ape/ape-paper.md)

### D5: The skill must be universal in function, even when invoked inside Inquiry

**Decision:** The skill should be treated as universal in behavior and intent.

**Justification:** The strongest precedent is `legion`: the skill remains useful with or without Inquiry. Deep research has the same profile. If it only works when `.inquiry/` or cleanroom-specific state is present, it is not actually solving the broader research problem; it is creating an Inquiry-bound wrapper. The protocol must remain intelligible and useful outside the FSM, even if Inquiry enriches it with context when present.

**References:** [docs/research/legion.md](../../../docs/research/legion.md), [docs/architecture.md](../../../docs/architecture.md)

### D6: Deep research and LEGION are orthogonal, not competing patterns

**Decision:** The new skill is not a replacement for `legion` and should not be modeled as “LEGION plus web.”

**Justification:** LEGION aggregates diverse expert perspectives. Deep research gathers and documents external evidence. One is a multi-perspective synthesis technique; the other is an evidence-acquisition and documentation protocol. They may compose in future work, but they solve distinct problems and should remain separate in diagnosis to avoid a blurred contract.

**References:** [code/cli/assets/skills/legion/SKILL.md](../../../code/cli/assets/skills/legion/SKILL.md), [docs/research/legion.md](../../../docs/research/legion.md)

## 3. Constraints and Risks

### Constraints

| # | Constraint | Impact |
|---|------------|--------|
| C1 | The issue must solve context pollution, not merely add search capability | The output contract matters more than the raw fetch mechanism |
| C2 | No new APE or FSM phase is justified by current evidence | The solution must fit the skill boundary |
| C3 | Research output must be durable and readable by downstream phases | Ephemeral chat-only research would fail the problem definition |
| C4 | The report must carry a standard citation form | Free-form prose references are insufficient for a reusable protocol |
| C5 | Existing repository practice favors one durable markdown artifact per analytical step | v1 should not assume a multi-artifact packaging system |

### Risks

| # | Risk | Severity | Why it matters |
|---|------|----------|----------------|
| R1 | The skill becomes an Inquiry-bound wrapper with hidden runtime assumptions | High | That would violate the universal-skill precedent established by `legion` |
| R2 | The report preserves too much raw web material and simply relocates context pollution | High | Then SOCRATES still inherits noise, just later |
| R3 | Citation format remains ambiguous across invocations | High | Downstream consumers cannot rely on the artifact contract |
| R4 | The skill is framed as a LEGION variant instead of a separate evidence protocol | Medium | The resulting design would mix expert synthesis and research gathering unnecessarily |
| R5 | Persisted research is omitted or under-specified | Medium | Reproducibility and auditability degrade, especially for future EVOLUTION work |

## 4. Scope

### IN scope

1. Define the problem as context-isolation for external research.
2. Establish that the new capability is a skill, not an APE.
3. Establish that the skill is universal in intent and usable beyond a single phase.
4. Establish that the output contract is one paper-style markdown artifact.
5. Establish that v1 uses BibTeX-compatible references embedded in the report.
6. Clarify that the skill is orthogonal to `legion`.

### OUT of scope

1. Exact web-search tooling or scraping stack.
2. Retry logic, rate limiting, or timeout policy.
3. Exact deployment path and packaging mechanics.
4. Exact file placement when invoked outside an APE cycle.
5. Thresholds for report length, retry counts, or fetch fan-out.
6. Optional secondary formats such as CSL-JSON or external `.bib` files.

## 5. Questions Resolved by This Diagnosis

| # | Question | Resolution |
|---|----------|------------|
| Q1 | Is this a new APE or a skill? | Skill |
| Q2 | What problem is being solved? | Isolation of research production from analytical consumption |
| Q3 | What is the primary output? | One paper-style markdown report |
| Q4 | What citation standard anchors v1? | BibTeX-compatible bibliography entries inside the report |
| Q5 | Is this an extension of LEGION? | No; it is orthogonal and potentially composable |
| Q6 | Should it only work inside Inquiry? | No; it should remain universal in function |

## 6. Questions Deferred to PLAN

1. Which exact tools or APIs perform the search and fetch operations.
2. The concrete section template of the report.
3. The exact stop condition for staged research.
4. The specific persistence location when invoked inside and outside a cycle.
5. Validation strategy for citation completeness and source verification.
6. Whether v1 needs optional secondary exports beyond the markdown report.

## 7. References

- [cleanrooms/044-fsm-fix-linux-support-crossplatform-audit/analyze/notas_para_evolution.md](../../../044-fsm-fix-linux-support-crossplatform-audit/analyze/notas_para_evolution.md)
- [docs/roadmap.md](../../../docs/roadmap.md)
- [docs/thinking-tools.md](../../../docs/thinking-tools.md)
- [docs/architecture.md](../../../docs/architecture.md)
- [code/cli/assets/skills/legion/SKILL.md](../../../code/cli/assets/skills/legion/SKILL.md)
- [docs/research/legion.md](../../../docs/research/legion.md)
- [docs/research/council_of_experts.md](../../../docs/research/council_of_experts.md)
- [docs/research/inquiry/bibliography.md](../../../docs/research/inquiry/bibliography.md)
- [docs/research/ape_builds_ape/ape-paper.md](../../../docs/research/ape_builds_ape/ape-paper.md)
