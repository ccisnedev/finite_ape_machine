---
type: diagnosis
scope: issue
issue: 97
title: Automate VS Code extension publishing to Marketplace
created: 2026-04-20
---

# Diagnosis — Automate VS Code Extension Publishing to Marketplace

## 1. Problem Statement

The `finite_ape_machine` monorepo contains three deployable artifacts under `code/`:

| Artifact | Directory | CI Workflow | Publishing |
|----------|-----------|-------------|------------|
| CLI | `code/cli` | `release.yml` | Automated via GitHub Releases + tags |
| Site | `code/site` | `pages.yml` | Automated via GitHub Pages |
| VS Code Extension | `code/vscode` | **none** | **Manual** |

The VS Code extension has no automated publishing workflow. Each release requires a
developer to manually run `vsce package` and `vsce publish`, which is error-prone and
creates friction that delays updates reaching users.

Additionally, a build artifact (`ape-vscode-0.0.6.vsix`) has been committed to the
repository, indicating that the manual process has already produced hygiene issues.

## 2. Decisions

### 2.1 Separate Workflow File

The extension will have its own workflow file (`vscode-marketplace.yml`), following the
established pattern where each artifact in `code/` owns its lifecycle independently.
`pages.yml` is separate from `release.yml`; the extension workflow follows suit.

### 2.2 No Git Tags

Git tags are owned by `code/cli` via `release.yml`. The extension will **not** create
tags. In a monorepo with multiple artifacts, tag namespaces risk collision (e.g., `v1.0.0`
— which artifact does it refer to?). The VS Code Marketplace itself serves as the
authoritative version registry for the extension.

### 2.3 Idempotency via Marketplace Version Check

The workflow will compare the version in `code/vscode/package.json` against the version
currently published on the VS Code Marketplace. The logic is:

- **Versions match** → skip publish, exit green ✅
- **Versions differ** → proceed to publish

This satisfies the requirement that "nothing to publish" should be a successful (green)
workflow run, not a failure. The Marketplace is the most authoritative source for what
is currently published. The `vsce` CLI or the Marketplace REST API can provide the
currently published version.

### 2.4 Trigger Strategy

```
on:
  push:
    branches: [main]
    paths: ['code/vscode/**']
```

The real trigger for a publish is a version bump in `package.json`, but the path filter
provides the first gate (only run when extension files change), and the Marketplace
version comparison provides the second gate (only publish when the version is new). This
two-gate approach is consistent with existing workflow patterns in the repository.

### 2.5 Validation: Unit Tests on Windows + Linux

The extension's test suite includes unit tests (`npm run test:unit`) that do not require
a display server. Integration tests require `xvfb` (Linux) or a GUI environment and are
reserved for local development.

CI validation will run unit tests on a matrix of `[ubuntu-latest, windows-latest]` to
ensure cross-platform correctness. This balances confidence against CI complexity.

### 2.6 Full Automation with PAT

Publishing uses `vsce publish` with a Personal Access Token stored as the `VSCE_PAT`
repository secret. This enables end-to-end automation: push a version bump to `main`,
and the extension is published without human intervention.

### 2.7 Cleanup Committed Build Artifact

The file `ape-vscode-0.0.6.vsix` committed in the repository is a build artifact that
does not belong in source control. It must be:

1. Removed from the repository
2. Covered by a `.gitignore` entry (`*.vsix`) to prevent recurrence

## 3. Constraints

| Constraint | Rationale |
|------------|-----------|
| Must not interfere with existing `release.yml` tag mechanism | Monorepo artifact isolation |
| Must work on `ubuntu-latest` runner for the publish job | `vsce publish` has no Windows-specific requirements |
| `VSCE_PAT` secret must be configured manually by repo owner | Secrets cannot be automated; prerequisite for first run |
| Extension is self-contained within `code/vscode/` | No cross-artifact build dependencies |

## 4. Risks

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Marketplace API unavailability during version check | Workflow cannot determine current version | Low | Fail the workflow (do not publish blindly) |
| VSCE PAT expiration | Publish step fails | Medium | Clear error message; manual rotation required |
| Pre-release version semantics | Wrong publish flags used | Low (not currently used) | Out of scope; add `--pre-release` path if needed later |

## 5. Scope

### In Scope

- New workflow file: `.github/workflows/vscode-marketplace.yml`
- Version check job: compare `package.json` version vs. Marketplace version
- Test job: unit tests on `[ubuntu-latest, windows-latest]` matrix
- Publish job: `vsce publish` with `VSCE_PAT` secret
- Remove committed `.vsix` file from repository
- Ensure `.gitignore` covers `*.vsix`
- Documentation of required `VSCE_PAT` secret setup

### Out of Scope

- Integration tests in CI (require display server)
- Pre-release version support
- GitHub Release creation for the extension
- Git tag creation for the extension
- Open VSX Registry publishing (can be added as a follow-up)

## 6. References

| Reference | Purpose |
|-----------|---------|
| `.github/workflows/release.yml` | Pattern reference for CI structure and GitHub Actions conventions |
| `.github/workflows/pages.yml` | Simplicity reference for single-artifact workflows |
| `code/vscode/package.json` | Source of truth for extension version |
| `code/vscode/.vscodeignore` | Controls what is packaged into the `.vsix` |
