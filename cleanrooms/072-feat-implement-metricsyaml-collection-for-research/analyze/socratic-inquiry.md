---
id: socratic-inquiry
title: "Indagación socrática: supuestos, lagunas y preguntas sobre la recolección de métricas"
date: 2025-07-18
status: active
tags: [socratic, analysis, metrics, assumptions, gaps]
author: socrates
---

# Indagación Socrática — Issue #72

## Lo que sabemos

1. **El esquema existe y es coherente.** `metrics-schema.md` define 17 campos, solo `issue` es obligatorio. El ejemplo del issue #68 demuestra un ciclo completo. Los campos opcionales permiten métricas parciales para datos retroactivos.

2. **La motivación es clara y doble.** El review-log.md muestra reproducibilidad = 2/10. Sin datos estructurados, el paper es opinión, no contribución. Pero el usuario también ve las métricas como herramienta de mejora del proyecto, no solo del paper.

3. **La metodología experimental ya define qué es automático vs. manual.** `experiment-methodology.md` §3.1 lista 8 datos extraíbles de git/GitHub. §3.2 lista 5 datos manuales. §8 reconoce explícitamente: *"Manual metrics (model used, δ failures) are lost for past issues."*

4. **Existen directorios con plan.md para los issues #51, #58, #66, #68.** Cada plan.md tiene fases con checkboxes `[x]`/`[ ]`, lo que permite extraer `plan.total_phases` y `plan.completed_phases`. El #66 además tiene `retrospective.md`.

5. **El issue #52 tiene directorio pero NO está en la lista de acceptance criteria.** Los criterios piden métricas para #51, #55, #58, #61, #66, #67, #68.

## Lo que NO está claro

### Laguna 1: Issues fantasma — #55, #61, #67 no tienen directorios

Los acceptance criteria exigen `metrics.yaml` para siete issues. Sin embargo, en `docs/issues/` solo existen directorios para:
- `51-idle-execution-guardrails` ✅
- `58-routing-version-doctor-fix` ✅
- `066-refactor-align-ape-cli-with-modular-cli-sdk` ✅
- `068-evolution-infrastructure-config-mutations` ✅

Los issues **#55, #61, #67 no tienen directorio alguno**. Esto significa que:
- No hay `plan.md` del cual extraer fidelidad de plan
- No hay directorio donde colocar `metrics.yaml`
- No hay artefactos locales que corroboren que fueron "ciclos completados con cambios de código"

¿Son realmente ciclos APE completos? ¿Se crearon antes de que existiera la convención de `docs/issues/NNN-slug/`?

### Laguna 2: Calidad vs. completitud en datos retroactivos

El esquema permite todos los campos opcionales. Pero hay una tensión:
- Un `metrics.yaml` con solo `issue`, `timing` y `cycle.completed` es *técnicamente* válido
- Pero un archivo así para 7 issues NO demuestra "reproducibility" — demuestra que se pueden crear archivos YAML

¿Cuál es el umbral mínimo de campos para que una métrica retroactiva sea *útil* para el paper, y no solo *conforme* al esquema?

### Laguna 3: Convención de nombres inconsistente

Los directorios existentes usan dos patrones:
- Sin padding: `51-idle-execution-guardrails`, `58-routing-version-doctor-fix`
- Con padding: `066-refactor-...`, `068-evolution-...`, `072-feat-...`

El esquema dice `docs/issues/NNN-slug/metrics.yaml`. ¿`NNN` es literal (tres dígitos con padding) o es placeholder? Esto afecta la ruta canónica de cada `metrics.yaml` y cualquier script futuro de `ape metrics collect`.

### Laguna 4: `tests.before` y `tests.after` — ¿de dónde salen?

Para datos históricos, el issue sugiere "test counts from CHANGELOG or commit messages". Pero:
- ¿El CHANGELOG registra conteos de tests consistentemente?
- ¿Los commits contienen esta información de forma parseable?
- ¿O se necesita hacer `git stash && git checkout <commit-antes> && dart test` para cada issue histórico?

La experiment-methodology.md dice `grep -c 'test(' before/after` sobre diffs de archivos de test. ¿Es esto confiable para Dart donde los tests usan `test()`, `group()`, y `testWidgets()`?

### Laguna 5: `delta_failures` retroactivo — ¿dato perdido o dato inventable?

La metodología dice explícitamente que los δ failures están "lost for past issues". Sin embargo, el acceptance criteria exige que cada archivo "validates against the schema". Si `delta_failures` se omite, valida. Pero si se incluye con `count: 0` por defecto, estamos *fabricando* datos — asumiendo que no hubo fallas cuando simplemente no lo sabemos.

¿Es mejor omitir el campo o declarar explícitamente la incertidumbre?
