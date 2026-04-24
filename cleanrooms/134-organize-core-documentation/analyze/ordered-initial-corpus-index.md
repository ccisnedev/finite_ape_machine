---
id: ordered-initial-corpus-index
title: "Ordered initial corpus index for issue #134"
date: 2026-04-22
status: active
tags: [corpus, audit, index, ordering, evidence]
author: socrates
---

# Ordered Initial Corpus Index for Issue #134

## Abstract

Issue #134 now has a sufficiently explicit evidence protocol to define an ordered first-pass corpus. Prior analysis established that the problem is archival rather than primarily conceptual for the maintainer, that one canonical home should be forced per concept with references from other documents, that glossary definitions should remain neutral, and that analysis is complete only when the documentation set can be mapped with justified canonical, historical, or obsolete status. The current analysis session further narrowed the reading rule: begin with `docs/research/` and `docs/spec/`, include `docs/architecture.md` and `docs/lore.md` in the initial pass, and defer the rest of the workspace unless a definitional gap, explicit outward reference, material contradiction, or canonicity conflict requires expansion. This document records that first-pass corpus and its ordered traversal so later audit judgments remain reproducible. [1][2][3][4][5][6][7][8]

## 1. Purpose

The function of this index is procedural rather than taxonomic. It does not yet decide which documents are canonical. It defines the initial evidence surface from which such judgments may later be made. Because issue #134 aims at a fully justified mapping of the documentation set, the first-pass corpus must be explicit, ordered, and inspectable. Without that discipline, later claims about duplication, obsolescence, or misplacement would rest on an opaque reading path. [2][3][4][5][7][8]

## 2. Ordered First-Pass Corpus

The ordered first pass begins inside `docs/research/`, continues through `docs/spec/`, and then includes the two standalone documents explicitly admitted into the initial pass by analysis-session clarification.

| Order | Path | Role in first pass | Initial status |
|---|---|---|---|
| 1 | `docs/research/ape_builds_ape/index.md` | Entry index for bootstrap-validation research artifacts | indexed |
| 2 | `docs/research/ape_builds_ape/ape-paper.md` | Theoretical research paper candidate | unread |
| 3 | `docs/research/ape_builds_ape/bootstrap-validation.md` | Empirical bootstrap narrative candidate | unread |
| 4 | `docs/research/ape_builds_ape/experiment-methodology.md` | Research methodology candidate | unread |
| 5 | `docs/research/ape_builds_ape/metrics-schema.md` | Metrics and evidence schema candidate | unread |
| 6 | `docs/research/ape_builds_ape/review-log.md` | Meta-review artifact candidate | unread |
| 7 | `docs/research/inquiry/index.md` | Entry index for philosophical foundation of inquiry | indexed |
| 8 | `docs/research/inquiry/peirce-abduction.md` | Inquiry theory source candidate | unread |
| 9 | `docs/research/inquiry/dewey-inquiry.md` | Inquiry theory source candidate | unread |
| 10 | `docs/research/inquiry/inquiry-cycle-ape-mapping.md` | Mapping from inquiry theory to APE cycle | unread |
| 11 | `docs/research/inquiry/bibliography.md` | Bibliographic support file | unread |
| 12 | `docs/research/swebok/index.md` | Entry index for external software-engineering reference corpus | indexed |
| 13 | `docs/research/swebok/swebok-overview.md` | General external reference candidate | unread |
| 14 | `docs/research/swebok/software-requirements.md` | Domain reference candidate | unread |
| 15 | `docs/research/swebok/software-design.md` | Domain reference candidate | unread |
| 16 | `docs/research/swebok/software-construction.md` | Domain reference candidate | unread |
| 17 | `docs/research/swebok/software-configuration-management.md` | Domain reference candidate | unread |
| 18 | `docs/research/swebok/software-engineering-management.md` | Domain reference candidate | unread |
| 19 | `docs/research/swebok/software-engineering-process.md` | Domain reference candidate | unread |
| 20 | `docs/research/swebok/software-engineering-models-methods.md` | Domain reference candidate | unread |
| 21 | `docs/research/swebok/software-quality.md` | Domain reference candidate | unread |
| 22 | `docs/research/swebok/process-enactment-tools.md` | Domain reference candidate | unread |
| 23 | `docs/spec/index.md` | Entry index for technical specification corpus | indexed |
| 24 | `docs/spec/finite-ape-machine.md` | Foundational specification candidate | unread |
| 25 | `docs/spec/agent-lifecycle.md` | Lifecycle specification candidate | unread |
| 26 | `docs/spec/cooperative-multitasking-model.md` | Coordination model candidate | unread |
| 27 | `docs/spec/signal-based-coordination.md` | Signal model candidate | unread |
| 28 | `docs/spec/orchestrator-spec.md` | Orchestrator contract candidate | unread |
| 29 | `docs/spec/memory-as-code-spec.md` | Documentation-architecture candidate | unread |
| 30 | `docs/spec/inquiry-cli-spec.md` | CLI specification candidate | unread |
| 31 | `docs/spec/cli-as-api.md` | Skills/commands boundary candidate | unread |
| 32 | `docs/spec/target-specific-agents.md` | Target deployment candidate | unread |
| 33 | `docs/architecture.md` | Standalone system explanation admitted into first pass | indexed |
| 34 | `docs/lore.md` | Standalone agent/thinking-tool explanation admitted into first pass | indexed |

## 3. Expansion Triggers Beyond the First Pass

The first pass is not the whole workspace by default. Expansion beyond this ordered corpus is conditional. The current analysis session accepts four legitimate trigger conditions: a definitional gap, an explicit outward reference, a material contradiction, or a canonicity conflict. Any of these conditions may justify leaving the first-pass corpus to inspect `README.md`, other loose documents under `docs/`, or explanatory material elsewhere in the workspace. This staged rule refines earlier whole-workspace language without abandoning the principle that later expansion must remain evidence-driven rather than discretionary. [4][5][6][8]

## 4. Glossary Constraint During the First Pass

The glossary requirement remains active during this audit, but its first-version entries are constrained. Current session clarification narrows the definition policy to clear, independent statements answering only what a term is. This means the glossary should stabilize vocabulary during the first pass without prematurely absorbing extended history, argument, or navigation logic that properly belongs to canonical documents discovered through the audit. [3][4][6][8]

## 5. Conclusion

This ordered corpus index supplies the minimum procedural scaffold for the first evidentiary pass of issue #134. It defines which documents belong to the initial audit, in what order they should be traversed, and under what conditions the audit may legitimately expand outward. That scaffold is necessary because the stated end condition of analysis is not a loose diagnosis but a fully justified mapping of the documentation set with increased clarity. [2][3][4][5][7][8]

## References

[1] Finite APE Machine repository. "APE Builds APE — Research Documents." `docs/research/ape_builds_ape/index.md`.

[2] Finite APE Machine repository. "Inquiry as Epistemic Foundation of APE." `docs/research/inquiry/index.md`.

[3] Finite APE Machine repository. "SWEBOK Research — Index." `docs/research/swebok/index.md`.

[4] Finite APE Machine repository. "Spec — Finite APE Machine." `docs/spec/index.md`.

[5] Finite APE Machine repository. "Architecture." `docs/architecture.md`.

[6] Finite APE Machine repository. "The Apes — Lore." `docs/lore.md`.

[7] Finite APE Machine repository. "Taxonomy and scope clarification for issue #134." `cleanrooms/134-organize-core-documentation/analyze/taxonomy-and-scope-clarification.md`; "Obsolescence and canonicity criteria for issue #134." `cleanrooms/134-organize-core-documentation/analyze/obsolescence-and-canonicity-criteria.md`.

[8] Primary-source analysis-session clarifications dated 2026-04-22 for issue #134: force a single canonical home with references from other documents; keep the glossary neutral; analysis is complete when a fully justified mapping and documentation clarity are achieved; begin with `docs/research/` and `docs/spec/`; include `docs/architecture.md` and `docs/lore.md` in the initial pass; expand outward when a definitional gap, explicit outward reference, material contradiction, or canonicity conflict appears; first glossary entries should be clear, independent definitions answering what a term is.