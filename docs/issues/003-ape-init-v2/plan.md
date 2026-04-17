# Plan — ape target get v0.0.2

Issue: #1
Branch: `issue-1/ape-target-get-v002`
Análisis aprobado: `dcbaac6`

---

## Fase 0: Limpiar config global legacy

Eliminar symlinks en `~/.copilot/` que apuntan al repo `ccisnedev/ai`.

- [x] 0.1 Eliminar `~/.copilot/skills/memory-read` (symlink)
- [x] 0.2 Eliminar `~/.copilot/skills/memory-write` (symlink)
- [x] 0.3 Eliminar `~/.copilot/instructions/coding-manifesto.instructions.md` (symlink)

---

## Fase 1: Assets — clase y archivos fuente

Entregable E1. Sin dependencias.

### 1.1 Tests de Assets

```dart
group('Assets', () {

  test('loadString reads a file relative to a given root', () {
    // Arrange: crear tempDir/assets/agents/ape.agent.md con contenido conocido
    // Act: instanciar Assets con root = tempDir, llamar loadString('agents/ape.agent.md')
    // Assert: el contenido leído == el contenido escrito
  });

  test('loadString throws when file does not exist', () {
    // Arrange: crear tempDir vacío
    // Act + Assert: loadString('nonexistent.md') lanza FileSystemException
  });

  test('path resolves correctly under assets/', () {
    // Arrange: Assets con root = '/fake/root'
    // Act: path('agents/ape.agent.md')
    // Assert: '/fake/root/assets/agents/ape.agent.md'
  });
});
```

**Nota de diseño:** La clase `Assets` acepta `root` como parámetro (inyectado), no lo deduce de `Platform.resolvedExecutable`. En producción se pasa `p.dirname(p.dirname(Platform.resolvedExecutable))`. En tests se pasa un `tempDir`. Esto evita depender del ejecutable real durante tests.

- [ ] 1.1 Escribir tests de `Assets` → RED
- [ ] 1.2 Implementar clase `Assets` en `lib/assets.dart` → GREEN
- [ ] 1.3 Crear archivos `.md` fuente en `assets/`
  - `assets/agents/ape.agent.md` (copiar desde `ccisnedev/ai`)
  - `assets/skills/memory-read/SKILL.md` (copiar desde `ccisnedev/ai`)
  - `assets/skills/memory-write/SKILL.md` (copiar desde `ccisnedev/ai`)
- [ ] 1.4 Test de integración: `Assets` lee los archivos reales de `assets/`
- [ ] Commit: `feat(assets): clase Assets + archivos .md fuente — refs #1`

---

## Fase 2: Adapter pattern — interfaz y 5 implementaciones

Entregable E2. Sin dependencias (paralelo a E1).

### 2.1 Tests de la interfaz TargetAdapter

```dart
group('TargetAdapter implementations', () {

  // Para cada adapter (copilot, claude, codex, crush, gemini):
  for (final adapter in allAdapters) {

    test('${adapter.name} returns non-empty skillsDirectory', () {
      final skillsDir = adapter.skillsDirectory('/home/user');
      expect(skillsDir, isNotEmpty);
      expect(skillsDir, contains(adapter.name) | contains(adapter.configDirName));
    });

    test('${adapter.name} returns non-empty agentDirectory', () {
      final agentDir = adapter.agentDirectory('/home/user');
      expect(agentDir, isNotEmpty);
    });

    test('${adapter.name} has a valid name', () {
      expect(adapter.name, isNotEmpty);
    });
  }
});

group('allAdapters registry', () {

  test('returns exactly 5 adapters', () {
    expect(allAdapters, hasLength(5));
  });

  test('each adapter has a unique name', () {
    final names = allAdapters.map((a) => a.name).toSet();
    expect(names, hasLength(5));
  });
});
```

**Nota de diseño:** `TargetAdapter` es una clase abstracta (no interface — convención del proyecto: `extends`, no `implements`). Métodos: `name`, `skillsDirectory(homeDir)`, `agentDirectory(homeDir)`. La lista `allAdapters` es una constante global. Los paths exactos se investigan durante implementación.

- [ ] 2.1 Investigar paths globales reales de los 5 targets (docs oficiales / gentle-ai)
- [ ] 2.2 Escribir tests de adapters → RED
- [ ] 2.3 Implementar `TargetAdapter` abstracto + 5 clases concretas → GREEN
  - `lib/targets/target_adapter.dart` — clase abstracta
  - `lib/targets/copilot_adapter.dart`
  - `lib/targets/claude_adapter.dart`
  - `lib/targets/codex_adapter.dart`
  - `lib/targets/crush_adapter.dart`
  - `lib/targets/gemini_adapter.dart`
  - `lib/targets/all_adapters.dart` — lista global
- [ ] Commit: `feat(targets): adapter pattern con 5 targets — refs #1`

---

## Fase 3: Deployer — lógica de despliegue y limpieza

Capa intermedia que orquesta: lee assets + itera adapters + escribe archivos. Sin acoplamiento al CLI.

### 3.1 Tests del Deployer

```dart
group('TargetDeployer', () {

  test('deploy copies skills to each adapter skillsDirectory', () {
    // Arrange:
    //   - tempDir con assets/skills/memory-read/SKILL.md (contenido conocido)
    //   - homeDir = otro tempDir
    //   - un solo FakeAdapter que apunta skillsDir a homeDir/fake-tool/skills/
    // Act: deployer.deploy()
    // Assert:
    //   - homeDir/fake-tool/skills/memory-read/SKILL.md existe
    //   - contenido == contenido original
  });

  test('deploy copies agent to each adapter agentDirectory', () {
    // Arrange:
    //   - tempDir con assets/agents/ape.agent.md
    //   - FakeAdapter con agentDir → homeDir/fake-tool/agents/
    // Act: deployer.deploy()
    // Assert: homeDir/fake-tool/agents/ape.agent.md existe con contenido correcto
  });

  test('deploy is idempotent — second run produces same result', () {
    // Arrange: ejecutar deploy una vez
    // Act: ejecutar deploy segunda vez
    // Assert: archivos idénticos, sin duplicados, sin errores
  });

  test('deploy cleans before deploying (D18)', () {
    // Arrange: desplegar, luego crear archivo extra en skillsDir
    // Act: desplegar de nuevo
    // Assert: el archivo extra ya no existe (se limpió y redesplegó)
  });

  test('clean removes deployed files from all adapters', () {
    // Arrange: desplegar primero
    // Act: deployer.clean()
    // Assert: los directorios de skills/agents están vacíos o no existen
  });

  test('clean does not fail if nothing was deployed', () {
    // Arrange: homeDir limpio
    // Act + Assert: deployer.clean() no lanza excepción
  });

  test('deploy works with all 5 real adapters', () {
    // Arrange: homeDir = tempDir, assets reales
    // Act: deployer.deploy() con allAdapters
    // Assert: archivos existen en los 5 subdirectorios esperados
  });
});
```

**Nota de diseño:** `TargetDeployer` recibe `Assets`, `List<TargetAdapter>`, y `homeDir` como parámetros. No tiene acoplamiento a `Platform` ni a `ModularCli`. Es lógica de negocio pura y testeable.

- [ ] 3.1 Escribir tests del deployer → RED
- [ ] 3.2 Implementar `TargetDeployer` en `lib/targets/deployer.dart` → GREEN
- [ ] Commit: `feat(targets): deployer con lógica de deploy y clean — refs #1`

---

## Fase 4: Módulo target — comandos CLI

Entregable E3. Depende de Fase 1–3.

### 4.1 Tests del módulo target

```dart
group('ape target get', () {

  test('exits 0 and deploys files to all targets', () async {
    // Arrange:
    //   - tempDir como home, tempDir como assetsRoot
    //   - configurar CLI con módulo target inyectando deployer fake/real
    // Act: cli.run(['target', 'get'])
    // Assert: exit 0, archivos desplegados
  });

  test('exits 0 on idempotent re-run', () async {
    // Arrange: ejecutar 'target get' una vez
    // Act: ejecutar 'target get' segunda vez
    // Assert: exit 0
  });
});

group('ape target clean', () {

  test('exits 0 and removes deployed files', () async {
    // Arrange: desplegar primero
    // Act: cli.run(['target', 'clean'])
    // Assert: exit 0, archivos removidos
  });

  test('exits 0 when nothing to clean', () async {
    // Act: cli.run(['target', 'clean']) sin despliegue previo
    // Assert: exit 0
  });
});

group('ape target (unknown subcommand)', () {

  test('exits 64 for unrecognized subcommand', () async {
    // Act: cli.run(['target', 'nonexistent'])
    // Assert: exit 64
  });
});
```

- [ ] 4.1 Escribir tests del módulo `target` → RED
- [ ] 4.2 Implementar comandos `TargetGetCommand` y `TargetCleanCommand` → GREEN
  - `lib/commands/target_get.dart` — Input/Output/Command
  - `lib/commands/target_clean.dart` — Input/Output/Command
- [ ] 4.3 Registrar módulo `target` en `ape_cli.dart`
- [ ] 4.4 Verificar que `ape version` y `ape init` siguen funcionando
- [ ] Commit: `feat(target): módulo target con get y clean — refs #1`

---

## Fase 5: Build script y validación manual

### 5.1 Build

- [ ] 5.1 Crear script `scripts/build.ps1`:
  - `dart compile exe bin/main.dart -o build/bin/ape.exe`
  - Copiar `assets/` → `build/assets/`
- [ ] 5.2 Validar manualmente: ejecutar `build/bin/ape.exe target get` desde build/
- [ ] 5.3 Validar: `build/bin/ape.exe target clean`
- [ ] 5.4 Validar: `build/bin/ape.exe version`
- [ ] Commit: `build: script de build para Windows — refs #1`

---

## Fase 6: Distribución — install.ps1 + GitHub Release

Entregable E4. Depende de Fase 5.

- [ ] 6.1 Crear `scripts/install.ps1`:
  - Detectar plataforma (Windows x64)
  - Descargar `.zip` del último release desde GitHub API
  - Extraer a `$env:LOCALAPPDATA\ape\`
  - Agregar `$env:LOCALAPPDATA\ape\bin\` al PATH del usuario
  - Ejecutar `ape target get`
  - Verificar con `ape version`
- [ ] 6.2 Crear workflow `.github/workflows/release.yml`:
  - Trigger: push de tag `v*`
  - Compilar en `windows-latest`
  - Empaquetar `build/` como `.zip`
  - Crear GitHub Release con el `.zip`
- [ ] 6.3 Validar manualmente: tag → release → install.ps1
- [ ] Commit: `ci: install.ps1 + release workflow — refs #1`

---

## Fase 7: Cleanup y PR

- [ ] 7.1 Actualizar `pubspec.yaml` → version `0.0.2`
- [ ] 7.2 Actualizar README
- [ ] 7.3 `dart analyze` — cero warnings
- [ ] 7.4 `dart test` — todo GREEN
- [ ] 7.5 Commit: `chore: bump version to 0.0.2 — refs #1`
- [ ] 7.6 Push branch + crear PR → `closes #1`

---

## Resumen

| Fase | Entregable | TDD | Commit |
|------|-----------|-----|--------|
| 1 | Assets (clase + archivos .md) | ✓ | `feat(assets)` |
| 2 | Adapter pattern (5 targets) | ✓ | `feat(targets)` |
| 3 | Deployer (lógica de negocio) | ✓ | `feat(targets)` |
| 4 | Módulo CLI target (get + clean) | ✓ | `feat(target)` |
| 5 | Build script | Manual | `build` |
| 6 | install.ps1 + release workflow | Manual | `ci` |
| 7 | Cleanup + PR | — | `chore` |

## Riesgos

| Riesgo | Mitigación |
|--------|-----------|
| Paths globales incorrectos para algún target | Fase 2.1 investiga antes de implementar. El adapter se corrige sin impacto en el resto. |
| Formato de agente difiere entre targets | v0.0.2 copia el mismo archivo. Si un target requiere transformación, se agrega en el adapter. |
| `Platform.resolvedExecutable` no resuelve symlinks correctamente en Windows | La clase Assets es inyectable — el test de integración (5.2) valida el path real. |
