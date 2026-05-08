# Plan — Issue #177: Rebuild IDLE Around Dewey

**Input:** [diagnosis.md](analyze/diagnosis.md)
**Plan invariant:** After approval, only checkbox state and deviation annotations may change.
**Execution root:** Run all `dart`, `iq`, and `rg` commands from `code/cli` unless a step explicitly names the repository root.
**Deviation rule:** If a phase verification produces unrelated failures or falsifies the phase hypothesis, stop implementation, record a deviation note under that phase, and return to ANALYZE before opening a new edit slice.
**Approval-boundary rule:** Phase-boundary commits are part of the programmatic protocol, not agent discretion. In particular, approving ANALYZE must create an explicit analysis commit before PLAN begins, and approving PLAN must create the explicit plan-boundary commit required before EXECUTE begins.
**Ordering thesis:** P0 repairs both approval boundaries so ANALYZE -> PLAN and PLAN -> EXECUTE produce real commits programmatically, P1 freezes the target dewey contract in RED tests, P2 establishes the canonical runtime asset and IDLE entry binding, P3 updates every remaining CLI truth surface to that binding, P4 brings declared architecture into sync only after the runtime contract is GREEN, and P5 records and validates the finished contract last.

## Phase 0 — Make approval-boundary commits programmatic (P0)

**Entry:** [diagnosis.md](analyze/diagnosis.md) approved; the current approval boundaries rely on commit-policy metadata that does not yet materialize explicit commits in the transition path.
**Depends on:** None.
**Risk:** High — this is a phase-boundary contract change, so a partial fix could leave the FSM contract, transition command, and tests disagreeing about whether approval merely stages, merely requires a branch, or actually commits the artifacts that justify the next phase.
**Produces:** Two explicit, enforced approval boundaries: approving analysis creates the analysis commit before PLAN begins, and approving the plan creates the plan-boundary commit before EXECUTE begins. Both transitions fail closed if the required commit cannot be produced.
**Why first:** The user review surfaced that the current cycle itself crossed ANALYZE -> PLAN without the expected commit, and inspection shows PLAN -> EXECUTE has the same structural weakness: the contract names a policy, but the transition command does not execute it. Fixing both boundaries first keeps later work coherent with Inquiry's stated methodology that phase transitions should be explicit protocol behavior rather than LLM judgment.

**Tests (pseudocode):**

```text
workspace := feature branch with modified analyze artifacts for issue 177
when complete_analysis is executed after user approval
then the transition path creates a git commit for analysis artifacts
and only then advances state.yaml to PLAN

workspace := same scenario but commit creation fails
when complete_analysis runs
then the command fails closed
and state.yaml remains ANALYZE

workspace := feature branch with approved plan artifacts
when approve_plan is executed after user approval
then the transition path creates the required plan-boundary commit
and only then advances state.yaml to EXECUTE

workspace := same scenario but commit creation fails
when approve_plan runs
then the command fails closed
and state.yaml remains PLAN

contract := parsed transition contract
when ANALYZE + complete_analysis and PLAN + approve_plan are inspected
then commit behavior is explicit and no longer represented as ambiguous stage_only / branch_required behavior
```

**Verification (pseudocode):**

```text
run dart test test/fsm_contract_test.dart test/fsm_transition_test.dart
expect exit 0
expect tests assert explicit commit semantics for ANALYZE -> PLAN and PLAN -> EXECUTE

workspace := temp repo on issue-linked branch with modified analyze artifacts
run iq fsm transition --event complete_analysis
expect transition succeeds only after a new analysis commit exists in git log
expect .inquiry/state.yaml contains state: PLAN

workspace := same setup with forced commit failure
run iq fsm transition --event complete_analysis
expect command fails
expect .inquiry/state.yaml still contains state: ANALYZE

workspace := temp repo on issue-linked branch with approved plan artifacts
run iq fsm transition --event approve_plan
expect transition succeeds only after a new plan-boundary commit exists in git log
expect .inquiry/state.yaml contains state: EXECUTE

workspace := same setup with forced commit failure
run iq fsm transition --event approve_plan
expect command fails
expect .inquiry/state.yaml still contains state: PLAN
```

**TDD:** Yes. Freeze the missing approval-boundary behavior in tests first so the current omission is observable as a contract failure before changing transition execution.

- [x] Edit `code/cli/assets/fsm/transition_contract.yaml` so `ANALYZE + complete_analysis` and `PLAN + approve_plan` encode explicit commit requirements instead of the current ambiguous `stage_only` / `branch_required` behavior.
- [x] Edit `code/cli/lib/modules/fsm/commands/transition.dart` and any supporting transition surface so approval of analysis and approval of plan perform the required commits programmatically or fail closed.
- [x] Update `code/cli/test/fsm_contract_test.dart` to assert the new explicit commit semantics for `complete_analysis` and `approve_plan`.
- [x] Update `code/cli/test/fsm_transition_test.dart` and the nearest integration test so ANALYZE -> PLAN and PLAN -> EXECUTE no longer pass when they only update state without creating the required boundary commit.
- [x] Run `dart test test/fsm_contract_test.dart test/fsm_transition_test.dart test/fsm_transition_integration_test.dart` until the approval-boundary contract is GREEN.
- [x] Commit: "fix(cli): make approval-boundary commits explicit for #177"

## Phase 1 — Lock the target IDLE contract in executable tests (P1)

**Entry:** Phase 0 complete; the target contract is `IDLE -> dewey/evaluate_scope`; no live runtime files for the dewey rename have been changed yet.
**Depends on:** Phase 0, so the plan executes after the ANALYZE -> PLAN boundary is no longer relying on implicit or discretionary commit behavior.
**Risk:** Medium — the current suite is wired to `socrates-idle`, so initial RED failures are expected and should isolate the contract drift.
**Produces:** A failing, behavior-level contract that names `dewey` as the intended IDLE operator across effect execution, state reporting, doctor validation, and prompt resolution.
**Why second:** Once the phase-boundary commit contract is explicit again, freeze the dewey operator mismatch across all affected surfaces before runtime edits so a prompt-only or asset-only rename cannot masquerade as a complete fix.

**Tests (pseudocode):**

```text
workspace := temp repo with .inquiry/state.yaml
when EffectExecutor transitions into IDLE
then state.yaml ape.name == "dewey"
and state.yaml ape.state == "evaluate_scope"

workspace := IDLE state
when FsmStateCommand renders JSON
then apes == [{name: "dewey", status: "RUNNING"}]

assets := temp assets root
when DoctorCommand validates bundled APE files
then required apes contains "dewey"
and required apes does not contain "socrates-idle"

workspace := IDLE with ape.name=dewey and ape.state=evaluate_scope
when ApePromptCommand loads --name dewey
then prompt assembly succeeds
and requesting --name socrates-idle fails as inactive or missing
```

**Verification (pseudocode):**

```text
run dart test test/effect_executor_test.dart test/fsm_state_test.dart test/doctor_test.dart test/ape_prompt_test.dart
expect exit != 0
expect failures mention expected "dewey" / actual "socrates-idle" or equivalent missing-dewey contract drift
expect no unrelated test files fail
```

**TDD:** Yes. This phase is intentionally RED-first: write or tighten the assertions before any runtime rename so the failure surface proves the contract drift that later phases must remove.

- [x] Edit `code/cli/test/effect_executor_test.dart` to expect `dewey` activation in IDLE and the existing `evaluate_scope` initial sub-state.
- [x] Edit `code/cli/test/fsm_state_test.dart` to expect `dewey` as the sole running ape in IDLE.
- [x] Edit `code/cli/test/doctor_test.dart` to require `dewey` in the bundled APE set and stop requiring `socrates-idle`.
- [x] Edit `code/cli/test/ape_prompt_test.dart` to copy `dewey.yaml`, add a successful IDLE prompt case for `dewey`, and replace the IDLE rejection case so `socrates-idle` is no longer considered valid there.
- [x] Run `dart test test/effect_executor_test.dart test/fsm_state_test.dart test/doctor_test.dart test/ape_prompt_test.dart` and capture the expected RED failures.
- [x] Commit: "test(cli): lock dewey idle contract for #177"

## Phase 2 — Replace the live IDLE operator asset and activation binding (P2)

**Entry:** Phase 1 complete; the only intended REDs are the ones proving that IDLE still enters with `socrates-idle` instead of `dewey`.
**Depends on:** Phase 1, because the RED contract must already exist before the live binding is changed.
**Risk:** Medium — changing the asset name without the activation map will break IDLE entry.
**Produces:** One canonical runtime source of truth for IDLE entry: the live `dewey` asset plus the effect executor binding that writes `dewey/evaluate_scope` into state.
**Why before P3:** Prompt resolution, state reporting, and doctor checks should converge on an already-real runtime binding. If those surfaces are edited before IDLE entry itself is canonical, the plan could align secondary views around the wrong underlying source.

**Tests (pseudocode):**

```text
asset := source and packaged dewey asset
when the asset is loaded
then name == "dewey"
and prompt text keeps issue triage scope only
and prompt text does not introduce ANALYZE, PLAN, or EXECUTE knowledge

workspace := temp repo transitioning from another state into IDLE
when EffectExecutor.updateState("IDLE") runs
then state.yaml ape.name == "dewey"
and state.yaml ape.state == "evaluate_scope"
```

**Verification (pseudocode):**

```text
run dart test test/effect_executor_test.dart
expect exit 0

workspace := temp repo transitioning into IDLE
read .inquiry/state.yaml
expect ape.name == "dewey"
expect ape.state == "evaluate_scope"

search code/cli/assets/apes and code/cli/build/assets/apes for canonical idle operator asset
expect dewey.yaml exists in both roots
expect no canonical source/build binding still requires socrates-idle for IDLE entry
```

**TDD:** Yes. Use the RED contract from P1 as the driver, but make this phase GREEN on the narrowest slice first: effect execution plus the live asset pair that makes that transition possible.

- [x] Create `code/cli/assets/apes/dewey.yaml` from the current idle-triage prompt, preserving Dewey problematization, issue-only scope, and ignorance of downstream states.
- [x] Remove or retire `code/cli/assets/apes/socrates-idle.yaml` from live source assets once `dewey.yaml` exists.
- [x] Edit `code/cli/lib/modules/fsm/effect_executor.dart` so entering IDLE activates `dewey` instead of `socrates-idle`.
- [x] Mirror the asset rename in `code/cli/build/assets/apes/` so packaged CLI assets expose the same canonical operator name.
- [x] Run `dart test test/effect_executor_test.dart` until the IDLE transition check passes GREEN.
- [x] Commit: "feat(cli): bind idle to dewey for #177"

## Phase 3 — Align all CLI truth surfaces with the dewey contract (P3)

**Entry:** Phase 2 complete; entering IDLE already activates `dewey` in `.inquiry/state.yaml`, and the source/build assets both expose `dewey` as the canonical live operator.
**Depends on:** Phase 2, because every downstream CLI surface reads or validates the runtime/operator choice established there.
**Risk:** High — prompt resolution, state reporting, and doctor validation can each preserve a contradictory operator identity if updated separately.
**Produces:** A fully coherent executable CLI contract in which effect execution, prompt loading, state JSON, doctor checks, and targeted tests all agree on `dewey`.
**Why before P4:** Runtime truth has to settle before documentation and process assets can be updated authoritatively. Otherwise P4 would document an intended contract that the CLI still fails to execute.

**Tests (pseudocode):**

```text
workspace := IDLE
when FsmStateCommand executes
then apes[0].name == "dewey"

workspace := IDLE with ape.name=dewey and ape.state=evaluate_scope
when ApePromptCommand(name: "dewey") executes
then prompt loads successfully
and ApePromptCommand(name: "socrates-idle") fails

assets := temp root missing dewey
when DoctorCommand executes
then doctor reports the missing dewey asset
```

**Verification (pseudocode):**

```text
run dart test test/effect_executor_test.dart test/fsm_state_test.dart test/doctor_test.dart test/ape_prompt_test.dart
expect exit 0

workspace := temp repo in IDLE
run iq fsm state --json
expect apes == [{name: "dewey", status: "RUNNING"}]

workspace := temp repo in IDLE with ape.name=dewey and ape.state=evaluate_scope
run iq ape prompt --name dewey
expect prompt assembly succeeds

run iq ape prompt --name socrates-idle
expect command fails because socrates-idle is not the active IDLE operator

run rg "socrates-idle" code/cli/lib code/cli/assets code/cli/test
expect no remaining live-contract matches outside intentional historical references
```

**TDD:** Yes. Keep the scope surface-by-surface: make the targeted suite GREEN by resolving one truth surface at a time, rerunning the same contract after each edit so prompt, state, and doctor never diverge again.

- [x] Edit `code/cli/lib/modules/ape/commands/prompt.dart` so IDLE accepts `dewey` and no longer treats `socrates-idle` as active.
- [x] Edit `code/cli/lib/modules/fsm/commands/state.dart` so IDLE reports `dewey` as `RUNNING`.
- [x] Edit `code/cli/lib/modules/global/commands/doctor.dart` so doctor validates `dewey` instead of `socrates-idle`.
- [x] Update any remaining live-contract references in `code/cli/lib/**` and the targeted test files so the active IDLE contract uses one name everywhere.
- [x] Run `dart test test/effect_executor_test.dart test/fsm_state_test.dart test/doctor_test.dart test/ape_prompt_test.dart` until the Phase 1 contract checks are GREEN.
- [x] Run `rg "socrates-idle" code/cli/lib code/cli/assets code/cli/test` and resolve remaining live-contract matches before leaving the phase.
- [x] Commit: "refactor(cli): unify idle runtime surfaces on dewey for #177"

## Phase 4 — Reconcile declared architecture, public documentation, and site roster with runtime (P4)

**Entry:** Phase 3 complete; the executable CLI contract is GREEN and the runtime no longer exposes `socrates-idle` as the active IDLE operator.
**Depends on:** Phase 3, because docs/spec and process assets must describe the implemented contract, not predict it.
**Risk:** High — leaving docs/spec, README, or the public site on `four active agents` or `APE direct / no sub-agent` wording will preserve two contradictions at once: the runtime/operator mismatch and a stale public roster that omits DEWEY from the active apes.
**Produces:** A declarative architecture, public agent roster, and handoff story that match the GREEN runtime contract: `dewey` owns bounded IDLE triage, is listed as an active APE alongside SOCRATES, DESCARTES, BASHO, and DARWIN, and `issue-start` remains the explicit handoff mechanism.
**Why before P5:** Release notes and final validation should capture the final user-facing story only after both runtime and declared architecture agree. Publishing before this reconciliation would ship a mixed contract.

**Tests (pseudocode):**

```text
search docs/spec and docs/architecture for "socrates-idle"
expect no live operator matches

search IDLE sections for "APE operates directly" or "no sub-agent"
expect no match in the declared runtime contract

search public roster surfaces for "Four active agents" or "Four apes, not nine"
expect no match once DEWEY joins the active APE roster

search public roster tables and cards
expect DEWEY appears as the IDLE ape
expect the total active roster reflects DEWEY + SOCRATES + DESCARTES + BASHO + DARWIN

search issue-start skill for "start_analyze"
expect the handoff command still exists

search issue-start skill for dewey performing branch prep, diagnosis, planning, or coding
expect no matches
```

**Verification (pseudocode):**

```text
run rg "socrates-idle|APE operates directly|no sub-agent" docs/spec docs/architecture.md code/cli/assets/skills/issue-start/SKILL.md code/cli/build/assets/skills/issue-start/SKILL.md
expect no matches that describe the live IDLE runtime contract

run rg "dewey" docs/spec/agent-lifecycle.md docs/spec/cooperative-multitasking-model.md docs/architecture.md
expect matches describe bounded issue triage only
expect no match grants dewey knowledge of ANALYZE, PLAN, or EXECUTE

run rg "Four active agents|Four apes, not nine|The four active|four active apes" README.md docs code/site
expect no match on live roster surfaces after the DEWEY change, except intentional historical narration that explicitly marks itself as history

run rg "DEWEY|dewey" README.md docs/architecture.md docs/roadmap.md docs/thinking-tools.md docs/spec/agent-lifecycle.md code/site/agents.html code/site/index.html code/site/methodology.html code/site/ape-builds-ape.html
expect matches include DEWEY as the IDLE APE and update the public roster accordingly

run rg "start_analyze" docs/architecture.md code/cli/assets/skills/issue-start/SKILL.md code/cli/build/assets/skills/issue-start/SKILL.md
expect handoff remains documented in issue-start rather than in dewey
```

**TDD:** Partial. Use search assertions as the RED guardrail before editing docs, but this is documentation/protocol reconciliation rather than classical unit TDD.

- [x] Edit `docs/spec/cooperative-multitasking-model.md` to replace the IDLE `APE direct + triage skill / no sub-agent` description with the approved dewey-operated model.
- [x] Edit `docs/spec/agent-lifecycle.md` to name `dewey` as the IDLE operator while preserving issue triage boundaries and externalized transition mechanics.
- [x] Update `README.md`, `docs/architecture.md`, `docs/roadmap.md`, and `docs/thinking-tools.md` wherever the live roster or state-to-agent mapping still omits DEWEY from the active APE set.
- [x] Inspect `docs/philosophy.md` and any other live methodology page that maps states to named agents; if the live roster or IDLE contract is stale there, update it in this phase.
- [x] Update `code/site/agents.html` so the public roster includes DEWEY as the IDLE ape, adjusts the count and copy that currently say `Four active agents` / `Four apes, not nine`, and preserves any historical note as explicitly historical rather than live roster truth.
- [x] Update any dependent site surface that mirrors the live roster or agent count, especially `code/site/index.html`, `code/site/methodology.html`, and `code/site/ape-builds-ape.html`.
- [ ] If adding DEWEY to the site requires new card styling or layout support, update `code/site/css/agents.css` in this phase so the public roster renders correctly on desktop and mobile.
- [x] Inspect `docs/lore.md`; if it distinguishes historical lore from the live roster, preserve that distinction while making the live roster sections and tables include DEWEY where appropriate.
- [ ] Inspect `docs/research/inquiry/dewey-inquiry.md` only if the public-facing documentation needs an explicit cross-reference explaining why DEWEY owns IDLE.
- [x] Inspect `docs/architecture.md` and `code/cli/assets/skills/issue-start/SKILL.md`; if either contradicts the approved dewey-operated IDLE model or collapses handoff logic back into IDLE, update it in this phase.
- [ ] If `code/cli/assets/skills/issue-start/SKILL.md` changes, mirror the same contract update into `code/cli/build/assets/skills/issue-start/SKILL.md` or rebuild packaged assets before leaving the phase.
- [x] Run `rg "socrates-idle|APE operates directly|no sub-agent" docs/spec docs/architecture.md code/cli/assets/skills/issue-start/SKILL.md code/cli/build/assets/skills/issue-start/SKILL.md` and clear stale contradictions before leaving the phase.
- [x] Run `rg "Four active agents|Four apes, not nine|The four active|four active apes" README.md docs code/site` and clear stale live-roster contradictions before leaving the phase.
- [x] Run `rg "DEWEY|dewey" README.md docs code/site` and confirm the live roster and IDLE mapping now include DEWEY on both technical and public-facing surfaces.
- [x] Run `rg "start_analyze" docs/architecture.md code/cli/assets/skills/issue-start/SKILL.md code/cli/build/assets/skills/issue-start/SKILL.md` and confirm the explicit handoff still belongs to `issue-start`, not to `dewey`.
- [x] Commit: "docs(site): add dewey to idle roster and handoff docs for #177"

## Phase 5 — Release record and full validation (P5)

**Entry:** Phase 4 complete; runtime and declared contract are aligned, and no known live contradiction remains between executable behavior and documentation.
**Depends on:** Phase 4, because release metadata should record the settled contract that survived both executable and documentation alignment.
**Risk:** Low — the remaining work is release bookkeeping and full-system verification.
**Produces:** The releasable record of #177 plus whole-CLI validation proving that the ordered hypothesis held end to end.
**Why last:** Version/changelog edits and full-suite reruns are evidence collection on the completed system, not part of discovering the contract. Running them earlier would validate a moving target and force redundant release bookkeeping.

**Tests (pseudocode):**

```text
run dart analyze
expect exit 0

run dart test
expect exit 0

workspace := temp repo in IDLE
when iq fsm state --json runs
then apes[0].name == "dewey"

workspace := temp repo in IDLE with active dewey
when iq ape prompt --name dewey runs
then prompt assembly succeeds

when iq doctor runs
then APE asset checks pass
```

**Verification (pseudocode):**

```text
run dart analyze
expect exit 0

run dart test
expect exit 0

workspace := temp repo in IDLE
run iq fsm state --json
expect apes[0].name == "dewey"

run iq ape prompt --name dewey
expect prompt assembly succeeds

run iq doctor
expect APE asset checks pass

inspect public site roster
expect DEWEY appears as the IDLE ape
expect no live page still claims there are only four active apes

inspect release metadata
expect code/cli/pubspec.yaml version updated for #177
expect code/cli/CHANGELOG.md mentions dewey as the IDLE operator change
```

**TDD:** No. This phase is whole-system confirmation and release recording after the feature contract is already GREEN; treat it as final evidence collection, not RED→GREEN design.

- [x] Run `dart analyze`.
- [x] Run `dart test`.
- [x] Manual smoke test: enter IDLE in a temp workspace and confirm `iq fsm state --json` reports `dewey` as the active operator.
- [x] Manual smoke test: in the same IDLE workspace, run `iq ape prompt --name dewey` and confirm prompt assembly succeeds.
- [x] Manual smoke test: run `iq doctor` and confirm the APE asset check passes with `dewey` present.
- [x] Manual smoke test: review the updated site roster pages and confirm DEWEY is listed as the IDLE ape and the live count/copy no longer says only four active apes.
- [x] Update `code/cli/pubspec.yaml` with the version bump that will ship issue #177.
- [x] Update `code/cli/CHANGELOG.md` with the dewey IDLE operator change.
- [x] Re-run `dart analyze` and `dart test` after the release metadata edits.
- [x] Commit: "release(cli): record dewey idle rebuild for #177"

> Deviation: the Phase 5 version bump could not stop at `code/cli/pubspec.yaml`. `code/cli/test/version_sync_test.dart` also required the same release number in `code/cli/lib/src/version.dart` and the `code/site/index.html` badge, so those release metadata surfaces were updated in-phase to keep validation GREEN.