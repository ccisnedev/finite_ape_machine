# Plan — Issue #154: Separate thinking-tool identity from operational contract

**Input:** [analyze/diagnosis.md](analyze/diagnosis.md)
**Draft scope:** DESCARTES `enumeration`. Decomposition, ordering, and verification are already locked as P1 -> P2 -> P3 -> P4 -> P5 -> P6; this pass refines completeness only and confirms that every phase has entry criteria, executable steps, verification, risk coverage where needed, and a commit line without changing phase boundaries or sequence.
**Plan invariant:** After approval, only checkbox state and deviation annotations may change.
**Execution root:** Run all `dart`, `iq`, and `rg` commands from `code/cli` unless a step explicitly names the repository root.
**Deviation rule:** If execution shows that operational contract cannot move out of APE YAMLs without either hidden prompt glue or a material prompt regression, stop, add a deviation note under the active phase, and return to ANALYZE before opening a new implementation slice.
**Verification rule:** A phase is not complete until its phase-local verification gate passes and `iq ape prompt` still exposes the exact assembled prompt for the touched surfaces.
**Verification focus:** Every phase-local gate must explicitly protect preserved effective behavior, visible prompt assembly, and the rule that DARWIN may keep only abstract-process methodology rather than repository procedure.
**Dependency graph:** P1 → P2 → P3 → P4 → P5 → P6.
**Ordering rationale:** P3 is the common-case migration and should prove the identity-first prompt boundary on the simplest APEs before any special-case routing or exception work begins. P4 comes next because IDLE/DEWEY adds state-specific routing but still follows the general separation model once the standard APE path is stable. P5 is last among the migration phases because DARWIN is the only legitimate abstract-process exception and should be constrained only after the non-exception and IDLE-specific carriers are already validated.

## Phase 1 — Lock the live assembled-prompt contract before migration (P1)

**Entry:** [analyze/diagnosis.md](analyze/diagnosis.md) is approved; the current runtime still depends on operational prose embedded in APE YAMLs; no executable guard yet defines what behavior must remain visible during migration.
**Depends on:** None.
**Risk:** High — if the current assembled prompts are not captured first, later APE cleanup can silently remove artifact obligations, command surfaces, or inspectability.
**Produces:** A prompt-contract regression harness that protects the current visible behavior of `iq ape prompt` for SOCRATES, DESCARTES, BASHO, DEWEY, and DARWIN.
**Why first:** This is the smallest additive slice and it creates the falsifiable baseline needed before moving ownership boundaries.

**Test definitions (pseudocode):**

```text
for each ape in [socrates, descartes, basho, dewey, darwin]
when a representative assembled prompt is rendered in its active FSM state
then the exact prompt remains inspectable through iq ape prompt
and the output still contains the behavior-critical operational guidance currently relied upon
and any inquiry-context block remains explicit in the rendered text
and the locked assertions name the visible prompt fragments later phases must preserve even if ownership moves

firmware := inquiry.agent.md
when the operator prompt-delivery contract is read
then iq ape prompt is still documented as the way to inspect the exact effective prompt
```

**Verification gate (pseudocode):**

```text
run dart test test/ape_prompt_test.dart test/firmware_agent_test.dart
expect exit 0
expect representative prompt assembly, visible inquiry-context, and inspectability assertions to be GREEN before any YAML contraction begins
```

**TDD:** Yes. RED first: tighten prompt-contract assertions before changing prompt ownership. GREEN second: keep this gate green through all later phases.

- [x] Expand `code/cli/test/ape_prompt_test.dart` with representative assembled-prompt assertions for SOCRATES, DESCARTES, BASHO, DEWEY, and DARWIN before any operational prose is removed.
- [x] Add or adjust prompt-test fixtures so each active APE can be assembled deterministically without depending on the live repository state.
- [x] Update `code/cli/test/firmware_agent_test.dart` so prompt inspectability through `iq ape prompt` is protected as a first-class contract.
- [x] Run `dart test test/ape_prompt_test.dart test/firmware_agent_test.dart` until the prompt baseline is GREEN.
- [x] Commit: "test(cli): lock assembled prompt contract for #154"

## Phase 2 — Introduce a CLI-owned operational-contract layer (P2)

**Entry:** Phase 1 is GREEN; the current prompt shape is now protected, but operational rules are still materially authored inside APE YAMLs.
**Depends on:** Phase 1.
**Risk:** High — centralizing ownership in CLI code can replace scattered prose with opaque glue unless the contract stays visible, phase-owned, and testable.
**Produces:** A single visible operational-contract layer assembled by Inquiry CLI from phase-owned runtime surfaces plus inquiry-context, while the existing APE YAML prose remains temporarily intact for additive migration.
**Why after P1:** The new carrier must be introduced while the old behavior is still guarded, otherwise the migration cannot distinguish cleanup from regression.

**Test definitions (pseudocode):**

```text
prompt := assembled prompt for an active ape
when the new composition layer is enabled
then the output contains one explicit operational-contract fragment owned outside the ape yaml
and phase mission/constraints/allowed actions come from phase-owned runtime surfaces
and issue-specific paths or protocol fields still come from CLI-resolved inquiry-context
and iq ape prompt still prints the exact effective prompt without hidden composition
and no duplicate primary ownership of the same operational contract remains across FSM state assets and ape yaml prose

state assets := analyze/plan/execute/end/idle/evolution yaml
when the phase-owned contract is inspected
then the runtime exposes the contract needed for prompt assembly without shifting identity back into the ape yaml
```

**Verification gate (pseudocode):**

```text
run dart test test/ape_prompt_test.dart test/fsm_state_test.dart test/fsm_contract_test.dart test/firmware_agent_test.dart
expect exit 0
expect the new operational-contract fragment to be visible in assembled prompts, sourced from runtime-owned surfaces, and still inspectable through iq ape prompt
```

**TDD:** Yes. RED first: add the new prompt-composition expectations. GREEN second: introduce the carrier and keep the same gate green.

- [x] Add a dedicated operational-contract assembly helper/model under `code/cli/lib/modules/ape/` and wire it into `code/cli/lib/modules/ape/commands/prompt.dart` so the assembled prompt order is explicitly APE identity -> phase-owned operational contract -> inquiry-context.
- [x] Treat existing FSM state `instructions`, `constraints`, and `allowed_actions` as the primary carrier for phase-owned mission and contract, and introduce new explicit state fields only where prompt delivery still needs data that those surfaces cannot express cleanly.
- [x] Extend the phase-owned runtime sources under `code/cli/assets/fsm/states/analyze.yaml`, `code/cli/assets/fsm/states/plan.yaml`, `code/cli/assets/fsm/states/execute.yaml`, `code/cli/assets/fsm/states/end.yaml`, `code/cli/assets/fsm/states/idle.yaml`, and `code/cli/assets/fsm/states/evolution.yaml` with only the additive contract fields still required after that normalization, then mirror those edits into `code/cli/build/assets/fsm/states/`.
- [x] Update `code/cli/test/ape_prompt_test.dart`, `code/cli/test/fsm_state_test.dart`, `code/cli/test/fsm_contract_test.dart`, and `code/cli/test/firmware_agent_test.dart` so the CLI-owned operational-contract fragment and inspectable composition boundary are protected.
- [x] Update `code/cli/assets/agents/inquiry.agent.md` so the firmware explicitly describes the assembled prompt as APE identity + phase-owned operational contract + inquiry-context.
- [x] Run `dart test test/ape_prompt_test.dart test/fsm_state_test.dart test/fsm_contract_test.dart test/firmware_agent_test.dart` until the additive carrier is GREEN.
- [x] Commit: "feat(cli): add operational contract layer for #154"

## Phase 3 — Migrate the standard thinking tools to identity-first prompts (P3)

**Entry:** Phase 2 is GREEN; the CLI can now deliver operational contract explicitly, but SOCRATES, DESCARTES, and BASHO still duplicate repository procedure inside their YAML prose.
**Depends on:** Phase 2.
**Risk:** High — these three APEs currently carry artifact destinations, documentation protocol, planning/execution procedure, and commit-oriented workflow details that execution still relies on.
**Produces:** SOCRATES, DESCARTES, and BASHO YAMLs reduced to thinking-tool identity and sub-state modulation, with their operational contract delivered by the new CLI/FSM-owned layer.
**Why first after P2:** The three standard working APEs share the same architectural defect and can prove the common migration pattern before IDLE- or EVOLUTION-specific exceptions are introduced.

**Test definitions (pseudocode):**

```text
for each ape in [socrates, descartes, basho]
when the assembled prompt is rendered in its active state
then reasoning identity, tone, and sub-state modulation remain in the ape yaml
and output_dir / analysis_input / plan_file / doc protocol / phase procedure come from the CLI-owned operational contract
and the rendered prompt remains materially equivalent for the operator
and iq ape prompt still exposes the same effective prompt shape without hidden recovery glue

ape yaml := socrates.yaml / descartes.yaml / basho.yaml
when the source is inspected
then repository-specific procedure is no longer the primary owner inside these yaml files
```

**Verification gate (pseudocode):**

```text
run dart test test/ape_prompt_test.dart test/ape_definition_test.dart test/assets_test.dart test/firmware_agent_test.dart
expect exit 0
expect standard-APE prompts to remain materially equivalent and inspectable while the new ownership boundary stays explicit

run rg "output_dir|analysis_input|plan_file|doc-read|doc-write|Commit:" assets/apes/socrates.yaml assets/apes/descartes.yaml assets/apes/basho.yaml
expect matches to be absent or reduced to identity-preserving references rather than the primary operational contract
```

**TDD:** Yes. RED first: tighten the standard-APE prompt expectations against the new contract carrier. GREEN second: contract the YAMLs until the gate passes.

- [x] Edit `code/cli/assets/apes/socrates.yaml`, `code/cli/assets/apes/descartes.yaml`, and `code/cli/assets/apes/basho.yaml` so they retain thinking-tool identity and sub-state modulation but stop owning the primary operational contract.
- [x] Mirror the updated standard APE YAMLs into `code/cli/build/assets/apes/socrates.yaml`, `code/cli/build/assets/apes/descartes.yaml`, and `code/cli/build/assets/apes/basho.yaml`.
- [x] Update prompt-composition tests and any nearby asset expectations in `code/cli/test/ape_prompt_test.dart`, `code/cli/test/ape_definition_test.dart`, and `code/cli/test/assets_test.dart` so the new ownership boundary is enforced.
- [x] Run `dart test test/ape_prompt_test.dart test/ape_definition_test.dart test/assets_test.dart test/firmware_agent_test.dart` and the `rg` verification above until the standard-APE boundary is GREEN.
- [x] Commit: "refactor(cli): externalize standard ape procedure for #154"

## Phase 4 — Externalize IDLE routing and DEWEY procedure from the APE YAML (P4)

**Entry:** Phase 3 is GREEN; the standard APE migration pattern is validated, but DEWEY still retains repository procedure and routing detail that belongs to IDLE orchestration.
**Depends on:** Phase 3.
**Risk:** High — DEWEY touches `create_or_select`, deterministic issue handling, and GitHub command surfaces, so a partial change can regress IDLE behavior even if the prompt still renders.
**Produces:** IDLE-owned routing and issue-work contract delivered through runtime composition, with DEWEY reduced to methodology and sub-state modulation.
**Why after P3:** IDLE routing is a distinct operational surface with fast-path and GitHub-command semantics, so it should build on the already-proven standard migration path instead of introducing two new prompt-boundary changes at once.

**Test definitions (pseudocode):**

```text
dewey := assembled prompt in create_or_select
when iq ape prompt --name dewey is rendered from IDLE
then triage objective, deterministic skill, and allowed command surface come from the CLI/FSM-owned contract
and dewey yaml remains methodology-focused
and the operator can still inspect the full routing contract in the assembled prompt without hidden IDLE-only glue

idle := idle state instructions and transition metadata
when the IDLE contract is inspected
then create/select routing and issue procedure are owned outside dewey.yaml
and the assembled prompt remains fully inspectable
```

**Verification gate (pseudocode):**

```text
run dart test test/ape_prompt_test.dart test/ape_transition_test.dart test/fsm_state_test.dart test/fsm_contract_test.dart test/firmware_agent_test.dart
expect exit 0
expect IDLE-owned routing to preserve create/select behavior while the prompt remains explicitly inspectable

run rg "gh issue|issue-create|create_or_select|allowed_commands" assets/apes/dewey.yaml assets/fsm/states/idle.yaml lib/modules/ape/commands/prompt.dart
expect IDLE/runtime surfaces to own the concrete procedure rather than dewey.yaml
```

**TDD:** Yes. RED first: codify IDLE-owned routing and prompt expectations. GREEN second: move the procedure until the same gate passes.

- [x] Edit `code/cli/assets/fsm/states/idle.yaml` and `code/cli/build/assets/fsm/states/idle.yaml` so IDLE explicitly owns the operational contract for create/select routing and issue work.
- [x] Edit `code/cli/assets/apes/dewey.yaml` and `code/cli/build/assets/apes/dewey.yaml` so DEWEY preserves methodology while dropping primary ownership of concrete repository procedure.
- [x] Update `code/cli/lib/modules/ape/commands/prompt.dart` and nearby prompt-contract helpers so DEWEY receives the new IDLE-owned contract at assembly time.
- [x] Update `code/cli/test/ape_prompt_test.dart`, `code/cli/test/ape_transition_test.dart`, `code/cli/test/fsm_state_test.dart`, and `code/cli/test/fsm_contract_test.dart` so the IDLE/DEWEY ownership boundary is protected.
- [x] Run `dart test test/ape_prompt_test.dart test/ape_transition_test.dart test/fsm_state_test.dart test/fsm_contract_test.dart test/firmware_agent_test.dart` and the `rg` verification above until the DEWEY boundary is GREEN.
- [x] Commit: "refactor(cli): externalize idle routing from dewey for #154"

## Phase 5 — Bound DARWIN's abstract-process exception and externalize repository procedure (P5)

**Entry:** Phase 4 is GREEN; the standard and IDLE-specific migrations are validated, but DARWIN still mixes evaluation method, GitHub issue procedure, and metrics-generation mechanics in the APE YAML.
**Depends on:** Phase 4.
**Risk:** High — if the abstract evolution standard is not made explicit outside the DARWIN YAML, repository procedure will creep back; if repository procedure is removed too early, EVOLUTION loses required behavior.
**Produces:** An explicit evolution-owned abstract process contract outside the DARWIN YAML, plus CLI-delivered repository procedure for issue search/comment/create and metrics collection; DARWIN keeps only the methodological exception.
**Why after P4:** DARWIN is the only justified exception, so it should be constrained only after the non-exception and IDLE-specific migration paths have already stabilized the carrier and prompt-helper shape.

**Test definitions (pseudocode):**

```text
darwin := assembled prompt in EVOLUTION
when the prompt is rendered after separation
then the ideal-cycle comparison standard is still present
and repository-specific gh issue / metrics.yaml / .inquiry mechanics come from the CLI/FSM-owned operational contract
and darwin.yaml no longer primarily owns concrete repository procedure
and the only retained DARWIN-specific exception is abstract-process methodology visible in the assembled prompt

evolution := evolution-owned runtime contract
when the source is inspected
then the abstract process expectations are explicit outside darwin.yaml
and iq ape prompt still shows the full assembled prompt including that contract
```

**Verification gate (pseudocode):**

```text
run dart test test/ape_prompt_test.dart test/ape_definition_test.dart test/fsm_state_test.dart test/assets_test.dart test/firmware_agent_test.dart
expect exit 0
expect DARWIN to retain only the bounded abstract-process exception while repository procedure stays externalized and inspectable

run rg "gh issue|metrics.yaml|\.inquiry|issue comment|issue create" assets/apes/darwin.yaml assets/fsm/states/evolution.yaml lib/modules/ape/commands/prompt.dart
expect repository procedure to move out of darwin.yaml while the abstract process standard remains available through runtime-owned surfaces
```

**TDD:** Yes. RED first: protect the allowed DARWIN exception and forbid the procedural one. GREEN second: move the procedure until the gate passes.

- [x] Extend `code/cli/assets/fsm/states/evolution.yaml` and `code/cli/build/assets/fsm/states/evolution.yaml` with the abstract-process contract that DARWIN may legitimately consume outside its own YAML.
- [x] Edit `code/cli/assets/apes/darwin.yaml` and `code/cli/build/assets/apes/darwin.yaml` so DARWIN keeps evaluation identity but stops owning the primary repository procedure.
- [x] Update `code/cli/lib/modules/ape/commands/prompt.dart` and nearby prompt-contract helpers so EVOLUTION injects repository procedure and metrics mechanics explicitly at assembly time.
- [x] Update `code/cli/test/ape_prompt_test.dart`, `code/cli/test/ape_definition_test.dart`, `code/cli/test/fsm_state_test.dart`, and `code/cli/test/assets_test.dart` so the DARWIN exception is bounded by executable tests.
- [x] Run `dart test test/ape_prompt_test.dart test/ape_definition_test.dart test/fsm_state_test.dart test/assets_test.dart test/firmware_agent_test.dart` and the `rg` verification above until the DARWIN boundary is GREEN.
- [x] Commit: "refactor(cli): bound darwin exception for #154"

## Phase 6 — Align doctrine, release surfaces, and final validation (P6)

**Entry:** Phase 5 is GREEN; the runtime now expresses the intended ownership boundary end to end, but explanatory docs and release metadata may still describe the old mixed model.
**Depends on:** Phase 5.
**Risk:** Medium — stale docs or unsynchronized release metadata would leave the repository teaching the wrong architecture or shipping inconsistent version surfaces.
**Produces:** Documentation, firmware wording, version metadata, and changelog aligned to the validated ownership boundary.
**Why last:** Explanatory and release surfaces should describe the runtime that already passes tests, not predict a contract that still exists only in planning.

**Test definitions (pseudocode):**

```text
docs := architecture and spec surfaces
when prompt-boundary sections are read
then they describe FSM state assets as phase-owned mission/contract sources
and they describe APE YAMLs as thinking-tool identity surfaces
and they describe Inquiry CLI as the explicit prompt assembler
and they keep iq ape prompt as the inspectable effective-prompt surface
and DARWIN is documented as an abstract-process exception only
and they do not reintroduce mixed ownership language that would imply hidden prompt glue or repository procedure inside standard APE YAMLs

release := pubspec.yaml + version.dart + site index badge + cli changelog
when version sync and final validation run
then all version surfaces agree
and the changelog records the prompt-boundary refactor
```

**Verification gate (pseudocode):**

```text
run dart analyze
expect exit 0

run dart test
expect exit 0

run dart test test/version_sync_test.dart
expect exit 0

run rg "thinking tool|operational contract|iq ape prompt|DARWIN|prompt assembly" ..\docs ..\code\cli\assets\agents
expect docs and firmware to describe the final validated ownership boundary, preserve prompt inspectability, and bound DARWIN to the abstract-process exception without stale mixed-ownership language
```

**TDD:** No. This phase aligns explanation and release surfaces after the executable contract is already green.

- [ ] Update the explanatory documentation in `docs/architecture.md`, `docs/thinking-tools.md`, `docs/spec/agent-lifecycle.md`, `docs/spec/finite-ape-machine.md`, and `docs/spec/target-specific-agents.md` so they describe the validated ownership boundary and the bounded DARWIN exception.
- [ ] Reconcile `code/cli/assets/agents/inquiry.agent.md` with the final runtime wording if earlier phases left any temporary wording behind.
- [ ] Update `code/cli/CHANGELOG.md` with the prompt-boundary refactor.
- [ ] Bump the release surfaces in `code/cli/pubspec.yaml`, `code/cli/lib/src/version.dart`, and `code/site/index.html`.
- [ ] Run `dart analyze`, `dart test`, `dart test test/version_sync_test.dart`, and the `rg` verification above until the repository is release-ready.
- [ ] Commit: "release(cli): finalize prompt-boundary separation for #154"