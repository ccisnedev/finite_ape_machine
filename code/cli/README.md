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
