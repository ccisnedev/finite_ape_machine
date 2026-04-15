# 1. Record Architecture Decisions

Date: 2026-03-10

## Status

Accepted

## Context

We need to record the architectural decisions made on this project so that future contributors (and our future selves) understand why the system is shaped the way it is.

Architecture decisions are those that affect the structure, non-functional characteristics, dependencies, interfaces, or construction techniques of the system.

## Decision

We will use Architecture Decision Records (ADRs), as described by Michael Nygard in [Documenting Architecture Decisions](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions).

Each ADR is a short text file numbered sequentially: `NNNN-short-title.md`. Each record contains:

- **Title** — A short noun phrase describing the decision
- **Status** — `Proposed`, `Accepted`, `Deprecated`, or `Superseded`
- **Context** — The forces at play, the problem being addressed
- **Decision** — What we decided and why
- **Consequences** — What becomes easier, what becomes harder

## Consequences

- Decisions are discoverable and traceable
- New contributors can understand the rationale without oral history
- We accept the overhead of writing a short document per significant decision
