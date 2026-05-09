---
id: perspectives-and-objections
title: Perspective pass on architecture, compatibility, and operator concerns
date: 2026-05-09
status: active
tags: [perspectives, objections, architecture, prompts]
author: socrates
---

# Perspective Pass

This note tests issue #154 from multiple viewpoints in order to surface the objections that would matter before planning.

## Runtime architecture perspective

From the runtime's point of view, the repository already has the raw surfaces needed for separation: FSM state assets carry phase mission text, APE definitions carry identity and sub-state modulation, and Inquiry CLI assembles the prompt at dispatch time. The strongest architectural objection is therefore not "where could the operational contract live?" but "what runtime layer will actually deliver it once it leaves the APE YAMLs?"

Implication:
- The refactor must enrich prompt delivery, not merely delete prose from the APE assets.

## Maintainability perspective

The current system scatters phase contract across multiple APE YAMLs. That makes operational changes expensive to reason about because a change in artifact expectations, command surfaces, or documentation protocol is expressed inside agent prose rather than in a clearly owned runtime layer.

Objection:
- Centralizing everything in CLI code could simply replace scattered prose with opaque glue unless the new ownership boundary is explicit, documented, and testable.

## Prompt-engineering integrity perspective

Mixing cognitive identity with repository procedure weakens the prompt as a design artifact. A named thinking tool becomes harder to reuse, compare, and reason about when its base prompt also has to carry file paths, output contracts, and command examples. The current SOCRATES and DARWIN prompts illustrate this drift clearly.

Objection:
- A raw operational data dump from the runtime could also damage prompt quality if the CLI injects context without preserving the voice and scope of the thinking tool.

## Backwards compatibility perspective

The live prompt assembler currently delivers APE base prompt, sub-state prompt, and a narrow inquiry-context block. That means the effective behavior still depends on operational content embedded directly in APE YAMLs today. Removing that content before an equivalent runtime-owned layer exists would change live agent behavior immediately.

Implication:
- The safe migration path is additive first: introduce the replacement delivery surface, then trim the APE YAML once prompt-equivalent behavior is preserved.

## Operator and user experience perspective

For the operator, a cleaner separation could improve predictability. Phase-owned instructions, paths, and allowed surfaces would stop changing merely because a different thinking tool is dispatched. It would also make it easier to explain why the system asked for or produced a given artifact.

Objection:
- If composition becomes harder to inspect, debugging prompt behavior gets worse. The current `iq ape prompt` surface is therefore not incidental; operator trust depends on keeping the assembled prompt inspectable.

## Exceptional-agent perspective: DARWIN

DARWIN is the narrowest justified exception. It likely needs abstract knowledge of the ideal cycle so it can compare actual execution against a standard. But that does not justify direct ownership of repository-specific `gh issue` procedures, `.inquiry` file mechanics, or concrete metrics-generation rules.

Objection:
- If the ideal process is not represented outside DARWIN's YAML, the special case will keep reabsorbing operational detail and the exception will expand.

## Overall judgment

From these perspectives, issue #154 remains well-aimed, but the real work is a layered prompt-delivery refactor rather than a prompt-edit cleanup. The most serious objection is backwards compatibility during migration, followed by the risk of replacing visible prompt ownership with opaque runtime glue.

## References

- [confirmed.md](confirmed.md)
- [identity-vs-operational-boundary.md](identity-vs-operational-boundary.md)
- [architectural-assumptions.md](architectural-assumptions.md)
- [evidence-inventory.md](evidence-inventory.md)