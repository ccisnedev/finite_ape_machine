# Memory as Code

**Finite APE Machine — Memory Architecture Specification**
*"Documentation that doesn't compile is documentation that doesn't exist."*

Version: 0.1.0-spec
Date: March 29, 2026
Author: Dev (cacsidev@gmail.com)

---

## 1. Premise

### 1.1 The Repository IS the Database

Traditional AI agent memory systems rely on external databases — SQLite, vector stores, Redis — to persist knowledge across sessions. Memory as Code rejects this approach for project-level memory. Instead, the repository itself is the memory. Well-structured documentation files, versioned with git, readable by both humans and AI agents, serve as the single source of truth.

This is not a compromise or a simplification. It is a deliberate architectural decision based on three observations:

**Observation 1:** AI agents read markdown natively and with high comprehension. A structured .md file is as queryable by an LLM as a SQL row is by a database engine — if the structure is strict.

**Observation 2:** Git provides versioning, blame, diff, and history for free. No database offers this without significant additional infrastructure.

**Observation 3:** Dual legibility — the same file that an agent reads is the same file a human reviews in GitHub. No translation layer, no tooling, no impedance mismatch.

### 1.2 The Database Analogy

Memory as Code borrows concepts from database engine design and applies them to markdown files and filesystem structure:

| Database Concept | Memory as Code Equivalent |
|-----------------|--------------------------|
| Table | Directory (e.g., `.ape/memory/adrs/`) |
| Row | Individual .md file |
| Schema | Frontmatter YAML structure (enforced by BORGES (schema enforcement, documentation compiler)) |
| Primary Index | `index.md` per directory |
| Secondary Index | Frontmatter YAML fields (tags, date, status) |
| WHERE clause | Frontmatter filtering by agent |
| Full table scan | Reading all files in a directory |
| Index scan | Reading `index.md` to find relevant files |
| Partial read | Reading only frontmatter (first N lines) |
| Full read | Reading complete file |
| Materialized view | Aggregate reports (e.g., `cycle-summary.md`) |
| Query planner | Agent strategy: index → filter → partial → full |
| Schema validation | BORGES skill (the "compiler") |
| INSERT | Creating a new .md file following schema |
| UPDATE | Editing an existing .md file + updating index |
| Transaction | Atomic write: file + index update together |
| Migration | Schema evolution via APE repo upgrade |

### 1.3 Design Principles

**Strict over flexible.** Every memory file follows an enforced schema. Malformed documentation is a bug, not a style choice.

**Indexed over searchable.** Agents should never grep through hundreds of files. Indices exist so agents can locate information in O(1) + O(k) where k is the number of relevant files.

**Incremental over recalculated.** Aggregate reports are updated incrementally per cycle, not recomputed from scratch.

**Versionable over mutable.** All memory is git-trackable. No binary blobs, no external state.

**Dual-readable over machine-optimized.** A human must be able to read, understand, and manually edit any memory file without special tooling.

---

## 2. Query Planner

### 2.1 How Agents Read Memory

An agent needing information from project memory follows a strategy analogous to a database query planner. The strategy optimizes for minimum reads while maximizing relevance.

```
QUERY: "What architectural decisions affect the payments module?"

STEP 1 — Index Scan
  Read: .ape/memory/adrs/index.md
  Result: Table of all ADRs with ID, title, date, status, tags
  Cost: 1 file read

STEP 2 — Filter on Index
  Filter: tags CONTAINS "payments" OR title CONTAINS "payments"
  Result: [adr-003, adr-007, adr-012]
  Cost: 0 (in-memory filtering of index data)

STEP 3 — Partial Read (if needed)
  Read: First 20 lines (frontmatter) of adr-003, adr-007, adr-012
  Purpose: Verify relevance, check status (accepted vs. superseded)
  Result: adr-003 (superseded), adr-007 (accepted), adr-012 (accepted)
  Cost: 2 partial reads (skip superseded)

STEP 4 — Full Read
  Read: Complete adr-007.md and adr-012.md
  Result: Full decision context, consequences, alternatives
  Cost: 2 full reads

TOTAL COST: 1 index read + 2 partial reads + 2 full reads = 5 reads
VERSUS NAIVE: Read all 50 ADR files = 50 reads
```

### 2.2 Query Strategies by Access Pattern

| Pattern | Strategy | Example |
|---------|----------|---------|
| Find by ID | Direct file access | "Read ADR-007" → `.ape/memory/adrs/adr-007.md` |
| Find by tag | Index scan → filter → full read | "ADRs about security" → index → filter tags → read matches |
| Find by date range | Index scan → filter → full read | "Decisions last month" → index → filter date → read matches |
| Find latest N | Index scan → sort → take N → full read | "Last 5 deviations" → index → sort by date → read top 5 |
| Aggregate query | Read materialized view | "How many deviations this quarter?" → `cycle-summary.md` |
| Cross-reference | Index scan on multiple tables | "What specs led to deviations?" → specs/index + deviations/index → join on related_specs |
| Full scan | Read all files (last resort) | DARWIN end-of-cycle analysis |

### 2.3 The Query Planner in the Agent Prompt

Every ape that reads memory receives this instruction as part of the BORGES skill:

```
## Memory Access Protocol

When you need information from .ape/memory/:

1. ALWAYS read the relevant index.md FIRST. Never read individual
   files without consulting the index.
2. Filter on the index table using the columns available
   (id, title, date, status, tags, related_*).
3. If the index provides enough information, STOP. Do not read
   individual files unnecessarily.
4. If you need more detail, read the frontmatter (first 20 lines)
   of candidate files to verify relevance before full read.
5. Only perform a full read of files confirmed as relevant.
6. NEVER scan an entire directory file by file. If the index
   doesn't help, report that the memory query returned no results.
```

---

## 3. Schema Definition

### 3.1 Universal Frontmatter (All Memory Files)

Every file in `.ape/memory/` MUST begin with a YAML frontmatter block. This is the schema — non-negotiable, enforced by BORGES.

```yaml
---
id: <type>-<sequential-number>        # Unique identifier
title: <descriptive title>             # Human-readable title
date: <YYYY-MM-DD>                     # Creation date
updated: <YYYY-MM-DD>                  # Last modification date
status: <draft|active|accepted|superseded|archived>
tags: [<tag1>, <tag2>, ...]            # Searchable tags
author: <human|ape-name>               # Who created this
cycle: <cycle-id>                      # APE cycle that produced this
related_specs: [<spec-id>, ...]        # Cross-references to specs
related_contracts: [<contract-pattern>] # @contract references
related_tasks: [<task-id>, ...]        # WBS task references
---
```

**Rules:**
- `id` must be globally unique within the memory directory.
- `tags` must use lowercase, hyphenated terms from a controlled vocabulary maintained in `.ape/memory/taxonomy.md`.
- `status` transitions follow defined lifecycle (see Section 3.5).
- All `related_*` fields use IDs that exist in their respective indices. Dangling references are schema violations.

### 3.2 Schema by Memory Type

#### Architecture Decision Records (ADRs)

```yaml
---
id: adr-001
title: Authentication Strategy
date: 2026-03-28
updated: 2026-03-28
status: accepted
tags: [auth, security, jwt]
author: human
cycle: cycle-003
related_specs: [spec-001]
related_contracts: [SPEC-001-*]
related_tasks: [task-005]
supersedes: null                       # ID of ADR this replaces
superseded_by: null                    # ID of ADR that replaces this
---

# ADR-001: Authentication Strategy

## Context
[What situation prompted this decision]

## Decision
[What was decided and why]

## Consequences
[What follows — both positive and negative]

## Alternatives Considered
[What was evaluated and rejected, with reasons]
```

#### Specifications (from Analyze)

```yaml
---
id: spec-001
title: User Authentication Flow
date: 2026-03-28
updated: 2026-03-28
status: active
tags: [auth, user, login, registration]
author: socrates
cycle: cycle-003
related_contracts: [SPEC-001-*]
related_tasks: [task-005, task-006]
scope: [api, db]                       # Affected layers
risk_level: high                       # From risk matrix
---

# SPEC-001: User Authentication Flow

## Objective
[What this specification defines]

## Scope
[What is included and excluded]

## Requirements
[Functional requirements, numbered]

## Constraints
[Non-functional requirements, limitations]

## Acceptance Criteria
[How to verify this spec is satisfied]
```

#### Runbooks (from Plan)

```yaml
---
id: rb-001
title: Implement Login Endpoint
date: 2026-03-28
updated: 2026-03-29
status: completed                      # draft|in_progress|completed|aborted
tags: [api, auth, login, endpoint]
author: sunzi
cycle: cycle-003
related_specs: [spec-001]
related_contracts: [SPEC-001-LOGIN-*]
related_tasks: [task-005]
estimated_phases: 4
actual_phases: 5                       # Filled on completion
estimation_accuracy: 80                # Percentage (filled by DARWIN)
---

# RB-001: Implement Login Endpoint

## Phase 1: Database schema
[What to implement, what tests verify]

## Phase 2: Service layer
[...]

## Phase N: Integration
[...]
```

#### Deviation Logs (from Execute)

```yaml
---
id: dev-001
title: Replaced jsonwebtoken with jose
date: 2026-03-29
updated: 2026-03-29
status: resolved
tags: [jwt, library, dependency]
author: ada
cycle: cycle-003
type: tactical                         # tactical | strategic
category: library-change               # Controlled vocabulary
related_specs: [spec-001]
related_contracts: [SPEC-001-LOGIN-003]
related_tasks: [task-005]
related_runbooks: [rb-001]
phase_discovered: 3                    # Runbook phase where discovered
resolution: replaced                   # replaced | workaround | escalated | redesigned
impact: low                            # low | medium | high
---

# DEV-001: Replaced jsonwebtoken with jose

## Problem
[What was expected vs. what happened]

## Root Cause
[Why the plan didn't anticipate this]

## Resolution
[What was done]

## Lessons
[What should change to prevent recurrence]
```

#### Lessons Learned (from DARWIN)

```yaml
---
id: lesson-001
title: Third-party JWT libraries require validation spike
date: 2026-03-29
updated: 2026-03-29
status: active
tags: [jwt, dependency, validation, analyze-improvement]
author: darwin
cycle: cycle-003
level: 2                               # 1=project, 2=methodology, 3=framework
related_deviations: [dev-001]
related_adrs: [adr-001]
issue_created: false                   # true if escalated to APE repo
issue_url: null
---

# LESSON-001: Third-party JWT libraries require validation spike

## Pattern Observed
[What happened and how often]

## Root Cause Analysis
[Why the methodology didn't catch this]

## Proposed Improvement
[Specific change to the APE process]

## Expected Impact
[What would change if this improvement is adopted]
```

### 3.3 Index Files

Each memory directory contains an `index.md` that serves as the primary index. HERMES (automatic state update hook) maintains these automatically.

```markdown
# ADR Index

> Auto-generated by HERMES. Do not edit manually.
> Last updated: 2026-03-29

| ID | Title | Date | Status | Tags | Related Specs |
|----|-------|------|--------|------|---------------|
| adr-001 | Authentication Strategy | 2026-03-28 | accepted | auth, security, jwt | spec-001 |
| adr-002 | Database Selection | 2026-03-29 | accepted | db, postgres | spec-002 |
| adr-003 | Payment Gateway | 2026-03-29 | draft | payments, stripe | spec-005 |

**Total: 3 | Accepted: 2 | Draft: 1 | Superseded: 0**
```

Index tables include summary statistics at the bottom — this serves as a lightweight materialized view that agents can read without opening any individual files.

### 3.4 Taxonomy (Controlled Vocabulary)

```markdown
# Memory Taxonomy

> Controlled vocabulary for tags. All tags must appear here.
> To add a new tag, append it and update this file.

## Domain Tags
- auth, payments, users, orders, notifications, search, admin

## Technical Tags
- api, db, ui, cli, infra, security, performance, testing

## Process Tags
- dependency, library-change, estimation, scope-change,
  architecture, design-pattern

## Layer Tags
- service, controller, repository, model, middleware, migration
```

Tags not in the taxonomy are schema violations. This prevents tag drift (where "auth", "authentication", "authn", and "login" all mean the same thing but fragment queries).

### 3.5 Status Lifecycles

```
Specs:     draft → active → completed → archived
ADRs:      draft → proposed → accepted → superseded → archived
Runbooks:  draft → in_progress → completed | aborted
Deviations: detected → resolved | escalated
Lessons:   draft → active → implemented → archived
```

Invalid transitions are schema violations. An ADR cannot go from `draft` to `superseded` without passing through `accepted`.

---

## 4. Materialized Views

### 4.1 Cycle Summary (Maintained by DARWIN)

`.ape/memory/reports/cycle-summary.md`

```markdown
# Cycle Summary

> Incrementally updated by DARWIN after each APE cycle.
> Last updated: 2026-03-29 (cycle-003)

## Cumulative Statistics

| Metric | Total | Avg per Cycle | Trend (last 5) |
|--------|-------|---------------|-----------------|
| Cycles completed | 3 | — | — |
| Tasks completed | 12 | 4.0 | stable |
| Tactical deviations | 5 | 1.7 | ↓ decreasing |
| Strategic deviations | 1 | 0.3 | stable |
| Estimation accuracy | — | 78% | ↑ improving |
| Tests written | 47 | 15.7 | stable |
| @contracts defined | 34 | 11.3 | stable |

## Deviation Breakdown by Category

| Category | Count | % of Total | Trend |
|----------|-------|------------|-------|
| library-change | 3 | 60% | ↓ |
| scope-change | 1 | 20% | stable |
| architecture | 1 | 20% | stable |

## Estimation Accuracy by Task Size

| Size | Cycles | Avg Accuracy | Notes |
|------|--------|-------------|-------|
| Small (1-2 phases) | 5 | 92% | Consistently accurate |
| Medium (3-5 phases) | 5 | 78% | Improving since cycle-002 |
| Large (6+ phases) | 2 | 65% | Decompose further |

## Active Lessons

| ID | Title | Level | Status |
|----|-------|-------|--------|
| lesson-001 | JWT library validation spike | 2 | active |
| lesson-002 | DB migration order matters | 1 | implemented |
```

### 4.2 Risk Patterns (Maintained by DARWIN)

`.ape/memory/reports/risk-patterns.md`

```markdown
# Risk Patterns

> Cross-cycle analysis of where deviations and failures concentrate.
> Updated by DARWIN when new patterns emerge.

## High-Frequency Deviation Sources

1. **Third-party library compatibility** (60% of deviations)
   Related: dev-001, dev-003, dev-005
   Mitigation: Validation spike in Analyze phase
   Status: lesson-001 active, improvement proposed

2. **Estimation of medium-complexity tasks** (30% overruns)
   Related: rb-003, rb-005
   Mitigation: Add buffer for tasks with 3+ phases
   Status: lesson-003 active

## Module Risk Heat Map

| Module | Deviations | Strategic | Risk Level |
|--------|-----------|-----------|------------|
| payments | 2 | 1 | high |
| auth | 1 | 0 | medium |
| ui/components | 0 | 0 | low |
```

---

## 5. BORGES — The Documentation Compiler

### 5.1 What BORGES Is

BORGES is a **shared skill** available to every ape. It is not an agent — it is a set of strict rules embedded in each ape's prompt that governs how documentation is written, structured, and validated. BORGES is to Memory as Code what a compiler is to source code: it enforces syntax, validates structure, rejects malformed output, and ensures consistency.

### 5.2 What BORGES Enforces

**Schema Compliance:**
- Every memory file MUST have YAML frontmatter matching the schema for its type (ADR, spec, runbook, deviation, lesson).
- All required fields MUST be present and non-empty.
- All `id` fields MUST be unique (check against index before writing).
- All `related_*` references MUST point to existing IDs (check against relevant indices).
- All `tags` MUST exist in the taxonomy (`.ape/memory/taxonomy.md`).
- All `status` values MUST be valid for the document type.

**Structure Compliance:**
- Every document MUST follow the section template for its type.
- No section may be empty — if unknown, write "To be determined in [phase]".
- Headers must follow the exact hierarchy defined in the template.

**Index Compliance:**
- After creating or modifying a memory file, the ape MUST update the corresponding `index.md`.
- Index entries MUST match the frontmatter of the file they reference.
- Index statistics (totals, counts by status) MUST be recalculated.

**Cross-Reference Integrity:**
- Dangling references (pointing to non-existent IDs) are violations.
- When a document is superseded or archived, all references to it MUST be checked and updated.

### 5.3 BORGES Validation Checklist

Every ape, before completing a write to `.ape/memory/`, runs this checklist:

```
BORGES VALIDATION:
□ Frontmatter YAML present and valid
□ All required fields populated
□ ID is unique (checked against index)
□ Tags exist in taxonomy
□ Status is valid for document type
□ All related_* IDs exist in their indices
□ Document sections follow type template
□ No empty sections
□ Index.md updated with new/modified entry
□ Index statistics recalculated
□ Cross-references valid (no dangling pointers)
```

If any check fails, the ape MUST fix the violation before proceeding. If it cannot fix it (e.g., a referenced spec doesn't exist), it reports the violation to the orchestrator as a **context_insufficient** condition.

### 5.4 BORGES as Prompt Injection

BORGES is implemented as a section in every ape's prompt:

```markdown
## BORGES Protocol (Mandatory)

You have write access to .ape/memory/. Every write MUST comply with
the BORGES protocol:

1. Before writing, read the schema for this document type from
   .ape/skills/_shared/contracts.md
2. Generate the frontmatter YAML with ALL required fields.
3. Verify: is the ID unique? Check the relevant index.md.
4. Verify: do all tags exist in .ape/memory/taxonomy.md?
5. Verify: do all related_* IDs exist? Check relevant indices.
6. Write the file following the section template exactly.
7. Update the relevant index.md immediately after writing.
8. If any verification fails, DO NOT write. Report the violation.

Malformed documentation is equivalent to broken code.
Do not proceed with malformed memory files.
```

### 5.5 Future: BORGES as Automated Validator

In v1.x.x, BORGES evolves from a prompt-based protocol to an automated validator:

```
ape repo doctor --memory
```

This command (in the APE CLI) would:
1. Parse all frontmatter YAML in `.ape/memory/`.
2. Validate against schemas.
3. Check all cross-references.
4. Verify index consistency.
5. Report violations with suggested fixes.

This is the equivalent of a linter or type checker for documentation.

---

## 6. DARWIN — The Evolutionary Curator

### 6.1 DARWIN's Relationship with Memory

DARWIN is the primary consumer and producer of aggregate memory. While other apes write individual memory files (ADRs, specs, deviations), DARWIN reads across all memory types to identify patterns, and maintains the materialized views.

### 6.2 DARWIN's Memory Operations

#### Read Operations (End of Cycle)

```
1. Read ALL deviation logs for current cycle
   Source: .ape/memory/deviations/index.md → filter by cycle

2. Read the runbook for current cycle
   Source: .ape/memory/runbooks/ → match by cycle

3. Read DIJKSTRA reports for current cycle
   Source: cycle artifacts (not in memory — in PR/commit)

4. Read current cycle-summary.md
   Source: .ape/memory/reports/cycle-summary.md

5. Read current risk-patterns.md
   Source: .ape/memory/reports/risk-patterns.md
```

#### Analysis Operations (In-Memory)

```
1. Compare planned vs. actual:
   - Phases estimated vs. phases executed
   - Time estimated vs. time actual (if tracked)
   - Deviations encountered

2. Categorize deviations:
   - By type (tactical/strategic)
   - By category (library, scope, architecture, etc.)
   - By module affected

3. Detect patterns:
   - Recurring deviation categories
   - Modules with high deviation rates
   - Estimation accuracy trends

4. Evaluate lessons:
   - Are previous lessons being followed?
   - Have implemented lessons reduced deviations?
```

#### Write Operations

```
1. Create lesson file (if pattern identified)
   Target: .ape/memory/lessons/lesson-NNN.md
   BORGES: full validation

2. Update cycle-summary.md (always)
   Target: .ape/memory/reports/cycle-summary.md
   Method: incremental update, not rewrite

3. Update risk-patterns.md (if new patterns)
   Target: .ape/memory/reports/risk-patterns.md
   Method: add/modify patterns, recalculate frequencies

4. Update indices (via BORGES protocol)
   Target: .ape/memory/lessons/index.md
```

### 6.3 DARWIN's Decision: When to Create an Issue

DARWIN creates an issue on the Finite APE Machine repository when a lesson reaches **Level 3** (framework-level). The criteria:

```
CREATE ISSUE when:
  - A pattern appears in 3+ cycles within the same project
  - OR a pattern appears in 2+ different projects (framework memory)
  - AND the lesson proposes a change to the APE methodology itself
  - AND the lesson has not already been reported (check issue_created field)

DO NOT CREATE ISSUE when:
  - The lesson is project-specific (Level 1)
  - The lesson improves project processes but not APE itself (Level 2,
    stays as local lesson)
  - An identical or similar issue already exists
```

#### Issue Format

```markdown
## Pattern: [Title]

**Source:** [project/repo] — [N cycles observed]
**Category:** [deviation category from taxonomy]
**Frequency:** [X% of cycles affected]

### Pattern Description
[What happens and when]

### Evidence
- Cycle [X]: [deviation-id] — [brief description]
- Cycle [Y]: [deviation-id] — [brief description]
- Cycle [Z]: [deviation-id] — [brief description]

### Root Cause Analysis
[Why the current APE methodology doesn't prevent this]

### Proposed Improvement
[Specific change to an ape prompt, skill, or workflow]

### Expected Impact
[What would improve if adopted]

### Affected APE Components
- [ ] Agent prompt: [which ape]
- [ ] Skill: [which skill]
- [ ] Template: [which template]
- [ ] Workflow: [which phase]
```

### 6.4 DARWIN's Incremental Update Protocol

DARWIN never rewrites materialized views from scratch. It follows an incremental protocol:

```
1. Read current cycle-summary.md
2. Parse existing statistics into memory
3. Add current cycle's data to the statistics
4. Recalculate averages, trends, percentages
5. Write updated cycle-summary.md
6. Validate via BORGES protocol
```

This ensures:
- O(1) cost per cycle (read one file, update, write one file).
- No need to re-read all historical deviations/runbooks.
- If the materialized view is corrupted, a full rebuild can be triggered manually: `ape darwin --rebuild-reports`.

---

## 7. Concurrency Protocol

### 7.1 Write Rules

| Writer | Can Write To | Cannot Write To |
|--------|-------------|-----------------|
| MARCOPOLO (document ingestion and normalization) | `.ape/memory/` (ingested docs, but typically not memory) | indices |
| SOCRATES (conversational requirements understanding) | `specs/` | other ape's outputs, indices |
| VITRUVIUS (decomposition and structuring) | `specs/` (WBS addendum) | other ape's outputs, indices |
| SUNZI (technical design and runbook generation) | `runbooks/` | other ape's outputs, indices |
| GATSBY (contract definition and RED tests) | — (writes to source code, not memory) | memory files |
| ADA (TDD implementation) | `deviations/` | other ape's outputs, indices |
| DIJKSTRA (quality gate pre-PR) | — (writes to PR comments, not memory) | memory files |
| DARWIN | `lessons/`, `reports/` | other ape's outputs |
| HERMES | All `index.md` files, `status.md` | individual memory files |

**Rule:** Each ape writes only to its designated directories. Only HERMES writes to shared files (indices). This eliminates write conflicts by design.

### 7.2 File Naming Convention

Every memory file name includes a timestamp to prevent collisions:

```
<type>-<sequential>-<slug>.md

Examples:
adr-001-auth-strategy.md
spec-001-user-auth-flow.md
rb-001-login-endpoint.md
dev-001-jwt-lib-replacement.md
lesson-001-lib-validation-spike.md
```

Sequential numbers are assigned by reading the latest index and incrementing. Since apes write to different directories, no two apes compete for the same sequence.

---

## 8. Upgrade Path

### 8.1 v0.x.x: Pure Markdown

- Memory lives entirely in `.ape/memory/` as .md files.
- Indices are markdown tables in `index.md` files.
- BORGES is a prompt-based protocol.
- DARWIN reads files directly.
- No external dependencies.

### 8.2 v1.x.x: Optional SQLite Cache

- `.ape/memory/` remains the source of truth.
- Optional SQLite database generated FROM the .md files as a read cache.
- FTS5 index built from frontmatter + content for faster search.
- `ape repo index --rebuild` regenerates SQLite from .md files at any time.
- Agents can query via MCP server if available, or fall back to .md files.
- BORGES gets automated validation via `ape repo doctor --memory`.

### 8.3 v2.x.x: Hybrid Search (Framework Memory)

- Framework memory (cross-project) uses SQLite + FTS5 + sqlite-vec.
- Embeddings generated for lesson content to enable semantic search.
- Project memory remains .md-first with optional SQLite cache.
- Hybrid search: BM25 (exact) + vector (semantic) with fusion ranking.

### 8.4 Migration Guarantee

At every version, the .md files are the canonical source. SQLite is always a derived artifact that can be rebuilt from the files. This ensures:

- No data loss if SQLite is corrupted or missing.
- Git history preserves the complete evolution of project memory.
- Developers can choose their preferred access method (files or DB) without affecting the source of truth.

---

## 9. Complete Directory Structure

```
.ape/memory/
├── taxonomy.md                         # Controlled vocabulary for tags
│
├── adrs/                               # Architecture Decision Records
│   ├── index.md                        # Primary index (HERMES maintains)
│   ├── adr-001-auth-strategy.md
│   └── adr-002-db-selection.md
│
├── specs/                              # Specifications (from Analyze)
│   ├── index.md
│   ├── spec-001-user-auth-flow.md
│   └── spec-002-payment-processing.md
│
├── runbooks/                           # Runbooks (from Plan)
│   ├── index.md
│   ├── rb-001-login-endpoint.md
│   └── rb-002-payment-gateway.md
│
├── deviations/                         # Deviation logs (from Execute)
│   ├── index.md
│   ├── dev-001-jwt-lib-replacement.md
│   └── dev-002-cors-config.md
│
├── lessons/                            # Lessons learned (from DARWIN)
│   ├── index.md
│   ├── lesson-001-lib-validation.md
│   └── lesson-002-migration-order.md
│
├── reports/                            # Materialized views (DARWIN maintains)
│   ├── cycle-summary.md               # Cumulative statistics and trends
│   └── risk-patterns.md               # Cross-cycle risk analysis
│
├── changelog.md                        # Chronological project evolution
│
└── status.md                           # Current state (HERMES maintains)
```

---

## 10. Glossary

| Term | Definition |
|------|-----------|
| **Memory as Code** | Architecture where project memory lives as structured .md files in the repository, versionable with git, readable by humans and agents |
| **BORGES** | Shared skill (documentation compiler) that enforces schema, structure, and cross-reference integrity on all memory files |
| **DARWIN** | Evolutionary agent that reads cross-memory patterns, maintains materialized views, and escalates framework-level lessons as issues |
| **HERMES** | Hook that maintains index files and project status, the only writer to shared files |
| **Index file** | `index.md` per directory, serving as primary index for fast lookup |
| **Frontmatter** | YAML header in each .md file, serving as schema-enforced metadata (secondary index) |
| **Materialized view** | Aggregate report maintained incrementally by DARWIN (e.g., `cycle-summary.md`) |
| **Query planner** | Agent strategy for reading memory: index → filter → partial read → full read |
| **Taxonomy** | Controlled vocabulary for tags, preventing fragmentation and ensuring consistent queries |
| **Schema violation** | Any memory file that fails BORGES validation — treated as a bug, not a style issue |
| **Dangling reference** | A `related_*` field pointing to an ID that doesn't exist — a cross-reference integrity violation |
| **Incremental update** | DARWIN's protocol for updating materialized views without re-reading all source files |

---

*Memory as Code v0.1.0-spec — Finite APE Machine*
*"Documentation that doesn't compile is documentation that doesn't exist."*
