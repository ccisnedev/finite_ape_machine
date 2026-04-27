# Plan — Issue #152: State encapsulation violation

**Input:** [diagnosis.md](analyze/diagnosis.md)

## Phase 1 — Add prechecks to `start_analyze` (A1)

**Entry:** diagnosis.md approved, branch `152-state-encapsulation-violation` active
**Risk:** Low — validation code already exists, only contract declaration missing

- [ ] Edit `code/cli/assets/fsm/transition_contract.yaml`: change `prechecks: []` to `prechecks: [issue_selected_or_created, feature_branch_selected]` on the IDLE→ANALYZE transition (line ~38)
- [ ] Run `dart test` — verify existing precheck tests pass
- [ ] Manual test: `iq fsm transition --event start_analyze` without `--issue` → should fail with precheck error
- [ ] Manual test: `iq fsm transition --event start_analyze --issue 152` → should succeed

**Verification:** Transition to ANALYZE is impossible without issue and branch.

---

## Phase 2 — Remove `next_state` from JSON output (A2)

**Entry:** Phase 1 complete
**Risk:** Low — 1 test to update, nothing reads this field for routing

- [ ] Edit `code/cli/lib/modules/fsm/commands/state.dart` `_computeTransitions`: remove `'next_state': transition.to!.value` from the map, return only `{'event': event.value}`
- [ ] Edit `code/cli/lib/modules/fsm/commands/state.dart` `toText()`: update the line `buf.writeln('  --${t['event']}--> ${t['next_state']}')` to only show the event name
- [ ] Edit `code/cli/test/fsm_state_test.dart`: update test `'each transition has event and next_state'` — rename to `'each transition has event'`, remove `expect(t, contains('next_state'))`
- [ ] Note: `transition.dart` line 77 also outputs `next_state` in its own output — this is the transition command confirming what happened, not leaking future state to the agent. Leave it.
- [ ] Run `dart test` — all tests pass

**Verification:** `iq fsm state --json` transitions array contains only `{"event": "..."}`, no `next_state`.

---

## Phase 3 — Rewrite `_stateInstructions` as mission descriptions (A3)

**Entry:** Phase 2 complete
**Risk:** Low — string changes only, no logic

- [ ] Edit `code/cli/lib/modules/fsm/commands/state.dart` `_stateInstructions` map. Replace all 6 values:

| State | New instruction |
|-------|----------------|
| IDLE | `Evaluate what work merits inquiry. Understand the problem, search for existing issues, create or select an issue, prepare the branch.` |
| ANALYZE | `Investigate the problem through structured questioning. Challenge assumptions, gather evidence, explore perspectives. Produce diagnosis.md.` |
| PLAN | `Design an experimental plan from the diagnosis. Divide into phases, order by dependencies, define verification for each. Produce plan.md.` |
| EXECUTE | `Implement the plan phase by phase under its formal constraints. Each phase produces tested code and a commit.` |
| END | `Review the execution. Create the pull request.` |
| EVOLUTION | `Evaluate the completed cycle. Observe what worked, what deviated, what can improve. Create improvement issues.` |

- [ ] Run `dart test` — no tests assert on instruction text content (verified)

**Verification:** `iq fsm state --json` `instructions` field contains mission description, no event names or command hints.

---

## Phase 4 — Update `issue-start` skill to use CLI (A4)

**Entry:** Phase 1 complete (prechecks active)
**Risk:** Low — text change in skill file

- [ ] Edit `code/cli/assets/skills/issue-start/SKILL.md` Step 7: replace "Write `.inquiry/state.yaml`" block with: "Execute `iq fsm transition --event start_analyze --issue <NNN>` — this transitions the FSM and auto-activates SOCRATES."
- [ ] Remove the raw YAML template from Step 7
- [ ] Edit Step 8: remove `[APE: ANALYZE]` announcement — the scheduler reads state from CLI, not from skill output
- [ ] Edit Verification section: replace "State updated: `.inquiry/state.yaml` shows `phase: ANALYZE`" with "State updated: `iq fsm state` shows `ANALYZE`"
- [ ] Sync: copy updated skill to `code/cli/build/assets/skills/issue-start/SKILL.md`

**Verification:** Skill text contains no direct writes to `.inquiry/`.

---

## Phase 5 — Activate SOCRATES in IDLE (B1)

**Entry:** Phases 1-4 complete
**Risk:** Medium — new sub-FSM definition, changes to 3 mapping files
**Depends on:** Phase 3 (IDLE instruction must exist before SOCRATES gets activated there)

- [ ] Create `code/cli/assets/apes/socrates-idle.yaml` — SOCRATES triage-mode definition:
  - Same `base_prompt` reference or reduced triage-focused prompt
  - `initial_state: evaluate_scope`
  - States: `evaluate_scope → search_existing → create_or_select → confirm → _DONE`
  - Each state has a triage-focused prompt (scope assessment, issue search, issue creation, confirmation)
- [ ] Edit `code/cli/lib/modules/fsm/effect_executor.dart` `_stateApes`: add `'IDLE': 'socrates-idle'`
- [ ] Edit `code/cli/lib/modules/fsm/commands/state.dart` `_stateApes`: add `FsmState.idle: [{'name': 'socrates-idle', 'status': 'RUNNING'}]`
- [ ] Edit `code/cli/lib/modules/ape/commands/prompt.dart` `_stateApes`: add `FsmState.idle: ['socrates-idle']`
- [ ] Add test: `dart test` — IDLE state now shows `socrates-idle` as active APE
- [ ] Add test: `iq ape prompt --name socrates-idle` in IDLE state returns triage prompt
- [ ] Manual test: enter IDLE → `iq fsm state --json` shows `ape: {name: socrates-idle, state: evaluate_scope}`

**Verification:** IDLE has an active sub-agent. Entering IDLE auto-activates SOCRATES in triage mode.

**Design note:** Using `socrates-idle` as a separate YAML rather than mode-switching on `socrates` keeps the current architecture intact. The conceptual principle (SOCRATES is one thinking tool in two modes) is preserved in naming. The full multi-mode infrastructure is a larger refactor tracked in #154.

---

## Phase 6 — Rewrite firmware (B2)

**Entry:** Phase 5 complete
**Risk:** Medium — the firmware is what the agent reads first; errors degrade all behavior
**Depends on:** All previous phases (firmware must reflect the new CLI behavior)

- [ ] Rewrite `code/cli/assets/agents/inquiry.agent.md`:
  - Remove all state name enumerations
  - Boot section: run `iq fsm state --json`, parse `state`, `issue`, `instructions`, `transitions`, `ape`
  - Outer Loop: announce `[INQUIRY]`, read `instructions` field, if `ape` active → Inner Loop, if no ape → follow instructions and present transitions
  - Inner Loop: unchanged (already generic)
  - Rules: unchanged (kernel boundary rule already present)
  - Remove `description` field reference to specific state names if present
- [ ] Sync: copy to `code/cli/build/assets/agents/inquiry.agent.md`
- [ ] Manual test: verify `iq fsm state --json` output in IDLE → firmware dispatches SOCRATES triage
- [ ] Manual test: verify ANALYZE → firmware dispatches SOCRATES analysis

**Verification:** Firmware text contains zero state names (IDLE, ANALYZE, PLAN, EXECUTE, END, EVOLUTION). Grep confirms.

---

## Phase 7 — Final validation

**Entry:** All phases complete
**Risk:** None — read-only verification

- [ ] `dart analyze` — no warnings
- [ ] `dart test` — all tests pass
- [ ] `iq fsm state --json` in IDLE — no `next_state`, mission instruction, `socrates-idle` active
- [ ] `iq fsm state --json` in ANALYZE — no `next_state`, mission instruction, `socrates` active
- [ ] Grep firmware for state names — zero matches
- [ ] Grep `issue-start/SKILL.md` for `state.yaml` — zero matches
- [ ] Commit all changes
