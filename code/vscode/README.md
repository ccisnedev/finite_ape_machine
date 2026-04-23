# Inquiry

**Analyze. Plan. Execute.**

> Select **@inquiry** as your GitHub Copilot custom agent.
> Every task follows a strict cycle: **ANALYZE → PLAN → EXECUTE → END**.
> No freestyling. No hallucinated plans. Structure from analysis to PR.

This README is the extension's public entry surface. For the canonical repository documentation map, start at [../docs/index.md](../docs/index.md).

---

## How it works

![Inquiry finite state machine](https://raw.githubusercontent.com/siliconbrainedmachines/inquiry/main/code/site/img/fsm.png)

| Phase | What happens | Output |
|-------|-------------|--------|
| **ANALYZE** | Questions, challenges assumptions, clarifies scope | `diagnosis.md` |
| **PLAN** | Decomposes into checkable steps with tests | `plan.md` |
| **EXECUTE** | Implements exactly what the plan says | code + commits |

The extension is a lightweight integration surface around the Inquiry CLI and the Inquiry custom agent for GitHub Copilot. The canonical explanations of Inquiry, APE, the Finite APE Machine, and Thinking Tools live in the repository documentation, not in this README.

---

## Quick start

1. Install from the [Marketplace](https://marketplace.visualstudio.com/items?itemName=siliconbrainedmachines.inquiry-vscode)
2. `Ctrl+Shift+P` → **Inquiry: Init**
3. The extension installs the CLI if missing, runs `iq init`, creates `.inquiry/`
4. Open Copilot Chat → select **@inquiry** → describe your task

That's it. The Inquiry agent takes over inside Copilot Chat: analysis first, then plan, then execute.

---

## Commands

| Command | What it does |
|---------|-------------|
| `Inquiry: Init` | Install CLI + scaffold `.inquiry/` in your workspace |
| `Inquiry: Toggle Evolution` | Enable/disable DARWIN's process improvement cycle |
| `Inquiry: Add Mutation Note` | Record an observation for DARWIN to evaluate |

---

## Status bar

The status bar shows the current FSM phase in real time:

**IDLE** · **ANALYZE** · **PLAN** · **EXECUTE** · **END** · **EVOLUTION**

---

## Requirements

- VS Code ≥ 1.85
- Windows or Linux
- GitHub Copilot (required) — Inquiry ships as a custom agent

---

## Links

- [Website](https://www.si14bm.com/inquiry/) · [GitHub](https://github.com/siliconbrainedmachines/inquiry) · [Issues](https://github.com/siliconbrainedmachines/inquiry/issues)
- [Docs map](https://github.com/siliconbrainedmachines/inquiry/blob/main/docs/index.md) · [Architecture](https://github.com/siliconbrainedmachines/inquiry/blob/main/docs/architecture.md) · [Finite APE Machine spec](https://github.com/siliconbrainedmachines/inquiry/blob/main/docs/spec/finite-ape-machine.md)

For the full methodology, see [si14bm.com/inquiry](https://www.si14bm.com/inquiry/).

MIT © 2026 Cristian Cisneros
