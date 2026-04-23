# Propuesta: Consolidación de Documentación de la Metodología

**Fecha:** Abril 22, 2026

---

## Contexto

La metodología de **Inquiry** está actualmente distribuida entre varios lugares:
- `docs/spec/` — especificaciones técnicas
- `docs/research/inquiry/` — fundamentos de Peirce
- `README.md` raíz — elevator pitch
- `docs/architecture.md` — cómo funciona el sistema
- `code/site/methodology.html` — versión web
- `docs/lore.md` — nomenclatura histórica de apes

**Problema:** Un nuevo usuario tiene que recorrer múltiples archivos para entender qué es la metodología.

---

## Propuesta de Estructura

### Paso 1: Crear `docs/METHODOLOGY.md` como punto de entrada

Este archivo sería el **hub central** de la metodología, con:

```markdown
# Inquiry Methodology

**Five-state finite machine for AI-aided software development.**

Quick navigation:
- [Quick Start](#quick-start)
- [Core Concepts](#core-concepts)
- [The Five States](#the-five-states)
- [The Agents](#the-agents)
- [Memory Architecture](#memory-architecture)
- [How It Works: A Cycle](#how-it-works-a-cycle)
- [Deep Dives](#deep-dives)

## Quick Start

[copy from README]

## Core Concepts

[4 principles: Methodology > Model, Memory as Code, Antifragility, AAD/AAE/AAM]

## The Five States

[table with state, agent, function, output]

## The Agents

[brief intro to SOCRATES, DESCARTES, BASHŌ, DARWIN + their collapse to 4]

## Memory Architecture

[.inquiry/, docs/issues/NNN/, docs/spec/ — roles of each]

## How It Works: A Cycle

[end-to-end walkthrough with concrete example]

## Deep Dives

- [Finite APE Machine Spec](spec/finite-ape-machine.md) — full manifesto
- [Agent Lifecycle](spec/agent-lifecycle.md) — FSM states
- [Memory-as-Code](spec/memory-as-code-spec.md) — structured documentation
- [Peirce's Inquiry Theory](research/inquiry/peirce-abduction.md) — philosophical foundation
- [Architecture](architecture.md) — how the system is built
```

### Paso 2: Reorganizar `docs/spec/index.md`

Cambiar de lista plana a **tabla jerárquica con propósito**:

```markdown
# Specifications — Finite APE Machine

## Core Concepts (Read First)

| Document | Purpose |
|----------|---------|
| [Finite APE Machine](finite-ape-machine.md) | Manifesto + control theory foundations |
| [Inquiry Methodology](../METHODOLOGY.md) | Hub — entry point to the framework |

## Agent & State Machine

| Document | Purpose |
|----------|---------|
| [Agent Lifecycle](agent-lifecycle.md) | How agents behave in each state |
| [Cooperative Multitasking](cooperative-multitasking-model.md) | Agent coordination |

## Memory & Knowledge

| Document | Purpose |
|----------|---------|
| [Memory-as-Code Spec](memory-as-code-spec.md) | Structured documentation architecture |
| [CLI as API](cli-as-api.md) | Skills invoke CLI, CLI enforces validation |

## Implementation

| Document | Purpose |
|----------|---------|
| [Inquiry CLI Spec](inquiry-cli-spec.md) | Command line interface + TUI |
| [Target-Specific Agents](target-specific-agents.md) | Multi-tool deployment strategy |
| [Orchestrator Spec](orchestrator-spec.md) | Agent prompt structure |

## Philosophy & Research

| Document | Purpose |
|----------|---------|
| [Peirce's Inquiry Theory](../research/inquiry/) | Why "Inquiry"? Abduction → Deduction → Induction |
| [APE Builds APE](../research/ape_builds_ape/) | Bootstrap validation — empirical results |
```

### Paso 3: Mejorar `docs/lore.md`

Cambiar el título y agregar disclaimer:

```markdown
# The Apes: Nomenclature & Evolution

**Note:** This document is historical. For current implementation, see [Methodology](METHODOLOGY.md).

## The Nine Lore Apes (Original Vision)

[keep current content]

## The Four Active Apes (Current Reality)

[current table]

## Why the Collapse Was Good

[explain why fewer, sharper agents is better design]
```

### Paso 4: Crear `docs/GETTING_STARTED.md`

Para el usuario que instala por primera vez:

```markdown
# Getting Started with Inquiry

## Installation

[install commands]

## Your First Cycle: Step by Step

1. **Check prerequisites**
   ```bash
   iq doctor
   ```

2. **Create an issue on GitHub**
   ```
   Title: Add user authentication
   Description: [requirements...]
   ```

3. **Start analysis**
   ```bash
   iq target get
   [Open VS Code with your repo]
   [Click "Inquiry: Start Analysis"]
   ```

4. **Chat with SOCRATES**
   [What SOCRATES will ask you]
   [Output: diagnosis.md]

5. **Approve diagnosis**
   [Click "Approve Diagnosis"]

6. **Chat with DESCARTES**
   [What DESCARTES will do]
   [Output: plan.md with checkboxes]

7. **Approve plan**
   [Click "Approve Plan"]

8. **BASHŌ implements**
   [How BASHŌ works — test-red, implement, test-green]
   [Monitor progress via status bar]

9. **Mark plan complete**
   [Click checkboxes or "Inquiry: Finish"]

10. **PR created & merged**
    [Automatic PR creation]
    [All your commits appear in PR]

11. **Optional: Evolution**
    [DARWIN proposes improvements — if enabled]

## Next Steps

- [Read the Methodology](METHODOLOGY.md)
- [Explore the Specs](spec/)
- [See Architecture Details](architecture.md)
```

### Paso 5: Actualizar raíz `README.md`

Cambiar la estructura para claridad:

```markdown
# Inquiry

**Analyze. Plan. Execute.**

[Elevator pitch — 3 párrafos]

## 🚀 Quick Start

[install commands]

## 📚 Learn Inquiry

- **[Getting Started](docs/GETTING_STARTED.md)** — your first cycle step by step
- **[Methodology](docs/METHODOLOGY.md)** — what Inquiry is and why it works
- **[Specifications](docs/spec/)** — technical details and architecture
- **[Roadmap](docs/roadmap.md)** — where we're going

## 🏗️ Project Structure

[code/, docs/, README per folder]

## Status

[v0.1.2, 131 tests, cross-platform, single-target MVP]

## License

MIT
```

---

## Beneficios

| Beneficio | Quién se beneficia |
|-----------|-------------------|
| **Hub central**: METHODOLOGY.md como punto de entrada | Usuarios nuevos, contribuidores |
| **Jerarquía clara**: spec/index.md reorganizado | Desarrolladores, architektos |
| **Guía paso a paso**: GETTING_STARTED.md | Usuarios que instalan por primera vez |
| **README mejor**: links a documentación en lugar de duplicar | Todos |
| **Menor duplicación**: un lugar para cada concepto | Mantenimiento más fácil |

---

## Implementación Propuesta

### Fase 1 (1-2 horas)

1. Crear `docs/METHODOLOGY.md` (copy + relink desde spec/)
2. Crear `docs/GETTING_STARTED.md` (nueva guía)
3. Actualizar `docs/spec/index.md` (reorganizar + jerquizar)

### Fase 2 (30 min)

1. Actualizar `README.md` raíz (links a docs/)
2. Actualizar `docs/lore.md` (disclaimer + archivo histórico)

### Fase 3 (30 min)

1. QA: verificar que todos los links sean correctos
2. Actualizar `code/site/` para usar estos links

---

## Decisión

¿Quieres que implemente esta propuesta?

- **SÍ → Procedo ahora**
- **NO → Déjame revisar primero**
- **CAMBIOS → Aquí están mis notas...**
