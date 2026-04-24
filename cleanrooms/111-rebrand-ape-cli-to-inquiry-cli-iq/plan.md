---
id: plan
title: "Plan — Rebrand APE CLI to Inquiry CLI"
date: 2026-04-21
status: active
tags: [rebrand, plan, inquiry, iq]
author: DESCARTES
---

# Plan — Rebrand APE CLI to Inquiry CLI (#111)

**Hipótesis:** Si ejecutamos estas 10 fases en este orden, separaremos la identidad del tool (Inquiry/iq) de la metodología (APE) sin romper la cadena CI/CD ni perder historia de Git.

**Falsificación:** Si alguna fase produce un estado donde `dart test` o `npm test` fallan por razones no anticipadas en el plan, se detiene la ejecución y se vuelve a ANALYZE.

---

## Fase 0: Bump de versión y CHANGELOG

**Entrada:** Branch `111-rebrand-ape-cli-to-inquiry-cli-iq` limpio, diagnosis.md comiteado.

**Justificación:** El bump de versión es una dependencia transversal. Hacerlo primero evita que fases posteriores trabajen con la versión vieja (0.0.16) y tengan que parchearlo después. Es la fase más simple y sin dependencias. Se usa v0.1.0 (no v0.0.1) porque el repo se transfiere con toda su historia — los tags v0.0.1 a v0.0.16 ya existen.

- [x] `code/cli/pubspec.yaml`: cambiar `version: 0.0.16` → `version: 0.1.0`
- [x] `code/cli/lib/src/version.dart`: cambiar `const String apeVersion = '0.0.16'` → `const String inquiryVersion = '0.1.0'`
  - Renombrar la constante `apeVersion` → `inquiryVersion`
  - Actualizar el comentario del doc: "Single source of truth for Inquiry CLI version"
- [x] `code/cli/CHANGELOG.md`: añadir entrada `## [0.1.0]` al inicio con:
  ```
  ## [0.1.0]
  ### Changed
  - **Rebrand**: APE CLI renamed to Inquiry CLI (`inquiry` binary, `iq` alias)
  - Config directory changed from `.ape/` to `.inquiry/`
  - Package renamed from `ape_cli` to `inquiry_cli`
  - GitHub org: siliconbrainedmachines, repo: siliconbrainedmachines/inquiry
  ```
- [ ] `code/vscode/package.json`: versión será `0.1.0` (se aplica en Fase 8 junto con otros cambios de extension)
- [x] Buscar todas las referencias a `apeVersion` en el codebase Dart y actualizar a `inquiryVersion`
  - Comando: `grep -rn "apeVersion" code/cli/lib/ code/cli/test/`
  - Archivos esperados: `upgrade.dart`, `version_test.dart`, `version_sync_test.dart`

**Verificación:**
- `grep -rn "0\.0\.16" code/cli/` → 0 resultados
- `grep -rn "apeVersion" code/cli/` → 0 resultados
- `dart analyze` pasa (sin errores de referencia rota)

**Riesgo:** `version_sync_test.dart` compara pubspec ↔ version.dart ↔ site badge. El badge del site se actualiza en Fase 7. Mientras tanto, el test fallará si valida el badge. → Verificar qué valida exactamente el test y ajustar la expectativa si necesario.

---

## Fase 1: Logo — Finalizar assets visuales (AC-8)

**Entrada:** Borrador SVG en Inkscape ya existe (`iq-logo-draft-v1.svg` en directorio de análisis). Decisiones de diseño cerradas: lighthouse `i`, circular `q`, `#5CE6B8` sobre `#0D1117`.

**Justificación:** El logo desbloquea la extensión VS Code (icono), el sitio web (favicon), y el org avatar (AC-12 Step 1). Es parcialmente manual — el usuario finalizará el SVG en Inkscape.

- [x] Finalizar `icon.svg` a partir del borrador: "iq" mark, dark bg `#0D1117`, green accent `#5CE6B8`, legible a 16×16
- [x] Rasterizar `icon.png` (128×128) desde `icon.svg`
  - Herramienta: Inkscape export o `convert` de ImageMagick
- [x] Crear `sidebar.svg`: versión monocromática del "iq" mark para activity bar VS Code (24×24 lógico, sin rellenos, single color)
- [x] Crear `favicon.svg`: "iq" mark optimizado para favicon (16×16 lógico)
- [x] Colocar archivos:
  - [x] `code/vscode/assets/icon.svg` ← reemplaza el actual
  - [x] `code/vscode/assets/icon.png` ← reemplaza el actual
  - [x] `code/vscode/assets/sidebar.svg` ← reemplaza el actual
  - [x] `code/site/img/favicon.svg` ← reemplaza el actual
- [ ] Definir TUI banner ASCII para "Inquiry" / "iq" (3-5 líneas, monospace)
  - Se implementará en código Dart en Fase 2 (donde se toque el TUI)

**Verificación:**
- Los 4 archivos SVG/PNG existen en sus ubicaciones
- `icon.png` es exactamente 128×128 px
- `sidebar.svg` es monocromático (un solo color, sin gradientes)
- Favicon se ve reconocible a tamaño de pestaña de navegador

**Nota:** Esta fase requiere intervención manual del usuario (Inkscape). BASHŌ preparará la estructura y el usuario completará los assets.

---

## Fase 2: CLI Rename — Código Dart (AC-1, AC-2, AC-3)

**Entrada:** Fase 0 completada (versión reseteada). Logo no es bloqueante para esta fase.

**Justificación:** Es el cambio nuclear. Todo lo demás depende de que el binario se llame `inquiry`, el paquete `inquiry_cli`, y el config dir sea `.inquiry/`. Aplicamos TDD: RED (actualizar expectativas en tests) → GREEN (actualizar código).

### 2a: Renombrar paquete Dart y punto de entrada

- [x] `code/cli/pubspec.yaml`: `name: ape_cli` → `name: inquiry_cli`
  - Verificar que `description` se actualice: "CLI for Inquiry — structured development through the APE methodology"
- [x] Renombrar archivo `code/cli/lib/ape_cli.dart` → `code/cli/lib/inquiry_cli.dart`
  - En el contenido: `library;` queda igual
  - Doc comment: "Public API for the `inquiry` CLI"
  - Función: `runApe()` → `runInquiry()`
- [x] `code/cli/bin/main.dart`: actualizar import `package:ape_cli/ape_cli.dart` → `package:inquiry_cli/inquiry_cli.dart`
  - Actualizar llamada: `runApe(arguments)` → `runInquiry(arguments)`
  - Actualizar comentario: "Entry point for the 'inquiry' CLI"
- [x] Buscar y reemplazar TODOS los imports `package:ape_cli/` → `package:inquiry_cli/` en:
  - `code/cli/lib/**/*.dart` (27 archivos)
  - `code/cli/test/**/*.dart` (17 archivos)
  - Comando de auditoría: `grep -rn "package:ape_cli" code/cli/`
- [x] `code/cli/lib/modules/global/commands/upgrade.dart`:
  - User-Agent: `'ape-cli/$apeVersion'` → `'inquiry-cli/$inquiryVersion'` (líneas 99 y 151)
  - Comentarios referencing "ape" como tool → "inquiry"

### 2b: Config directory `.ape/` → `.inquiry/`

- [x] `code/cli/lib/modules/global/commands/init.dart`:
  - Todos los `.ape/` → `.inquiry/` (paths, comments, step messages)
  - `.gitignore` entry: `.ape/` → `.inquiry/`
  - Variables: `apeDir` → `inquiryDir` (si aplica como nombre de variable)
- [x] Buscar `.ape/` en todo el código Dart:
  - `grep -rn "\.ape/" code/cli/lib/` → actualizar cada ocurrencia
  - `grep -rn "\.ape/" code/cli/test/` → actualizar cada ocurrencia
  - Archivos esperados: `init.dart`, posiblemente `linux_platform_ops.dart`

### 2c: Build scripts

- [x] `code/cli/scripts/build.ps1`:
  - Output: `ape.exe` → `inquiry.exe`
  - Comentarios: "ape CLI" → "Inquiry CLI"
  - Comment header: actualizar estructura de output (`build/bin/inquiry.exe`, `agents/inquiry.agent.md`)
- [x] `code/cli/scripts/build.sh`:
  - Output: `ape` → `inquiry`
  - Comentarios: "ape CLI" → "Inquiry CLI"
  - Comment header: actualizar estructura de output

### 2d: Agent file rename

- [x] Renombrar `code/cli/assets/agents/ape.agent.md` → `code/cli/assets/agents/inquiry.agent.md`
- [x] Dentro del archivo: actualizar YAML `name:` field y command references (`ape doctor` → `iq doctor`)
  - **NO** cambiar contenido del FSM ni la metodología APE — solo refs al tool
- [x] Buscar refs al filename `ape.agent.md` en código Dart:
  - `grep -rn "ape.agent" code/cli/lib/ code/cli/test/`
  - Actualizar cada referencia a `inquiry.agent.md`

### 2e: Skill files — command references

- [x] `code/cli/assets/skills/issue-start/SKILL.md`: `ape doctor` → `iq doctor`, cualquier otra ref al binary
- [x] `code/cli/assets/skills/issue-end/SKILL.md`: mismas refs
- [x] `code/cli/assets/skills/memory-read/SKILL.md`: verificar si hay refs (probablemente no)
- [x] `code/cli/assets/skills/memory-write/SKILL.md`: verificar si hay refs (probablemente no)
  - Comando de auditoría: `grep -rn "ape " code/cli/assets/skills/`

### 2f: TUI banner

- [x] Localizar el código que genera el TUI banner (buscar en `code/cli/lib/`)
  - `grep -rn "banner\|ascii\|logo\|tui" code/cli/lib/`
- [x] Actualizar el banner con el nuevo texto "Inquiry" / "iq" definido en Fase 1
- [x] Si hay ASCII art hardcoded, reemplazar con la nueva versión

### 2g: Dart comments audit

- [x] `grep -rn '"ape"' code/cli/lib/` — buscar string literals que referencien "ape" como tool
- [x] `grep -rn "'ape'" code/cli/lib/` — misma búsqueda con single quotes
- [x] Revisar y actualizar cada comentario/doc que diga "ape" refiriéndose al tool (no a la metodología APE)
  - Regla: "APE methodology" / "APE FSM" → se queda. "ape CLI" / "the ape binary" → cambia a "inquiry"

**Verificación:**
- `grep -rn "package:ape_cli" code/cli/` → 0 resultados
- `grep -rn "runApe" code/cli/` → 0 resultados
- `grep -rn "ape\.exe\|bin/ape[^.]" code/cli/scripts/` → 0 resultados
- `grep -rn "ape\.agent" code/cli/` → 0 resultados
- `dart pub get` (en `code/cli/`) resuelve dependencias con nuevo nombre
- `dart analyze` pasa sin errores

**Riesgo:** Los imports rotos se detectan inmediatamente con `dart analyze`. Si algún archivo se omite, el compilador lo reporta.

---

## Fase 3: Tests — Validar el rename (AC-11)

**Entrada:** Fase 2 completada. Todos los imports y refs actualizados. `dart analyze` pasa.

**Justificación:** Los tests son la verificación de que la Fase 2 no rompió nada. Algunos tests tienen expectativas hardcodeadas sobre paths y nombres que necesitan actualización.

### 3a: Actualizar expectativas de tests (RED → GREEN)

- [x] `code/cli/test/init_command_test.dart`:
  - Todas las aserciones `.ape/` → `.inquiry/`
  - `grep -n "\.ape" code/cli/test/init_command_test.dart`
- [x] `code/cli/test/doctor_test.dart`:
  - Verificar si hay checks de nombre de binario → actualizar
  - `grep -n "ape" code/cli/test/doctor_test.dart`
- [x] `code/cli/test/assets_test.dart`:
  - Refs a `ape.agent.md` → `inquiry.agent.md`
  - `grep -n "ape" code/cli/test/assets_test.dart`
- [x] `code/cli/test/target_commands_test.dart`:
  - Refs a agent file → actualizar
  - `grep -n "ape" code/cli/test/target_commands_test.dart`
- [x] `code/cli/test/deployer_test.dart`:
  - Refs a agent file y paths → actualizar
  - `grep -n "ape" code/cli/test/deployer_test.dart`
- [x] `code/cli/test/platform_ops_test.dart`:
  - Refs a `.ape/bin/` → `.inquiry/bin/`
  - `grep -n "\.ape" code/cli/test/platform_ops_test.dart`
- [x] `code/cli/test/scaffold_test.dart`:
  - Verificar si referencia `.ape/` → actualizar
- [x] `code/cli/test/version_test.dart`:
  - `apeVersion` → `inquiryVersion`
- [x] `code/cli/test/version_sync_test.dart`:
  - `apeVersion` → `inquiryVersion` en refs
  - Verificar si valida badge del site (si sí, puede fallar hasta Fase 7)
- [x] `code/cli/test/upgrade_test.dart`:
  - User-Agent strings, refs a binary names
- [x] `code/cli/test/tui_test.dart`:
  - Banner/branding strings
- [x] `code/cli/test/site_test.dart`:
  - Este test valida HTML del site — fallará hasta Fase 7. Documentar que es esperado.
- [x] Auditoría exhaustiva: `grep -rn "ape" code/cli/test/ | grep -v "APE\|ape_builds_ape\|Analyze.Plan.Execute"` para encontrar refs restantes al tool

### 3b: Ejecutar suite completa

- [x] `cd code/cli && dart test` → todos los tests pasan (excepto `site_test.dart` y posiblemente `version_sync_test.dart` si validan el site badge — documentar excepciones)
  - **Resultado:** 155 pass, 2 fail (version_sync_test: site badge aún 0.0.16 → se corrige en Fase 6)
- [x] Si hay fallos inesperados: diagnosticar y corregir antes de continuar

**Verificación:**
- `dart test` reporta 0 failures (o failures documentadas como esperadas por dependencia de fases posteriores)
- Cada test file ha sido auditado con `grep`

**Riesgo:** `site_test.dart` valida contenido del site HTML que aún no se ha actualizado (Fase 7). Si el test es bloqueante, se puede marcar como `@Skip('Pending site update in Phase 7')` temporalmente y quitar el skip en Fase 7. Documentar la desviación.

---

## Fase 4: Install Scripts (AC-4)

**Entrada:** Fase 2 completada (nombres de binario definidos). Fase 3 confirma que el CLI compila y pasa tests.

**Justificación:** Los install scripts dependen de los nombres de binario y asset definidos en Fase 2.

### 4a: PowerShell install scripts

- [ ] `code/cli/scripts/install.ps1`:
  - `$installDir` / paths: `ape` → `inquiry`, `$LOCALAPPDATA\inquiry\bin\`
  - Asset pattern: `ape-windows-x64` → `inquiry-windows-x64`
  - Binary name: `ape.exe` → `inquiry.exe`
  - Repo URL: `ccisnedev/finite_ape_machine` → `siliconbrainedmachines/inquiry`
  - Añadir alias: crear `iq.cmd` en el bin dir con contenido `@"%~dp0inquiry.exe" %*`
    - Batch shim (estándar industria: npm, volta, cargo). No requiere privilegios, funciona en todos los shells, se mantiene sincronizado con upgrades
  - Post-install behavior: mantener actual (`inquiry target get` + `inquiry version`)
  - Success messages: "APE CLI" → "Inquiry CLI"
  - User guidance post-install: sugerir `iq doctor`, `iq init` como siguientes pasos
- [ ] `code/site/install.ps1`:
  - Mismos cambios que arriba (este es el script descargado desde la web)
  - Verificar que ambos scripts sean consistentes

### 4b: Bash install script

- [ ] `code/site/install.sh`:
  - `REPO`: `ccisnedev/finite_ape_machine` → `siliconbrainedmachines/inquiry`
  - `INSTALL_DIR`: `~/.ape` → `~/.inquiry`
  - Asset pattern: `ape-linux-x64` → `inquiry-linux-x64`
  - Binary name: `ape` → `inquiry`
  - Añadir alias: `ln -sf "$BIN_DIR/inquiry" "$BIN_DIR/iq"` (symlink en el bin dir)
  - Añadir symlink en `~/.local/bin/`: `ln -sf "$BIN_DIR/inquiry" "$LINK_DIR/iq"` (junto al existente para `inquiry`)
  - Post-install behavior: mantener actual (`inquiry target get` + `inquiry version`)
  - Success messages: "APE CLI" → "Inquiry CLI"
  - User guidance post-install: sugerir `iq doctor`, `iq init` como siguientes pasos

**Verificación:**
- `grep -rn "ape" code/cli/scripts/install.ps1 code/site/install.ps1 code/site/install.sh | grep -vi "APE methodology\|Analyze.Plan.Execute"` → 0 resultados
- Los scripts son sintácticamente válidos (PowerShell: `pwsh -NoProfile -File install.ps1 -WhatIf` si soporta dry-run; Bash: `bash -n install.sh`)
- Asset names en scripts coinciden con los que producirá `release.yml` (Fase 5)

---

## Fase 5: CI/CD Release Workflow (AC-5)

**Entrada:** Fase 2 (binary names) y Fase 4 (install scripts con nuevos asset names) completadas.

**Justificación:** El workflow de release debe producir assets con los nombres que los install scripts esperan consumir. La dependencia es bidireccional pero los nombres ya están definidos.

### 5a: release.yml

- [x] Matrix strategy: actualizar nombres
  ```yaml
  - os: windows-latest
    asset: inquiry-windows-x64.zip
    binary: inquiry.exe
  - os: ubuntu-latest
    asset: inquiry-linux-x64.tar.gz
    binary: inquiry
  ```
- [x] `dart compile exe bin/main.dart -o build/bin/${{ matrix.binary }}` → ya usa la variable, no necesita cambio en la línea de compile, pero verificar
- [x] Comentarios del workflow: actualizar refs a "ape"
- [x] Windows Defender workaround: no cambia (es sobre `dart.exe`, no el output binary) — pero re-verificar que funciona con `inquiry.exe`
- [x] Repo ref en paths trigger: `code/cli/**` → no cambia (path no contiene "ape")

### 5b: vscode-marketplace.yml

- [x] Query Marketplace step: `ccisnedev.ape-vscode` → `siliconbrainedmachines.inquiry-vscode`
- [x] Publisher: actualizar a `siliconbrainedmachines`
- [x] PAT reference: sigue usando `secrets.VSCE_PAT` (el secret se recreará post-transfer en Fase 6)
- [ ] `.pat-expires` file: actualizar con fecha del nuevo PAT
- [x] working-directory: sigue siendo `code/vscode` → no cambia

**Verificación:**
- `grep -n "ape" .github/workflows/release.yml | grep -vi "APE methodology"` → solo refs en comentarios de Defender workaround (que hablan de `dart.exe`, no `ape.exe`)
- `grep -n "ccisnedev" .github/workflows/` → 0 resultados (todo apunta a `siliconbrainedmachines`)
- Los asset names en `release.yml` matrix coinciden exactamente con los patterns en `install.ps1` y `install.sh`

**Riesgo:** El workflow no se puede testear localmente (necesita GitHub Actions). La verificación es por inspección. El test real ocurre al crear el primer release post-rebrand.

---

## Fase 6: Documentación (AC-10)

**Entrada:** Fases 2-5 completadas. El CLI, tests, scripts y CI están renombrados. URLs aún apuntan a `ccisnedev/finite_ape_machine` (el transfer es Fase 7).

**Justificación:** Actualizar docs ahora (antes del transfer) permite verificar localmente. Los URLs se actualizan a `siliconbrainedmachines/inquiry` anticipando el transfer.

### 6a: README.md (raíz del repo)

- [x] Título: "Finite APE Machine" → "Inquiry CLI"
- [x] Subtítulo/descripción: actualizar
- [x] Install section: URLs apuntan a `siliconbrainedmachines/inquiry`
- [x] Command table: `ape init` → `iq init`, `ape doctor` → `iq doctor`, etc.
- [x] Config dir refs: `.ape/` → `.inquiry/`
- [x] Badge: actualizar versión a v0.1.0 y repo URL

### 6b: Specs

- [x] Renombrar `docs/spec/ape-cli-spec.md` → `docs/spec/inquiry-cli-spec.md`
  - Dentro: todos los `.ape/` → `.inquiry/`, todos los `ape` (como tool) → `inquiry`/`iq`
  - Mantener refs a "APE methodology", "APE FSM" sin cambios
- [x] `docs/spec/index.md`: actualizar referencia al filename renombrado
- [x] `docs/spec/finite-ape-machine.md`: refs al tool (no a la metodología) → actualizar
- [x] Auditoría: `grep -rn "ape" docs/spec/ | grep -vi "APE\|Analyze.Plan.Execute\|ape_builds"` → verificar

### 6c: Otros docs

- [x] `docs/architecture.md`: `.ape/` → `.inquiry/`, command examples
- [x] `docs/roadmap.md`: refs al tool name
- [x] `docs/lore.md`: refs al tool (la metodología se queda como APE)

### 6d: Agent y skill files (contenido, ya renombrados en Fase 2d/2e)

- [x] Verificar que `inquiry.agent.md` tiene contenido actualizado
- [x] Verificar que skill files tienen commands actualizados
- [x] Auditoría final: `grep -rn '"ape"\|ape doctor\|ape init\|ape target' code/cli/assets/` → 0 resultados (excepto refs a "APE methodology")

**Verificación:**
- `grep -rn "finite_ape_machine" docs/ README.md` → 0 resultados (excepto en `docs/issues/` que son históricos)
- `grep -rn "\.ape/" docs/spec/ docs/architecture.md README.md` → 0 resultados
- Los docs son legibles y coherentes (revisión manual)

---

## Fase 7: Org + Repo Transfer + Website (AC-12, AC-9)

**Entrada:** Todas las fases anteriores completadas. Todo el código interno ya referencia `siliconbrainedmachines/inquiry` y `.inquiry/`. Logo disponible.

**Justificación:** El transfer es el punto de no retorno. Debe hacerse después de que todas las refs internas estén actualizadas. El sitio web se actualiza en la misma fase porque depende de las URLs finales.

### 7a: AC-12 Step 1 — Completar org setup

- [ ] Subir avatar del org `siliconbrainedmachines` con el logo Si¹⁴ (depende de Fase 1)
  - **Estado actual:** 3/4 pasos completados, avatar pending

### 7b: AC-12 Step 2 — Rename repo

- [ ] `gh repo rename inquiry` (desde el repo `ccisnedev/finite_ape_machine`)
- [ ] Verificar redirect: `curl -sI https://github.com/ccisnedev/finite_ape_machine` → 301 a `ccisnedev/inquiry`
- [ ] Actualizar local remote: `git remote set-url origin https://github.com/ccisnedev/inquiry.git`

### 7c: AC-12 Step 3 — Transfer repo

- [ ] `gh repo transfer ccisnedev/inquiry siliconbrainedmachines --confirm` (o vía web UI)
- [ ] Verificar redirect chain: `curl -sI https://github.com/ccisnedev/finite_ape_machine` → `siliconbrainedmachines/inquiry`
- [ ] Actualizar local remote: `git remote set-url origin https://github.com/siliconbrainedmachines/inquiry.git`

### 7d: AC-12 Step 4 — Post-transfer setup

- [ ] Recrear secret `VSCE_PAT` en `siliconbrainedmachines/inquiry`:
  - Nuevo PAT en Azure DevOps (All accessible organizations, Marketplace Manage)
  - `gh secret set VSCE_PAT --body "<token>"` (en el repo nuevo)
- [ ] Actualizar `code/vscode/.pat-expires` con nueva fecha de expiración
- [ ] Verificar GitHub Actions: push un commit trivial y confirmar que CI triggers
- [ ] Actualizar repo description: "Inquiry CLI — structured development through the APE methodology"
- [ ] Establecer display name de la org: `Silicon Brained Machines` (Settings → Profile → Name)

### 7e: GitHub Pages + Custom Domain (si14bm.com)

El sitio web se sirve desde GitHub Pages. La URL de instalación actual es `www.ccisne.dev/finite_ape_machine/install.{ps1,sh}`. Debe migrar a `www.si14bm.com/inquiry/install.{ps1,sh}`.

**DNS Configuration:**

- [ ] En el registrador de `si14bm.com`, crear registro CNAME:
  ```
  www.si14bm.com  →  siliconbrainedmachines.github.io
  ```
- [ ] Para apex domain (sin www), crear registros A apuntando a GitHub Pages IPs:
  ```
  185.199.108.153
  185.199.109.153
  185.199.110.153
  185.199.111.153
  ```
- [ ] Verificar propagación DNS: `nslookup www.si14bm.com` → debe resolver a GitHub Pages

**GitHub Pages Configuration:**

- [ ] En repo `siliconbrainedmachines/inquiry` → Settings → Pages:
  - Source: Deploy from a branch → `main` → `/code/site` (o `docs/` según configuración actual)
  - Custom domain: `www.si14bm.com`
  - Enforce HTTPS: ✅
- [ ] Verificar que GitHub genera certificado SSL (puede tardar hasta 24h la primera vez)
- [ ] Crear `code/site/CNAME` con contenido: `www.si14bm.com`

**Verificación DNS + Pages:**

- [ ] `curl -sI https://www.si14bm.com/inquiry/install.ps1` → 200 OK
- [ ] `curl -sI https://www.si14bm.com/inquiry/install.sh` → 200 OK
- [ ] `curl -sI https://www.ccisne.dev/finite_ape_machine/install.ps1` → Verificar si redirect funciona (GitHub Pages redirect antiguo puede seguir activo tras transfer)

**URL de instalación definitiva:**
```
# Windows
irm https://www.si14bm.com/inquiry/install.ps1 | iex

# Linux
curl -fsSL https://www.si14bm.com/inquiry/install.sh | bash
```

**Riesgo DNS:** La propagación DNS puede tardar hasta 48h. Durante ese tiempo, las URLs nuevas no funcionarán. Mitigación: mantener `ccisne.dev` activo como redirect temporal hasta confirmar propagación completa.

### 7f: Website (AC-9)

- [ ] `code/site/index.html`:
  - Title y meta tags → Inquiry branding
  - Install URLs → `www.si14bm.com/inquiry/install.{ps1,sh}`
  - Badge → v0.1.0
  - Heading/hero → Inquiry
- [ ] `code/site/methodology.html`: breadcrumbs, title, meta tags
- [ ] `code/site/agents.html`: breadcrumbs, title, meta tags
- [ ] `code/site/evolution.html`: breadcrumbs, title, meta tags
- [ ] `code/site/ape-builds-ape.html`: breadcrumbs (contenido se queda — es sobre la metodología APE)
- [ ] Favicon: `<link>` apunta al nuevo `img/favicon.svg` (ya colocado en Fase 1)

**Install scripts — actualizar URLs en comentarios de Usage:**
- [ ] `code/site/install.ps1` línea 4: `irm https://www.ccisne.dev/finite_ape_machine/install.ps1 | iex` → `irm https://www.si14bm.com/inquiry/install.ps1 | iex`
- [ ] `code/site/install.sh` línea 5: `curl -fsSL https://www.ccisne.dev/finite_ape_machine/install.sh | bash` → `curl -fsSL https://www.si14bm.com/inquiry/install.sh | bash`

**Auditoría ccisne.dev en codebase (fuera de docs/issues/):**
- [ ] `grep -rn "ccisne\.dev" code/ README.md` → 0 resultados
  - Archivos conocidos: `code/site/install.ps1`, `code/site/install.sh`, `code/vscode/src/installer.ts`, `code/vscode/test/unit/installer.test.ts`, `code/vscode/README.md`, `README.md`
  - Todos deben apuntar a `www.si14bm.com/inquiry/`

### 7g: Tests del site

- [ ] Si `site_test.dart` fue marcado con `@Skip` en Fase 3, quitar el skip ahora
- [ ] `cd code/cli && dart test test/site_test.dart` → pasa
- [ ] `cd code/cli && dart test test/version_sync_test.dart` → pasa (badge actualizado)

**Verificación completa de Fase 7:**
- Repo accesible en `https://github.com/siliconbrainedmachines/inquiry`
- Org display name: `Silicon Brained Machines`
- Org avatar: logo Si¹⁴
- Redirects funcionan desde las URLs antiguas (GitHub + ccisne.dev)
- CI workflow se ejecuta correctamente en el nuevo repo
- `dart test` pasa completo (incluyendo site tests)
- Secret `VSCE_PAT` existe en el nuevo repo
- `https://www.si14bm.com/inquiry/install.ps1` sirve el script correcto con HTTPS
- `https://www.si14bm.com/inquiry/install.sh` sirve el script correcto con HTTPS
- `grep -rn "ccisne\.dev\|ccisnedev\|finite_ape_machine" code/ README.md | grep -v ".inquiry\|docs/issues"` → 0 resultados

**Riesgo:** El transfer pierde secrets y branch protection. El PAT debe recrearse inmediatamente. Si el transfer falla, el repo sigue en `ccisnedev/inquiry` (el rename ya aplicó) y se puede reintentar. DNS puede tardar en propagar — tener fallback.

---

## Fase 8: VS Code Extension — Nueva (AC-6)

**Entrada:** Repo transferido, CI funcional, logo disponible, CLI renombrado.

**Justificación:** La extensión depende de todo lo anterior: nombres de binario (guard.ts), URLs del repo (installer.ts), logo (icon), publisher (nuevo PAT).

### 8a: Crear publisher en VS Code Marketplace

- [ ] Ir a https://marketplace.visualstudio.com/manage → "Create publisher"
  - Publisher ID: `siliconbrainedmachines`
  - Display name: `Silicon Brained Machines`
  - Logo: Si¹⁴ (mismo que org avatar)
- [ ] Crear PAT en Azure DevOps para el nuevo publisher:
  - https://dev.azure.com → avatar → Personal Access Tokens
  - Name: `vscode-marketplace-siliconbrainedmachines`
  - Organization: **All accessible organizations** (obligatorio — org específica causa 403)
  - Scopes: Show all → **Marketplace (Manage)**
  - Expiration: máximo (365 días)
  - Anotar fecha de expiración
- [ ] Verificar acceso: `npx @vscode/vsce login siliconbrainedmachines` con el nuevo PAT → debe autenticar

**Verificación:**
- Publisher visible en https://marketplace.visualstudio.com/publishers/siliconbrainedmachines
- `vsce login` exitoso con el nuevo PAT

### 8b: package.json

- [ ] `"name"`: `"ape-vscode"` → `"inquiry-vscode"`
- [ ] `"displayName"`: `"APE"` → `"Inquiry"`
- [ ] `"publisher"`: `"ccisnedev"` → `"siliconbrainedmachines"`
- [ ] `"version"`: `"0.0.6"` → `"0.1.0"`
- [ ] `"description"`: actualizar a "Inquiry CLI — structured development through the APE methodology for GitHub Copilot"
- [ ] `"repository.url"`: → `"https://github.com/siliconbrainedmachines/inquiry"`
- [ ] `"bugs.url"`: → `"https://github.com/siliconbrainedmachines/inquiry/issues"`
- [ ] `"homepage"`: → `"https://github.com/siliconbrainedmachines/inquiry"`
- [ ] `"activationEvents"`: `"workspaceContains:.ape/"` → `"workspaceContains:.inquiry/"`
- [ ] `"commands"`: todos los `ape.*` → `inquiry.*`:
  - `ape.init` → `inquiry.init` / title: "Inquiry: Init"
  - `ape.toggleEvolution` → `inquiry.toggleEvolution` / title: "Inquiry: Toggle Evolution"
  - `ape.addMutation` → `inquiry.addMutation` / title: "Inquiry: Add Mutation Note"
- [ ] `"keywords"`: actualizar para incluir "inquiry"

### 8c: TypeScript source

- [ ] `code/vscode/src/extension.ts`:
  - Command IDs: `ape.init` → `inquiry.init`, etc.
  - `.ape` folder path → `.inquiry`
  - Cualquier string "APE" referida al tool → "Inquiry"
- [ ] `code/vscode/src/guard.ts`:
  - `getApeBinaryPath()` → `getInquiryBinaryPath()`
  - `isApeInstalled()` → `isInquiryInstalled()`
  - `isApeWorkspace()` → `isInquiryWorkspace()`
  - Paths: `.ape/bin/ape` → `.inquiry/bin/inquiry` (Linux)
  - Paths: `ape\bin\ape.exe` → `inquiry\bin\inquiry.exe` (Windows)
- [ ] `code/vscode/src/commands.ts`:
  - `.ape/config.yaml` → `.inquiry/config.yaml`
  - `.ape/mutations.md` → `.inquiry/mutations.md`
- [ ] `code/vscode/src/installer.ts`:
  - Repo URL: `ccisnedev/finite_ape_machine` → `siliconbrainedmachines/inquiry`
  - **Install base URL**: `const INSTALL_BASE_URL = 'https://www.ccisne.dev/finite_ape_machine'` → `'https://www.si14bm.com/inquiry'`
  - Asset patterns: `ape-windows-x64` → `inquiry-windows-x64`, `ape-linux-x64` → `inquiry-linux-x64`
- [ ] Auditoría: `grep -rn "ape" code/vscode/src/ | grep -vi "APE methodology\|Analyze.Plan"` → 0 resultados
- [ ] Auditoría: `grep -rn "ccisne" code/vscode/src/` → 0 resultados

### 8d: Assets y README

- [ ] Logo files ya colocados en Fase 1 (verificar que existen)
- [ ] `code/vscode/README.md`: reescribir para Inquiry
  - Describir Inquiry, no APE
  - Install instructions con `inquiry`/`iq`
  - Screenshots si aplica
- [ ] `code/vscode/CHANGELOG.md`: nueva entrada v0.1.0

### 8e: Tests VS Code

- [ ] Actualizar tests en `code/vscode/test/` para nuevos nombres:
  - `guard.ts` test expectations
  - Command ID expectations
  - Path expectations
- [ ] `code/vscode/test/unit/installer.test.ts`:
  - Todas las URLs `https://www.ccisne.dev/finite_ape_machine/install.{ps1,sh}` → `https://www.si14bm.com/inquiry/install.{ps1,sh}`
  - Asset pattern expectations actualizadas
  - Al menos 4 aserciones conocidas con la URL vieja
- [ ] Auditoría: `grep -rn "ccisne\|ape-vscode\|ape\.init\|\.ape/" code/vscode/test/` → 0 resultados
- [ ] `cd code/vscode && npm install && npm run test:unit` → pasa

### 8f: Publicar

- [ ] `cd code/vscode && npm run package` → genera `inquiry-vscode-0.1.0.vsix`
- [ ] `vsce publish -p <PAT>` (o dejar que CI lo haga al merge)
- [ ] Verificar en Marketplace: `siliconbrainedmachines.inquiry-vscode` está visible

**Verificación:**
- `grep -rn "ccisnedev\|ape-vscode\|ape\.init\|\.ape/" code/vscode/` → 0 resultados
- `npm run test:unit` pasa
- Extension se empaqueta sin errores
- Extension visible en Marketplace

---

## Fase 9: Deprecar extensión vieja (AC-7)

**Entrada:** Fase 8 completada. La nueva extensión `siliconbrainedmachines.inquiry-vscode` está publicada y verificada en Marketplace.

**Justificación:** Es el último paso. Se ejecuta solo después de confirmar que la nueva extensión funciona.

- [ ] Crear rama temporal o usar la misma rama para el último publish de `ccisnedev.ape-vscode`
- [ ] En `code/vscode/package.json` (versión temporal para deprecation):
  - `"displayName"`: `"APE (Deprecated — use Inquiry)"`
  - `"description"`: `"DEPRECATED: Replaced by Inquiry (siliconbrainedmachines.inquiry-vscode)"`
  - `"extensionDependencies"`: `["siliconbrainedmachines.inquiry-vscode"]`
  - Bump version a `0.0.7` (para que Marketplace lo acepte como update)
  - Vaciar commands y activation events (empty shell)
- [ ] `code/vscode/README.md` (versión temporal): reemplazar con notice de deprecación + link a Inquiry
- [ ] Publicar con el PAT viejo de `ccisnedev`: `vsce publish -p <OLD_PAT>`
  - **Nota:** necesita el PAT del publisher `ccisnedev`, no el nuevo de `siliconbrainedmachines`
- [ ] Verificar en Marketplace que `ccisnedev.ape-vscode` muestra deprecation
- [ ] Revertir los cambios temporales (no queremos el deprecation shell en el repo permanentemente)
  - O: hacer esto en una rama separada que no se mergea

**Verificación:**
- Marketplace muestra "APE (Deprecated — use Inquiry)" con banner
- Instalar `ccisnedev.ape-vscode` trigger auto-install de `siliconbrainedmachines.inquiry-vscode`

**Riesgo:** El PAT viejo de `ccisnedev` podría haber expirado. Verificar antes de intentar publicar. Si expiró, crear uno nuevo temporal.

---

## Fase 10: Retrospectiva del producto

**Entrada:** Todas las fases anteriores completadas.

### Verificación integral

- [ ] `dart test` completo pasa (all green)
- [ ] `npm test` (vscode) pasa
- [ ] Binario `inquiry` compila y ejecuta localmente
- [ ] `iq --version` reporta `0.1.0` (via batch shim en Windows, symlink en Linux)
- [ ] `.inquiry/` se crea con `iq init`
- [ ] Nuevo repo accessible en `https://github.com/siliconbrainedmachines/inquiry`
- [ ] Org display name: `Silicon Brained Machines`, avatar: Si¹⁴
- [ ] Nueva extensión publicada: `siliconbrainedmachines.inquiry-vscode` en Marketplace
- [ ] Vieja extensión deprecada: `ccisnedev.ape-vscode` con banner
- [ ] Install URL funciona: `irm https://www.si14bm.com/inquiry/install.ps1 | iex` (o dry-run equivalente)
- [ ] Install URL funciona: `curl -fsSL https://www.si14bm.com/inquiry/install.sh | bash` (o dry-run equivalente)
- [ ] Publisher verificable: https://marketplace.visualstudio.com/publishers/siliconbrainedmachines

### Auditoría final (zero legacy)

- [ ] `grep -rn "ccisne\.dev\|ccisnedev\|finite_ape_machine" code/ README.md | grep -v "docs/issues"` → 0 resultados
- [ ] `grep -rn "ape-vscode\|ape\.init\|ape\.exe\|bin/ape[^.]" code/ | grep -vi "APE methodology\|Analyze.Plan\|docs/issues"` → 0 resultados
- [ ] `grep -rn "\.ape/" code/ | grep -v "docs/issues"` → 0 resultados

### Retrospectiva

- [ ] Producir `retrospective.md` en `docs/issues/111-rebrand-ape-cli-to-inquiry-cli-iq/`

---

## Resumen de dependencias

```
Fase 0 (version reset) ─────────────────────────────┐
Fase 1 (logo) ──────────────────────────────────┐    │
                                                 │    │
Fase 2 (CLI rename) ◄───────────────────────────┼────┘
    │                                            │
    ▼                                            │
Fase 3 (tests) ◄────────────────────────────────┤
    │                                            │
    ▼                                            │
Fase 4 (install scripts)                         │
    │                                            │
    ▼                                            │
Fase 5 (CI/CD)                                   │
    │                                            │
    ▼                                            │
Fase 6 (docs)                                    │
    │                                            │
    ▼                                            │
Fase 7 (org + transfer + website) ◄──────────────┘
    │
    ▼
Fase 8 (VS Code extension nueva)
    │
    ▼
Fase 9 (deprecar extensión vieja)
    │
    ▼
Fase 10 (retrospectiva)
```

**Leyenda:** Fase 0 y Fase 1 son paralelas. Fase 1 (logo) es bloqueante para Fase 7 (avatar del org) y Fase 8 (extension icon). Fases 2-6 son secuenciales y no necesitan el logo. Fase 7 en adelante necesita todo.

---

## Commits esperados

| Fase | Commit message |
|------|---------------|
| 0 | `chore(111): bump version to 0.1.0 for rebrand` |
| 1 | `feat(111): add iq logo assets (icon, sidebar, favicon)` |
| 2 | `refactor(111): rename ape_cli to inquiry_cli, .ape to .inquiry` |
| 3 | `test(111): update all test expectations for inquiry rebrand` |
| 4 | `fix(111): update install scripts for inquiry binary and alias` |
| 5 | `ci(111): update release and marketplace workflows for inquiry` |
| 6 | `docs(111): update README, specs, agent, skill files for inquiry` |
| 7 | `feat(111): update website and complete org transfer` |
| 8 | `feat(111): publish inquiry-vscode extension` |
| 9 | `chore(111): deprecate ccisnedev.ape-vscode extension` |
| 10 | `docs(111): add product retrospective` |
