# CLARIFICATION Phase — SOCRATES Dialogue

## Session 1: Initial Questions

**SOCRATES' Clarifications Needed:**

Assumption 1: "Execution" boundary
- Is *searching* (read-only) part of triage?
- Is *creating an issue* still triage, or does it cross into execution?
- What's the boundary between "preparation for decision-making" and "taking action"?

Assumption 2: "Why issues first"
- Is the constraint about ensuring human visibility?
- Maintaining audit trail?
- Preventing agent from acting on incomplete analysis?
- Or something else about IDLE's role in APE cycle?

**SOCRATES' Questions for User:**

1. **On the tool level:** When you say "non-execution guardrails," are you thinking about preventing *specific tool calls* (like file editing), or is it more about the *decision to call them*? Should IDLE be prevented from calling `replace_string_in_file` itself, or should there be a guard before that tool is even available in IDLE?

2. **On the process level:** What would you say is the *purpose* of requiring an issue to exist before IDLE makes a change? What breaks if that order is reversed?

3. **On the boundaries:** Can you think of a change that IDLE *should* be allowed to make directly, without an issue? If not, why not? If yes, what makes it different from the install.sh / upgrade.dart changes that violated the constraint?

---

## Session 1: User Responses

### Question 1: Tool-level boundary (read vs. edit)

**User:** IDLE can search information, analyze issues, **and modify files**. But should NOT make commits. To make commits, must do "checkout" (create/select issue, create branch). Checkout requires an issue to exist first.

**Clarification:** The boundary between "preparation" and "action" is **commit/checkout**, not file editing.
- Preparation (IDLE): Read, search, modify files as *exploration*, analyze issues
- Action: `git checkout -b NNN-slug` (requires issue to exist)

### Question 2: Purpose of "issue first" 

**User:** The purpose is **methodology**. It's part of APE's formal structure: every formal change cycle must be associated with a GitHub issue. Not about audit trail or preventing incomplete analysis—it's how the process is designed.

**Implication:** Issue-first is a **structuring constraint**, not a safety guardrail.

### Question 3: When IDLE can make changes

**User:** The error in this incident was treating user-provided code as a "ready artifact" instead of "information for triage."

**Correct flow:**
- IDLE receives code (information)
- IDLE recognizes this could advance to ANALYZE
- IDLE proposes/creates issue (#52)
- Transitions to ANALYZE (user approves)
- ANALYZE → PLAN (quick, simple changes)
- PLAN → EXECUTE (actual implementation)

**Incorrect flow (what happened):**
- IDLE received code
- Treated it as ready artifact
- Called `replace_string_in_file` + made commit
- Skipped issue→checkout→formal cycle

### Question 4: Commits in IDLE (implicit)

**User:** IDLE can modify files, but should NOT make `git commit` until after `git checkout -b <issue-branch>`. That checkout requires an issue to exist first.

**Rule:** File modifications are OK in IDLE. Commits are NOT until checkout is done.

---

## Synthesis: IDLE Boundary Redefined

**IDLE can:**
- Read, search, analyze
- Modify files (as exploration/triage)
- Create or suggest issues
- Diagnose problems

**IDLE cannot:**
- Make `git commit` (requires issue + checkout first)
- Treat provided code as "ready to execute" without issue+cycle
- Transition to ANALYZE without explicit user authorization + issue created

**Key insight:** This incident violated the "issue-first" *methodology* (not a tool constraint). IDLE should have:
1. Recognized the user request as candidate work
2. Proposed/created issue #52
3. Waited for user authorization to transition to ANALYZE
4. Then proceeded through ANALYZE → PLAN → EXECUTE in formal cycle

Instead, it conflated triage (exploration) with execution (commit without issue).

---

## Next Phase: ASSUMPTIONS

Pending: SOCRATES continues to ASSUMPTIONS phase to validate other assumptions about FSM structure, tool availability, and state transitions.
