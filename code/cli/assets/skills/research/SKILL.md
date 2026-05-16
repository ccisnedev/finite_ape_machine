---
name: research
description: 'Run staged web investigation and produce one durable paper-style markdown report with BibTeX-compatible references.'
---

# research - Staged Web Investigation Protocol

## When to Use

- You need to investigate a topic using external web sources
- You need a durable, auditable report (not only chat output)
- The problem requires evidence synthesis from multiple sources
- You need explicit citation traceability from claims to references

## Invocation Scope

- This skill is standalone and user-invoked directly.
- v1 scope is direct invocation only.
- Do not couple this protocol to other routes, phases, or automatic invocation flows.

## Inputs

Required:
- Research question (single sentence)

Optional:
- Context and constraints
- Time/depth budget
- Preferred source domains
- Output path

## Output Contract

Produce exactly one paper-style markdown artifact (`.md`) with this mandatory structure:

```markdown
# <Title>

## Abstract
## Research Question
## Scope and Constraints
## Method (Staged Protocol)
## Findings by Stage
### Stage 1 - Problem Framing
### Stage 2 - Source Discovery
### Stage 3 - Source Triage
### Stage 4 - Evidence Extraction
### Stage 5 - Synthesis and Limits
## Discussion
## Conclusion
## Limitations
## References
```

Rules:
1. The report is a single durable artifact.
2. Every non-trivial claim must include an in-text citation key, e.g. `[@smith2024llm]`.
3. `References` must be BibTeX-compatible entries embedded in markdown fenced code blocks.
4. Citation keys used in the body must exist in `References`.

## Staged Protocol

Follow stages in order and do not skip forward.

### Stage 1: Problem Framing

- Normalize the question.
- Define explicit scope boundaries and out-of-scope points.
- Define success criteria for the investigation.

Exit condition:
- Problem statement and boundaries are unambiguous.

### Stage 2: Source Discovery

- Collect candidate sources from diverse origins (specs, official docs, papers, benchmarks, incident reports when relevant).
- Capture URL, title, publisher/author, date, and source type.

Exit condition:
- Candidate set covers at least 3 independent sources or a justified smaller set if the domain is niche.

### Stage 3: Source Triage

- Score each source for relevance, credibility, recency, and evidence type.
- Drop low-quality or redundant sources with explicit rationale.

Exit condition:
- Curated source set is sufficient to answer the question.

### Stage 4: Evidence Extraction

- Extract claims, methods, metrics, and constraints from curated sources.
- Record direct evidence snippets with attribution.
- Distinguish fact vs interpretation.

Exit condition:
- Each major sub-question has evidence coverage.

### Stage 5: Synthesis and Limits

- Reconcile agreements and conflicts across sources.
- State confidence per key conclusion (high/medium/low) with rationale.
- Explicitly document unresolved uncertainties and limitations.

Exit condition:
- Conclusions are traceable and uncertainty is explicit.

## Citation Standard (BibTeX-Compatible)

In `References`, provide entries in this style:

```bibtex
@article{smith2024llm,
  title={Example Title},
  author={Smith, Alice and Doe, Bob},
  journal={Journal Name},
  year={2024},
  url={https://example.org/paper}
}
```

Minimum fields by source type:
- Article/paper: `author`, `title`, `year`, `url` (+ venue field when available)
- Website/doc page: `title`, `year` (or `note={Accessed: YYYY-MM-DD}`), `url`
- Book/report: `author` or `institution`, `title`, `year`, `url` or publisher metadata

## Quality Gate Checklist

Before finishing, verify:

- Exactly one markdown report was produced
- All mandatory sections are present
- Every non-trivial claim has an in-text citation key
- Every citation key resolves to one BibTeX-compatible entry
- Broken or unreachable links are flagged in Limitations
- The report reflects staged progression, not an unstructured source dump

## Non-Goals (v1)

- No automatic routing or scheduler integration
- No coupling to phase-specific workflows
- No generation of multiple report artifacts for one invocation
- No hidden side artifacts as required outputs
