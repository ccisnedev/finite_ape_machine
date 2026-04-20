---
type: analysis
scope: issue
issue: 97
title: "SOCRATES round 2 — Challenging assumptions"
created: 2026-04-20
status: in-progress
tags: [socrates, assumptions, marketplace, versioning]
---

# SOCRATES — Ronda 2: Desafiando supuestos

## Lo que entiendo hasta ahora

El modelo que se ha descrito es claro en su intención:

1. Push a `main` con cambios en `code/vscode/**`
2. Leer versión de `package.json`
3. Si la versión es nueva → tests unitarios (Windows + Linux) → `vsce publish`
4. Secreto `VSCE_PAT` configurado en el repo

El patrón sigue la lógica de `release.yml`: "si la versión cambió, publicar". Pero al examinar los detalles, encuentro **premisas ocultas** que merecen ser cuestionadas.

---

## Premisa 1: "Comparar contra un tag git es suficiente para saber si hay que publicar"

En `release.yml`, el mecanismo de idempotencia es: leer versión de `pubspec.yaml`, buscar si existe el tag `vX.Y.Z` en el remoto. Si no existe → publicar.

Pero aquí hay una diferencia fundamental: **el CLI se publica en GitHub Releases (que son tags git), pero la extensión se publica en el VS Code Marketplace, que es un sistema externo con su propio registro de versiones.**

Preguntas:

- **¿Qué pasa si alguien publica manualmente una versión al Marketplace sin pasar por el workflow?** El tag git no existiría, pero la versión ya estaría publicada. El workflow intentaría publicar de nuevo y fallaría (o peor, sobrescribiría algo).
- **¿Qué pasa si se crea el tag pero `vsce publish` falla a medio camino?** Quedaría el tag creado pero la versión no publicada. En el próximo push, el workflow vería el tag y pensaría "ya está publicado" — cuando no lo está.
- **¿Debería el workflow verificar contra el Marketplace directamente** (por ejemplo, `vsce show ccisnedev.ape-vscode --json` y comparar versiones) en lugar de contra tags?

**La pregunta de fondo: ¿Este workflow siquiera necesita tags?** El Marketplace es la fuente de verdad para la extensión. Un tag git es la fuente de verdad para un GitHub Release. Si la extensión no genera un GitHub Release, ¿para qué crear un tag?

---

## Premisa 2: "Si los tests pasan y la versión cambió, la extensión está lista para publicar"

Esto asume que un bump de versión en `package.json` es una **señal intencional de publicación**. Pero:

- **¿Qué pasa si alguien sube la versión como parte de un PR que todavía está en progreso?** Un merge a main con versión bumpeada pero con código incompleto en otros archivos del mismo PR triggearía el publish.
- **¿Qué pasa si se necesita publicar un hotfix que no toca `code/vscode/**`?** Por ejemplo, un cambio solo en el workflow file. El path filter no dispararía.
- **¿La versión `0.0.6` sugiere que estamos en fase pre-1.0?** Si es así, ¿tiene sentido tener un mecanismo de pre-release (`--pre-release` flag de `vsce`) para distinguir versiones estables de experimentales? ¿O en esta etapa toda publicación es inherentemente "pre-release"?

---

## Premisa 3: "Si se publica una versión mala, se puede arreglar publicando otra"

El Marketplace de VS Code permite despublicar versiones, pero no es inmediato ni trivial. Mientras tanto:

- Los usuarios con auto-update recibirían la versión defectuosa.
- No hay un mecanismo de rollback automático — solo "publicar una versión más alta".

**¿El workflow necesita algún mecanismo de protección adicional**, como:
- ¿Un paso de "dry-run" (`vsce package` sin `publish`) para validar que el paquete se construye correctamente antes de intentar publicar?
- ¿O eso ya está cubierto por el script `package` que hace `webpack --mode production && vsce package`?

---

## Preguntas para profundizar

1. **Sobre la fuente de verdad**: Dijimos que este workflow es *separado* de `release.yml` y no genera GitHub Releases. Si el Marketplace es el único destino, **¿tiene sentido que el mecanismo de idempotencia sea un tag git, o debería ser una consulta directa al Marketplace?** Esto simplificaría el workflow (sin necesidad de permisos `contents: write` para crear tags) pero agregaría una dependencia en la API del Marketplace.

2. **Sobre el significado de la versión**: La versión actual es `0.0.6`. **¿El bump de versión en `package.json` es siempre una decisión deliberada de "quiero publicar esto"?** ¿O existe el riesgo de que alguien cambie la versión sin intención de publicar inmediatamente? Si el bump es siempre deliberado, entonces el modelo es correcto. Si no, necesitamos algo más (como un tag manual, o un `workflow_dispatch`).

3. **Sobre la relación entre los flujos**: La extensión VS Code depende de los skills/prompts que también viven en este repo. **¿Un cambio en `code/cli/` o en `docs/` podría requerir una nueva publicación de la extensión sin tocar `code/vscode/`?** Si es así, el path filter `code/vscode/**` sería insuficiente como trigger.

---

*No propongo soluciones — eso viene después. La pregunta es si estos supuestos son sólidos o si alguno necesita ajuste antes de diseñar el workflow.*
