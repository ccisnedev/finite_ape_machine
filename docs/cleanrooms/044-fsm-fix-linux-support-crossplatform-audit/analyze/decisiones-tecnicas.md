---
id: decisiones-tecnicas
title: "Decisiones técnicas: matrix strategy, PlatformOps, y validación WSL"
date: 2026-04-18
status: draft
tags: [decisions, matrix, platform-ops, wsl, tdd, cross-platform]
author: socrates
---

# Decisiones Técnicas

Resultado de las preguntas Q1–Q3 del análisis socrático. Cada sección documenta la pregunta, la investigación realizada, y la decisión tomada.

## Q1: ¿Colisionan los builds de Linux y Windows en release.yml?

### Pregunta original

> ¿El cambio en release.yml para añadir Linux colisiona con el workaround de Windows Defender?

### Investigación

La práctica recomendada en GitHub Actions para builds multi-OS es `strategy.matrix` con `include`:

```yaml
strategy:
  matrix:
    include:
      - os: windows-latest
        asset_name: ape-windows-x64.zip
        binary: ape.exe
      - os: ubuntu-latest
        asset_name: ape-linux-x64.tar.gz
        binary: ape
```

Cada variante de la matrix ejecuta un job independiente con su propio runner, filesystem, y steps. Los jobs NO comparten estado.

### Decisión

**No colisionan.** El workaround de Defender (limpiar toolcache + re-setup dart) queda aislado en el job de Windows. El job de Linux no lo necesita ni lo ejecuta. Un job `check-version` corre una sola vez; luego ambos builds corren en paralelo.

### Premisa no examinada

La matrix resuelve el build, pero **¿quién crea el GitHub Release?** Si ambos jobs intentan crear el release, habrá conflicto. Esto requiere un job adicional o que solo un job cree el release y el otro suba assets a uno existente.

---

## Q2: ¿Qué abstracción necesitan upgrade/uninstall para ser cross-platform?

### Pregunta original

> ¿Qué significa "cross-platform" para upgrade y uninstall? ¿Implementaciones separadas por OS?

### Investigación

El patrón idiomático en Dart para cross-platform:

1. **Detección:** `Platform.isWindows` / `Platform.isLinux` de `dart:io`
2. **Abstracción:** Clase abstracta (e.g., `PlatformOps`) con métodos como `expandArchive()`, `setPathVariable()`, `selfReplace()`
3. **Implementaciones concretas:** `WindowsPlatformOps`, `LinuxPlatformOps`
4. **Inyección:** El command recibe `PlatformOps` en su constructor; nunca llama a PowerShell directamente

Este patrón es análogo al `platform_channel` de Flutter: un contrato abstracto con backends por OS.

### Decisión

**Abstracción con implementaciones por OS.** Los commands `upgrade` y `uninstall` dependerán de `PlatformOps`, no de llamadas directas a shells del sistema.

### Premisa no examinada

¿Cuáles son los **límites** de `PlatformOps`? No todo comando necesita abstracción:
- `doctor` ejecuta `code --list-extensions` — ¿es esto portable o necesita PlatformOps?
- `init` tiene un backslash hardcoded — ¿es un problema de PlatformOps o del paquete `path`?
- `build.ps1` — ¿se reemplaza por un Dart script o se crea `build.sh` paralelo?

---

## Q3: ¿Es suficiente la auditoría de backslash en init.dart?

### Pregunta original

> ¿Es init.dart línea 78 el único punto con separador hardcoded?

### Investigación

No se puede asumir completitud. El búsqueda de `\\` puede tener falsos negativos (e.g., paths construidos con interpolación, o separadores introducidos por lógica indirecta).

### Decisión

**No asumir nada.** Tres medidas:

1. **Búsqueda exhaustiva** de `\\` en todo el codebase CLI
2. **TDD:** escribir tests que validen paths en ambos OS antes de implementar fixes
3. **Validación en WSL:** ejecutar `dart test` en WSL para confirmar que los tests pasan en entorno Linux real

### Premisa no examinada

¿Son los tests de Dart **deterministas entre OS**? Específicamente:
- Si un test hace `expect(path, equals('foo\\bar'))`, pasará en Windows pero fallará en Linux
- Si un test usa `Platform.pathSeparator` para construir expectations, ¿pierde valor como test cross-platform?
- WSL ejecuta Linux real, pero ¿el filesystem montado en `/mnt/c/` se comporta como ext4 o como NTFS?

---

## Resumen de decisiones

| # | Decisión | Confianza | Riesgo abierto |
|---|----------|-----------|-----------------|
| D1 | Matrix strategy con include per-OS | Alta | ¿Quién crea el Release? |
| D2 | PlatformOps abstracto con impl. por OS | Media | Límites de la abstracción no definidos |
| D3 | TDD + WSL para validación cross-platform | Media | Determinismo de tests entre OS |
