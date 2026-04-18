---
id: fsm-fix-analysis
title: "FSM Fix Analysis: END state, retrospective, and Git workflow (#43, #30, #32)"
date: 2026-04-18
status: draft
tags: [fsm, end-state, evolution, retrospective, git-workflow, ape-agent]
author: socrates
---

# FSM Fix Analysis: Bundle A

Analysis of the three FSM-related issues in scope for v0.0.11. These changes are **prompt/documentation changes** in `ape.agent.md` — no Dart code is required (except minor `.ape/state.yaml` validation if END becomes a recognized phase).

---

## 1. The Three Issues

### Issue #43: Add END state + EVOLUTION optional

**Problem:** In v0.0.10, BASHŌ auto-created the PR without user validation. The PR creation happens as a transition *effect* (`EXECUTE → EVOLUTION: Effect: git commit + push + PR`), not as a user-gated action within a state. The user had no gate between "code complete" and "PR created".

**Proposed change:**
```
Current:  IDLE → ANALYZE → PLAN → EXECUTE → EVOLUTION → IDLE
Proposed: IDLE → ANALYZE → PLAN → EXECUTE → END → [EVOLUTION] → IDLE
```

END state semantics:
- **Entry:** User approves EXECUTE report (validation passed)
- **Actions:** PR created, cycle formally closed
- **Exit:** User authorizes PR creation
- **EVOLUTION** becomes optional via `.ape/config.yaml` `evolution.enabled: false`

### Issue #30: Formalize post-EXECUTE retrospective

**Problem:** Issue #001 revealed the cycle has a feedback loop, not a linear flow. EXECUTE must produce a lessons-learned document *before* EVOLUTION evaluates the process. The retrospective is the final step of execution, not the start of a new cycle.

**Key distinction:** DARWIN (EVOLUTION) evaluates the *process*. The retrospective evaluates the *product* and *decisions made during execution*. These are different concerns.

### Issue #32: Integrate Git workflow into the APE cycle

**Problem:** During issue #002, all commits were on main. Expected flow:
```
issue → branch → ANALYZE → PLAN → EXECUTE → retrospective → PR → close
```
Commits at phase transitions. Conventional commit format. Branch naming: `NNN-slug`.

---

## 2. What `ape.agent.md` Already Handles

A line-by-line audit of the current agent prompt reveals partial coverage:

### Git workflow (#32) — Partially addressed

| Aspect | Status | Location in ape.agent.md |
|--------|--------|--------------------------|
| Branch naming (`NNN-slug`) | ✅ Defined | IDLE state, step 4 |
| `issue-start` skill | ✅ Referenced | IDLE state, step 4 |
| Commit at transitions | ✅ Stated | Transitions section: "Effect: git commit" at each transition |
| Branch → PR flow | ⚠️ Implicit | Only in EXECUTE→EVOLUTION transition effect |
| Conventional commits | ❌ Not specified | No mention of commit format |
| Issue closing | ❌ Not specified | No mention of closing issue after PR merge |

### EVOLUTION optional — Partially addressed

| Aspect | Status | Location in ape.agent.md |
|--------|--------|--------------------------|
| `evolution.enabled: false` | ✅ Documented | EVOLUTION state rules: "Can be disabled" |
| Skip to IDLE | ✅ Documented | Same rule: "skip this state entirely and go directly to IDLE" |
| END state as gate | ❌ Missing | No END state exists; PR is a transition effect |

### Retrospective (#30) — Partially addressed

| Aspect | Status | Location in ape.agent.md |
|--------|--------|--------------------------|
| BASHŌ validation report | ✅ Exists | EXECUTE "Final phase — Product Retrospective" |
| Lessons-learned document | ❌ Missing | BASHŌ reports *what was done*, not *what was learned* |
| Retrospective before DARWIN | ❌ Missing | DARWIN receives artifacts but no explicit retrospective doc |

---

## 3. What Specifically Needs to Change

### Change 1: Add END state to the FSM (addresses #43)

**Current transitions section (ape.agent.md ~L168-175):**
```
IDLE     → ANALYZE     User says to start analysis. Effect: issue-start skill executed.
ANALYZE  → PLAN        User approves diagnosis. Effect: git commit analysis.
PLAN     → EXECUTE     User approves the plan. Effect: git commit plan.
EXECUTE  → EVOLUTION   User approves execution. Effect: git commit + push + PR.
EVOLUTION → IDLE       Automatic. DARWIN completes.
```

**Proposed transitions:**
```
IDLE     → ANALYZE     User says to start analysis. Effect: issue-start skill executed.
ANALYZE  → PLAN        User approves diagnosis. Effect: git commit analysis.
PLAN     → EXECUTE     User approves the plan. Effect: git commit plan.
EXECUTE  → END         User approves execution report. Effect: git commit.
END      → EVOLUTION   User authorizes PR. Effect: git push + gh pr create.
END      → IDLE        User authorizes PR (evolution disabled). Effect: git push + gh pr create.
EVOLUTION → IDLE       Automatic. DARWIN completes.
```

**New END state definition needed:**
```
### END — Cycle closure and PR gate

Entry: User approves EXECUTE validation report.
Actions:
  1. BASHŌ produces retrospective (lessons-learned) — addresses #30
  2. User reviews retrospective
  3. User authorizes PR creation
Effects: git push, gh pr create --title "NNN: slug" --body "Closes #NNN"
Exit: If evolution.enabled → EVOLUTION. Else → IDLE.
```

**Illegal transitions to add:**
- EXECUTE → IDLE (must go through END)
- END → PLAN (must go through ANALYZE)

### Change 2: Expand BASHŌ's final phase to include retrospective (#30)

**Current BASHŌ final phase (ape.agent.md ~L130-133):**
```
Final phase — Product Retrospective:
- BASHŌ produces a validation report: what was implemented, how to verify, known limitations.
- The user reviews, validates, runs their own tests.
- Additional commits may be needed based on user feedback.
```

**Proposed BASHŌ final phase:**
```
Final phase — Product Retrospective:
- BASHŌ produces a validation report: what was implemented, how to verify, known limitations.
- BASHŌ produces a lessons-learned document: what went well, what deviated, what surprised.
  This document is saved as docs/issues/NNN-slug/retrospective.md.
- The user reviews, validates, runs their own tests.
- Additional commits may be needed based on user feedback.
- The retrospective becomes input for DARWIN alongside diagnosis.md and plan.md.
```

### Change 3: Formalize Git workflow conventions (#32)

**Add to the Directory Structure section or a new Conventions section:**
```
## Git Conventions

- Branch: NNN-slug (created by issue-start skill)
- Commits: conventional format — type(scope): description
  - analyze(NNN): complete analysis phase
  - plan(NNN): approve plan
  - feat(NNN): implement phase X
  - fix(NNN): address deviation in phase X
- PR: gh pr create --title "NNN: slug" --body "Closes #NNN"
- Issue: closed automatically by PR merge via "Closes #NNN"
```

### Change 4: Update state announcement block

**Current (ape.agent.md ~L24-30):**
```
[APE: IDLE] ...
[APE: ANALYZE] ...
[APE: PLAN] ...
[APE: EXECUTE] ...
[APE: EVOLUTION] ...
```

**Proposed:**
```
[APE: IDLE] ...
[APE: ANALYZE] ...
[APE: PLAN] ...
[APE: EXECUTE] ...
[APE: END] ...
[APE: EVOLUTION] ...
```

### Change 5: Update DARWIN's input to include retrospective

**Current DARWIN input (ape.agent.md ~L449-453):**
```
You receive the complete cycle artifacts:
- diagnosis.md (what was analyzed)
- plan.md (what was planned, with checkbox state and deviation annotations)
- Commit history (what was actually built)
- Any deviation notes
```

**Proposed:**
```
You receive the complete cycle artifacts:
- diagnosis.md (what was analyzed)
- plan.md (what was planned, with checkbox state and deviation annotations)
- retrospective.md (lessons learned from execution)
- Commit history (what was actually built)
- Any deviation notes
```

### Change 6: Update `.ape/state.yaml` valid phases

**Minor code change:** If the CLI validates `phase:` values in `.ape/state.yaml`, add `END` to the valid set. This is the ONLY potential Dart code change in Bundle A.

---

## 4. Independence Assessment: Bundle A ≠ Bundle B

| Dimension | Bundle A (FSM Fix) | Bundle B (Cross-Platform) |
|-----------|---------------------|---------------------------|
| **Files changed** | `ape.agent.md` (+ possibly state.yaml validation) | `upgrade.dart`, `uninstall.dart`, `init.dart`, `release.yml`, `ci.yaml`, `install.sh`, `PlatformOps` classes |
| **Nature of change** | Prompt/documentation | Dart code + CI/CD |
| **Can be tested** | By running an APE cycle | By `dart test` + CI matrix |
| **Dependencies** | None on Bundle B | None on Bundle A |
| **Risk** | Low (text changes) | Medium (new platform support) |

**Shared surface:** If `.ape/state.yaml` needs to recognize "END" as a valid phase, that's a 1-line Dart change in the CLI. This does not create a dependency — it can be done in either bundle independently.

**Conclusion:** The bundles are fully independent. They can be implemented in parallel, in any order, or split into separate PRs/issues.

---

## 5. Decision Log (P10–P12)

### P10: PlatformOps DI pattern

**Question:** How should commands receive PlatformOps — constructor injection or global factory?

**Decision:** Constructor injection. The user stated: *"Entiendo que no es aceptable que los tests sean frágiles, inyectar por constructor es buena práctica. Vamos por esa opción."*

**Implication:** All commands that use PlatformOps (`upgrade`, `uninstall`, `doctor`) receive it via constructor. Tests inject mocks. A `PlatformOps.current()` factory exists for production code in `main()`.

### P11: ci.yaml scope for v0.0.11

**Question:** How elaborate should ci.yaml be?

**Decision:** Level 1 only: `dart analyze` + `dart test` in matrix `[ubuntu-latest, windows-latest]`. The user stated: *"Para v0.0.11 hagamos solo nivel 1: dart analyze + dart test."*

**Implication:** No integration tests, no coverage reports, no caching in v0.0.11. Keep it simple. Expand in future cycles.

### P12: FSM independence acknowledged

**Question:** Have we neglected Bundle A in the analysis?

**Decision:** Yes. The user pointed out: *"Revisa los documentos de investigación creados, el problema es que hasta ahora nos hemos centrado solo en multiplataforma."* This document is the corrective action.

---

## 6. Open Questions

1. **END state naming:** Is "END" the right name? Alternatives: "CLOSE", "REVIEW", "DELIVER". "END" is clear but could be confused with process termination. "DELIVER" emphasizes the PR delivery semantics.

2. **Retrospective ownership:** Should retrospective.md be produced by BASHŌ (as part of EXECUTE's final phase) or by a new interaction in END state? If BASHŌ produces it, END is purely a gate. If END produces it, it needs its own sub-agent or APE handles it directly.

3. **`notas_para_evolution.md` pattern:** The user described a running notes file where observations accumulate during the cycle. How does this relate to retrospective.md? Are they the same artifact or complementary?

---

## References

- [scope-and-audit-overview.md](scope-and-audit-overview.md) — Original scope definition with Bundle A/B/C
- [decisiones-tecnicas.md](decisiones-tecnicas.md) — Technical decisions Q1–Q3 (cross-platform)
- [investigacion-patrones.md](investigacion-patrones.md) — Pattern research P4–P6
- [implicaciones-decisiones.md](implicaciones-decisiones.md) — Implications of decisions P7–P9
- [notas_para_evolution.md](notas_para_evolution.md) — User observations for DARWIN
- `ape.agent.md` — Current FSM definition (source of truth)
