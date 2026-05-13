---
id: confirmed
title: "Confirmed findings"
date: 2026-05-13
status: active
tags: [findings, confirmed]
author: socrates
---

# Confirmed Findings

> Living document. Update as findings are confirmed, revised, or invalidated.
> Format: ## F<N>: <title> — CONFIRMED|REVISED|INVALIDATED

## F1: SKILL.md frontmatter uses only `name` and `description` — CONFIRMED

All 6 existing skills (`doc-read`, `doc-write`, `issue-create`, `issue-start`, `issue-end`, `inquiry-install`) use identical frontmatter structure: `name` (lowercase, hyphenated) and `description` (single-quoted one-liner). No additional fields.

**Source:** `code/cli/assets/skills/*/SKILL.md`

## F2: Existing skills are all inquiry-bound — CONFIRMED

Every skill in `code/cli/assets/skills/` references Inquiry-specific concepts (`iq` commands, `gh` CLI, cleanrooms, FSM phases, `inquiry-context` blocks). None is designed to work outside the Inquiry runtime. Invoke-ExpertCouncil would be the first universal skill.

**Source:** All 6 SKILL.md files in `code/cli/assets/skills/`

## F3: `iq target get` deploys to user-level `~/.copilot/skills/` — CONFIRMED

The deployer in `code/cli/lib/targets/deployer.dart` copies from `code/cli/assets/skills/<name>/SKILL.md` to `~/.copilot/skills/<name>/SKILL.md`. This is user-level deployment, distinct from project-level `.github/copilot/skills/`.

**Source:** `code/cli/lib/targets/deployer.dart`, `code/cli/lib/targets/copilot_adapter.dart`

## F4: Deployment path for universal skills is unresolved — CONFIRMED

`legion.md` §4.1 states the skill lives in `.github/copilot/skills/` (project-level) and "no se entrega via `iq target get`". The council doc (Expert 5) mentions `iq target get`. No mechanism currently exists to deploy to `.github/copilot/skills/`. This is out of scope for #186 (covered by #185).

**Source:** `docs/research/legion.md` §4.1, `docs/research/council_of_experts.md` Expert 5

## F5: No existing skill uses sub-agent invocation — CONFIRMED

All current skills issue CLI commands (`iq`, `gh`, `git`, `mkdir`) or reference inquiry-context blocks. None instructs the agent to invoke a sub-agent. Invoke-ExpertCouncil would be the first skill to require sub-agent orchestration.

**Source:** All 6 SKILL.md files in `code/cli/assets/skills/`

## F6: The LEGION protocol is a 4-step sequential flow — CONFIRMED

The protocol from `legion.md` §3.2 is: (1) Comprehension, (2) Expert Selection, (3) Consultation (sub-agents), (4) Synthesis + Persistence. Each step depends on the output of the previous. No branching or conditional paths.

**Source:** `docs/research/legion.md` §3.2

## F7: v1 uses free expert selection, no formal catalog — CONFIRMED

`legion.md` §3.4 specifies that v1 operates in "free mode" — the agent selects expert characteristics freely based on the problem. A reference catalog of persona templates is provided as guidance, not as a formal constraint. Formal YAML catalog is deferred to future work.

**Source:** `docs/research/legion.md` §3.4

## F8: Default 5 experts, range 3–7 — CONFIRMED

Based on Karotkin & Paroush (2003) and Dietrich & Spiekermann (2021). Default is 5 for standard analysis. 3 for focused problems, up to 7 for complex multi-domain. Beyond 7, marginal returns are negligible.

**Source:** `docs/research/legion.md` §3.6, `docs/research/council_of_experts.md` §Número óptimo

## F9: The agent tool is available in the Inquiry runtime — CONFIRMED

The `inquiry.agent.md` frontmatter declares `tools: [vscode, execute, read, agent, edit, search, web, browser, todo]`. The `agent` tool enables sub-agent invocation.

**Source:** `code/cli/assets/agents/inquiry.agent.md`
