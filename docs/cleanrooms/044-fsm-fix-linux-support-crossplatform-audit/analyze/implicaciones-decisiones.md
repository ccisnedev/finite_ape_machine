---
id: implicaciones-decisiones
title: "Implicaciones de las decisiones P7–P9: release, PlatformOps, y CI"
date: 2026-04-18
status: draft
tags: [implications, release, platform-ops, ci, testing, fsm, cross-platform]
author: socrates
---

# Implicaciones de las Decisiones

Análisis de implicaciones correspondiente a las preguntas P7, P8 y P9 del análisis socrático. Para cada decisión, exploramos: *"Si esto es cierto, ¿qué más debe ser cierto?"*

---

## P7: No draft release — auto-publish directamente

### Decisión

El release se publica automáticamente al crearse. No hay paso intermedio de draft. El job `create-release` crea un release publicado; los jobs de build suben assets.

### Implicación 1: La ventana de release incompleto es visible

Si el release se publica antes de que los builds terminen, durante unos minutos existirá un release publicado sin binarios (o con binarios parciales). Cualquiera que mire la página de releases en ese intervalo verá un release "vacío".

**¿Es esto un problema real?** Para un proyecto con pocos usuarios y releases infrecuentes, probablemente no. Pero si `ape upgrade` consulta la API de GitHub en ese instante exacto, podría encontrar un release sin el asset que necesita.

**Lo que debe ser cierto:** `ape upgrade` debe manejar gracefully el caso donde el release existe pero el asset para su plataforma aún no está disponible. Un mensaje como *"Release v0.0.11 found, but asset for linux-x64 is not yet available. Try again in a few minutes."* es preferible a un crash.

### Implicación 2: No hay rollback humano antes de publicar

Con draft, un humano puede inspeccionar los artifacts antes de publicar. Sin draft, si el build produce un binario corrupto, ya está publicado. El rollback es borrar el release y re-ejecutar el workflow.

**Lo que debe ser cierto:** La confianza en que el binario es correcto viene de los TESTS, no de inspección manual. Esto refuerza la necesidad de CI robusto (ver P9).

### Implicación 3: El tag es el gatillo definitivo

Sin draft, el flujo es: push tag → create release → build → upload. El tag es el punto de no retorno. No hay "cancelar" después de pushear el tag.

**Lo que debe ser cierto:** El proceso de tagging debe ser deliberado. No accidental. Idealmente, el tag sólo se pushea cuando main ya está verde.

---

## P8: PlatformOps con ~7 métodos concretos

### Decisión

`PlatformOps` es una abstracción de ejecución de scripts: `.ps1` en Windows, `.sh` en Linux. Los métodos son operaciones de alto nivel (`expandArchive`, `getEnvVariable`, `setEnvVariable`, `selfReplace`, `binaryName`, `assetName`, `runPostInstall`).

### Implicación 1: Cada método requiere DOS implementaciones validadas

7 métodos × 2 plataformas = 14 implementaciones concretas. Cada una con sus edge cases propios. `selfReplace` en Windows tiene el problema del archivo bloqueado (el exe en ejecución no se puede sobreescribir). `expandArchive` en Linux asume `tar` disponible.

**Lo que debe ser cierto:** Cada método debe tener tests que corran en su plataforma nativa. No se puede testear `WindowsPlatformOps.selfReplace` en Linux ni `LinuxPlatformOps.expandArchive` en Windows. Esto tiene implicaciones directas para CI (matrix obligatorio).

### Implicación 2: La inyección de dependencia se vuelve obligatoria

Si los comandos (`upgrade`, `init`, `doctor`) usan `PlatformOps`, necesitan recibirlo como dependencia. Actualmente `doctor.dart` usa un patrón ad-hoc (`_runProcess` como parámetro). Con PlatformOps, esto se formaliza.

**Lo que debe ser cierto:** Debe existir UN patrón consistente de DI para todos los comandos. Si `doctor` recibe `PlatformOps` por constructor, `upgrade` también. Si `init` usa `p.relative()` (que no necesita PlatformOps), queda claro que PlatformOps NO se usa para paths.

**Tensión:** ¿Quién instancia `PlatformOps`? ¿Un factory global `PlatformOps.current()` que detecta `Platform.isWindows`? ¿O se pasa desde `main()`? La respuesta afecta la testabilidad.

### Implicación 3: Los scripts (.ps1 / .sh) se vuelven artefactos de primera clase

Si PlatformOps ejecuta scripts, esos scripts deben vivir en el proyecto, versionarse, y probablemente empaquetarse con el binario compilado. Un `Expand-Archive` inline en Dart es diferente de un `scripts/install.ps1` que se invoca.

**Lo que debe ser cierto:** Debe estar claro si PlatformOps ejecuta comandos INLINE (via `Process.run('tar', ['-xzf', ...])`) o invoca SCRIPTS empaquetados. Esto afecta el compilado: `dart compile exe` no empaqueta archivos adjuntos.

**Observación:** Si los comandos son inline (`Process.run`), entonces PlatformOps no "ejecuta scripts" — ejecuta *comandos de shell*. La diferencia importa para el empaquetado y la distribución.

### Implicación 4: El boundary `PlatformOps` vs `package:path` debe ser explícito

La decisión dice: PlatformOps para shell operations, `package:path` para paths. Pero hay zonas grises. `setEnvVariable` modifica `~/.bashrc` en Linux — eso involucra un path Y una operación de shell.

**Lo que debe ser cierto:** La regla debe ser: "Si involucra `Process.run` o shell-specific syntax, es PlatformOps. Si es manipulación de strings de paths, es `package:path`." Los comandos que usan ambos (como `setEnvVariable` que necesita el path a `.bashrc` Y escribir en él) usan AMBOS sin conflicto.

---

## P9: ci.yaml como red de seguridad

### Decisión

El desarrollo valida en Windows + WSL. CI es confirmación. Matrix: `[ubuntu-latest, windows-latest]`.

### Implicación 1: El gap actual es total

Hoy no hay CI en PRs. Ni siquiera en push a main (release.yml sólo corre en tags). Esto significa que CUALQUIER ci.yaml, por mínimo que sea, es una mejora infinita sobre el estado actual.

**Lo que debe ser cierto:** No hay que sobre-diseñar ci.yaml. Un `dart test` en matrix es suficiente como primer paso.

### Implicación 2: CI en matrix duplica el coste de minutos

Dos runners (ubuntu + windows) = 2× minutos de GitHub Actions. Para un proyecto personal esto es despreciable. Pero el runner de Windows es ~2× más lento que Linux para las mismas operaciones.

**Lo que debe ser cierto:** El presupuesto de minutos de Actions debe ser suficiente. Para repos privados, el free tier tiene límites. Para repos públicos, no hay límite.

### Implicación 3: "Código ya depurado" es una promesa, no una garantía

El usuario dice que el código llega depurado a CI porque se testea en ambos entornos durante desarrollo. Pero ¿qué pasa cuando hay prisa? ¿Cuando se hace un hotfix y se salta el ciclo WSL? CI es precisamente la red para esos momentos.

**Lo que debe ser cierto:** CI debe BLOQUEAR el merge si falla. Si CI es sólo informativo (permite merge aunque falle), no es una red de seguridad — es decoración. Esto implica branch protection rules en GitHub.

### Implicación 4: release.yml y ci.yaml tienen responsabilidades distintas

- `ci.yaml`: valida código en PR/push. `dart analyze` + `dart test` en matrix.
- `release.yml`: compila y publica en tag. Build en matrix + upload assets.

**Lo que debe ser cierto:** `release.yml` NO necesita re-ejecutar tests (ya pasaron en CI antes del merge). Pero actualmente release.yml SÍ ejecuta tests. ¿Se eliminan de release.yml una vez que ci.yaml existe? ¿O se mantienen como doble validación?

---

## Implicación transversal: ¿Y el FSM fix?

El issue #44 tiene CUATRO componentes en su título: *"FSM fix + Linux support + cross-platform audit + doctor VS Code check"*. El análisis socrático ha profundizado extensamente en Linux support, cross-platform (PlatformOps, paths, CI), y release workflow. Pero el FSM fix (issues #43, #30, #32) apenas se ha mencionado.

**Lo que debe ser cierto:** El plan de ejecución debe incluir los cambios concretos del FSM fix. Si no se han analizado, hay un punto ciego. Los issues #30 y #32 (referenced en #43) pueden tener cambios de lógica que interactúan con los cambios cross-platform.

---

## Preguntas abiertas para resolución

Estas implicaciones generan tres preguntas finales que requieren respuesta antes de pasar a planificación:

1. **Testabilidad de PlatformOps** — ¿Quién provee el mock/fake para tests? ¿Se extiende el patrón DI de doctor.dart a todos los comandos?
2. **Alcance mínimo de ci.yaml** — ¿Solo `dart test`? ¿También `dart analyze`? ¿Smoke tests?
3. **FSM fix** — ¿Cuáles son los cambios concretos de código? ¿Interactúan con los cambios cross-platform?
