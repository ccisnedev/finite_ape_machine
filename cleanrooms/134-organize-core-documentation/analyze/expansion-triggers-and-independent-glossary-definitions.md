---
id: expansion-triggers-and-independent-glossary-definitions
title: "Expansion triggers, initial-pass inclusion of architecture and lore, and independent glossary definitions for issue #134"
date: 2026-04-22
status: active
tags: [corpus-expansion, glossary, evidence, architecture, lore]
author: socrates
---

# Expansion Triggers, Initial-Pass Inclusion of Architecture and Lore, and Independent Glossary Definitions for Issue #134

## Abstract

Prior analysis refined the whole-workspace corpus into a staged first pass beginning from `docs/spec/` and the relevant `docs/research/` index, with expansion beyond those indexed foundations treated as conditional rather than automatic. The current analysis session tightens that policy in three ways. First, expansion beyond the first-pass corpus should be governed by multiple explicit trigger conditions rather than by a single undifferentiated notion of evidentiary insufficiency. Second, `docs/architecture.md` and `docs/lore.md` should now be counted inside the initial evidentiary pass, because they are top-level explanatory documents that already bear directly on the concepts under review rather than merely serving as optional secondary context. Third, first-version glossary entries may now be written as clear, independent definitions rather than only as minimal direct labels, because the glossary must support comparison across documentary surfaces without forcing the reader to reconstruct basic term identity from scattered texts. These claims are grounded in repository evidence, prior analysis papers in this cleanroom, and primary-source analysis-session clarifications dated 2026-04-22. [1][2][3][4][5][6][7][8][9]

## 1. Decision Frame

### 1.1 The first-pass policy now needs a sharper account of both entry and expansion

Earlier papers established two important constraints. The admissible evidentiary horizon for issue #134 extends beyond a narrow `docs/spec/`-only or `docs/research/`-only reading, yet first-pass analysis should still begin from a disciplined subset rather than from indiscriminate whole-workspace simultaneity. The staged-entry paper answered that need by proposing an initial pass through `docs/spec/` and the relevant `docs/research/` index, while keeping later expansion available when the initial pass left the matter unresolved. [1][2][5][6]

The current session clarifies that this staged policy must now be expressed more precisely. Expansion is not triggered by one vague condition, but by several analytically distinct conditions. At the same time, the first pass is not limited to indexed subdirectories alone, because `docs/architecture.md` and `docs/lore.md` belong to the initial evidentiary surface. Finally, the glossary's first entries should not be reduced to thin labels that only gesture toward later elaboration; they may and should stand as clear independent definitions. The present paper addresses these three linked refinements as one topic: the evidentiary discipline governing how the first pass begins, when it widens, and what kind of lexical control must accompany it. [3][4][5][6][7][8][9]

## 2. Why Multiple Trigger Conditions Are Acceptable for Leaving the First-Pass Corpus

### 2.1 A single trigger formula would hide different failure modes of first-pass sufficiency

If expansion were governed only by a single phrase such as "insufficient evidence," the policy would be directionally correct but analytically weak. Different kinds of insufficiency imply different evidentiary consequences. A definitional gap means that the first-pass corpus does not yet yield a stable answer to what a target concept is. An explicit outward reference means that an initial-pass document itself points the reader to another documentary surface as necessary for proper understanding. A material contradiction means that two initial-pass surfaces make claims that cannot both govern interpretation without further comparison. A canonicity conflict means that multiple surfaces plausibly compete to serve as the authoritative home for the same concept. These are not interchangeable problems, even if all of them justify widening the corpus. [1][2][3][4][5][6][7][9]

Treating them as distinct triggers improves rigor because it converts expansion from a discretionary impression into a reproducible evidentiary judgment. Another analyst can inspect whether the widening occurred because a term remained undefined, because a document explicitly sent the reader elsewhere, because the corpus contradicted itself, or because concept ownership remained contested. A multi-trigger policy is therefore not looser than a single-trigger policy. It is stricter, because it makes the reasons for leaving the first-pass corpus inspectable and contestable. [5][6][7][9]

### 2.2 Multiple triggers preserve staged discipline without pretending that every unresolved case looks the same

The earlier staged-entry paper was correct to reject automatic expansion from the outset. But once the first pass has begun, the analysis can fail in more than one way. Sometimes the problem is absence: the concept is not defined well enough in the initial pass. Sometimes the problem is dependency: the initial pass explicitly points beyond itself. Sometimes the problem is conflict: the initial pass yields incompatible claims. Sometimes the problem is authority: more than one document appears to own the concept. The existence of multiple triggers therefore reflects the real structure of documentary uncertainty rather than analytical laxity. [3][4][5][6][7][9]

### 2.3 Analytical consequence

Leaving the first-pass corpus should now be governed by a declared set of trigger conditions: definitional gap, explicit outward reference, material contradiction, or canonicity conflict. This keeps expansion conditional rather than automatic while also preventing the analysis from collapsing distinct evidentiary problems into one opaque justification. [5][6][7][9]

## 3. Why `docs/architecture.md` and `docs/lore.md` Belong in the Initial Evidentiary Pass

### 3.1 These documents already carry first-order explanatory weight for the concepts under review

The issue under analysis concerns the organization of documentation for Inquiry, APE, Finite APE Machine, and Thinking Tools. The specification index and inquiry research index are obvious first-pass anchors because they are repository-authored indexes for technical and philosophical foundations. But `docs/architecture.md` and `docs/lore.md` are not remote or optional commentary. The architecture document explains APE as an orchestrated finite-state system, describes the inquiry cycle, names the state-specific roles of SOCRATES, DESCARTES, BASHO, and DARWIN, and situates the relationship among the human, the inquiry CLI, the agent, and repository memory. The lore document explains APE as scheduler rather than sub-agent, assigns SOCRATES to ANALYZE, and defines the thinking-tool identities of the named agents. These are direct contributions to the meaning of the very concepts at issue. [1][2][3][4]

Because of that direct explanatory weight, excluding architecture and lore from the initial pass would artificially privilege indexed subdirectories while postponing two top-level documents that already shape how a reader understands the conceptual family in question. The first pass is supposed to gather the repository's most immediate foundation surfaces, not merely the subset that happen to live under indexed subfolders. On the present evidence, architecture and lore qualify as initial-pass evidence because they already function as foundational cross-layer explanations inside `docs/`. [1][2][3][4][5][6][8][9]

### 3.2 Their initial-pass inclusion is necessary precisely because expansion remains conditional

If architecture and lore were treated as materials to be consulted only after a trigger fired, the initial pass would begin by omitting two documents that are already known to bear directly on the target concepts. That would force the analysis to manufacture an expansion event merely to admit evidence whose relevance is already established. A trigger-based policy should be reserved for uncertain or contingent widening, not for documentary surfaces whose first-order relevance is already plain from repository evidence and prior analysis. [3][4][5][6][7][8][9]

### 3.3 Analytical consequence

The initial evidentiary pass should now include four entry surfaces rather than two kinds of indexed material alone: `docs/spec/index.md`, `docs/research/inquiry/index.md`, `docs/architecture.md`, and `docs/lore.md`. This remains a staged policy because the pass is still narrower than the whole workspace, but it is a stronger staged policy because it includes the top-level explanatory documents that already participate directly in concept formation. [1][2][3][4][5][6][9]

## 4. Why First Glossary Entries May Now Be Clear, Independent Definitions Rather Than Only Minimal Direct Labels

### 4.1 The earlier minimal-label rule solved one problem but now undershoots the evidentiary need

Prior glossary papers were right to insist that the glossary define terms directly and to resist turning it into a second encyclopedia. They also moved toward narrower first-pass formulations, including minimal direct disambiguation and what-it-is-only definitions. Those moves were justified because the glossary's immediate role was lexical stabilization while canonicity remained unsettled. [5][6][8]

The current clarification strengthens rather than rejects that logic. A first glossary entry may remain brief and first-pass in scope, yet it should now be written as a clear, independent definition. The difference matters. A minimal direct label can identify a term without being fully intelligible on its own. An independent definition, by contrast, should allow a reader to understand the basic identity of the term without needing immediate rescue from another document. Once the first pass explicitly includes research, specification, architecture, and lore, and once expansion is triggered by definitional gaps and authority conflicts, the glossary must do more than pin a placeholder label onto each concept. It must furnish a stable sentence-level definition that can be used to compare later evidence across surfaces. [1][2][3][4][5][6][8][9]

### 4.2 Independence is required because glossary entries now function as comparison baselines

The glossary is no longer serving only as a memory aid for the analyst. It now functions as a control instrument for comparing claims across a staged corpus that may widen under several triggers. When a later document contradicts the first-pass understanding of a term, or competes to become its canonical home, the analysis needs a baseline formulation against which that later evidence can be judged. A merely skeletal label is too weak for that task. A clear independent definition is strong enough to stabilize comparison while still remaining shorter and more neutral than a full canonical exposition. [5][6][7][8][9]

### 4.3 Analytical consequence

The first glossary entries for issue #134 may and should now be treated as clear, independent definitions: concise enough to avoid replacing canonical documents, but self-sufficient enough to communicate what the term is without immediate dependency on deferred explanation. This is a stronger first-pass glossary rule than minimal direct labeling, yet it remains compatible with later revision if expanded evidence reveals a better formulation. [5][6][8][9]

## 5. Conclusion

The staged evidentiary policy for issue #134 now has a more precise form. Expansion beyond the first-pass corpus should be governed by several explicit triggers rather than by one undifferentiated appeal to insufficiency. `docs/architecture.md` and `docs/lore.md` belong in the initial pass because they already carry first-order explanatory authority for the concepts under review. And the glossary's first entries may now be written as clear, independent definitions rather than only as minimal direct labels, because the glossary must stabilize comparison across a staged corpus whose widening is conditional and inspectable. These refinements do not yet settle final canonicity outcomes. They clarify the evidentiary discipline required before such outcomes can be trusted. [1][2][3][4][5][6][7][8][9]

## References

[1] Finite APE Machine repository. "Spec - Finite APE Machine." `docs/spec/index.md`.

[2] Finite APE Machine repository. "Inquiry as Epistemic Foundation of APE." `docs/research/inquiry/index.md`.

[3] Finite APE Machine repository. "Architecture." `docs/architecture.md`.

[4] Finite APE Machine repository. "The Apes - Lore." `docs/lore.md`.

[5] Finite APE Machine repository. "Glossary direct-definition and audit navigation requirements for issue #134." `docs/cleanrooms/134-organize-core-documentation/analyze/glossary-and-audit-navigation-requirements.md`.

[6] Finite APE Machine repository. "Staged corpus entry and what-it-is-only glossary policy for issue #134." `docs/cleanrooms/134-organize-core-documentation/analyze/staged-corpus-entry-and-minimal-glossary-policy.md`.

[7] Finite APE Machine repository. "Obsolescence and canonicity criteria for issue #134." `docs/cleanrooms/134-organize-core-documentation/analyze/obsolescence-and-canonicity-criteria.md`.

[8] Finite APE Machine repository. "Glossary necessity and reader-priority clarification for issue #134." `docs/cleanrooms/134-organize-core-documentation/analyze/glossary-need-and-reader-priority.md`.

[9] Primary-source analysis-session clarifications dated 2026-04-22 for issue #134: expansion beyond the first pass may be triggered by definitional gap, explicit outward reference, material contradiction, or canonicity conflict; `docs/architecture.md` and `docs/lore.md` count as part of the initial evidentiary pass; first glossary entries may and should be clear, independent definitions.