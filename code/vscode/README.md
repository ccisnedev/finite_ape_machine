# APE

**Analyze. Plan. Execute.**

> Select **@ape** as your GitHub Copilot custom agent.
> Every task follows a strict cycle: **ANALYZE → PLAN → EXECUTE**.
> No freestyling. No hallucinated plans. Structure from analysis to PR.

---

## How it works

![APE finite state machine](https://raw.githubusercontent.com/ccisnedev/finite_ape_machine/main/code/site/img/fsm.png)

| Phase | What happens | Output |
|-------|-------------|--------|
| **ANALYZE** | Questions, challenges assumptions, clarifies scope | `diagnosis.md` |
| **PLAN** | Decomposes into checkable steps with tests | `plan.md` |
| **EXECUTE** | Implements exactly what the plan says | code + commits |

Each phase has a dedicated agent. Transitions are enforced — no skipping steps.

---

## Quick start

1. Install from the [Marketplace](https://marketplace.visualstudio.com/items?itemName=ccisnedev.ape-vscode)
2. `Ctrl+Shift+P` → **APE: Init**
3. The extension installs the CLI if missing, runs `ape init`, creates `.ape/`
4. Open Copilot Chat → select **@ape** → describe your task

That's it. APE takes over: analysis first, then plan, then execute.

---

## Commands

| Command | What it does |
|---------|-------------|
| `APE: Init` | Install CLI + scaffold `.ape/` in your workspace |
| `APE: Toggle Evolution` | Enable/disable DARWIN's process improvement cycle |
| `APE: Add Mutation Note` | Record an observation for DARWIN to evaluate |

---

## Status bar

The status bar shows the current FSM phase in real time:

**IDLE** · **ANALYZE** · **PLAN** · **EXECUTE** · **END** · **EVOLUTION**

---

## Requirements

- VS Code ≥ 1.85
- Windows or Linux
- GitHub Copilot (required) — APE ships as a custom agent

---

## Links

- [Website](https://www.ccisne.dev/finite_ape_machine/) · [GitHub](https://github.com/ccisne-dev/finite_ape_machine) · [Issues](https://github.com/ccisne-dev/finite_ape_machine/issues)

For the full methodology, see [ccisne.dev/finite_ape_machine](https://www.ccisne.dev/finite_ape_machine/).

MIT © 2026 Cristian Cisneros
