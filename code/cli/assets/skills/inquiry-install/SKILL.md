---
name: inquiry-install
description: 'Install or repair the Inquiry CLI. Use when `iq` is not found or `iq doctor` reports missing/broken installation.'
---

# inquiry-install — CLI Bootstrap Protocol

## When to Use

- `iq` command is not found ("not recognized" / "command not found")
- `iq doctor` reports the CLI is missing or corrupt
- User explicitly asks to install or reinstall Inquiry

## Option A: VS Code Extension (recommended)

If the Inquiry VS Code extension is installed:

1. Press `Ctrl+Shift+P` → **Inquiry: Init**
2. The extension auto-downloads the CLI, places it on PATH, and runs `iq init`
3. Verify: `iq version`

## Option B: Manual Install (Windows)

```powershell
irm https://inquiry.ccisne.dev/install.ps1 | iex
```

Then initialize:

```powershell
iq doctor
iq init
```

## Option C: Manual Install (Linux / devcontainer)

```bash
curl -fsSL https://inquiry.ccisne.dev/install.sh | bash
```

Then initialize:

```bash
iq doctor
iq init
```

## Verification

After installation, all of these must succeed:

```bash
iq version        # prints version number
iq doctor         # all checks pass
iq fsm state      # prints current FSM state (IDLE if freshly initialized)
```

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `iq: command not found` after install | Restart terminal or open a new one (PATH not refreshed) |
| Permission denied (Linux) | `chmod +x ~/.inquiry/bin/inquiry` |
| HTTP 404 on download | Check internet connectivity and that `inquiry.ccisne.dev` resolves |
| `iq doctor` fails on `gh auth` | Run `gh auth login` first |
