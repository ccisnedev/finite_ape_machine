---
id: investigacion-patrones
title: "Investigación de patrones: release multi-OS, PlatformOps vs path, y ci.yaml"
date: 2026-04-18
status: draft
tags: [research, release, ci, platform-ops, path, ripgrep, cross-platform]
author: socrates
---

# Investigación de Patrones

Hallazgos de investigación correspondientes a las preguntas P4, P5 y P6 del análisis socrático. Cada sección documenta la pregunta original, la respuesta del usuario, la investigación realizada, y las tensiones encontradas.

---

## P4: ¿Quién es el dueño del Release?

### Pregunta original

> Si ambos jobs de la matrix intentan crear el GitHub Release, habrá conflicto. ¿Quién crea el release?

### Respuesta del usuario

> "Este no puede ser un problema nuevo, investiga la solución que dan otras herramientas."

### Investigación: patrones reales en proyectos open-source

#### ripgrep (BurntSushi) — Patrón Gold Standard

```
Job 1: create-release (ubuntu-latest)
  → Crea un draft GitHub release via `gh release create $VERSION --draft`
  → Outputs: version (disponible para jobs dependientes)

Job 2: build-release (needs: create-release, strategy.matrix con include)
  → Cada variante de OS construye su binario
  → Cada job sube su asset via `gh release upload $VERSION <archivo>`
  → Windows: ripgrep-$version-x86_64-pc-windows-msvc.zip
  → Linux: ripgrep-$version-x86_64-unknown-linux-musl.tar.gz
  → macOS: ripgrep-$version-x86_64-apple-darwin.tar.gz
```

**Características clave:**
- El release se crea UNA sola vez, en un job dedicado y liviano (ubuntu-latest)
- Se crea como **draft** — no es visible hasta publicación manual
- Los builds corren en paralelo gracias a `needs: create-release`
- Cada build sube su propio asset al release existente
- Escalable: agregar un OS es agregar una entrada en la matrix

#### SwiftFormat (nicklockwood) — Patrón Alternativo

```
Job 1: macos (build + upload-artifact)
Job 2: linux (build + upload-artifact)
Job 3: upload (needs: [macos, linux])
  → Descarga todos los artifacts
  → Los sube al release en un solo paso
```

**Características clave:**
- Usa `upload-artifact` / `download-artifact` en lugar de subir directamente al release
- Un job final centraliza la subida
- Más complejo, más puntos de fallo (artifacts expiran, download puede fallar)

#### Comparación

| Aspecto | ripgrep | SwiftFormat |
|---------|---------|-------------|
| Complejidad | Baja | Media |
| Puntos de fallo | Menos | Más (artifact transfer) |
| Escalabilidad | Alta (matrix) | Media (jobs explícitos) |
| Release creation | Job dedicado (draft) | Implícito o manual |

### Hallazgo crítico para nuestro proyecto

Nuestro `release.yml` actual usa `softprops/action-gh-release@v2`, que **crea el release Y sube assets en un solo step**. Con matrix, esto fallaría porque ambos jobs de OS intentarían crear el mismo tag simultáneamente.

**Implicación:** Debemos reestructurar al patrón ripgrep:
1. Job `create-release` crea un draft release
2. Jobs de build (matrix) suben assets al release existente
3. Se elimina `softprops/action-gh-release@v2` o se usa solo para upload (no creation)

### Tensión no resuelta

ripgrep crea un **draft** release. Esto significa que alguien debe publicarlo manualmente. ¿Queremos eso? El draft permite inspeccionar los artifacts antes de publicar, pero añade un paso manual al proceso. ¿O preferimos que el release sea automático con un job final que publique?

---

## P5: ¿PlatformOps debe incluir path?

### Pregunta original

> Los límites de PlatformOps no están definidos. ¿Debe incluir operaciones de path?

### Respuesta del usuario

> "Pienso que PlatformOps debería incluir al paquete path porque cumplen el mismo objetivo, busquemos información en las buenas prácticas."

### Investigación: uso actual de `package:path` en el codebase

`package:path` se usa extensamente en el proyecto:

- **10 archivos en lib/** lo importan como `import 'package:path/path.dart' as p;`
- **4 archivos en test/** lo usan para construir paths de test
- Funciones usadas: `p.join()`, `p.dirname()`, `p.basename()`, `p.relative()`, `p.extension()`

#### Bugs de path encontrados

**init.dart L147** — Separador hardcoded:
```dart
// Actual (buggy):
path.replaceFirst('$root/', '').replaceFirst('$root\\', '')

// Correcto (cross-platform):
p.relative(path, from: root)
```
Este bug existe porque se hizo manualmente lo que `p.relative()` ya resuelve.

#### Operaciones de shell encontradas (verdaderas dependencias de OS)

| Archivo | Línea | Operación | OS-dependiente |
|---------|-------|-----------|----------------|
| `uninstall.dart` | L112-116 | `Process.runSync('powershell', [...])` — leer variable de entorno | Sí |
| `uninstall.dart` | L123-127 | `Process.runSync('powershell', [...])` — escribir variable de entorno | Sí |
| `upgrade.dart` | L159-163 | `Process.run('powershell', [...])` — Expand-Archive | Sí |
| `upgrade.dart` | L184 | `p.join(installDir, 'bin', 'ape.exe')` — extensión hardcoded | Sí |
| `doctor.dart` | L106 | Inyección de dependencia para `Process.run` | No (ya portable) |

#### Insight del ecosistema Dart

`package:path` es **por diseño** una abstracción cross-platform:
- `p.join('a', 'b')` produce `a\b` en Windows y `a/b` en Linux automáticamente
- `p.context` permite forzar un estilo (Windows/Posix) en tests
- `p.relative()` maneja separadores sin intervención del usuario

### La tensión central

`package:path` **ya es** la abstracción cross-platform para paths. Envolverlo dentro de PlatformOps:

| A favor de envolver | En contra de envolver |
|---------------------|----------------------|
| Superficie cross-platform unificada en un solo lugar | Capa innecesaria sobre algo que ya es cross-platform |
| Consistencia: todo lo de OS pasa por PlatformOps | `p.join()` es más ergonómico que `platformOps.joinPath()` |
| Punto único de control para testing | 10 archivos ya usan `p.` directamente — migración costosa |

**Observación:** Los bugs de path encontrados (init.dart L147) no son problemas de abstracción — son problemas de **no usar** la abstracción que ya existe (`p.relative()`). La solución no es otra capa, sino usar correctamente `package:path`.

**Lo que SÍ necesita PlatformOps** son las operaciones que `package:path` NO resuelve:
- Ejecutar shells (`powershell` vs `bash`)
- Manipular variables de entorno del sistema
- Descomprimir archivos (`Expand-Archive` vs `tar`)
- Extensiones de binarios (`.exe` vs sin extensión)
- Auto-reemplazo del ejecutable en ejecución

---

## P6: ¿Necesitamos ci.yaml?

### Pregunta original

> ¿Dónde se ejecutan los tests actualmente? ¿Se valida en Linux?

### Respuesta del usuario

> "Para desarrollo usaremos WSL, para CI sí debemos usar ubuntu-latest. WSL es mi entorno de desarrollo en Linux."

### Estado actual del CI

| Workflow | Trigger | OS | Función |
|----------|---------|-----|---------|
| `release.yml` | push to main (paths: code/cli/**) | windows-latest | Build + release |
| `pages.yml` | push to main | ubuntu-latest | Deploy site |
| **ci.yaml** | **no existe** | — | — |

### Gaps identificados

1. **No hay CI en Pull Requests.** Los tests no corren hasta que el código llega a main.
2. **No hay tests en Linux.** Nunca se ha ejecutado `dart test` en ubuntu-latest en CI.
3. **Tests y release están acoplados.** Si un test falla, se descubre en el momento del release, no antes.

### Estructura natural propuesta

```
ci.yml — trigger: PR + push to main
  strategy.matrix: [ubuntu-latest, windows-latest]
  steps: dart pub get → dart analyze → dart test

release.yml — trigger: push to main (si versión cambió)
  job: check-version
  job: create-release (draft)
  job: build (matrix) → upload assets
```

### Implicación de WSL como entorno de desarrollo

El usuario desarrollará en WSL (Linux real). Esto significa:
- Los bugs cross-platform se descubrirán en desarrollo, no solo en CI
- WSL ejecuta Linux nativo, pero el filesystem montado en `/mnt/c/` tiene comportamiento NTFS (case-insensitive, permisos Windows)
- Si los tests pasan en WSL pero fallan en ubuntu-latest, el problema está en el filesystem, no en el código
- CI en ubuntu-latest usa ext4 nativo — es la validación definitiva

---

## Preguntas abiertas (Fase EVIDENCE)

Las siguientes preguntas buscan justificación y evalúan la fiabilidad de las decisiones emergentes.

### P7: El patrón ripgrep crea un draft release — ¿debe el nuestro?

ripgrep usa `--draft` deliberadamente: permite inspeccionar binarios antes de publicar. Pero ripgrep tiene millones de usuarios y un mantenedor que revisa cada release manualmente. Nuestro proyecto es más pequeño y el release lo dispara un push a main.

**La pregunta:** ¿Un draft release nos protege de algo concreto, o solo añade fricción? Si el CI ya validó tests en ambos OS, ¿qué información nueva aporta inspeccionar el draft? ¿Hay un escenario donde los tests pasen pero el binario esté mal?

### P8: Si `package:path` ya es cross-platform, ¿qué operaciones ESPECÍFICAS van en PlatformOps?

Hemos dicho que PlatformOps abstraerá "lo que depende del OS". Pero el límite es difuso. `package:path` ya resuelve separadores. `dart:io` ya provee `Platform.isWindows`. `Process.run` ya ejecuta comandos.

**La pregunta:** ¿Puedes enumerar las operaciones concretas (no categorías, sino funciones con nombre y firma) que PlatformOps expondría? Si no puedes listarlas ahora, ¿es señal de que la abstracción se está diseñando antes de entender completamente el problema?

### P9: ¿Qué debe validar ci.yaml más allá de `pub get + analyze + test`?

El CI básico corre tests. Pero tenemos `doctor` que valida el entorno, y tenemos un install script que modifica PATH. ¿Debe ci.yaml ejecutar `ape doctor` como smoke test? ¿O doctor es una herramienta de usuario, no de CI?

**La pregunta:** Si ci.yaml solo corre `dart test`, ¿quién detecta que `ape doctor` dejó de funcionar en Linux? ¿Y si un cambio en upgrade.dart rompe el flujo de instalación en ubuntu — dónde se atrapa eso?
