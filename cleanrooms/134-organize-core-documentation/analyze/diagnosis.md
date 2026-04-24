---
id: diagnosis
title: "Diagnosis for issue #134: justified documentation status map and canonical-home recommendations"
date: 2026-04-22
status: active
tags: [diagnosis, canonicality, mapping, documentation, glossary]
author: socrates
---

# Diagnosis for Issue #134: Justified Documentation Status Map and Canonical-Home Recommendations

## Abstract

Issue #134 is not fundamentally a problem of missing names. It is a problem of documentary authority under accumulation and drift. The repository already contains strong current homes for some core concepts, mixed or historical strata for others, and several outward-facing surfaces that summarize current reality while still carrying stale details. The evidence now supports a precise diagnosis. Inquiry already has a strong canonical philosophical home in `docs/research/inquiry/`. APE, understood as the orchestrating methodological system, is best anchored in `docs/architecture.md`, supported by current lifecycle and coordination specifications. Finite APE Machine does not presently have a fully safe canonical overview, because the file that naturally carries that name preserves an older, more expansive architecture; that concept therefore requires rehabilitation of `docs/spec/finite-ape-machine.md` rather than blind elevation of its current contents. Thinking Tools likewise lacks a clean canonical home: `docs/lore.md` is the strongest current source, but it mixes active terminology with lore and history, so it should become a source and nomenclature document rather than the final glossary home. The reorganization required by issue #134 is therefore selective rather than symmetric across all four named concepts. [1][2][3][4][5][6][7][8][9][10]

## 1. Governing Diagnosis

The audit supports one central claim: the project's documentation problem is a mismatch between current concept ownership and the surfaces through which readers actually encounter the project. Some concepts already have defensible homes, but those homes are obscured by historical residue, duplicated summaries, and inconsistent outward-facing details. Other concepts do not yet have a single reliable home at all. A good reorganization should therefore preserve existing authority where it already exists, rewrite or demote mixed documents where it does not, and avoid creating new top-level concept files merely because their names appear in the issue title. [1][2][3][4][5]

## 2. Concept-by-Concept Canonical-Home Map

| Concept | Canonical decision | Justification | Required action |
|---|---|---|---|
| Inquiry | Keep `docs/research/inquiry/` as canonical home | This corpus already defines inquiry as the epistemic foundation of APE and develops the Peircean and Deweyan grounding coherently | Do not replace with a duplicate doctrinal `inquiry.md`; if needed, create only a short gateway pointing here |
| APE | Elevate `docs/architecture.md` as canonical current home | It best connects methodology, orchestrator role, CLI, agent deployment, and repository memory at a system level for the foundations-oriented reader | Clean stale paths and tighten cross-references so architecture clearly owns the term |
| Finite APE Machine | Reclaim `docs/spec/finite-ape-machine.md` as canonical home only after rewrite | The filename is naturally authoritative, but the current document preserves a larger legacy architecture and cannot safely govern present understanding without qualification | Rewrite the document to reflect the current model; until then treat `cooperative-multitasking-model.md` and `signal-based-coordination.md` as the practical current technical strata |
| Thinking Tools | Create a dedicated canonical glossary/explainer document | `docs/lore.md` is currently the richest source, but it mixes nomenclature, allegory, active roster, and historical residue, which makes it too blended to serve as a clean canonical home | Introduce a dedicated Thinking Tools document; keep `docs/lore.md` as source material and historical/nomenclature companion |

This map is intentionally asymmetrical. Inquiry and APE already have defensible current homes. Finite APE Machine and Thinking Tools do not. The reorganization should follow that evidence rather than imposing a symmetrical four-file outcome simply because four names were proposed at the outset. [1][3][4][5][6][7][8][9]

## 3. Document Status Map

| Document or surface | Status | Justification | Recommended role |
|---|---|---|---|
| `docs/research/inquiry/index.md` and core inquiry papers | canonical current | Strongest coherent development of inquiry as philosophical and epistemic foundation | Own Inquiry; other surfaces should reference it |
| `docs/architecture.md` | canonical current candidate | Best current system-level explanation of APE as orchestrated methodology, though still affected by stale paths | Own APE after cleanup |
| `docs/spec/agent-lifecycle.md` | current supporting | Aligns with current five-state/four-sub-agent model | Supporting spec under APE and Finite APE Machine |
| `docs/spec/cooperative-multitasking-model.md` | current supporting | Clean current technical explanation of scheduler and two-level FSM structure | Supporting spec; temporary technical anchor while `finite-ape-machine.md` is rewritten |
| `docs/spec/signal-based-coordination.md` | current supporting | Current RTOS-style signal/event explanation | Supporting spec for Finite APE Machine |
| `docs/lore.md` | mixed current and historical | Strong on nomenclature and thinking-tool identities, but blended with allegory, extended lore, and drift | Source and historical companion, not sole canonical home for Thinking Tools |
| `docs/spec/finite-ape-machine.md` | historical or mixed, rewrite-required | Same-name authority is undermined by older multi-agent architecture and legacy states | Rewrite and reclaim as canonical technical overview |
| `docs/spec/orchestrator-spec.md` | historical | Preserves earlier orchestrator architecture with expanded agent roster and REVIEW-era structure | Keep as historical design record |
| `docs/spec/memory-as-code-spec.md` | mixed historical | Still conceptually important, but tied to older agents and older write-zone assumptions | Split or revise when memory docs are reorganized |
| `docs/spec/inquiry-cli-spec.md` | mixed planned | Contains real CLI intent but also planned surfaces and outdated assumptions | Keep as planning/specification material, not canonical current behavior |
| `docs/spec/cli-as-api.md` | current supporting with drift | Principle remains useful, but paths and some naming are stale | Keep after path cleanup |
| `docs/spec/target-specific-agents.md` | current supporting with drift | Strategic decision remains current, but path references are stale | Keep after path cleanup |
| `README.md` | current derivative | Public orientation surface aligned in broad story but stale in version and artifact paths | Entry surface only; reduce operational detail |
| `docs/roadmap.md` | strategic current, operationally mixed | Valuable for theses and evolution narrative, but stale on current version and END-state status | Strategic planning only; not current-state authority |
| `code/site/index.html` | current derivative | Public gateway aligned with current branding and release version | Entry surface only |
| `code/vscode/docs/ape_vscode_extension.md` | obsolete-risky draft | Draft spec diverges from actual extension manifest, naming, commands, and artifact paths | Demote, archive, or rewrite before treating as current |

## 4. Consequences for the Four Proposed Documents

### 4.1 `inquiry.md`

The evidence does not justify a full new doctrinal `inquiry.md` as the primary home of Inquiry. The project already has that home in `docs/research/inquiry/`. If a new reader-facing document is still desired, it should be a short bridge or map to the existing inquiry corpus rather than a competing full explanation. [1][3][6]

### 4.2 `ape.md`

The evidence does not justify a separate `ape.md` if `docs/architecture.md` is strengthened and made explicit as the authoritative current explanation of APE. A new `ape.md` would likely duplicate the architecture document unless it were reduced to a short pointer. [1][3][4]

### 4.3 `finite_ape_machine.md`

Here the issue title is substantively right, but not in the naive sense. The current same-named file is not ready to act as canonical authority. It should be rewritten, not merely retained. The proper action is to reclaim that filename as the authoritative technical overview of the current finite-state, signal-driven, scheduler-based system. [4][7][8]

### 4.4 `thinking_tools.md`

This is the concept for which a new dedicated file is most clearly justified. The project already uses the category, but the current evidence is spread across lore and active-model documents. A dedicated Thinking Tools document would improve clarity without displacing an already-clean home, because no such home presently exists. [1][4][5][9]

## 5. Minimum Reorganization Outcome That Actually Solves the Problem

The smallest reorganization that satisfies the evidence is the following:

1. Preserve `docs/research/inquiry/` as the canonical Inquiry corpus.
2. Elevate and clean `docs/architecture.md` as the canonical current explanation of APE.
3. Rewrite `docs/spec/finite-ape-machine.md` to match the current architecture and reclaim its name.
4. Create one dedicated Thinking Tools document built from current-model evidence and supported by, but not collapsed into, `docs/lore.md`.
5. Demote README, site, roadmap, and the VS Code extension draft to clearly non-canonical roles, each with sharper cross-references and reduced authority claims.

Any broader rewrite can still be justified later, but this is the minimum evidence-aligned set of changes. It improves clarity without discarding the repository's existing authoritative strata. [1][2][6][10]

## 6. Conclusion

Issue #134 should end not with a cosmetic redistribution of names, but with a clearer doctrine of documentary authority. Inquiry already has a home. APE already has a plausible home. Finite APE Machine needs its natural home rewritten and reclaimed. Thinking Tools needs a true home created. Everything else should be reorganized around those authority decisions, with historical and derivative surfaces marked as such. That is the fully justified map supported by the current repository evidence. [1][2][3][4][5][6][7][8][9][10]

## References

[1] Finite APE Machine repository. "Taxonomy and scope clarification for issue #134." `cleanrooms/134-organize-core-documentation/analyze/taxonomy-and-scope-clarification.md`.

[2] Finite APE Machine repository. "Obsolescence and canonicity criteria for issue #134." `cleanrooms/134-organize-core-documentation/analyze/obsolescence-and-canonicity-criteria.md`.

[3] Finite APE Machine repository. "First-pass findings on current documentation strata for issue #134." `cleanrooms/134-organize-core-documentation/analyze/first-pass-findings-on-current-document-strata.md`.

[4] Finite APE Machine repository. "Expanded entry-surface findings and contradiction synthesis for issue #134." `cleanrooms/134-organize-core-documentation/analyze/expanded-entry-surface-findings.md`.

[5] Finite APE Machine repository. "Expansion triggers, initial-pass inclusion of architecture and lore, and independent glossary definitions for issue #134." `cleanrooms/134-organize-core-documentation/analyze/expansion-triggers-and-independent-glossary-definitions.md`.

[6] Finite APE Machine repository. "Inquiry as Epistemic Foundation of APE." `docs/research/inquiry/index.md`.

[7] Finite APE Machine repository. "Finite APE Machine." `docs/spec/finite-ape-machine.md`.

[8] Finite APE Machine repository. "Cooperative multitasking model — two-level FSM architecture." `docs/spec/cooperative-multitasking-model.md`; "Signal-based coordination — RTOS event model for agent communication." `docs/spec/signal-based-coordination.md`.

[9] Finite APE Machine repository. "Architecture." `docs/architecture.md`; "The Apes — Lore." `docs/lore.md`.

[10] Finite APE Machine repository. "Inquiry." `README.md`; "Roadmap." `docs/roadmap.md`; "Inquiry — Analyze. Plan. Execute." `code/site/index.html`; "APE VS Code Extension — Architecture & Specification." `code/vscode/docs/ape_vscode_extension.md`.