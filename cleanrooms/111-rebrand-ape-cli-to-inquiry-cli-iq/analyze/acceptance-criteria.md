---
id: acceptance-criteria
title: "Detailed Acceptance Criteria for #111"
date: 2026-04-21
status: active
tags: [rebrand, acceptance-criteria, plan]
author: SOCRATES
---

# Detailed Acceptance Criteria for #111

Granular, testable acceptance criteria derived from impact surface analysis + SOCRATES review.

## Key Decisions

| Decision | Value |
|----------|-------|
| GitHub org | `siliconbrainedmachines` |
| Domain | `si14bm.com` |
| Repo | `siliconbrainedmachines/inquiry` |
| VS Code publisher | `siliconbrainedmachines` |
| Extension ID | `siliconbrainedmachines.inquiry-vscode` |
| Binary | `inquiry` (primary) |
| Alias | `iq` (copy on Windows, symlink on Linux/macOS) |
| Config dir | `.inquiry/` |
| Logo mark | `iq` (lighthouse/typewriter, green Gatsby light) |
| Backward compat | None (v0.0.x, breaking change accepted) |
| Methodology name | `APE` (unchanged — Analyze-Plan-Execute) |

---

## AC-1: CLI Binary Rename

- [ ] `dart compile exe` produces `inquiry.exe` (Windows) / `inquiry` (Linux)
- [ ] `build.ps1` outputs `build/bin/inquiry.exe`
- [ ] `build.sh` outputs `build/bin/inquiry`
- [ ] `pubspec.yaml` name changed to `inquiry_cli`
- [ ] `lib/ape_cli.dart` renamed to `lib/inquiry_cli.dart`
- [ ] `runApe()` renamed to `runInquiry()`
- [ ] All internal `package:ape_cli` imports updated to `package:inquiry_cli`
- [ ] `bin/main.dart` comment updated
- [ ] `upgrade.dart` User-Agent changed: `ape-cli/$version` → `inquiry-cli/$version`
- [ ] All Dart comments referencing "ape" as tool name updated to "inquiry"/"iq"

## AC-2: Alias Creation

- [ ] Install scripts create both `inquiry` and `iq` entry points
- [ ] Windows: `inquiry.exe` + `iq.cmd` (batch shim: `@"%~dp0inquiry.exe" %*`) in bin directory
- [ ] Linux/macOS: `inquiry` + `iq` (symlink → inquiry) in bin directory
- [ ] Both `inquiry --version` and `iq --version` work after install

## AC-3: Config Directory

- [ ] `iq init` creates `.inquiry/` (not `.ape/`)
- [ ] `.inquiry/state.yaml`, `.inquiry/config.yaml`, `.inquiry/mutations.md` created
- [ ] `.gitignore` entry is `.inquiry/` (not `.ape/`)
- [ ] All Dart code references `.inquiry/` path
- [ ] All tests assert `.inquiry/` paths
- [ ] `init_command_test.dart` updated for `.inquiry/`

## AC-4: Install Scripts

- [ ] `code/cli/scripts/install.ps1`: installs to `$LOCALAPPDATA\inquiry\bin\`
- [ ] `code/site/install.ps1`: same as above
- [ ] `code/site/install.sh`: installs to `$HOME/.inquiry/bin/`
- [ ] Asset pattern: `inquiry-windows-x64.zip`, `inquiry-linux-x64.tar.gz`
- [ ] Windows scripts create `iq.exe` via file copy after installing `inquiry.exe`
- [ ] Linux/macOS scripts create `iq` via symlink after installing `inquiry`
- [ ] Success messages reference "Inquiry CLI" (not "APE CLI")
- [ ] Commands shown post-install: `iq doctor`, `iq init`, `iq target get`
- [ ] Repo URL updated to `siliconbrainedmachines/inquiry`

## AC-5: CI/CD Release Workflow

- [ ] `.github/workflows/release.yml` produces `inquiry-windows-x64.zip` containing `inquiry.exe`
- [ ] `.github/workflows/release.yml` produces `inquiry-linux-x64.tar.gz` containing `inquiry`
- [ ] Dart compile step outputs correct binary name
- [ ] Release asset upload uses new names
- [ ] Windows Defender workaround re-tested with renamed binary
- [ ] Repo reference updated to `siliconbrainedmachines/inquiry`

## AC-6: VS Code Extension — New (inquiry-vscode)

- [ ] New publisher `siliconbrainedmachines` created on VS Code Marketplace
- [ ] New extension ID: `siliconbrainedmachines.inquiry-vscode`
- [ ] Display name: `Inquiry`
- [ ] Commands prefixed `inquiry.*`: `inquiry.init`, `inquiry.toggleEvolution`, `inquiry.addMutation`
- [ ] Activation event: `workspaceContains:.inquiry/`
- [ ] `guard.ts` functions renamed: `getInquiryBinaryPath()`, `isInquiryInstalled()`, `isInquiryWorkspace()`
- [ ] `guard.ts` paths updated: `.inquiry/bin/inquiry` (Linux), `inquiry\bin\inquiry.exe` (Windows)
- [ ] `installer.ts` URL updated to `siliconbrainedmachines/inquiry` repo
- [ ] `installer.ts` asset patterns: `inquiry-windows-x64`, `inquiry-linux-x64`
- [ ] Extension icon is the new "iq" mark (SVG + PNG)
- [ ] Sidebar icon is the new "iq" mark (monochrome SVG)
- [ ] README.md describes Inquiry, not APE
- [ ] Published to VS Code Marketplace as `siliconbrainedmachines.inquiry-vscode`
- [ ] New PAT created for publisher `siliconbrainedmachines`
- [ ] GitHub secret `VSCE_PAT` updated with new PAT

## AC-7: VS Code Extension — Deprecate Old (ape-vscode)

- [ ] Final version of `ccisnedev.ape-vscode` published with:
  - Display name: `APE (Deprecated — use Inquiry)`
  - Description: "DEPRECATED: Replaced by Inquiry (siliconbrainedmachines.inquiry-vscode)"
  - `extensionDependencies`: `["siliconbrainedmachines.inquiry-vscode"]`
  - All commands and activation events removed (empty shell)
  - README replaced with deprecation notice + link to Inquiry
- [ ] Marketplace page shows deprecation banner
- [ ] CI workflow `vscode-marketplace.yml` updated to publish `inquiry-vscode` under `siliconbrainedmachines`

## AC-8: Logo — iq Mark

- [ ] `code/vscode/assets/icon.svg` — "iq" lighthouse/typewriter icon, dark bg, green Gatsby light
- [ ] `code/vscode/assets/icon.png` — rasterized 128×128 from SVG
- [ ] `code/vscode/assets/sidebar.svg` — monochrome "iq" mark for activity bar
- [ ] `code/site/img/favicon.svg` — "iq" favicon (full `iq`, not just `i`)
- [ ] CLI TUI banner updated with "iq" / "Inquiry" branding
- [ ] Design: `i` as lighthouse (slab-serif stem, beacon dot with radial gradient), `q` with circular bowl and descender, green `#5CE6B8` accent on `#0D1117` dark background

## AC-9: Website

- [ ] `index.html` title updated to reflect Inquiry branding
- [ ] `index.html` meta tags (description, og:description, twitter:description) updated
- [ ] `index.html` install commands use new URLs pointing to `siliconbrainedmachines/inquiry`
- [ ] `methodology.html` breadcrumbs and title updated
- [ ] `agents.html` breadcrumbs and title updated
- [ ] `evolution.html` breadcrumbs and title updated
- [ ] `ape-builds-ape.html` — content stays (methodology reference), breadcrumbs updated
- [ ] Favicon reference points to new "iq" favicon
- [ ] Badge version updated
- [ ] Site domain: evaluate migration to `si14bm.com` (or keep `ccisne.dev` with redirect)

## AC-10: Documentation

- [ ] `README.md` — title, install section, command table (`iq init`, `iq doctor`), `.inquiry/` references
- [ ] `docs/architecture.md` — `.inquiry/` references, command examples
- [ ] `docs/spec/ape-cli-spec.md` → rename to `inquiry-cli-spec.md`, update all `.ape/` → `.inquiry/`, all `ape` → `iq` commands
- [ ] `docs/spec/index.md` — reference updated filename
- [ ] `docs/roadmap.md` — tool name references
- [ ] `docs/lore.md` — tool name references (methodology stays as APE)
- [ ] Agent file `ape.agent.md` → `inquiry.agent.md`, YAML name + command references
- [ ] Skill files: command references updated (`ape doctor` → `iq doctor`)
- [ ] `upgrade.dart`, `platform_ops.dart` comments referencing "ape" as tool

## AC-11: Tests

- [ ] All existing Dart tests pass with new naming
- [ ] `init_command_test.dart` — `.inquiry/` paths
- [ ] `scaffold_test.dart` — if references `.ape/`
- [ ] `doctor_test.dart` — binary name checks
- [ ] `state_transition_test.dart` — no naming dependency expected
- [ ] `fsm_contract_test.dart` — no naming dependency expected
- [ ] `target_commands_test.dart` — agent file references (`inquiry.agent.md`)
- [ ] `assets_test.dart` — asset file references
- [ ] VS Code tests: `guard.ts` tests, `installer.ts` tests
- [ ] `dart test` passes (all green)
- [ ] `npm test` (vscode) passes

## AC-12: GitHub Org + Repo Transfer

### Step 1: Create org
- [x] Create GitHub org `siliconbrainedmachines` on GitHub
- [x] Set org email to `ccisnedev@gmail.com`
- [x] Add user `ccisnedev` as owner
- [ ] Set org avatar to `Si¹⁴` logo

### Step 2: Rename repo
- [ ] Rename `ccisnedev/finite_ape_machine` → `ccisnedev/inquiry`
- [ ] Verify redirect: `ccisnedev/finite_ape_machine` → `ccisnedev/inquiry`

### Step 3: Transfer repo
- [ ] Transfer `ccisnedev/inquiry` → `siliconbrainedmachines/inquiry`
- [ ] Verify redirect chain: `ccisnedev/finite_ape_machine` → `siliconbrainedmachines/inquiry`
- [ ] Update local clone: `git remote set-url origin https://github.com/siliconbrainedmachines/inquiry.git`

### Step 4: Post-transfer setup
- [ ] Recreate GitHub Actions secret `VSCE_PAT` (lost during transfer)
- [ ] Verify GitHub Pages and custom domain (`si14bm.com` or subdomain like `inquiry.si14bm.com`)
- [ ] Verify CI workflows trigger correctly
- [ ] GitHub repo About/description updated: "Inquiry CLI — structured development through the APE methodology"
- [ ] All install scripts, CI, `installer.ts` reference `siliconbrainedmachines/inquiry`

---

## Execution Order

1. **Logo** (AC-8) — unblocks extension and site work
2. **CLI rename** (AC-1, AC-2, AC-3) — core code change
3. **Tests** (AC-11) — validate core change
4. **Install scripts** (AC-4) — depend on binary names
5. **CI/CD** (AC-5) — depend on binary + asset names
6. **Documentation** (AC-10) — update all docs while URLs are still old (easier to test)
7. **Org + repo transfer** (AC-12) — rename + transfer (all internal refs already updated)
8. **Website** (AC-9) — depend on logo + final URLs
9. **New VS Code extension** (AC-6) — depend on CLI + logo + final repo URL + new publisher
10. **Deprecate old extension** (AC-7) — last, after new is published and verified

### SOCRATES observations incorporated

- AC-1: Added User-Agent string and Dart comments audit
- AC-2: Specified copy (Windows) vs symlink (Linux) explicitly
- AC-4: Added repo URL update and alias creation details
- AC-5: Added Defender workaround re-test
- AC-6: Changed publisher from `ccisnedev` to `siliconbrainedmachines`, added PAT/secret setup
- AC-7: Updated deprecation to point to `siliconbrainedmachines.inquiry-vscode`
- AC-8: Locked design decisions (lighthouse, Gatsby green, full `iq`)
- AC-9: Added domain evaluation
- AC-12: Expanded to 4-step process (create org → rename → transfer → post-transfer)
- Removed AC-13 (backward compatibility) — breaking change accepted in v0.0.x
