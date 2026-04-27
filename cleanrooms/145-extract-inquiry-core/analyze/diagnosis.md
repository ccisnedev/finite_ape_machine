---
id: diagnosis
title: "Diagnosis — v0.2.0: Rediseño del scheduler como Finite APE Machine"
date: 2026-04-25
status: active
tags: [diagnosis, fsm, rtos, scheduler, architecture, v0.2.0]
author: socrates
---

# Diagnosis — v0.2.0: Rediseño del scheduler como Finite APE Machine

## 1. Problema

El custom agent `inquiry.agent.md` es un monolito de ~600 líneas que contiene:
- El algoritmo del scheduler (FSM de 6 estados)
- Los prompts completos de 4 sub-agentes (SOCRATES, DESCARTES, BASHŌ, DARWIN)
- Las reglas de transición, precondiciones y efectos
- La documentación de la estructura de directorios
- Convenciones de git

Este diseño tiene consecuencias directas:
- **No testeable**: la lógica de scheduling vive en markdown interpretado por un LLM
- **No modular**: cambiar el prompt de SOCRATES requiere editar el mismo archivo que define el scheduler
- **Frágil**: el cumplimiento del ciclo depende de que el LLM "obedezca" texto largo
- **No extensible**: agregar un sub-agente requiere expandir el monolito
- **Gap spec↔código**: el `transition_contract.yaml` define 54 transiciones con efectos, pero `transition.dart` no ejecuta ningún efecto — solo los reporta como strings

## 2. Visión: CLI como Kernel, Agent como Firmware

### 2.1 Modelo RTOS

El sistema se modela como un RTOS cooperativo:

| Concepto RTOS | Equivalente Inquiry |
|---------------|---------------------|
| Kernel | Inquiry CLI (`iq`) |
| Firmware | Custom agent (`inquiry.agent.md`) |
| Task | Sub-agente (SOCRATES, DESCARTES, BASHŌ, DARWIN) |
| TCB (Task Control Block) | YAML versionado del sub-agente (`assets/<name>.yaml`) |
| Syscall | Comando CLI (`iq fsm state`, `iq ape prompt`, etc.) |
| Event flags | Señales de transición (signal-based-coordination spec) |
| Shared memory | Archivos en `cleanrooms/` y `.inquiry/` |
| Tick | Cada interacción del usuario en el chat |

### 2.2 Tres capas de la arquitectura

```
CAPA 1 — FIRMWARE (custom agent, inquiry.agent.md)
├── Construido en `iq init`
├── Contiene: algoritmo del scheduler (loop FSM)
├── Estático tras init. Cambios requieren version bump del CLI.
├── ~10 líneas: "ejecuta iq fsm state, despacha, repite"
└── Es el "kernel code" que corre en el procesador (Copilot)

CAPA 2 — SKILLS (estáticas, como man pages)
├── Documentan cómo/cuándo usar comandos CLI
├── No contienen lógica dinámica
├── Compiladas al deployment en `iq init`
└── Usan: iq, git, gh, powershell/bash

CAPA 3 — PROMPTS DE SUB-AGENTES (dinámicos, generados en runtime)
├── Cada sub-agente tiene un YAML versionado en assets/ del CLI
├── `iq ape prompt <name>` lee YAML + estado actual → ensambla prompt
├── Determinístico: (versión YAML + estado) = prompt exacto
└── Testeable: dado un estado, el prompt generado es predecible
```

### 2.3 El loop del scheduler

```
USUARIO ESCRIBE EN CHAT
    │
    ▼
inquiry.agent.md (firmware) se activa
    │
    ├── 1. Ejecuta `iq fsm state --json`
    │      → {phase, task, active_apes, valid_transitions}
    │
    ├── 2. Para cada APE activo: `iq ape prompt <name>`
    │      → prompt ensamblado según estado del sub-agente
    │
    ├── 3. Despacha sub-agente(s) con prompt + input del usuario
    │
    ├── 4. Sub-agente trabaja (razona, lee archivos, escribe artefactos)
    │
    ├── 5. Si usuario autoriza transición: `iq fsm transition --event <e>`
    │
    └── 6. GOTO 1
```

## 3. Decisiones tomadas

### 3.1 Comandos separados por responsabilidad

| Comando | Responsabilidad | Retorna |
|---------|----------------|---------|
| `iq fsm state --json` | Estado del FSM + lista de APEs activos | JSON: phase, task, active_apes, valid_transitions |
| `iq ape prompt <name>` | Prompt ensamblado del sub-agente | Texto: prompt completo para el sub-agente |
| `iq fsm transition --event <e>` | Ejecutar transición de estado | JSON: success, new_state, effects |

**Justificación**: en RTOS, consultar estado y obtener código de tarea son operaciones distintas. `fsm state` es `xTaskGetState()`, `ape prompt` es cargar el task code desde ROM.

### 3.2 Renombrar `state transition` → `fsm transition`

El comando se renombra de `iq state transition` a `iq fsm transition` para enfatizar la naturaleza de máquina de estados finita.

### 3.3 Todas las escrituras en `.inquiry/` van por CLI

El LLM nunca escribe directamente en `.inquiry/`. Todas las mutaciones de estado, configuración, y metadata del ciclo se hacen mediante comandos del CLI. Esto garantiza que el estado sea siempre consistente y validado.

El LLM conserva acceso completo a lectura/escritura de archivos fuera de `.inquiry/` (código, documentos de análisis, plan.md, etc.) — su trabajo intelectual no está restringido.

### 3.4 Skills usan todos los tools validados por `iq doctor`

Skills pueden referenciar: `iq`, `git`, `gh`, `powershell`, `bash`. El CLI en `iq init` debe detectar el terminal (bash vs powershell) para que los prompts generados incluyan comandos en el shell correcto.

El CLI NO wrappea git, gh, ni comandos de shell. No hay `iq branch create` ni `iq issue create`. Las skills documentan cómo usar esos tools directamente — es más práctico que duplicar comandos.

### 3.5 Manejo de errores — sin estado ERROR

- **Error epistémico** (plan incorrecto, hipótesis falsificada): transición a ANALYZE para re-analizar.
- **Error mecánico** (git falla, red caída, disco lleno): el scheduler pausa/retry dentro del estado actual. No hay cambio de estado.

No se agrega un estado ERROR al FSM. Justificación:
- En RTOS (FreeRTOS, µC/OS), no existe estado ERROR para tasks — cada task maneja sus propios errores
- No hay ejemplo concreto donde un error mecánico requiera que el FSM cambie de comportamiento
- El LLM puede reportar "falló, ¿reintento?" sin necesidad de transicionar
- Los errores mecánicos son transitorios; los epistémicos ya tienen ruta (→ ANALYZE)

El FSM mantiene 6 estados: `IDLE → ANALYZE → PLAN → EXECUTE → END → EVOLUTION → IDLE`

### 3.6 No se extrae `inquiry_core` como paquete separado

La extracción a un paquete separado se difiere. Las razones:
- No hay un segundo consumidor hoy
- La separación por ciclos de cambio independientes es una hipótesis no validada aún
- Mantener todo en `code/cli/` es más simple mientras se diseña y estabiliza la arquitectura
- Si la evidencia de ciclos independientes emerge tras varias releases, se extrae

Los prompts modulares y el generador vivirán dentro del CLI como módulos internos.

### 3.7 Mailbox diferido

No hay caso de uso concreto hoy donde un agente necesite enviar datos a otro agente no activo. Con un solo APE activo a la vez y coordinación por archivos compartidos, el mailbox no es necesario. Se evaluará cuando haya concurrencia de sub-agentes.

### 3.8 El custom agent se construye en `iq init` (runtime generation)

`iq init` genera y despliega:
- `~/.copilot/agents/inquiry.agent.md` — el firmware (scheduler loop)
- `~/.copilot/skills/<name>/SKILL.md` — las skills estáticas

Los prompts de sub-agentes NO se despliegan como archivos — se generan en runtime por `iq ape prompt <name>`.

## 4. Dos funciones de transición a diseñar

### 4.1 Función de transición del Scheduler (FSM principal)

```
Estados: IDLE, ANALYZE, PLAN, EXECUTE, END, EVOLUTION
Eventos: issue_ready, analysis_approved, plan_approved, execution_approved,
         pr_ready, cycle_complete, block_epistemic
```

Transiciones con autorización humana (excepto EVOLUTION → IDLE que es automática):

```
IDLE       →  ANALYZE     [issue_ready]
ANALYZE    →  PLAN        [analysis_approved]     precondition: diagnosis.md exists
PLAN       →  ANALYZE     [return_to_analysis]
PLAN       →  EXECUTE     [plan_approved]          precondition: plan.md exists
EXECUTE    →  ANALYZE     [block_epistemic]        deviation detected
EXECUTE    →  END         [execution_approved]
END        →  EVOLUTION   [pr_ready]               effect: git push + gh pr create
END        →  IDLE        [pr_ready_no_evolution]  when evolution.enabled: false
EVOLUTION  →  IDLE        [cycle_complete]          automatic, no human gate
```

Errores mecánicos (git falla, red caída): el scheduler pausa y ofrece retry dentro del estado actual, sin transicionar.

### 4.2 Función de transición del APE (sub-agente)

Gestionada por el CLI (como un TCB en RTOS), NO por el sub-agente:

```
Estados del TCB: DORMANT, READY, RUNNING
```

| Estado | Significado | Quién controla |
|--------|-------------|---------------|
| DORMANT | No registrado para la fase actual | Scheduler (automático al cambiar fase) |
| READY | Registrado, esperando despacho | Scheduler activa al entrar en la fase |
| RUNNING | Despachado, ejecutando | Sub-agente trabaja; scheduler observa |

Cada sub-agente NOMBRADO (SOCRATES, DESCARTES, BASHŌ, DARWIN) tiene además un FSM interno para su estado activo:

**SOCRATES** (dentro de RUNNING):
```
CLARIFICATION → ASSUMPTIONS → EVIDENCE → PERSPECTIVES → IMPLICATIONS → META-REFLECTION
```

**DESCARTES** (dentro de RUNNING):
```
DECOMPOSITION → ORDERING → VERIFICATION → ENUMERATION
```

**BASHŌ** (dentro de RUNNING):
```
Per-phase: IMPLEMENT → TEST → COMMIT → next phase
```

**DARWIN** (dentro de RUNNING):
```
OBSERVE → COMPARE → SELECT → REPORT
```

Estos FSMs internos se definen en el YAML versionado de cada sub-agente (ej: `assets/apes/socrates.yaml`) y determinan qué prompt devuelve `iq ape prompt <name>`.

## 5. Estructura de YAMLs de sub-agentes

Cada sub-agente tiene un YAML versionado en `assets/apes/`:

```yaml
# assets/apes/socrates.yaml
name: socrates
description: "Analysis via Socratic method"
base_prompt: |
  You are SOCRATES, an analysis assistant that uses the Socratic method...
  ## Mindset
  - EPISTEMIC HUMILITY...
states:
  clarification:
    prompt: |
      FOCUS: Clarification questions. Define terms, establish scope...
  assumptions:
    prompt: |
      FOCUS: Challenge assumptions. Reveal hidden premises...
  evidence:
    prompt: |
      FOCUS: Evidence and reasons. Seek justification...
  perspectives:
    prompt: |
      FOCUS: Alternative perspectives. Change viewpoints...
  implications:
    prompt: |
      FOCUS: Implications and consequences...
  meta-reflection:
    prompt: |
      FOCUS: Questions about the questions...
```

`iq ape prompt socrates` lee este YAML + el estado actual del sub-agente → retorna `base_prompt + states[current_state].prompt`.

El YAML vive en `assets/apes/` del CLI (como parte del binario distribuido), NO en `.inquiry/` del proyecto. Es código del CLI, versionado con el CLI.

## 6. Scope — qué entra en v0.2.0

### Entra:
- [ ] Rediseñar `inquiry.agent.md` como firmware thin (~10 líneas)
- [ ] Crear YAMLs de sub-agentes (`assets/apes/socrates.yaml`, etc.)
- [ ] Implementar `iq fsm state --json`
- [ ] Implementar `iq ape prompt <name>`
- [ ] Renombrar `iq state transition` → `iq fsm transition`
- [ ] Implementar ejecución de effects en `iq fsm transition` (cerrar gap spec↔código)
- [ ] `iq init` detecta shell (bash/powershell) y genera agent + skills
- [ ] Tests con 100% cobertura para toda la lógica FSM y generación de prompts
- [ ] Corregir bug: doctor reporta "0 skills deployed" (#bugs.md #2)
- [ ] Corregir bug: `iq init` crea `docs\cleanrooms` en vez de `.\cleanrooms` (#bugs.md #3)

### NO entra:
- Extracción de `inquiry_core` como paquete separado
- Sistema de mailbox
- Múltiples sub-agentes activos simultáneamente
- Multi-target (Claude, Codex, etc.)
- Semantic compiler (detección de contradicciones entre instrucciones)

## 7. Decisiones pendientes para PLAN

### 7.1 Nivel del kernel: frontera `.inquiry/`

**Decidido**: el CLI es kernel para `.inquiry/` y oracle para todo lo demás.

| Dominio | Quién opera | Ejemplo |
|---------|------------|----------|
| `.inquiry/` (estado, config, TCB) | CLI exclusivamente | `iq fsm transition`, `iq fsm state` |
| Repositorio (git, gh, archivos) | LLM via skills | `git commit`, `gh pr create`, crear archivos |
| Contenido intelectual | LLM directamente | Escribir diagnosis.md, código, análisis |

Justificación:
- `.inquiry/` es el estado del kernel — solo el kernel lo muta (como `/proc` en Linux)
- git/gh son herramientas externas documentadas en skills — el LLM las usa como lo haría una persona
- El CLI NO wrappea herramientas externas (no hay `iq branch create`)
- El CLI valida precondiciones y ejecuta effects que tocan `.inquiry/` en `iq fsm transition`
- Effects que tocan git/gh (como `git commit analysis`) se documentan en la skill correspondiente

### 7.2 Estructura del JSON de `iq fsm state`

**Decidido**: schema mínimo, solo lo que el scheduler necesita para despachar.

```json
{
  "state": "ANALYZE",
  "task": "145",
  "apes": [
    { "name": "socrates", "tcb": "RUNNING" }
  ],
  "transitions": [
    { "event": "complete_analysis", "to": "PLAN" }
  ],
  "instructions": "Estás en ANALYZE. Usa el skill dispatch-ape para cada agente de la lista apes."
}
```

Principios del schema:
- **Solo apes activos** (RUNNING): los DORMANT son invisibles al scheduler, como en RTOS
- **Sin prechecks**: el CLI es el guardián; el firmware intenta, el CLI valida/rechaza
- **Sin prompts**: eso es `iq ape prompt <name>`, no `iq fsm state`
- **`transitions`**: lista de transiciones válidas desde el estado actual (datos estructurados para que el firmware sepa qué eventos puede disparar)
- **`instructions`**: texto inline con instrucciones del scheduler para este estado (~2-3 frases)

→ No quedan decisiones pendientes. El diagnosis está completo.

## 8. Riesgos

| Riesgo | Impacto | Mitigación |
|--------|---------|------------|
| LLM ignora el loop del firmware | El scheduler no ejecuta `iq fsm state` | Prompt ultra-corto y enfático; el CLI no tiene forma de forzar |
| Prompts generados degradan comportamiento | Sub-agente funciona peor con prompt modular que con monolito | Tests de prompt: dado estado X, assert prompt contiene Y |

| El YAML del sub-agente no captura toda la complejidad del prompt actual | Se pierde contexto al fragmentar | Comparar output generado vs. prompt monolítico actual como baseline |

## 9. Referencias

| Documento | Contenido |
|-----------|-----------|
| [scheduler-model.md](scheduler-model.md) | Modelo v1 del scheduler: FSM dispatcher |
| [scheduler-model-v2.md](scheduler-model-v2.md) | Modelo v2: generador de prompts + insight clave |
| [copilot-target.md](copilot-target.md) | Capacidades del procesador Copilot |
| [package.md](package.md) | Arquitectura del package (parcialmente superseded) |
| [bugs.md](bugs.md) | Bugs pendientes |
| [signal-based-coordination.md](../../docs/spec/signal-based-coordination.md) | Spec: modelo de señales RTOS |
| [transition_contract.yaml](../../code/cli/assets/fsm/transition_contract.yaml) | Contrato FSM actual (54 transiciones) |
| [inquiry.agent.md](../../code/cli/assets/agents/inquiry.agent.md) | Agent monolítico actual (~600 líneas) |
