---
name: legion
description: 'Convoke a council of diverse experts as independent sub-agents to analyze a problem from multiple perspectives and synthesize their outputs into a persisted .md dictamen.'
---

# legion — Council of Experts (LEGION)

## When to Use

- A complex problem spans multiple domains and a single perspective risks blind spots
- A design or architecture decision has subtle trade-offs that benefit from diverse viewpoints
- You need to validate a proposal, diagnosis, or plan from genuinely different angles
- A decision carries high stakes and you want structured dissent before committing
- You suspect your analysis is anchored in one framing and want to break out of it

## Protocol

### Step 1: Comprehension

Analyze the problem before selecting experts:

1. Restate the problem in your own words.
2. Identify the domains involved (technical, business, security, UX, etc.).
3. Determine the type of output needed (decision, design, diagnosis, evaluation).
4. If the problem is ambiguous or underspecified, ask the user for clarification before proceeding.

Do NOT select experts until you understand the problem.

### Step 2: Expert Selection

Select **5 experts** (default). Minimum 3, maximum 7.

For each expert, define:
- **Name**: a descriptive persona (e.g., "Security Auditor", "Senior Engineer")
- **Perspective**: the cognitive lens they bring
- **Why selected**: how this perspective covers a distinct region of the problem space

**Selection criteria:** maximize cognitive distance between experts. Avoid selecting experts with overlapping perspectives (e.g., two backend engineers). Each expert should cover a different axis of the problem.

Announce the selected experts to the user before proceeding to consultation. List each expert's name, perspective, and the rationale for their inclusion.

See **Reference Personas** below for guidance on cognitive styles.

### Step 3: Consultation

Invoke each expert as a **separate, independent sub-agent** with its own isolated context.

Each expert receives:
- A persona prompt defining their identity, perspective, and cognitive style
- The problem statement (as comprehended in Step 1)
- Access to workspace tools and skills as needed
- Instructions to produce output in the **Expert Dictamen Format** (see below)

**Sub-agent isolation is mandatory.** Each expert must reason independently, without access to other experts' outputs. This prevents progressive anchoring and preserves the diversity that makes the council valuable.

```
CRITICAL: Do NOT role-play experts sequentially in a single context.
Each expert MUST be invoked as a separate sub-agent.
Sequential role-play destroys independence — the second expert
is anchored by the first, the third by both, and so on.
The entire value of the council depends on isolated invocation.
```

**Fallback for runtimes without sub-agent support:** If your runtime does not support sub-agent invocation, you may fall back to sequential prompting with explicit context resets between experts. Be aware that this is a **degraded mode** — context isolation cannot be fully guaranteed, and anchoring effects will reduce the diversity of perspectives.

### Step 4: Synthesis

After all experts have produced their dictamens, synthesize the results:

1. Read all expert dictamens.
2. Identify **consensuses** — points where multiple experts independently agree.
3. Identify **dissents** — points where experts disagree, with attribution.
4. Identify **blind spots** — aspects of the problem that no expert addressed.
5. Formulate a **final recommendation** that integrates the perspectives, weighs the dissents, and addresses the blind spots.

Produce the output in the **Synthesis Format** (see below).

Persist the synthesis as a `.md` file in the appropriate project directory.

## Expert Dictamen Format

Each expert must produce their output using this structure:

```markdown
### Expert: [Name]
**Perspective:** [cognitive lens]

#### Findings
- [Key observations from this expert's perspective]

#### Risks
- [Risks identified from this perspective]

#### Recommendation
[What this expert recommends and why]

#### Confidence
[high | medium | low] — [brief justification]
```

## Synthesis Format

The final integrated document uses this structure:

```markdown
# Council of Experts — Synthesis

## Problem Analyzed
[Problem statement as comprehended in Step 1]

## Experts Convened
| # | Persona | Perspective | Confidence |
|---|---------|-------------|------------|
| 1 | [name]  | [lens]      | [level]    |

## Individual Dictamens
[Embed each expert's dictamen in full]

## Consensuses
- [Points where multiple experts independently agree]

## Dissents
- **[Expert A]** vs **[Expert B]**: [nature of disagreement and implications]

## Blind Spots
- [Aspects no expert addressed, or areas of insufficient coverage]

## Final Recommendation
[Integrated recommendation that weighs consensuses, addresses dissents, and acknowledges blind spots]
```

Persist the synthesis as a `.md` file in the appropriate project directory. Use a descriptive filename (e.g., `council-synthesis-<topic>.md`).

## Reference Personas

The following are **guidance, not mandatory**. Select or adapt personas based on the specific problem. Define entirely new personas when the problem demands it. The goal is maximum cognitive distance — each expert should see the problem through a genuinely different lens.

| Persona | Perspective | Cognitive Style |
|---------|-------------|-----------------|
| Theoretical Physicist (Nobel profile) | First-principles thinking | Decomposes to axioms. Questions assumptions everyone takes for granted. Prefers elegant models over patched solutions. |
| Senior Engineer (15+ years) | Pragmatism from experience | Thinks about maintainability, tech debt, and what breaks at 3am. Values what works over what's clever. |
| Business Analyst | User value and process | Translates between technical and human. Focuses on value flow. Identifies business rules that engineers assume or ignore. |
| Autodidact Designer | Radical simplicity and UX | Questions unnecessary complexity. If a user can't understand it in 30 seconds, it's wrong. Thinks in flows, not components. |
| Security Auditor | Threat model and attack surface | Thinks like an attacker. Identifies what can go wrong, not what should go right. Assumes all input is hostile. |
| Veteran DBA | Performance and data integrity | Thinks in locks, indexes, execution plans. Knows 80% of performance problems are poorly written queries. |
| Academic Researcher | State of the art and formal rigor | Knows the literature. Distinguishes anecdotal evidence from reproducible results. Warns when you're reinventing the wheel. |

## Rules

1. **Sub-agent isolation is mandatory.** Each expert must be invoked as a separate sub-agent with its own context. Context must not leak between experts.
2. **No sequential role-play.** Do not simulate multiple experts in a single context. Each expert must be a separate sub-agent invocation. This is non-negotiable.
3. **Maximize cognitive distance.** Avoid selecting experts with overlapping perspectives. Each expert must cover a distinct region of the problem space.
4. **Default 5 experts.** Minimum 3, maximum 7. Adjust within this range based on problem complexity.
5. **Output must be persisted as `.md`.** The synthesis is a durable artifact, not ephemeral chat output.
6. **Runtime-agnostic.** This protocol does not depend on any specific tooling, framework, or runtime. It works with any agent that supports sub-agent invocation.
