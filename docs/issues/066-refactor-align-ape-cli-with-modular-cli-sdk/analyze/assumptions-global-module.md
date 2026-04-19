---
id: assumptions-global-module
title: "Assumptions Challenge — The 'global' Module and SDK Alignment"
date: 2026-04-18
status: active
tags: [architecture, refactoring, assumptions, global-module]
author: SOCRATES
---

# Assumptions Challenge — The "global" Module

## User's Clarifications (from Q1-Q3)

1. **Root vs Module**: No property determines the split — it's a decision. Global commands (doctor, init, version, upgrade, uninstall) go in `modules/global/`. They would register "under the empty module."
2. **Alignment = structural**: Refactor to `lib/modules/` with subfolders per module, each with `commands/`.
3. **Dependencies**: Deferred — solve ad-hoc for now.

## Assumptions Surfaced

### A1: `modules/global/` follows the SDK convention

The SDK example keeps root commands in a top-level `commands/` folder, NOT under `modules/`. Moving root commands to `modules/global/` is a *deviation* from the SDK pattern, not an alignment. The question is whether this deviation is intentional and justified.

### A2: Empty-string module registration

The user said commands should "register under the empty module" (`cli.module('', buildGlobalModule)`). It's unclear whether this is tested/supported by `ModularCli`. The current behavior uses `cli.command()` directly — does `cli.module('')` produce identical routing?

### A3: TUI is a "global command"

The TUI command (`''` route) is the default handler — a fallback when no args are provided. Grouping it with `doctor`, `version`, etc. in `modules/global/` conflates two concepts: global commands (explicit user invocations) vs. default handler (no-args fallback).

## Clarifying Questions

### Q1: SDK convention vs. semantic preference
What would it look like if the SDK's convention (root `commands/` for root commands) is actually *correct*, and `modules/global/` is a semantic convenience that creates a false folder structure?

### Q2: What problem does `modules/global/` solve?
Why is the distinction between "registered as root" and "registered in an empty module" important — what problem does it solve that the current flat structure doesn't?

### Q3: TUI's identity
Where does TUI belong? It's not a "global command" like `version` or `doctor` — it's a fallback. Are we conflating two different concepts?
