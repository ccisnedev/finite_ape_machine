---
id: scope-decisions
title: Scope decisions for ape doctor checks on target visibility
date: 2026-04-20
status: active
tags: [doctor-command, targets, agents-skills, scope]
author: SOCRATES
---

# Scope Decisions — ape doctor target verification

## Context

After `ape init`, the APE infrastructure is initialized locally (`.ape/state.yaml`, `.ape/config.yaml`, `.ape/mutations.md`), but agents and skills are **not deployed**. Deployment happens via `ape target get`, which copies:
- Skills to `~/.copilot/skills/`
- Agents to `~/.copilot/agents/`

**The gap:** There is no feedback mechanism to detect when a user has run `ape init` but NOT yet run `ape target get`. The agent is invisible in Copilot until deployment occurs.

## Current ape doctor Implementation

Today `ape doctor` verifies:
1. APE version (always passes)
2. `git --version` installed
3. `gh --version` installed
4. `gh auth status` (logged in)

**Missing:** No verification of agent/skill deployment to targets.

## Scope Decisions Made

### Decision 1: Version matching scope
**Decision:** Check for file **existence only**, not version matching. No frontmatter validation at this stage.

**Rationale:** Early development (v0.0.x). Single-target MVP means simplicity is priority.

### Decision 2: Target scope
**Decision:** Only check for `CopilotAdapter` deployment. Do not verify other targets (Claude, Codex, Gemini, Crush).

**Rationale:** Currently only Copilot is deployed. Future targets added post-MVP.

### Decision 3: Skill visibility definition
**Decision:** Verify file existence in deployment directories:
- `~/.copilot/agents/ape.agent.md` exists
- `~/.copilot/skills/<skillName>/SKILL.md` exists for each expected skill

**Rationale:** Answers the question: "Can Copilot see the agent and skills?"

## Open Questions

1. ¿El doctor debe descubrir skills dinámicamente del asset tree, o validar una lista fija?
2. ¿En despliegue parcial: reportar solo lo faltante o árbol completo con ✓/✗?
3. ¿Target sin desplegar debe ser fatal (exit 1) o solo advertencia (exit 0)?
