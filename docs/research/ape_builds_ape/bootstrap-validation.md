para # Bootstrap Validation: APE Builds APE

## Title (working)

Finite APE Machine in Practice: Bootstrap Validation through Self-Construction

## 1. Thesis

The APE framework was built using itself — a bootstrap process where the methodology evolved from implicit human behavior into an explicit, deployable system. This paper section documents that evolution as empirical evidence that the APE cycle produces verifiable software.

## 2. The Bootstrap Narrative

The development of `ape_cli` (v0.0.1 → v0.0.14) followed a four-stage evolution:

### Stage 1 — Implicit APE (pre-v0.0.1)

The author directed a default AI coding agent stage-by-stage, manually enforcing the Analyze → Plan → Execute cycle through conversational discipline. No tooling existed. The methodology lived entirely in the author's mental model.

**Evidence:** Early commit history, unstructured conversations.

### Stage 2 — Prompt as Methodology (v0.0.1–v0.0.5)

The mental model was codified into a prompt. The author wrote `ape.agent.md` as a custom agent instruction set that formalized states, transitions, and sub-agent roles. The prompt became the transition function δ.

**Evidence:** First versions of `ape.agent.md`, commit diffs showing prompt evolution.

### Stage 3 — Custom Agent (v0.0.6–v0.0.10)

The deploy infrastructure (`ape target get`) existed since v0.0.2, but was unstable — bugs in coexistence logic (#12), locked-exe upgrades (#14), and uninstall (#16) consumed v0.0.3–v0.0.5. From v0.0.6 onward, the agent was stabilized as a single-target Copilot deployment. The APE cycle became self-enforcing — the agent refused to skip states, demanded issue numbers, required user gates. The system began constraining its own development.

**Evidence:** Issue history shows structured cycle adoption from v0.0.6+. PR descriptions follow consistent format. Every version from v0.0.7 onward has `docs/issues/NNN-slug/` artifacts.

### Stage 4 — CLI + Contract (v0.0.11–v0.0.14)

The CLI gained runtime infrastructure: FSM transition contract (YAML), programmatic state transitions with precondition validation (`ape state transition`), declarative effects, and evolution infrastructure (`.ape/config.yaml`, `.ape/mutations.md`). State tracking (`.ape/state.yaml`) existed since v0.0.7, but Stage 4 made transitions machine-verifiable — the contract says what's legal, tests prove the contract holds.

**Evidence:** `transition_contract.yaml`, 131 passing tests, 14 versions (12 GitHub releases — v0.0.1 was dev-only, v0.0.8 missed release due to pubspec.yaml desync), 69+ issues/PRs.

## 3. Data Sources

All evidence exists in the Git history and GitHub API:

| Source | What it proves | How to extract |
|--------|---------------|----------------|
| `gh issue list` | Every task had an issue before work began | GitHub API |
| `gh pr list` | Every change went through PR review | GitHub API |
| Commit messages | Structured format: `type(#N): description` | `git log --oneline` |
| `docs/issues/NNN-slug/` | Every cycle produced analysis + plan artifacts | File system |
| `plan.md` checkboxes | Plan completion rate (checked vs total) | grep `- \[x\]` vs `- \[ \]` |
| Test count over time | Quality investment grows with features | `git log` + test file diffs |
| PR descriptions | Consistent checklist (tests, analyze, changelog, version) | GitHub API |
| `metrics.yaml` | Structured per-cycle experiment data | File system (see [metrics-schema.md](./metrics-schema.md)) |

For methodology on how each issue is treated as an experiment, see [experiment-methodology.md](./experiment-methodology.md).

## 4. Metrics to Graph

### 4.1 Velocity & Reliability

- **Issues closed per version** — does the cycle accelerate or plateau?
- **Test count over time** — linear, exponential, or step-function growth?
- **Time-to-merge per PR** — cycle time from branch to merge
- **Deviation rate** — plan.md original vs final (annotated deviations)

### 4.2 Self-Construction Evidence

- **Lines of code by version** — growth curve of the CLI itself
- **Agent prompt size over time** — does the prompt grow, shrink, or stabilize?
- **Contract coverage** — states × events matrix completeness per version
- **Ratio: spec-driven vs bug-fix issues** — shows proactive vs reactive development

### 4.3 Methodology Convergence

- **Commit message format compliance** — when did structured messages become consistent?
- **Issue-first discipline** — versions where commits without issue references appear (should decrease)
- **Sub-agent roster changes** — MARCOPOLO→SOCRATES→VITRUVIUS timeline vs SOCRATES/DESCARTES/BASHŌ simplification

## 5. Paper Structure (planned)

```
§1  Introduction — "APE builds APE" as experimental design
§2  Methodology — how data was collected (observational, not controlled)
§3  Results
    §3.1  Bootstrap timeline (4 stages with evidence)
    §3.2  Quantitative metrics (graphs from §4)
    §3.3  Qualitative observations (what worked, what was discarded)
§4  Threats to validity
    - Single developer (N=1)
    - Self-selection bias (author chose what to measure)
    - No control group (no "without APE" comparison on same tasks)
§5  Discussion
    - What the bootstrap proves: the methodology is self-consistent
    - What it doesn't prove: superiority over alternatives
    - Future work: controlled experiments with external developers
§6  Conclusion
```

## 6. Threats to Validity (acknowledged upfront)

1. **N=1** — Single developer means no statistical power. Mitigated by: the evidence is architectural (system works) not statistical (system is faster).
2. **Observer effect** — The author knows they're collecting data. Mitigated by: data is extracted from git history post-hoc, not self-reported.
3. **No control** — No identical tasks done "without APE" for comparison. Mitigated by: the claim is "APE produces verifiable software," not "APE is faster than X."
4. **Bootstrap paradox** — If the tool fails, the paper can't be written. Mitigated by: v0.0.14 exists with 131 tests, the tool works.

## 7. Timeline

| Milestone | When | Status |
|-----------|------|--------|
| Data extraction scripts | After v0.1.0 | Not started |
| Graph generation | After data extraction | Not started |
| Narrative writing (§3.1) | Can start now | Not started |
| Quantitative analysis (§3.2) | After graphs | Not started |
| Full paper draft | After v0.1.0 | Not started |

## 8. Relationship to Theoretical Paper

The theoretical paper (`ape-paper.md`) presents the framework design with 36 references and 10 claimed contributions. This experimental paper validates claim #1 empirically: **APE builds APE** is not a slogan — it is a documented, verifiable fact extracted from 14 releases of self-constructing software.
