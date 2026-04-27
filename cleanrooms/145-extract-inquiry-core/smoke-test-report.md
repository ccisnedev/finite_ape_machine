# Smoke Test Report — Inquiry CLI v0.2.0

**Date:** 2026-04-26
**Subject under test:** `iq` CLI v0.2.0 (commit `8370128`, branch `release/0.2.0`)
**Test environment:** VS Code Devcontainer in repo `cacsi-dev/tareas`
**Test target:** Real GitHub issue `cacsi-dev/tareas#31` ("No guarda la fase registrada")
**Operator:** User (manual operation of `@inquiry` custom agent in Copilot Chat)
**Reporter:** GitHub Copilot (assistant)

> **Disclaimer.** This report records only the directly observed evidence shared by the operator. No inferences about root cause are included. Severity is qualitative and limited to the visible impact during the test.

---

## 1. Test scope

Validate the v0.2.0 firmware end-to-end:

- CLI commands: `iq fsm transition`, `iq fsm state`, `iq ape transition`, `iq ape state`, `iq ape prompt`
- Custom agent firmware behavior (`inquiry.agent.md`)
- Sub-FSMs: SOCRATES, DESCARTES, BASHŌ
- Interaction protocol between agent and CLI
- State persistence in `.inquiry/state.yaml`

The objective was **flow validation**, not solving the underlying business issue. The repo's runtime stack (MongoDB, API, Flutter) was **not** required to validate the firmware.

---

## 2. Cycle outcome

| Phase | Result |
|---|---|
| IDLE → ANALYZE | ✅ Completed |
| ANALYZE (SOCRATES) | ✅ `diagnosis.md` produced |
| ANALYZE → PLAN | ⚠️ Required manual fix to `state.yaml` (see F1) |
| PLAN (DESCARTES) | ✅ `plan.md` produced |
| PLAN → EXECUTE | ✅ Completed |
| EXECUTE (BASHŌ) | ✅ Implementation + 81/81 tests green |
| EXECUTE → END | ✅ Completed |
| END (PR creation) | ✅ PR `cacsi-dev/tareas#32` created |
| END → IDLE | ✅ Completed |
| Final state | ✅ `state: IDLE, issue: null, ape: null` |

**Final state.yaml (verified by operator):**
```yaml
state: IDLE
issue: null
ape: null
```

**Config in effect during test:**
```yaml
evolution:
  enabled: false
```

---

## 3. Findings

### 3.1 Findings classified as POSITIVE

| ID | Observation |
|----|-------------|
| P1 | The full APE cycle completed end-to-end and returned to IDLE cleanly. |
| P2 | `iq fsm state --json` returned consistent, well-formed structured output at every checkpoint queried. |
| P3 | `iq ape transition` correctly walked the DESCARTES sub-FSM: `decomposition → ordering → verification → enumeration → _DONE`. |
| P4 | `iq ape transition` correctly walked the BASHŌ sub-FSM: `implement → test → commit → _DONE`. |
| P5 | `iq fsm transition --event finish_execute` correctly moved EXECUTE → END. |
| P6 | `iq fsm transition --event pr_ready_no_evolution` correctly moved END → IDLE and cleared `issue` to `null`. |
| P7 | The `iq ape prompt --name <name>` output rendered the full role prompt + sub-state focus block (verified for SOCRATES, DESCARTES, BASHŌ). |
| P8 | The implementation phase produced a real, working code change merged into branch `031-no-guarda-la-fase-registrada` with 81/81 tests green. |
| P9 | A real GitHub PR was created against `cacsi-dev/tareas` (PR #32). |
| P10 | **Context window utilization stayed at 39%** for the full cycle. Previous cycles without the externalized `.inquiry/` state and `iq` CLI typically required multiple context fills and compactions, causing the LLM to lose important details. By delegating state to files and CLI, the LLM no longer carries that burden. |

---

### 3.2 Findings classified as DEFECTS

Severity scale:
- **CRITICAL** — broke or required manual intervention to recover the cycle
- **HIGH** — visible UX or contract violation
- **MEDIUM** — minor UX issue or unwanted noise

| ID | Severity | Component | Observation |
|----|----------|-----------|-------------|
| F1 | CRITICAL | CLI `iq fsm transition` | Flag `--issue 31` was silently ignored. After `iq fsm transition --event start_analyze --issue 31`, `state.yaml` showed `issue: null`. Later, `iq fsm transition --event complete_analysis` (and the retry `--issue 31`) failed precondition with `ERROR_PRECONDITION_ISSUE_FIRST`. The operator manually edited `state.yaml` to set `issue: 31`, after which the same transition succeeded. **Note:** A fix was committed to the inquiry repo as `9f7d56c` but was not redeployed into the devcontainer; the test ran entirely on the unfixed binary. |
| F2 | HIGH | Custom agent firmware | DESCARTES's plan content was rendered inside the chat by the custom agent. Operator's contract: the custom agent must not display the plan; the sub-agent writes `plan.md` directly to disk and the custom agent only reports that it was created. |
| F3 | HIGH | Custom agent firmware | After producing the plan, the custom agent asked: *"¿Apruebas este plan o quieres ajustar algo antes de que lo formalice en `plan.md`?"* — an open-ended question. Operator's contract: only yes/no questions, no ambiguity. Expected: *"¿Apruebas el plan?"*. |
| F4 | HIGH | Custom agent firmware | After the operator's answer "Sí, aprobado", the agent then proceeded to write `plan.md` (sequence: `iq ape transition next` → `next` → `next` → write plan). Operator's contract: the plan must be written by the sub-agent before being announced; the custom agent should not be the writer. |
| F5 | HIGH | Custom agent firmware | Custom agent edited `.inquiry/state.yaml` directly (twice during the cycle: once to fix the missing `issue: 31`, once attempting to "resync" EXECUTE state). Operator's contract: the custom agent may **read** state files but **all writes must go through `iq` commands**. Evidence: VS Code blocked the second edit with *"The content of the file is newer. Please compare your version..."* |
| F6 | HIGH | Custom agent firmware | Before the commit during EXECUTE, the agent asked: *"¿Autorizo el commit y la transición a END?"*. Operator's contract: commits do not require authorization; only FSM transitions do. |
| F7 | CRITICAL | Sub-agent context isolation | During EXECUTE → END, the agent emitted: *"La skill issue-end menciona version bumps y changelogs, pero eso es para el proyecto inquiry mismo. Para este proyecto (tareas), solo necesito commit + push + PR."* This explicitly references the Inquiry meta-project from inside a sub-agent operating on `tareas`. Operator's contract: at this layer, no agent or sub-agent should know that the Inquiry project exists, and version-bump + changelog should be attempted regardless of which repo is the target. |
| F8 | HIGH | Custom agent firmware | At END, the agent asked: *"¿Quieres que haga push de la rama y cree el PR? ¿Y prefieres ir a EVOLUTION o directamente a IDLE?"* — two compound questions with multiple options. Operator's contract: a single binary question — *"¿Hago el PR?"*. The choice between EVOLUTION and IDLE must not be exposed. |
| F9 | HIGH | Custom agent firmware | EVOLUTION was offered as a user choice. With `evolution.enabled: false` in `config.yaml`, EVOLUTION must be silently skipped — neither offered nor mentioned. Evidence: the cycle correctly took the `pr_ready_no_evolution` path (good outcome), but the user was unnecessarily prompted to choose. |

---

## 4. Verbatim CLI evidence

### 4.1 Evidence for F1 — `--issue` ignored

```
$ iq fsm transition --event complete_analysis
ERROR_PRECONDITION_ISSUE_FIRST: Create/select issue before commitment actions

$ iq fsm transition --event complete_analysis --issue 31
ERROR_PRECONDITION_ISSUE_FIRST: Create/select issue before commitment actions

# Operator manually edited .inquiry/state.yaml:
$ cat .inquiry/state.yaml
state: ANALYZE
issue: 31
ape:
  name: socrates
  state: _DONE

$ iq fsm transition --event complete_analysis
Transition ANALYZE --complete_analysis--> PLAN
```

### 4.2 Evidence for sub-FSM walks (positive — P3, P4)

DESCARTES:
```
$ iq ape transition --event next     → decomposition --next--> ordering
$ iq ape transition --event next     → ordering --next--> verification
$ iq ape transition --event next     → verification --next--> enumeration
$ iq ape transition --event complete → enumeration --complete--> _DONE
```

BASHŌ:
```
$ iq ape transition --event next     → implement --next--> test
$ iq ape transition --event next     → test --next--> commit
$ iq ape transition --event complete → commit --complete--> _DONE
```

### 4.3 Evidence for F5 — concurrent file edit blocked

VS Code error during second direct edit of `state.yaml` by the agent:
> *"Failed to save 'state.yaml': The content of the file is newer. Please compare your version with the file contents or overwrite the content of the file with your changes."*

### 4.4 Evidence for cycle closure (positive — P1, P6)

```
$ iq fsm transition --event finish_execute
Transition EXECUTE --finish_execute--> END

$ iq fsm transition --event pr_ready_no_evolution
Transition END --pr_ready_no_evolution--> IDLE

$ cat .inquiry/state.yaml
state: IDLE
issue: null
ape: null
```

---

## 5. Outcome of the smoke test

| Dimension | Result |
|-----------|--------|
| `iq` CLI commands | ✅ Functioned correctly (modulo F1) |
| FSM main state machine | ✅ All transitions executed as expected |
| Sub-FSMs (SOCRATES / DESCARTES / BASHŌ) | ✅ All states walked correctly |
| State persistence | ⚠️ One missing-write bug (F1) |
| Custom agent firmware | ❌ Multiple contract violations (F2–F9) |
| Context efficiency | ✅ 39% utilization for a full cycle |
| Real-world output | ✅ Working code + green tests + PR `cacsi-dev/tareas#32` |

---

## 6. Open questions for follow-up (not investigated in this report)

The following items were observed but not analyzed; they are listed only so they are not lost:

- F1's fix (`9f7d56c`) was authored during the test but **not deployed** into the devcontainer. A second smoke test with the patched binary is needed to confirm the fix lands.
- All firmware-related defects (F2–F9) point to the same surface: `code/cli/assets/agents/inquiry.agent.md`. A focused review of that file is the natural next step.
- F7 specifically suggests the `issue-end` skill content leaks Inquiry-meta concepts into target-repo cycles; the skill text should be reviewed.

---

*End of report.*
