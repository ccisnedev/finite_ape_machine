---
id: cli-as-api
title: "CLI as API — skills instruct, commands execute through Inquiry"
date: 2026-04-17
status: active
tags: [architecture, cli, skills, commands, validation, human-usable]
author: socrates
---

# CLI as API Principle

## The Duality

```
Skill (memory-write)        →  Tells the agent WHEN and HOW to write
CLI (`iq` command surface)  →  Does the actual work with validation
```

A skill is documentation. A command is execution. The skill tells the agent what protocol to follow; the CLI enforces the repository's runtime contract where a command exists.

## Design Decisions

### D5: Skills never bypass CLI validation where a command exists

An AI agent does not bypass the CLI for operations that already have an Inquiry command. The CLI enforces:

- YAML frontmatter validation
- Filename conventions
- Index.md updates
- Directory structure rules

This means **skills are pure documentation** and commands are the enforcement layer. Where the command surface is still planned rather than implemented, the documentation should say so explicitly instead of pretending the command already exists.

### D6: Humans can use Inquiry without AI

A developer without any AI tool can still use the implemented Inquiry CLI directly. Today that includes commands such as `iq init`, `iq doctor`, `iq target get`, `iq version`, and `iq state transition --event <e>`. The AI is an accelerator, not a requirement.

This is critical for trust: the human understands exactly what the tool does because they can use it themselves.

### D7: No new documentation formats

APE follows existing standards:

- **ADRs**: Michael Nygard format (already in `docs/adr/`)
- **Analysis docs**: Markdown with YAML frontmatter (memory-write schema)
- **Plans**: Markdown with checklists
- **Code docs**: Standard language conventions

The future `iq memory write` command should enforce these standards without inventing new ones. The agent simply automates compliance with established practices.

## Current State

The current Inquiry CLI already enforces the runtime FSM and deployment operations, but the memory-writing command surface remains partly planned rather than fully materialized. The principle is therefore current, while some of the commands that would complete it still belong to future work in [inquiry-cli-spec.md](inquiry-cli-spec.md).

## Mapping: Skill → Command

| Skill | CLI Command | Writes to | APE State |
|-------|-------------|-----------|-----------|
| triage | `gh issue list`, `gh issue create`, issue-start protocol | Issue + branch + cleanroom folder | IDLE |
| memory-write | `iq memory write` (planned) | `docs/` (persistent) | ANALYZE |
| memory-read | `iq memory read` (planned) | stdout (query) | ANALYZE |
| planning | (via DESCARTES sub-agent) | `cleanrooms/{task}/plan.md` | PLAN |
| tdd | (domain skill for BASHŌ) | Source code + tests | EXECUTE |
| api-design | (domain skill for BASHŌ) | Source code | EXECUTE |
| db-as-code | (domain skill for BASHŌ) | Migration files | EXECUTE |
| evolution | `gh issue list`, `gh issue create`, `gh issue comment` | Issues in APE repo | EVOLUTION |
| transition | `iq state transition --event <e>` | `.inquiry/state.yaml` | Any |
| (future) status | `iq status` | stdout (derived from docs/) | Any |

## CLI Commands: Existing and Planned

### Existing

| Command | Description |
|---------|-------------|
| `iq init` | Initialize Inquiry in a repo (`.inquiry/` runtime files) |
| `iq doctor` | Verify prerequisites and environment readiness |
| `iq target get` | Deploy agent + skills to the active target |
| `iq target clean` | Remove deployed files |
| `iq state transition --event <e>` | Execute a declared FSM transition |
| `iq upgrade` | Upgrade CLI binary |
| `iq version` | Show version |
| `iq uninstall` | Remove Inquiry completely |

### Planned

| Command | Description |
|---------|-------------|
| `iq memory query` | Index-aware lookup over repository memory |
| `iq memory validate` | Validate memory artifacts and schema expectations |
| `iq memory write` | Create documentation artifacts with validation |
| `iq task` | Wrap issue/PR workflow with FSM-aware prechecks |
