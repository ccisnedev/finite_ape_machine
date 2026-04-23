# Changelog

## [0.1.3] - 2026-04-23

### Changed
- Marketplace metadata aligned with the current Inquiry documentation map: description now includes the explicit END gate and homepage points to the public Inquiry site
- README and internal extension docs now route readers to canonical repository docs instead of acting like primary doctrine
- Integration coverage is now exercised inside the VS Code host for activation, mutation notes, evolution toggling, and status-bar behavior instead of remaining as skipped placeholders

### Fixed
- Historical design notes now explicitly mark old `ape` vocabulary and `docs/issues/*/plan.md` examples as archive-only guidance
- The integration suite no longer reports skipped placeholder cases for the currently shipped extension features

## [0.1.2] - 2026-04-22

### Changed
- Description updated to canonical `Inquiry — Analyze. Plan. Execute.` subtitle (#122)
- README alt text updated: `Inquiry finite state machine` (#122)

## [0.0.6] - 2026-04-20

### Changed
- Icon: triple yin-yang replaces APE text logo
- FSM diagram: embedded SVG replaces ASCII art in README
- README phase table: removed internal agent names (cleaner for Marketplace)

## [0.0.5] - 2026-04-19

### Changed
- Description aligned with APE branding: "Analyze. Plan. Execute."
- README rewritten as landing page with honest Copilot-only messaging
- Removed redundant `onCommand:ape.init` from `activationEvents`

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
