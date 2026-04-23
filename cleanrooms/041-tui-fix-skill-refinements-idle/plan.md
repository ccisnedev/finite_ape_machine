---
id: plan
title: Plan — v0.0.10 UX fixes + SDK enhancement
date: 2026-04-17
status: active
tags: [plan, sdk, ux, tui, doctor, upgrade]
author: DESCARTES
---

# Plan — v0.0.10

## Hipótesis

> Si añadimos `toText()` al SDK (Phase 1-2) y lo usamos en TUI/Doctor/Upgrade (Phase 3), entonces resolveremos el problema de UX donde se muestran campos JSON crudos en lugar de texto formateado.

## Dependencias

```
Phase 0 → Phase 1 → Phase 2 → Phase 3 → Phase 4 (paralelo) → Phase 5
           SDK       pub.dev   APE CLI    docs        release
```

---

## Phase 0: SDK Issue Creation

**Entrada:** Diagnosis aprobado  
**Salida:** Issue creado en GitHub  
**Duración:** 5 min

- [ ] Crear issue en `macss-dev/modular_cli_sdk`
  - Título: `feat: add toText() to Output for custom text formatting`
  - Body: Referencia diagnosis, describe el problema de UX
- [ ] Anotar número de issue para commits

**Verificación:** `gh issue view <N> --repo macss-dev/modular_cli_sdk`

---

## Phase 1: SDK Implementation (TDD)

**Entrada:** Issue creado, SDK en v0.2.0  
**Salida:** PR mergeado con `toText()` implementado  
**Duración:** 30 min

### 1.1 RED — Escribir tests que fallan

- [ ] Crear `test/output_to_text_test.dart`

```dart
// test/output_to_text_test.dart
group('Output.toText()', () {
  test('default implementation returns null', () {
    final output = SimpleOutput(value: 'test');
    expect(output.toText(), isNull);
  });

  test('can be overridden to return custom text', () {
    final output = CustomTextOutput(diagram: 'DIAGRAM');
    expect(output.toText(), equals('DIAGRAM'));
  });
});

group('TextCliOutput.writeObject()', () {
  test('uses toText() when present', () {
    // Arrange
    final buffer = StringBuffer();
    final output = TextCliOutput(stdout: MockSink(buffer), ...);
    
    // Act
    output.writeObject({'key': 'value'}, textOverride: 'CUSTOM');
    
    // Assert
    expect(buffer.toString(), equals('CUSTOM\n'));
  });

  test('iterates toJson() when toText() is null', () {
    // Existing behavior preserved
    final buffer = StringBuffer();
    final output = TextCliOutput(stdout: MockSink(buffer), ...);
    
    output.writeObject({'key': 'value'}, textOverride: null);
    
    expect(buffer.toString(), equals('key: value\n'));
  });
});
```

- [ ] Ejecutar tests: `dart test test/output_to_text_test.dart`
- [ ] Confirmar que fallan (RED)

### 1.2 GREEN — Implementar `toText()`

- [ ] Modificar `lib/src/output.dart`:

```dart
abstract class Output {
  Output();
  
  Map<String, dynamic> toJson();
  int get exitCode;
  List<dynamic>? get schemaFields => null;
  
  /// Override for custom text formatting.
  /// If null, [TextCliOutput] iterates [toJson()] fields.
  String? toText() => null;  // NEW
}
```

- [ ] Modificar `lib/src/cli_output_text.dart`:

```dart
@override
void writeObject(Map<String, dynamic> object, {String? textOverride}) {
  if (textOverride != null) {
    stdout.writeln(textOverride);
    return;
  }
  for (final entry in object.entries) {
    stdout.writeln('${entry.key}: ${entry.value}');
  }
}
```

- [ ] Modificar `lib/src/modular_cli.dart` — donde se llama `writeObject`:

```dart
// En _runCommand o donde formatee Output:
cliOutput.writeObject(output.toJson(), textOverride: output.toText());
```

- [ ] Ejecutar tests: `dart test`
- [ ] Confirmar que pasan (GREEN)

### 1.3 REFACTOR — Limpiar

- [ ] Verificar que `CliOutput` interface tiene `textOverride` opcional
- [ ] Actualizar `JsonCliOutput` si es necesario (probablemente no, JSON ignora textOverride)
- [ ] `dart analyze` sin warnings
- [ ] `dart format .`

### 1.4 Documentación SDK

- [ ] Actualizar docstring de `Output.toText()`
- [ ] Actualizar CHANGELOG.md:
  ```markdown
  ## 0.2.1
  
  - Added `Output.toText()` for custom text formatting
  - `TextCliOutput.writeObject()` uses `toText()` when non-null
  ```

### 1.5 PR y merge

- [ ] `git checkout -b feat/output-to-text`
- [ ] `git add -A && git commit -m "feat: add toText() to Output (#<N>)"`
- [ ] `git push -u origin feat/output-to-text`
- [ ] `gh pr create --title "feat: add toText() to Output" --body "Closes #<N>"`
- [ ] Esperar CI verde
- [ ] `gh pr merge --squash --delete-branch`

**Verificación:** Tests pasan, PR mergeado, branch borrado.

---

## Phase 2: SDK Publish to pub.dev

**Entrada:** PR mergeado en main  
**Salida:** modular_cli_sdk v0.2.1 en pub.dev  
**Duración:** 10 min

- [ ] `git checkout main && git pull`
- [ ] Bump version en `pubspec.yaml`: `0.2.0` → `0.2.1`
- [ ] Verificar CHANGELOG tiene entrada para 0.2.1
- [ ] `dart pub publish --dry-run`
- [ ] Corregir cualquier warning
- [ ] `dart pub publish`
- [ ] Verificar en https://pub.dev/packages/modular_cli_sdk

**Verificación:** `dart pub cache clean && dart pub add modular_cli_sdk:0.2.1` funciona.

---

## Phase 3: APE CLI Updates

**Entrada:** modular_cli_sdk 0.2.1 publicado  
**Salida:** APE CLI v0.0.10 con toText() en TUI/Doctor y progress en Upgrade  
**Duración:** 45 min

### 3.1 Update SDK dependency

- [ ] Editar `pubspec.yaml`:
  ```yaml
  modular_cli_sdk: ^0.2.1
  ```
- [ ] `dart pub get`
- [ ] Verificar que resuelve 0.2.1

### 3.2 TuiOutput.toText() (TDD)

**Test primero:**

```dart
// test/tui_command_test.dart
test('TuiOutput.toText() returns diagram only', () {
  final output = TuiOutput(version: '0.0.10', diagram: 'DIAGRAM');
  expect(output.toText(), equals('DIAGRAM'));
});

test('TuiOutput.toJson() includes version and diagram', () {
  final output = TuiOutput(version: '0.0.10', diagram: 'DIAGRAM');
  expect(output.toJson(), {'version': '0.0.10', 'diagram': 'DIAGRAM'});
});
```

**Implementación:**

- [ ] Añadir a `lib/commands/tui.dart`:

```dart
class TuiOutput extends Output {
  final String version;
  final String diagram;

  TuiOutput({required this.version, required this.diagram});

  @override
  Map<String, dynamic> toJson() => {
    'version': version,
    'diagram': diagram,
  };

  @override
  int get exitCode => ExitCode.ok;

  @override
  String? toText() => diagram;  // NEW
}
```

- [ ] Ejecutar test: `dart test test/tui_command_test.dart`

### 3.3 DoctorOutput.toText() (TDD)

**Test primero:**

```dart
// test/doctor_command_test.dart
test('DoctorOutput.toText() returns formatted checkmarks', () {
  final checks = [
    DoctorCheck(name: 'ape', passed: true, version: '0.0.10'),
    DoctorCheck(name: 'git', passed: true, version: '2.45.0'),
    DoctorCheck(name: 'gh', passed: false, error: 'not found'),
  ];
  final output = DoctorOutput(checks: checks, passed: false);
  
  expect(output.toText(), contains('✓ ape'));
  expect(output.toText(), contains('✓ git'));
  expect(output.toText(), contains('✗ gh'));
});
```

**Implementación:**

- [ ] Añadir a `lib/commands/doctor.dart`:

```dart
class DoctorOutput extends Output {
  // ... existing fields ...

  @override
  String? toText() {
    final buffer = StringBuffer();
    for (final check in checks) {
      final icon = check.passed ? '✓' : '✗';
      final suffix = check.version ?? check.error ?? '';
      buffer.writeln('$icon ${check.name}: $suffix');
    }
    return buffer.toString().trimRight();
  }
}
```

- [ ] Ejecutar test: `dart test test/doctor_command_test.dart`

### 3.4 UpgradeCommand progress (sin TDD — side effect)

El progress es un side effect (stdout durante ejecución), no un valor de retorno. No se puede testear con el patrón Output.

- [ ] Modificar `lib/commands/upgrade.dart`:

```dart
@override
Future<UpgradeOutput> execute() async {
  final client = httpClientOverride ?? HttpClient();
  try {
    stdout.writeln('Checking for updates...');  // NEW
    
    // 1. Fetch latest release metadata
    final releaseUrl = Uri.parse(...);
    // ... existing code ...
    
    stdout.writeln('Downloading $latestVersion...');  // NEW
    
    // 2. Download zip
    // ... existing code ...
    
    stdout.writeln('Installing...');  // NEW
    
    // ... existing code ...
```

- [ ] Test manual: `dart run bin/ape.dart upgrade` muestra progress

### 3.5 UpgradeOutput.toText()

```dart
@override
String? toText() {
  if (!upgraded) return message;
  return 'Upgraded from $previousVersion to $newVersion';
}
```

### 3.6 Bump version

- [ ] Editar `lib/src/version.dart`:
  ```dart
  const String apeVersion = '0.0.10';
  ```

- [ ] Editar `pubspec.yaml`:
  ```yaml
  version: 0.0.10
  ```

### 3.7 Update CHANGELOG

- [ ] Añadir a CHANGELOG.md:
  ```markdown
  ## 0.0.10
  
  - Fix: TUI shows diagram only (not JSON fields)
  - Fix: Doctor shows formatted checkmarks
  - Enhancement: Upgrade shows progress indicators
  - Deps: modular_cli_sdk ^0.2.1
  ```

### 3.8 Final verification

- [ ] `dart analyze`
- [ ] `dart test`
- [ ] Test manual:
  - `dart run bin/ape.dart` → muestra diagrama limpio
  - `dart run bin/ape.dart doctor` → muestra checkmarks
  - `dart run bin/ape.dart --json` → JSON completo
  - `dart run bin/ape.dart doctor --json` → JSON con checks array

**Verificación:** Todos los tests pasan, output visual correcto.

---

## Phase 4: Skill Documentation Update

**Entrada:** Implementación completa  
**Salida:** Skill issue-end actualizado  
**Duración:** 10 min

**Puede ejecutarse en paralelo con Phase 5.**

- [ ] Localizar skill `issue-end` en el repo `ai/`
- [ ] Añadir clarificación:
  ```markdown
  ## PR Create = Cycle End
  
  When a PR is created and merged, the APE cycle terminates:
  EXECUTE → EVOLUTION → IDLE
  
  Do not wait for additional signals after PR merge.
  ```
- [ ] Commit: `docs: clarify PR create = cycle end in issue-end skill`

**Verificación:** Skill actualizado con clarificación.

---

## Phase 5: APE CLI Release

**Entrada:** Phase 3 completada, tests pasando  
**Salida:** v0.0.10 release en GitHub  
**Duración:** 15 min

### 5.1 Create PR

- [ ] `git checkout -b fix/tui-doctor-ux`
- [ ] `git add -A`
- [ ] `git commit -m "fix: TUI/Doctor text output, upgrade progress (#041)"`
- [ ] `git push -u origin fix/tui-doctor-ux`
- [ ] `gh pr create --title "v0.0.10: UX fixes" --body "Closes #041"`

### 5.2 CI verification

- [ ] Esperar CI verde
- [ ] Revisar que artifact ape-windows-x64.zip se genera

### 5.3 Merge and tag

- [ ] `gh pr merge --merge --delete-branch`
- [ ] `git checkout main && git pull`
- [ ] `git tag v0.0.10`
- [ ] `git push origin v0.0.10`

### 5.4 Verify release

- [ ] Esperar que GitHub Actions cree release
- [ ] Verificar asset ape-windows-x64.zip presente
- [ ] `gh release view v0.0.10`

**Verificación:** Release v0.0.10 visible con asset descargable.

---

## Criterios de Éxito

| Criterio | Verificación |
|----------|--------------|
| `ape` muestra solo diagrama | `dart run bin/ape.dart` — sin "version:" prefix |
| `ape doctor` muestra checkmarks | `dart run bin/ape.dart doctor` — ✓/✗ icons |
| `ape upgrade` muestra progress | `dart run bin/ape.dart upgrade` — "Checking...", "Downloading..." |
| JSON mode preservado | `ape --json` — full JSON output |
| SDK publicado | `pub.dev/packages/modular_cli_sdk` shows 0.2.1 |
| APE released | `gh release view v0.0.10` succeeds |

---

## Rollback

Si Phase 2 (publish) falla:
- APE CLI puede usar path dependency temporalmente
- `modular_cli_sdk: { path: ../modular_cli_sdk }`

Si Phase 3 causa regresiones:
- Revert PR: `gh pr create --title "Revert v0.0.10"`
- Tag pre-release no afecta usuarios (necesitan manual upgrade)

---

## Notas de Implementación

1. **TextCliOutput signature change**: El parámetro `textOverride` es opcional con default `null`, así que es backward compatible.

2. **Unicode checkmarks**: ✓ (U+2713) y ✗ (U+2717) funcionan en Windows Terminal y PowerShell 7. Si hay issues, fallback a `[OK]` y `[FAIL]`.

3. **stdout durante execute()**: El SDK no prohíbe writes directos a stdout durante `execute()`. Solo el resultado final pasa por `CliOutput`.
