---
id: plan
title: "Plan: Invoke-ExpertCouncil SKILL.md"
date: 2026-05-13
status: draft
tags: [plan, skill, legion, invoke-expertcouncil]
author: descartes
---

# Plan: Invoke-ExpertCouncil SKILL.md

## Hypothesis

If we construct the `Invoke-ExpertCouncil/SKILL.md` in four incremental phases — scaffold, protocol core, output templates, and reference material — the resulting document will be a complete, self-contained, runtime-agnostic protocol that any agent can follow to convoke a council of experts via independent sub-agents and synthesize their outputs into a persisted `.md` dictamen.

## Grounding

This plan implements all decisions from [diagnosis.md](analyze/diagnosis.md) (D1–D7), respects constraints C1–C5, and mitigates risks R1–R5. The deliverable is a single file: `code/cli/assets/skills/Invoke-ExpertCouncil/SKILL.md`.

---

## Phase 1: Scaffold — Directory, Frontmatter, Section Headers

**Entry criteria:**
- diagnosis.md approved
- Confirmed findings F1 (frontmatter convention) and F2 (first universal skill) reviewed

**Steps:**

- [x] P1.1: Create directory `code/cli/assets/skills/Invoke-ExpertCouncil/`
- [x] P1.2: Create `SKILL.md` with YAML frontmatter:
  ```yaml
  ---
  name: Invoke-ExpertCouncil
  description: '<one-line description: what the skill does and when to use it>'
  ---
  ```
  - `name` uses PascalCase Verb-Noun per D2 and Q5
  - `description` must be self-contained for agent discovery (evidence-inventory §2.3)
  - Only `name` and `description` fields — matching F1 convention
- [x] P1.3: Add section headers as skeleton (no content yet):
  - `# Invoke-ExpertCouncil — Council of Experts (LEGION)`
  - `## When to Use`
  - `## Protocol`
  - `### Step 1: Comprehension`
  - `### Step 2: Expert Selection`
  - `### Step 3: Consultation`
  - `### Step 4: Synthesis`
  - `## Expert Dictamen Format`
  - `## Synthesis Format`
  - `## Reference Personas`
  - `## Rules`

**Verification:**
```
ASSERT file exists at code/cli/assets/skills/Invoke-ExpertCouncil/SKILL.md
ASSERT frontmatter has exactly two fields: name, description
ASSERT frontmatter.name == "Invoke-ExpertCouncil"
ASSERT frontmatter.description is a non-empty single line
ASSERT all 11 section headers present in correct order
ASSERT no references to iq commands, FSM state, or cleanrooms in frontmatter/description (D3, C1)
```

**Risk:** R5 (SKILL.md too long) — mitigated by establishing lean skeleton upfront. Theoretical background stays in `docs/research/legion.md` per D3/Q4.

**Dependencies:** None.

---

## Phase 2: Protocol Core — The 4-Step Operational Protocol

**Entry criteria:**
- Phase 1 complete (skeleton exists)
- `legion.md` §3.2 (flujo operativo) and §3.3 (sub-agentes) reviewed

**Steps:**

- [ ] P2.1: Write `## When to Use` section — trigger conditions for invoking the skill. Must be runtime-agnostic (D3). Examples: complex multi-domain problems, decisions requiring diverse perspectives, validating designs from multiple angles.
- [ ] P2.2: Write `### Step 1: Comprehension` — instructions for the agent to analyze the problem, identify domains involved, determine if clarification is needed from the user. Based on `legion.md` §3.2 step 1.
- [ ] P2.3: Write `### Step 2: Expert Selection` — instructions for selecting 3–7 experts (default 5, per D7) with maximum cognitive distance (Page 2007). Free mode (D4): agent selects freely, no formal catalog required. Must announce selected experts before proceeding.
- [ ] P2.4: Write `### Step 3: Consultation` — the critical sub-agent invocation step. Each expert MUST be invoked as an independent sub-agent with isolated context (D5). Explicitly prohibit sequential role-play (R1 mitigation). Specify what each expert receives: persona prompt, problem statement, access to tools/skills. Describe the expected output format per expert (pointer to Expert Dictamen Format section). Runtime-agnostic language per C1: "invoke each expert as a separate sub-agent" without prescribing `@agent` syntax.
- [ ] P2.5: Write `### Step 4: Synthesis` — instructions for integrating all expert dictamens. Must identify: consensuses, dissents, blind spots, final recommendation (per `legion.md` §3.5). Output persists to `.md` file (D6). Pointer to Synthesis Format section.
- [ ] P2.6: Address sub-agent fallback (A2 from diagnosis): add a note within Step 3 for runtimes that do not support sub-agent invocation — degraded mode with sequential prompting and explicit context isolation warning.

**Verification:**
```
ASSERT "When to Use" contains at least 3 trigger conditions
ASSERT Step 1 instructs problem analysis before expert selection
ASSERT Step 2 specifies default=5, range=3-7
ASSERT Step 2 mentions cognitive distance / diversity maximization
ASSERT Step 3 contains explicit "sub-agent" invocation instruction
ASSERT Step 3 contains explicit prohibition of role-play
ASSERT Step 3 mentions context isolation
ASSERT Step 3 contains fallback note for runtimes without sub-agent support
ASSERT Step 4 requires consensus, dissent, blind spots sections
ASSERT Step 4 instructs persistence to .md
ASSERT no references to iq commands or FSM state in protocol (D3, C1)
ASSERT imperative language addressed to executing agent (evidence-inventory §2.3)
```

**Risk:** R1 (agent ignores sub-agent instruction) — mitigated by explicit prohibition with rationale. R2 (runtime lacks sub-agents) — mitigated by fallback note in P2.6.

**Dependencies:** Phase 1.

---

## Phase 3: Output Templates — Dictamen and Synthesis Formats

**Entry criteria:**
- Phase 2 complete (protocol references these sections)
- `legion.md` §3.5 (persistencia) reviewed

**Steps:**

- [ ] P3.1: Write `## Expert Dictamen Format` — the structured template each expert must follow for their individual output. Fields from `legion.md` §3.5 and §3.2:
  - Expert identity (name, perspective)
  - Analysis / Hallazgos (findings)
  - Risks identified
  - Recommendation
  - Confidence level (high / medium / low)
  - Format as markdown template with placeholders
- [ ] P3.2: Write `## Synthesis Format` — the template for the final integrated document. Fields from `legion.md` §3.5:
  - Problem analyzed
  - Experts convened (table: #, persona, perspective, confidence)
  - Individual dictamens (embedded or referenced)
  - Consensuses
  - Dissents (with attribution)
  - Blind spots
  - Final recommendation
  - Format as markdown template with placeholders
- [ ] P3.3: Add persistence instructions within Synthesis Format — where and how to save the output `.md` file. Runtime-agnostic: "persist the synthesis as a `.md` file in the appropriate project directory" (D6). No reference to cleanrooms or `doc-write` as requirement (D3).

**Verification:**
```
ASSERT Expert Dictamen Format contains: identity, findings, risks, recommendation, confidence
ASSERT Synthesis Format contains: problem, experts table, individual dictamens, consensuses, dissents, blind spots, recommendation
ASSERT templates use markdown with clear placeholders
ASSERT persistence instruction present and runtime-agnostic
ASSERT no Inquiry-specific references in templates (D3)
```

**Risk:** R3 (synthesis quality) — mitigated by structured template with mandatory sections forcing systematic integration. R5 (too long) — templates are concise markdown skeletons, not prose.

**Dependencies:** Phase 2 (protocol references these formats).

---

## Phase 4: Reference Material, Rules, and Final Polish

**Entry criteria:**
- Phase 3 complete (all operational sections written)
- `legion.md` §3.4 (catálogo de personas) and §3.6 (número de expertos) reviewed
- All existing SKILL.md files reviewed for tone/style alignment

**Steps:**

- [ ] P4.1: Write `## Reference Personas` section — non-prescriptive catalog of cognitive perspectives as guidance (D4, F7). Include 5–7 reference personas from `legion.md` §3.4 adapted to concise format. Explicitly state these are guidance, not mandatory. Note that the agent should maximize cognitive distance for the specific problem.
- [ ] P4.2: Write `## Rules` section — invariant constraints that must hold during any invocation:
  - Sub-agent isolation is mandatory; context must not leak between experts (D5)
  - No sequential role-play — each expert must be a separate sub-agent invocation (R1)
  - Cognitive distance maximization — avoid selecting experts with overlapping perspectives
  - Default 5 experts, minimum 3, maximum 7 (D7)
  - Output must be persisted as `.md` (D6)
  - Protocol is runtime-agnostic — do not depend on any specific tooling or runtime (D3)
- [ ] P4.3: Review the complete SKILL.md end-to-end for:
  - Consistent imperative tone (matching existing skills per evidence-inventory §2.3)
  - No Inquiry-specific dependencies in the protocol body (D3, C1)
  - Conciseness — no theoretical background (Q4, stays in `legion.md`)
  - All diagnosis decisions D1–D7 addressed
  - All constraints C1–C5 respected
  - Risk mitigations R1–R5 embedded
- [ ] P4.4: Verify `description` frontmatter is self-contained and discoverable — an agent reading only the description must understand what the skill does and when to use it.

**Verification:**
```
ASSERT Reference Personas section contains 5-7 personas with distinct cognitive styles
ASSERT Reference Personas section explicitly states "guidance, not mandatory"
ASSERT Rules section contains at least 6 invariants
ASSERT Rules section contains explicit "no role-play" prohibition
ASSERT Rules section contains "sub-agent isolation" requirement
ASSERT entire SKILL.md contains zero occurrences of: "iq ", "cleanroom", "FSM", "inquiry-context"
ASSERT entire SKILL.md uses imperative language addressed to executing agent
ASSERT file length is reasonable (target: 150-250 lines — concise operational protocol)
ASSERT all D1-D7 decisions from diagnosis.md are traceable in the document
```

**Risk:** R5 (too long) — P4.3 explicitly reviews for conciseness. Reference personas are brief (2–3 line descriptions, not full cognitive_style blocks from `legion.md`).

**Dependencies:** Phases 1–3.

---

## Phase Summary

| Phase | Deliverable | Key Decisions | Dependencies |
|-------|-------------|---------------|--------------|
| P1 | Scaffold: directory + frontmatter + section headers | D2, F1, Q5 | None |
| P2 | Protocol: 4-step operational flow + fallback | D3, D4, D5, D7, A2 | P1 |
| P3 | Templates: expert dictamen + synthesis format | D6, R3 | P2 |
| P4 | Reference material, rules, final review | D4, all D/C/R | P1–P3 |

## TDD Applicability

This deliverable is a pure text artifact (C2: no CLI changes). Traditional TDD (RED→GREEN) does not apply. However, each phase defines verification assertions that serve an analogous role: they are checkable predicates that confirm the phase's output satisfies its requirements. Verification is manual (human review) supplemented by text search assertions (e.g., grep for prohibited terms).

## Deviation Protocol

If during execution any phase reveals that the diagnosis is incomplete or incorrect:
1. Annotate the deviation in plan.md under the affected phase
2. Return to ANALYZE for re-diagnosis
3. Do not proceed past the deviating phase

## Out of Scope (confirmed from diagnosis)

- Deployment mechanism to `.github/copilot/skills/` → #185
- `iq skill` CLI module → #185
- Formal YAML expert catalog → future
- CLI code changes → none needed
- Test changes → none needed
- Agent.md changes → none needed
- Theoretical background in SKILL.md → stays in `docs/research/legion.md`
