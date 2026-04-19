---
id: diagnosis
title: "Diagnosis — Modular CLI Structure Alignment"
date: 2026-04-18
status: completed
tags: [diagnosis, architecture, refactoring, cli-router, empty-mount, modular-structure]
author: SOCRATES
---

# Diagnosis — Issue #66

**Issue:** #66 — refactor: align ape_cli structure with modular_cli_sdk conventions
**Branch:** 066-refactor-align-ape-cli-with-modular-cli-sdk
**Phase:** ANALYZE (completed)

---

## 1. Problem Defined

Two coupled problems: one architectural, one technical.

### 1.1 Architectural Problem

`ape_cli.dart` (117 lines) is monolithic:
- All command registration inline in a single file
- Module builders are anonymous closures, not extracted functions
- Commands flat in `lib/commands/` without organizational structure
- No separation between global and module-scoped commands

**Goal:** Align with `modular_cli_sdk` conventions — extracted builders, organized `modules/` tree, minimal entry point.

### 1.2 Technical Problem (cli_router Bug)

`mount('', router)` is syntactically allowed but functionally broken:
- `_prefixEquals()` returns `true` for any args when prefix is empty (`[]`)
- An empty mount becomes a **catch-all** that intercepts all commands before named mounts
- Root commands via `cli.command('')` are protected by a guard; mounts have no equivalent

**Impact:** `cli.module('', buildGlobalModule)` triggers this bug and breaks all other modules.

---

## 2. Decisions Taken

### D1: `modules/global/` Structure is Intentional

Global commands reside in `lib/modules/global/commands/`, NOT in top-level `lib/commands/`.

**Rationale:** Symmetry, order, clarity. All commands live under `lib/modules/`, creating structural uniformity. Deliberate deviation from SDK example.

### D2: TUI Command Goes in Global Module

TUI (empty route `''`) registered as `cmd('')` within the global module.

**Constraint:** Requires D5 (cli_router fix).

### D3: Alignment = Structural Refactoring Only

File moves, builder extraction, entry point minimization. No behavioral changes.

### D4: Dependency Injection Deferred

`target` module dependency on `TargetDeployer` solved via wrapper lambda:
```dart
cli.module('target', (m) => buildTargetModule(m, deployer: deployer, cleaner: cleaner))
```

### D5: Fix cli_router Empty-Mount Bug First

`_prefixEquals()` must handle empty prefixes safely before `cli.module('')` can work.

---

## 3. Constraints and Risks

### C1: cli_router Fix Must Not Break Existing Dispatch

All existing tests must continue to pass. New empty-mount tests must be isolated.

### C2: Empty Route vs. Empty Mount Semantics

- Empty route (`cmd('')`): fallback when no positional args and no named flags
- Empty mount (`mount('')`): prefix match — currently broken, must be restricted

### C3: Backward Compatibility

No known users rely on empty mount catch-all behavior. Breaking change is acceptable.

### C4: Module Builder Signature

`ModularCli.module(name, Function(ModuleBuilder))` doesn't support extra params. Wrapper lambdas required (D4).

### C5: Cross-repo Dependency

cli_router fix must be published/available before ape_cli can consume it. Both repos are in the workspace.

---

## 4. Scope

### In Scope

✅ **cli_router fix:** empty mount guard, TDD tests
✅ **ape_cli refactoring:** create `modules/` tree, extract builders, minimal entry point
✅ **File moves:** all commands to `modules/{name}/commands/`
✅ **Testing:** routing integration, module isolation, backward compatibility

### Out of Scope

❌ Dependency injection framework
❌ New modules (issue, memory)
❌ Behavioral command changes
❌ Dynamic module discovery

---

## 5. TDD Test Specification for cli_router

### 5.1 Existing Behavior (Must Continue to Pass)

```
test: cmd('') matches when args is empty → exit 0
test: cmd('') does NOT match when args has flags → exit 64
test: cmd('') does NOT match when args has positionals → exit 64
test: named mount reachable when cmd('') exists → exit 0
```

### 5.2 New Behavior: Empty Mount

```
test: mount('', router) with cmd('') inside matches when args is empty
  Setup: globalRouter.cmd('') → 'tui'; root.mount('', globalRouter)
  Input: []
  Expected: exit 0, 'tui' output

test: mount('', router) does NOT intercept named mounts
  Setup: root.mount('', globalRouter); root.mount('target', targetRouter)
  Input: ['target', 'get']
  Expected: exit 0, 'target-get' output

test: mount('', router) does NOT match when args has unrecognized positionals
  Setup: root.mount('', globalRouter) with cmd('') only
  Input: ['unknown', 'command']
  Expected: exit 64

test: mount('', router) does NOT match when args has only flags
  Setup: root.mount('', globalRouter) with cmd('')
  Input: ['--help']
  Expected: exit 64

test: named mounts take precedence over empty mount when prefix matches
  Setup: globalRouter.cmd('target') → 'global-target'; root.mount('', globalRouter); root.mount('target', targetRouter)
  Input: ['target', 'get']
  Expected: 'target-get' (named mount wins)

test: named commands in empty mount are reachable
  Setup: globalRouter.cmd('version') → 'version'; root.mount('', globalRouter)
  Input: ['version']
  Expected: exit 0, 'version' output

test: named commands in empty mount do NOT shadow named mounts
  Setup: globalRouter.cmd('target') → 'global-target'; root.mount('target', targetRouter) with cmd('get')
  Input: ['target', 'get']
  Expected: 'target-get' (named mount wins over empty mount's named command)
```

### 5.3 Semantics Table

| Args | Empty Mount (has cmd('')) | Named Mount 'target' | Expected | Reason |
|------|--------------------------|---------------------|----------|--------|
| `[]` | ✅ match cmd('') | — | TUI | Empty args → empty mount → cmd('') |
| `['version']` | ✅ match cmd('version') | — | version | Route inside empty mount |
| `['target', 'get']` | cmd('target') exists | cmd('get') exists | target-get | Named mount (longer prefix) wins |
| `['unknown']` | no match | no match | exit 64 | Nothing matched |
| `['--help']` | — | — | exit 64 | Flags alone ≠ valid route |

---

## 6. Target Structure

```
lib/
  ape_cli.dart              ← minimal (< 30 lines)
  modules/
    global/
      global_builder.dart   ← buildGlobalModule(ModuleBuilder m)
      commands/
        tui.dart
        init.dart
        version.dart
        doctor.dart
        upgrade.dart
        uninstall.dart
    target/
      target_builder.dart   ← buildTargetModule(ModuleBuilder m, {deployer, cleaner})
      commands/
        get.dart
        clean.dart
    state/
      state_builder.dart    ← buildStateModule(ModuleBuilder m)
      commands/
        transition.dart
  targets/                  ← unchanged
  assets.dart               ← unchanged
  fsm_contract.dart         ← unchanged
  src/version.dart          ← unchanged
```

---

## 7. References

| Document | Purpose |
|----------|---------|
| socratic-clarification.md | Clarification questions: root vs module, structural vs behavioral |
| assumptions-global-module.md | Challenge to global module assumption |
| evidence-empty-module.md | Technical evidence for cli_router empty-mount bug |
| modular_cli_sdk AGENTS.md | SDK conventions reference |
| cli_router cli_router.dart | Dispatch logic and _prefixEquals source |
