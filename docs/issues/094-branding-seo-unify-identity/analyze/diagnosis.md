---
id: diagnosis
title: "Diagnóstico: unificación de branding y SEO en APE"
date: 2026-04-19
status: active
tags: [branding, seo, identity, diagnosis]
author: socrates
---

# Diagnóstico: unificación de branding y SEO en APE

## 1. Problema definido

APE tiene tres touchpoints públicos — sitio web, extensión de VS Code y README del repositorio — que comunican identidades inconsistentes. El resultado es fricción de descubrimiento (SEO débil, keywords genéricos) y disonancia de marca (el usuario encuentra mensajes distintos según dónde llegue).

### 1.1 Síntomas concretos

| Touchpoint | Síntoma | Impacto |
|---|---|---|
| Sitio (`code/site`) | Título largo ("Finite APE Machine"), meta description genérica, hero promete compatibilidad con "any AI coding agent" | SEO diluido; promesa falsa (solo funciona con Copilot) |
| Extensión (`code/vscode`) | README es lista de features sin propuesta de valor; keywords no apuntan a búsquedas reales del Marketplace | Baja conversión de instalación; invisible en búsquedas relevantes |
| Repo README | No alineado con branding; no lidera con propuesta de valor | Primera impresión técnica desconectada del resto |

### 1.2 Causa raíz

No existía una jerarquía de identidad definida. El nombre formal ("Finite APE Machine"), la marca ("APE"), el tagline y los beneficios crecieron orgánicamente sin un sistema que los conecte.

El descubrimiento clave del análisis socrático es que **"Analyze. Plan. Execute."** es simultáneamente:

- La expansión del acrónimo A.P.E.
- La descripción del proceso
- La promesa de beneficio (estructura que evita tiempo perdido)
- El onboarding (el nombre enseña el método)

Esta convergencia semántica es rara y valiosa. Funciona como "Just Do It": ofrece la aspiración, no el dolor.

## 2. Decisiones tomadas

Cada decisión fue validada a lo largo de 6 rondas de análisis socrático.

### D1: Jerarquía de identidad

| Nivel | Elemento | Uso |
|---|---|---|
| Marca | **APE** | Siempre visible: h1 del sitio, displayName de la extensión, CLI |
| Tagline | **Analyze. Plan. Execute.** | Siempre acompaña a la marca |
| Nombre formal | **Finite APE Machine** | README del repo (h1), sección "About", contextos formales |

**Justificación:** Ronda 1-2. El nombre formal es el proyecto; la marca es el producto. Separar ambos permite comunicación concisa sin perder identidad.

### D2: Tagline único — "Analyze. Plan. Execute."

**Se descarta** "Methodology over model" como tagline.

**Justificación:** Ronda 3-4. "Methodology over model" es una afirmación filosófica sin evidencia de adopción externa. Es válida como copy en secciones de filosofía, pero no como branding primario. "Analyze. Plan. Execute." ya cumple la función de tagline, proceso y beneficio en una sola frase.

### D3: Audiencia honesta — Copilot hoy, más targets pronto

El messaging actual DEBE reflejar que APE funciona actualmente con GitHub Copilot, con más targets en camino. Las referencias a "any AI coding agent" o "frontier or free" son incorrectas y deben corregirse con fórmula: **"Currently available for GitHub Copilot. More targets coming soon."**

**Justificación:** Ronda 2 y 6. La honestidad protege credibilidad. Un usuario que instala esperando compatibilidad con Claude Code o Cursor y no la encuentra genera frustración y desinstalaciones. La fórmula "more targets coming soon" mantiene la aspiración sin mentir.

**Inventario de correcciones necesarias:**

| Archivo | Texto actual | Acción |
|---|---|---|
| `code/site/index.html` línea 7 | `meta description`: "Works with frontier and free models alike." | Reemplazar con messaging Copilot + más targets |
| `code/site/index.html` línea 11 | `og:description`: "Ship software with any AI coding agent — frontier or free." | Reemplazar |
| `code/site/index.html` línea 18 | `twitter:description`: "Ship software with any AI coding agent — frontier or free." | Reemplazar |
| `code/site/index.html` línea 34 | `primary-tagline`: "Ship software with any AI coding agent — frontier or free." | Reemplazar |
| `code/site/index.html` línea 35 | `secondary-tagline`: "Infinite monkeys produce noise. Finite APEs produce software." | Eliminar |
| `code/site/index.html` línea 67 | `intro`: "methodology over model" | Mantener como copy filosófico, no como branding |
| `README.md` línea 3 | blockquote: "Infinite monkeys produce noise. Finite APEs produce software." | Eliminar |

### D4: Pain point latente → trabajo de content marketing, no de tagline

El dolor que APE resuelve (tiempo perdido corrigiendo output de IA) es latente: los usuarios no lo reconocen activamente. Articular ese dolor es trabajo de contenido (blog, talks, copy del sitio), NO del tagline.

**Justificación:** Ronda 4-5. El tagline "Analyze. Plan. Execute." ofrece aspiración, no diagnóstico. Intentar meter el pain point en el tagline lo debilita.

### D5: Touchpoints coherentes pero no idénticos

| Touchpoint | Función | Nivel de detalle |
|---|---|---|
| Sitio | Experiencia completa, storytelling, secciones | Máximo |
| Extension README | Landing page del Marketplace | Conciso, orientado a acción |
| Repo README | Documentación técnica | Técnico, nombre formal, valor primero |

**Justificación:** Ronda 5-6. Cada superficie tiene su audiencia y contexto. Copiar el mismo texto en los tres destruye la efectividad de cada uno.

### D6: Título del sitio

```
APE — Analyze. Plan. Execute.
```

**Justificación:** Ronda 1. Conciso, SEO-friendly, marca + tagline en `<title>`.

## 3. Constraints y riesgos

### 3.1 Constraints

| Constraint | Impacto |
|---|---|
| Solo Copilot | Todo claim de compatibilidad multi-agente debe eliminarse o calificarse como futuro |
| Sin datos de usuarios externos | Los beneficios citados se basan en uso propio (APE builds APE) e investigación existente, no en métricas de adopción |
| Extension ya publicada | Cambios en `package.json` (keywords, description) afectan a usuarios existentes — requieren version bump |
| Coherencia ≠ identidad | Cambios de branding deben propagarse a TODOS los touchpoints en el mismo release |

### 3.2 Riesgos

| Riesgo | Probabilidad | Mitigación |
|---|---|---|
| Keywords nuevos no mejoran ranking en Marketplace | Media | Basados en términos reales de búsqueda; medir en 30 días |
| Rewrite del extension README no mejora conversión | Media | A/B no es posible en Marketplace; iterar basado en install rate |
| Corrección "Copilot-only" reduce percepción de alcance | Baja | Honestidad > inflación; la aspiración multi-agente se puede comunicar como roadmap |
| Scope creep: reescribir todo el sitio | Alta | Limitar a meta tags, hero, y claims incorrectos. Contenido profundo es otro issue |

## 4. Scope

### 4.1 ENTRA en scope

1. **Extension `package.json`:** description (sin prefijo APE, ya está en displayName), keywords (`agent`, `github-copilot`, `copilot`, `ai`, `methodology`)
2. **Extension README:** rewrite estilo landing page — diagrama FSM, `@ape` en Copilot, fases con outputs, propuesta de valor clara
3. **Sitio `<title>`:** `APE — Analyze. Plan. Execute.`
4. **Sitio meta tags:** `og:title`, `og:description`, `twitter:title`, `twitter:description` alineados con nuevo tagline
5. **Sitio hero:** corrección de "any AI coding agent" → "Currently available for GitHub Copilot. More targets coming soon."
6. **Sitio secondary-tagline:** eliminar "Infinite monkeys produce noise. Finite APEs produce software."
7. **Repo README:** eliminar blockquote de monos; abrir con propuesta de valor, "Analyze. Plan. Execute." visible, mantener profundidad técnica
8. **Validación:** todos los tests existentes pasan (CLI 131 + vscode 59)

### 4.2 NO entra en scope

1. Reescritura completa de páginas del sitio (methodology.html, evolution.html, agents.html) — issue separado si se necesita
2. Creación de contenido nuevo (blog, artículos sobre pain point latente)
3. Cambios en el CLI o su branding
4. Diseño visual / identidad gráfica (logo, colores, tipografía)
5. ~~Frase "Infinite monkeys produce noise. Finite APEs produce software."~~ — ELIMINAR de touchpoints de branding (repo README blockquote, site secondary-tagline). Se conserva en docs internos (spec, research paper, banner spec) sin cambios activos
6. "Methodology over model" como tagline — descartada como branding, puede aparecer en copy filosófico existente sin cambios activos

## 5. Jerarquía de messaging — referencia para PLAN

```
┌─────────────────────────────────────────┐
│  APE                          (marca)   │
│  Analyze. Plan. Execute.    (tagline)   │
├─────────────────────────────────────────┤
│  Sitio: storytelling completo           │
│  Extension: landing page concisa        │
│  Repo: técnico, valor primero           │
├─────────────────────────────────────────┤
│  Finite APE Machine     (nombre formal) │
│  → repo h1, about, contextos formales   │
└─────────────────────────────────────────┘
```

## 6. Referencias

- Issue #94: "Branding & SEO — unify identity across site, extension, and repo"
- ADR-0002: ape-builds-ape (evidencia de uso propio como validación)
- 6 rondas de análisis socrático (abril 2026) — convergencia en identidad, audiencia, beneficio, pain point, touchpoints, messaging
- Investigación existente sobre productividad con IA y tiempo de corrección (referencia genérica — el usuario confirma que existe pero no se citó fuente específica)
