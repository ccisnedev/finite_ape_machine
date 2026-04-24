---
id: glossary-need-and-reader-priority
title: "Glossary necessity and reader-priority clarification for issue #134"
date: 2026-04-22
status: active
tags: [glossary, reader-priority, canonicity, evidence, documentation]
author: socrates
---

# Glossary Necessity and Reader-Priority Clarification for Issue #134

## Abstract

Issue #134 now has an additional evidentiary constraint beyond taxonomy and canonicity alone. The analysis can no longer assume that core terms are self-evident to readers, nor that the documents most likely to induce false understanding can be identified in advance from their titles or locations. This paper establishes three claims. First, an explicit glossary is analytically necessary because the relevant vocabulary is distributed across research, specification, architecture, and lore layers while prior analysis has already shown that these terms are related but not interchangeable. Second, canonicity decisions should prioritize the reader trying to understand the project's philosophical and technological foundations, because that reader must traverse those layers together rather than in isolation. Third, document-by-document reading is now an evidentiary requirement rather than optional exploration, because the user cannot yet pre-identify which current texts are most misleading. These claims are grounded in repository evidence and in analysis-session clarifications dated 2026-04-22. [1][2][3][4][5][6][7]

## 1. Why an Explicit Glossary Is Analytically Necessary

### 1.1 Core terminology is distributed across distinct documentary functions

The repository already separates explanatory labor across multiple documentation layers. The specification index presents technical specifications and architectural references, including project overview and foundational concepts. The inquiry research index presents the philosophical foundations of inquiry and explicitly maps them to APE. The architecture document explains the system as a finite state machine and orchestration contract. The lore document explains APE, sub-agents, and thinking tools through an allegorical but still conceptually consequential register. This means a reader encountering issue #134 does not meet a single, centralized vocabulary surface. The same conceptual family is encountered across documents with different explanatory purposes. [1][2][3][4]

### 1.2 The relevant terms are already known to require boundary discipline

The prior taxonomy paper established that Inquiry, APE, Finite APE Machine, and Thinking Tools form a hierarchy of related but non-identical concepts. The current analysis session adds that an explicit glossary is needed for clarity and that the first glossary scope must extend beyond the four target terms to include items such as FSM and RTOS. Once the analysis accepts both claims, the glossary ceases to be a stylistic enhancement. It becomes the minimal instrument for keeping term boundaries stable across subsequent canonicity judgments. [5][7]

### 1.3 Canonicity analysis cannot proceed reliably without controlled term definitions

The prior canonicity paper argued that duplication and canonical ownership are concept-dependent rather than globally fixed. That standard cannot be applied coherently if the analysis lacks a stable lexical baseline for what counts as the same concept, a neighboring concept, or an implementation-specific elaboration. Without an explicit glossary, a later judgment could mistake cross-reference for duplication, or technical operationalization for conceptual identity. The glossary is therefore analytically necessary because it controls the vocabulary on which canonicity and obsolescence judgments depend. [5][6][7]

## 2. Why the Philosophical-and-Technological Foundations Reader Should Dominate Canonicity Decisions

### 2.1 Issue #134 spans both foundational layers at once

The repository's current structure already distinguishes philosophical foundation from technical realization. Inquiry is documented as the epistemic foundation of APE, while the specification and architecture documents present technical and system-level explanations of the finite machine. The lore document adds a third layer in which APE is described as scheduler and RTOS-like event loop while the named sub-agents embody thinking tools. Because issue #134 concerns core documentation for Inquiry, APE, Finite APE Machine, and Thinking Tools, the relevant reader is not merely seeking one isolated layer. The relevant reader is trying to understand how those layers connect. [1][2][3][4]

### 2.2 This reader bears the highest interpretive cost if canonicity is assigned badly

The prior canonicity paper already established that canonical homes should be chosen according to the reader or use case whose misunderstanding would be most costly. The current analysis session makes that abstract standard concrete by naming the dominant reader: someone trying to understand the philosophical and technological foundations. This reader has the highest interpretive burden because any bad canonicity decision will fracture the bridge between inquiry as epistemic process, APE as orchestrating methodology, and Finite APE Machine as engineered operationalization. A reader looking only for a narrow technical detail or only for intellectual ancestry can remain inside one documentary layer; the foundations reader cannot. [2][3][5][6][7]

### 2.3 Analytical consequence

Canonicity judgments for issue #134 should therefore be evaluated against a single controlling question: where would the foundations reader most reliably expect to find the first authoritative explanation that connects philosophical grounding and technical realization without contradiction or unnecessary duplication? This does not yet decide any canonical home. It clarifies whose interpretive success must govern the evidence standard. [1][2][3][6][7]

## 3. Why Document-by-Document Reading Is Now an Evidentiary Requirement

### 3.1 The governing risk is false understanding, not mere archival untidiness

The prior canonicity paper defined obsolescence narrowly: a document is obsolete if it is no longer relevant or if it creates a meaningful risk of false understanding for present readers. That criterion cannot be applied from filename, directory, age, or issue title alone. False understanding depends on what a document actually claims, how it frames concept boundaries, and whether it silently competes with another document for canonical ownership. [6]

### 3.2 The user cannot pre-identify the risky documents

The current analysis session now removes the last plausible shortcut. The user explicitly states that they cannot yet identify which current documents risk false understanding and that those documents must be read individually. Once that clarification is accepted, selective reading based only on prior suspicion becomes evidentially inadequate. The analysis can no longer treat close reading as optional exploration performed only if time permits. [7]

### 3.3 Individual reading is the minimum reliable evidence-gathering procedure

Document-by-document reading follows directly from the combined criteria already established. If canonicity depends on concept ownership, if obsolescence depends on false-understanding risk, and if risky documents cannot be pre-selected in advance, then each candidate document must be inspected on its own terms before it can be classified as canonical, historical, duplicated, or obsolete. Any weaker procedure would rely on proxy signals that earlier analysis has already shown to be insufficient. Document-by-document reading is therefore not exploratory excess; it is the minimum evidentiary procedure compatible with the issue's current standard of rigor. [5][6][7]

## 4. Conclusion

Issue #134 now requires three additional analytical constraints. An explicit glossary is necessary because core terms are distributed across multiple documentary layers yet must remain lexically stable if canonicity judgments are to be coherent. The dominant reader for those judgments is the one trying to understand both philosophical and technological foundations, because that reader must integrate the repository's distinct explanatory layers. And because the user cannot now pre-identify which documents are most misleading, document-by-document reading is a mandatory evidentiary step rather than optional exploration. These clarifications narrow the analysis by specifying both the vocabulary control it requires and the readership whose reliable understanding must anchor subsequent judgments. [1][2][3][4][5][6][7]

## References

[1] Finite APE Machine repository. "Spec - Finite APE Machine." `docs/spec/index.md`.

[2] Finite APE Machine repository. "Inquiry as Epistemic Foundation of APE." `docs/research/inquiry/index.md`.

[3] Finite APE Machine repository. "Architecture." `docs/architecture.md`.

[4] Finite APE Machine repository. "The Apes - Lore." `docs/lore.md`.

[5] Finite APE Machine repository. "Taxonomy and scope clarification for issue #134." `cleanrooms/134-organize-core-documentation/analyze/taxonomy-and-scope-clarification.md`.

[6] Finite APE Machine repository. "Obsolescence and canonicity criteria for issue #134." `cleanrooms/134-organize-core-documentation/analyze/obsolescence-and-canonicity-criteria.md`.

[7] Primary-source analysis-session clarifications dated 2026-04-22 for issue #134: explicit glossary required; dominant reader is the reader seeking philosophical and technological foundations; risky current documents cannot yet be pre-identified and therefore must be read individually.