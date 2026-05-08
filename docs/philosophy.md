# Philosophy

> This is the foundational document of the Inquiry project. Every specification, architecture decision, and implementation choice must be traceable to the principles stated here. When two specs contradict each other, this document arbitrates. When a new feature is proposed, this document is the litmus test.

## The thesis

**The bottleneck in AI-assisted development is not AI capability — it is human clarity.**

The AI assumes things you didn't say. It misinterprets ambiguous requests. It produces plausible but wrong solutions with absolute confidence. And most of the time, the fault is yours — you expressed yourself with the ambiguity natural to human language and expected the machine to read your intent. It didn't. It read your words.

Inquiry exists to solve this communication problem. It is a method for **thinking clearly before the AI acts** — so that when it acts, it produces code you recognize as your own. Not because you wrote it, but because you designed it. Every decision was made during analysis and planning. The AI implemented your design, following your conventions, under your constraints.

The methodology doesn't replace the engineer — it amplifies them.

## What Inquiry is

Inquiry is a methodology that treats software development as an instance of **philosophical inquiry** in the pragmatist tradition.

Every development cycle is an inquiry in Dewey's precise sense:

> "Inquiry is the controlled or directed transformation of an indeterminate situation into one that is so determinate in its constituent distinctions and relations as to convert the elements of the original situation into a unified whole." — John Dewey, *Logic: The Theory of Inquiry* (1938)

A GitHub issue is an indeterminate situation. A merged pull request is a determinate unified whole. The APE cycle is the controlled transformation between them.

This is not a metaphor. It is an isomorphism:

| Pragmatist inquiry | Inquiry cycle |
|-------------------|---------------|
| Indeterminate situation | Open issue |
| Abduction (hypothesis) | ANALYZE — SOCRATES generates diagnosis |
| Deduction (experimental design) | PLAN — DESCARTES derives the plan |
| Induction (empirical test) | EXECUTE — BASHŌ implements and verifies |
| Determinate unified whole | Merged PR |

The three modes of inference — abduction, deduction, induction — are not optional stages. They are **epistemically necessary**. You cannot plan what you have not understood (abduction before deduction). You cannot verify what you have not planned (deduction before induction). You cannot understand without questioning what you assume (abduction requires Socratic humility). Peirce proved this cycle is the structure of all scientific inquiry. We apply it to software.

Before formal inquiry begins, DEWEY owns bounded IDLE triage. DEWEY determines whether the indeterminate situation is ready to become or select a GitHub issue, then hands off through the explicit `issue-start` protocol. DEWEY does not analyze, plan, or execute.

## The five convictions

### 1. Clarity through method

The typical failures of AI-assisted development — hallucination, loss of context, unauthorized changes, code that doesn't match intent — are not failures of AI capability. They are failures of **human communication**. The developer says something ambiguous. The AI interprets literally. The result surprises the developer. The developer blames the AI.

Inquiry breaks this cycle by forcing clarity *before* the AI acts. The analysis phase eliminates ambiguity — you cannot plan what you have not understood. The plan phase makes the solution explicit — by the time execution starts, the problem is already solved. What remains is mechanical transcription from a clear specification into code.

The method liberates the mind. Instead of holding the entire problem in your head while also writing code, you externalize your thinking into structured artifacts: diagnosis documents, step-by-step plans, test specifications. The AI then executes against those artifacts, not against your vague intent. The thinking tools — Socratic questioning, Cartesian decomposition, constraint-aware implementation — are the instruments that make this externalization rigorous.

### 2. Memory as code

Project knowledge belongs in the repository, version-controlled, readable by any agent, owned by the developer. Not in a cloud-hosted vector database. Not in a chat history that evaporates. Not in a proprietary model's context window.

`.inquiry/` is the runtime state. `cleanrooms/` are the epistemic artifacts. `docs/` is the canonical doctrine. Everything is markdown, YAML, or code. Everything is `git diff`-able. Everything survives the disappearance of any vendor.

### 3. The kernel boundary

`.inquiry/` is kernel space. Agents are userspace.

Just as Linux processes do not write to `/proc/` — the kernel manages that state — agents do not write to `.inquiry/`. All state mutations go through `iq` commands. Skills and prompts must never instruct agents to modify `.inquiry/` files directly.

This boundary exists because **trust must be verified, not assumed**. The CLI validates preconditions before every transition. The CLI enforces the contract. The agent proposes; the CLI disposes. If the agent hallucinates a state change, the CLI rejects it. The kernel is the last line of defense.

### 4. States are worlds

Each FSM state is a complete, self-contained world. It has a mission, a sub-agent, and artifacts. It does not know that other states exist. It does not know their names, their events, or their transitions.

The scheduler sees the full graph. The state sees only itself. This is not an implementation detail — it is an **epistemic principle**. SOCRATES must not know about PLAN because knowing about PLAN corrupts analysis. If you analyze a problem while already thinking about how to plan it, you shortcut the abductive process. You confirm instead of questioning. You converge instead of exploring.

Encapsulation is not about code hygiene. It is about **preserving the integrity of each mode of inference**.

### 5. Evolution is built-in

The system must improve itself through its own operation. DARWIN is not an afterthought — it is the reason the system can survive.

Every completed cycle generates evidence: what worked, what failed, what was harder than expected. DARWIN reads this evidence and proposes mutations to Inquiry itself. The mutations that improve the process survive. The mutations that don't are discarded. This is natural selection applied to methodology.

The end-state is a system where every cycle leaves the framework measurably better than before. Not by design — by selection.

## The named agents as thinking tools

The sub-agents are not arbitrary characters. Each name identifies a **thinking tool** — a method of reasoning drawn from a specific philosopher, culture, and era:

| Agent | Thinker | Era | Culture | Tool | Essence |
|-------|---------|-----|---------|------|---------|
| DEWEY | John Dewey (1859–1952) | Pragmatist | American | **Problematization** — disciplined inquiry into an indeterminate situation | To turn a vague problem into a well-formed issue worthy of inquiry |
| SOCRATES | Socrates (470–399 BC) | Classical | Greek | **Mayéutica** — truth through questioning | To understand before solving |
| DESCARTES | René Descartes (1596–1650) | Early Modern | French | **The Method** — divide, order, verify, enumerate | To decompose until execution is mechanical |
| BASHŌ | Matsuo Bashō (1644–1694) | Edo period | Japanese | **Techne + 用の美** — functional beauty under constraint | To create within limits, where constraint reveals elegance |
| DARWIN | Charles Darwin (1809–1882) | Victorian | English | **Natural selection** — observe, compare, select | To improve without a designer |

This diversity is intentional. The tools span 2,400 years, five cultures, and five disciplines (philosophy, epistemology, mathematics, poetry, biology). The thesis: **the best methodology for building software already exists, scattered across human intellectual history. Inquiry assembles it.**

## The name

The project is called Inquiry because that is what it does. Not "AI coding assistant." Not "agent framework." Not "prompt engineering toolkit." It conducts inquiry — the disciplined transformation of doubt into knowledge, of problems into solutions, of indeterminate situations into determinate unified wholes.

**Inquiry** names the cycle-level process. **APE** (Analyze-Plan-Execute) names the orchestrating methodology. **Finite APE Machine** names the engineered finite-state system that makes the methodology operational. The philosophy precedes the engineering. The engineering serves the philosophy.

The banner phrase captures this lineage:

> Infinite monkeys produce noise. Finite APEs produce software.

The infinite monkey theorem says that random input eventually produces any text — given infinite time. Inquiry rejects randomness. A finite number of disciplined agents, following a structured method, produce working software in finite time. The constraint is the point. The method is the machine.

## Implications for design decisions

When evaluating any change to Inquiry, apply these tests in order:

1. **Does it respect the kernel boundary?** If agents write to `.inquiry/` directly, reject it.
2. **Does it preserve state encapsulation?** If a state learns about other states, reject it.
3. **Does it maintain the epistemic sequence?** If analysis is skipped or planning is merged with execution, reject it.
4. **Does it force clarity before action?** If the AI can act without the developer having articulated a clear, unambiguous intent, the method has failed.
5. **Does it leave evidence for DARWIN?** If the cycle produces no measurable artifacts, the system cannot improve itself.

These are not guidelines. They are invariants. Violating them is a bug.

## References

- Peirce, C.S. (1878). "Deduction, Induction, and Hypothesis." *Popular Science Monthly*, 13, 470–482.
- Peirce, C.S. (1903). "Pragmatism as a Principle and Method of Right Thinking." *Harvard Lectures on Pragmatism*.
- Dewey, J. (1938). *Logic: The Theory of Inquiry*. Henry Holt and Company.
- Dewey, J. (1910). *How We Think*. D.C. Heath.
- Aristotle. *Nicomachean Ethics*, Book VI. Phronesis as practical wisdom.
- Aristotle. *Categories* (Κατηγορίαι). The first systematic taxonomy.
- Descartes, R. (1637). *Discours de la méthode*. Ian Maire, Leiden.
- Linux kernel documentation. "Submitting patches." https://www.kernel.org/doc/html/latest/process/submitting-patches.html
- Popper, K. (1959). *The Logic of Scientific Discovery*. Routledge.
