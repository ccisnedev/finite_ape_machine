# Target-Specific Agent Files

**Finite APE Machine — Architectural Reference**

Date: April 16, 2026
Status: Active

---

## 1. Problem Statement

AI coding tools scope their agent/skill discovery to **their own configuration directory**. A file placed in `~/.claude/agents/` is invisible to GitHub Copilot, and vice versa. This is not a format incompatibility — it is a path-scoping boundary.

### Observed behavior

| Tool | Reads from | Ignores |
|------|-----------|---------|
| GitHub Copilot | `~/.copilot/agents/`, `~/.copilot/skills/` | `~/.claude/`, `~/.codex/`, etc. |
| Claude Code | `~/.claude/agents/`, `~/.claude/skills/` | `~/.copilot/`, `~/.codex/`, etc. |

When `iq target get` deployed the same `inquiry.agent.md` to both `~/.copilot/` and `~/.claude/`, Copilot displayed the agent twice (once from each path it scans). The subsumption fix (D19) — skip Copilot deploy when Claude exists — eliminated the duplicate but made the agent invisible to Copilot entirely, since it only existed in `~/.claude/`.

### Root cause

Each tool only reads files from its own directory. Subsumption assumed tools share visibility across directories. They do not.

---

## 2. Correction: gentle-ai Pattern

The initial adapter design referenced gentle-ai (see `cleanrooms/003-ape-init-v2/analyze/referencia-gentle-ai.md`), which copies skills identically across 11 targets. The assumption was that agents could receive the same treatment.

**This was incorrect.**

gentle-ai itself uses target-specific asset directories (`internal/assets/claude/`, `internal/assets/cursor/agents/`, etc.) and different injection strategies per target (MarkdownSections, FileReplace, AppendToFile). The lesson that "skills are shared, agents are shared" was a misread of the reference. The correct lesson is:

- **Skills:** Content can be shared (plain markdown, no tool-specific metadata). Each target gets a copy in its own directory.
- **Agents:** Content must be target-specific. Each tool has its own frontmatter schema, tool declaration syntax, and behavioral expectations.

---

## 3. What Differs Per Target

| Aspect | Copilot | Claude Code | Codex | Gemini CLI |
|--------|---------|-------------|-------|------------|
| Config dir | `~/.copilot/` | `~/.claude/` | `~/.codex/` | `~/.gemini/` |
| Agent format | `.agent.md` with YAML frontmatter (`tools:`, `description:`) | `.md` with YAML frontmatter (different schema) | TBD | TBD |
| Tool declaration | `tools: [vscode, execute, read, ...]` in frontmatter | Different mechanism | TBD | TBD |
| Skill format | `SKILL.md` (plain markdown) | `SKILL.md` (plain markdown) | TBD | TBD |

The prompt body (instructions, state machine, behavior rules) is the **shared core**. The frontmatter and file structure are **target-specific wrappers**.

---

## 4. Architectural Decision

### D20: Single-target development until MVP

**Decision:** Develop exclusively for GitHub Copilot until a functional MVP exists. Add other targets (Claude Code, Codex, Gemini, Crush) after the Copilot experience is validated.

**Rationale:**
- Multi-target deployment adds complexity without value during early development.
- The subsumption mechanism (D19) was a workaround for a problem that shouldn't exist — each target should have its own deploy path with its own content.
- Building for one target first forces us to understand that target's requirements deeply before abstracting.

### D21: Agent files are target-specific, skills are shared

**Decision:** The deployer must generate target-specific agent files. Skills remain identical copies across targets.

**Rationale:**
- Each AI tool has its own agent file schema (frontmatter, tool declarations, behavioral metadata).
- The shared content is the prompt body — the instructions that define APE's behavior.
- The target-specific content is the wrapper: frontmatter, tool lists, file naming conventions.
- Skills are plain markdown with no tool-specific metadata — they can be copied verbatim.

### D22: Subsumption (D19) reverted for CopilotAdapter

**Decision:** Remove `subsumedBy` override from `CopilotAdapter`. The `subsumedBy` mechanism stays in the `TargetAdapter` base class (zero cost, available for future use). No target suppresses another.

**Rationale:**
- D19 was a workaround for duplicate visibility. The real fix is: each tool reads only from its own directory, so duplicates cannot occur if each target deploys to its own path.
- The base class mechanism is preserved for potential future use when multi-target is re-enabled.

### D23: Adapter code preserved, registration limited

**Decision:** All 5 adapter files remain in `lib/targets/`. Only `CopilotAdapter` is registered for deploy in v0.0.x. `clean()` uses all adapters for backward compatibility (cleans orphaned files from previous deploys).

**Rationale:**
- The adapter code is already written and tested. Deleting it wastes prior work.
- Re-enabling a target is a one-line change in the adapter registry.
- Backward-compatible clean ensures users who previously deployed to other targets don't have orphaned files.

---

## 5. Implementation Path

### Phase 1 (v0.0.x): Copilot-only

- Keep all adapter files, register only `CopilotAdapter` for deploy
- Remove `subsumedBy` from `CopilotAdapter`
- Deploy `inquiry.agent.md` + skills to `~/.copilot/` only
- `clean()` still operates on all 5 adapters (backward compat)
- Validate that Copilot reads the agent and honors tool declarations

### Phase 2 (post-MVP): Multi-target

- Re-register adapters one at a time in the deploy list
- Each adapter may define its own agent template or transformation
- The deployer becomes a compiler: shared prompt + target-specific wrapper → target-specific file
- Skills continue to be copied verbatim

---

## 6. Key Insight

> **The deployer is not a file copier. It is a compiler.**
>
> Input: shared prompt content + target-specific metadata schema.
> Output: one correctly-formatted agent file per target.
>
> For v0.0.x, the "compiler" is trivial — copy one file to one target.
> For v0.1.x+, it must compose target-specific wrappers around shared prompts.
