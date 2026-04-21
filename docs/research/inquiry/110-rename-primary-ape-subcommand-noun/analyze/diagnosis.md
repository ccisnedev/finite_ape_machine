---
id: diagnosis
title: "Diagnosis: inquiry as APE's primary CLI noun"
date: 2026-04-20
status: active
tags: [naming, cli, inquiry, peirce, dewey, decision]
author: socrates
---

# Diagnosis: `inquiry` as APE's Primary CLI Noun

This document closes the ANALYZE phase of issue #110 and serves as the sole required input for DESCARTES in the PLAN phase.

---

## 1. Problem Defined

APE needs a primary noun for its CLI subcommand, completing a three-tier trilogy:

| Tool | Command | Abstraction |
|------|---------|-------------|
| GitHub CLI | `gh issue` | Problem tracking: code, commits, PRs |
| GitLab CLI | `gl task` | Coordination: dates, people, priorities |
| APE CLI | `ape ___` | Development: structured epistemic process (A→P→E) |

The chosen noun will:

1. **Name the subcommand:** `ape XXX create`, `ape XXX start`, `ape XXX list`, `ape XXX status`
2. **Name the docs directory:** `docs/XXXs/NNN-slug/` (if applicable)
3. **Define APE's identity** in the CLI ecosystem
4. **Function as a state descriptor:** "it's in XXX"

---

## 2. Decision

The chosen noun is **`inquiry`**.

```
ape inquiry create
ape inquiry start
ape inquiry list
ape inquiry status
```

---

## 3. Rationale

### 3.1 Philosophical Foundation

Charles Sanders Peirce (1878, 1903) identified three modes of inference as the complete taxonomy of reasoning:

- **Abduction** — hypothesis generation from surprising facts
- **Deduction** — derivation of necessary consequences from hypotheses
- **Induction** — empirical testing of derived consequences

These three are necessary and sufficient for complete inquiry (CP 2.775). No inquiry proceeds without all three; no fourth mode exists.

John Dewey (1938, *Logic: The Theory of Inquiry*) defined inquiry as:

> "The controlled or directed transformation of an indeterminate situation into one that is so determinate in its constituent distinctions and relations as to convert the elements of the original situation into a unified whole."

This is exactly what APE does to a GitHub issue: transforms an indeterminate problem into a determinate, merged solution.

References: [peirce-three-modes.md](peirce-three-modes.md), [dewey-inquiry-definition.md](dewey-inquiry-definition.md)

### 3.2 The Mapping: ADI → APE

| Peirce | Mode | APE Phase | Activity |
|--------|------|-----------|----------|
| Abduction | Hypothesis generation | ANALYZE | Diagnose the problem space |
| Deduction | Consequence derivation | PLAN | Derive implementation steps |
| Induction | Empirical testing | EXECUTE | Test through implementation |

The mapping is not metaphorical — it is structural. APE's three phases instantiate Peirce's three inference modes. The FSM enforces the ordering ABD→DED→IND, which Peirce proved is the only logically valid sequence for inquiry.

Reference: [adi-ape-software-mapping.md](adi-ape-software-mapping.md)

### 3.3 Why Not Other Candidates

Fifteen rounds of Socratic analysis evaluated and rejected these candidates:

| Candidate | Rejection Reason |
|-----------|-----------------|
| `cycle` | Describes mechanism (HOW), not nature (WHAT). Breaks tern pattern: `issue`/`task` say WHAT, `cycle` says HOW. "Cycle of what?" remains unanswered. |
| `dev` | Connotes only coding, not epistemic process. Verb-like. Collides with `npm run dev`. |
| `study` | Passive connotation (reading, memorization). Fails to capture active A+P+E totality. |
| `experiment` | Maps only to EXECUTE (testing). Synecdoche — names one phase, not three. |
| `scan` | Mechanical/temporal. No epistemic content. |
| `tick` | Temporal metaphor. No knowledge-process semantics. |
| `epoch` | ML connotation. Temporal, not epistemic. |
| `craft` | Maps only to EXECUTE (making). |
| `work` | Maps only to EXECUTE (doing). Too generic. |
| `build` | Maps only to EXECUTE (constructing). Collides with compilation. |
| `case` | Legal/medical connotation too dominant. |
| `probe` | Too narrow, too punctual. Connotes only ANALYZE. |
| `quest` | Gamified/fantasy connotation. Not professional. |
| `trial` | Legal connotation. Maps only to EXECUTE (testing). |
| `lab` | Names a place, not a process. Semantically distant. |
| `adi` | Opaque acronym. Zero semantic content without prior context. |

**Key insight:** every rejected candidate is a **synecdoche** — it names only one phase of the A+P+E totality. `inquiry` is the only word that captures the complete arc from hypothesis to verification.

### 3.4 The Tern Test

The three tools form a natural progression in abstraction depth:

```
gh issue create   → creates a problem record
gl task create    → creates a work coordination unit
ape inquiry create → creates a structured epistemic investigation
```

Each level increases in depth: **problem → coordination → knowledge**. Each noun operates at a different abstraction level. `inquiry` completes the progression naturally because it names the thing that subsumes both problem-identification and task-coordination into a knowledge-producing process.

### 3.5 Locative Usage

`inquiry` functions naturally as a state descriptor:

- "The bug is in inquiry" ✓ (analogous to "in sprint", "in review")
- "I have issue #234 in inquiry" ✓
- "Start a new inquiry for this feature" ✓

Contrast with rejected candidates:
- "in cycle" ✗ (meaningless without qualifier)
- "in study" ✗ (unnatural in English)
- "in experiment" ✗ (sounds like a test subject)

### 3.6 Reclaiming the Term

APE reclaims `inquiry` in the Peircean technical sense, analogous to how:
- Scrum reclaimed `sprint` (from athletics → time-boxed iteration)
- Git reclaimed `commit` (from law/databases → snapshot)
- Agile reclaimed `story` (from narrative → requirement unit)

The colloquial meaning of inquiry (journalistic investigation, formal questioning) is narrow. The Peircean meaning — a complete ABD→DED→IND cycle that transforms indeterminacy into knowledge — is the technical definition APE adopts.

**Spanish resolution:** `inquiry` is a technical loanword, like `sprint`, `commit`, `deploy`, `issue`. It does not require translation. The CLI operates in English regardless of the operator's natural language.

---

## 4. Constraints and Risks

### Constraints

| Constraint | Impact | Severity |
|------------|--------|----------|
| 7 characters (vs `issue`=5, `task`=4) | Slightly more typing | LOW |
| Less commonly known than `issue`/`task` | Initial learning curve | LOW |
| Spanish speakers may map to "indagación" | Possible semantic drift | LOW |

### Mitigations

- **Ergonomics:** Tab completion, shell history, and aliases (`inq`) address character count
- **Discoverability:** CLI help text (`ape --help`) and onboarding docs explain the term
- **Semantic precision:** The philosophical depth is an asset for documentation and brand identity

### Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| New users don't understand `ape inquiry create` | LOW | MEDIUM | CLI context makes it intuitive; "investigation" is close enough |
| Confusion with journalistic "inquiry" | VERY LOW | LOW | Technical context disambiguates immediately |
| Resistance to philosophical terminology | LOW | LOW | The word is English and accessible; philosophy is in docs, not UX |

---

## 5. Scope

### In scope for issue #110

- [x] Choose the noun → `inquiry`
- [x] Document the rationale → this document
- [ ] Implementation plan → deferred to PLAN phase (DESCARTES)

### Out of scope (insights captured for future work)

These emerged during analysis and should migrate to `docs/research/`:

1. **Artifact persistence architecture** — inquiry artifacts as ephemeral working memory vs. permanent knowledge
2. **DARWIN as Kuhnian evaluator** — post-hoc recognition mechanism that migrates knowledge from `issues/` to `research/`
3. **APE as inverse entropy machine** — the disorder→order transformation as thermodynamic metaphor
4. **Cooperative multitasking between inquiry instances** — signal-based coordination model

---

## 6. Contract with PLAN

DESCARTES receives this diagnosis and must produce a `plan.md` that addresses:

1. CLI implementation: add `inquiry` subcommand with `create`, `start`, `list`, `status` verbs
2. Directory structure: decide on `docs/inquiries/` vs. retain `docs/issues/`
3. FSM integration: how `ape inquiry start` triggers IDLE→ANALYZE transition
4. Migration strategy: existing `docs/issues/` content
5. Documentation: update CLI help, README, and spec

---

## 7. References

| Document | Content |
|----------|---------|
| [peirce-three-modes.md](peirce-three-modes.md) | Peirce's three modes of inference |
| [dewey-inquiry-definition.md](dewey-inquiry-definition.md) | Dewey's canonical definition of inquiry |
| [adi-ape-software-mapping.md](adi-ape-software-mapping.md) | ADI→APE structural isomorphism |
| [pragmatist-implications.md](pragmatist-implications.md) | 9 implications of pragmatist anchoring |
| [darwin-kuhnian-evaluator.md](darwin-kuhnian-evaluator.md) | DARWIN as post-hoc Kuhnian evaluator |
| `docs/research/inquiry/` | Extended research documents |
