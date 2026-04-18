# Changelog
All notable changes to this project will be documented in this file.

The format loosely follows [Keep a Changelog](https://keepachangelog.com/)
and the project adheres to [Semantic Versioning](https://semver.org/).

## [0.0.11]
### Added
- **Linux support**: PlatformOps abstraction with Windows and Linux implementations
- `install.sh` — Linux installer (`curl | bash`)
- `build.sh` — Linux build script (mirrors `build.ps1`)
- `ci.yml` — CI workflow with `ubuntu-latest` + `windows-latest` matrix
- `ape doctor` now checks VS Code Copilot extension (`code --list-extensions`)
- OS tabs (Windows/Linux) on landing page
### Changed
- FSM rewrite: 6-state model with END state, optional EVOLUTION, retrospective.md, git conventions
- `release.yml` restructured to 3-job pattern: check-version → create-release → build (matrix)
- `ape upgrade` refactored to use PlatformOps (cross-platform archive extraction)
- `ape uninstall` refactored to use PlatformOps (cross-platform env vars and deletion)
- Windows Defender workaround in release.yml now conditional (`if: runner.os == 'Windows'`)
### Fixed
- `ape init` `_relative()` now uses `p.relative()` instead of fragile `replaceFirst`
- Uninstall tests no longer corrupt `dart.exe` (FakePlatformOps injection)

## [0.0.10]
### Fixed
- TUI shows diagram only in text mode (no "version:", "diagram:" field labels)
- Doctor shows formatted checkmarks in text mode (✓/✗) like `flutter doctor`
- Upgrade shows cleaner status message with checkmark
### Changed
- Deps: modular_cli_sdk ^0.2.1 (adds `Output.toText()` for custom text formatting)
### Added
- `Output.toText()` implementations for TuiOutput, DoctorOutput, UpgradeOutput
- 5 new tests for toText() behavior

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
