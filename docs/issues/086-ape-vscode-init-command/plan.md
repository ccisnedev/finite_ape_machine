---
id: plan
title: "Plan: APE Init command + command guards for VS Code extension"
date: 2026-04-19
status: draft
tags: [vscode, onboarding, guard-clause, init, install, tdd]
author: descartes
---

# Plan: APE Init + Command Guards

## Summary

Five phases transform the extension from v0.0.1 (no onboarding, buggy file creation) to v0.0.2 (guided init, guard clauses, cross-platform install).

---

## Phase 1 — Guard clause: pure logic + unit tests

**Goal:** Create the guard module with platform-aware path resolution and existence checks. Pure functions, no VS Code API dependency.

**File:** `src/guard.ts`

### Steps

- [x] 1.1 Create `src/guard.ts` exporting:
  - `getApeBinaryPath(platform: string): string` — returns absolute path
    - `win32` → `path.join(process.env.LOCALAPPDATA!, 'ape', 'bin', 'ape.exe')`
    - `linux` → `path.join(process.env.HOME!, '.ape', 'bin', 'ape')`
  - `isApeInstalled(platform?: string): boolean` — `fs.existsSync(getApeBinaryPath(...))`
  - `isApeWorkspace(workspaceFolder: string): boolean` — `fs.existsSync(path.join(folder, '.ape'))`

- [x] 1.2 Write unit tests `test/unit/guard.test.ts` (RED → GREEN)

```pseudo
describe('getApeBinaryPath')
  it('returns LOCALAPPDATA path on win32')
    assert getApeBinaryPath('win32') == join(LOCALAPPDATA, 'ape/bin/ape.exe')
  it('returns HOME path on linux')
    assert getApeBinaryPath('linux') == join(HOME, '.ape/bin/ape')
  it('throws on unsupported platform')
    assert throws(() => getApeBinaryPath('darwin'))

describe('isApeInstalled')
  it('returns true when binary exists')
    stub fs.existsSync → true
    assert isApeInstalled('win32') == true
  it('returns false when binary missing')
    stub fs.existsSync → false
    assert isApeInstalled('linux') == false

describe('isApeWorkspace')
  it('returns true when .ape/ exists')
    stub fs.existsSync(join(folder, '.ape')) → true
    assert isApeWorkspace('/workspace') == true
  it('returns false when .ape/ missing')
    stub fs.existsSync → false
    assert isApeWorkspace('/workspace') == false
```

- [x] 1.3 All tests pass (GREEN)
- [x] 1.4 REFACTOR: extract platform detection to `getPlatform(): string` wrapper for testability

**Risk:** `LOCALAPPDATA` env var undefined in CI. Mitigation: test with explicit platform param, mock env.

---

## Phase 2 — Guard integration into existing commands (bug fix)

**Goal:** Wrap `toggleEvolution` and `addMutation` with guard validation. Remove `fs.mkdirSync` bug. Commands now fail gracefully when CLI or `.ape/` are missing.

### Steps

- [x] 2.1 Create `src/command-guard.ts` — VS Code-aware wrapper:

```pseudo
async function withGuard(apeFolderPath, options, fn):
  if not isApeInstalled():
    show notification "APE CLI not found" with [Install] [Cancel]
    if Install → execute command 'ape.init'
    return
  if not options.skipWorkspaceCheck and not isApeWorkspace(folder):
    show notification "No APE workspace" with [Run Init] [Cancel]
    if Run Init → execute command 'ape.init'
    return
  await fn()
```

- [x] 2.2 Write unit tests `test/unit/command-guard.test.ts` (RED → GREEN)

```pseudo
describe('withGuard')
  it('executes fn when CLI installed and .ape/ exists')
    stub isApeInstalled → true, isApeWorkspace → true
    assert fn called once

  it('shows CLI notification when not installed')
    stub isApeInstalled → false
    assert showInformationMessage called with "APE CLI not found"
    assert fn NOT called

  it('shows workspace notification when .ape/ missing')
    stub isApeInstalled → true, isApeWorkspace → false
    assert showInformationMessage called with "No APE workspace"
    assert fn NOT called

  it('skips workspace check when skipWorkspaceCheck is true')
    stub isApeInstalled → true, isApeWorkspace → false
    options = { skipWorkspaceCheck: true }
    assert fn called once
```

- [x] 2.3 All tests pass (GREEN)

- [x] 2.4 Modify `src/commands.ts`:
  - Remove `fs.mkdirSync(path.dirname(...), { recursive: true })` from both functions
  - Both functions now assume `.ape/` exists (guard ensures it)

- [x] 2.5 Modify `src/extension.ts`:
  - Wrap `toggleEvolution` call inside `withGuard(apeFolderPath, {}, () => ...)`
  - Wrap `addMutation` call inside `withGuard(apeFolderPath, {}, () => ...)`

- [x] 2.6 Update existing tests in `test/unit/toggle-evolution.test.ts` and `test/unit/add-mutation.test.ts`:
  - Tests must set up `.ape/` directory before calling commands
  - Verify `mkdirSync` is no longer called

- [x] 2.7 Run full test suite — all 29 existing + new guard tests pass

**Risk:** Breaking existing tests. Mitigation: run tests after each sub-step, not just at the end.

---

## Phase 3 — APE: Init command — happy path (CLI exists)

**Goal:** Register `ape.init` command. When CLI exists, run `ape init` in a VS Code terminal. Extension activates on command.

### Steps

- [x] 3.1 Update `package.json`:
  - Add `"onCommand:ape.init"` to `activationEvents`
  - Add `{ "command": "ape.init", "title": "APE: Init" }` to `contributes.commands`

- [x] 3.2 Create `src/init.ts` with `apeInit(workspaceFolder: string)`:

```pseudo
async function apeInit(workspaceFolder):
  if not workspaceFolder:
    showErrorMessage("Open a folder first")
    return

  if not isApeInstalled():
    → delegate to install flow (Phase 4)
    return

  terminal = createTerminal('APE Init')
  terminal.show()
  terminal.sendText(`"${binaryPath}" init`)
```

- [x] 3.3 Register command in `src/extension.ts`:
  - `vscode.commands.registerCommand('ape.init', () => apeInit(workspaceFolder))`
  - Command must work even when `workspaceFolder` was undefined at activation (re-query `workspaceFolders`)

- [x] 3.4 Write unit tests `test/unit/init.test.ts` (RED → GREEN)

```pseudo
describe('apeInit')
  it('shows error when no workspace folder')
    stub workspaceFolders → undefined
    assert showErrorMessage called

  it('runs ape init in terminal when CLI exists')
    stub isApeInstalled → true
    assert createTerminal called with 'APE Init'
    assert sendText called with path containing 'ape init'

  it('delegates to install flow when CLI missing')
    stub isApeInstalled → false
    assert install flow triggered (Phase 4 stub)
```

- [x] 3.5 All tests pass (GREEN)

- [x] 3.6 Manual smoke test: `Ctrl+Shift+P` → "APE: Init" activates extension

**Risk:** Terminal command path with spaces. Mitigation: quote the binary path.

---

## Phase 4 — APE: Init — install flow (CLI missing)

**Goal:** When CLI not found, offer installation via notification. Spawn install script with progress parsing. Post-install, verify and run `ape init`.

### Steps

- [x] 4.1 Create `src/installer.ts`:

```pseudo
async function installApeCli():
  script = platform == 'win32'
    ? 'powershell -NoProfile -c "irm https://www.ccisne.dev/finite_ape_machine/install.ps1 | iex"'
    : 'bash -c "curl -fsSL https://www.ccisne.dev/finite_ape_machine/install.sh | bash"'

  await window.withProgress({ location: Notification, title: 'Installing APE CLI', cancellable: true }, (progress, token) =>
    return new Promise((resolve, reject) =>
      proc = spawn(shell, args)
      token.onCancellationRequested → proc.kill()

      proc.stdout.on('data', chunk =>
        lines = chunk.toString().split('\n')
        for line in lines:
          if line.startsWith('>>>'):
            progress.report({ message: line.slice(4).trim() })
      )

      proc.on('close', code =>
        if code == 0: resolve()
        else: reject(new Error(`Install failed (exit ${code})`))
      )
    )
  )
```

- [x] 4.2 Wire install flow into `src/init.ts`:
  - When `isApeInstalled()` returns false:
    - Show notification: "APE CLI not found. Install it?" with [Install] [Cancel]
    - If Install → call `installApeCli()`
    - After install → verify `isApeInstalled()` is now true
    - If verification passes → run `ape init` in terminal
    - If verification fails → show error "Installation failed"

- [x] 4.3 Write unit tests `test/unit/installer.test.ts` (RED → GREEN)

```pseudo
describe('installApeCli')
  it('spawns powershell on win32')
    stub platform → 'win32'
    stub spawn → mock process
    emit stdout '>>> Downloading...\n'
    emit close(0)
    assert progress.report called with { message: 'Downloading...' }
    assert resolves

  it('spawns bash on linux')
    stub platform → 'linux'
    stub spawn → mock process
    emit close(0)
    assert resolves

  it('rejects on non-zero exit code')
    stub spawn → mock process
    emit close(1)
    assert rejects with 'Install failed (exit 1)'

  it('kills process on cancellation')
    stub spawn → mock process
    fire token.onCancellationRequested
    assert proc.kill called

  it('reports multiple progress milestones')
    emit stdout '>>> Fetching...\n>>> Downloading...\n>>> Extracting...\n'
    emit close(0)
    assert progress.report called 3 times
```

- [x] 4.4 Integration test `test/integration/init-flow.test.ts` (deferred — requires VS Code runtime)

```pseudo
describe('APE: Init integration')
  it('shows install notification when CLI missing')
  it('completes full flow: install → verify → ape init')
```

- [x] 4.5 All unit tests pass (GREEN)
- [x] 4.6 REFACTOR: extract `getInstallCommand(platform)` for testability

**Risk:** Corporate proxy blocks download. Mitigation: D6 — show error with manual install URL.
**Risk:** Antivirus quarantines binary. Mitigation: show error suggesting allowlist.

---

## Phase 5 — README + CHANGELOG + version bump + publish

**Goal:** Document onboarding, bump version, publish v0.0.2.

### Steps

- [x] 5.1 Update `README.md`:
  - Add "Getting Started" section with `APE: Init` instructions
  - Add "Requirements" section noting Windows/Linux only
  - Document the three commands with expected behavior

- [x] 5.2 Update `CHANGELOG.md`:

```markdown
## [0.0.2] - 2026-04-XX

### Added
- `APE: Init` command — detects, installs, and initializes APE CLI
- Guard clause on all commands — validates CLI + workspace before executing
- Cross-platform install (Windows + Linux) with progress notification

### Fixed
- Commands no longer silently create `.ape/` without CLI validation
```

- [x] 5.3 Bump `package.json` version: `"0.0.1"` → `"0.0.2"`

- [x] 5.4 Run full test suite: `npm run test:unit`

- [x] 5.5 Package: `npx vsce package --no-dependencies`

- [x] 5.6 Publish: `npx vsce publish --no-dependencies`

- [x] 5.7 Commit + PR: `"086: ape-vscode v0.0.2 — APE Init + command guards"`

---

## Dependency Graph

```
Phase 1 (guard logic)
   ↓
Phase 2 (bug fix — uses guard)
   ↓
Phase 3 (init command — uses guard)
   ↓
Phase 4 (install flow — called from init)
   ↓
Phase 5 (docs + release)
```

## Files Created/Modified

| File | Action | Phase |
|------|--------|-------|
| `src/guard.ts` | CREATE | 1 |
| `test/unit/guard.test.ts` | CREATE | 1 |
| `src/command-guard.ts` | CREATE | 2 |
| `test/unit/command-guard.test.ts` | CREATE | 2 |
| `src/commands.ts` | MODIFY — remove mkdirSync | 2 |
| `src/extension.ts` | MODIFY — add guards + init registration | 2, 3 |
| `test/unit/toggle-evolution.test.ts` | MODIFY | 2 |
| `test/unit/add-mutation.test.ts` | MODIFY | 2 |
| `src/init.ts` | CREATE | 3 |
| `test/unit/init.test.ts` | CREATE | 3 |
| `package.json` | MODIFY — activationEvents + command | 3, 5 |
| `src/installer.ts` | CREATE | 4 |
| `test/unit/installer.test.ts` | CREATE | 4 |
| `test/integration/init-flow.test.ts` | CREATE (stub) | 4 |
| `README.md` | MODIFY | 5 |
| `CHANGELOG.md` | MODIFY | 5 |

## Exit Criteria

- All unit tests pass (existing 29 + new ~20)
- `APE: Init` works on Windows (manual test)
- Guard blocks `toggleEvolution`/`addMutation` when `.ape/` missing
- No `fs.mkdirSync` creating `.ape/` in command code
- Published v0.0.2 on Marketplace
