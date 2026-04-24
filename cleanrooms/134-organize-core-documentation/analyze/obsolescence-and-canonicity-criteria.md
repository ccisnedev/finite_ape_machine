---
id: obsolescence-and-canonicity-criteria
title: "Obsolescence and canonicity criteria for issue #134"
date: 2026-04-22
status: active
tags: [obsolescence, canonical-home, documentation, taxonomy, scope]
author: socrates
---

# Obsolescence and Canonicity Criteria for Issue #134

## Abstract

Issue #134 cannot be resolved by assuming that the four proposed target documents are already the correct documentary center of gravity. Before any reorganization judgment can be trusted, the analysis must establish criteria for three distinctions: obsolete versus historical versus still-current but duplicated material; canonical home versus cross-reference; and proposed target documents versus documents that may prove more primary once repository evidence is examined. This paper argues that obsolescence should be defined narrowly, that canonical homes are concept-dependent rather than globally fixed, and that document primacy must be discovered through evidence about concept ownership and reader reliability rather than inferred from the issue title alone. The argument is grounded in repository evidence about existing documentation layers and in analysis-session clarifications dated 2026-04-22. [1][2][3][4][5][6]

## 1. Decision Frame

### 1.1 The present problem concerns reliability under archival drift

The prior analysis already established that issue #134 is best framed as a documentation-taxonomy problem under archival drift rather than as an internal dispute about terminology. What must now be added is a criterion for deciding when a document ceases to be a trustworthy guide for readers. In a repository whose documentation is already distributed across specification, research, architectural, and lore layers, the main risk is not mere multiplicity. The main risk is that readers encounter the wrong document first and are therefore led toward a false model of the system. [1][2][3][4][5]

### 1.2 Three judgments must remain analytically separate

Three judgments should not be collapsed into one. First, whether a document is current, historical, or obsolete. Second, whether a concept has a single canonical home or is merely mentioned in a given document as supporting context. Third, whether the four proposed documents of issue #134 are in fact the most important documentary targets, or only initial hypotheses that analysis must test. Conflating these judgments would produce premature consolidation and would risk replacing one form of archival drift with another. [5][6]

## 2. Criteria for Documentary Status

### 2.1 Obsolete

A document should be considered obsolete only under one of two conditions: either it is no longer relevant to the current repository and its active conceptual structure, or it poses a meaningful risk of inducing false understanding in present readers. This criterion is intentionally narrow. Age alone is not obsolescence. Redundancy alone is not obsolescence. A document becomes obsolete when its continued ordinary visibility is more likely to distort understanding than to support it. This standard follows the analysis-session clarification that obsolescence is tied to irrelevance or to the risk of false understanding, not merely to supersession in time. [6]

This definition matters because the repository already preserves several documentation functions. A research text may remain useful as intellectual grounding even when it is not the best user-facing explainer. A lore document may remain current for symbolic identity even when it is not the right place for technical specification. Obsolescence should therefore be reserved for documents that no longer serve a legitimate explanatory or historical role, or that actively misdirect readers about present reality. [1][2][3][4]

### 2.2 Historical

Historical documents are not obsolete. A document is historical when it remains relevant as evidence of prior reasoning, architectural evolution, or conceptual development, but should not be treated as the primary source for current understanding without explicit status signaling. The prior analysis already concluded that later work must distinguish canonical, historical, and obsolete materials. That distinction implies a stable middle category: documents that retain interpretive value because they explain how the system arrived at its current shape, even if they should no longer function as the first explanation a new reader encounters. [5]

The practical significance of the historical category is that it preserves traceability without allowing archival materials to masquerade as current doctrine. A historical document may still be necessary when the question is why a concept evolved, which tradeoff was once accepted, or which meaning a term previously carried. It becomes problematic only when repository organization fails to signal that temporal and interpretive status clearly enough for readers. [5][6]

### 2.3 Still-current but duplicated

Some documents may remain materially correct and therefore still current, while nevertheless duplicating concepts whose authoritative explanation belongs elsewhere. This is a distinct category from both obsolete and historical material. A duplicated document does not necessarily mislead because its claims are false. It misleads because it competes with another document for conceptual ownership, thereby making it unclear where readers should go for the authoritative formulation. [1][2][3][4][6]

The analysis-session clarification states the governing rule succinctly: one concept in one place, while other documents should reference rather than duplicate. Under that rule, duplication is a canonicity problem rather than an obsolescence problem. A duplicated document may remain current if it is accurate, but it should not continue to restate a concept as though it were co-equal with the canonical source. Its proper role is cross-reference, contextual summary, or scoped application. [6]

## 3. Criteria for Canonical Homes and Cross-References

### 3.1 Canonical home

A canonical home is the single document that owns the authoritative explanation of a concept. It is the place where the concept is defined at full scope, where changes to that concept should be maintained first, and where readers should be directed when they need the most reliable account. Repository evidence already suggests that canonical homes are differentiated by documentary function. The spec index defines `docs/spec/` as the home of technical specifications and architectural references. The inquiry research index defines `docs/research/inquiry/` as the home of the philosophical foundations of inquiry. The architecture document explains APE as an orchestrated finite-state system. The lore document explains symbolic identities, allegories, and thinking-tool personas. These are not interchangeable explanatory layers. [1][2][3][4]

From this evidence, the canonical-home policy cannot be universal in the sense of assigning one top-level directory as the home of every important idea. It must instead be concept-dependent. A concept should live where its full and most stable explanatory frame belongs. Philosophical grounding belongs where philosophical grounding is maintained. Technical system behavior belongs where technical architecture is maintained. Allegorical identity belongs where allegorical identity is maintained. [1][2][3][4][6]

### 3.2 Cross-reference

A cross-reference is justified when a concept is relevant to a document's argument but is not owned by that document. The purpose of cross-reference is not to avoid explanation altogether. Its purpose is to avoid re-defining a concept at full scope when that authority already exists elsewhere. Cross-reference therefore preserves local readability while protecting canonicity. It allows a document to situate the reader without silently becoming a rival home for the same concept. [5][6]

This distinction is especially important in issue #134 because terms such as Inquiry, APE, Finite APE Machine, and Thinking Tools are related but non-identical. A document may legitimately describe how one of these concepts interacts with another while still pointing elsewhere for the canonical definition. The prior taxonomy paper established those boundary distinctions; the present criterion adds that each boundary should be maintained by reference discipline, not by uncontrolled repetition. [5]

### 3.3 Reader and use-case dominance

The choice of canonical home should be governed by the reader or use case whose misunderstanding would produce the highest interpretive cost. Repository evidence already shows distinct readership functions: technical readers looking for specification and architecture, conceptual readers looking for inquiry foundations, and readers seeking the narrative identity of the agents and their thinking tools. Because these functions differ, canonicity should be assigned according to the dominant explanatory burden of the concept in question rather than according to a blanket preference for one document type. [1][2][3][4]

This criterion does not yet answer which reader should dominate in every contested case; that remains an evidentiary question for further analysis. It does, however, establish the governing standard: the canonical home of a concept should minimize the probability that its highest-priority reader will form a false or fragmented understanding. [6]

## 4. Why the Primacy of the Four Proposed Documents Must Not Be Assumed

### 4.1 The issue title identifies candidates, not verdicts

Issue #134 names four proposed documents: `inquiry.md`, `ape.md`, `finite_ape_machine.md`, and `thinking_tools.md`. These should be treated as analytical candidates, not as conclusions already justified. The prior analysis explicitly warned against reducing the issue to terminology alone and clarified that the central task is to determine which concepts are primary, where each concept's canonical explanation belongs, and what marks texts as canonical, historical, or obsolete. That framing leaves open the possibility that some proposed documents are necessary, some are redundant, and some already have more suitable canonical homes elsewhere in the repository. [5][6]

### 4.2 Repository evidence already presents competing primary loci

The repository already exposes potential primary loci that may compete with or subsume some of the proposed target documents. The spec index lists `finite-ape-machine.md` as a project overview and foundational concepts document within the specification layer. The inquiry research index already serves as an organized home for the epistemic foundation of inquiry. The architecture document already presents a system-level explanation of orchestration through the FSM. The lore document already assigns the symbolic and methodological roles of the agents and their thinking tools. This means analysis cannot simply infer that four new or reorganized top-level documents are the most important outputs. It must test whether some concepts are already primarily housed, and whether the real problem is duplication, discoverability, status signaling, or misplaced authority. [1][2][3][4]

### 4.3 Proper analytical consequence

The correct analytical posture is therefore comparative rather than presumptive. For each candidate concept, the question is not "which of the four proposed documents should contain it?" but rather "where is the concept's most reliable canonical home, and what secondary documents should point to it?" Under this criterion, the answer may indeed support one or more of the proposed target documents. It may also show that one of them should remain only as a pointer, that an existing document is already primary, or that an additional document not listed in the issue is the real canonical center. [1][2][3][4][5][6]

## 5. Conclusion

Issue #134 requires a stricter analytical vocabulary before any consolidation judgment can be trusted. Obsolete documents are those that are irrelevant or that risk inducing false understanding. Historical documents remain valuable as records of prior reasoning but should not silently govern current understanding. Still-current duplicated documents are accurate yet non-canonical and should yield authority to a single canonical home. Canonical homes are concept-dependent and should be chosen according to the reader and use case whose misunderstanding would be most costly. Finally, the four proposed documents of issue #134 must be treated as hypotheses to evaluate, not as the answer assumed in advance. [1][2][3][4][5][6]

## References

[1] Finite APE Machine repository. "Spec — Finite APE Machine." `docs/spec/index.md`.

[2] Finite APE Machine repository. "Inquiry as Epistemic Foundation of APE." `docs/research/inquiry/index.md`.

[3] Finite APE Machine repository. "Architecture." `docs/architecture.md`.

[4] Finite APE Machine repository. "The Apes — Lore." `docs/lore.md`.

[5] Finite APE Machine repository. "Taxonomy and scope clarification for issue #134." `cleanrooms/134-organize-core-documentation/analyze/taxonomy-and-scope-clarification.md`.

[6] Analysis-session clarifications with the user regarding issue #134, dated 2026-04-22.