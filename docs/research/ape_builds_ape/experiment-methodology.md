# Experiment Methodology

How to document each APE cycle (issue) as an experiment for the bootstrap validation paper.

---

## 1. Premise

Every issue attended using APE is an experiment. The data exists naturally in git history and GitHub API. This document defines what *additional* structured data to capture and where.

## 2. Experiment Unit

One experiment = one APE cycle = one issue from IDLE → ... → IDLE.

## 3. Data Capture Per Experiment

### 3.1 Automatic (extractable post-hoc from git/GitHub)

| Datum | Source | Extraction |
|---|---|---|
| Issue # and title | GitHub | `gh issue view N` |
| Branch name | Git | `git branch` history |
| Time: branch created → PR merged | GitHub PR API | `createdAt`, `mergedAt` |
| Commit count | Git | `git log --oneline branch..main` |
| Test count delta | Git diff on test files | `grep -c 'test(' before/after` |
| Plan completion | `plan.md` checkboxes | `grep -c '\[x\]'` vs `grep -c '\[ \]'` |
| LOC delta | Git diff | `git diff --stat` |
| PR description | GitHub | `gh pr view N` |

### 3.2 Manual (captured during the cycle)

| Datum | Where | Who fills it |
|---|---|---|
| Mutations/observations | `.ape/mutations.md` | Human during ANALYZE..EXECUTE |
| Model used | `metrics.yaml` | Human (or future: automatic) |
| Deviations from plan | `metrics.yaml` | Human annotates at cycle end |
| δ failures (LLM didn't follow prompt) | `metrics.yaml` | Human notes retries/corrections |
| DARWIN activated? | `metrics.yaml` | Yes/No + issue # generated |

### 3.3 Structured output: `metrics.yaml`

Each issue directory (`docs/issues/NNN-slug/`) MAY contain a `metrics.yaml` file. Schema defined in [`metrics-schema.md`](./metrics-schema.md).

## 4. What Constitutes a "Failed" Experiment

An experiment is not pass/fail — it's observational. But we track:

- **Cycle abort**: issue abandoned, branch deleted without merge
- **Plan deviation**: significant changes between initial plan.md and final plan.md
- **δ failure rate**: how many times the LLM produced output that required human correction
- **Retry count**: how many times a sub-agent had to be re-invoked for the same step

These are not failures of the methodology — they are data points about model capability and prompt quality.

## 5. DARWIN as Experiment Feedback Loop

When DARWIN (EVOLUTION) is activated:

1. Reads `.ape/mutations.md` (human observations from the cycle)
2. Analyzes the completed cycle (plan vs. reality)
3. Generates an issue with label `evolution`
4. These issues represent methodology improvements identified by the system itself

**Key insight:** DARWIN issues are the system's self-identified improvement opportunities. Tracking which DARWIN-generated issues get implemented vs. discarded measures the signal-to-noise ratio of the evolutionary mechanism.

## 6. Failure Modes to Document

### 6.1 Invalid output that passes validation

**What:** A sub-agent produces output that is syntactically valid but semantically wrong (e.g., a test that passes but doesn't verify the spec's intent).

**How to detect:** Human review during PR, or post-hoc when bugs surface.

**Where to record:** `.ape/mutations.md` during the cycle → DARWIN processes it → generates improvement issue.

**Implication:** High frequency of this failure mode justifies implementing GATSBY (dedicated quality gate agent). Currently DESCARTES handles this role — if model quality decreases (e.g., free/local model), GATSBY becomes necessary.

### 6.2 LLM refuses to follow δ (prompt non-compliance)

**What:** The model omits required sections, adds unrequested content, or hits safety filters.

**Mitigation strategy:** Make the FSM deterministic through CLI commands and tools. Sub-agents use `ape` CLI commands for state transitions. The LLM only reasons about *content* within tightly constrained prompts. Minimal prompt = minimal failure surface.

**When mitigation fails:** mutations.md + DARWIN refine the prompts over time. The prompt IS the transition function — if δ fails repeatedly, DARWIN should generate an issue to improve δ.

**Where to record:** `metrics.yaml` field `delta_failures` with count and brief description.

## 7. Antifragility Validation Plan

To validate Scenario A (model degradation / cost), test APE with:

| Configuration | Model | Cost | Access |
|---|---|---|---|
| Baseline | GitHub Copilot (Claude/GPT) | Subscription | IDE extension |
| Cloud free | Crush + free cloud model | $0 | Open source agent + API |
| Local | gemma4 (or similar) | $0 | Local hardware |

**What to measure across configurations:**
- δ failure rate (prompt compliance)
- Cycle completion rate
- Test quality (manual assessment)
- Time to complete same-complexity issues
- DARWIN issue quality (actionable vs. noise)

## 8. Retroactive Data

Issues #1–#69 were completed before this methodology was defined. Data can still be extracted post-hoc from git/GitHub for all automatic metrics. Manual metrics (model used, δ failures) are lost for past issues but can be approximated for documentation purposes.

The bootstrap narrative (stages 1–4 in `bootstrap-validation.md`) serves as the qualitative account of this retroactive data.
