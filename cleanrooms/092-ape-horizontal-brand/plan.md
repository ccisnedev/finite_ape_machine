---
id: plan
title: "Plan: Adopt Horizontal APE brand for site + VS Code extension"
date: 2026-04-19
status: done
tags: [brand, icons, favicon, vscode, marketplace]
author: descartes
---

# Plan: Horizontal APE brand adoption

## Summary

`code/site/icons.html` presented three candidate directions for the APE brand mark. Direction 1 — **Horizontal APE** — is selected. This issue consolidates the brand (`APE` wordmark in JetBrains Mono 700, red on navy with a soft radial glow) into canonical assets and rolls it out across every surface.

Scope: site favicons, VS Code Marketplace icon, VS Code sidebar glyph.

---

## Assets

| File | Purpose | Size |
|------|---------|------|
| `code/site/img/favicon.svg` | Site favicon, single source of truth | 128×128 viewBox |
| `code/vscode/assets/icon.svg` | VS Code brand source | 128×128 viewBox |
| `code/vscode/assets/icon.png` | Marketplace tile (rasterized from SVG) | 128×128 PNG |
| `code/vscode/assets/sidebar.svg` | Activity-bar glyph, `currentColor` for theme tinting | 24×24 viewBox |

---

## Phase 1 — Canonical assets

- [x] 1.1 Write `code/site/img/favicon.svg` — rounded-square tile, radial red glow, "APE" in JetBrains Mono 700 size 48, `letter-spacing: -1`, fill `#ef4444`.
- [x] 1.2 Copy the same SVG to `code/vscode/assets/icon.svg` (same brand, one source truth).
- [x] 1.3 Rasterize to `code/vscode/assets/icon.png` at 128×128 via `@resvg/resvg-js` (WASM, no native build tools).
- [x] 1.4 Rewrite `code/vscode/assets/sidebar.svg` — plain "APE" text, JetBrains Mono 700 size 10, `letter-spacing: -0.5`, `fill="currentColor"`.

## Phase 2 — Site integration

- [x] 2.1 Replace the inline data-URI favicon (just a red "A") in 5 HTMLs with `<link rel="icon" type="image/svg+xml" href="img/favicon.svg">`:
  - `index.html`
  - `methodology.html`
  - `ape-builds-ape.html`
  - `agents.html`
  - `evolution.html`
- [x] 2.2 Delete `code/site/icons.html` — decision page served its purpose.

## Phase 3 — VS Code extension

- [x] 3.1 Bump version `0.0.3` → `0.0.4` in `code/vscode/package.json`.
- [x] 3.2 Add CHANGELOG entry under `[0.0.4]`.
- [x] 3.3 Remove legacy `ape-vscode-0.0.1.vsix` artifact.

Out of scope (deferred): registering `sidebar.svg` via `contributes.viewsContainers.activitybar` — the asset is in place but no activity-bar view is wired yet. That can be a separate ticket once a view exists to contain.

## Phase 4 — Unrelated fix included in scope

- [x] 4.1 Add `<span class="badge">v0.0.14</span>` to `code/site/index.html` hero — required so CLI tests that assert the published version string keep passing. Bundled here to avoid a trivial one-line PR.

---

## Verification

- Browser tab shows horizontal "APE" wordmark on all 5 site pages.
- VS Code Extensions panel shows new Marketplace tile icon after publish.
- `assets/icon.png` is a clean 128×128 raster with red "APE" on navy + glow.
- CLI version-string test keeps passing against the site's badge.
