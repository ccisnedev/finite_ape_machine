---
id: taxonomy-and-scope-clarification
title: "Taxonomy and scope clarification for issue #134"
date: 2026-04-22
status: active
tags: [taxonomy, scope, documentation, inquiry, ape]
author: socrates
---

# Taxonomy and Scope Clarification for Issue #134

## Abstract

Issue #134 is not primarily driven by unresolved conceptual ambiguity among project maintainers. The present problem is archival and user-facing: core concepts and their supporting materials are distributed across heterogeneous documentation roots, while some documents may be historical or obsolete without that status being legible to readers. This paper establishes three analytical boundaries needed before any reorganization question can be evaluated: first, the distinction between archival disorder and conceptual ambiguity; second, the distinction among Inquiry, APE, Finite APE Machine, and Thinking Tools; third, the evidence policy that subsequent analysis documents should follow. These boundaries are derived from repository evidence and from analysis-session clarifications dated 2026-04-22. [1][2][3][4][5][6][7]

## 1. Problem Framing: Archival Disorder Rather Than Internal Conceptual Confusion

### 1.1 Existing repository structure already separates documentation functions

The repository already distinguishes several documentation functions. The spec index presents `docs/spec/` as the home of technical specifications and architectural references. The inquiry research index presents `docs/research/inquiry/` as the epistemic foundation of APE. Top-level documents such as `docs/architecture.md` add system explanation at a broader descriptive layer. This means issue #134 begins from an existing taxonomy, albeit an uneven one, rather than from the absence of conceptual categories. [1][2][3]

### 1.2 The clarified problem is user-facing clarity under archival drift

The analysis-session clarification states that the user does not experience the four target terms as conceptually ambiguous. The difficulty lies instead in whether readers can understand their boundaries quickly, and in whether documents made obsolete by later decisions remain visible without adequate status signaling. The issue is therefore archival in two senses: placement is unclear, and historical status may be unclear. It is not, at root, a dispute about what the internal vocabulary means to the project's authors. [7]

### 1.3 Analytical consequence

Issue #134 should therefore be treated as a taxonomy-and-status problem. The relevant analytical questions are which concepts are primary, where each concept's canonical explanation belongs, and what marks a text as current, historical, or obsolete. An analysis that reduces the issue to terminological confusion would mis-specify the problem. [1][2][7]

## 2. Terminology Boundaries

### 2.1 Inquiry

Within repository evidence, inquiry names the epistemic foundation of APE and the structured process that transforms an indeterminate situation into a determinate result. The inquiry research index explicitly frames inquiry as the philosophical basis of APE, and its key thesis states that every APE cycle is an instance of inquiry. The current analysis session further clarifies this boundary in direct terms: Inquiry is an APE cycle. Inquiry should therefore be treated as the cycle or process, not as the entire technical machinery that operationalizes it. [2][7]

### 2.2 APE

Repository documents use APE in two closely related but compatible senses: as a methodology for AI-aided development and as the orchestrating system that dispatches specialized agents across phases. The Finite APE Machine specification defines APE as a methodology and agent architecture, while the agent lifecycle and lore documents stress that APE is not one ape among others but the scheduler or event loop that coordinates them. The stable boundary is therefore that APE names the orchestrating methodological system. [5][6]

### 2.3 Finite APE Machine

Finite APE Machine is the most concrete, system-level term in the current taxonomy. It names Inquiry brought into operational practice through the APE cycle and expressed through finite-state, scheduler, signal, and control-loop concepts. The architecture document describes orchestration through an FSM and target-deployed agent system; the specification describes APE as a feedback control loop; the lifecycle and signal-coordination documents describe scheduler and RTOS-like event behavior. The analysis-session clarification adds that Finite APE Machine is Inquiry brought into practice through the APE cycle, additionally using FSM and RTOS theory. Finite APE Machine is therefore not merely a synonym for inquiry. It is the engineered realization of that inquiry framework. [3][5][6][7]

### 2.4 Thinking Tools

Thinking Tools are neither synonymous with Inquiry nor coextensive with APE or Finite APE Machine. They are the cognitive methods, reasoning disciplines, or working heuristics embodied within phases or agents. Repository evidence repeatedly describes active agents in terms of their thinking tools: Socratic questioning for SOCRATES, methodical decomposition and experiment design for DESCARTES, and execution disciplines such as TDD within the broader implementation loop. The current analysis session broadens this class explicitly to include Socratic method, Cartesian method, scientific method, TDD, and related methods. Thinking Tools should therefore be treated as a family of methods employed within the framework rather than as the framework's umbrella identity. [5][6][7]

### 2.5 Boundary summary

Taken together, the terms form a hierarchy rather than a set of interchangeable labels. Inquiry denotes the cycle-level epistemic process. APE denotes the orchestrating methodological system that structures that process. Finite APE Machine denotes the concrete system architecture that operationalizes APE through FSM, signal, and control-loop concepts. Thinking Tools denote the reusable methods deployed within or across phases. Collapsing these terms would reduce user-facing clarity precisely where the issue seeks to increase it. [2][3][5][6][7]

## 3. Evidence Policy for Subsequent Documents

### 3.1 Internal evidence should be primary for repository-local taxonomy

Because issue #134 concerns the organization of this repository's own documentation, internal sources should be primary whenever the claim concerns current structure, intended terminology, canonical homes, or present architectural boundaries. The repository already maintains distinct roots for specification, inquiry research, architecture, lore, and working analysis. Those distinctions are the best evidence for claims about current documentary function. [1][2][3][4][6]

### 3.2 External evidence is warranted only when repository evidence underdetermines the claim

External references become necessary when a later analysis document makes claims about philosophical history, methodological ancestry, or technical theory that exceed repository self-description. Claims about Peirce, Dewey, the Socratic method, Cartesian method, control theory, or RTOS theory may require external support if they are advanced as historical or theoretical truths rather than merely as project framing. In those cases, repository documents remain evidence of project intent, but not sufficient evidence of the external claim itself. [2][3][5][6]

### 3.3 Analysis-session clarifications may be cited as primary-source evidence

Where the current conversation establishes scope decisions or user-defined terminology not yet codified in repository documents, those clarifications may be cited as primary-source analysis-session clarifications dated 2026-04-22. This applies here to the claims that the problem is archival rather than conceptual for the maintainer, that Inquiry is an APE cycle, that Finite APE Machine is Inquiry operationalized through the cycle with FSM and RTOS theory, and that Thinking Tools include methods such as the Socratic method, Cartesian method, scientific method, and TDD. [7]

### 3.4 Negative rule

Subsequent documents should avoid two evidentiary errors. First, they should not import external authorities to settle repository-local taxonomy when internal project evidence already decides the matter. Second, they should not rely only on internal project documents when advancing claims whose truth depends on external intellectual history. This mixed evidence policy follows directly from the repository's existing separation between specification, research, and architecture, and from the user's stated evidence standard for this issue. [1][2][3][7]

## 4. Conclusion

Issue #134 is best framed as a documentation-taxonomy problem under archival drift. The central analytical task is not to discover what the maintainers mean, but to make that meaning legible to readers and to distinguish canonical, historical, and obsolete materials. Within that framing, Inquiry denotes the cycle or process; APE denotes the orchestrating methodological system; Finite APE Machine denotes the engineered realization of that system through FSM, signal, and control-loop concepts; and Thinking Tools denote the family of methods employed within or across phases. Later analysis should preserve these boundaries if it aims to improve user-facing clarity rather than merely rearrange files. [1][2][3][5][6][7]

## References

[1] Finite APE Machine repository. "Spec — Finite APE Machine." `docs/spec/index.md`.

[2] Finite APE Machine repository. "Inquiry as Epistemic Foundation of APE." `docs/research/inquiry/index.md`.

[3] Finite APE Machine repository. "Architecture." `docs/architecture.md`.

[4] Finite APE Machine repository. "Memory as Code." `docs/spec/memory-as-code-spec.md`.

[5] Finite APE Machine repository. "Finite APE Machine." `docs/spec/finite-ape-machine.md`.

[6] Finite APE Machine repository. "Agent Lifecycle and States." `docs/spec/agent-lifecycle.md`; "The Apes — Lore." `docs/lore.md`.

[7] Analysis-session clarifications with the user regarding issue #134, dated 2026-04-22.