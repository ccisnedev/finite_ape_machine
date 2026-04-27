---
title: "Análisis de Bugs — Smoke Test v0.2.0"
date: 2026-04-26
status: active
source: smoke-test-report.md
---

# Análisis de Bugs — Smoke Test v0.2.0

**Evidencia base**: [smoke-test-report.md](smoke-test-report.md)
**Commits de referencia**: `9f7d56c` (fix F1 ya aplicado), `8370128` (binario en devcontainer)

Cada bug agrupa uno o más findings del smoke test bajo una hipótesis de causa raíz. La hipótesis se apoya exclusivamente en evidencia citada del reporte y del código fuente leído directamente.

---

## BUG-A — "Become" en lugar de "Dispatch" (F2, F4)

**Findings**: F2 (contenido del plan renderizado en chat), F4 (scheduler escribió plan.md en vez del sub-agente)

### Evidencia

`code/cli/assets/agents/inquiry.agent.md`, Inner Loop, paso 2 (texto exacto del archivo):

```
2. **Become** that sub-agent: follow its instructions exactly
```

Observación F2 del smoke test:
> "DESCARTES's plan content was rendered inside the chat by the custom agent."

Observación F4 del smoke test:
> "After the operator's answer 'Sí, aprobado', the agent then proceeded to write `plan.md` (sequence: `iq ape transition next` → `next` → `next` → write plan)."

La herramienta `agent` está declarada en el `tools` del frontmatter del firmware:
```
tools: [vscode, execute, read, agent, edit, search, web, browser, todo]
```

### Hipótesis

La instrucción `Become` hace que el scheduler ejecute el rol del sub-agente dentro de su propio contexto de conversación. Consecuencia: el scheduler realiza el trabajo de DESCARTES directamente (genera plan, escribe archivo, renderiza todo en chat).

El contrato correcto es `Dispatch`: el scheduler debe invocar `@descartes` como proceso separado usando la herramienta `agent`, pasarle el prompt obtenido de `iq ape prompt --name descartes`. DESCARTES escribe plan.md de forma autónoma. El scheduler solo verifica que el archivo fue creado y anuncia el resultado.

El scheduler tiene acceso a la herramienta `agent` pero la instrucción actual no la usa.

**Archivos afectados**: `code/cli/assets/agents/inquiry.agent.md` — Inner Loop, paso 2

---

## BUG-B — Preguntas de aprobación no acotadas (F3, F8)

**Findings**: F3 (pregunta abierta en PLAN), F8 (pregunta compuesta en END)

### Evidencia

Observación F3 — pregunta literal del agente:
> "¿Apruebas este plan o quieres ajustar algo antes de que lo formalice en `plan.md`?"

Observación F8 — pregunta literal del agente:
> "¿Quieres que haga push de la rama y cree el PR? ¿Y prefieres ir a EVOLUTION o directamente a IDLE?"

`code/cli/assets/agents/inquiry.agent.md`, Inner Loop, paso 4 (texto exacto):
```
4. When a sub-phase completes, ask user to approve, then: `iq ape transition --event <event>`
```

El firmware no especifica:
- Formato de la pregunta (binaria vs abierta)
- Límite de preguntas por checkpoint (una vs múltiples)
- Qué opciones están prohibidas de ofrecer

### Hipótesis

La instrucción "ask user to approve" no impone restricciones de formato. Sin ellas, el LLM genera preguntas conversacionales que incluyen alternativas, aclaraciones y opciones compuestas.

La corrección requiere especificar explícitamente: una sola pregunta por checkpoint, formato binario sí/no, sin incluir opciones alternativas ni combinaciones de preguntas.

**Archivos afectados**: `code/cli/assets/agents/inquiry.agent.md` — Inner Loop, paso 4; y sección END (actualmente ausente)

---

## BUG-C — Escritura directa de `.inquiry/state.yaml` (F5)

**Findings**: F5

### Evidencia

Observación F5 del smoke test:
> "Custom agent edited `.inquiry/state.yaml` directly (twice during the cycle: once to fix the missing `issue: 31`, once attempting to 'resync' EXECUTE state). Evidence: VS Code blocked the second edit with 'The content of the file is newer. Please compare your version...'"

Regla existente en `code/cli/assets/agents/inquiry.agent.md` (texto exacto):
```
- **NEVER** write to `.inquiry/` directly. All mutations go through `iq` commands.
```

La primera edición directa ocurrió inmediatamente después del bug F1 (state.yaml mostraba `issue: null`). El agente detectó una inconsistencia y optó por corregir el archivo directamente en lugar de usar un comando CLI.

### Hipótesis

La regla existe y es clara. Sin embargo, tiene dos debilidades estructurales:

1. Está ubicada al final del archivo (sección Rules), después de los loops principales. El LLM puede haber reducido su peso atencional al llegar al caso de error.
2. La regla prohíbe la acción pero no especifica la acción alternativa correcta cuando se detecta una inconsistencia de estado. Sin una respuesta prescripta, el LLM improvisa la corrección más directa.

La corrección requiere: (a) mover la regla a una posición más prominente, y (b) agregar la respuesta prescripta ante inconsistencia de estado: reportar al usuario y ejecutar el comando CLI correspondiente.

**Archivos afectados**: `code/cli/assets/agents/inquiry.agent.md` — sección Rules

---

## BUG-D — Autorización requerida para commits (F6)

**Findings**: F6

### Evidencia

Observación F6 — pregunta literal del agente:
> "¿Autorizo el commit y la transición a END?"

Regla existente en `code/cli/assets/agents/inquiry.agent.md` (texto exacto):
```
- **NEVER** change state without explicit user authorization.
```

El commit ocurrió durante la sub-fase `commit` de BASHŌ (EXECUTE), que es una operación `git commit` + `git push`, no una llamada a `iq fsm transition` ni a `iq ape transition`.

### Hipótesis

La instrucción usa el término "state" sin definir a qué estado se refiere. El LLM interpreta "state" en sentido amplio (cualquier efecto observable del sistema, incluyendo commits) en lugar del sentido específico (estado del FSM documentado en state.yaml).

La corrección es delimitar el alcance explícitamente: la autorización se requiere únicamente para llamadas a `iq fsm transition` y `iq ape transition`. Las demás operaciones (commits, pushes, creación de archivos, ejecución de tests) son autónomas dentro de la sub-fase activa.

**Archivos afectados**: `code/cli/assets/agents/inquiry.agent.md` — sección Rules

---

## BUG-E — Skill `issue-end` con referencias al proyecto Inquiry (F7)

**Findings**: F7 (CRITICAL)

### Evidencia

Observación F7 — texto literal emitido por el agente durante EXECUTE → END:
> "La skill issue-end menciona version bumps y changelogs, pero eso es para el proyecto inquiry mismo. Para este proyecto (tareas), solo necesito commit + push + PR."

`code/cli/assets/skills/issue-end/SKILL.md`, Step 3 (texto exacto):

```bash
# Read current version
grep "inquiryVersion" lib/src/version.dart
```

`code/cli/assets/skills/issue-end/SKILL.md`, Step 4 — archivos referenciados:
```
1. `pubspec.yaml`
2. `lib/src/version.dart`
```

`code/cli/assets/skills/issue-end/SKILL.md`, Step 3 header:
```
### Step 3: Determine Version Bump
```

Con instrucciones como `grep "inquiryVersion"` y referencias a `pubspec.yaml` / `lib/src/version.dart`, el LLM reconoció que el contexto no coincidía con el repo `tareas` (un proyecto Node.js + Flutter) y comunicó ese razonamiento explícitamente, nombrando el meta-proyecto `inquiry`.

### Hipótesis

La skill `issue-end` fue escrita para el ciclo de release del propio proyecto Inquiry (Dart/Flutter). Contiene rutas de archivos hard-coded (`lib/src/version.dart`), nombres de variables específicas (`inquiryVersion`), y comandos específicos de Dart (`dart analyze`, `dart test`). Al ser distribuida como skill genérica a cualquier repo target, sus referencias: (a) son incorrectas para proyectos con otro stack tecnológico, y (b) revelan al LLM que existe un proyecto llamado `inquiry` que es la fuente de esta skill.

La corrección requiere reescribir la skill para ser agnóstica al stack: usar lenguaje de patrón en lugar de rutas específicas ("determina si el proyecto gestiona versionado semántico y actualiza según la convención del proyecto") y eliminar toda referencia a archivos, variables o comandos específicos de Dart/Flutter.

**Archivos afectados**: `code/cli/assets/skills/issue-end/SKILL.md`

---

## BUG-F — EVOLUTION ofrecida como opción cuando está desactivada (F9)

**Findings**: F9, F8 (parcialmente)

### Evidencia

Observación F9:
> "EVOLUTION was offered as a user choice. With `evolution.enabled: false` in `config.yaml`, EVOLUTION must be silently skipped."

Observación F8 — pregunta literal:
> "¿Y prefieres ir a EVOLUTION o directamente a IDLE?"

`code/cli/assets/skills/issue-end/SKILL.md`, sección final (texto exacto):
```
- If `evolution.enabled: true`, the cycle advances from END to EVOLUTION after PR creation.
- If `evolution.enabled: false`, the cycle returns directly from END to IDLE after PR creation.
```

`code/cli/assets/agents/inquiry.agent.md` — no contiene ninguna instrucción sobre `evolution.enabled`.

### Hipótesis

La skill describe ambas rutas (EVOLUTION y no-EVOLUTION) en tiempo presente sin imperativo condicional. El LLM, al leer ambas ramas como igualmente válidas, las presenta al usuario como opciones a elegir en lugar de evaluar la condición y ejecutar la ruta correcta automáticamente.

El firmware no tiene instrucción explícita para el caso `evolution.enabled: false`. Sin ella, el LLM interpola desde la skill y genera una pregunta de elección.

La corrección requiere agregar al firmware una instrucción imperativa para el checkpoint END: "After PR creation, read `evolution.enabled` from `.inquiry/config.yaml`. If `false`, execute `iq fsm transition --event pr_ready_no_evolution` WITHOUT asking the user. Do NOT mention EVOLUTION at any point during the cycle when it is disabled."

**Archivos afectados**: `code/cli/assets/agents/inquiry.agent.md` — agregar sección END checkpoint

---

## Resumen

| ID | Findings | Componente | Hipótesis raíz | Archivos afectados |
|----|----------|------------|---------------|--------------------|
| BUG-A | F2, F4 | Firmware — Inner Loop | `Become` debe ser `Dispatch` (invocar `agent` tool) | `inquiry.agent.md` |
| BUG-B | F3, F8 | Firmware — aprobaciones | Sin restricción de formato → preguntas abiertas/compuestas | `inquiry.agent.md` |
| BUG-C | F5 | Firmware — Rules | Regla prohíbe acción pero no prescribe alternativa | `inquiry.agent.md` |
| BUG-D | F6 | Firmware — Rules | "state" ambiguo → autorización sobre-aplicada a commits | `inquiry.agent.md` |
| BUG-E | F7 | Skill issue-end | Referencias hard-coded a Inquiry/Dart exponen meta-proyecto | `issue-end/SKILL.md` |
| BUG-F | F9 | Firmware — END | EVOLUTION descrita pasivamente → ofrecida como opción | `inquiry.agent.md` |

**Finding F1** fue corregido en commit `9f7d56c`. No tiene hipótesis pendiente.
