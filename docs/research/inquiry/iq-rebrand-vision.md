---
id: iq-rebrand-vision
title: "Inquiry CLI (iq) — Rebrand Vision Document"
date: 2026-04-20
status: draft
tags: [rebrand, inquiry, iq, cli, vision, cleanroom]
author: ccisnedev
---

# Inquiry CLI (`iq`) — Rebrand Vision

## Origin

During the Socratic analysis of issue #110 (naming APE's primary subcommand noun), a deeper insight emerged: **inquiry is not a subcommand of APE — inquiry IS the identity**. APE (Analyze-Plan-Execute) is the methodology that inquiry employs, not the other way around.

This document captures the vision for rebranding the CLI tool from `ape` to `iq` (Inquiry).

---

## The Revelation

### Current architecture

```
ape cli
ape.exe
ape init          # creates .ape/
ape upgrade
ape inquiry create  # subcommand within ape
```

### Proposed architecture

```
inquiry cli
iq.exe
iq init           # creates .inquiry/
iq cleanroom create   # creates workspace for an issue
```

### The identity shift

| Aspect | Current | Proposed |
|--------|---------|----------|
| CLI binary | `ape.exe` / `ape` | `iq.exe` / `iq` |
| Config directory | `.ape/` | `.inquiry/` |
| Tool identity | APE (the methodology) | Inquiry (the epistemic process) |
| APE's role | The brand | The internal methodology |
| Primary subcommand | `ape inquiry create` | `iq cleanroom create` |
| Short form analogy | `ape` is to `inquiry` | as `gh` is to `github` |

---

## Why `iq`

1. **`iq` is to `inquiry` as `gh` is to `github`** — a 2-character abbreviation of the full name, following the convention established by GitHub CLI
2. **IQ (Intelligence Quotient) collision is marketing gain** — the term is already in everyone's mind; the association with intelligence/methodology is positive, not confusing
3. **2 characters** — the most ergonomic CLI name possible. `iq init`, `iq doctor`, `iq cleanroom create`

---

## Key Commands

### `iq init`

Creates `.inquiry/` directory with:
- `state.yaml` — FSM state tracking
- `config.yaml` — configuration (evolution enabled, etc.)
- `mutations.md` — human observations for DARWIN

### `iq cleanroom create`

Creates the workspace for investigating an issue:

1. Selects a GitHub issue (interactive or by number)
2. Creates a git worktree on a new branch: `NNN-slug`
3. Creates the inquiry directory structure: `docs/issues/<NNN-slug>/analyze/`
4. Transitions FSM to ANALYZE state
5. The workspace is a "cleanroom" — an isolated environment for structured investigation

**Why "cleanroom":** A cleanroom is a controlled environment where sensitive work happens under strict conditions. An inquiry cleanroom is the controlled epistemic space where Analyze→Plan→Execute occurs. The term implies:
- Isolation (git worktree = separate working directory)
- Control (FSM enforces phase transitions)
- Method (structured process, not ad-hoc coding)

### `iq doctor`

Verifies prerequisites: `iq`, `git`, `gh`, `gh auth`.

### `iq upgrade`

Downloads and installs latest release.

---

## Directory Structure

### Per-repository: `.inquiry/`

```
.inquiry/
├── state.yaml       # FSM state: phase, task, ready/waiting/complete
├── config.yaml      # evolution.enabled, etc.
└── mutations.md     # human observations for DARWIN
```

### Per-inquiry working artifacts: `docs/issues/<slug>/`

```
docs/issues/<NNN-slug>/
├── analyze/
│   ├── index.md
│   ├── *.md          # working documents
│   └── diagnosis.md  # ANALYZE output → PLAN input
└── plan.md           # PLAN output → EXECUTE input
```

**Note:** `docs/issues/` is `.gitignore`'d by default. The inquiry artifacts are ephemeral working memory — the real outputs live in code, commits, issues, and PRs. Users who want to persist inquiry artifacts (like the Finite APE Machine repo itself) can remove the gitignore entry.

---

## The Tern (Final)

```
gh issue create     → creates a problem record          (GitHub)
gl task create      → creates a work coordination unit   (GitLab)
iq cleanroom create → creates a structured investigation (Inquiry)
```

Or equivalently:
```
gh issue create     → problem
gl task create      → coordination
iq cleanroom create → knowledge
```

---

## Relationship to APE

APE (Analyze-Plan-Execute) does not disappear — it becomes the **internal methodology** of Inquiry:

- **APE** = the FSM, the state machine, the process (IDLE → ANALYZE → PLAN → EXECUTE → END → EVOLUTION)
- **Inquiry** = the tool, the CLI, the brand, the epistemic identity
- **IQ** = the binary, the 2-character command

Analogy: **Scrum** is the methodology. **Jira** is the tool. You don't name the tool "Scrum." Similarly: **APE** is the methodology. **Inquiry (iq)** is the tool.

---

## What This Changes

### Must change
- [ ] Binary name: `ape` → `iq`
- [ ] Config directory: `.ape/` → `.inquiry/`
- [ ] CLI help and TUI banner
- [ ] Install scripts (`install.ps1`, `install.sh`)
- [ ] GitHub releases (asset names)
- [ ] VS Code extension commands and references

### Might change
- [ ] Repository name: `finite_ape_machine` → TBD (possibly keep for historical reasons)
- [ ] Website domain/paths
- [ ] Paper title and references

### Does NOT change
- [ ] The FSM (IDLE → ANALYZE → PLAN → EXECUTE → END → EVOLUTION)
- [ ] The agents (SOCRATES, DESCARTES, BASHŌ, DARWIN)
- [ ] The philosophy (Peirce, Dewey, pragmatism)
- [ ] The methodology name "APE" (Analyze-Plan-Execute)
- [ ] The Dart codebase architecture

---

## References

- Issue #110 analysis: `docs/research/inquiry/110-rename-primary-ape-subcommand-noun/analyze/diagnosis.md`
- Peirce's inquiry theory: `docs/research/inquiry/peirce-abduction.md`
- Dewey's inquiry definition: `docs/research/inquiry/dewey-inquiry.md`
- ADI→APE mapping: `docs/research/inquiry/inquiry-cycle-ape-mapping.md`
