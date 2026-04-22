---
id: plan
title: "Plan: unificación de branding y SEO en APE"
date: 2026-04-19
status: approved
tags: [branding, seo, site, extension, readme]
author: descartes
---

# Plan: unificación de branding y SEO en APE

**Hipótesis:** Si actualizamos los tres touchpoints (sitio, extensión, repo README) de simple a complejo en cinco fases independientemente commiteables, unificaremos la identidad de APE sin romper tests ni funcionalidad.

**Diagnóstico verificado:** El estado real de los archivos coincide con el inventario del diagnóstico. Única discrepancia: `twitter:description` está en línea 17 (no 18). No afecta la ejecución.

---

## Fase 1 — Sitio: `<title>` y meta tags

**Objetivo:** Alinear título y metadatos SEO con la identidad decidida.

**Dependencias:** Ninguna.

### Cambios

- [x] `code/site/index.html` L6: `<title>` → `APE — Analyze. Plan. Execute.`
- [x] `code/site/index.html` L7: `<meta name="description">` → `A methodology framework for AI-assisted development. Currently available for GitHub Copilot.`
- [x] `code/site/index.html` L10: `og:title` → `APE — Analyze. Plan. Execute.`
- [x] `code/site/index.html` L11: `og:description` → `Analyze. Plan. Execute. A methodology framework for AI-assisted development. Currently available for GitHub Copilot.`
- [x] `code/site/index.html` L16: `twitter:title` → `APE — Analyze. Plan. Execute.`
- [x] `code/site/index.html` L17: `twitter:description` → `Analyze. Plan. Execute. A methodology framework for AI-assisted development. Currently available for GitHub Copilot.`

### Test

- Abrir `index.html` en navegador y verificar `<title>` en pestaña.
- Inspeccionar `<head>` con DevTools: confirmar que los 6 tags tienen el contenido nuevo.
- Validar con [metatags.io](https://metatags.io) o equivalente (visual, no blocker).

### Riesgos

- Ninguno técnico. Son strings estáticos en HTML.
- Riesgo de copy: la description del `og:` es ligeramente más larga para dar contexto en cards sociales. Si resulta demasiado larga (>200 chars), recortar a solo la primera oración.

---

## Fase 2 — Sitio: hero section

**Objetivo:** Comunicar identidad real en el primer viewport. Eliminar promesa falsa ("any AI coding agent") y frase de monos.

**Dependencias:** Ninguna (puede ejecutarse en paralelo con Fase 1, pero se commitea después por orden).

### Cambios

- [x] `code/site/index.html` L34: `primary-tagline` → `Analyze. Plan. Execute.`
- [x] `code/site/index.html` L35: `secondary-tagline` → `Currently available for GitHub Copilot. More targets coming soon.`

### Decisiones implícitas

- **No se elimina** el elemento `secondary-tagline`, se reutiliza para la audiencia honesta (D3). Eliminar el elemento requeriría ajustar CSS (fuera de scope).
- El párrafo `intro` (L67-68, "methodology over model") **se conserva intacto** (D2: puede aparecer en copy filosófico).

### Test

- Visual: abrir `index.html`, verificar que el hero muestra "Analyze. Plan. Execute." como tagline principal y el mensaje de Copilot debajo.
- No hay tests automatizados para el sitio estático.

### Riesgos

- Si el CSS de `secondary-tagline` tiene estilo inadecuado para un mensaje de disponibilidad (ej: itálica o tamaño diferente), podría verse raro. Verificar visualmente; ajuste CSS queda fuera de scope pero se documenta si ocurre.

---

## Fase 3 — Repo README

**Objetivo:** Primera impresión alineada. Nombre formal + tagline + valor antes de detalles técnicos.

**Dependencias:** Ninguna.

### Cambios

- [x] `README.md` L3: eliminar blockquote `> Infinite monkeys produce noise. Finite APEs produce software.`
- [x] `README.md` L3 (nueva): insertar `**Analyze. Plan. Execute.**` como línea inmediatamente después del h1
- [x] `README.md` L5 (actual): revisar primer párrafo — reemplazar "replaces 'vibe coding' with" por "structures AI coding agents into" o redacción equivalente orientada a valor

### Resultado esperado

```markdown
# Finite APE Machine

**Analyze. Plan. Execute.**

A methodology framework for AI-assisted development that models coding agents as a cooperative finite state machine — **Analyze → Plan → Execute → End → [Evolution] → Idle** — where the value is in the process, not the model.

**Status:** `v0.0.14` · 131 tests · 12 GitHub releases · Windows + Linux · Single-target MVP (Copilot)
```

### Test

- Verificar que el README renderiza correctamente en GitHub (preview local con VS Code).
- Confirmar que el tagline "Analyze. Plan. Execute." es visible sin scroll.

### Riesgos

- El texto "vibe coding" aparece una sola vez en el repo README. Eliminarlo no afecta otros documentos.
- La frase de monos se conserva en `docs/` internos (confirmado en diagnosis: fuera de scope de limpieza).

---

## Fase 4 — Extensión: `package.json`

**Objetivo:** Optimizar metadatos de la extensión para Marketplace search y alinear descripción con identidad.

**Dependencias:** Ninguna para los cambios. Pero el version bump se hace aquí y CHANGELOG en Fase 5.

### Cambios

- [x] `code/vscode/package.json` → `description`: cambiar a `Analyze. Plan. Execute. AI-aided development methodology for GitHub Copilot (more targets coming soon).`
- [x] `code/vscode/package.json` → `activationEvents`: eliminar `"onCommand:ape.init"` (redundante — auto-generado por contributes.commands)
- [x] `code/vscode/package.json` → `version`: bump `0.0.4` → `0.0.5`

### Decisión: formato del tagline en description

La `description` del Marketplace tiene máximo ~200 caracteres y se muestra como texto plano. Se usa **puntos** (`Analyze. Plan. Execute.`) en lugar de flechas (`→`) porque:
1. La marca usa puntos (D2).
2. Los puntos funcionan mejor como frase standalone en search results.
3. Las flechas se reservan para contextos de diagramas/ciclos.

### Test

```bash
cd code/vscode
npm run compile   # debe compilar sin error
npm run test:unit # 59 tests deben pasar
```

- Verificar que `activationEvents` solo contiene `workspaceContains:.ape/`.
- Verificar que `vsce package --no-dependencies` genera .vsix sin warnings.

### Riesgos

- **Version bump:** requiere que CHANGELOG se actualice (Fase 5). Si se commitea sin CHANGELOG, la publicación será inconsistente.
- **activationEvent removal:** `onCommand:ape.init` es efectivamente redundante porque VS Code lo genera automáticamente desde `contributes.commands`. Pero verificar en tests de integración que `ape.init` sigue activándose correctamente.

---

## Fase 5 — Extensión: README + CHANGELOG

**Objetivo:** Verificar alineación del README con decisiones finales. Actualizar CHANGELOG.

**Dependencias:** Fase 4 (version bump determina entrada de CHANGELOG).

### Cambios en README

El README ya fue reescrito como landing page. Verificar alineación:

- [x] `code/vscode/README.md` L3: confirmar que usa `Analyze → Plan → Execute.` (en contexto de ciclo, flechas son correctas) o alinear con `Analyze. Plan. Execute.` (como tagline). **Decisión:** usar **puntos** en la tagline bold de L3 para consistencia con el resto de touchpoints: `**Analyze. Plan. Execute.**`
- [x] `code/vscode/README.md`: confirmar que NO dice "any AI coding agent" en ningún lugar
- [x] `code/vscode/README.md`: confirmar que menciona "GitHub Copilot" explícitamente como target
- [x] `code/vscode/README.md` Requirements section: confirmar que dice `GitHub Copilot (recommended)` o similar honesto

### Cambios en CHANGELOG

- [x] `code/vscode/CHANGELOG.md`: agregar entrada `## [0.0.5]` con:
  - `description` alineada con branding
  - `activationEvents` limpiado
  - README alineado con identidad unificada

### Test

- Renderizar README en VS Code preview. Verificar que "Analyze. Plan. Execute." aparece como tagline.
- No hay tests automatizados para README/CHANGELOG.

### Riesgos

- El README actual dice `Analyze → Plan → Execute.` con flechas en la tagline. Cambiar a puntos es coherente con la marca pero rompe consistencia visual con el diagrama de ciclo que usa flechas. **Mitigación:** puntos para el tagline (identidad), flechas para el ciclo (diagrama). Son contextos diferentes.

---

## Fase 6 — Validación cruzada

**Objetivo:** Confirmar que todos los cambios son coherentes entre sí y que no se rompió nada.

**Dependencias:** Fases 1–5 completadas.

### Checklist de identidad

- [x] **"Analyze. Plan. Execute."** aparece en:
  - `code/site/index.html` (title + primary-tagline)
  - `code/vscode/package.json` (description)
  - `code/vscode/README.md` (tagline bold)
  - `README.md` (después del h1)
- [x] **"APE — Analyze. Plan. Execute."** aparece en:
  - `code/site/index.html` (title, og:title, twitter:title)
- [x] **Copilot como target explícito** aparece en:
  - `code/site/index.html` (meta description, og:description, twitter:description, secondary-tagline)
  - `code/vscode/package.json` (description)
  - `code/vscode/README.md` (múltiples menciones)
- [x] **Frase de monos eliminada** de:
  - `code/site/index.html` (secondary-tagline)
  - `README.md` (blockquote)
- [x] **"any AI coding agent" eliminado** de:
  - `code/site/index.html` (primary-tagline, meta tags)

### Tests automatizados

- [x] CLI: `cd code/cli && dart test` → 131 tests pass
- [x] VS Code: `cd code/vscode && npm run test:unit` → 59 tests pass

### Smoke test manual

- [x] Sitio: abrir `index.html` localmente, verificar hero y title
- [x] Extensión: `vsce package --no-dependencies` genera .vsix sin error
- [x] Repo: preview de `README.md` en VS Code

---

## Resumen de dependencias

```
Fase 1 (meta tags) ─────┐
Fase 2 (hero)      ─────┤
Fase 3 (repo README) ───┼──→ Fase 6 (validación)
Fase 4 (pkg.json)  ─────┤
                         │
Fase 4 ──→ Fase 5 (ext README + CHANGELOG)
```

Fases 1, 2, 3, 4 son independientes entre sí.
Fase 5 depende de Fase 4 (necesita número de versión).
Fase 6 depende de todas.

## Commits sugeridos

| Fase | Commit message |
|------|---------------|
| 1 | `fix(site): align title and meta tags with APE identity` |
| 2 | `fix(site): hero tagline and audience honesty` |
| 3 | `fix(readme): lead with value proposition and tagline` |
| 4+5 | `feat(vscode): align branding, clean activationEvents, bump 0.0.5` |
| 6 | No commit propio — es validación |
