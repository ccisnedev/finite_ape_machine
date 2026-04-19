# APE — VS Code Extension

**Finite-state methodology for AI-assisted development — now in your editor.**

[![Visual Studio Marketplace](https://img.shields.io/visual-studio-marketplace/v/ccisnedev.ape-vscode?color=brightgreen&label=Marketplace)](https://marketplace.visualstudio.com/items?itemName=ccisnedev.ape-vscode)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

---

## ✨ Overview

APE (Autonomous Programming Engine) is a strict six-state FSM that structures AI-assisted development: **IDLE → ANALYZE → PLAN → EXECUTE → END → EVOLUTION**.

This extension brings APE's lifecycle into VS Code — no CLI execution needed. It reads and writes `.ape/` files directly.

---

## 🧩 Features

| Feature | Description |
|---------|-------------|
| 📊 **Status Bar** | Live display of the current APE state with phase-specific icons |
| 🔄 **Toggle Evolution** | Enable/disable the EVOLUTION phase via `.ape/config.yaml` |
| 📝 **Add Mutation Note** | Append observations to `.ape/mutations.md` from the Command Palette |
| ⚡ **Auto-activation** | Extension activates automatically when `.ape/` exists in the workspace |

---

## 🚀 Quick Start

1. Install the extension from the [VS Code Marketplace](https://marketplace.visualstudio.com/items?itemName=ccisnedev.ape-vscode)
2. Open a workspace that contains a `.ape/` directory
3. The status bar shows the current FSM state
4. Use `Ctrl+Shift+P` → **APE: Toggle Evolution** or **APE: Add Mutation Note**

---

## 💾 Commands

| Command | Action |
|---------|--------|
| **APE: Toggle Evolution** | Flip `evolution.enabled` in `.ape/config.yaml` |
| **APE: Add Mutation Note** | Prompt for text → append to `.ape/mutations.md` |

---

## 📊 Status Bar Icons

| State | Icon |
|-------|------|
| IDLE | `$(circle-outline)` |
| ANALYZE | `$(search)` |
| PLAN | `$(list-ordered)` |
| EXECUTE | `$(rocket)` |
| END | `$(git-pull-request)` |
| EVOLUTION | `$(sparkle)` |

---

## Requirements

- VS Code ≥ 1.85
- A workspace with a `.ape/` directory (created by the [APE CLI](https://github.com/ccisne-dev/finite_ape_machine))

---

## 🔭 Roadmap

- CLI integration (`ape` command execution from VS Code)
- Tree view for `.ape/` directory contents
- state.yaml editing via UI
- Multi-root workspace support

---

## 🧾 License

MIT © 2026 Cristian Cisneros

---

## 🧩 Links

- 🧠 APE CLI: [ccisne-dev/finite_ape_machine](https://github.com/ccisne-dev/finite_ape_machine)
- 💬 Report issues: [GitHub Issues](https://github.com/ccisne-dev/finite_ape_machine/issues)
