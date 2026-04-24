---
id: expanded-entry-surface-findings
title: "Expanded entry-surface findings and contradiction synthesis for issue #134"
date: 2026-04-22
status: active
tags: [findings, entry-surfaces, contradictions, documentation, canonicity]
author: socrates
---

# Expanded Entry-Surface Findings and Contradiction Synthesis for Issue #134

## Abstract

The initial evidentiary pass already showed that the repository contains a current-model cluster, a legacy-or-expansive cluster, and multiple signals of path drift. Expansion beyond that first pass was then warranted because outward-facing entry surfaces materially affected how a reader would understand the current project. The expanded read confirms four additional findings. First, the root README and the public site largely align around the current Inquiry-branded five-state story, so they are not mere archival leftovers. Second, they remain derivative rather than canonical, because they summarize rather than own the concepts and still contain stale details such as version drift and `docs/issues/` paths. Third, the roadmap remains strategically useful but contains operational facts that now contradict the public current-state story, especially on versioning and the END state. Fourth, the VS Code extension architecture draft is not a safe current specification surface: it preserves older APE naming, planned command vocabulary, and outdated artifact paths that diverge from the actual published extension manifest. These findings materially sharpen the status map for issue #134. [1][2][3][4][5][6][7][8]

## 1. Why Expansion Beyond the First Pass Was Necessary

The first-pass findings already identified two conditions that justified widening the corpus: material contradiction and canonicity conflict. A reader entering through the repository root, the public site, or the VS Code extension documentation would encounter claims about branding, state structure, commands, artifact locations, and implementation maturity that could not be settled from the first-pass corpus alone. That means expansion was not discretionary. It was required by the audit protocol previously established for issue #134. [7][8]

## 2. README and Site as Current but Derivative Entry Surfaces

### 2.1 Both surfaces broadly match the current public model

The root README presents Inquiry rather than APE as the public identity, describes a five-state cycle including END and opt-in EVOLUTION, and presents current commands under the `iq` executable. The site landing page aligns with that same public framing: Inquiry branding, Analyze/Plan/Execute tagline, a five-state machine image that includes END, and active emphasis on GitHub Copilot as the current target. In that sense, both documents reflect the current public-facing narrative rather than an abandoned older layer. [1][3]

### 2.2 Neither surface should be treated as a canonical concept home

Despite that alignment, both surfaces are derivative rather than authoritative. The README is a public gateway that compresses the system into a project overview. The site is a marketing and onboarding surface that further condenses the same story for external readers. Neither document owns the concepts it presents. Both summarize technical and methodological material maintained elsewhere in the repository. Their correct role is therefore discoverability and orientation, not canonical definition. [1][3][7]

### 2.3 Both surfaces still contain stale or contradictory operational detail

The README declares status `v0.1.0`, while the site badge shows `v0.1.2`, the CLI package version is `0.1.2`, and the VS Code extension manifest is also `0.1.2`. The README also continues to describe per-cycle artifacts under `docs/issues/NNN-slug/`, even though the current repository workflow has moved analysis artifacts into `cleanrooms/`. These defects do not make the README useless. They do mean it cannot be treated as the authoritative operational source for current documentation structure. [1][3][5][6]

## 3. The Roadmap Remains Strategically Valuable but Operationally Mixed

### 3.1 The roadmap still communicates real strategic intent

The roadmap remains important because it captures the project's long-running theses: methodology over model, memory as code, and antifragility. It also documents the collapse from a larger lore roster into a smaller active set of four agents. These are still relevant interpretive facts for readers trying to understand why the project currently looks the way it does. [2]

### 3.2 The roadmap should not govern current-state operational understanding

Operationally, however, the roadmap now conflicts with newer outward-facing and implementation-facing surfaces. It describes the current state as `v0.0.14`, lists a five-state FSM that omits END, and places the addition of END in near-term issue #62. That directly conflicts with the README and public site, both of which already present END as part of the current cycle, and with the current released package versions at `0.1.2`. The roadmap therefore remains valid as a strategic and historical planning document, but not as the cleanest source for present operational facts. [1][2][3][5][6]

## 4. The VS Code Extension Architecture Draft Is a Historical or Aspirational Surface, Not a Current Spec

### 4.1 The draft preserves older naming and command assumptions

The extension document is explicitly a draft and still names the product as an APE extension rather than an Inquiry extension. Its examples revolve around `ape` commands, `ape.exe`, `ape.doctor`, `ape.state transition`, and APE-prefixed context keys. By contrast, the actual extension manifest now publishes `Inquiry` as display name, exposes only `inquiry.init`, `inquiry.toggleEvolution`, and `inquiry.addMutation`, and activates only on `workspaceContains:.inquiry/`. These are not cosmetic differences. They show that the draft is describing a broader or earlier design than the one actually published in the codebase. [4][6]

### 4.2 The draft also preserves outdated artifact-path assumptions

The extension draft still proposes a `plan-watcher.ts` that watches `docs/issues/*/plan.md`. That assumption no longer matches the present analysis workflow centered on `cleanrooms/`. This reproduces the same path drift already found elsewhere, but here the risk is greater because the document presents itself as an architectural specification for an implementation surface. If followed literally, it would direct work toward outdated file locations and command names. [4][7]

### 4.3 Analytical consequence

The VS Code extension draft should not be treated as a current canonical specification surface. At best it is a historical or aspirational design artifact. At worst it risks inducing false understanding about the implemented command surface and runtime file layout. Under the criteria already fixed for issue #134, it therefore belongs outside the current canonical set and should be explicitly demoted or rewritten before being presented as current architecture. [4][6][8]

## 5. Consequences for the Status Map

The expanded read sharpens the repository map in three ways. First, README and site are current derivative entry surfaces: useful, current in broad narrative, but non-canonical and partly stale in detail. Second, the roadmap is strategically current but operationally mixed, because it preserves useful historical intent alongside outdated current-state claims. Third, the VS Code extension architecture draft is a historical or obsolete-risky design surface rather than a current implementation authority. These conclusions matter because they prevent the analysis from mistaking high-visibility surfaces for canonical homes simply because readers encounter them early. [1][2][3][4][7][8]

## References

[1] Finite APE Machine repository. "Inquiry." `README.md`.

[2] Finite APE Machine repository. "Roadmap." `docs/roadmap.md`.

[3] Finite APE Machine repository. "Inquiry — Analyze. Plan. Execute." `code/site/index.html`.

[4] Finite APE Machine repository. "APE VS Code Extension — Architecture & Specification." `code/vscode/docs/ape_vscode_extension.md`.

[5] Finite APE Machine repository. `code/cli/pubspec.yaml`.

[6] Finite APE Machine repository. `code/vscode/package.json`.

[7] Finite APE Machine repository. "First-pass findings on current documentation strata for issue #134." `cleanrooms/134-organize-core-documentation/analyze/first-pass-findings-on-current-document-strata.md`.

[8] Finite APE Machine repository. "Obsolescence and canonicity criteria for issue #134." `cleanrooms/134-organize-core-documentation/analyze/obsolescence-and-canonicity-criteria.md`.