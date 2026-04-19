---
id: evidence-empty-module
title: "Evidence — Empty-string module mount is broken in cli_router"
date: 2026-04-18
status: active
tags: [evidence, routing, bug, empty-mount, cli-router]
author: SOCRATES
---

# Evidence — Empty-string Module Mount

## Hypothesis Tested

"We can use `cli.module('', buildGlobalModule)` to register global commands under a symmetric `modules/global/` folder structure."

## Findings

### 1. `cli.module('', builder)` is syntactically allowed

`ModularCli.module()` calls `_root.mount(name, moduleRouter)` — no validation prevents empty string.

### 2. `mount('', router)` is BROKEN

In `cli_router.dart`, `_prefixEquals` compares args against the mount prefix:

```dart
static bool _prefixEquals(List<String> args, List<_Segment> prefix) {
  if (prefix.length > args.length) return false;
  for (int i = 0; i < prefix.length; i++) { ... }
  return true;
}
```

When prefix is `[]` (from empty string), the for-loop never executes → returns `true` for ANY args. An empty mount becomes a **catch-all** that intercepts every command.

### 3. Root commands (`cli.command()`) have protection

Empty routes registered via `cli.command('')` have a guard in `_dispatch()`:
```dart
if (j == 0 && args.isNotEmpty) continue;
```

This guard does NOT apply to mounts.

### 4. No tests exist for empty-string mount

Neither cli_router nor modular_cli_sdk test `mount('')` or `cli.module('')`.

## Conclusion

Using `cli.module('', buildGlobalModule)` would break all other modules — the empty mount would intercept every command before named modules are reached. This is the same catch-all bug that was fixed in issue #58.

## Options

A. **Folder-only symmetry**: Files live in `modules/global/commands/`, but registration stays as `cli.command()` in `ape_cli.dart` (or via a builder that registers on cli directly, not via module).

B. **Fix cli_router first**: Add empty-mount protection in `_prefixEquals`, test it, then use `cli.module('')`.
