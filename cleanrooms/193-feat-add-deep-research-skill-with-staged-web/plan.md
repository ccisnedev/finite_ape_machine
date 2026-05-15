---
id: plan
issue: 193
title: "Plan: Add Deep-Research Skill with Staged Web Investigation"
status: active
phase: decomposition
owner: descartes
date: 2026-05-15
---

# Plan - Issue #193 (decomposition)

## Goal
Create a new standalone skill named `research` with an explicit staged web-investigation protocol and a durable paper-style markdown output with BibTeX-compatible references.

## Scope Guardrails
- [ ] Keep work strictly limited to creating the new `research` skill.
- [ ] Keep the skill independent (same independence level as `legion`).
- [ ] Do not mention, wire, or integrate this skill into any other system route or surface.
- [ ] Ensure v1 invocation scope is direct user invocation only (no APE, phase, router, command-surface, or automatic invocation integration).
- [ ] Keep this artifact as PLAN-only; do not execute implementation work in this phase.

## Diagnosis Decision Traceability (Mandatory)
- [ ] D1 (skill, not new APE) is explicitly preserved by all phases.
- [ ] D2 (producer-consumer isolation) is explicitly preserved by contract and verification gates.
- [ ] D3 (single paper-style markdown artifact) is explicitly reflected in output/schema checks.
- [ ] D4 (BibTeX-compatible references in report) is explicitly reflected in citation checks.
- [ ] D5 (universal skill intent) is acknowledged while v1 execution scope remains direct user invocation only.
- [ ] D6 (orthogonal to `legion`) is explicitly preserved; no "LEGION-plus-web" framing or coupling tasks.

## Ordering Contract
- [ ] Execute phases strictly in order: Phase 1 -> Phase 2 -> Phase 3 -> Phase 4.
- [ ] A phase may start only when all checklist items in the previous phase are complete.
- [ ] If any new dependency appears, it must be resolved in the current phase before moving forward.

## Phase 1 - Contract and Output Definition

### Entry Criteria
- [ ] `diagnosis.md` is available and accepted as source of truth for #193.
- [ ] Team confirms this cycle is decomposition/plan-only (no implementation).

### Steps
- [ ] Define v1 contract for `research` skill: purpose, inputs, outputs, non-goals.
- [ ] Define staged investigation flow at protocol level (stage sequence and stop condition semantics only).
- [ ] Define required output schema for a single paper-style markdown artifact.
- [ ] Define citation rule: bibliography entries must be BibTeX-compatible and referencable from body sections.
- [ ] Define explicit independence statement: skill is standalone and directly user-invocable, with no cross-route integration tasks.

### Verification
- [ ] Contract document includes: objective, boundaries, expected artifact, and citation standard.
- [ ] Output schema is specific enough that two implementers would produce equivalent section structure.
- [ ] No step text references integration hooks, routing, auto-invocation, or phase-agent wiring.
- [ ] Contract section includes explicit decision trace tags to D1, D2, D3, D4, D5, and D6.

### Pseudotests
- [ ] PseudoTest P1.1: "Given only the contract, reviewer can explain what `research` does in <=3 bullets without mentioning any APE route integration."
- [ ] PseudoTest P1.2: "Given the output schema, reviewer can checklist mandatory sections and BibTeX-compatible bibliography expectations."
- [ ] PseudoTest P1.3: "String scan over planning artifacts finds no tasks that introduce cross-route/surface coupling or auto-routing behavior."

### Risk Notes
- [ ] Risk: Contract drifts into implementation details (tooling/APIs) too early.
- [ ] Mitigation: Keep this phase at interface/behavior level only.
- [ ] Risk: Ambiguous citation expectations create inconsistent outputs.
- [ ] Mitigation: Lock mandatory bibliography format requirements in this phase.

### Dependencies
- [ ] Depends only on diagnosis decisions D1-D6 and scope constraints.

## Phase 2 - Repository Placement and Skill Skeleton Plan

### Entry Criteria
- [ ] Phase 1 contract is complete and internally validated.
- [ ] Repository conventions for skills are identified from existing skill patterns (e.g., `legion`).
- [ ] No unresolved dependency remains from Phase 1.

### Steps
- [ ] Determine target repository location and naming convention for the new `research` skill assets.
- [ ] Define planned skill skeleton files and minimal required sections/content per file.
- [ ] Define how direct user invocation is documented for this skill (without adding runtime routing).
- [ ] Define acceptance boundaries for "standalone" status (what must not be present).

### Verification
- [ ] Planned file layout is complete, minimal, and consistent with current skill conventions.
- [ ] Direct invocation guidance is present and independent of phase-agent workflows.
- [ ] "Not allowed in v1" list explicitly includes any cross-system integration actions.
- [ ] Phase text explicitly traces placement/skeleton decisions to D1, D5, and D6.

### Pseudotests
- [ ] PseudoTest P2.1: "Planned file tree can be reviewed line-by-line; each file has a single clear purpose."
- [ ] PseudoTest P2.2: "Checklist confirms no planned edit touches any non-skill route/surface assets."
- [ ] PseudoTest P2.3: "Reviewer can execute a dry-run mental model where only user calls `research` directly and no system actor auto-calls it."

### Risk Notes
- [ ] Risk: Hidden coupling introduced by copying patterns that include integration hints.
- [ ] Mitigation: Add explicit exclusion checklist before execution.
- [ ] Risk: Over-scoping into docs or command surfaces outside skill boundaries.
- [ ] Mitigation: Restrict planned changes to skill-local assets and direct-use documentation only.

### Dependencies
- [ ] Depends on Phase 1 output contract and independence constraints.
- [ ] Depends on diagnosis decisions D1, D5, and D6 for boundary enforcement.
- [ ] Must not introduce dependencies beyond Phase 1 outputs.

## Phase 3 - Execution Blueprint and Test Strategy Plan

### Entry Criteria
- [ ] Skill contract and planned skeleton are approved.
- [ ] Exclusion list for integrations is explicit.
- [ ] No unresolved dependency remains from Phase 2.

### Steps
- [ ] Produce implementation-ready checklist for creating skill content (still no code changes in PLAN).
- [ ] Define phase-level verification checklist for artifact quality:
- [ ] Define required report sections coverage check.
- [ ] Define citation completeness check (all non-trivial claims trace to bibliography/source notes).
- [ ] Define staged-process traceability check (report reflects staged progression, not unstructured dump).
- [ ] Define repository test commands to run in EXECUTE (including full-suite requirement for final phase).

### Verification
- [ ] Blueprint is executable in order with no missing prerequisites.
- [ ] Verification checklist is objective (pass/fail) and reproducible.
- [ ] Test strategy includes both targeted checks and final full-suite execution.
- [ ] Verification matrix explicitly maps checks back to diagnosis decisions D2, D3, and D4.

### Pseudotests
- [ ] PseudoTest P3.1: "A second engineer can follow blueprint steps without asking where to place/edit skill assets."
- [ ] PseudoTest P3.2: "Applying verification checklist to a sample artifact yields deterministic pass/fail outcomes."
- [ ] PseudoTest P3.3: "Test plan includes an explicit final command block for full project suite, not only targeted tests."

### Risk Notes
- [ ] Risk: Verification criteria are subjective and allow low-quality reports to pass.
- [ ] Mitigation: Use binary checks for structure, traceability, and citation linkage.
- [ ] Risk: Final validation omitted due to time pressure.
- [ ] Mitigation: Make full-suite validation a mandatory terminal gate.

### Dependencies
- [ ] Depends on Phase 1 and Phase 2 completion.
- [ ] Depends on diagnosis decisions D2, D3, and D4 for artifact/verification design.
- [ ] Must not introduce dependencies beyond approved contract/skeleton outputs.

## Phase 4 - Final Validation Gate (Mandatory Full Suite)

### Entry Criteria
- [ ] All prior phase checklists are complete.
- [ ] Planned implementation scope remains limited to standalone `research` skill only.
- [ ] No unresolved dependency remains from Phase 3.

### Steps
- [ ] Run the complete project validation suite defined by repository standards (no subset-only closure).
- [ ] Run any additional mandatory lint/analyze/build checks required by repository policy.
- [ ] Confirm no unintended edits touch integration surfaces outside skill scope.
- [ ] Record validation evidence in issue artifacts before closure.

### Verification
- [ ] Full suite passes with no regressions.
- [ ] No changes appear outside standalone `research` skill scope.
- [ ] Validation evidence is sufficient for audit/review.
- [ ] Final gate evidence includes explicit confirmation of decision compliance for D1-D6.

### Pseudotests
- [ ] PseudoTest P4.1: "If full suite is skipped, issue cannot be marked done."
- [ ] PseudoTest P4.2: "Diff review confirms only standalone `research` skill scope edits are present."
- [ ] PseudoTest P4.3: "Closure checklist requires attached evidence of full-suite execution and results."

### Risk Notes
- [ ] Risk: Green targeted checks mask broader regressions.
- [ ] Mitigation: Enforce full-suite gate as non-optional.
- [ ] Risk: Scope creep introduces forbidden integration edits late.
- [ ] Mitigation: Perform explicit forbidden-surface diff audit before closure.

### Dependencies
- [ ] Depends on successful completion of Phases 1-3 and execution outputs.
- [ ] Depends on prior decision-traceability checks remaining green.

## Completion Criteria
- [ ] A complete EXECUTE-ready plan exists for creating the standalone `research` skill only.
- [ ] Every phase includes Entry Criteria, Steps, Verification, Pseudotests, Risk Notes, and Dependencies.
- [ ] Final phase mandates full project suite validation before closure.
- [ ] No plan item introduces cross-route/surface integration.
- [ ] Decision traceability to diagnosis D1-D6 is explicit and verifiable across all phases.
