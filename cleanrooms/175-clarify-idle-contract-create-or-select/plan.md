# Plan — Issue #175: Clarify IDLE create-or-select contract

**Input:** [analyze/diagnosis.md](analyze/diagnosis.md)
**Extended scope:** Close #176 only where it is required to place explicit create-or-select routing at the canonical IDLE boundary.
**Plan invariant:** After approval, only checkbox state and deviation annotations may change.
**Execution root:** Run all `dart`, `iq`, and `rg` commands from `code/cli` unless a step explicitly names the repository root.
**Deviation rule:** If execution shows that the clarified IDLE contract cannot be expressed through the planned runtime surfaces without changing phase boundaries, stop, add a deviation note under the active phase, and return to ANALYZE before opening a new implementation slice.
**Verification rule:** A phase is not complete until its phase-local verification gate passes without contradiction.
**Ordering thesis:** P1 removes stale canonical guidance, P2 encodes the core IDLE contract across runtime assets, firmware, and handoff sequencing, P3 separates TRIAGE issue creation from DONE operational start, P4 moves the explicit fast path into IDLE orchestration, P5 aligns explanatory docs behind the validated runtime, and P6 records the release surfaces and final verification.

## Phase 1 — Establish the normative IDLE source map (P1)

**Entry:** [analyze/diagnosis.md](analyze/diagnosis.md) is approved; developers can still infer current truth from explanatory docs and from [docs/spec/state-encapsulation.md](../../docs/spec/state-encapsulation.md) even though the intended canonical pair is `transition_contract.yaml` + `idle.yaml`.
**Depends on:** None.
**Risk:** Medium — if stale explanatory text still appears canonical, later runtime changes can be read as regressions instead of as the intended contract.
**Produces:** A clear source-of-truth map: runtime canon lives in `transition_contract.yaml` + `idle.yaml`, explanatory docs describe the model without replacing it, and the stale state-encapsulation note is explicitly marked historical.
**Why first:** This is the simplest independent slice and it removes ambiguity before any runtime or skill changes land.

**Test definitions (pseudocode):**

```text
doc := docs/spec/agent-lifecycle.md
when the IDLE section is read
then it says the runtime contract is encoded in transition_contract.yaml + idle.yaml
and it does not present itself as the sole normative source

doc := docs/spec/cooperative-multitasking-model.md
when the DEWEY/IDLE boundary section is read
then it describes issue readiness as staying in IDLE by default
and it distinguishes explanatory architecture from runtime canon

doc := docs/spec/state-encapsulation.md
when the file is opened
then a superseded/historical note is visible
and the obsolete operator, _DONE, and handoff semantics are called out as stale
```

**Verification gate (pseudocode):**

```text
run rg "canonical|normative|superseded|historical|transition_contract|idle.yaml" ..\docs\spec
expect the docs to point readers to the runtime pair and to mark stale IDLE guidance as non-canonical
```

**TDD:** No. This phase is documentation groundwork; execute the verification gate after the edits as the completion check.

- [x] Update `docs/spec/state-encapsulation.md` to mark it as superseded for canonical IDLE behavior while preserving any still-valid architectural intuition.
- [x] Update `docs/spec/agent-lifecycle.md` so it states that `transition_contract.yaml` defines the outer IDLE boundary and `idle.yaml` defines the internal IDLE behavior.
- [x] Update `docs/spec/cooperative-multitasking-model.md` so it describes the clarified DEWEY/IDLE boundary as explanatory architecture rather than the canonical runtime contract.
- [x] Run `rg "canonical|normative|superseded|historical|transition_contract|idle.yaml" ..\docs\spec` and resolve contradictory wording before leaving the phase.
- [x] Commit: "docs(spec): clarify idle source map for #175"

## Phase 2 — Canonicalize the core IDLE runtime contract (P2)

**Entry:** Phase 1 is complete; the documentation now points to the correct runtime sources, but the runtime assets still send DEWEY to `_DONE` too early and still leave the internal IDLE loop under-specified.
**Depends on:** Phase 1.
**Risk:** High — the same behavior appears in `dewey.yaml`, `idle.yaml`, `transition_contract.yaml`, `inquiry.agent.md`, packaged assets, and targeted/integration tests, so a partial change will preserve contradictory truths.
**Produces:** A green core contract where issue readiness resets DEWEY inside IDLE, explicit start intent alone reaches `_DONE`, `idle.yaml` defines TRIAGE vs DONE and owns the internal DONE semantics, `inquiry.agent.md` encodes the explicit-start handoff semantics, and `start_analyze` remains the only outer exit from IDLE with `transition_contract.yaml` advertising only the external prechecks and expected handoff surface.
**Why before P3:** The issue-create split and the fast path both depend on the inner/outer IDLE boundary already being explicit.

**Test definitions (pseudocode):**

```text
ape := DEWEY in confirm after issue readiness
when the completion event is applied
then DEWEY returns to its initial triage state
and _DONE is not reached on issue readiness alone

state := IDLE
when fsm state instructions are rendered
then TRIAGE is the default internal mode
and issue readiness resets DEWEY while the main FSM remains IDLE
and explicit start intent is the only path that consumes issue-start

transition := IDLE + start_analyze
when the FSM contract and transition output are inspected
then start_analyze is still the only allowed outer exit from IDLE
and the outer edge advertises only the required prechecks and expected handoff surface
and it does not define TRIAGE/DONE semantics or the trigger that consumes issue-start

firmware := inquiry.agent.md
when the IDLE completion and handoff rules are read
then issue readiness does not trigger issue-start
and explicit start intent alone triggers issue-start followed by start_analyze
and the production of issue_selected_or_created vs feature_branch_selected is described in the correct sequence

integration := IDLE handoff path
when the outer transition is exercised end to end
then the main FSM leaves IDLE only after the explicit-start handoff is prepared
and start_analyze remains guarded by the two required prechecks
```

**Verification gate (pseudocode):**

```text
run dart test test/ape_transition_test.dart test/fsm_state_test.dart test/fsm_contract_test.dart test/fsm_transition_test.dart test/fsm_transition_integration_test.dart test/firmware_agent_test.dart
expect exit 0
expect the issue-readiness loop, idle instructions, idle_to_analyze metadata, firmware wording, and handoff sequencing to match the clarified contract
```

**TDD:** Yes. RED first: tighten the targeted contract tests inside this phase. GREEN second: update the source assets, packaged assets, and contract metadata until the same verification gate passes.

- [x] Update `code/cli/test/ape_transition_test.dart` to assert that issue readiness returns DEWEY to its initial triage state instead of `_DONE`.
- [x] Update `code/cli/test/fsm_state_test.dart`, `code/cli/test/fsm_contract_test.dart`, `code/cli/test/fsm_transition_test.dart`, `code/cli/test/fsm_transition_integration_test.dart`, and `code/cli/test/firmware_agent_test.dart` so IDLE instructions, `idle_to_analyze` metadata, explicit-start gating, and the split production of `issue_selected_or_created` vs `feature_branch_selected` are all protected.
- [x] Edit `code/cli/assets/apes/dewey.yaml` so issue readiness resets DEWEY to its initial state and only explicit start intent reaches `_DONE`.
- [x] Edit `code/cli/assets/fsm/states/idle.yaml` so the canonical IDLE instructions explicitly define TRIAGE vs DONE, reset-after-issue-ready, and DONE consuming `issue-start`.
- [x] Edit `code/cli/assets/fsm/transition_contract.yaml` so `start_analyze` remains the only outer IDLE exit and the `idle_to_analyze` fragment advertises only the external handoff metadata: required prechecks and expected handoff surface, while `idle.yaml` remains the canonical owner of TRIAGE/DONE semantics and `issue-start` trigger timing.
- [x] Edit `code/cli/assets/agents/inquiry.agent.md` so the firmware states that issue readiness stays in IDLE/TRIAGE, only explicit start intent reaches DONE, and `issue-start` then prepares the operational handoff into `start_analyze`.
- [x] Mirror the updated source assets into `code/cli/build/assets/apes/dewey.yaml`, `code/cli/build/assets/fsm/states/idle.yaml`, and `code/cli/build/assets/fsm/transition_contract.yaml`.
- [x] Run `dart test test/ape_transition_test.dart test/fsm_state_test.dart test/fsm_contract_test.dart test/fsm_transition_test.dart test/fsm_transition_integration_test.dart test/firmware_agent_test.dart` until the Phase 2 contract is GREEN.
- [x] Commit: "feat(cli): canonicalize idle runtime contract for #175"

## Phase 3 — Separate TRIAGE issue creation from DONE operational start (P3)

**Entry:** Phase 2 is GREEN; the runtime now distinguishes issue readiness from explicit work start, but issue creation/confirmation is still mixed into `issue-start` instead of being owned deterministically from TRIAGE.
**Depends on:** Phase 2.
**Risk:** High — introducing `issue-create` changes bundled assets, deployed-target expectations, doctor checks, and wording that still assumes `issue-start` creates the issue.
**Produces:** A deterministic `issue-create` skill for TRIAGE, a narrowed `issue-start` skill for operational setup only, and IDLE wording that points issue creation/confirmation to the correct surface.
**Why before P4:** The explicit fast path from #176 must land on a dedicated TRIAGE skill, not on an overloaded `issue-start` protocol.

**Test definitions (pseudocode):**

```text
assets := bundled skills
when the packaged skill list is inspected
then issue-create exists beside issue-start

doctor := deployed target validation
when issue-create is missing
then doctor reports it as a missing skill asset

skill := issue-start
when the protocol is read
then it assumes the issue already exists
and it verifies the issue, prepares the branch/cleanroom, and fires start_analyze
and it does not own default gh issue creation behavior

idle instructions := idle.yaml
when TRIAGE determines that an issue must be created or confirmed
then it points to issue-create rather than to issue-start
```

**Verification gate (pseudocode):**

```text
run dart test test/assets_test.dart test/doctor_test.dart test/fsm_state_test.dart
expect exit 0
expect bundled assets, deployed-target expectations, and idle instructions all recognize issue-create
```

**TDD:** Yes. RED first: add the new asset and deployment expectations. GREEN second: introduce `issue-create`, narrow `issue-start`, and rerun the same verification gate until it passes.

- [x] Update `code/cli/test/assets_test.dart` and `code/cli/test/doctor_test.dart` so bundled and deployed skill expectations include `issue-create`.
- [x] Add `code/cli/assets/skills/issue-create/SKILL.md` and mirror it to `code/cli/build/assets/skills/issue-create/SKILL.md`, defining deterministic GitHub issue creation or confirmation during TRIAGE.
- [x] Edit `code/cli/assets/skills/issue-start/SKILL.md` and `code/cli/build/assets/skills/issue-start/SKILL.md` so `issue-start` assumes the issue already exists and only verifies it, creates the branch/cleanroom, and fires `start_analyze`.
- [x] Update `code/cli/assets/fsm/states/idle.yaml` and nearby wording so TRIAGE names `issue-create` as the deterministic GitHub-side skill when issue creation or confirmation is required.
- [x] Run `dart test test/assets_test.dart test/doctor_test.dart test/fsm_state_test.dart` until the skill split is GREEN.
- [x] Commit: "feat(cli): split issue creation from issue-start for #175"

## Phase 4 — Move explicit create-or-select routing into IDLE orchestration (P4)

**Entry:** Phase 3 is GREEN; TRIAGE has a dedicated `issue-create` skill and `issue-start` is purely the explicit handoff into ANALYZE.
**Depends on:** Phase 3.
**Risk:** High — the current routing leak is split across `dewey.yaml`, missing IDLE trigger language, and missing CLI prompt context, so a one-sided fix can leave DEWEY owning process routing even if the user-visible behavior appears unchanged.
**Produces:** IDLE-owned fast-path trigger semantics for explicit create-or-select requests, Inquiry CLI prompt enrichment that carries the routing context, and a methodology-only DEWEY asset that no longer serves as the canonical owner of process routing.
**Why now:** Once TRIAGE has a deterministic issue skill and the IDLE boundary is stable, the fast path can move to the correct orchestration layer without reopening earlier phase assumptions.

**Test definitions (pseudocode):**

```text
prompt := iq ape prompt --name dewey from IDLE
when the prompt is assembled for an explicit create-or-select request
then the inquiry-context block names the TRIAGE objective
and it advertises issue-create as the deterministic skill
and it exposes the allowed command surface for create/select work

asset := dewey.yaml
when DEWEY behavior is inspected
then the prompt remains methodology-focused
and explicit create-or-select routing is no longer presented as DEWEY's canonical ownership boundary

firmware := inquiry.agent.md
when the IDLE handoff rules are read
then explicit create/select intent only changes routing inside TRIAGE
and only explicit start intent triggers issue-start plus start_analyze
```

**Verification gate (pseudocode):**

```text
run dart test test/ape_prompt_test.dart test/ape_transition_test.dart test/firmware_agent_test.dart
expect exit 0
expect dewey prompt assembly to include IDLE-owned routing context
expect no regression to the issue-readiness loop, firmware contract, or explicit-start gate

run rg "skip|issue-create|issue-start|start_analyze|create_or_select" assets/apes/dewey.yaml assets/fsm/states/idle.yaml assets/agents/inquiry.agent.md lib/modules/ape/commands/prompt.dart
expect matches to reflect IDLE-owned routing rather than DEWEY-owned process logic
```

**TDD:** Yes. RED first: add the canonical IDLE-level prompt and routing expectations. GREEN second: move orchestration/context into the CLI and runtime assets until the same verification gate passes.

- [x] Update `code/cli/test/ape_prompt_test.dart` and `code/cli/test/firmware_agent_test.dart` so explicit create-or-select requests are protected at the IDLE layer and the firmware wording keeps that ownership boundary explicit.
- [x] Edit `code/cli/lib/modules/ape/commands/prompt.dart` so Inquiry CLI injects IDLE-specific routing context for DEWEY instead of leaving process routing implicit in the DEWEY asset.
- [x] Edit `code/cli/assets/fsm/states/idle.yaml` and `code/cli/build/assets/fsm/states/idle.yaml` so IDLE owns the explicit create-or-select fast-path trigger semantics.
- [x] Edit `code/cli/assets/apes/dewey.yaml` and `code/cli/build/assets/apes/dewey.yaml` so DEWEY consumes the new inquiry-context contract without presenting process routing as its canonical responsibility.
- [x] Edit `code/cli/assets/agents/inquiry.agent.md` so the firmware states that explicit create/select intent only changes TRIAGE routing inside IDLE, while explicit start intent alone triggers `issue-start` and `start_analyze`.
- [x] Run `dart test test/ape_prompt_test.dart test/ape_transition_test.dart test/firmware_agent_test.dart` and the `rg` verification above until the fast-path ownership leak is closed.
- [x] Commit: "refactor(cli): move idle fast-path ownership for #175"

## Phase 5 — Align explanatory docs behind the validated runtime contract (P5)

**Entry:** Phases 2-4 are GREEN; runtime assets, skills, firmware, and prompt assembly now express the clarified IDLE behavior.
**Depends on:** Phases 2, 3, and 4.
**Risk:** Medium — several docs are still useful historically, so the goal is to align them without erasing reference material that remains valuable.
**Produces:** Explanatory documentation that agrees with the validated runtime contract and clearly explains the issue-create split, the split production of `start_analyze` preconditions, and the IDLE-owned fast path without reintroducing stale semantics.
**Why after runtime:** Documentation should explain the contract that already passes tests, not predict a contract that still exists only in prose.

**Test definitions (pseudocode):**

```text
docs := agent-lifecycle + cooperative-multitasking-model
when the IDLE sections are read
then issue readiness resets DEWEY inside IDLE
and explicit start intent alone consumes issue-start/start_analyze
and TRIAGE owns issue creation through issue-create
and issue_selected_or_created is attributed to TRIAGE while feature_branch_selected is attributed to issue-start
and the explicit fast path is described as IDLE/Inquiry CLI behavior rather than DEWEY routing

historical note := state-encapsulation.md
when the document is read after runtime alignment
then its superseded note still matches the final runtime terminology
```

**Verification gate (pseudocode):**

```text
run rg "gh issue create|issue-start.*create|explicit handoff|issue readiness|_DONE|create_or_select|issue-create|issue_selected_or_created|feature_branch_selected" ..\docs\spec ..\code\cli\assets
expect only the updated wording to remain for the clarified IDLE model
```

**TDD:** No. This phase aligns explanatory material after the executable contract is already green; complete it by passing the documentation verification gate.

- [x] Update `docs/spec/agent-lifecycle.md` so IDLE explicitly stays in TRIAGE after issue readiness, reserves DONE for explicit start intent, points issue creation to `issue-create`, and assigns `issue_selected_or_created` vs `feature_branch_selected` to the correct moments in the handoff sequence.
- [x] Update `docs/spec/cooperative-multitasking-model.md` so DEWEY remains methodology-only and the explicit create-or-select fast path is described as IDLE/Inquiry CLI behavior rather than DEWEY routing.
- [x] Reconcile the superseded note in `docs/spec/state-encapsulation.md` with the final runtime terminology from Phases 2-4.
- [x] Run `rg "gh issue create|issue-start.*create|explicit handoff|issue readiness|_DONE|create_or_select|issue-create|issue_selected_or_created|feature_branch_selected" ..\docs\spec ..\code\cli\assets` and resolve stale wording before leaving the phase.
- [x] Commit: "docs: align idle specs with clarified contract for #175"

Deviation: Also aligned `docs/spec/cli-as-api.md` and `docs/spec/inquiry-cli-spec.md` because both still described the pre-split IDLE issue-creation and explicit-start handoff semantics, which would have left contradictory explanatory guidance after P5.

## Phase 6 — Version, changelog, and final validation (P6)

**Entry:** Phases 1-5 are complete; runtime assets, skills, firmware, and explanatory docs all agree on the clarified IDLE contract.
**Depends on:** Phases 1, 2, 3, 4, and 5.
**Risk:** Medium — version metadata is enforced across three files and the release note must describe both the #175 contract clarification and the #176 routing fix that was necessary to support it.
**Produces:** Release-ready metadata, changelog entry, and a final validation record for the clarified IDLE contract.
**Why last:** Versioning and changelog work should describe the final, already-validated behavior rather than an intermediate state.

**Test definitions (pseudocode):**

```text
version sources := pubspec.yaml + version.dart + site badge
when release metadata is updated
then all three version surfaces match

changelog := code/cli/CHANGELOG.md
when the release entry is written
then it records the clarified IDLE boundary, the issue-create split, and the relocation of fast-path ownership into IDLE

project := code/cli
when analyze and the targeted regression suites run
then analysis passes
and all phase-specific tests plus version_sync_test pass
```

**Verification gate (pseudocode):**

```text
run dart analyze
expect exit 0

run dart test test/ape_transition_test.dart test/fsm_state_test.dart test/fsm_contract_test.dart test/fsm_transition_test.dart test/fsm_transition_integration_test.dart test/firmware_agent_test.dart test/assets_test.dart test/doctor_test.dart test/ape_prompt_test.dart test/version_sync_test.dart
expect exit 0
expect no regressions across the idle boundary, firmware contract, skill split, prompt assembly, or release metadata
```

**TDD:** No. This phase is release bookkeeping plus whole-slice validation; completion depends on the final analyze/test verification gate.

- [x] Update `code/cli/CHANGELOG.md` with an entry for the clarified IDLE contract, the new `issue-create` skill, and the relocation of fast-path ownership into IDLE.
- [x] Bump the CLI version in `code/cli/pubspec.yaml`, `code/cli/lib/src/version.dart`, and the version badge in `code/site/index.html`.
- [x] Run `dart analyze`.
- [x] Run `dart test test/ape_transition_test.dart test/fsm_state_test.dart test/fsm_contract_test.dart test/fsm_transition_test.dart test/fsm_transition_integration_test.dart test/firmware_agent_test.dart test/assets_test.dart test/doctor_test.dart test/ape_prompt_test.dart test/version_sync_test.dart`.
- [x] Commit: "chore(release): record clarified idle contract for #175"
