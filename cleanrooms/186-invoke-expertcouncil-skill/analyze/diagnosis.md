---
id: diagnosis
title: "Diagnosis: Invoke-ExpertCouncil SKILL.md"
date: 2026-05-13
status: active
tags: [diagnosis, skill, legion, invoke-expertcouncil]
author: socrates
---

# Diagnosis: Invoke-ExpertCouncil SKILL.md

## 1. Problem Defined

Create the `Invoke-ExpertCouncil` SKILL.md — the first universal skill in Inquiry. This skill implements the LEGION technique: council of experts via prompt personas with sub-agent invocation. The SKILL.md must encode a complete, self-contained protocol that an AI agent can follow to convoke a council, invoke each expert as an independent sub-agent, and synthesize their outputs into a structured dictamen persisted as `.md`.

## 2. Decisions Taken

### D1: Invoke-ExpertCouncil is a Skill, NOT an APE

**Justification:** Unanimous council decision (5/5, confidence 0.87). LEGION does not map to any FSM phase, lacks autonomous epistemological warrant, and operates as a technique of aggregation across methods rather than a method itself. The 1:1 APE↔Phase invariant ($\phi: Q \to \mathcal{A}$) is preserved.

**Reference:** [`council_of_experts.md`](../../../docs/research/council_of_experts.md)

### D2: SKILL.md follows existing frontmatter convention

**Justification:** All 6 existing skills use `name` + `description` frontmatter only. No reason to deviate. The `name` field is `Invoke-ExpertCouncil` (Verb-Noun, PowerShell convention). The `description` must explain what the skill does and when to use it, in a single line.

**Reference:** [evidence-inventory.md](evidence-inventory.md) §2.1

### D3: The SKILL.md must work without Inquiry

**Justification:** Universal skill definition from `legion.md` §1.4. The protocol cannot reference `iq` commands, FSM state, or cleanrooms as requirements. It may mention Inquiry-specific enhancements as optional context but must function with any agent that supports skills and sub-agent invocation.

**Reference:** [`legion.md`](../../../docs/research/legion.md) §1.4, §4.1

### D4: v1 uses free expert selection (no formal catalog)

**Justification:** `legion.md` §3.4 specifies free mode. The SKILL.md includes reference persona templates as guidance, not as an exhaustive or mandatory catalog. The agent selects expert characteristics based on the problem's cognitive diversity needs.

**Reference:** [`legion.md`](../../../docs/research/legion.md) §3.4

### D5: Each expert is invoked as independent sub-agent

**Justification:** Context isolation is the theoretical foundation of LEGION (Condorcet, Page). Role-play in a single context causes progressive anchoring and destroys independence. The SKILL.md must instruct sub-agent invocation, not sequential role-play.

**Reference:** [`legion.md`](../../../docs/research/legion.md) §3.3, [`council_of_experts.md`](../../../docs/research/council_of_experts.md) Expert 4

### D6: Output format is a structured dictamen in `.md`

**Justification:** Memory as Code principle. The dictamen template from `legion.md` §3.5 provides the canonical structure: problem, experts convened, individual dictamens, consensuses, dissents, blind spots, final recommendation.

**Reference:** [`legion.md`](../../../docs/research/legion.md) §3.5

### D7: Default 5 experts, range 3–7

**Justification:** Karotkin & Paroush (2003) optimal committee size with heterogeneous competence. Beyond 7, marginal returns are negligible and synthesis quality degrades.

**Reference:** [`legion.md`](../../../docs/research/legion.md) §3.6

## 3. Constraints and Risks

### Constraints

| # | Constraint | Impact |
|---|-----------|--------|
| C1 | SKILL.md must be runtime-agnostic | Cannot use `@agent` syntax directly — must describe sub-agent invocation in abstract terms |
| C2 | No CLI changes in scope | The SKILL.md is a pure text artifact; no `iq` command modifications |
| C3 | v1 has no formal expert catalog | The SKILL.md provides reference personas as guidance, not as a registry |
| C4 | Deployment mechanism is out of scope (#185) | The SKILL.md is created but where it lives on disk (project-level vs user-level) is deferred |
| C5 | No sub-agent invocation precedent | This is the first skill to require it — the protocol must be explicit and unambiguous |

### Risks

| # | Risk | Severity | Mitigation |
|---|------|----------|------------|
| R1 | Agent ignores sub-agent instruction and does role-play instead | High | Explicit prohibition in SKILL.md: "Do NOT role-play sequentially — invoke each expert as a separate sub-agent" |
| R2 | Runtime does not support sub-agent invocation | Medium | SKILL.md should specify a fallback for runtimes without sub-agent support — but must warn that isolation is degraded |
| R3 | Synthesis quality is poor (LLM evaluating its own outputs) | Medium | Structured synthesis template with mandatory sections (consensus, dissent, blind spots) forces systematic integration |
| R4 | Deployment path confusion (project-level vs user-level) | Low | Out of scope for #186. The SKILL.md file is created; deployment infrastructure is #185 |
| R5 | SKILL.md too long for agent context window | Low | Keep protocol concise. Reference personas are guidance, not exhaustive. Theoretical background stays in research docs, not in SKILL.md |

## 4. Scope

### IN scope

1. **Create `Invoke-ExpertCouncil/SKILL.md`** with:
   - YAML frontmatter (`name`, `description`)
   - "When to Use" section
   - Protocol section (4 steps: Comprehension → Selection → Consultation → Synthesis)
   - Output format specification (dictamen template)
   - Reference persona catalog (guidance, not mandatory)
   - Expert count guidance (default 5, range 3–7)
   - Explicit sub-agent invocation instructions
   - Persistence instructions (output → `.md`)

2. **File location:** `code/cli/assets/skills/Invoke-ExpertCouncil/SKILL.md`
   - This places it alongside existing inquiry-bound skills for now
   - When #185 establishes the universal/inquiry-bound infrastructure, it may move

### OUT of scope

- Deployment mechanism to `.github/copilot/skills/` (#185)
- `iq skill` CLI module (#185)
- Formal YAML expert catalog (future)
- CLI code changes
- Test changes
- Agent.md changes
- Theoretical background (stays in `docs/research/legion.md`)

## 5. SKILL.md Structure (Recommended)

Based on analysis of existing skills and the LEGION protocol:

```
---
name: Invoke-ExpertCouncil
description: '<one-liner>'
---

# Invoke-ExpertCouncil — Council of Experts (LEGION)

## When to Use
[Trigger conditions]

## Protocol

### Step 1: Comprehension
[Understand the problem]

### Step 2: Expert Selection  
[Select 3–7 experts with maximum cognitive distance]

### Step 3: Consultation
[Invoke each expert as independent sub-agent]
[Specify the dictamen format per expert]

### Step 4: Synthesis
[Integrate perspectives: consensus, dissent, blind spots]
[Persist as .md]

## Expert Dictamen Format
[Template for each expert's structured output]

## Synthesis Format
[Template for the final integrated document]

## Reference Personas
[Guidance catalog — not mandatory]

## Rules
[Invariants: sub-agent isolation, no role-play, cognitive distance maximization]
```

## 6. Open Questions Resolved

| # | Question | Resolution |
|---|----------|------------|
| Q1 | Where does the file live? | `code/cli/assets/skills/Invoke-ExpertCouncil/SKILL.md` — alongside other skills. Movement to project-level `.github/copilot/skills/` is deferred to #185. |
| Q2 | How does the agent know to use sub-agents? | The SKILL.md explicitly instructs: "invoke each expert as a separate sub-agent with isolated context." The mechanism is runtime-dependent. |
| Q3 | What if the runtime doesn't support sub-agents? | The SKILL.md can note degraded mode (sequential prompting) but should warn that context isolation is lost. |
| Q4 | Does the SKILL.md include theoretical background? | No. The research stays in `docs/research/legion.md`. The SKILL.md is operational protocol only. |
| Q5 | Does the `name` field use PascalCase? | Yes. `Invoke-ExpertCouncil` — matching the directory name and the PowerShell Verb-Noun convention. |

## 7. Remaining Ambiguity

### A1: Deployment path contradiction

`legion.md` §4.1 says "no se entrega via `iq target get`" (project-level `.github/copilot/skills/`). The council doc Expert 5 says "un SKILL.md + un YAML de catálogo + `iq target get`". For #186, this is moot — we create the file in `code/cli/assets/skills/` and let #185 determine the deployment surface. However, this should be flagged for #185.

### A2: Sub-agent fallback behavior

The research is silent on what happens when the runtime cannot invoke sub-agents. The SKILL.md should address this explicitly — either prohibit non-sub-agent execution or document degraded mode with caveats.

## 8. References

- [`docs/research/legion.md`](../../../docs/research/legion.md) — LEGION technique specification (v0.4)
- [`docs/research/council_of_experts.md`](../../../docs/research/council_of_experts.md) — Skill vs APE dictamen
- [`code/cli/assets/skills/`](../../../code/cli/assets/skills/) — Existing skill format examples
- [`code/cli/lib/targets/deployer.dart`](../../../code/cli/lib/targets/deployer.dart) — Skill deployment mechanism
- [evidence-inventory.md](evidence-inventory.md) — Detailed evidence collected during analysis
- [confirmed.md](confirmed.md) — Confirmed findings (F1–F9)
