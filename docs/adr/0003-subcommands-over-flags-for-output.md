# 3. Subcommands Over Flags for Independent Output

Date: 2026-03-31

## Status

Accepted

## Context

CLI tools traditionally mix two patterns for operations that produce independent output:

- **Flags:** `ape --version` — intercepted before routing, bypasses the command lifecycle, typically prints plain text and exits.
- **Subcommands:** `ape version` — dispatched through the router, follows the full `Command<I, O>` lifecycle (validate → execute → format).

The `--version` convention originates from POSIX/GNU traditions (1980s) designed for human operators. APE's primary consumer is an AI orchestrator that invokes commands programmatically and parses structured output.

Key observations:

1. A flag that produces output and exits behaves semantically as a command — but bypasses the framework's lifecycle, error handling, and output formatting.
2. The AI orchestrator benefits from a uniform grammar: always `ape <verb> [--modifiers]`, always structured JSON via `--json`.
3. Supporting both `--version` (flag) and `version` (subcommand) creates two code paths, two test suites, and forces the orchestrator to know which form to use.
4. Global flags like `--json` and `--quiet` are genuine modifiers — they alter *how* another command behaves, not *what* it does.

## Decision

**Everything that produces independent output is a subcommand that passes through the full `Command<I, O>` lifecycle.**

Global flags are reserved exclusively for behavior modifiers (`--json`, `--quiet`, `--verbose`, `--dry-run`) that alter how a command executes or formats its output.

The discriminant:

- **Produces its own output → subcommand:** `version`, `init`, `doctor`, `help`
- **Modifies another command's behavior → flag:** `--json`, `--quiet`

## Consequences

- Uniform grammar for both AI and human consumers: `ape <verb> [--flags]`
- All commands benefit from validation, structured error handling, `CommandException`, and exit codes
- `--json` works universally: `ape version --json` returns `{"version":"0.0.1",...}`
- No special-case middleware for `--version`, `--help`, etc.
- Slight deviation from POSIX/GNU tradition — acceptable given the AI-first audience and pre-v1.0.0 scope
- If human users demand `--version` in v1.0.0, adding it as a trivial middleware alias is a backward-compatible change
