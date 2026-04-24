# ASSUMPTIONS Phase — SOCRATES Dialogue

## Session 2: Three Assumptions Challenged

### Assumption A: "Tool gating is the right fix"

**SOCRATES Challenge:**
Tool gating treats the *symptom* (tools available), not the *disease* (no permission check). Even if we remove `replace_string_in_file`, IDLE could:
- Write a Python script to modify files
- Manipulate memory files to store uncommitted changes
- Create patch files or shell scripts

**The Real Issue:** Nobody asked "Do I have permission to commit this?" before doing `git commit`.

**Reframe:** Better to add a validation check (one rule) than remove tools (brittle; requires listing infinite workarounds).

---

### Assumption B: "This is an IDLE-specific problem"

**SOCRATES Challenge:**
This pattern occurs in *any* agent state:
- ANALYZE: receives findings → treats as validated → proposes without confirmation
- PLAN: receives feedback → assumes authorization → modifies roadmap
- EXECUTE: receives suggestion → assumes alignment → commits without review
- EVOLUTION: receives metrics → assumes final → closes cycle

**The Commonality:** Agent receives input → assumes minimal validation → takes irreversible action.

**General Principle Needed:** What conditions must be true before *any* agent state performs an irreversible action?

---

### Assumption C: "Methodology constraint = behavior constraint"

**SOCRATES Challenge:**
Is "create issue first" more like:
- **Safety rules** (enforce mechanically, no negotiation)
- **Coding standards** (suggest, human decides)
- **Process rules** (enforce for team, optional for emergency)

Methodology is about **workflow integrity**, not system safety. But it *does* matter—ignored, it makes ANALYZE receive garbage.

**Question:** Should IDLE warn + prompt ("Commit without issue? [yes/no]") instead of blocking?

---

## Critical Reframe: Separate "Exploration" from "Commitment"

**SOCRATES' Key Insight:**

The problem isn't that tools exist. It's that IDLE conflates two modes:

**Exploration Mode (IDLE today):**
- Read files ✓ Always allowed
- Modify files (as analysis/triage) ✓ Should be allowed
- Create intermediate artifacts ✓ Should be allowed

**Commitment Mode (what got mixed in):**
- `git commit` ✗ Requires pre-condition: issue exists
- `git checkout -b` ✗ Requires pre-condition: issue exists  
- PR creation ✗ Requires pre-condition: cycle completed

**The Fix:** Separate these modes explicitly. IDLE can explore freely, but **commitment requires a transition** that validates pre-conditions.

---

## Pending: EVIDENCE Phase

Next step: Validate this understanding against the actual incident evidence (git diff, git log, sequence of events).
