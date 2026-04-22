---
id: diagnosis
title: "Diagnosis — Rebrand APE CLI to Inquiry CLI"
date: 2026-04-21
status: active
tags: [rebrand, diagnosis, inquiry, iq]
author: SOCRATES
---

# Diagnosis — Rebrand APE CLI to Inquiry CLI (#111)

## 1. Problem Defined

The CLI tool currently named `ape` implements the APE methodology (Analyze-Plan-Execute) but conflates two distinct identities: the **methodology** (APE — a structured epistemic process) and the **tool** (a CLI binary that enacts that process). Issue #110's Socratic analysis revealed that **inquiry** — not any subcommand noun — is the tool's true identity, grounded in Peirce's logic of inquiry (ABD→DED→IND) and Dewey's definition of inquiry as "the controlled transformation of an indeterminate situation into a determinate one."

The rebrand separates these concerns:
- **APE** remains the methodology name (Analyze-Plan-Execute)
- **Inquiry** becomes the tool name; `iq` is the daily-use alias

This is not a cosmetic rename. It is a **reification of the epistemological insight** that the tool's purpose is inquiry, not aping.

## 2. Decisions Taken

| Decision | Value | Justification |
|----------|-------|---------------|
| Binary name | `inquiry` | Self-documenting; first encounter reveals purpose |
| Alias | `iq` | Daily-use shorthand (`iq` is to `inquiry` as `gh` is to `github`) |
| Alias mechanism | Batch shim (`iq.cmd`) on Windows, symlink on Linux/macOS | Batch shim: no admin privileges, works in all shells (CMD, PowerShell, Git Bash), stays in sync with upgrades. Industry standard (npm, volta, cargo). Symlink on Linux has no privilege issues |
| Config directory | `.inquiry/` | Replaces `.ape/`; hard cutover, no migration |
| Primary noun | `cleanroom` | Controlled environment metaphor; no CLI collision; memorable |
| Logo mark | `iq` | Lighthouse `i` (slab-serif stem, beacon dot with green radial gradient), circular `q` with descender |
| Logo color | `#5CE6B8` on `#0D1117` | Green "Gatsby light" — the beacon that illuminates the indeterminate situation |
| GitHub org | `siliconbrainedmachines` | Corporate umbrella org for all OSS + commercial projects (Silicon Brained Machines, Inc.). Single org maximizes cross-project discoverability |
| Repository | `siliconbrainedmachines/inquiry` | Rename `ccisnedev/finite_ape_machine` → transfer to `siliconbrainedmachines` org |
| Domain | `si14bm.com` | Owned. Logo `Si¹⁴` (periodic table style) anchors the short numeronym |
| VS Code publisher | `siliconbrainedmachines` | Coherent with org; separates project from personal identity (`ccisnedev`) |
| Extension ID | `siliconbrainedmachines.inquiry-vscode` | Replaces `ccisnedev.ape-vscode` |
| Backward compat | None | v0.0.x series; breaking change is the contract |
| Methodology name | APE (unchanged) | Analyze-Plan-Execute; the FSM, agents, philosophy all stay |
| Version | Bump to v0.1.0 | Continuity: repo transfers with full history, existing tags v0.0.1-v0.0.16 preserved |

## 3. Constraints

### Technical
- GitHub repo transfer preserves Git history, issues, PRs, stars — but loses Actions secrets and branch protection rules
- GitHub redirects `ccisnedev/finite_ape_machine` → `siliconbrainedmachines/inquiry` automatically (chain redirect through rename + transfer)
- VS Code Marketplace does not support true extension "replacement" — only `extensionDependencies` + deprecation banner
- Windows file copy for alias means `iq.exe` is a full duplicate (~5-6 MB), not a pointer
- The `dart compile exe` output name is set in build scripts, not in `pubspec.yaml`

### Process
- The repo transfer must happen AFTER all internal URL references are updated but BEFORE publishing the new extension
- The old extension `ccisnedev.ape-vscode` deprecation is a one-time manual publish
- New VS Code Marketplace publisher `siliconbrainedmachines` requires a new Azure DevOps PAT
- GitHub Pages custom domain needs verification after transfer

### Scope
- 50+ files affected across CLI, extension, site, docs, CI, install scripts
- 12 acceptance criteria, ~90 individual checkboxes
- The FSM, agents (SOCRATES, DESCARTES, BASHŌ, DARWIN), and philosophy (Peirce, Dewey) are explicitly OUT of scope — they do not change

## 4. Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| Windows Defender quarantines renamed binary | Release breaks | Re-test Defender workaround with `inquiry.exe` name on `windows-2025` runner |
| Repo transfer loses GitHub Actions secrets | CI fails silently | Recreate `VSCE_PAT` immediately after transfer; run test workflow |
| Install script URL becomes stale during rename window | Users get 404 | Do rename + transfer in quick succession; GitHub redirects cover the gap |
| Old extension users don't see deprecation | Fragmented user base | `extensionDependencies` auto-installs new extension alongside; deprecation banner in Marketplace |
| `siliconbrainedmachines` org name conflict | Cannot create org | Verified available via `gh api` — risk neutralized |
| `si14bm.com` DNS / GitHub Pages setup delays | Site downtime | Domain owned; configure DNS before transfer |
| Asset name mismatch between CI and install scripts | Silent install failure | Single source of truth: matrix in `release.yml` defines names, scripts consume them |

## 5. Scope

### In Scope (this issue)
- CLI binary rename (`ape` → `inquiry` + `iq` alias)
- Config directory rename (`.ape/` → `.inquiry/`)
- Package rename (`ape_cli` → `inquiry_cli`)
- Logo creation (iq mark in 4 contexts: icon, favicon, sidebar, TUI)
- Install scripts update
- CI/CD workflow update
- VS Code extension: publish new `siliconbrainedmachines.inquiry-vscode`
- VS Code extension: deprecate old `ccisnedev.ape-vscode`
- Website update (titles, meta, install URLs, favicon)
- Documentation update (README, specs, architecture, agent/skill files)
- GitHub org creation + repo rename + transfer
- All tests passing with new naming
- Version reset to v0.0.1

### Out of Scope
- FSM states (IDLE, ANALYZE, PLAN, EXECUTE, END, EVOLUTION) — unchanged
- Agent definitions (SOCRATES, DESCARTES, BASHŌ, DARWIN) — unchanged
- Philosophy references (Peirce, Dewey, pragmatism) — unchanged
- Methodology name "APE" — unchanged
- `cleanroom` command implementation — separate issue after rebrand
- `si14bm.com` DNS and GitHub Pages setup — can be done independently
- Migration tooling for existing `.ape/` workspaces — no backward compat in v0.0.x

## 6. Execution Order

```
1. Logo (AC-8)          ← unblocks extension + site
2. CLI rename (AC-1,2,3) ← core code change
3. Tests (AC-11)         ← validate rename
4. Install scripts (AC-4) ← depend on binary names
5. CI/CD (AC-5)          ← depend on asset names
6. Documentation (AC-10)  ← update while URLs still old (easier to test locally)
7. Org + transfer (AC-12) ← all refs already point to new names
8. Website (AC-9)         ← depend on final URLs
9. New extension (AC-6)   ← depend on everything above
10. Deprecate old (AC-7)  ← last step
```

## 7. References

| Document | Location |
|----------|----------|
| Impact surface inventory | [impact-surface.md](impact-surface.md) |
| VS Code deprecation strategy | [vscode-deprecation-strategy.md](vscode-deprecation-strategy.md) |
| Logo design brief | [logo-requirements.md](logo-requirements.md) |
| Detailed acceptance criteria | [acceptance-criteria.md](acceptance-criteria.md) |
| Logo draft (Inkscape) | [iq-logo-draft-v1.svg](iq-logo-draft-v1.svg) |
| Peirce/Dewey research | [docs/research/inquiry/](../../../research/inquiry/) |
| Issue #110 diagnosis (naming) | [docs/research/inquiry/110-rename-primary-ape-subcommand-noun/analyze/diagnosis.md](../../../research/inquiry/110-rename-primary-ape-subcommand-noun/analyze/diagnosis.md) |
| Rebrand vision | [docs/research/inquiry/iq-rebrand-vision.md](../../../research/inquiry/iq-rebrand-vision.md) |
| SWEBOK process enactment tools | [docs/research/swebok/process-enactment-tools.md](../../../research/swebok/process-enactment-tools.md) |
