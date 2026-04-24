---
id: impact-surface
title: "Rebrand Impact Surface — Complete Inventory"
date: 2026-04-21
status: active
tags: [rebrand, inventory, analysis]
author: SOCRATES
---

# Rebrand Impact Surface — Complete Inventory

Analysis of every touchpoint that the rebrand from `ape` → `inquiry`/`iq` affects.

## Naming Convention

| Current | New | Context |
|---------|-----|---------|
| `ape` (binary) | `inquiry` (binary) + `iq` (alias/symlink) | CLI executable |
| `.ape/` | `.inquiry/` | Config directory |
| `ape_cli` | `inquiry_cli` | Dart package name |
| `ape-vscode` | `inquiry-vscode` | VS Code extension ID |
| `ape.exe` | `inquiry.exe` (+ `iq.exe` symlink) | Windows binary |
| `APE` (methodology) | `APE` (**unchanged**) | Analyze-Plan-Execute |

---

## 1. CLI Binary & Build

| File | What Changes |
|------|-------------|
| `code/cli/bin/main.dart` | Comment: "Entry point for the 'ape' CLI" → 'inquiry' |
| `code/cli/lib/ape_cli.dart` | Filename → `inquiry_cli.dart`, function `runApe()` → `runInquiry()` |
| `code/cli/pubspec.yaml` | `name: ape_cli` → `name: inquiry_cli` |
| `code/cli/scripts/build.ps1` | Output binary `ape.exe` → `inquiry.exe`, comments |
| `code/cli/scripts/build.sh` | Output binary `ape` → `inquiry`, comments |

## 2. Config Directory `.ape/` → `.inquiry/`

| File | Occurrences |
|------|-------------|
| `code/cli/lib/modules/global/commands/init.dart` | `.ape/state.yaml`, `.ape/config.yaml`, `.ape/mutations.md`, `.gitignore` entry |
| `code/cli/test/init_command_test.dart` | All test assertions checking `.ape/` paths |
| `code/vscode/src/guard.ts` | `isApeWorkspace()` checks for `.ape/`, binary path `.ape/bin/` |
| `code/vscode/src/commands.ts` | `.ape/config.yaml`, `.ape/mutations.md` |
| `code/vscode/src/extension.ts` | `.ape` folder path |
| `code/cli/lib/targets/linux_platform_ops.dart` | `.ape/bin/` path |

## 3. VS Code Extension

| File | What Changes |
|------|-------------|
| `code/vscode/package.json` | `name: ape-vscode` → `inquiry-vscode`, `displayName: APE` → `Inquiry`, commands `ape.*` → `inquiry.*`, activation event `.ape/` → `.inquiry/` |
| `code/vscode/src/extension.ts` | Command IDs `ape.init` → `inquiry.init`, etc. |
| `code/vscode/src/guard.ts` | Functions: `getApeBinaryPath()`, `isApeInstalled()`, `isApeWorkspace()` |
| `code/vscode/src/commands.ts` | `.ape/` path references |
| `code/vscode/src/installer.ts` | Install URL references `finite_ape_machine`, asset name patterns |
| `code/vscode/README.md` | All "APE" tool references, `@ape` agent name |
| `code/vscode/assets/icon.svg` | Brand icon → new "iq" logo |
| `code/vscode/assets/icon.png` | Rasterized icon → new "iq" logo |
| `code/vscode/assets/sidebar.svg` | SVG text "APE" → "iq" |

### VS Code Marketplace Deprecation Strategy

The current extension `ccisnedev.ape-vscode` must be deprecated, not deleted:
1. Publish a final version of `ape-vscode` with a deprecation notice pointing to `inquiry-vscode`
2. Publish `inquiry-vscode` as a new extension under the same publisher (`ccisnedev`)
3. The old extension shows "Deprecated: This extension has been replaced by Inquiry"

## 4. Install Scripts

| File | What Changes |
|------|-------------|
| `code/cli/scripts/install.ps1` | `$installDir` from `ape` → `inquiry`, asset pattern `ape-windows-x64` → `inquiry-windows-x64`, binary name, PATH messages |
| `code/site/install.ps1` | Same as above (duplicate for web) |
| `code/site/install.sh` | `INSTALL_DIR` from `.ape` → `.inquiry`, asset pattern `ape-linux-x64` → `inquiry-linux-x64`, binary name, alias creation |

### Alias Creation in Install Scripts

New requirement: install scripts must create both `inquiry` and `iq`:
- **Windows:** copy `inquiry.exe` → `iq.exe` in the same bin directory
- **Linux/macOS:** symlink `iq` → `inquiry` in the bin directory

## 5. CI/CD Workflows

| File | What Changes |
|------|-------------|
| `.github/workflows/release.yml` | Asset names: `ape-windows-x64.zip` → `inquiry-windows-x64.zip`, `ape-linux-x64.tar.gz` → `inquiry-linux-x64.tar.gz`, binary names inside archives |
| `.github/workflows/vscode-marketplace.yml` | Extension ID `ccisnedev.ape-vscode` → `ccisnedev.inquiry-vscode` |

## 6. Website

| File | What Changes |
|------|-------------|
| `code/site/index.html` | Title, meta tags, headings, install URLs, badge |
| `code/site/methodology.html` | Title, breadcrumbs, meta tags |
| `code/site/ape-builds-ape.html` | Title, breadcrumbs (content stays — "APE builds APE" is methodology) |
| `code/site/agents.html` | Title, breadcrumbs |
| `code/site/evolution.html` | Title, breadcrumbs |
| `code/site/img/favicon.svg` | SVG icon text "APE" → "iq" |

## 7. Documentation

| File | What Changes |
|------|-------------|
| `README.md` | Title "Finite APE Machine", install URLs, command table (`ape init` → `iq init`), `.ape/` references |
| `docs/architecture.md` | `.ape/` directory references, command examples |
| `docs/spec/ape-cli-spec.md` | Filename → `inquiry-cli-spec.md`, 100+ references to `.ape/` and `ape` commands |
| `docs/spec/finite-ape-machine.md` | Tool name references (methodology name stays) |
| `docs/spec/index.md` | Reference to spec filename |
| `docs/roadmap.md` | Any tool-name references |
| `docs/lore.md` | Tool-name references (methodology stays) |

## 8. Agent & Skill Assets

| File | What Changes |
|------|-------------|
| `code/cli/assets/agents/ape.agent.md` | Filename → `inquiry.agent.md`, YAML `name: ape` → `name: inquiry`, command refs (`ape doctor` → `iq doctor`) |
| `code/cli/assets/skills/issue-start/SKILL.md` | `ape doctor` → `iq doctor` command references |
| `code/cli/assets/skills/issue-end/SKILL.md` | Command references |
| `code/cli/assets/fsm/transition_contract.yaml` | Comment: "APE FSM" (stays — it's the methodology) |

## 9. Logo / Visual Assets

Three new "iq" logos needed:

| Asset | Purpose | Format | Size |
|-------|---------|--------|------|
| VS Code icon | Extension icon in Marketplace and sidebar | SVG + PNG (128×128) | Small mark |
| Website favicon | Browser tab icon | SVG | 16×16 logical |
| CLI TUI banner | ASCII art in terminal output | Text | N/A |
| VS Code sidebar icon | Activity bar icon | SVG | 24×24 logical |

## 10. GitHub Organization + Repository

New org + rename + transfer:

| Step | Action | Result |
|------|--------|--------|
| 1 | Create org `siliconbrainedmachines` on GitHub | New org exists, owner=`ccisnedev`, email=`ops@si14bm.com` |
| 2 | Rename repo `ccisnedev/finite_ape_machine` → `ccisnedev/inquiry` | Redirect active |
| 3 | Transfer `ccisnedev/inquiry` → `siliconbrainedmachines/inquiry` | Final location |

Post-transfer:
- Recreate `VSCE_PAT` secret (lost during transfer)
- Verify GitHub Pages / custom domain
- Update local clone remote URL
- All install scripts, CI, `installer.ts` must reference `siliconbrainedmachines/inquiry`

### VS Code Marketplace Publisher

New publisher `siliconbrainedmachines` — coherent with org name:
- Extension ID: `siliconbrainedmachines.inquiry-vscode`
- Requires new PAT from Azure DevOps (All accessible organizations, Marketplace Manage scope)
- Old extension `ccisnedev.ape-vscode` gets deprecation update under old publisher

## 11. Dart Code Internal Names

| Symbol | Location | New Name |
|--------|----------|----------|
| `runApe()` | `lib/ape_cli.dart` | `runInquiry()` |
| `package:ape_cli` | All imports | `package:inquiry_cli` |
| `ape_cli.dart` | Filename | `inquiry_cli.dart` |
| `getApeBinaryPath()` | VS Code `guard.ts` | `getInquiryBinaryPath()` |
| `isApeInstalled()` | VS Code `guard.ts` | `isInquiryInstalled()` |
| `isApeWorkspace()` | VS Code `guard.ts` | `isInquiryWorkspace()` |
