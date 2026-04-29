---
title: "Extract FSM state instructions into prompt YAML files"
issue: 160
date: 2026-04-29
status: confirmed
---

# Diagnosis: FSM State Instructions Extraction

## Problem Defined

State instructions are hardcoded in Dart (`_stateInstructions` in `state.dart`), mixing CLI mechanical logic with prompt content. This prevents:

- Iterating on state behavior without recompiling the binary
- Auditing state rules as plain text
- Declaring constraints (read-only mode, allowed actions) per state
- Having a clear layered architecture: mechanics → mission → methodology

Additionally, the CLI lacks:
- Self-integrity validation (missing assets go undetected until runtime failure)
- Version-awareness at startup (users don't know an update exists)
- A repair mechanism when assets are corrupted/missing

## Decisions Taken

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Fail hard on missing YAML | Yes | Assets are packaged with binary — missing = broken deployment |
| Recovery mechanism | `iq doctor --fix` | Runs remediations sequentially; downloads assets from current version's release |
| Version check location | `iq doctor` + `iq` (bare) | Non-blocking; silent on network failure |
| `--fix` behavior | Execute all remediations, report per-step | Like `apt --fix-broken` — one failure doesn't block others |
| Schema for state YAML | `instructions` + `constraints` + `allowed_actions` | Separates mission from method |
| IDLE must run `iq doctor` first | Yes | Validates environment before any triage work |

## Scope

### In scope

1. **Extract prompts to YAML** — Create `assets/fsm/states/{idle,analyze,plan,execute,end,evolution}.yaml`
2. **Doctor: validate internal assets** — Verify `apes/*.yaml`, `fsm/states/*.yaml`, `skills/*/SKILL.md` exist
3. **Doctor: check for new version** — Hit GitHub API, suggest `iq upgrade`
4. **Doctor `--fix`** — Execute remediations sequentially (download assets from release of current version if missing)
5. **TUI (`iq` bare): version check** — Show banner if update available
6. **IDLE scheduler runs `iq doctor` first** — Update `_stateInstructions` (or its replacement) and `inquiry.agent.md`

### Out of scope

- Changing APE sub-agent methodology (socrates-idle.yaml stays as-is)
- Adding `--force` to `iq upgrade` (not semantically correct for repair)
- Modifying transition_contract.yaml mechanics
- Changing the FSM state machine itself

## Constraints & Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| Missing YAML after extraction | High | Doctor validates + `--fix` repairs |
| Network failure on version check | Low | Silent fallback — CLI works offline |
| Malformed YAML in state file | High | Try-catch with clear error message pointing to `iq doctor --fix` |
| build/assets drift from source | Medium | CI/build step must sync; doctor could detect |
| Breaking change in state YAML schema | Low | Version field in YAML for future migrations |

## Architecture: Three-Layer Model

```
transition_contract.yaml    ← MECHANICS (events, states, prechecks, effects)
states/idle.yaml            ← MISSION (instructions, constraints, allowed_actions)
apes/socrates-idle.yaml     ← METHOD (how the sub-agent executes the mission)
```

## Proposed State YAML Schema

```yaml
name: idle
version: "1.0.0"
description: "Triage and issue formulation"

instructions: |
  Evaluate what work merits inquiry. Understand the problem,
  search for existing issues, create or select an issue.

constraints:
  - Read-only mode — no code edits
  - No file creation outside of GitHub issues
  - No branch preparation (belongs to transition prechecks)
  - No analysis of root causes (belongs to ANALYZE)

allowed_actions:
  - Create GitHub issues
  - Edit GitHub issues
  - Comment on GitHub issues
  - Search codebase (read-only)
  - Discuss and clarify with user
  - Run iq doctor
```

## Files Affected

| File | Change |
|------|--------|
| `code/cli/lib/modules/fsm/commands/state.dart` | Remove `_stateInstructions`, load from YAML |
| `code/cli/assets/fsm/states/*.yaml` | **New** — 6 files |
| `code/cli/lib/modules/global/commands/doctor.dart` | Add asset integrity check + version check + `--fix` flag |
| `code/cli/lib/modules/global/commands/tui.dart` | Add version check banner |
| `code/cli/lib/modules/global/global_builder.dart` | Wire `--fix` flag to doctor |
| `code/cli/assets/agents/inquiry.agent.md` | Add "run `iq doctor` first in IDLE" to firmware |
| `code/cli/test/` | Update tests for new behavior |
| `code/cli/build/assets/` | Sync after merge |

## References

- [state.dart#L183](code/cli/lib/modules/fsm/commands/state.dart) — current hardcoded instructions
- [doctor.dart](code/cli/lib/modules/global/commands/doctor.dart) — existing doctor checks
- [upgrade.dart](code/cli/lib/modules/global/commands/upgrade.dart) — GitHub API pattern for version check
- [socrates-idle.yaml](code/cli/assets/apes/socrates-idle.yaml) — APE YAML pattern to follow
- [transition_contract.yaml](code/cli/assets/fsm/transition_contract.yaml) — mechanics layer (unchanged)
