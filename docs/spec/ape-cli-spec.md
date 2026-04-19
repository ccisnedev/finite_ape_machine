# APE CLI/TUI — Technical Specification

**Finite APE Machine — Command Line Interface & Terminal User Interface**

Version: 0.2.0-spec
Date: March 29, 2026
Author: Dev (cacsidev@gmail.com)
Supersedes: v0.1.0-spec (March 28, 2026)

---

## 1. Overview

`ape` is the command-line tool for the Finite APE Machine framework. It configures development repositories to work with the APE methodology (Analyze → Plan → Execute + DARWIN) by installing agents, skills, prompts, hooks, and configuration files tailored to the user's AI coding tool of choice.

`ape` is also the **programmatic API** for apes. Skills do not write files directly — they execute `ape memory create`, `ape task create`, `ape git commit`, etc. The CLI enforces validation via BORGES (schema enforcement, documentation compiler), maintains indices, and guarantees consistency. This is a key architectural decision: the CLI is the single gateway through which all structured writes pass.

`ape` is a single native binary that operates in two modes:

- **TUI mode** (`ape` with no arguments): launches an interactive terminal UI for guided configuration and management.
- **CLI mode** (`ape <command>`): executes specific commands directly for scripting, automation, and ape invocation.

### 1.1 Design Principles

- **Single binary, zero runtime dependencies.** The user downloads one executable. No Dart SDK, no package manager, no runtime required.
- **Separation of CLI tool and repo configuration.** The `ape` binary lives on the machine. The `.ape/` directory lives in the repo. They version independently.
- **Semantic migrations, not snapshots.** Repo upgrades apply structured transformation scripts, not brute-force backup/restore.
- **Target-agnostic source of truth.** `.ape/` is the canonical configuration. Target-specific files (`.github/agents/`, `.claude/`, `.cursorrules`) are generated from it and can be regenerated at any time.
- **CLI as API.** Apes interact with memory, tasks, and git through `ape` commands, never through direct file manipulation. The CLI is the validation boundary.
- **Memory as Code.** Project memory lives as structured .md files in the repository, versioned with git, readable by humans and agents. No external database dependencies. See: *Memory as Code Specification*.

### 1.2 Prerequisites

The following tools MUST be installed and available in PATH before `ape` can operate:

| Prerequisite | Minimum Version | Purpose |
|-------------|----------------|---------|
| `git` | 2.30+ | Version control, branching, commits |
| `gh` (GitHub CLI) | 2.0+ | Task management (Issues), PR creation, DARWIN issue creation |

These are **hard requirements**, not optional integrations. `ape init` verifies their presence and aborts with a clear error message if either is missing. The rationale: git is the substrate of Memory as Code, and GitHub is the task backend for v0.x.x.

---

## 2. Technology Stack

| Component | Technology | Rationale |
|-----------|-----------|-----------|
| Language | Dart | Aligns with author's primary stack (Modular API). Native compilation via `dart compile exe`. |
| TUI Framework | Nocterm | Flutter-like API (StatefulComponent, setState, Row, Column). Hot reload for development. Testing support. Low learning curve for Flutter/Dart developers. |
| CLI Parsing | `package:args` | Standard Dart CLI argument parsing. CommandRunner pattern for subcommands. |
| Configuration | YAML (`package:yaml` / `package:yaml_edit`) | Human-readable, git-friendly, standard for dev tooling. |
| HTTP | `package:http` | For downloading releases, checking updates, and GitHub API calls. |
| Archive | `package:archive` | For extracting release assets (tar.gz, zip). |
| File System | `package:path` + `dart:io` | Cross-platform path handling. |
| Markdown Parsing | `package:markdown` | For frontmatter extraction and index parsing (BORGES validation). |
| Versioning | Semantic Versioning (semver) | CLI version and repo config version tracked independently. |

---

## 3. Distribution

### 3.1 Compilation

Dart does not support cross-compilation. Each platform binary must be compiled on its native OS.

| Platform | Binary | Compilation |
|----------|--------|-------------|
| Windows | `ape.exe` | `dart compile exe bin/ape.dart -o ape.exe` |
| Linux | `ape` | `dart compile exe bin/ape.dart -o ape` |
| macOS (Intel) | `ape` | `dart compile exe bin/ape.dart -o ape` |
| macOS (ARM) | `ape` | `dart compile exe bin/ape.dart -o ape` |

Note: Windows users with WSL can also use the Linux binary directly.

### 3.2 GitHub Actions Build Pipeline

```yaml
name: Release
on:
  push:
    tags: ['v*']

jobs:
  build:
    strategy:
      matrix:
        include:
          - os: ubuntu-latest
            artifact: ape-linux-x64
            ext: ""
          - os: macos-latest
            artifact: ape-macos-arm64
            ext: ""
          - os: macos-13
            artifact: ape-macos-x64
            ext: ""
          - os: windows-latest
            artifact: ape-windows-x64
            ext: ".exe"
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - uses: dart-lang/setup-dart@v1
      - run: dart compile exe bin/ape.dart -o ${{ matrix.artifact }}${{ matrix.ext }}
      - uses: actions/upload-artifact@v4
        with:
          name: ${{ matrix.artifact }}
          path: ${{ matrix.artifact }}${{ matrix.ext }}

  release:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/download-artifact@v4
      - uses: softprops/action-gh-release@v2
        with:
          files: |
            ape-linux-x64/ape-linux-x64
            ape-macos-arm64/ape-macos-arm64
            ape-macos-x64/ape-macos-x64
            ape-windows-x64/ape-windows-x64.exe
```

### 3.3 Installation

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/<org>/ape/main/scripts/install.ps1 | iex
```

**Linux / macOS (Bash):**
```bash
curl -fsSL https://raw.githubusercontent.com/<org>/ape/main/scripts/install.sh | bash
```

**Manual:**
Download the binary from GitHub Releases, place it in PATH.

#### Install Script Behavior

1. Detect platform and architecture.
2. Download the appropriate binary from the latest GitHub Release.
3. Place binary in a standard location (`~/.ape/bin/` or `%USERPROFILE%\.ape\bin\`).
4. Add to PATH if not already present.
5. Verify installation with `ape --version`.

---

## 4. Commands

### 4.1 Entry Point Logic

```
main(args):
  if args is empty:
    launch TUI
  else:
    parse and execute CLI command
```

### 4.2 Command Tree

```
ape                                  # TUI mode (no arguments)
ape init                             # Initialize repo
ape status                           # Show repo status
ape upgrade                          # Upgrade CLI binary
ape repo upgrade                     # Migrate repo config
ape repo doctor                      # Verify repo integrity
ape repo doctor --memory             # + BORGES validation
ape repo retarget <target>           # Change agent target
ape memory status                    # Memory health overview
ape memory search <query>            # Search memory files
ape memory validate                  # Run BORGES validation
ape memory create <type>             # Create a memory file
ape memory rebuild-index             # Rebuild all indices
ape task create <title>              # Create task (→ GitHub Issue)
ape task list                        # List tasks
ape task status [task-id]            # Show task status
ape task update <task-id>            # Update task
ape task close <task-id>             # Close task
ape git branch <task-id>             # Create branch from task
ape git commit                       # Commit (green phase)
ape git pr                           # Create pull request
ape darwin --rebuild-reports         # Rebuild materialized views
```

### 4.3 Command Reference

#### `ape` (no arguments)

**Mode:** TUI

Launches the interactive terminal user interface. The TUI provides:

- **Init wizard:** guided repo configuration with visual selection of agent target, stack, risk defaults.
- **Status dashboard:** current repo configuration, agent health, task overview, memory statistics.
- **Reconfigure:** change target, add/remove skills, modify risk defaults.
- **Upgrade manager:** visual diff of what `ape repo upgrade` will change before applying.
- **Memory browser:** navigate memory files, view indices, check BORGES status.
- **Task board:** visual task management backed by GitHub Issues.

---

#### `ape init`

**Mode:** CLI (with inline prompts)

Initializes APE configuration in the current repository.

```
$ cd my-project
$ ape init

Checking prerequisites...
  ✓ git 2.43.0 found
  ✓ gh 2.45.0 found
  ✓ GitHub authentication verified (gh auth status)

? Select agent target: (use arrows)
  ❯ GitHub Copilot
    Claude Code
    Cursor
    Gemini CLI
    OpenCode

? Select stack: (multi-select)
  ❯ ◉ Dart
    ◉ TypeScript
    ◯ Python

? Default risk level: (use arrows)
  ❯ Medium (recommended)
    Low
    High

✓ Created .ape/ape.yaml
✓ Created .ape/agents/ (8 agents)
✓ Created .ape/skills/ (12 skills + BORGES protocol)
✓ Created .ape/templates/ (6 templates)
✓ Created .ape/hooks/tracker.sh
✓ Created .ape/memory/ (structure + taxonomy + empty indices)
✓ Generated .github/agents/ (target: GitHub Copilot)
✓ APE v0.2.0 initialized successfully
```

**Flags:**
- `--target <name>`: skip target selection prompt.
- `--stack <list>`: skip stack selection prompt.
- `--risk <level>`: skip risk level prompt.
- `--force`: overwrite existing `.ape/` configuration.
- `--dry-run`: show what would be created without writing files.

**Behavior:**
1. Verifies prerequisites: `git` and `gh` in PATH, `gh auth status` returns authenticated.
2. If `.ape/` already exists, warns and exits (unless `--force`).
3. Writes `.ape/` directory with full configuration.
4. Creates complete memory structure: directories, empty `index.md` files with headers, `taxonomy.md` with default vocabulary.
5. Generates target-specific files based on selected agent target.
6. Adds `.ape/status.md` to `.gitignore` suggestions (memory files ARE versioned).

---

#### `ape status`

**Mode:** CLI

Shows current repo configuration, task overview, and memory health.

```
$ ape status

Finite APE Machine v0.2.0
Repo config: v0.2.0 ✓ (up to date)
Target: GitHub Copilot
Stack: Dart, TypeScript
Risk default: Medium

Agents: 8/8 installed ✓
Skills: 13/13 installed ✓
Hooks: 1/1 active ✓

Memory:
  ADRs: 3 (2 accepted, 1 draft)
  Specs: 5 (3 active, 2 completed)
  Runbooks: 4 (1 in_progress, 3 completed)
  Deviations: 7 (6 resolved, 1 escalated)
  Lessons: 2 (2 active)
  BORGES: ✓ all files valid

Tasks:
  Open: 4 (2 in_progress, 2 pending)
  Closed this week: 3
  Source: GitHub Issues

Last APE cycle: 2026-03-27 (task: add-payment-endpoint)
DARWIN reports: 3 pending lessons
```

---

#### `ape upgrade`

**Mode:** CLI

Upgrades the `ape` binary itself to the latest version.

```
$ ape upgrade

Current version: 0.1.0
Latest version:  0.2.0
Downloading ape-windows-x64.exe... done
✓ Upgraded to v0.2.0

Note: Run 'ape repo upgrade' in your repos to migrate configurations.
```

**Behavior:**
1. Queries GitHub Releases API for latest version.
2. Compares with current version.
3. Downloads appropriate binary for current platform.
4. Replaces current binary (platform-appropriate swap mechanism).
5. Reminds user to run `ape repo upgrade` in their repos.

---

#### `ape repo upgrade`

**Mode:** CLI

Migrates the `.ape/` configuration in the current repo to match the installed CLI version.

```
$ ape repo upgrade

Repo config version: 0.1.0
CLI version:         0.2.0

Migrations to apply:
  0.1.0 → 0.1.1: Add @contract template, update DIJKSTRA (quality gate pre-PR) prompt
  0.1.1 → 0.2.0: Add memory structure, task configuration, BORGES protocol

? Apply migrations? (y/N) y

Applying 0.1.0 → 0.1.1... ✓
Applying 0.1.1 → 0.2.0... ✓
Running doctor... ✓

✓ Repo upgraded to v0.2.0
```

**Behavior:**
1. Reads `version` from `.ape/ape.yaml`.
2. Reads CLI version.
3. Finds migration chain in embedded migration scripts.
4. Shows user what will change (human gate).
5. Applies migrations sequentially.
6. Updates `version` in `ape.yaml`.
7. Regenerates target-specific files.
8. Runs `doctor` to verify integrity.

**Flags:**
- `--dry-run`: show migration plan without applying.
- `--force`: skip confirmation prompt.

---

#### `ape repo doctor`

**Mode:** CLI

Verifies the integrity of the `.ape/` configuration and optionally validates memory.

```
$ ape repo doctor

Checking .ape/ integrity...
  ✓ Prerequisites: git 2.43.0, gh 2.45.0
  ✓ ape.yaml valid
  ✓ All 8 agent prompts present
  ✓ All shared skills present (including BORGES)
  ✓ Templates intact
  ✓ Target files in sync with .ape/
  ⚠ hooks/tracker.sh not executable (fixing...)
  ✓ Fixed
  ✓ Task backend reachable (GitHub)

All checks passed.
```

**With `--memory` flag:**

```
$ ape repo doctor --memory

Checking .ape/ integrity... ✓ (all checks passed)

BORGES Validation:
  Scanning .ape/memory/...
  ✓ taxonomy.md present and valid
  ✓ All index.md files present (5/5 directories)
  ✓ Frontmatter schema: 17/17 files valid
  ✓ ID uniqueness: no duplicates
  ✓ Tag compliance: all tags in taxonomy
  ✓ Status values: all valid for type
  ✓ Cross-references: no dangling pointers
  ✓ Index consistency: all indices match files
  ⚠ lesson-002: related_adrs references adr-005 (not found)
    → Suggestion: update or remove reference

16/17 files fully valid. 1 warning.
```

**Checks performed (base):**
- Prerequisites verification (`git`, `gh` in PATH, `gh auth status`).
- `ape.yaml` schema validation.
- All required agent prompt files exist.
- All required skill files exist (including BORGES protocol).
- Templates exist and match expected structure.
- Target-specific files are in sync with `.ape/` source of truth.
- Hooks have correct permissions.
- Version consistency.
- Task backend reachable.

**Additional checks with `--memory`:**
- BORGES validation: parse all frontmatter YAML in `.ape/memory/`.
- Validate against schemas (per memory type).
- Check all cross-references (no dangling pointers).
- Verify index consistency (indices match files).
- Tag compliance (all tags in taxonomy).
- ID uniqueness across all memory files.
- Report violations with suggested fixes.

---

#### `ape repo retarget <target>`

**Mode:** CLI

Changes the agent target without losing configuration.

```
$ ape repo retarget claude

Removing: .github/agents/ (old target: GitHub Copilot)
Generating: .claude/ (new target: Claude Code)
Updating: .ape/ape.yaml → target: claude

✓ Retargeted to Claude Code
```

**Behavior:**
1. Removes old target-specific files.
2. Generates new target-specific files from `.ape/` source of truth.
3. Updates target in `ape.yaml`.
4. Runs `doctor` to verify.

---

#### `ape memory status`

**Mode:** CLI

Shows memory health overview.

```
$ ape memory status

Memory as Code — .ape/memory/
  Taxonomy: 28 tags (4 categories)

  ADRs:        3 files (2 accepted, 1 draft)
  Specs:       5 files (3 active, 2 completed)
  Runbooks:    4 files (1 in_progress, 3 completed)
  Deviations:  7 files (6 resolved, 1 escalated)
  Lessons:     2 files (2 active)
  Reports:     2 files (cycle-summary, risk-patterns)

  Indices: 5/5 present ✓
  BORGES: last validated 2026-03-29 ✓
  Total: 23 memory files
```

---

#### `ape memory search <query>`

**Mode:** CLI

Searches memory files using the query planner strategy (index scan → filter → partial read).

```
$ ape memory search "payments"

Searching indices...
  adrs/index.md: 1 match
  specs/index.md: 2 matches
  deviations/index.md: 1 match

Results:
  adr-003  Payment Gateway Selection       accepted   2026-03-28
  spec-002 Payment Processing Flow         active     2026-03-28
  spec-005 Refund Policy Implementation    draft      2026-03-29
  dev-004  Stripe API version mismatch     resolved   2026-03-29

4 results found. Use 'ape memory search "payments" --full' for content.
```

**Flags:**
- `--type <type>`: filter by memory type (adr, spec, runbook, deviation, lesson).
- `--status <status>`: filter by status.
- `--tag <tag>`: filter by tag.
- `--full`: show file content, not just index matches.
- `--json`: output as JSON (for programmatic use by apes).

---

#### `ape memory validate`

**Mode:** CLI

Runs full BORGES validation on all memory files. Equivalent to `ape repo doctor --memory` but memory-only.

```
$ ape memory validate

BORGES Validation:
  ✓ 17/17 files — schema valid
  ✓ 17/17 files — tags in taxonomy
  ✓ 17/17 files — cross-references valid
  ✓ 5/5 indices — consistent

All memory files pass BORGES validation.
```

**Exit codes:**
- `0`: all valid.
- `1`: violations found (printed to stderr).

This allows apes to call `ape memory validate` as a pre-flight check and react to failures programmatically.

---

#### `ape memory create <type>`

**Mode:** CLI (with validation)

Creates a new memory file with correct schema, unique ID, and updates the index.

```
$ ape memory create adr --title "Authentication Strategy" --tags "auth,security,jwt" --cycle cycle-003

Generating ID: adr-004 (next in sequence)
BORGES validation:
  ✓ ID unique
  ✓ Tags in taxonomy
  ✓ Schema complete

✓ Created .ape/memory/adrs/adr-004-auth-strategy.md
✓ Updated .ape/memory/adrs/index.md
```

**Arguments:**
- `<type>`: one of `adr`, `spec`, `runbook`, `deviation`, `lesson`.

**Flags:**
- `--title <title>`: required. Human-readable title.
- `--tags <tags>`: comma-separated. Must be in taxonomy.
- `--cycle <cycle-id>`: APE cycle context.
- `--status <status>`: initial status (defaults per type: `draft`).
- `--related-specs <ids>`: comma-separated spec IDs.
- `--related-tasks <ids>`: comma-separated task IDs.
- `--body <file>`: path to a file with the body content (below frontmatter).
- `--json`: output created file path and metadata as JSON (for ape consumption).

**Behavior:**
1. Reads the relevant index to determine next sequential ID.
2. Generates frontmatter from flags + defaults.
3. Validates all fields via BORGES rules (tags in taxonomy, related IDs exist, etc.).
4. Creates the .md file with frontmatter + section template for the type.
5. Updates the corresponding `index.md`.
6. Returns the file path (or JSON with full metadata).

**This is the primary write path for apes.** Instead of writing .md files directly, apes execute:
```
ape memory create deviation --title "JWT lib replacement" --tags "jwt,dependency" --cycle cycle-003 --json
```

The CLI guarantees BORGES compliance, index consistency, and unique IDs.

---

#### `ape memory rebuild-index`

**Mode:** CLI

Rebuilds all index.md files from the actual memory files. Recovery command for when indices get out of sync.

```
$ ape memory rebuild-index

Scanning .ape/memory/...
  Rebuilding adrs/index.md (3 files)... ✓
  Rebuilding specs/index.md (5 files)... ✓
  Rebuilding runbooks/index.md (4 files)... ✓
  Rebuilding deviations/index.md (7 files)... ✓
  Rebuilding lessons/index.md (2 files)... ✓

✓ All indices rebuilt from source files.
```

---

#### `ape task create <title>`

**Mode:** CLI

Creates a task backed by a GitHub Issue.

```
$ ape task create "Implement login endpoint" --tags "auth,api" --risk high --spec spec-001

Creating GitHub Issue...
  Title: Implement login endpoint
  Labels: ape-task, risk:high, auth, api
  Body: [generated from spec-001 reference]

✓ Created task-005 (GitHub Issue #42)
✓ Updated .ape/status.md
```

**Flags:**
- `--tags <tags>`: labels for the issue.
- `--risk <level>`: risk level (low, medium, high, critical).
- `--spec <spec-id>`: link to specification in memory.
- `--assignee <user>`: GitHub assignee.
- `--milestone <name>`: GitHub milestone.
- `--body <file>`: path to a file with the issue body.
- `--json`: output task metadata as JSON.

**Backend:** GitHub Issues via `gh` CLI. The task ID mapping (`task-005` → `Issue #42`) is maintained in `.ape/status.md`.

**Design note:** `ape task` is deliberately abstract. The interface is designed so that v1.x.x can support Jira, Linear, Gainline, or any other backend by implementing a `TaskBackend` interface. In v0.x.x, GitHub is the only backend, and `gh` is the only dependency.

---

#### `ape task list`

**Mode:** CLI

Lists tasks from the configured backend.

```
$ ape task list

ID        Status       Risk    Title                          Issue
task-005  in_progress  high    Implement login endpoint       #42
task-006  in_progress  medium  Add password reset flow         #43
task-007  pending      low     Update footer copyright         #44
task-008  pending      medium  Refactor user service           #45

4 open tasks (2 in_progress, 2 pending)
```

**Flags:**
- `--status <status>`: filter by status (pending, in_progress, completed, all).
- `--risk <level>`: filter by risk level.
- `--json`: output as JSON.

---

#### `ape task status [task-id]`

**Mode:** CLI

Shows detailed status of a specific task, or current active task if no ID given.

```
$ ape task status task-005

Task: task-005 — Implement login endpoint
Issue: #42 (https://github.com/org/repo/issues/42)
Risk: high
Spec: spec-001 (User Authentication Flow)
Branch: task-005/login-endpoint
Status: in_progress

Runbook: rb-001 (4 phases)
  ✓ Phase 1: Database schema
  ✓ Phase 2: Service layer
  → Phase 3: API endpoint (current)
  ○ Phase 4: Integration tests

Deviations: 1 tactical (dev-001: JWT lib replacement)
Tests: 12 green, 3 red (phase 3)
```

---

#### `ape task update <task-id>`

**Mode:** CLI

Updates task metadata.

**Flags:**
- `--status <status>`: change status.
- `--risk <level>`: change risk level.
- `--assignee <user>`: change assignee.

---

#### `ape task close <task-id>`

**Mode:** CLI

Closes a task and its backing GitHub Issue.

```
$ ape task close task-005

Closing GitHub Issue #42...
✓ task-005 closed
✓ Updated .ape/status.md
```

---

#### `ape git branch <task-id>`

**Mode:** CLI (skill)

Creates a git branch from a task, following naming conventions.

```
$ ape git branch task-005

Creating branch: task-005/login-endpoint
  Source: main
  Task: Implement login endpoint (Issue #42)

✓ Branch task-005/login-endpoint created and checked out
```

**Naming convention:** `<task-id>/<slug>` derived from the task title.

---

#### `ape git commit`

**Mode:** CLI (skill)

Creates a commit at the end of a green phase. This is a **skill** — it is invoked by apes (typically ADA — TDD implementation) after tests pass, not by humans directly (though humans can use it).

```
$ ape git commit --phase 3 --task task-005

Pre-commit checks:
  ✓ Tests passing (green)
  ✓ No uncommitted memory files
  ✓ Status.md updated

Staging changes...
Creating commit...

✓ Committed: "task-005 phase 3: API endpoint implementation"
  [task-005/login-endpoint abc1234]
```

**Flags:**
- `--phase <n>`: runbook phase number (for commit message).
- `--task <task-id>`: task context.
- `--message <msg>`: override generated commit message.

**Behavior:**
1. Verifies tests are green (runs test command from `ape.yaml`).
2. Stages all relevant changes (source + memory files modified during the phase).
3. Generates a structured commit message: `<task-id> phase <n>: <description>`.
4. Commits. No human gate — a commit after green tests is a mechanical fact, not a decision.
5. Does NOT push. Pushing is part of PR creation.

**Important:** Commits are NOT governed by the risk matrix. A green test suite is a binary fact. The risk matrix governs test approval (what tests to write and when to approve them) and destructive operations, not commits.

---

#### `ape git pr`

**Mode:** CLI (skill)

Creates a pull request for the current task branch.

```
$ ape git pr --task task-005

Pushing task-005/login-endpoint to origin...

Creating PR:
  Title: task-005: Implement login endpoint
  Base: main
  Body: [generated from runbook + deviation log + test summary]

✓ PR #23 created: https://github.com/org/repo/pull/23
```

**Flags:**
- `--task <task-id>`: task context (for title and body generation).
- `--base <branch>`: base branch (default: main).
- `--draft`: create as draft PR.
- `--body <file>`: override generated body.

**Behavior:**
1. Pushes current branch to origin.
2. Generates PR body from: runbook summary, deviation log, test summary, @contract coverage.
3. Creates PR via `gh pr create`.
4. Links PR to the GitHub Issue (via "Closes #N" in body).

---

#### `ape darwin --rebuild-reports`

**Mode:** CLI

Forces a full rebuild of DARWIN's materialized views from source memory files.

```
$ ape darwin --rebuild-reports

Reading all memory files...
  Deviations: 7
  Runbooks: 4
  Lessons: 2

Rebuilding:
  cycle-summary.md... ✓
  risk-patterns.md... ✓

✓ Reports rebuilt from source data.
```

This is the recovery mechanism described in the Memory as Code spec — normally DARWIN updates incrementally, but this command triggers a full recompute.

---

## 5. Repo Configuration (`.ape/`)

### 5.1 Directory Structure

```
.ape/
├── ape.yaml                        # Main configuration file
│
├── agents/                         # Agent prompts (transition functions)
│   ├── scout.md                    # MARCOPOLO: document ingestion
│   ├── analyst.md                  # SOCRATES: requirements understanding
│   ├── architect.md                # VITRUVIUS: decomposition, WBS
│   ├── strategist.md               # SUNZI: runbook generation
│   ├── tester.md                   # GATSBY: @contract test writing
│   ├── coder.md                    # ADA: TDD implementation
│   ├── reviewer.md                 # DIJKSTRA: quality gate
│   └── darwin.md                   # DARWIN: evolutionary analysis
│
├── skills/                         # Skills (tools available to apes)
│   ├── _shared/                    # Universal skills (all apes inherit)
│   │   ├── scribe.md              # BORGES protocol (documentation compiler)
│   │   ├── memory.md              # Memory consultation protocol
│   │   ├── contracts.md           # @contract reading/writing
│   │   └── tracker.md             # State reporting protocol
│   ├── markitdown/                # Document conversion
│   │   └── skill.md
│   ├── mermaid/                   # Diagram generation
│   │   └── skill.md
│   ├── tdd/                       # TDD workflow
│   │   └── skill.md
│   ├── git/                       # Git operations (commit, branch, PR)
│   │   └── skill.md
│   └── security/                  # Security analysis
│       └── skill.md
│
├── templates/                      # Output templates
│   ├── runbook.md                 # Runbook structure template
│   ├── wbs.md                     # WBS output template
│   ├── contract.md                # @contract block template
│   ├── deviation.md               # Deviation report template
│   ├── darwin-report.md           # DARWIN lessons learned template
│   └── status.md                  # Project status template
│
├── hooks/                          # Automation hooks
│   └── tracker.sh                 # HERMES: auto-update status
│
├── memory/                         # Project memory (Memory as Code)
│   ├── taxonomy.md                # Controlled vocabulary for tags
│   ├── adrs/                      # Architecture Decision Records
│   │   └── index.md              # Primary index (HERMES maintains)
│   ├── specs/                     # Specifications (from Analyze)
│   │   └── index.md
│   ├── runbooks/                  # Runbooks (from Plan)
│   │   └── index.md
│   ├── deviations/                # Deviation logs (from Execute)
│   │   └── index.md
│   ├── lessons/                   # Lessons learned (from DARWIN)
│   │   └── index.md
│   ├── reports/                   # Materialized views (DARWIN maintains)
│   │   ├── cycle-summary.md      # Cumulative statistics and trends
│   │   └── risk-patterns.md      # Cross-cycle risk analysis
│   └── changelog.md              # Chronological project evolution
│
└── status.md                       # Current project state (HERMES output)
```

**Versioning rules:**
- Everything in `.ape/` is versioned in git EXCEPT `status.md`.
- `status.md` is listed in `.gitignore` — it is ephemeral working state.
- However, `status.md` IS committed at milestone boundaries (end of APE cycle, tag, release). This captures a snapshot of project state at meaningful points.
- Memory files (`.ape/memory/`) are fully versioned. Git history IS the audit trail.

### 5.2 Configuration File (`ape.yaml`)

```yaml
# Finite APE Machine Configuration
version: "0.2.0"                    # Config schema version (for migrations)

# Agent target
target: copilot                     # copilot | claude | cursor | gemini | opencode

# Technology stack
stack:
  - dart
  - typescript

# Risk matrix defaults
risk:
  default: medium                   # low | medium | high | critical
  rules:                            # Auto-detection rules
    - pattern: "*/payments/*"
      level: high
    - pattern: "*/auth/*"
      level: critical
    - pattern: "*/ui/components/*"
      level: low

# Gate configuration
gates:
  low:
    - tests
    - pr
  medium:
    - analysis
    - plan
    - tests
    - pr
  high:
    - analysis
    - plan
    - tests
    - security_review
    - pr
  critical:
    - analysis
    - plan
    - tests
    - security_review
    - pr
    - per_ape_review

# Task management
tasks:
  backend: github                   # github (only backend in v0.x.x)
  sync_status: true                 # Sync task status with GitHub Issue labels
  labels_prefix: "ape-"             # Prefix for APE-managed labels

# DARWIN configuration
darwin:
  auto_run: true                    # Run DARWIN after each cycle
  issue_target: null                # GitHub repo for framework issues (opt-in)
  # issue_target: "org/finite-ape-machine"

# Test command (used by ape git commit to verify green)
test_command: "dart test"           # or "npm test", "pytest", etc.
```

**Changes from v0.1.0:**
- Removed `memory.provider` and `memory.project_path`. Memory is always `.ape/memory/` as structured .md files. There is no provider choice — Memory as Code is the architecture.
- Added `tasks` section with `backend`, `sync_status`, `labels_prefix`.
- Added `test_command` for green verification during `ape git commit`.

### 5.3 Agent Prompt Files

Each file in `.ape/agents/` is the complete prompt for that ape — its transition function. Structure:

```markdown
# MARCOPOLO — Document Ingestion and Normalization

## Identity
You are MARCOPOLO, a specialized agent in the Finite APE Machine framework.
Your role is to ingest heterogeneous documents and produce structured markdown.

## FSM States
- idle: waiting for task assignment
- ingesting: reading and parsing input documents
- normalizing: converting to structured markdown
- delivering: producing output files

## Transition Rules
- On receiving documents → transition to ingesting
- On parse complete → transition to normalizing
- On normalization complete → transition to delivering
- On delivery confirmed → transition to idle

## Skills Available
- markitdown: convert PDF, Word, Excel, PowerPoint to markdown
- codebase: read and analyze repository structure
- memory: consult project and framework memory via `ape memory search`

## BORGES Protocol (Mandatory)
[Embedded from .ape/skills/_shared/scribe.md]

## CLI API
When you need to create or modify structured data, use the `ape` CLI:
- Create memory: `ape memory create <type> --title "..." --tags "..." --json`
- Search memory: `ape memory search "<query>" --json`
- Validate: `ape memory validate`
Do NOT write to .ape/memory/ directly. The CLI enforces BORGES validation.

## Output Contract
Produce one .md file per input document in the following structure:
...

## Constraints
- Do NOT make decisions about requirements — only normalize
- Do NOT discard information — flag unclear sections
- Do NOT proceed if input format is unrecognizable — report to orchestrator
```

### 5.4 Target File Generation

`ape init` and `ape repo retarget` generate target-specific files from `.ape/`:

| Target | Files Generated | Source |
|--------|----------------|--------|
| GitHub Copilot | `.github/copilot-instructions.md` | `.ape/ape.yaml` + context |
| | `.github/agents/<ape>.md` | `.ape/agents/<ape>.md` |
| Claude Code | `CLAUDE.md` | `.ape/ape.yaml` + context |
| | `.claude/settings.json` | `.ape/ape.yaml` |
| | `.claude/agents/<ape>.md` | `.ape/agents/<ape>.md` |
| Cursor | `.cursor/rules/ape.mdc` | `.ape/agents/*` combined |
| | `.cursorrules` | `.ape/ape.yaml` + context |
| Gemini CLI | `AGENTS.md` | `.ape/agents/*` combined |
| | `.gemini/settings.json` | `.ape/ape.yaml` |
| OpenCode | `.opencode/agents/<ape>.md` | `.ape/agents/<ape>.md` |
| | `.opencode/config.yaml` | `.ape/ape.yaml` |

The generation is deterministic: given the same `.ape/` contents, the same target files are always produced. This means target files can be `.gitignore`d if preferred, or committed for teams that don't use `ape`.

---

## 6. Migration System

### 6.1 How Migrations Work

Each migration is a Dart script embedded in the CLI binary. Migrations are named by version transition:

```
lib/migrations/
├── v0_1_0_to_v0_1_1.dart
├── v0_1_1_to_v0_2_0.dart
└── v0_2_0_to_v0_3_0.dart
```

Each migration implements a standard interface:

```dart
abstract class Migration {
  String get fromVersion;
  String get toVersion;
  String get description;

  /// Returns list of changes that will be made (for dry-run / preview)
  List<String> preview(ApeConfig config);

  /// Applies the migration. Returns true on success.
  Future<bool> apply(ApeConfig config, FileSystem fs);

  /// Rolls back the migration if apply fails mid-way.
  Future<void> rollback(ApeConfig config, FileSystem fs);
}
```

### 6.2 Migration Chain Resolution

```dart
List<Migration> resolveMigrationChain(String from, String to) {
  // Find ordered sequence of migrations from current to target version
  // e.g., "0.1.0" → "0.2.0" resolves to [v0_1_0_to_v0_1_1, v0_1_1_to_v0_2_0]
}
```

### 6.3 Migration Examples

**v0.1.0 → v0.1.1:**
```
Description: Add @contract template, update DIJKSTRA prompt
Changes:
  + .ape/templates/contract.md (new file)
  ~ .ape/agents/reviewer.md (add @contract verification section)
  ~ .ape/ape.yaml (version bump)
```

**v0.1.1 → v0.2.0:**
```
Description: Add memory structure, task config, BORGES protocol, CLI API instructions
Changes:
  + .ape/memory/ (full directory structure with indices and taxonomy)
  + .ape/skills/_shared/scribe.md (BORGES protocol)
  + .ape/skills/git/skill.md (git operations skill)
  ~ .ape/ape.yaml (remove memory.provider, add tasks section, add test_command)
  ~ .ape/agents/*.md (add BORGES protocol section, CLI API section to all agents)
  ~ .ape/templates/deviation.md (new format with frontmatter)
  + .ape/templates/status.md (updated with task/memory sections)
```

### 6.4 Safety Guarantees

- Migrations are **atomic**: if any step fails, the entire migration rolls back.
- Migrations are **idempotent**: running the same migration twice produces the same result.
- `ape repo upgrade --dry-run` always shows what will change before applying.
- A `.ape/.backup/` snapshot is created before each migration chain, deleted on success.

---

## 7. Project Structure (Source Code)

```
finite-ape-machine/
├── bin/
│   └── ape.dart                    # Entry point
│
├── lib/
│   ├── cli/                        # CLI command definitions
│   │   ├── cli_runner.dart         # CommandRunner setup
│   │   ├── init_command.dart
│   │   ├── upgrade_command.dart
│   │   ├── status_command.dart
│   │   ├── repo/                   # Repo subcommands
│   │   │   ├── repo_command.dart
│   │   │   ├── upgrade_command.dart
│   │   │   ├── doctor_command.dart
│   │   │   └── retarget_command.dart
│   │   ├── memory/                 # Memory subcommands
│   │   │   ├── memory_command.dart
│   │   │   ├── status_command.dart
│   │   │   ├── search_command.dart
│   │   │   ├── validate_command.dart
│   │   │   ├── create_command.dart
│   │   │   └── rebuild_index_command.dart
│   │   ├── task/                   # Task subcommands
│   │   │   ├── task_command.dart
│   │   │   ├── create_command.dart
│   │   │   ├── list_command.dart
│   │   │   ├── status_command.dart
│   │   │   ├── update_command.dart
│   │   │   └── close_command.dart
│   │   ├── git/                    # Git subcommands
│   │   │   ├── git_command.dart
│   │   │   ├── branch_command.dart
│   │   │   ├── commit_command.dart
│   │   │   └── pr_command.dart
│   │   └── darwin/                 # Darwin subcommands
│   │       ├── darwin_command.dart
│   │       └── rebuild_reports_command.dart
│   │
│   ├── tui/                        # TUI screens (Nocterm)
│   │   ├── app.dart                # TUI app entry
│   │   ├── screens/
│   │   │   ├── home_screen.dart
│   │   │   ├── init_wizard.dart
│   │   │   ├── status_screen.dart
│   │   │   ├── upgrade_screen.dart
│   │   │   ├── memory_browser.dart
│   │   │   └── task_board.dart
│   │   ├── components/             # Reusable TUI components
│   │   │   ├── agent_card.dart
│   │   │   ├── risk_selector.dart
│   │   │   ├── memory_table.dart
│   │   │   └── progress_bar.dart
│   │   └── theme/
│   │       └── ape_theme.dart
│   │
│   ├── core/                       # Core domain logic
│   │   ├── config.dart             # ApeConfig model (ape.yaml)
│   │   ├── agent.dart              # Agent model
│   │   ├── skill.dart              # Skill model
│   │   ├── version.dart            # Version parsing and comparison
│   │   ├── risk.dart               # Risk matrix logic
│   │   └── prerequisites.dart      # Prerequisite checker (git, gh)
│   │
│   ├── memory/                     # Memory as Code module
│   │   ├── schema.dart             # Frontmatter schema definitions
│   │   ├── index.dart              # Index file parser/writer
│   │   ├── taxonomy.dart           # Taxonomy reader/validator
│   │   ├── scribe_validator.dart   # BORGES validation engine
│   │   ├── query_planner.dart      # Index scan → filter → read strategy
│   │   └── id_generator.dart       # Sequential ID generation
│   │
│   ├── tasks/                      # Task management module
│   │   ├── task_backend.dart       # Abstract TaskBackend interface
│   │   ├── github_backend.dart     # GitHub Issues implementation via gh
│   │   ├── task_model.dart         # Task domain model
│   │   └── status_sync.dart        # Sync APE status ↔ GitHub labels
│   │
│   ├── git/                        # Git operations module
│   │   ├── branch.dart             # Branch creation from task
│   │   ├── commit.dart             # Structured commit (post-green)
│   │   └── pr.dart                 # PR creation with body generation
│   │
│   ├── targets/                    # Target-specific generators
│   │   ├── target.dart             # Abstract target interface
│   │   ├── copilot_target.dart
│   │   ├── claude_target.dart
│   │   ├── cursor_target.dart
│   │   ├── gemini_target.dart
│   │   └── opencode_target.dart
│   │
│   ├── migrations/                 # Version migration scripts
│   │   ├── migration.dart          # Migration interface
│   │   ├── registry.dart           # Migration chain resolver
│   │   ├── v0_1_0_to_v0_1_1.dart
│   │   └── v0_1_1_to_v0_2_0.dart
│   │
│   ├── installer/                  # Self-upgrade logic
│   │   ├── platform.dart           # Platform detection
│   │   ├── downloader.dart         # GitHub Release downloader
│   │   └── self_update.dart        # Binary replacement
│   │
│   └── assets/                     # Embedded assets
│       ├── agents/                 # Default agent prompts
│       ├── skills/                 # Default skill definitions
│       │   └── _shared/
│       │       └── scribe.dart     # BORGES protocol prompt
│       ├── templates/              # Default templates
│       ├── hooks/                  # Default hooks
│       └── memory/                 # Memory initialization assets
│           ├── taxonomy.dart       # Default taxonomy
│           ├── index_templates.dart # Empty index.md templates
│           └── schema_templates.dart # Frontmatter templates per type
│
├── test/                           # Tests
│   ├── cli/
│   ├── tui/
│   ├── core/
│   ├── memory/                     # BORGES validation tests
│   ├── tasks/                      # Task backend tests
│   ├── git/                        # Git operations tests
│   ├── targets/
│   └── migrations/
│
├── scripts/                        # Installation scripts
│   ├── install.sh
│   └── install.ps1
│
├── .github/
│   └── workflows/
│       └── release.yml             # Multi-platform build + release
│
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

## 8. Embedded Assets

The `ape` binary embeds all default agent prompts, skills, templates, hooks, and memory initialization files. These are extracted during `ape init`.

Dart supports embedding assets at compile time. Default agent prompts and skills are stored as Dart string constants in `lib/assets/` and written to disk during init.

```dart
// lib/assets/agents/scout.dart
const scoutPrompt = r'''
# MARCOPOLO — Document Ingestion and Normalization
...
''';
```

### 8.1 Asset Categories

| Category | Contents | Extracted To |
|----------|----------|-------------|
| Agents | 8 agent prompts (transition functions) | `.ape/agents/` |
| Skills | Shared skills (BORGES, memory, contracts, hermes) + specialized (markitdown, mermaid, tdd, git, security) | `.ape/skills/` |
| Templates | Runbook, WBS, @contract, deviation, darwin-report, status | `.ape/templates/` |
| Hooks | tracker.sh | `.ape/hooks/` |
| Memory | taxonomy.md (default vocabulary), empty index.md templates (one per type), frontmatter schema templates | `.ape/memory/` |

### 8.2 BORGES Protocol Asset

The BORGES skill is the most critical shared asset. It contains:

1. The validation checklist (11 checks).
2. The query planner protocol (index → filter → partial → full).
3. The memory write protocol (always via `ape` CLI commands).
4. Schema definitions for all 5 memory types.
5. The index update protocol.

This is embedded in every agent prompt during target file generation.

### 8.3 Offline Guarantee

This ensures:
- No network request needed during `ape init` (works offline, after initial binary download).
- Assets are versioned with the binary (each CLI version carries its matching assets).
- Migrations can compare embedded defaults with repo files to detect customizations.

---

## 9. Workflow Integration

### 9.1 Complete Task Lifecycle

The canonical workflow through APE commands:

```
1. ape task create "Feature title" --spec spec-NNN --risk medium
   → Creates GitHub Issue, assigns task ID

2. ape git branch task-NNN
   → Creates feature branch from task

3. [ANALYZE: MARCOPOLO → SOCRATES → VITRUVIUS]
   → Apes use: ape memory create spec, ape memory create adr
   → Human gates between apes

4. [PLAN: SUNZI → GATSBY]
   → Apes use: ape memory create runbook
   → GATSBY writes test files directly (source code, not memory)
   → Human gate: confirm tests

5. [EXECUTE: ADA → DIJKSTRA]
   → ADA implements TDD phase by phase
   → After each green phase: ape git commit --phase N --task task-NNN
   → Tactical deviations: ape memory create deviation
   → DIJKSTRA runs: ape memory validate (pre-check)
   → Human gate: review PR

6. ape git pr --task task-NNN
   → Creates PR linking to issue

7. [Human merges PR]

8. ape task close task-NNN
   → Closes GitHub Issue

9. [DARWIN runs]
   → ape memory create lesson (if patterns found)
   → Updates reports/cycle-summary.md
   → Updates reports/risk-patterns.md
   → Optionally: creates issue on APE framework repo
```

### 9.2 Skills Use CLI as API

This is a fundamental architectural decision. Apes do NOT:
- Write .md files directly to `.ape/memory/`.
- Modify `index.md` files manually.
- Create GitHub Issues via `gh` directly.
- Run `git commit` directly.

Instead, they execute `ape` CLI commands. This creates a single validation boundary:

```
[Ape prompt] → executes → [ape memory create ...] → [BORGES validates] → [file written + index updated]
[Ape prompt] → executes → [ape task create ...]   → [gh issue create] → [status.md updated]
[Ape prompt] → executes → [ape git commit ...]    → [green verified] → [structured commit]
```

Benefits:
- BORGES validation is enforced programmatically, not just by prompt compliance.
- Index consistency is guaranteed.
- ID uniqueness is guaranteed.
- The CLI can be tested independently of the agent prompts.
- Future backends (Jira, SQLite cache) can be swapped without changing agent prompts.

---

## 10. Future Considerations

### 10.1 Orchestrator (Separate Specification — Pending)

The orchestrator that coordinates apes within a cycle is not part of the CLI — it lives as a special agent prompt that the target tool executes. Decision from debate: Option C (prompt orchestrator + state files) for v0.x.x, with daemon as possible v1+ upgrade. The orchestrator specification is the next document to produce.

### 10.2 Memory as Code Evolution (See: Memory as Code Specification)

The full Memory as Code architecture, including schemas, query planner, BORGES protocol, DARWIN operations, concurrency rules, and upgrade path (v0=md, v1=optional SQLite cache, v2=hybrid search), is specified in the companion document *Memory as Code v0.1.0-spec*.

### 10.3 Task Backend Abstraction

The `TaskBackend` interface in `lib/tasks/task_backend.dart` is designed for extensibility:

```dart
abstract class TaskBackend {
  Future<Task> create(TaskCreateRequest request);
  Future<List<Task>> list({TaskFilter? filter});
  Future<Task> get(String taskId);
  Future<Task> update(String taskId, TaskUpdateRequest request);
  Future<void> close(String taskId);
  Future<String> getUrl(String taskId);
}
```

In v0.x.x, only `GitHubBackend` implements this interface. Future implementations may include Jira, Linear, Gainline, or others — without any change to agent prompts or the CLI command surface.

### 10.4 Plugin System

Future versions may support community-contributed apes and skills installed via:
```
ape install skill <name>
ape install agent <name>
```

### 10.5 Team Configuration

For teams, a shared `.ape/` configuration committed to the repo ensures all developers use the same methodology. Team-specific overrides could be supported via:
```
.ape/
└── overrides/
    └── <user>.yaml     # Per-developer gate preferences, risk tolerance
```

---

## 11. Glossary

| Term | Definition |
|------|-----------|
| **CLI as API** | Architectural decision: apes interact with memory, tasks, and git through `ape` commands, not direct file manipulation |
| **Memory as Code** | Architecture where project memory lives as structured .md files, versioned with git, no external database |
| **BORGES** | Shared skill (documentation compiler) enforcing schema, structure, and cross-reference integrity on all memory files |
| **BORGES validation** | Automated checks run by `ape repo doctor --memory` and `ape memory validate` |
| **Task backend** | Abstract interface for task management; GitHub Issues in v0.x.x |
| **Green phase** | A completed TDD cycle where all tests pass — triggers `ape git commit` |
| **Prerequisite** | External tool required by `ape` (git, gh) — verified during `ape init` |
| **Target** | The AI coding tool that apes run in (Copilot, Claude Code, Cursor, etc.) |
| **Materialized view** | Aggregate report maintained incrementally by DARWIN (`cycle-summary.md`, `risk-patterns.md`) |
| **Taxonomy** | Controlled vocabulary for tags in `.ape/memory/taxonomy.md` |

---

*APE CLI/TUI Specification v0.2.0-spec — Finite APE Machine*
*"Infinite monkeys produce noise. Finite APEs produce software."*
