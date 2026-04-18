# Changelog
All notable changes to this project will be documented in this file.

The format loosely follows [Keep a Changelog](https://keepachangelog.com/)
and the project adheres to [Semantic Versioning](https://semver.org/).

## [0.0.9]
### Added
- `ape` TUI — displays FSM diagram when invoked without arguments
- Skill `issue-end` — 9-step protocol for completing APE cycles (EXECUTE → EVOLUTION)
### Fixed
- Version inconsistency: unified to single source of truth in `lib/src/version.dart`
### Changed
- `ape doctor` now imports shared version constant
- `ape version` now imports shared version constant

## [0.0.8]
### Added
- `ape doctor` command — verifies prerequisites (ape, git, gh, gh auth, gh copilot)
- Skill `issue-start` — 8-step protocol for transitioning IDLE → ANALYZE
### Changed
- Updated `ape.agent.md` with doctor checks and issue-start skill reference

## [0.0.7]
### Changed
- `ape init` now performs 5 idempotent steps (#21):
  1. Detect `doc/` or `docs/` directory (prefers `docs/`)
  2. Create `{docs}/issues/` for APE cycle artifacts
  3. Add `.ape/` to `.gitignore`
  4. Create `.ape/state.yaml` with IDLE state
  5. Deploy agent to active target (via `ape target get`)
- Rename `docs/ape/` to `docs/issues/` — each APE cycle maps to an issue
### Added
- Future architecture specs moved to `docs/references/`:
  cooperative-multitasking-model, agent-lifecycle,
  signal-based-coordination, cli-as-api

## [0.0.6]
### Fixed
- Revert subsumption (D19): deploy only to Copilot instead of skipping it when Claude exists (#22).
- `target get` now deploys exclusively to `~/.copilot/` (D20: single-target until MVP).
- `target clean` and `uninstall` still clean all 5 target directories for backward compatibility.
### Removed
- `effectiveAdapters` subsumption logic from deployer (D22).

## [0.0.5]
### Added
- `ape uninstall` command (#16).

## [0.0.4]
### Fixed
- `ape upgrade` renames the running executable before extracting the new one (#14).

## [0.0.3]
### Added
- `ape upgrade` command and automatic release on merge (#3).
### Fixed
- `copilot` target is skipped when `claude` coexists (#12).

## [0.0.2]
### Added
- Initial Dart project scaffold and `ape init` command.
- `assets` module with `ape` agent and memory skills.
- Adapter pattern with 5 targets (claude, codex, copilot, crush, gemini).
- Deployer and `ape target get` / `ape target clean` commands.
- `ape version` command.
