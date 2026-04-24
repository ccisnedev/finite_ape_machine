---
id: corpus-boundary-and-ordering-policy
title: "Corpus boundary, directory-order traversal, and minimal-definition glossary policy for issue #134"
date: 2026-04-22
status: active
tags: [corpus-boundary, audit-order, glossary, documentation, evidence]
author: socrates
---

# Corpus Boundary, Directory-Order Traversal, and Minimal-Definition Glossary Policy for Issue #134

## Abstract

Prior analysis established that issue #134 is a documentation-taxonomy problem under archival drift, that the relevant reader is the one seeking both philosophical and technological foundations, and that a glossary plus an auditable reading procedure are analytically necessary. The present paper fixes three narrower operational policies that now follow from both repository evidence and analysis-session clarifications dated 2026-04-22. First, the evidentiary corpus should begin at the scale of the whole workspace rather than at `docs/` alone, because explanatory material already appears in the repository root and within `code/` as well as within `docs/`. Second, directory order should be treated as part of the audit protocol, because ordered traversal must be reproducible and the repository's own path hierarchy is the most repository-native default sequence currently available. Third, first-version glossary entries should be minimal direct disambiguation statements, because the glossary's immediate analytical role is to stabilize term boundaries for the audit rather than to become a second encyclopedia of the system. [1][2][3][4][5][6][7][8][9]

## 1. Why the Evidentiary Corpus Now Includes the Whole Workspace Rather Than `docs/` Alone

### 1.1 Explanatory material is already distributed across root, `docs/`, and `code/`

The repository root is not a neutral wrapper around the documentation set. The root `README.md` introduces Inquiry, states the APE cycle, points readers toward architecture, specification, research, ADRs, issues, and lore, and even embeds visual material from `code/site/`. This means the reader's first model of the system can already be shaped before entering `docs/`. [5]

Nor is explanatory material confined to top-level documentation roots. The repository's main documentation layer remains important: the specification index defines canonical technical references, the inquiry research index defines the epistemic foundation of APE, `docs/architecture.md` explains the orchestrated finite-state system, and `docs/lore.md` explains the agents and thinking tools. Yet the workspace also contains explanatory documents inside `code/`. The site banner specification in `code/site/docs/spec/banner.md` interprets the project's strategic meaning, the Analyze-Plan-Execute triad, and the status of Socrates, Descartes, and Basho as thinking tools. The VS Code extension architecture document in `code/vscode/docs/ape_vscode_extension.md` explains how the editor extension is intended to operationalize the APE cycle. These are not mere implementation comments. They are documentary surfaces that shape interpretation of the same conceptual family at issue in #134. [1][2][3][4][5][6][7]

### 1.2 A `docs/`-only corpus would therefore pre-filter evidence before analysis begins

Prior analysis already established that risky or misleading documents cannot yet be identified in advance and must therefore be read rather than assumed away. Once that premise is combined with the present session's clarification that "all" means the entire workspace, including documentation and code, a `docs/`-only audit becomes analytically inconsistent. It would exclude some explanatory surfaces before the audit has earned the right to classify them as secondary, derivative, or out of scope. [8][9]

The point is not that every file in the workspace will ultimately deserve equal interpretive weight. The point is that admissibility judgments must follow evidence rather than precede it. When documentation about core concepts already exists in root-level entry surfaces and in code-adjacent design documents, the corpus boundary cannot be set at `docs/` without importing a bias in favor of one documentary region before canonicity has been evaluated. [1][5][6][7][8][9]

### 1.3 Analytical consequence

For issue #134, the audit should begin from the whole workspace as the prima facie evidentiary corpus. Later analysis may still distinguish canonical sources from historical notes, implementation-local explanations, and low-authority derivative material. But those are downstream classification judgments. They do not justify a `docs/`-only starting boundary. [6][8][9]

## 2. Why Directory Order Is Now Part of the Audit Protocol

### 2.1 Ordered traversal was already necessary; the current clarification now supplies its default principle

The prior navigation paper already established that reading all relevant material in order is an evidentiary commitment rather than a convenience, because sequence affects how provisional term boundaries are formed and later revised. The current analysis session adds the missing operational rule: reading order should follow directory order. This clarification does not arise from aesthetic preference. It supplies a reproducible traversal rule for a corpus that now spans the whole workspace. [8][9]

### 2.2 Directory order is the most repository-native default sequence currently available

The repository already expresses a path hierarchy that readers encounter as structure: the root `README.md` frames the project at entry; top-level directories such as `docs/` and `code/` divide documentary and implementation regions; local indexes such as `docs/spec/index.md` and `docs/research/inquiry/index.md` organize subcorpora within those regions. Directory order therefore turns an existing repository artifact into an explicit audit procedure. It minimizes private analyst discretion by letting the repository's own arrangement supply the default route. [1][2][5][8]

This matters because issue #134 concerns not only what documents exist, but also what a reader is likely to encounter first. If sequence remains implicit or ad hoc, later judgments about duplication, canonicity, and false-understanding risk become harder to reproduce. Directory order does not guarantee the correct interpretation by itself. It does, however, make the audit's first pass inspectable by another reader who can follow the same route and challenge its results. [6][8][9]

### 2.3 Analytical consequence

Directory order is now part of the audit protocol because completeness without declared sequence is insufficient for reproducible analysis. The policy makes path hierarchy part of the evidence procedure rather than a private convenience of the analyst. It also creates a clear place for later disputes: if the order is wrong, the disagreement can be stated against an explicit rule rather than against an invisible personal reading path. [8][9]

## 3. Why First-Version Glossary Entries Should Be Minimal Direct Disambiguation Statements

### 3.1 Prior analysis established direct definition; the present clarification narrows its form

Earlier analysis already established that the glossary should define terms directly rather than function merely as a hub of deferred references, and that the glossary may expand iteratively as the audit proceeds. The current analysis session adds a more exact standard for the first version: the earliest glossary definitions should be minimal direct definitions focused on disambiguation. [8][9]

### 3.2 Minimality is required because the glossary's immediate task is boundary control

The glossary's first analytical job is not to retell the whole repository. It is to keep adjacent terms from collapsing into one another while the audit is still determining canonical homes and duplicate surfaces. Prior taxonomy analysis already showed that Inquiry, APE, Finite APE Machine, and Thinking Tools are related but non-identical terms. A first-version glossary entry therefore succeeds when it states, as directly as possible, what the term denotes and how it differs from its nearest conceptual neighbors. That is the minimum information needed to stabilize subsequent judgments about overlap, cross-reference, and false-understanding risk. [6][7][8][9]

If the glossary instead begins with expansive mini-essays, two analytical problems follow. First, the glossary starts competing with the very canonical documents whose status is still under review. Second, the audit inherits unnecessary prose volume before it has secured the narrow lexical distinctions on which later document classification depends. Minimality is therefore not a concession to incompleteness. It is a way to preserve direct definition without prematurely turning the glossary into a second documentary center. [6][7][8]

### 3.3 Analytical consequence

A first-version glossary entry should be a minimal direct disambiguation statement: short, explicit, and boundary-focused. It should say what the term is in the current project vocabulary and what distinction it must preserve against adjacent terms. Richer history, implementation detail, and extended exposition may follow later if the audit shows they belong there. But the first-pass glossary should stabilize vocabulary before it attempts completeness. [6][7][8][9]

## 4. Conclusion

Issue #134 now has three additional operating policies that materially constrain the audit. The evidentiary corpus should begin at the whole-workspace level because explanatory surfaces already exist in the repository root, in `docs/`, and within `code/`. Directory order should be part of the audit protocol because reproducible sequence is now required and the repository's own path hierarchy is the least arbitrary available default. And the first glossary should begin with minimal direct disambiguation statements because the glossary's immediate analytical role is lexical stabilization, not exhaustive exposition. These policies do not yet settle canonicity outcomes. They determine the evidentiary discipline under which those later outcomes can be trusted. [1][2][3][4][5][6][7][8][9]

## References

[1] Finite APE Machine repository. "Spec - Finite APE Machine." `docs/spec/index.md`.

[2] Finite APE Machine repository. "Inquiry as Epistemic Foundation of APE." `docs/research/inquiry/index.md`.

[3] Finite APE Machine repository. "Architecture." `docs/architecture.md`.

[4] Finite APE Machine repository. "The Apes - Lore." `docs/lore.md`.

[5] Finite APE Machine repository. "Inquiry." `README.md`.

[6] Finite APE Machine repository. "Taxonomy and scope clarification for issue #134." `cleanrooms/134-organize-core-documentation/analyze/taxonomy-and-scope-clarification.md`.

[7] Finite APE Machine repository. "Glossary direct-definition and audit navigation requirements for issue #134." `cleanrooms/134-organize-core-documentation/analyze/glossary-and-audit-navigation-requirements.md`.

[8] Finite APE Machine repository. "Finite APE Machine Banner Specification." `code/site/docs/spec/banner.md`; "APE VS Code Extension - Architecture & Specification." `code/vscode/docs/ape_vscode_extension.md`.

[9] Primary-source analysis-session clarifications dated 2026-04-22 for issue #134: "all" means the entire workspace, including documentation and code; reading order should follow directory order; first glossary definitions should be minimal direct definitions focused on disambiguation.