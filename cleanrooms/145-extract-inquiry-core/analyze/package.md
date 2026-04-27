# inquiry_core — Package Architecture

**Issue:** #145
**Branch:** release/0.2.0
**Status:** En análisis

---

## Visión

El paquete `inquiry_core` es el **corazón de la Finite APE Machine**: contiene la definición formal del ciclo, el scheduler RTOS-like, las máquinas de estado de cada sub-agente, y los prompts/skills que son la metodología en sí.

## Modelo conceptual

```
┌─────────────────────────────────────────────────┐
│  inquiry.agent.md (el scheduler)                │
│                                                 │
│  Misión: velar por el ciclo                     │
│  IDLE → ANALYZE → PLAN → EXECUTE → END          │
│                                                 │
│  En cada interacción:                           │
│  1. Ejecuta `iq status --json`                  │
│  2. Recibe: estado actual + instrucciones       │
│  3. Procesa input del usuario                   │
│  4. Despacha sub-agente(s) según estado         │
│                                                 │
│  ┌───────────┐ ┌──────────┐ ┌───────┐ ┌──────┐  │
│  │ SOCRATES  │ │DESCARTES │ │ BASHŌ │ │DARWIN│  │
│  │ (FSM own) │ │(FSM own) │ │(FSM)  │ │(FSM) │  │
│  └───────────┘ └──────────┘ └───────┘ └──────┘  │
└─────────────────────────────────────────────────┘
```

## Idea clave: `iq status --json` como fuente de verdad

El agente inquiry NO tiene estado interno. En cada tick:

1. Ejecuta `iq status --json` → recibe estado + prompt del estado actual
2. El CLI responde con un JSON que incluye:
   - `phase`: IDLE | ANALYZE | PLAN | EXECUTE | END | EVOLUTION
   - `task`: número de issue
   - `instructions`: prompt para el scheduler en este estado
   - `subagent`: qué sub-agente invocar
   - `subagent_prompt`: prompt específico para el sub-agente
3. El scheduler combina las instrucciones + input del usuario → despacha

Esto hace que la **inteligencia del scheduling viva en el CLI** (código Dart tipado, testeable) y no en el prompt markdown (frágil, no testeable).

## Estructura propuesta del package

```
code/inquiry_core/
├── pubspec.yaml          ← publish_to: none (de momento)
├── lib/
│   ├── inquiry_core.dart ← barrel export
│   └── src/
│       ├── fsm/
│       │   ├── state.dart        ← FsmState enum (6 estados)
│       │   ├── event.dart        ← FsmEvent enum
│       │   ├── transition.dart   ← FsmTransition, TransitionOperations
│       │   ├── contract.dart     ← FsmContract + parser
│       │   └── scheduler.dart    ← SchedulerOutput (lo que devuelve iq status --json)
│       ├── agents/
│       │   ├── agent.dart        ← AgentDefinition (metadata de cada sub-agente)
│       │   └── registry.dart     ← Registro de agentes por estado
│       ├── assets/
│       │   ├── loader.dart       ← Assets class (I/O)
│       │   └── deployer.dart     ← TargetDeployer + adapters
│       └── methodology/          ← Los assets estáticos (prompts, skills, contract)
│           ├── agents/
│           │   └── inquiry.agent.md
│           ├── skills/
│           │   ├── issue-start/SKILL.md
│           │   ├── issue-end/SKILL.md
│           │   ├── memory-read/SKILL.md
│           │   └── memory-write/SKILL.md
│           └── fsm/
│               ├── transition_contract.yaml
│               └── fsm-diagram.md
├── test/
│   ├── fsm_contract_test.dart
│   ├── scheduler_test.dart
│   └── assets_test.dart
└── README.md
```

## Preguntas abiertas

1. ¿`iq status --json` es un nuevo comando o evolución de `iq` (el TUI)?
2. ¿El output JSON del scheduler debe incluir el prompt completo del sub-agente o solo un ID?
3. ¿Los sub-agentes tienen cada uno su propia máquina de estados definida en YAML?
4. ¿Qué pasa con `TargetAdapter` y los 5 adapters? ¿Van al core o se quedan en CLI?
5. ¿El concepto de EVOLUTION como estado opcional cambia algo en el package?
