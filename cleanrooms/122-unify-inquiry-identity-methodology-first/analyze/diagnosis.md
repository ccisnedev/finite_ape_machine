# Diagnosis — Issue #122
# Unify Inquiry identity: methodology-first title/subtitle

**Phase:** ANALYZE → PLAN
**Date:** 2026-04-22

---

## Problem Statement

After the rebrand from APE CLI → Inquiry (`iq`), the title and description of the project are inconsistent across surfaces. Some still use "APE" as the brand. Some call it "Inquiry CLI" (too narrow — CLI is just one artifact). The project lacks a single canonical identity statement applied uniformly.

---

## Canonical Identity (Decided)

| Element | Value |
|---------|-------|
| **Title** | `Inquiry` |
| **Subtitle** | `Analyze. Plan. Execute.` |
| **Combined** | `Inquiry — Analyze. Plan. Execute.` (33 chars) |
| **APE acronym** | Internal lore only — does NOT appear in title/subtitle |
| **After title+subtitle** | Each surface adds platform-specific context |

**Rationale:**
- Inquiry is simultaneously: (1) a brand, (2) the Peircean philosophical concept of inquiry (abduction→deduction→induction), and (3) a concrete implementation (FSM, CLI, VS Code extension, subagents). The title+subtitle works for all three layers.
- "Analyze. Plan. Execute." describes the three primary states that users will encounter. The full 6-state FSM (IDLE, ANALYZE, PLAN, EXECUTE, END, EVOLUTION) is discoverable via the web diagram. IDLE and END are trivial; EVOLUTION is opt-in.
- APE remains meaningful as internal lore: each phase agent is called an "ape" (SOCRATES, DESCARTES, BASHŌ, DARWIN). This is explained in the "agents" page, not in the title.

---

## Audience

New users who: found the VS Code extension while browsing AI tools, received a link, or saw it in a list. They are potential adopters of a methodology — not yet users of the CLI. The title+subtitle is their first signal.

---

## Site Structure Decision

**Domain architecture (clarified):**
- `www.si14bm.com` → home of the **Silicon Brained Machines** organization (not Inquiry's site)
- `www.si14bm.com/inquiry` → the Inquiry product website
- The org GitHub Pages (`github.com/siliconbrainedmachines`) should eventually serve `www.si14bm.com/` from a dedicated org repo

**Current reality:** The inquiry repo has `CNAME: www.si14bm.com` in `site/`, which means this repo currently owns the entire domain. The `site/index.html` redirect (`/ → /inquiry/`) is therefore architecturally correct as a stopgap — root visitors land on `/inquiry/`.

The install scripts at `https://www.si14bm.com/inquiry/install.ps1` must stay at that path — it is baked into all documentation.

**Scope of this issue:**
1. Fix the **double DOCTYPE bug** in `site/index.html` — currently two concatenated HTML documents (a 9-line redirect followed by a full copy of the old landing page with `<h1>APE</h1>`). Bots and scrapers see malformed HTML with old APE branding.
2. The redirect itself (`/ → /inquiry/`) is correct — keep it.
3. **Create `github.com/siliconbrainedmachines/siliconbrainedmachines`** — the GitHub org repo that serves `www.si14bm.com/` via GitHub Pages. Content: a minimal `index.html` showing `Silicon Brained Machines` centered with a single link to `www.si14bm.com/inquiry`. Configure GitHub Pages on that repo with custom domain `www.si14bm.com`.
4. **Remove `site/CNAME`** from the inquiry repo. Once the org repo owns `www.si14bm.com`, the inquiry repo should have no CNAME — GitHub Pages will automatically serve it at `www.si14bm.com/inquiry/` (subpath of the org domain). The install scripts at `www.si14bm.com/inquiry/install.ps1` continue to work unchanged..

---

## Inconsistencies Found

### 1. `README.md` (repo root)
| Location | Current | Fix |
|---|---|---|
| H1 | `# Inquiry CLI` | `# Inquiry` |
| Tagline | `Powered by the Finite APE Machine — Analyze. Plan. Execute.` | `Analyze. Plan. Execute.` |
| Section heading | `## What is APE?` | `## What is Inquiry?` |
| Body | "APE treats coding agents..." | "Inquiry treats coding agents..." |
| `iq target get` description | `Deploy APE agent + skills to ~/.copilot` | `Deploy Inquiry agent + skills to ~/.copilot` |

### 2. `code/cli/assets/agents/inquiry.agent.md`
| Location | Current | Fix |
|---|---|---|
| Frontmatter `description` | `'APE — The Finite APE Machine. A strict six-state FSM scheduler...'` | `'Inquiry — Analyze. Plan. Execute. A strict six-state FSM scheduler for structured task delivery.'` |
| H1 heading | `# APE — The Finite APE Machine` | `# Inquiry — Analyze. Plan. Execute.` |
| Line 46 | `` `ape doctor` (all checks must pass) `` | `` `iq doctor` (all checks must pass) `` |
| Line 62 | `` `ape doctor` confirms ape version, git... `` | `` `iq doctor` confirms inquiry version, git... `` |

### 3. `code/vscode/package.json`
| Field | Current | Fix |
|---|---|---|
| `description` | `"Inquiry CLI — structured development through the APE methodology for GitHub Copilot."` | `"Inquiry — Analyze. Plan. Execute. Structured AI-assisted development for GitHub Copilot."` |

### 4. `code/vscode/README.md`
| Location | Current | Fix |
|---|---|---|
| img alt | `APE finite state machine` | `Inquiry finite state machine` |

### 5. `site/index.html`
| Issue | Current | Fix |
|---|---|---|
| Double DOCTYPE bug | Two concatenated HTML documents | Single clean redirect only |

### 6. `site/inquiry/index.html`
| Location | Current | Fix |
|---|---|---|
| Targets section | `APE deploys agent prompts and skills...` | `Inquiry deploys agent prompts and skills...` |
| Windows install note | `deploys APE agents to your AI coding tool` | `deploys Inquiry agents to your AI coding tool` |
| Quickstart comment | `# deploy APE agent + skills to your AI tool` | `# deploy Inquiry agent + skills to your AI tool` |
| FSM img alt | `APE finite state machine diagram` | `Inquiry finite state machine diagram` |
| Card: agents | `Meet the APEs →` | `Meet the agents →` |
| Card: ape-builds | `APE builds APE →` | `Inquiry builds Inquiry →` |
| Evolution aside | `mutations to APE itself` | `mutations to Inquiry itself` |

### 7. `site/inquiry/agents.html`
| Location | Current | Fix |
|---|---|---|
| `<title>` | `Meet the APEs — Finite APE Machine` | `Meet the agents — Inquiry` |
| OG/Twitter title | `Meet the APEs — Finite APE Machine` | `Meet the agents — Inquiry` |
| Meta description | `How the APE roster went from nine to four` | `How the Inquiry agent roster went from nine to four` |
| Nav breadcrumb | `← Finite APE Machine` | `← Inquiry` |
| Intro | `APE started with nine named agents. Two months of building APE with APE...` | `Inquiry started with nine named agents. Two months of building Inquiry with Inquiry...` |
| DARWIN description | `mutations to APE itself — changes to the framework, the transition contract, the other apes` | `mutations to Inquiry itself — changes to the framework, the transition contract, the other agents` |
| Retrospective | `After two months of building APE with APE, the roster collapsed to four` | `After two months of building Inquiry with Inquiry, the roster collapsed to four` |
| Antifragility | `APE got better by running against itself` | `Inquiry got better by running against itself` |
| Card: ape-builds | `APE builds APE →` | `Inquiry builds Inquiry →` |

**Note on "apes" as lowercase noun:** The word "apes" (lowercase) in agent descriptions is intentional lore — each agent IS an ape. These lowercase references are kept. Only "APE" as brand/acronym is removed.

### 8. `site/inquiry/methodology.html`
| Location | Current | Fix |
|---|---|---|
| `<title>` | `Methodology — Finite APE Machine` | `Methodology — Inquiry` |
| OG/Twitter title | `Methodology — Finite APE Machine` | `Methodology — Inquiry` |
| Meta description | `How APE works...` | `How Inquiry works...` |
| Nav breadcrumb | `← Finite APE Machine` | `← Inquiry` |
| Intro | `APE treats your AI coding assistant as a finite state machine...` | `Inquiry treats your AI coding assistant as a finite state machine...` |
| FSM img alt | `APE finite state machine diagram` | `Inquiry finite state machine diagram` |
| DARWIN description | `proposes mutations to APE itself` | `proposes mutations to Inquiry itself` |
| Transition contract | `makes APE reproducible across models: every ape reads the same contract` | `makes Inquiry reproducible across models: every agent reads the same contract` |
| Antifragility | `The thesis APE exists to test` | `The thesis Inquiry exists to test` |
| Link text | `See APE builds APE →` | `See Inquiry builds Inquiry →` |
| Card | `Meet the APEs →` | `Meet the agents →` |

### 9. `code/cli/README.md` — MISSING FILE
The CLI has no README.md. Create a minimal one that:
- Opens with `Inquiry — Analyze. Plan. Execute.`
- Describes what the CLI does (not what the methodology is — the root README does that)
- Lists commands (already in root README, can reference it)
- Points to root README for philosophy/architecture

---

## Out of Scope

- `site/inquiry/ape-builds-ape.html` — this page's name and content deliberately uses "APE builds APE" as a historical/technical term (the bootstrap thesis). It references the methodology BY NAME. Changing it would lose the semantic precision. Deferred.
- `docs/` research and spec files — philosophical/academic documents use APE as a methodology name intentionally.
- `code/cli/assets/skills/` — skill files use APE internally; the FSM states are named correctly.
