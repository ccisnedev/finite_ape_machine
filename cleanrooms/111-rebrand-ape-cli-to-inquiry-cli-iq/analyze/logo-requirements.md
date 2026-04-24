---
id: logo-requirements
title: "Logo Requirements — iq Mark"
date: 2026-04-21
status: active
tags: [logo, branding, design]
author: SOCRATES
---

# Logo Requirements — iq Mark

## Design Brief

The logo is the two-letter mark `iq`. It must work across four contexts with different constraints.

## Contexts

### 1. VS Code Extension Icon (128×128 PNG + SVG)

- Displayed in: Marketplace listing, extension sidebar, install dialog
- Constraints: must be legible at 16×16 in the extension list, clear at 128×128 in the Marketplace
- Background: VS Code shows icons on both light and dark backgrounds
- Current icon: horizontal "APE" text in monospace — see `code/vscode/assets/icon.svg`

### 2. Website Favicon (SVG, 16×16 logical)

- Displayed in: browser tab, bookmarks bar
- Constraints: must be recognizable at favicon size (16×16 CSS pixels, possibly 32×32 physical)
- Current: `code/site/img/favicon.svg` with "APE" text

### 3. VS Code Sidebar Icon (24×24 SVG)

- Displayed in: activity bar (left sidebar)
- Constraints: monochrome, must match VS Code's icon style (single color, no fills)
- Current: `code/vscode/assets/sidebar.svg` with "APE" text

### 4. CLI TUI Banner (ASCII text)

- Displayed in: terminal output when running `iq` with no args or `iq --help`
- Constraints: monospace font, should be compact (3-5 lines max)
- Current banner: to be determined (check current TUI output)

## Design Constraints

- The mark is `iq`, lowercase
- Must work in monochrome (sidebar) and color (marketplace, favicon)
- The `i` and `q` should be visually balanced — the `q` descender gives natural asymmetry
- No tagline in the icon — the icon is just the mark
- Color palette: to be defined (current APE uses a green accent)

## Files to Create/Replace

| File | Format | Purpose |
|------|--------|---------|
| `code/vscode/assets/icon.svg` | SVG | VS Code extension icon (vector source) |
| `code/vscode/assets/icon.png` | PNG 128×128 | VS Code extension icon (rasterized) |
| `code/vscode/assets/sidebar.svg` | SVG | VS Code activity bar icon |
| `code/site/img/favicon.svg` | SVG | Website favicon |
| TUI banner in Dart code | ASCII text | CLI help/banner output |

## Open Questions

- Color: keep green accent from current branding, or new palette?
- Typography: geometric sans (like the current APE), monospace, or custom letterforms?
- Should the favicon be just `i` at 16×16 (legibility) or full `iq`?
