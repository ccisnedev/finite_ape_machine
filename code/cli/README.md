# Inquiry CLI

**Analyze. Plan. Execute.**

The `iq` CLI enforces the Inquiry methodology in your repository — scaffolding the FSM state, deploying agents to your AI tool, and validating transitions.

This README is the CLI package entry surface. For the canonical documentation map, see [../../docs/index.md](../../docs/index.md). For the broader public overview, see the [root README](../../README.md).

Inquiry names the cycle-level process. APE names the orchestrating methodology. The Finite APE Machine names the engineered finite-state system that the CLI enforces through explicit transitions and persisted artifacts.

## Install

**Windows:**

```powershell
irm https://inquiry.si14bm.com/install.ps1 | iex
```

**Linux:**

```bash
curl -fsSL https://inquiry.si14bm.com/install.sh | bash
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
