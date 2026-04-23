---
id: plan
title: "Plan for issue #134: reorganize documentation authority inside docs/"
date: 2026-04-22
status: active
tags: [documentation, canonicality, architecture, finite-ape-machine, thinking-tools]
author: descartes
---

# Plan for Issue #134: Reorganize Documentation Authority Inside docs/

**Hypothesis:** If we reorganize only the `docs/` tree around the canonical-home map established in the diagnosis, then a foundations-oriented reader will be able to find one authoritative home per core concept without being misled by mixed, duplicated, or historical surfaces.

**Diagnosis verified:** The analysis corpus now supports an asymmetrical solution. Inquiry already has a canonical home in `docs/research/inquiry/`. APE should be owned by `docs/architecture.md`. `docs/spec/finite-ape-machine.md` must be rewritten before it can safely serve as a canonical current overview. Thinking Tools requires a dedicated document. Current-supporting docs need path cleanup and sharper cross-references; historical or mixed docs need explicit status signaling. Per the current user instruction, execution scope is limited to `docs/` and its contents. Root `README.md`, site files, and `code/vscode/docs/` remain outside this execution scope even when the diagnosis classified them. [1][2][3]

---

## Phase 1 — Canonical navigation inside docs/

**Objective:** Make the documentation tree itself express the canonical-home map before rewriting content in depth.

**Dependencies:** Diagnosis complete.

### Changes

- [x] Update `docs/spec/index.md` so it no longer presents all specification documents as co-equal current authorities.
- [x] Make `docs/spec/index.md` explicitly route readers to:
  - Inquiry → `docs/research/inquiry/`
  - APE → `docs/architecture.md`
  - Finite APE Machine → `docs/spec/finite-ape-machine.md`
  - Thinking Tools → new `docs/thinking-tools.md`
- [x] Add concise status signaling in `docs/spec/index.md` for current-supporting versus historical-or-planned specs.
- [x] If needed for readability, add one short cross-reference in `docs/research/inquiry/index.md` clarifying that it is the canonical philosophical home of Inquiry.

### Test

- Read `docs/spec/index.md` top-to-bottom and confirm that each of the four core concepts has exactly one named destination.
- Confirm that no second document is presented in the same index as a co-equal home for the same concept.

### Risks

- Over-correcting the index into a changelog of statuses instead of a navigation surface.
- Accidentally demoting a supporting technical spec that should remain easy to discover.

---

## Phase 2 — Reclaim `docs/spec/finite-ape-machine.md`

**Objective:** Rewrite the same-named flagship spec so it reflects the current model rather than the older expansive roster.

**Dependencies:** Phase 1 complete, because the rewritten file must land inside an already clarified navigation structure.

### Changes

- [x] Rewrite `docs/spec/finite-ape-machine.md` around the current architecture:
  - finite-state orchestration
  - scheduler role of APE
  - Inquiry as the cycle-level process
  - signal/event coordination
  - END and opt-in EVOLUTION in the current cycle model
- [x] Remove or relocate claims that present MARCOPOLO, VITRUVIUS, SUNZI, GATSBY, ADA, DIJKSTRA, BORGES, and HERMES as active architectural peers in the current implementation.
- [x] Preserve historically valuable material only if it is clearly labeled as historical context or appendix material.
- [x] Add cross-references from the rewritten spec to `docs/research/inquiry/`, `docs/architecture.md`, `docs/spec/cooperative-multitasking-model.md`, and `docs/spec/signal-based-coordination.md`.

### Test

- Compare the rewritten `docs/spec/finite-ape-machine.md` against `docs/architecture.md`, `docs/spec/cooperative-multitasking-model.md`, and `docs/spec/signal-based-coordination.md` and confirm that the current-state model matches across all four surfaces.
- Grep the rewritten file for legacy-agent names and verify they appear only in explicitly historical context, if at all.

### Risks

- Losing valuable historical rationale while removing legacy architecture.
- Rewriting too narrowly and duplicating `docs/architecture.md` instead of giving `finite-ape-machine.md` its own technical-overview role.

---

## Phase 3 — Create Thinking Tools canonical home and reposition lore

**Objective:** Give Thinking Tools a clean canonical document while preserving `docs/lore.md` as nomenclature and historical companion.

**Dependencies:** Phase 1 complete.

### Changes

- [x] Create new `docs/thinking-tools.md` as the canonical current explanation of Thinking Tools.
- [x] Define the category directly and map current tools to phases and agents without collapsing the document into lore.
- [x] Use repo-native hyphenated naming (`thinking-tools.md`) even though the issue title used underscore spelling.
- [x] Update `docs/lore.md` so it explicitly states its role as nomenclature, allegory, and historical context rather than the sole canonical home of Thinking Tools.
- [x] Add forward references between `docs/thinking-tools.md`, `docs/lore.md`, and `docs/architecture.md`.

### Test

- Read `docs/thinking-tools.md` alone and confirm it explains the concept without requiring lore to rescue basic comprehension.
- Read the first sections of `docs/lore.md` and confirm a reader is immediately directed to `docs/thinking-tools.md` for the current canonical explanation.

### Risks

- Creating a Thinking Tools document that merely duplicates `docs/lore.md`.
- Over-sanitizing lore and erasing the symbolic layer that still has documentary value.

---

## Phase 4 — Align current-supporting docs and mark mixed surfaces clearly

**Objective:** Remove high-risk drift from current-supporting docs and add explicit status signaling to mixed or historical docs that remain in `docs/`.

**Dependencies:** Phases 2 and 3 complete.

### Changes

- [x] Update `docs/architecture.md` so it explicitly owns APE as the orchestrating methodology and uses current artifact paths under `docs/cleanrooms/` where it is describing current workflow.
- [x] Update current-supporting docs as needed for consistency and path drift:
  - `docs/spec/agent-lifecycle.md`
  - `docs/spec/cooperative-multitasking-model.md`
  - `docs/spec/signal-based-coordination.md`
  - `docs/spec/cli-as-api.md`
  - `docs/spec/target-specific-agents.md`
- [x] Add clear historical-or-mixed-status notes near the top of the following docs without rewriting them into current doctrine:
  - `docs/spec/orchestrator-spec.md`
  - `docs/spec/memory-as-code-spec.md`
  - `docs/spec/inquiry-cli-spec.md`
  - `docs/roadmap.md`
- [x] Ensure `docs/roadmap.md` is framed as strategic direction rather than the source of current operational truth.

### Test

- Search the updated current-supporting docs for `docs/issues/` and confirm that remaining matches are either removed or explicitly historical.
- Read the opening note of each mixed/historical document and confirm that a new reader would not mistake it for the current authoritative model.

### Risks

- Treating every stale path as a reason for full rewrite when a narrower status note is enough.
- Leaving ambiguous mixed docs without a strong enough warning to prevent false understanding.

---

## Phase 5 — Validation pass across docs/

**Objective:** Confirm that the modified docs tree behaves as one coherent documentation system.

**Dependencies:** Phases 1–4 complete.

### Changes

- [x] Re-read the canonical set in order:
  - `docs/research/inquiry/index.md`
  - `docs/architecture.md`
  - `docs/spec/finite-ape-machine.md`
  - `docs/thinking-tools.md`
- [x] Re-read `docs/spec/index.md` and confirm the navigation still matches the final state of the files.
- [x] Fix any broken relative links introduced during execution.
- [x] Update status notes or cross-references if validation reveals a remaining ambiguity.

### Test

- Manual link validation in VS Code markdown preview for all modified docs.
- Focused search for the core terms `Inquiry|APE|Finite APE Machine|Thinking Tools` inside `docs/` and confirm the first explanatory hit for each term points to the intended canonical home.
- Focused search for `docs/issues/` inside modified current docs and confirm no accidental current-path drift remains.

### Risks

- Link integrity drift after moving or renaming conceptual destinations.
- Remaining contradictory summaries in supporting docs after the core rewrite is complete.

---

## Out of Scope for This Execution

- Root `README.md`
- `code/site/`
- `code/vscode/docs/ape_vscode_extension.md`

These surfaces were classified during analysis and may need later follow-up, but they are outside the current user-authorized execution scope, which is limited to `docs/`.

---

## References

[1] Finite APE Machine repository. "Diagnosis for issue #134: justified documentation status map and canonical-home recommendations." `docs/cleanrooms/134-organize-core-documentation/analyze/diagnosis.md`.

[2] Finite APE Machine repository. "Expanded entry-surface findings and contradiction synthesis for issue #134." `docs/cleanrooms/134-organize-core-documentation/analyze/expanded-entry-surface-findings.md`.

[3] Finite APE Machine repository. "Baseline glossary for issue #134." `docs/cleanrooms/134-organize-core-documentation/analyze/glossary-baseline.md`.