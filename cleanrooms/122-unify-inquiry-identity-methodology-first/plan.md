# Plan — Unify Inquiry Identity (Methodology-First)

**Issue:** #122  
**Branch:** `122-unify-inquiry-identity-methodology-first`

---

## Group A — Text edits in existing files

### A1. `README.md` (repo root)

- [ ] Change H1 from `# Inquiry CLI` to `# Inquiry`
- [ ] Change tagline from `Powered by the Finite APE Machine — Analyze. Plan. Execute.` to `Analyze. Plan. Execute.`
- [ ] Change section heading `## What is APE?` to `## What is Inquiry?`
- [ ] Change body opening sentence from `APE treats coding agents ("apes") as states...` to `Inquiry treats coding agents ("apes") as states...`
- [ ] Change `iq target get` table description from `Deploy APE agent + skills to ~/.copilot` to `Deploy Inquiry agent + skills to ~/.copilot`
- [ ] Change quick start comment in code block from `# deploy APE agent + skills to ~/.copilot` to `# deploy Inquiry agent + skills to ~/.copilot`
- [ ] Change Architecture references: `APE's runbook` → `Inquiry's runbook` and `APE deploys` → `Inquiry deploys`

### A2. `code/cli/assets/agents/inquiry.agent.md`

- [ ] Change frontmatter `description` from `'APE — The Finite APE Machine. A strict six-state FSM scheduler...'` to `'Inquiry — Analyze. Plan. Execute. A strict six-state FSM scheduler...'`
- [ ] Change H1 from `# APE — The Finite APE Machine` to `# Inquiry — Analyze. Plan. Execute.`
- [ ] Change line 46: `` `ape doctor` (all checks must pass) `` to `` `iq doctor` (all checks must pass) ``
- [ ] Change line 62: `` `ape doctor` confirms ape version, git, gh, gh auth, and gh copilot are available. `` to `` `iq doctor` confirms inquiry version, git, gh, gh auth, and gh copilot are available. ``

### A3. `code/vscode/package.json`

- [ ] Change `description` from `"Inquiry CLI — structured development through the APE methodology for GitHub Copilot."` to `"Inquiry — Analyze. Plan. Execute. Structured AI-assisted development for GitHub Copilot."`

### A4. `code/vscode/README.md`

- [ ] Change img alt text from `APE finite state machine` to `Inquiry finite state machine`

### A5. `site/index.html` — double DOCTYPE bug

- [ ] Truncate `site/index.html` to contain only the 9-line redirect HTML; remove all content after the closing `</html>` of the redirect block

### A6. `site/inquiry/index.html`

- [ ] Change Targets section paragraph: `APE deploys agent prompts and skills...` → `Inquiry deploys agent prompts and skills...`
- [ ] Change Windows install note: `deploys APE agents to your AI coding tool` → `deploys Inquiry agents to your AI coding tool`
- [ ] Change quickstart comment: `# deploy APE agent + skills to your AI tool (Copilot today)` → `# deploy Inquiry agent + skills to your AI tool (Copilot today)`
- [ ] Change FSM img alt: `APE finite state machine diagram showing...` → `Inquiry finite state machine diagram showing...`
- [ ] Change "Go deeper" card link text: `Meet the APEs →` → `Meet the agents →`
- [ ] Change "Go deeper" card link text: `APE builds APE →` → `Inquiry builds Inquiry →`
- [ ] Change Evolution aside: `mutations to APE itself` → `mutations to Inquiry itself`

### A7. `site/inquiry/agents.html`

- [ ] Change `<title>` from `Meet the APEs — Finite APE Machine` to `Meet the agents — Inquiry`
- [ ] Change all OG/Twitter meta `content` titles: `Meet the APEs — Finite APE Machine` → `Meet the agents — Inquiry`
- [ ] Change meta description: `How the APE roster went from nine to four.` → `How the Inquiry agent roster went from nine to four.`
- [ ] Change nav breadcrumb: `← Finite APE Machine` (with `span.ape` around APE) → `← Inquiry` (plain text, no span)
- [ ] Change intro paragraph: `APE started with nine named agents. Two months of building APE with APE collapsed the roster to four.` → `Inquiry started with nine named agents. Two months of building Inquiry with Inquiry collapsed the roster to four.`
- [ ] Change DARWIN description: `mutations to APE itself — changes to the framework, the transition contract, the other apes` → `mutations to Inquiry itself — changes to the framework, the transition contract, the other agents`
- [ ] Change retrospective paragraph: `After two months of building APE with APE, the roster collapsed to four.` → `After two months of building Inquiry with Inquiry, the roster collapsed to four.`
- [ ] Change antifragility sentence: `APE got better by running against itself` → `Inquiry got better by running against itself`
- [ ] Change "Go deeper" card: `APE builds APE →` → `Inquiry builds Inquiry →`

### A8. `site/inquiry/methodology.html`

- [ ] Change `<title>` from `Methodology — Finite APE Machine` to `Methodology — Inquiry`
- [ ] Change all OG/Twitter meta `content` titles: `Methodology — Finite APE Machine` → `Methodology — Inquiry`
- [ ] Change meta description: `How APE works:` → `How Inquiry works:`
- [ ] Change nav breadcrumb: `← Finite APE Machine` → `← Inquiry`
- [ ] Change intro sentence: `APE treats your AI coding assistant as a finite state machine...` → `Inquiry treats your AI coding assistant as a finite state machine...`
- [ ] Change FSM img alt: `APE finite state machine diagram` → `Inquiry finite state machine diagram`
- [ ] Change DARWIN entry: `proposes mutations to APE itself` → `proposes mutations to Inquiry itself`
- [ ] Change transition contract sentence: `makes APE reproducible across models: every ape reads...` → `makes Inquiry reproducible across models: every agent reads...`
- [ ] Change antifragility heading/sentence: `The thesis APE exists to test` → `The thesis Inquiry exists to test`
- [ ] Change link text: `See APE builds APE →` → `See Inquiry builds Inquiry →`
- [ ] Change card link text: `Meet the APEs →` → `Meet the agents →`

---

## Group B — New file

### B1. `code/cli/README.md`

- [ ] Create `code/cli/README.md` with the following content:

```markdown
# Inquiry CLI

**Analyze. Plan. Execute.**

The `iq` CLI enforces the Inquiry methodology in your repository — scaffolding the FSM state, deploying agents to your AI tool, and validating transitions.

For the full methodology, architecture, and philosophy, see the [root README](../../README.md).

## Install

**Windows:**
```powershell
irm https://www.si14bm.com/inquiry/install.ps1 | iex
```

**Linux:**
```bash
curl -fsSL https://www.si14bm.com/inquiry/install.sh | bash
```

## Commands

| Command | Purpose |
|---|---|
| `iq` | TUI banner with current FSM state |
| `iq init` | Scaffold `.inquiry/` (state.yaml, config.yaml, mutations.md) |
| `iq doctor` | Verify prerequisites: `inquiry`, `git`, `gh`, `gh auth` |
| `iq version` | Print CLI version |
| `iq upgrade` | Download and install latest release |
| `iq uninstall` | Remove `inquiry` binary and deployed assets |
| `iq target get` | Deploy Inquiry agent and skills to active AI tool |
| `iq target clean` | Remove deployed Inquiry files from all known targets |
| `iq state transition --event <e>` | Execute a deterministic FSM transition |
```

---

## Group C — Org GitHub Pages infrastructure

### C1. Create org repo

- [ ] Run `gh repo create siliconbrainedmachines/siliconbrainedmachines --public` to create the special org GitHub Pages repo

### C2. Create `index.html` in org repo

- [ ] Clone or init the org repo locally and create `index.html` with the minimal org homepage (Silicon Brained Machines → `https://www.si14bm.com/inquiry/`)

### C3. Create `CNAME` in org repo

- [ ] Create `CNAME` file in the org repo root with content `www.si14bm.com`

### C4. Enable GitHub Pages on org repo

- [ ] Enable GitHub Pages via `gh api` or the GitHub UI: source = main branch, root directory

### C5. Remove `site/CNAME` from inquiry repo

- [ ] Delete `site/CNAME` from this repo — CNAME ownership transfers to the org repo

### C6. Push org repo and confirm Pages activation

- [ ] Commit and push `index.html` + `CNAME` to `siliconbrainedmachines/siliconbrainedmachines` main branch
- [ ] Confirm GitHub Pages is active on the org repo (green status in repo settings)

---

## Verification

- [ ] `site/index.html` contains exactly one `<!DOCTYPE html>` declaration (no duplicate content after `</html>`)
- [ ] `README.md` H1 is `# Inquiry` and tagline is `Analyze. Plan. Execute.` — no "APE" in title or subtitle
- [ ] `code/cli/assets/agents/inquiry.agent.md` frontmatter description starts with `Inquiry — Analyze. Plan. Execute.`
- [ ] `code/vscode/package.json` description reads `Inquiry — Analyze. Plan. Execute. Structured AI-assisted development for GitHub Copilot.`
- [ ] `site/inquiry/agents.html` `<title>` is `Meet the agents — Inquiry`
- [ ] `site/inquiry/methodology.html` `<title>` is `Methodology — Inquiry`
- [ ] `code/cli/README.md` exists and contains the `iq target get` row in the commands table
- [ ] `site/CNAME` is deleted from this repo
- [ ] `siliconbrainedmachines/siliconbrainedmachines` repo exists and is public
- [ ] `www.si14bm.com` resolves to the org homepage (after DNS propagation)
- [ ] `www.si14bm.com/inquiry/` serves the Inquiry landing page
- [ ] `www.si14bm.com/inquiry/install.ps1` still resolves (install script unaffected)
- [ ] `iq doctor` passes locally
- [ ] After `iq target get`, the Copilot agent description shows `Inquiry — Analyze. Plan. Execute.`
- [ ] `site/inquiry/ape-builds-ape.html` is untouched
- [ ] Lowercase `apes` as a noun in `agents.html` body text is preserved

---

## Constraints

- Do NOT edit `site/inquiry/ape-builds-ape.html` — "APE builds APE" is a deliberate historical/technical term
- Lowercase `apes` (individual agents as a noun) in `agents.html` body text is intentional lore — do not capitalise or replace
- Group C steps may take minutes to propagate via DNS — verify after deployment settles
