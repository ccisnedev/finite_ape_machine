# Changelog

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
