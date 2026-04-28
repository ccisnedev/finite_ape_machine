---
id: assumptions-challenge
title: "Assumptions challenge — 4 decisions analyzed"
date: 2026-04-27
status: active
tags: [assumptions, decisions, risk, blast-radius]
author: socrates
---

# Assumptions Challenge Report

## Decision 1: Remove `next_state` from JSON — SAFE
- No firmware or agent reads `next_state` for routing
- 1 test file to update (`fsm_state_test.dart`)
- Zero external dependencies

## Decision 2: Rename event names to generic — HIGH BLAST RADIUS
- 25+ files reference current event names
- 8 cleanroom plan files, tests, site HTML
- The (state, event) tuple mechanism is sound — renaming preserves it
- Precondition validation is event-agnostic
- **Recommendation: defer to separate issue** — too much churn for this scope

## Decision 3: IDLE sub-agent (TRIAGE) — FEASIBLE, needs design
- `_stateApes` pattern already supports it
- `iq ape prompt` will work once mapping updated
- Firmware `if ape is null` check correctly routes to Inner Loop
- **Design gap**: TRIAGE completion → what happens?
  - TRIAGE `_DONE` + issue ready → scheduler transitions via `iq fsm transition --event start_analyze --issue <NNN>`
  - TRIAGE `_DONE` + no issue → stays IDLE, block event
  - TRIAGE never auto-transitions the main FSM — scheduler decides based on TRIAGE output

## Decision 4: `.inquiry/` is kernel space — SOUND, requires updates
- `issue-start` SKILL.md line 111 instructs agents to WRITE state.yaml directly — MUST be fixed
- `--issue` flag on `iq fsm transition` already works
- No test validates `--issue` flag — gap
- DARWIN metrics write has no CLI endpoint — future issue

## New finding: issue-start skill violates kernel space principle
The skill tells agents: "Write `.inquiry/state.yaml` with phase: ANALYZE, task: NNN"
Should say: "Execute `iq fsm transition --event start_analyze --issue <NNN>`"
