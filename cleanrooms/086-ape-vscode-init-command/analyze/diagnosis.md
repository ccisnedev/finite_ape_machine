---
id: diagnosis
title: "Diagnosis: APE Init + command guards — onboarding and validation from VS Code extension"
date: 2026-04-19
status: completed
tags: [vscode, onboarding, cli-detection, install, ux, bug-fix, guard-clause]
author: socrates
---

# Diagnosis: APE Init + Command Guards

## Problem Statement

Users who install the APE VS Code extension from the Marketplace cannot use it without first installing the APE CLI separately. There is no onboarding path from within VS Code — the extension activates only when `.ape/` exists, creating a chicken-and-egg problem for new users.

## Bug in v0.0.1

The commands `APE: Add Mutation Note` and `APE: Toggle Evolution` are active even when `.ape/` does not exist. If invoked without a workspace, they silently create the `.ape/` directory and their corresponding file (`mutations.md`, `config.yaml`) directly — bypassing `ape init` entirely.

This is incorrect behavior:
- Files are created without CLI validation, producing an incomplete `.ape/` structure
- The user gets no feedback that the CLI is missing
- The extension masks the absence of a proper `ape init` run

**All APE commands must validate CLI installation and `.ape/` existence before executing.** Files should never be created directly by the extension.

## Guard Clause Pattern

Every APE command (`ape.init`, `ape.toggleEvolution`, `ape.addMutation`) must pass through a shared guard before execution:

```
1. Command triggered
2. Guard: does `ape` binary exist at known path?
   ├─ NO  → notification: "APE CLI not found. [Install] [Cancel]"
   │        (Install triggers the install flow from APE: Init)
   └─ YES → does `.ape/` exist in workspace?
            ├─ NO  → notification: "No APE workspace found. Run APE: Init first. [Run Init] [Cancel]"
            └─ YES → execute the command normally
```

Exception: `ape.init` skips the `.ape/` check (its purpose is to create it).

## User Persona

New user browsing the VS Code Marketplace for AI-assisted programming tools. Finds APE, installs the extension, and expects a guided setup experience (like Flutter's extension offers).

## UX Flow

1. User installs extension from Marketplace
2. Opens any workspace → `Ctrl+Shift+P` → "APE" → selects **APE: Init**
3. Extension checks if `ape` binary exists at known path:
   - Windows: `%LOCALAPPDATA%\ape\bin\ape.exe`
   - Linux: `~/.ape/bin/ape`
4. **If found:** runs `ape init` in the workspace folder via terminal
5. **If NOT found:** shows notification with `[Install]` and `[Cancel]` actions
6. User clicks "Install" → extension spawns install script with `window.withProgress`:
   - Windows: `powershell -c "irm https://www.ccisne.dev/finite_ape_machine/install.ps1 | iex"`
   - Linux: `bash -c "curl -fsSL https://www.ccisne.dev/finite_ape_machine/install.sh | bash"`
7. Progress notification shows milestones parsed from script stdout (`>>>` markers):
   - "Fetching latest release..."
   - "Downloading..."
   - "Extracting..."
   - "Verifying installation..."
   - "APE CLI installed successfully!"
8. On success → runs `ape init` in workspace
9. `.ape/` created → status bar appears, extension fully functional

## Technical Decisions

| # | Decision | Rationale |
|---|----------|-----------|
| D1 | Invoke existing install scripts, not reimplementation | Single source of truth for installation logic |
| D2 | Extension uses absolute path internally (hardcoded) | PATH changes not visible until VS Code restart. Known deterministic paths avoid ambiguity |
| D3 | No configurable `ape.cliPath` setting | Third-party distribution unlikely to be relocated. KISS principle. |
| D4 | `onCommand:ape.init` added to activationEvents | Onboarding requires activation without `.ape/` existing |
| D5 | `child_process.spawn` + `window.withProgress` for install | Milestones parsed from script stdout markers (`>>>`). User sees live progress. |
| D6 | Optimistic error handling | Show error notification on failure, no retry loops |
| D7 | `ape init` runs in terminal (not hidden) | User sees output of `ape init`, transparency over magic |
| D8 | No backward compatibility requirement | v0.0.x phase, no installed base to worry about |
| D9 | Discoverability via Marketplace docs | `Ctrl+Shift+P` → "APE" shows `APE: Init`. Document in README. |
| D10 | All APE commands validate CLI + `.ape/` before executing | v0.0.1 bug: commands silently create files without CLI. Guard clause centralizes validation, provides user-friendly notifications with actionable buttons, and prevents corrupt `.ape/` state. |

## Constraints

- v0.0.2 scope — adds `APE: Init` command + guard clause on all commands
- No CLI execution beyond `ape init` (boundary from v0.0.1)
- Cross-platform: Windows x64 + Linux x64
- Scripts hosted at `ccisne.dev/finite_ape_machine/install.{ps1,sh}`

## Risks

| Risk | Mitigation |
|------|-----------|
| Corporate proxy blocks GitHub API | Show error message with manual install link |
| Antivirus quarantines binary after extraction | Show error, suggest allowlisting |
| Script markers change | Loose parsing — unknown lines ignored, progress still works |
| User cancels mid-install | No cleanup needed — partial install is harmless, next attempt overwrites |

## Scope Boundary

**IN:**
- `APE: Init` command registered in `package.json`
- `onCommand:ape.init` activation event
- CLI detection (file existence check at known path)
- Install via scripts with progress notification
- Run `ape init` after install/detection
- Guard clause on `ape.toggleEvolution` and `ape.addMutation` (validate CLI + `.ape/`)
- Remove direct file creation from existing commands (bug fix)
- Updated README with onboarding instructions

**OUT (deferred):**
- `ape.cliPath` configurable setting
- Walkthrough / welcome tab
- Auto-update CLI
- macOS support (no install script yet)
- Retry/recovery loops on failure

## References

- Flutter/Dart extension SDK detection: `Dart-Code/Dart-Code` repo, `src/extension/sdk/utils.ts`
- APE install scripts: `code/site/install.ps1`, `code/site/install.sh`
- Current extension: `code/vscode/src/extension.js`
- Issue: https://github.com/ccisnedev/finite_ape_machine/issues/86
