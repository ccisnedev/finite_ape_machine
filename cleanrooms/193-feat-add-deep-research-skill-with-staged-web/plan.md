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
- [x] Keep work strictly limited to creating the new `research` skill.
- [x] Keep the skill independent (same independence level as `legion`).
- [x] Do not mention, wire, or integrate this skill into any other system route or surface.
- [x] Ensure v1 invocation scope is direct user invocation only (no APE, phase, router, command-surface, or automatic invocation integration).
- [x] Keep this artifact as PLAN-only; do not execute implementation work in this phase.

## Diagnosis Decision Traceability (Mandatory)
- [x] D1 (skill, not new APE) is explicitly preserved by all phases.
- [x] D2 (producer-consumer isolation) is explicitly preserved by contract and verification gates.
- [x] D3 (single paper-style markdown artifact) is explicitly reflected in output/schema checks.
- [x] D4 (BibTeX-compatible references in report) is explicitly reflected in citation checks.
- [x] D5 (universal skill intent) is acknowledged while v1 execution scope remains direct user invocation only.
- [x] D6 (orthogonal to `legion`) is explicitly preserved; no "LEGION-plus-web" framing or coupling tasks.

## Ordering Contract
- [x] Execute phases strictly in order: Phase 1 -> Phase 2 -> Phase 3 -> Phase 4.
- [x] A phase may start only when all checklist items in the previous phase are complete.
- [x] If any new dependency appears, it must be resolved in the current phase before moving forward.

## Phase 1 - Contract and Output Definition

### Entry Criteria
- [x] `diagnosis.md` is available and accepted as source of truth for #193.
- [x] Team confirms this cycle is decomposition/plan-only (no implementation).

### Steps
- [x] Define v1 contract for `research` skill: purpose, inputs, outputs, non-goals.
- [x] Define staged investigation flow at protocol level (stage sequence and stop condition semantics only).
- [x] Define required output schema for a single paper-style markdown artifact.
- [x] Define citation rule: bibliography entries must be BibTeX-compatible and referencable from body sections.
- [x] Define explicit independence statement: skill is standalone and directly user-invocable, with no cross-route integration tasks.

### Verification
- [x] Contract document includes: objective, boundaries, expected artifact, and citation standard.
- [x] Output schema is specific enough that two implementers would produce equivalent section structure.
- [x] No step text references integration hooks, routing, auto-invocation, or phase-agent wiring.
- [x] Contract section includes explicit decision trace tags to D1, D2, D3, D4, D5, and D6.

### Pseudotests
- [x] PseudoTest P1.1: "Given only the contract, reviewer can explain what `research` does in <=3 bullets without mentioning any APE route integration."
- [x] PseudoTest P1.2: "Given the output schema, reviewer can checklist mandatory sections and BibTeX-compatible bibliography expectations."
- [x] PseudoTest P1.3: "String scan over planning artifacts finds no tasks that introduce cross-route/surface coupling or auto-routing behavior."

### Risk Notes
- [x] Risk: Contract drifts into implementation details (tooling/APIs) too early.
- [x] Mitigation: Keep this phase at interface/behavior level only.
- [x] Risk: Ambiguous citation expectations create inconsistent outputs.
- [x] Mitigation: Lock mandatory bibliography format requirements in this phase.

### Dependencies
- [x] Depends only on diagnosis decisions D1-D6 and scope constraints.

## Phase 2 - Repository Placement and Skill Skeleton Plan

### Entry Criteria
- [x] Phase 1 contract is complete and internally validated.
- [x] Repository conventions for skills are identified from existing skill patterns (e.g., `legion`).
- [x] No unresolved dependency remains from Phase 1.

### Steps
- [x] Determine target repository location and naming convention for the new `research` skill assets.
- [x] Define planned skill skeleton files and minimal required sections/content per file.
- [x] Define how direct user invocation is documented for this skill (without adding runtime routing).
- [x] Define acceptance boundaries for "standalone" status (what must not be present).

### Verification
- [x] Planned file layout is complete, minimal, and consistent with current skill conventions.
- [x] Direct invocation guidance is present and independent of phase-agent workflows.
- [x] "Not allowed in v1" list explicitly includes any cross-system integration actions.
- [x] Phase text explicitly traces placement/skeleton decisions to D1, D5, and D6.

### Pseudotests
- [x] PseudoTest P2.1: "Planned file tree can be reviewed line-by-line; each file has a single clear purpose."
- [x] PseudoTest P2.2: "Checklist confirms no planned edit touches any non-skill route/surface assets."
- [x] PseudoTest P2.3: "Reviewer can execute a dry-run mental model where only user calls `research` directly and no system actor auto-calls it."

### Risk Notes
- [x] Risk: Hidden coupling introduced by copying patterns that include integration hints.
- [x] Mitigation: Add explicit exclusion checklist before execution.
- [x] Risk: Over-scoping into docs or command surfaces outside skill boundaries.
- [x] Mitigation: Restrict planned changes to skill-local assets and direct-use documentation only.

### Dependencies
- [x] Depends on Phase 1 output contract and independence constraints.
- [x] Depends on diagnosis decisions D1, D5, and D6 for boundary enforcement.
- [x] Must not introduce dependencies beyond Phase 1 outputs.

## Phase 3 - Execution Blueprint and Test Strategy Plan

### Entry Criteria
- [x] Skill contract and planned skeleton are approved.
- [x] Exclusion list for integrations is explicit.
- [x] No unresolved dependency remains from Phase 2.

### Steps
- [x] Produce implementation-ready checklist for creating skill content (still no code changes in PLAN).
- [x] Define phase-level verification checklist for artifact quality:
- [x] Define required report sections coverage check.
- [x] Define citation completeness check (all non-trivial claims trace to bibliography/source notes).
- [x] Define staged-process traceability check (report reflects staged progression, not unstructured dump).
- [x] Define repository test commands to run in EXECUTE (including full-suite requirement for final phase).

### Verification
- [x] Blueprint is executable in order with no missing prerequisites.
- [x] Verification checklist is objective (pass/fail) and reproducible.
- [x] Test strategy includes both targeted checks and final full-suite execution.
- [x] Verification matrix explicitly maps checks back to diagnosis decisions D2, D3, and D4.

### Pseudotests
- [x] PseudoTest P3.1: "A second engineer can follow blueprint steps without asking where to place/edit skill assets."
- [x] PseudoTest P3.2: "Applying verification checklist to a sample artifact yields deterministic pass/fail outcomes."
- [x] PseudoTest P3.3: "Test plan includes an explicit final command block for full project suite, not only targeted tests."

### Risk Notes
- [x] Risk: Verification criteria are subjective and allow low-quality reports to pass.
- [x] Mitigation: Use binary checks for structure, traceability, and citation linkage.
- [x] Risk: Final validation omitted due to time pressure.
- [x] Mitigation: Make full-suite validation a mandatory terminal gate.

### Dependencies
- [x] Depends on Phase 1 and Phase 2 completion.
- [x] Depends on diagnosis decisions D2, D3, and D4 for artifact/verification design.
- [x] Must not introduce dependencies beyond approved contract/skeleton outputs.

## Phase 4 - Final Validation and Release Preparation Gate

### Entry Criteria
- [x] All prior phase checklists are complete.
- [x] Planned implementation scope remains limited to standalone `research` skill only.
- [x] No unresolved dependency remains from Phase 3.

### Steps
- [x] Run the complete project validation suite defined by repository standards (no subset-only closure).
- [x] Run any additional mandatory lint/analyze/build checks required by repository policy.
- [x] Confirm no unintended edits touch integration surfaces outside skill scope.
- [x] Apply mandatory version bump for this issue following repository version-sync policy.
- [x] Update `CHANGELOG.md` with the `research` skill addition details.
- [x] Re-run required validation checks after version/changelog updates to confirm no regressions.
- [x] Record validation evidence in issue artifacts before closure.

### Verification
- [x] Full suite passes with no regressions.
- [ ] No changes appear outside standalone `research` skill scope.
- [x] Version bump is present and synchronized in all required version surfaces.
- [x] `CHANGELOG.md` includes an entry describing the `research` skill addition.
- [x] Validation evidence is sufficient for audit/review.
- [x] Final gate evidence includes explicit confirmation of decision compliance for D1-D6.

### Pseudotests
- [x] PseudoTest P4.1: "If full suite is skipped, issue cannot be marked done."
- [ ] PseudoTest P4.2: "Diff review confirms only standalone `research` skill scope edits are present."
- [x] PseudoTest P4.3: "Closure checklist requires attached evidence of full-suite execution and results."
- [x] PseudoTest P4.4: "If version bump or CHANGELOG update is missing, issue cannot be marked done."

### Risk Notes
- [x] Risk: Green targeted checks mask broader regressions.
- [x] Mitigation: Enforce full-suite gate as non-optional.
- [x] Risk: Scope creep introduces forbidden integration edits late.
- [x] Mitigation: Perform explicit forbidden-surface diff audit before closure.

### Dependencies
- [x] Depends on successful completion of Phases 1-3 and execution outputs.
- [x] Depends on prior decision-traceability checks remaining green.

Deviation note (2026-05-15, resolved): CLI validation initially completed successfully, but repo-wide closure was blocked by issue #194 due to two timeout failures in `code/vscode/test/integration/status-bar.test.ts` (`updateStatusBar...` and `dispose...`).

Resolution note (2026-05-15): Issue #194 was fixed by aligning the status-bar integration fixtures with the real `.inquiry/state.yaml` format (`state`/`issue`, not `cycle.phase`/`cycle.task`). Full validation now passes with the following evidence:

- `code/cli`: `dart pub get`, `dart analyze`, `dart test`, `dart compile exe bin/main.dart -o build/inquiry.exe`
- `code/vscode`: `npm run test:unit`, `npm run test:integration`
- Decision compliance remains intact for D1-D6 because the `research` artifact, its scope, its standalone invocation contract, and its bibliography/output requirements were not altered by the blocker fix.

## Completion Criteria
- [x] A complete EXECUTE-ready plan exists for creating the standalone `research` skill only.
- [x] Every phase includes Entry Criteria, Steps, Verification, Pseudotests, Risk Notes, and Dependencies.
- [x] Final phase mandates full project suite validation before closure.
- [x] Final phase includes mandatory version bump and CHANGELOG update before closure.
- [x] No plan item introduces cross-route/surface integration.
- [x] Decision traceability to diagnosis D1-D6 is explicit and verifiable across all phases.
