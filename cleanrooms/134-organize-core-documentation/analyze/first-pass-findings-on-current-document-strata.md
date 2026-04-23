---
id: first-pass-findings-on-current-document-strata
title: "First-pass findings on current documentation strata for issue #134"
date: 2026-04-22
status: active
tags: [findings, first-pass, canonicality, obsolescence, documentation]
author: socrates
---

# First-Pass Findings on Current Documentation Strata for Issue #134

## Abstract

The first evidentiary pass over the initial corpus reveals that the repository's documentation is not merely dispersed; it is stratified into clusters with different degrees of current authority. The `docs/research/inquiry/` corpus functions as the strongest current home for the philosophical meaning of inquiry. A second cluster composed of `docs/spec/agent-lifecycle.md`, `docs/spec/cooperative-multitasking-model.md`, `docs/spec/signal-based-coordination.md`, `docs/architecture.md`, and `docs/lore.md` largely aligns around the current five-state, four-sub-agent model, though it still contains path drift and legacy references. A third cluster, especially `docs/spec/finite-ape-machine.md`, `docs/spec/orchestrator-spec.md`, `docs/spec/memory-as-code-spec.md`, and parts of `docs/spec/inquiry-cli-spec.md`, preserves an older or more expansive architecture with additional agents, legacy state names, and planned components not reflected in the current active model. Meanwhile, `docs/research/ape_builds_ape/` and `docs/research/swebok/` appear to function primarily as supporting research strata rather than as canonical homes for the core glossary terms now under review. These findings do not yet complete the status mapping, but they materially narrow the field of plausible canonical homes. [1][2][3][4][5][6][7][8][9][10][11]

## 1. Scope of the First Pass

The present findings are limited to the first-pass corpus defined earlier for issue #134: `docs/research/ape_builds_ape/`, `docs/research/inquiry/`, `docs/research/swebok/`, `docs/spec/`, `docs/architecture.md`, and `docs/lore.md`. The purpose of this pass is not yet to finalize canonical/historical/obsolete status for every document, but to identify where the repository currently locates its strongest definitions, where the documentation aligns with the current active model, and where explicit signals of documentary drift appear. [1][2][3][4][8][9]

## 2. Inquiry Already Has a Strong Philosophical Home

Among all materials read so far, `docs/research/inquiry/` is the clearest and most coherent candidate for the philosophical home of Inquiry. Its index explicitly frames inquiry as the epistemic foundation of APE. `peirce-abduction.md` defines the three modes of inference and directly maps them to ANALYZE, PLAN, and EXECUTE. `dewey-inquiry.md` defines inquiry as the controlled transformation of an indeterminate situation into a determinate one and distinguishes inquiry from documentation. `inquiry-cycle-ape-mapping.md` explicitly presents the cycle-level isomorphism between Peirce's inquiry modes and APE states. Taken together, these documents do not merely mention inquiry; they jointly develop it as a conceptual framework. [2][12][13][14]

This matters for issue #134 because it weakens any assumption that a new top-level `inquiry.md` must be written as though no authoritative material already exists. The repository already contains a substantial inquiry corpus. The real question is whether that corpus should remain where it is, be elevated, be summarized elsewhere, or be cross-referenced from a more user-facing document. [2][12][13][14]

## 3. A Current-Model Cluster Exists, but It Is Not Cleanly Consolidated

Several documents outside `docs/research/inquiry/` align strongly with the current active model. `docs/spec/agent-lifecycle.md` presents a five-state cycle with SOCRATES, DESCARTES, BASHŌ, and DARWIN as the confirmed agents, while explicitly stating that APE is not an ape but the scheduler. `docs/spec/cooperative-multitasking-model.md` reinforces the same scheduler/task distinction and frames APE as the finite machine, not one peer agent among others. `docs/spec/signal-based-coordination.md` likewise describes the five-state cycle and the mechanical signal-driven transition model. `docs/architecture.md` explains the system as a finite-state orchestration model with one orchestrator file and current target deployment. `docs/lore.md` aligns the active model with four operative sub-agents while relegating other named agents to extended lore or future/reference status. [5][6][7][8][9]

This cluster is important because it appears to contain the repository's strongest current articulation of APE as an orchestrating system, Finite APE Machine as an engineered scheduler/event-loop architecture, and Thinking Tools as methods embodied by active or historical agents. However, the cluster is not yet documentary clean. Several of these documents still reference `docs/issues/` rather than `docs/cleanrooms/`, even though the current codebase and agent assets have already moved toward `docs/cleanrooms/`. That means a document can be current in model but stale in implementation detail. [5][6][7][8][9][10]

## 4. A Legacy-or-Expansive Cluster Persists Inside `docs/spec/`

The first pass also reveals a different cluster that preserves a larger and older architecture. `docs/spec/finite-ape-machine.md` still describes MARCOPOLO, SOCRATES, VITRUVIUS, SUNZI, GATSBY, ADA, DIJKSTRA, BORGES, HERMES, and DARWIN as active architectural actors in a much richer multi-agent system than the currently confirmed five-state/four-sub-agent model. `docs/spec/orchestrator-spec.md` is even more explicit: it treats the orchestrator as sequencing MARCOPOLO, VITRUVIUS, SUNZI, GATSBY, ADA, and DIJKSTRA across ANALYZE, PLAN, EXECUTE, REVIEW, and DARWIN phases, with HERMES and BORGES as operational components. `docs/spec/memory-as-code-spec.md` likewise presupposes BORGES and HERMES as active machinery and assigns write zones to agents such as SUNZI and ADA. `docs/spec/inquiry-cli-spec.md` still describes broad planned command surfaces and reviewer artifacts not reflected in the current operational CLI. [4][11][15][16][17]

These documents may still be valuable. They may preserve original architecture, aspirational design, or historical rationale. But they cannot be treated without qualification as the cleanest current source for user-facing definitions of the core terms under issue #134, because they repeatedly present a system that exceeds or diverges from the active registry documented elsewhere in the repository. The precise status of each such document remains to be mapped, but the first pass already shows that they carry stronger historical or mixed-status signals than the current-model cluster. [4][5][6][11][15][16][17]

## 5. Supporting Research Strata Are Distinct from Canonical Taxonomy Homes

The `docs/research/ape_builds_ape/` corpus appears to function mainly as a validation and research layer rather than as a home for base terminology. Its documents discuss the paper, bootstrap validation, experiment methodology, metrics, and review practice. They are highly relevant for empirical claims about the project, but they are not currently the best candidate home for defining Inquiry, APE, Finite APE Machine, FSM, RTOS, or Thinking Tools. [1][18][19][20][21]

The `docs/research/swebok/` corpus similarly reads as an external reference layer. Its index explicitly frames the directory as SWEBOK/IEEE reference documentation. That makes it relevant as supporting evidence for process, models, methods, or software engineering vocabulary, but not as the project's canonical home for self-definition. [3]

## 6. Path Drift Is a Concrete Obsolescence Signal

One concrete signal of documentation drift now appears repeatedly enough to matter analytically: the mismatch between `docs/issues/` and `docs/cleanrooms/`. The current runtime, tests, changelog, and deployed agent assets have already moved toward `docs/cleanrooms/`, yet multiple first-pass documents still explain artifacts under `docs/issues/`. This does not automatically make those documents obsolete in full. It does, however, provide evidence that at least some portions of them risk inducing false understanding in present readers, especially those trying to infer where current analysis and planning artifacts actually live. [5][8][9][10][22]

## 7. Provisional Implications for the Core Terms

The first pass supports several provisional implications. Inquiry is already strongly grounded in `docs/research/inquiry/` as a philosophical and epistemic process. APE is most coherently articulated in the current-model cluster as the orchestrating methodological system and scheduler rather than as one peer agent among others. Finite APE Machine is most strongly supported where the repository describes the system as a finite-state, signal-driven, event-loop architecture rather than where it merely narrates broad methodology. Thinking Tools are currently spread between `docs/lore.md` and current-model specifications, with lore carrying the strongest explicit naming of Socratic method, Cartesian method, techne, and natural selection, but with some risk that allegorical presentation may blur current versus referential status for readers. [2][5][6][7][8][9][12][13][14]

These implications remain provisional because the status mapping has not yet been fully justified document by document. But the field of plausible canonical homes is already much narrower than it was before the first pass. [1][2][3][4][5][6][7][8][9][10][11]

## 8. Conclusion

The initial corpus does not support a flat view of the repository's documentation. It supports a stratified one. The inquiry research corpus is the strongest current candidate for philosophical definitions. A current-model technical cluster exists across lifecycle, multitasking, signals, architecture, and lore, but it is still marred by stale paths and residual drift. A legacy-or-expansive cluster inside `docs/spec/` preserves older multi-agent and planned-system formulations that are unlikely to serve as unqualified current canonical homes for user-facing definitions. Finally, the research corpora on bootstrap validation and SWEBOK function primarily as supporting evidence layers, not as core taxonomy homes. These findings materially advance issue #134 because they transform the question from “where should the concepts go?” into the more precise question “which existing strata already own them, and which documents are now historical, mixed, or misleading?” [1][2][3][4][5][6][7][8][9][10][11]

## References

[1] Finite APE Machine repository. "APE Builds APE — Research Documents." `docs/research/ape_builds_ape/index.md`.

[2] Finite APE Machine repository. "Inquiry as Epistemic Foundation of APE." `docs/research/inquiry/index.md`.

[3] Finite APE Machine repository. "SWEBOK Research — Index." `docs/research/swebok/index.md`.

[4] Finite APE Machine repository. "Spec — Finite APE Machine." `docs/spec/index.md`.

[5] Finite APE Machine repository. "Agent lifecycle — five-state model and confirmed agent registry." `docs/spec/agent-lifecycle.md`.

[6] Finite APE Machine repository. "Cooperative multitasking model — two-level FSM architecture." `docs/spec/cooperative-multitasking-model.md`.

[7] Finite APE Machine repository. "Signal-based coordination — RTOS event model for agent communication." `docs/spec/signal-based-coordination.md`.

[8] Finite APE Machine repository. "Architecture." `docs/architecture.md`.

[9] Finite APE Machine repository. "The Apes — Lore." `docs/lore.md`.

[10] Finite APE Machine repository. `code/cli/CHANGELOG.md`; `code/cli/assets/agents/inquiry.agent.md`; `code/cli/test/init_command_test.dart`.

[11] Finite APE Machine repository. "Finite APE Machine." `docs/spec/finite-ape-machine.md`; "Orchestrator — Technical Specification." `docs/spec/orchestrator-spec.md`; "Memory as Code." `docs/spec/memory-as-code-spec.md`; "Inquiry CLI/TUI — Technical Specification." `docs/spec/inquiry-cli-spec.md`.

[12] Finite APE Machine repository. "Peirce's Theory of Abduction and the Three Modes of Inference." `docs/research/inquiry/peirce-abduction.md`.

[13] Finite APE Machine repository. "Dewey's Definition of Inquiry as Controlled Transformation." `docs/research/inquiry/dewey-inquiry.md`.

[14] Finite APE Machine repository. "Mapping Peirce's Inquiry Cycle to APE's FSM States." `docs/research/inquiry/inquiry-cycle-ape-mapping.md`.

[15] Finite APE Machine repository. "Orchestrator — Technical Specification." `docs/spec/orchestrator-spec.md`.

[16] Finite APE Machine repository. "Memory as Code." `docs/spec/memory-as-code-spec.md`.

[17] Finite APE Machine repository. "Inquiry CLI/TUI — Technical Specification." `docs/spec/inquiry-cli-spec.md`.

[18] Finite APE Machine repository. "Finite APE Machine: Cooperative FSM Orchestration for AI-Assisted Software Engineering." `docs/research/ape_builds_ape/ape-paper.md`.

[19] Finite APE Machine repository. "Bootstrap Validation: APE Builds APE." `docs/research/ape_builds_ape/bootstrap-validation.md`.

[20] Finite APE Machine repository. "Experiment Methodology." `docs/research/ape_builds_ape/experiment-methodology.md`.

[21] Finite APE Machine repository. "Metrics Schema." `docs/research/ape_builds_ape/metrics-schema.md`; "Review Log — APE Paper." `docs/research/ape_builds_ape/review-log.md`.

[22] Finite APE Machine repository. `docs/spec/cli-as-api.md`; `docs/spec/target-specific-agents.md`.