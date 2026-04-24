---
id: collection-process
title: "Proceso de recolección de metrics.yaml"
date: 2025-07-18
status: active
tags: [metrics, process, documentation]
author: basho
---

# Proceso de recolección de metrics.yaml

## Resumen

metrics.yaml captura datos empíricos por ciclo APE para alimentar el paper
de investigación (bootstrap-validation.md). La recolección es prospectiva:
solo ciclos futuros que alcancen EVOLUTION generan métricas.

## Precondiciones

- `.ape/config.yaml` → `evolution.enabled: true`
- El ciclo debe completarse (alcanzar EVOLUTION)

## Flujo de recolección

### Punto 1: Snapshot (IDLE → ANALYZE)

**Cuándo:** Al transitar de IDLE a ANALYZE (effect `snapshot_metrics`).
**Quién:** El orquestador APE (no un subagente).
**Qué captura:**
- `tests_before`: conteo de tests actual (`cd code/cli && dart test 2>&1 | tail -1 | grep -oP '\+\K\d+'`, exacto; fallback: `grep -rc 'test(' code/cli/test/`)
- `branch_created`: timestamp del momento del snapshot (`date -u +"%Y-%m-%dT%H:%M:%SZ"` o equivalente PowerShell)

**Dónde escribe:** `.ape/metrics_snapshot.yaml`

**Formato:**
```yaml
tests_before: 127
branch_created: "2025-07-18T10:00:00Z"
```

### Punto 2: Recolección completa (EVOLUTION)

**Cuándo:** Durante EVOLUTION, después de que DARWIN evalúa el ciclo (effect `collect_metrics`).
**Quién:** DARWIN (subagente de EVOLUTION).
**Qué captura:** Todos los 17 campos del schema (`metrics-schema.md`), consolidando el snapshot del Punto 1.

**Dónde escribe:** `.ape/metrics.yaml`

**Fuentes de datos:**
| Campo | Fuente |
|-------|--------|
| `issue` | `.ape/state.yaml` → `cycle.task` |
| `version` | `pubspec.yaml` o `lib/src/version.dart` |
| `model` | Self-report del agente |
| `agent` | Contexto del runtime |
| `cycle.*` | Implícito + output de DARWIN |
| `timing.branch_created` | `.ape/metrics_snapshot.yaml` |
| `timing.pr_merged` | `gh pr view --json mergedAt` (puede estar vacío) |
| `plan.*` | Parsing de `plan.md` |
| `tests.before` | `.ape/metrics_snapshot.yaml` |
| `tests.after` | Conteo actual de tests |
| `tests.delta` | Derivado |
| `delta_failures.*` | Self-report |
| `observations` | Freeform |

### Copia condicional

**Cuándo:** Después de generar `.ape/metrics.yaml`.
**Condición:** `git remote get-url origin` contiene `ccisnedev/finite_ape_machine`.
**Acción:** Copiar `.ape/metrics.yaml` → `docs/issues/<slug>/metrics.yaml` y `git add`.
**Quién:** El orquestador APE (no DARWIN). APE ejecuta la copia después de que DARWIN retorna.

## Almacenamiento dual (D11)

| Ubicación | Siempre | Committed | Propósito |
|-----------|---------|-----------|-----------|
| `.ape/metrics.yaml` | Sí (si evolution=true) | No (gitignored) | Workspace del framework |
| `docs/issues/<slug>/metrics.yaml` | Solo si remote=finite_ape_machine | Sí (en el PR) | Datos de investigación |

## Etapas de madurez (D7)

| Etapa | Responsable | Estado |
|-------|-------------|--------|
| 1. Orquestador (prompt) | DARWIN vía instrucciones en `ape.agent.md` | **Actual** |
| 2. Sub-agente dedicado | Agente especializado en métricas | Futuro |
| 3. CLI automatizado | `ape metrics collect` | Futuro |

## Campos omitibles

Si un campo no se puede determinar de forma confiable, se omite.
No fabricar datos (D5). El schema permite todos los campos como opcionales
excepto `issue`.
