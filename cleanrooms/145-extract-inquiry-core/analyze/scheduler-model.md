# Scheduler Model — inquiry.agent.md como FSM dispatcher

**Issue:** #145
**Branch:** release/0.2.0
**Status:** En análisis

---

## Principio fundamental

El custom agent `inquiry.agent.md` tiene UNA misión: **velar por el cumplimiento del ciclo**. No le importa de qué habla el usuario. Solo le importa que el proceso se cumpla.

## No hay tick — hay un algoritmo

No es un tick periódico. Es un flujo determinista que el agente ejecuta en cada interacción:

```
┌─────────────────────────────────────────────────────────┐
│  USUARIO ESCRIBE ALGO EN EL CHAT                        │
│                                                         │
│  inquiry.agent.md (el scheduler) se activa              │
│                                                         │
│  PASO 1: iq status --json                               │
│  ┌─────────────────────────────────────────────┐        │
│  │ {                                           │        │
│  │   "phase": "ANALYZE",                       │        │
│  │   "task": "145",                            │        │
│  │   "instructions": "...",  ← prompt del      │        │
│  │                              estado actual   │        │
│  │   "subagents": [                            │        │
│  │     {                                       │        │
│  │       "name": "socrates",                   │        │
│  │       "state": "RUN",                       │        │
│  │       "prompt": "...",  ← prompt completo   │        │
│  │       "context_files": [                    │        │
│  │         ".inquiry/agents/socrates.yaml",    │        │
│  │         "cleanrooms/145/analyze/index.md"   │        │
│  │       ]                                     │        │
│  │     }                                       │        │
│  │   ]                                         │        │
│  │ }                                           │        │
│  └─────────────────────────────────────────────┘        │
│                                                         │
│  PASO 2: Evaluar estado                                 │
│  ¿El ciclo se está cumpliendo?                          │
│  ¿Hay sub-agentes en RUN?                               │
│  ¿El input del usuario es relevante para el estado?     │
│                                                         │
│  PASO 3: Despachar sub-agentes                          │
│  Para cada subagent con state=RUN:                      │
│    → Lanzar en paralelo con su prompt + context_files   │
│    → Pasar el input del usuario como contexto           │
│                                                         │
│  PASO 4: Los sub-agentes escriben archivos              │
│  NO devuelven texto al scheduler                        │
│  Escriben en:                                           │
│    .inquiry/agents/<name>.yaml  (su estado)             │
│    cleanrooms/<task>/analyze/*  (artefactos)            │
│                                                         │
│  PASO 5: Responder al usuario                           │
│  El scheduler reporta el estado del proceso             │
│  No el contenido — solo el estado                       │
└─────────────────────────────────────────────────────────┘
```

## Estados de sub-agentes (modelo RTOS)

Cada sub-agente tiene exactamente 2 estados operativos:

```
WAIT ─────→ RUN ─────→ WAIT
         (activado      (terminó o
          por el         el scheduler
          scheduler)     lo desactiva)
```

| Estado | Significado | Quién decide |
|--------|-------------|-------------|
| **WAIT** | Ni se invoca. No existe para el scheduler en este momento. | El scheduler, basado en la fase del ciclo |
| **RUN** | Activo. Se lanza con su prompt. Lee su estado de `.inquiry/agents/<name>.yaml`. Escribe artefactos. | El scheduler lo activa; el sub-agente trabaja |

### Estado del sub-agente vive en `.inquiry/`

```yaml
# .inquiry/agents/socrates.yaml
name: socrates
state: RUN
phase_context:
  issue: 145
  working_dir: cleanrooms/145-extract-inquiry-core/analyze/
  memory_files:
    - cleanrooms/145-extract-inquiry-core/analyze/index.md
    - cleanrooms/145-extract-inquiry-core/analyze/bugs.md
    - cleanrooms/145-extract-inquiry-core/analyze/package.md
  output_target: cleanrooms/145-extract-inquiry-core/analyze/
```

## Sub-agentes NO hablan con el scheduler

Principio clave: **los sub-agentes escriben archivos, no devuelven texto**.

```
SOCRATES ──writes──→ cleanrooms/145/analyze/diagnosis.md
                     cleanrooms/145/analyze/*.md
                     .inquiry/agents/socrates.yaml (actualiza su estado)

DESCARTES ──reads──→ cleanrooms/145/analyze/diagnosis.md
          ──writes──→ cleanrooms/145/plan.md
                      .inquiry/agents/descartes.yaml

BASHŌ ──reads──→ cleanrooms/145/plan.md
      ──writes──→ código, tests, commits
                  .inquiry/agents/basho.yaml
```

La coordinación es por **archivos**, no por mensajes. Exactamente como tareas en un RTOS que se comunican por shared memory.

## Mapping estado del ciclo → sub-agentes activos

| Fase | Sub-agentes en RUN | Sub-agentes en WAIT |
|------|-------------------|-------------------|
| IDLE | ninguno | todos |
| ANALYZE | SOCRATES | DESCARTES, BASHŌ, DARWIN |
| PLAN | DESCARTES | SOCRATES, BASHŌ, DARWIN |
| EXECUTE | BASHŌ | SOCRATES, DESCARTES, DARWIN |
| END | ninguno (gate humano) | todos |
| EVOLUTION | DARWIN | SOCRATES, DESCARTES, BASHŌ |

## `iq status --json` — la fuente de verdad

El CLI construye el JSON a partir de:

1. `.inquiry/state.yaml` → fase actual, task
2. `transition_contract.yaml` → instrucciones del estado, transiciones válidas
3. `.inquiry/agents/*.yaml` → estado de cada sub-agente
4. Prompt templates → prompt específico para el scheduler en este estado

```json
{
  "phase": "ANALYZE",
  "task": "145",
  "branch": "release/0.2.0",
  "instructions": "Estás en ANALYZE. Tu misión es velar que SOCRATES produzca diagnosis.md. No analices tú — despacha a SOCRATES con el input del usuario.",
  "valid_transitions": [
    {"event": "complete_analysis", "to": "PLAN", "prechecks": ["diagnosis_exists"]},
    {"event": "block", "to": "IDLE"}
  ],
  "subagents": [
    {
      "name": "socrates",
      "state": "RUN",
      "prompt": "You are SOCRATES...",
      "context_files": ["cleanrooms/145/analyze/index.md"]
    }
  ]
}
```

## Lo que esto cambia vs. el modelo actual

| Aspecto | Hoy | Propuesta |
|---------|-----|-----------|
| Scheduling | Todo vive en `inquiry.agent.md` (25KB de markdown) | Markdown mínimo + lógica en Dart |
| Sub-agente prompts | Inline en el agent.md | Generados por `iq status --json` |
| Estado sub-agentes | No existe | `.inquiry/agents/<name>.yaml` |
| Coordinación | Conversacional | Por archivos (shared memory RTOS) |
| Testabilidad | Cero (es markdown) | Total (Dart + unit tests) |
| Compliance | "Ojalá el LLM obedezca" | El CLI valida, el agente despacha |

## Pregunta abierta: ¿Qué tan delgado es el agent.md?

Si la inteligencia vive en `iq status --json`, el `inquiry.agent.md` se reduce a:

```markdown
---
name: inquiry
description: 'Inquiry scheduler — enforces the APE cycle'
tools: [vscode, execute, read, agent, edit, search]
---

# Inquiry Scheduler

On EVERY interaction:
1. Run: `iq status --json`
2. Read the response
3. For each subagent with state=RUN: launch it with its prompt
4. Pass the user's input as context to active subagents
5. Report cycle status to the user

You do NOT analyze, plan, or implement. You dispatch.
You do NOT skip step 1. Ever.
```

Esto es ~10 líneas vs. las ~600+ líneas actuales.

## Preguntas para resolver

1. ¿Cómo maneja el scheduler el caso donde el LLM ignora paso 1?
   - Opción A: El prompt es tan corto y enfático que es difícil ignorarlo
   - Opción B: El CLI detecta que no se ejecutó y advierte
   - Opción C: Redundancia — el agent.md repite "SIEMPRE ejecuta iq status --json" 3 veces

2. ¿Los sub-agentes pueden pedir transición de estado?
   - SOCRATES termina → ¿escribe `state: DONE` en su yaml y el scheduler lo detecta?
   - ¿O solo el usuario autoriza transiciones?

3. ¿`iq status --json` es un comando nuevo o evolución de `iq` (TUI)?
