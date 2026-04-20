# Changelog

## [0.0.4] - 2026-04-19

### Changed
- Brand refresh: horizontal APE icon (JetBrains Mono 700, red on navy with radial glow)
- Sidebar glyph now uses `currentColor` so it tints with the VS Code theme

## [0.0.3] - 2026-04-19

### Fixed
- Installer uses download-then-execute pattern instead of pipe-to-exec (fixes Marketplace virus scan failure)
- Exclude `docs/` from `.vsix` package

### Changed
- `getInstallCommand` replaced by `getInstallScriptUrl` + `getRunCommand` (two-step: download to temp, then execute file)
- Installer now downloads script to `%TEMP%`/`/tmp` via Node.js `https.get`, then runs with `powershell -File` / `bash`

## [0.0.2] - 2026-04-19

### Added
- `APE: Init` command — detects, installs, and initializes APE CLI from VS Code
- Guard clause on all commands — validates CLI + workspace before executing
- Cross-platform install (Windows + Linux) with progress notification

### Fixed
- Commands no longer silently create `.ape/` without CLI validation

## [0.0.1] - 2026-04-19

### Added
- Status bar showing FSM state (IDLE, ANALYZE, PLAN, EXECUTE, END, EVOLUTION) with live updates
- Toggle Evolution command (`APE: Toggle Evolution`) — reads/writes `.ape/config.yaml`
- Add Mutation Note command (`APE: Add Mutation Note`) — appends to `.ape/mutations.md`
- Automatic activation when `.ape/` directory exists in workspace
