---
id: socratic-clarification
title: "Socratic Clarification — What Do We Mean by 'Aligning with Conventions'?"
date: 2026-04-18
status: active
tags: [architecture, refactoring, module-structure, clarification]
author: SOCRATES
---

# Socratic Clarification — Issue #66

## What We've Been Told

You wish to refactor `ape_cli.dart` from a 117-line monolithic entry point (registering all commands and modules inline) into a modular structure that follows the conventions demonstrated in `modular_cli_sdk/example/`. The concrete target state is clear: folder reorganization, extract module builders, separate module commands into a `modules/` tree.

The special complication is also clear: the `target` module requires `TargetDeployer` dependencies, which cannot be directly passed through `ModularCli.module(Function)` because that function signature is `void Function(ModuleBuilder)`.

## What Appears Clear

1. **Organizational goal**: Move from inline closures to extracted builder functions (`buildTargetModule`, `buildStateModule`).
2. **Folder structure**: The proposed `lib/modules/{target,state}/*_builder.dart` and `lib/modules/{target,state}/commands/` organization mirrors the SDK example.
3. **Scope of moves**: Which files move where (`target_clean.dart` → `modules/target/commands/clean.dart`, etc.).
4. **Dependency injection pattern**: Wrapping module builders with dependencies via lambda: `cli.module('target', (m) => buildTargetModule(m, deployer: deployer))`.

## What Is NOT Clear

1. **The semantics of root vs. module commands**: Why are `doctor`, `init`, `version`, `upgrade`, `uninstall` registered as root commands, while `target_clean`, `target_get`, and `state_transition` belong in modules? What rule determines this split?

2. **Whether "alignment" is structural or behavioral**: Does aligning with SDK conventions mean *only* reorganizing folders and extracting builders? Or does it imply changes to how commands are composed, how they invoke each other, or how they report results?

3. **Dependency management as a general pattern**: TargetDeployer is a dependency for `target` module. Are there (or will there be) other modules with constructor-injected dependencies? If so, should we establish a general pattern now, or solve it ad-hoc for `target`?

## Clarifying Questions

### Question 1: Root vs. Module — What's the Boundary?

You've identified `doctor`, `init`, `version`, `upgrade`, `uninstall` as root commands, and `target_clean`, `target_get`, `state_transition` as module commands. **What property makes a command 'root' rather than module-scoped?**

For example:
- Is it about *scope of effect* (root commands affect the whole application, module commands affect a domain)?
- Or *discoverability* (root commands are top-level, modules are discovered under their namespace)?
- Or is it historical — these just happen to be root now?

Could `doctor` or `init` have been designed as module commands? If yes, what would change? If no, what would break?

### Question 2: Beyond Folders — What Is "Alignment"?

The SDK example shows the *organizational* convention: builders, modules/, commands/. **But when you say 'align with modular_cli_sdk conventions,' do you also mean aligning with how the SDK expects commands to be *composed*, *tested*, or *discovered*?**

For instance:
- Should each command in a module be independently testable (as they are in the SDK example)?
- Should module builders be pure functions that compose commands without side effects?
- Should error handling or input validation follow a specific pattern?

Or is this refactoring *purely* about reorganizing existing code without changing how commands work internally?

### Question 3: Dependencies as a System-Level Concern

The `target` module needs `TargetDeployer`. Today, you're solving this with a wrapper lambda. **But imagine we add a `plugin` module that needs a `PluginRegistry`, or a `config` module that needs a `ConfigStore`. What pattern do we want in place so that dependency injection doesn't become a mess of nested lambdas?**

Should we:
- Document this as a one-off pattern and accept it?
- Create a helper to standardize it?
- Or does the SDK's design actually expect a different approach?

## Invitation

These three questions are intentionally open. They're not obstacles; they're entry points for clarifying the *intent* behind the refactoring. Your answers will determine whether this is a mechanical reorganization or a deeper architectural alignment.
