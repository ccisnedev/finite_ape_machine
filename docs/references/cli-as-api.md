---
id: cli-as-api
title: "CLI as API — skills instruct, commands execute"
date: 2026-04-17
status: active
tags: [architecture, cli, skills, commands, validation, human-usable]
author: socrates
---

# CLI as API Principle

## The Duality

```
Skill (memory-write)        →  Tells the agent WHEN and HOW to write
CLI (ape memory write)      →  Does the actual work with validation
```

A skill is documentation. A command is execution. The skill says "when you need to create an analysis document, use `ape memory write` with these parameters." The command validates input, enforces format, and writes the file.

## Design Decisions

### D5: Skills never bypass CLI validation

An AI agent does not write files directly. It reads the skill to understand what to do, then invokes the CLI command. The CLI enforces:

- YAML frontmatter validation
- Filename conventions
- Index.md updates
- Directory structure rules

This means **skills are pure documentation** and commands are the enforcement layer.

### D6: Humans can use ape.exe without AI

A developer without any AI tool can run `ape memory write`, `ape status`, `ape signal` and get the same results. The CLI prints instructions, validates input, and manages state. The AI is an accelerator, not a requirement.

This is critical for trust: the human understands exactly what the tool does because they can use it themselves.

### D7: No new documentation formats

APE follows existing standards:

- **ADRs**: Michael Nygard format (already in `docs/adr/`)
- **Analysis docs**: Markdown with YAML frontmatter (memory-write schema)
- **Plans**: Markdown with checklists
- **Code docs**: Standard language conventions

The `ape memory write` command enforces these standards but does not invent new ones. The agent simply automates compliance with established practices.

## Current State

The [ape-cli-spec](../../references/ape-cli-spec.md) §1 already states: "Skills do not write files directly — they execute ape memory create, ape task create, ape git commit. The CLI enforces validation."

The current implementation does not reflect this. The `memory-write` skill today is a standalone markdown instruction file with no connection to any CLI command. Closing this gap is part of the work ahead.

## Mapping: Skill → Command

| Skill | CLI Command | Writes to | APE State |
|-------|-------------|-----------|-----------|
| triage | `gh issue list`, `gh issue create`, `ape issue start` | Issue + branch + folder | IDLE |
| memory-write | `ape memory write` | `docs/` (persistent) | ANALYZE |
| memory-read | `ape memory read` | stdout (query) | ANALYZE |
| planning | (via DESCARTES sub-agent) | `docs/issues/{task}/plan.md` | PLAN |
| tdd | (domain skill for BASHŌ) | Source code + tests | EXECUTE |
| api-design | (domain skill for BASHŌ) | Source code | EXECUTE |
| db-as-code | (domain skill for BASHŌ) | Migration files | EXECUTE |
| evolution | `gh issue list`, `gh issue create`, `gh issue comment` | Issues in APE repo | EVOLUTION |
| (future) signal | `ape signal <event>` | `.ape/state.yaml` | Any |
| (future) status | `ape status` | stdout (derived from docs/) | Any |

## CLI Commands: Existing and Planned

### Existing (v0.0.7)

| Command | Description |
|---------|-------------|
| `ape init` | Initialize APE in a repo (docs/issues/, .gitignore, .ape/state.yaml) |
| `ape target get` | Deploy agent + skills to target (Copilot) |
| `ape target clean` | Remove deployed files |
| `ape upgrade` | Upgrade CLI binary |
| `ape version` | Show version |
| `ape uninstall` | Remove APE completely |

### Planned (v0.0.8+)

| Command | Description |
|---------|-------------|
| `ape issue start <NNN>` | Create branch + checkout + working directory from issue |
| `ape doctor` | Verify prerequisites: git, gh, gh auth status |
| `ape config set <key> <value>` | Configure APE settings (.ape/config.yaml) |
| `ape state transition <event>` | Execute state transition with effects (commit, push, etc.) |
