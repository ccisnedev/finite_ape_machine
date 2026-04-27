# Scheduler Model v2 — Respuestas y refinamiento

**Issue:** #145
**Branch:** release/0.2.0
**Status:** En análisis — iteración 2

---

## Clarificaciones del usuario (respuestas a SOCRATES)

### 1. Señal de terminación: el scheduler PIENSA

No es un `for` que llama funciones. Es un LLM que **razona** sobre las respuestas de los sub-agentes. El scheduler sabe que algo terminó porque recibe las respuestas, razona, y luego ejecuta `iq status` (u otro comando) para saber el estado actualizado.

El scheduler es una **máquina pensante** cuya tarea es llevar el control mediante razonamiento. El CLI provee las **herramientas** para que pueda hacer eso.

### 2. Modelo de estados de sub-agentes: multinivel

Nivel 1 (ciclo de vida del sub-agente):
```
IDLE → RUN → SUCCESS | ERROR
```

Nivel 2 (interno, dentro de RUN):
Cada sub-agente tiene sus propias etapas internas.
- ANALYZE/SOCRATES: clarificación → assumptions → evidencia → perspectivas → diagnosis
- EXECUTE/BASHŌ: por cada fase del plan → implementar → test → commit

Estos estados internos se determinan progresivamente.

### 3. "El CLI tiene la inteligencia" = tiene los PROMPTS y SKILLS

NO significa que el CLI razona. Significa que:
- Los prompts viven en el CLI (como assets/templates)
- Los skills viven en el CLI
- El **razonamiento** lo hace: la persona que sigue las instrucciones, O el LLM que usa el CLI

El CLI es un **repositorio de instrucciones**, no un motor de razonamiento.

### 4. Buzón de mensajes entre agentes

Un archivo tipo email básico donde los agentes dejan mensajes. Cuando el scheduler lanza un sub-agente:
- Ejecuta un comando `iq` que sabe:
  - En qué estado está el sub-agente
  - Qué prompt enviarle según ese estado
  - Qué archivos necesita leer
  - Qué mensajes tiene pendientes en el buzón

### 5. EL INSIGHT CLAVE: inquiry_core es un GENERADOR DE PROMPTS

No es solo un paquete de assets estáticos. Es un **generador de documentos** (prompts, skills) a partir de plantillas y documentos granulares.

Analogía: así como un programa se separa en módulos, archivos y carpetas por función, lo mismo haremos para las instrucciones de AI.

```
Plantilla granular          →  inquiry_core (generador)  →  Prompt formateado para Copilot
(una instrucción por archivo)                                (luego para otros targets)

Ejemplo:
  methodology/states/analyze.md        ┐
  methodology/agents/socrates/role.md  ├→ inquiry_core genera → socrates.prompt.md
  methodology/agents/socrates/phases/  │                         (formato Copilot)
  methodology/skills/memory-read.md    ┘
```

Beneficios:
- **Granularidad**: un archivo = una instrucción/concepto
- **Sin repetición**: una instrucción existe en un solo lugar
- **Modificación quirúrgica**: cambiar un comportamiento = editar un archivo
- **Multi-target**: el generador produce para Copilot hoy, Claude/Codex mañana
- **Testeable**: se puede validar que cada plantilla genera el prompt esperado

---

## Modelo actualizado del package

```
code/inquiry_core/
├── pubspec.yaml                    ← publish_to: none
├── lib/
│   ├── inquiry_core.dart           ← barrel export
│   └── src/
│       ├── fsm/
│       │   ├── state.dart          ← FsmState, FsmEvent, enums
│       │   ├── contract.dart       ← FsmContract + parser
│       │   └── scheduler.dart      ← SchedulerOutput (iq status --json)
│       ├── agents/
│       │   ├── agent_state.dart    ← IDLE/RUN/SUCCESS/ERROR
│       │   ├── registry.dart       ← qué agente va en qué fase
│       │   └── mailbox.dart        ← sistema de buzón entre agentes
│       ├── generator/              ← EL GENERADOR
│       │   ├── prompt_builder.dart ← ensambla plantillas → prompt final
│       │   ├── skill_builder.dart  ← ensambla plantillas → SKILL.md final
│       │   └── target.dart         ← CopilotTarget, futuros targets
│       └── methodology/            ← PLANTILLAS GRANULARES
│           ├── cycle/
│           │   ├── idle.md
│           │   ├── analyze.md
│           │   ├── plan.md
│           │   ├── execute.md
│           │   ├── end.md
│           │   └── evolution.md
│           ├── agents/
│           │   ├── socrates/
│           │   │   ├── role.md
│           │   │   ├── mindset.md
│           │   │   └── phases/
│           │   │       ├── clarification.md
│           │   │       ├── assumptions.md
│           │   │       ├── evidence.md
│           │   │       ├── perspectives.md
│           │   │       └── meta-reflection.md
│           │   ├── descartes/
│           │   │   ├── role.md
│           │   │   └── method/
│           │   ├── basho/
│           │   │   ├── role.md
│           │   │   └── principles/
│           │   └── darwin/
│           │       ├── role.md
│           │       └── evaluation/
│           ├── skills/
│           │   ├── issue-start/
│           │   ├── issue-end/
│           │   ├── memory-read/
│           │   └── memory-write/
│           └── fsm/
│               └── transition_contract.yaml
├── test/
│   ├── generator_test.dart
│   ├── fsm_contract_test.dart
│   └── agent_state_test.dart
└── README.md
```

## Preguntas para la siguiente iteración

1. ¿Cómo se ve el formato de salida del generador para un prompt de Copilot? ¿Es un .agent.md con frontmatter YAML?
2. ¿El generador corre en build time (genera archivos estáticos que se despliegan) o en runtime (`iq status` genera el prompt on-the-fly)?
3. ¿El buzón de mensajes es un archivo por agente, o un archivo global?
