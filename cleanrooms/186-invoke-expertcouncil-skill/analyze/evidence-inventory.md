---
id: evidence-inventory
title: "Evidence inventory for Invoke-ExpertCouncil SKILL.md"
date: 2026-05-13
status: active
tags: [evidence, inventory, skill, legion]
author: socrates
---

# Evidence Inventory

## 1. Research Documents

### 1.1 `docs/research/legion.md` (v0.4)

Full specification of the LEGION technique. Key sections relevant to SKILL.md authoring:

| Section | Content | Relevance to SKILL.md |
|---------|---------|----------------------|
| §1 Introducción | Problem statement, hypothesis, positioning | Context for `description` frontmatter |
| §1.4 Universal vs inquiry-bound | Deployment taxonomy table | Determines WHERE the SKILL.md lives |
| §2 Fundamentos Teóricos | Condorcet, Page, MoE, MoP, PanelGPT | Background only — NOT in SKILL.md |
| §3.1 Principio de diseño | Zero additional infrastructure | Constraint on SKILL.md content |
| §3.2 Flujo operativo | 4-step protocol (Comprehension → Selection → Consultation → Synthesis) | **Core protocol for SKILL.md** |
| §3.3 Sub-agentes | Isolation principle, each expert as independent sub-agent | **Critical implementation detail** |
| §3.4 Catálogo de personas | Free mode (v1), reference catalog YAML | Inline reference material for SKILL.md |
| §3.5 Persistencia | Dictamen structure template | **Output format for SKILL.md** |
| §3.6 Número de expertos | Default 5, range 3–7 | Configuration guidance |
| §4.1 Skill deployment | `.github/copilot/skills/Invoke-ExpertCouncil/SKILL.md` | Deployment path |
| §4.2 Relación con APEs | Complementary, not conflicting | Context |
| §5 Nombre y filosofía | LEGION = technique, Invoke-ExpertCouncil = skill name | Naming convention |

### 1.2 `docs/research/council_of_experts.md`

Formal dictamen from 5-expert council. Key conclusions:

- LEGION is a Skill, NOT an APE (5/5, confidence 0.87)
- Structural reason: no 1:1 mapping to FSM phase
- Epistemological reason: no autonomous warrant
- Skill-first preserves APE-later option
- Sub-agent capability is independent of APE status

## 2. Existing Skills — Format Analysis

All 6 existing skills follow the same pattern:

### 2.1 YAML Frontmatter

```yaml
---
name: <skill-name>          # lowercase, hyphenated
description: '<one-line>'    # single-quoted, describes when to use
---
```

All existing skills use exactly these two fields. No `tools`, `applyTo`, or other frontmatter.

### 2.2 Section Structure

| Skill | Sections |
|-------|----------|
| doc-read | When to Use, Reading the inquiry-context Block, Protocol (Steps 1-4), Rules |
| doc-write | When to Use, Reading the inquiry-context Block, How It Works, Creating New Documents, Index Update Procedure, Checklist |
| issue-create | When to Use, Prerequisites, Steps (1-5), Verification, Notes |
| issue-start | When to Use, Prerequisites, Steps (1-6) |
| issue-end | When to Use, Prerequisites, Steps (1-6+) |
| inquiry-install | When to Use, Option A/B/C, Verification, Troubleshooting |

**Common pattern:** `When to Use` → `Prerequisites` (optional) → `Steps/Protocol` → `Verification/Checklist` (optional) → `Notes/Troubleshooting` (optional)

### 2.3 Key Observations

1. **All existing skills are inquiry-bound.** They reference `iq` commands, `gh` CLI, cleanrooms, FSM state. None are universal.
2. **Skills use imperative language** addressed to the agent executing them.
3. **Steps are numbered** and use code blocks for CLI commands.
4. **No skill uses sub-agent invocation.** Invoke-ExpertCouncil would be the first.
5. **Frontmatter `description`** is the VS Code/Copilot discovery text — must be self-contained.

## 3. Skill Deployment Mechanism

### 3.1 Current deployment (`iq target get`)

- `code/cli/lib/targets/deployer.dart` iterates `assets.listDirectory('skills')` 
- Copies each `skills/<name>/SKILL.md` to `~/.copilot/skills/<name>/SKILL.md`
- Idempotent: cleans before deploying (D18)
- Target: `~/.copilot/skills/` (user-level, via `CopilotAdapter`)

### 3.2 Universal skill deployment (intended)

- `legion.md` §4.1 says: "vive permanentemente en `.github/copilot/skills/Invoke-ExpertCouncil/SKILL.md`"
- `.github/copilot/skills/` is project-level (repo-scoped), NOT user-level
- "No se entrega via `iq skill get` ni `iq target get`; está siempre disponible"
- **Gap:** No mechanism exists to deploy universal skills to project-level `.github/copilot/skills/`
- Issue #185 covers `iq skill` module but for inquiry-bound skills

### 3.3 Contradiction

The council_of_experts.md (Expert 5) says: "Un SKILL.md + un YAML de catálogo + `iq target get`" — implying deployment via existing mechanism. But legion.md §4.1 explicitly says "No se entrega via `iq skill get` ni `iq target get`". This is an unresolved contradiction about deployment path.

## 4. Sub-Agent Invocation

### 4.1 Copilot agent tool

The `inquiry.agent.md` frontmatter includes `agent` in its tools list. This enables `@<agent-name>` sub-agent invocation in VS Code Copilot.

### 4.2 Implication for SKILL.md

The SKILL.md must instruct the executing agent to invoke each expert as a sub-agent. The mechanism depends on the runtime:
- **VS Code Copilot:** `@<agent-name>` syntax or agent tool
- **Other runtimes:** May use different sub-agent mechanisms

Since Invoke-ExpertCouncil is universal, the SKILL.md must describe the sub-agent pattern in runtime-agnostic terms, with the expectation that the agent will use whatever sub-agent mechanism is available.

## 5. Scope Boundaries (from issue description)

**IN scope for #186:**
- Create the SKILL.md file with the LEGION protocol
- The file must work as a standalone skill

**OUT of scope for #186:**
- Universal vs inquiry-bound infrastructure (#185)
- Formal YAML expert catalog (future)
- Deployment mechanism to `.github/copilot/skills/`
- CLI changes
- `iq skill` commands
