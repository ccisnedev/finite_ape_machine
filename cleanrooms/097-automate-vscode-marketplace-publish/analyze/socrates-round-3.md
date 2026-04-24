---
type: analysis
scope: issue
issue: 97
title: "SOCRATES round 3 — Evidence for idempotency"
created: 2026-04-20
status: in-progress
tags: [socrates, evidence, idempotency, marketplace-api, git-diff]
---

# SOCRATES — Ronda 3: Evidencia para la decisión de idempotencia

## Lo que se ha establecido

En las dos rondas anteriores llegamos a decisiones claras:

- **No tags** — los tags son del CLI (`code/cli`), la extensión necesita otro mecanismo.
- **`package.json` version es la fuente de verdad** — porque `vsce publish` lo respeta.
- **El trigger real es un cambio de versión** — no cualquier cambio en `code/vscode/`.

La pregunta pendiente es operativa: **¿CÓMO detecta el workflow que la versión es "nueva"?**

Hay tres candidatos. Antes de elegir, necesitamos evidencia sobre cada uno.

---

## Evidencia recopilada

### 1. Comportamiento de `vsce publish` con versión duplicada

Investigación directa sobre qué ocurre cuando se intenta publicar una versión que ya existe:

> `vsce publish` **falla con error claro** (`ERROR Publishing failed: Version X.Y.Z already exists.`) y **no produce efectos secundarios** — no se sube nada, no se modifica la versión existente, la operación es atómica.

**Implicación**: dejar que `vsce publish` falle es técnicamente seguro. La extensión publicada no se corrompe ni se sobreescribe.

### 2. API del Marketplace — consulta de versión publicada

Ejecuté una consulta real contra la API del Marketplace para la extensión `ccisnedev.ape-vscode`:

```
POST https://marketplace.visualstudio.com/_apis/public/gallery/extensionquery
→ Extension: APE (ccisnedev.ape-vscode)
→ Versión publicada: 0.0.6
→ Total versiones: 1
```

La API funciona y devuelve la versión actual. **Sin embargo**:
- La API es **no oficial/no documentada** — Microsoft la usa internamente pero no la garantiza como contrato público.
- Depende de disponibilidad del Marketplace en el momento del workflow run.

### 3. Git diff para detectar cambio de versión

El historial del repo muestra que se usan **merge commits** (no squash):

```
4de3d32 Merge pull request #95 ...
7a8f3c1 Merge pull request #93 ...
e586181 Merge pull request #89 ...
```

Y los bumps de versión aparecen como commits dedicados:

```
c0da3f2 chore(094): bump vscode extension to 0.0.6
fa46a9a feat(vscode): align branding, clean activationEvents, bump 0.0.5
```

**El problema con `git diff HEAD~1`**: en un merge commit, `HEAD~1` es el primer parent (la punta anterior de `main`), no el commit previo del PR. Esto funciona correctamente para merge commits: `HEAD` tiene la versión nueva, `HEAD~1` tiene la versión anterior en main. **Pero**:
- Si se hacen dos pushes rápidos a main (por ejemplo, dos PRs mergeados casi simultáneamente), el segundo workflow podría ver un `HEAD~1` que ya tiene la versión nueva.
- Si se hace un push directo a main (sin PR), `HEAD~1` sería el commit anterior, que podría o no tener la versión anterior.

### 4. Patrón establecido en este repositorio

`release.yml` usa un patrón probado para el CLI:

```yaml
# Lee versión de pubspec.yaml
VERSION=$(grep '^version:' code/cli/pubspec.yaml ...)
# Compara contra tag remoto
git ls-remote --tags --exit-code origin "refs/tags/$TAG"
```

Este patrón es robusto porque **la fuente de verdad para "¿ya se publicó?" es el propio destino de publicación** (GitHub Releases = tags git). Siguiendo la misma lógica, la fuente de verdad para la extensión debería ser el Marketplace, no un artefacto git.

---

## Lo que NO me queda claro

Veo una tensión entre tres valores: **simplicidad**, **robustez** y **consistencia con el repo**.

- La **opción más simple** es dejar que `vsce publish` falle (no necesita código de detección).
- La **opción más robusta** es consultar el Marketplace (compara contra la fuente de verdad real).
- La **opción más consistente** con el repo sería usar git diff (se parece a cómo release.yml compara versiones).

Pero "consistente con el repo" es un argumento débil si el mecanismo no aplica bien al caso de la extensión.

---

## Preguntas de evidencia

### 1. Sobre la falla controlada como estrategia

`vsce publish` falla limpiamente si la versión existe. Esto es un hecho verificado. Pero **¿es aceptable que el workflow aparezca como "fallido" (❌) en GitHub Actions cuando la realidad es que simplemente no había nada que publicar?**

En `release.yml`, cuando el tag ya existe, el workflow termina con ✅ (éxito) porque el job `check-version` pone `should_release=false` y los jobs dependientes se saltan con `if:`. La ❌ no es solo cosmética — afecta branch protections, notificaciones, y la confianza del equipo en el estado de CI. **¿Hay evidencia de que un workflow rojo por "versión ya publicada" no causaría ruido en la operación diaria del proyecto?** ¿O cada falla inesperada generaría una investigación manual?

### 2. Sobre la fiabilidad del git diff en los patrones de merge de este repo

El repo usa merge commits. Eso significa que `git diff HEAD~1 -- code/vscode/package.json` compararía el merge commit contra el commit anterior de main. Esto parece funcionar... **pero ¿qué pasa si un solo PR contiene DOS bumps de versión** (por ejemplo, se bumpeó de 0.0.6 a 0.0.7 en un commit y luego a 0.0.8 en otro dentro del mismo PR)? El diff solo vería 0.0.6 → 0.0.8, lo cual es correcto para publicar 0.0.8. **Pero ¿qué pasa si el repo cambiara su merge strategy a squash en el futuro?** ¿Se ha considerado si la detección debe ser resiliente a cambios en la estrategia de merge, o si eso sería sobreingeniería para un proyecto en v0.0.6?

### 3. Sobre la dependencia en una API no oficial

La API del Marketplace funciona hoy — lo verifiqué. Devuelve `0.0.6` correctamente. **Pero ¿cuánto nos importa que sea no oficial?** El propio `vsce` CLI consulta esta misma API internamente. Si la API dejara de funcionar, `vsce publish` probablemente también dejaría de funcionar. **¿Es este un riesgo real o un riesgo teórico?** Dicho de otro modo: si el Marketplace está caído, nada funciona de todas formas. ¿Hay algún escenario donde la API de consulta falle pero `vsce publish` siga funcionando?

---

*La elección no es técnica — las tres opciones funcionan. La pregunta es qué tipo de señal quieres que el workflow envíe cuando no hay nada que publicar: ¿silencio (skip), ¿falla roja?, ¿o éxito verde con un log que diga "ya publicado"?*
