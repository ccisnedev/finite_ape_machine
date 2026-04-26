# Changelog
All notable changes to this project will be documented in this file.

The format loosely follows [Keep a Changelog](https://keepachangelog.com/)
and the project adheres to [Semantic Versioning](https://semver.org/).

## [0.2.0]
### Added
- **FSM module** (`iq fsm`): renamed from `iq state`, new `iq fsm state --json` command returns full FSM context (state, issue, transitions, APEs, instructions) for machine consumption
- **Effect execution**: `iq fsm transition` now executes CLI-side effects (update_state, reset_mutations, snapshot_metrics, close_cycle, collect_metrics) — skill-side effects reported for agent handling
- **Sub-agent YAMLs**: four versioned APE definitions in `assets/apes/` (socrates, descartes, basho, darwin) with base_prompt + per-state prompts
- **APE prompt assembly** (`iq ape prompt --name <name> [--state <sub_state>]`): reads YAML definition + FSM state, assembles context-aware prompt; auto-reads sub-state from `state.yaml` when `--state` omitted
- **RTOS dual-FSM**: each APE has its own internal FSM with validated transitions, persistence in `state.yaml`, and `_DONE` sentinel for completion
- **APE state** (`iq ape state`): reports active sub-agent's current state and valid internal transitions
- **APE transition** (`iq ape transition --event <e>`): validates and executes internal APE transitions with semantic error codes
- **Auto-activation**: main FSM transitions automatically activate the corresponding APE at its `initial_state`
- **Firmware thin agent**: replaced 554-line monolith `inquiry.agent.md` with ~35-line dual-loop scheduler (outer=FSM, inner=per-APE)
- **InquiryState helper**: centralized read/write of `state.yaml` including `ape:` field with backward compatibility
- **Devcontainer**: `.devcontainer/devcontainer.json` with Dart SDK for Linux e2e testing

### Changed
- **state.yaml format**: now includes `ape: {name, state}` field (backward-compatible with old format)
- **`iq init`**: generates `state.yaml` with `ape: null` field

### Fixed
- **doctor reports "0 skills deployed"** (#145): `Assets` now injected into `DoctorCommand` via `buildGlobalModule`
- **APE domain errors**: `StateError`/`ArgumentError` replaced with `CommandException` using semantic exit codes (conflict=6, notFound=4, validationFailed=7)
- **EXECUTE→END preserves APE state**: same-APE transitions no longer reset sub-state to `initial_state`

## [0.1.3]
### Changed
- **Historical naming boundary** (#134): `APE builds APE` is now preserved only as the historical bootstrap thesis and lore wording from the period when APE was the system's working name; Inquiry remains the current system identity across README, lore, and site bootstrap surfaces
- **Live FSM contract** (#134): the CLI now treats `END` as an explicit runtime state between `EXECUTE` and `EVOLUTION`, with updated transition prompts, TUI output, and distributed FSM assets

### Fixed
- **issue-start skill path drift** (#134): deployed source and build assets now create `cleanrooms/<NNN>-<slug>/analyze/` instead of the stale `docs/issues/` path
- **Asset regression coverage** (#134): `assets_test.dart` now asserts the distributed `issue-start` skill uses `cleanrooms/`
- **FSM verification drift** (#134): transition tests now reuse the live contract asset and cover the `EXECUTE -> END -> EVOLUTION|IDLE` flow explicitly

## [0.1.2]
### Changed
- **Identity unification** (#122): canonical title+subtitle `Inquiry — Analyze. Plan. Execute.` applied uniformly across README, CLI README, agent definition, and site
- **Agent paths** (#122): all `docs/issues/` references in `inquiry.agent.md` updated to `cleanrooms/`
- **Site architecture** (#122): `site/CNAME` removed from repo; `www.si14bm.com` domain transferred to org repo `SiliconBrainedMachines/siliconbrainedmachines`
- **Site content** (#122): `index.html` double-DOCTYPE bug fixed; product site copy updated to Inquiry branding across `index.html`, `agents.html`, `methodology.html`
- **issue-start skill** (#122): `docs/issues/` → `cleanrooms/` path updated

## [0.1.0]
### Changed
- **Rebrand**: APE CLI renamed to Inquiry CLI (`inquiry` binary, `iq` alias)
- Config directory changed from `.ape/` to `.inquiry/`
- Package renamed from `ape_cli` to `inquiry_cli`
- GitHub org: siliconbrainedmachines, repo: siliconbrainedmachines/inquiry

## [0.0.16]
### Added
- **Site validation tests** (`site_test.dart`): 14 tests validating `code/site/` HTML structure, meta tags, install scripts, and secondary pages
- **Triangular version sync test**: `version_sync_test.dart` now checks all three version sources are mutually consistent with actionable error messages

### Fixed
- **CI trigger for site changes** (#103): `ci.yml` now includes `code/site/**` in paths filter so site changes trigger version sync tests
- **Version sync test messages**: Error output now tells the developer exactly which file to fix

## [0.0.15]
### Added
- **Target verification in `ape doctor`** (#96): Verify agent and skill deployment per target
  - Check `.ape/` directory existence with `ape init` remediation suggestion
  - Check agent file existence in `~/.copilot/agents/`
  - Dynamic skill discovery from asset tree (no hardcoded list)
  - Asymmetric verbosity: clean output when OK, detailed errors with remediation
  - Exit code 1 when target checks fail
  - `FileSystemOps` abstraction for testable filesystem access
  - 8 new tests covering Scenarios A-D (all pass, nothing deployed, no init, partial)
  - Cross-platform validated: Windows + Linux (WSL)

## [0.0.14]
### Added
- **EVOLUTION infrastructure** (#68): `.ape/config.yaml` + `.ape/mutations.md` lifecycle
  - `ape init` creates `.ape/config.yaml` with `evolution.enabled: false` default
  - `ape init` creates `.ape/mutations.md` with header template for DARWIN
  - Both files are idempotent (never overwritten if already present)
  - `reset_mutations` effect declared in IDLE→ANALYZE and EVOLUTION→IDLE transitions
  - DARWIN prompt updated to include `mutations.md` as input

## [0.0.13]
### Changed
- **Modular structure refactor** (#66): Align ape_cli with modular_cli_sdk conventions
  - Create `lib/modules/{global,target,state}/commands/` directory structure
  - Extract `buildGlobalModule`, `buildTargetModule`, `buildStateModule` builder functions
  - Move 9 command files from flat `lib/commands/` to domain-grouped modules
  - Rewrite `ape_cli.dart` entry point: 117 → 49 lines (3 `cli.module()` registrations)
- **cli_router regression tests**: 7 empty-mount tests added to cli_router

## [0.0.12]
### Added
- **FSM Declarative Transition Contract** (#51): YAML-based state machine contract defining allowed/forbidden transitions and operations
- `ape state transition` command: Programmatic state transitions with precondition validation (issue-first, branch-policy)
- Precondition validation gates: issue_selected, feature_branch_selected checks before irreversible actions
- Fail-closed prompt fragment registry: Explicit error on missing prompt_fragment_id or referenced fragments
- Full-cycle integration tests: Incident replay prevention, full FSM cycle validation (IDLE→ANALYZE→PLAN→EXECUTE→EVOLUTION→IDLE)
### Changed
- IDLE state now supports exploration without issue context, but blocks commitment actions until preconditions validated
- State transitions now use declarative operation definitions (precheck, effects, commit_policy) instead of agent reasoning

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
- `assets` module with `ape` agent and memory skills.
- Adapter pattern with 5 targets (claude, codex, copilot, crush, gemini).
- Deployer and `ape target get` / `ape target clean` commands.
- `ape version` command.

## [0.0.1]
### Added
- Initial Dart project scaffold with `modular_cli_sdk`.
- `ape init` command.
