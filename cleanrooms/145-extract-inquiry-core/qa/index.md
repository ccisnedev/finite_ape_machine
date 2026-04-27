---
id: qa-analysis
title: "QA Analysis — Bugs encontrados en v0.2.0 Linux e2e"
date: 2026-04-26
status: active
tags: [qa, bugs, analysis, tdd, v0.2.0]
---

# QA Analysis — Bugs v0.2.0

## 1. Análisis profundo por bug

---

### BUG-1: Unhandled exceptions en módulo `ape` — errores lógicos exponen stacktrace

**Síntoma observado**:
```
$ ./code/cli/bin/iq ape transition --event next   # (en IDLE)
Unhandled exception:
Bad state: NO_ACTIVE_APE: No APE is active in state IDLE
#0      ApeTransitionCommand.execute (package:inquiry_cli/modules/ape/commands/transition.dart:92)
#1      ModuleBuilder._executeCommand (package:modular_cli_sdk/src/module_builder.dart:92)
...
EXIT: 255
```

**Severidad**: MEDIUM

**Root cause**:

Los comandos `ApeTransitionCommand.execute()` y `ApePromptCommand.execute()` lanzan `StateError` y `ArgumentError` nativas de Dart para comunicar errores de dominio (NO_ACTIVE_APE, APE_COMPLETED, APE_NOT_FOUND, APE_NOT_ACTIVE, INVALID_APE_EVENT).

El SDK `modular_cli_sdk` (`ModuleBuilder._executeCommand`) solo captura `CommandException`:

```dart
// module_builder.dart L96-99
} on CommandException catch (e) {
  cliOutput.writeError(e);
  return e.exitCode;
}
```

Cualquier otra excepción (`StateError`, `ArgumentError`) escapa al runtime de Dart → stacktrace completo + exit 255.

**Contraste con el patrón correcto** — `StateTransitionCommand.execute()` en `fsm/commands/transition.dart`:

```dart
// fsm transition usa CommandException → capturada limpiamente
throw CommandException(
  code: 'MISSING_EVENT',
  message: 'Missing required flag --event for state transition',
  exitCode: ExitCode.validationFailed,  // → exit 7
);
```

El módulo `fsm` también retorna `StateTransitionOutput` con `code: ExitCode.invalidUsage` para transiciones ilegales en vez de lanzar excepciones.

**Archivos afectados**:
- `lib/modules/ape/commands/transition.dart` — 4 `throw StateError(...)` (líneas 92, 97, 110, 133)
- `lib/modules/ape/commands/prompt.dart` — 2 `throw StateError(...)` (líneas 121, 130)

**Errores específicos y su exit code correcto**:
| Error | Tipo actual | Debería ser | Exit code |
|-------|------------|-------------|-----------|
| `NO_ACTIVE_APE` | `StateError` | `CommandException` | 6 (conflict) |
| `APE_COMPLETED` | `StateError` | `CommandException` | 6 (conflict) |
| `APE_NOT_FOUND` | `StateError` | `CommandException` | 4 (notFound) |
| `APE_NOT_ACTIVE` | `StateError` | `CommandException` | 6 (conflict) |
| `INVALID_APE_EVENT` | `StateError` | `CommandException` | 7 (validationFailed) |
| `INVALID_APE_STATE` | `StateError` | `CommandException` | 6 (conflict) |

---

### BUG-2: Transición a END re-inicializa APE en vez de preservar _DONE

**Síntoma observado**:
```
# basho ya completó su trabajo (_DONE)
$ ./code/cli/bin/iq fsm transition --event finish_execute   # EXECUTE → END
$ cat .inquiry/state.yaml
state: END
issue: "145"
ape:
  name: basho
  state: implement    # ← debería ser _DONE o al menos no re-inicializar
```

**Severidad**: LOW (cosmético — el ciclo continúa correctamente)

**Root cause**:

`EffectExecutor.updateState()` siempre re-inicializa el APE al `initial_state` del YAML, sin considerar si el APE ya estaba activo y en qué sub-estado:

```dart
// effect_executor.dart L64-68
final ape = _stateApes[newState];  // 'END' → 'basho'
if (ape != null) {
  apeName = ape;
  apeInitialState = _resolveInitialState(ape);  // → 'implement' SIEMPRE
}
```

El mapeo `_stateApes['END'] = 'basho'` es **intencional por diseño** — en END, basho sigue activo para la fase de PR. Pero el problema es que `updateState()` no distingue entre:
- **Primer entrada**: IDLE→ANALYZE — socrates no existía, crearlo en `clarification` ✓
- **Continuación**: EXECUTE→END — basho ya existía en `_DONE`, no debería re-inicializarse

El mapeo es consistente en 3 archivos (`effect_executor.dart:42`, `prompt.dart:109`, `state.dart:140`), confirmando que END→basho es un diseño deliberado. El bug está en la lógica de `updateState`, no en el mapeo.

**Archivo afectado**: `lib/modules/fsm/effect_executor.dart` — método `updateState()`

**Dos opciones de fix**:
1. **Preservar sub-estado**: Si el APE asignado al nuevo estado es el MISMO que el APE actual, preservar su sub-estado en vez de re-inicializar
2. **END sin APE**: Cambiar `_stateApes['END']` a `null` — END es una gate de PR, no una fase de trabajo activo

La opción 1 es más correcta: respeta el diseño actual (basho activo en END) sin perder el progreso del sub-FSM.

---

### BUG-3: Missing flags en `ape` commands → unhandled exception

**Síntoma observado**:
```
$ ./code/cli/bin/iq ape transition          # sin --event
Unhandled exception:
Invalid argument(s): Usage: iq ape transition --event <event>
#0      new ApeTransitionInput.fromCliRequest (package:inquiry_cli/modules/ape/commands/transition.dart:25)
...
EXIT: 255

$ ./code/cli/bin/iq ape prompt              # sin --name
Unhandled exception:
Invalid argument(s): Usage: iq ape prompt --name <name> [--state <sub_state>]
...
EXIT: 255
```

**Severidad**: MEDIUM

**Root cause**:

Los factory constructors `ApeTransitionInput.fromCliRequest()` y `ApePromptInput.fromCliRequest()` validan los flags obligatorios lanzando `ArgumentError`:

```dart
// transition.dart L24-26
factory ApeTransitionInput.fromCliRequest(CliRequest req) {
  final event = req.flagString('event', aliases: const ['e']);
  if (event == null || event.trim().isEmpty) {
    throw ArgumentError('Usage: iq ape transition --event <event>');
  }
```

El `ModuleBuilder._executeCommand()` invoca `commandFactory(req)` (que llama `fromCliRequest`) **antes** del bloque try/catch que captura `CommandException`. El try/catch está en `_executeCommand`, pero la factory se ejecuta **dentro del mismo try** como parte de `final cmd = commandFactory(req)`:

```dart
// module_builder.dart L77-78
try {
  final cmd = commandFactory(req);  // ← fromCliRequest lanza aquí
```

La `ArgumentError` no es `CommandException`, así que escapa.

**Contraste**: `StateTransitionInput.fromCliRequest()` en `fsm transition` NO valida flags en el constructor — acepta `null` y delega la validación a `execute()`, donde lanza `CommandException`:

```dart
// fsm transition.dart L28-33
factory StateTransitionInput.fromCliRequest(CliRequest req) {
  return StateTransitionInput(
    currentState: req.flagString('state', aliases: const ['s']),
    event: req.flagString('event', aliases: const ['e']),  // acepta null
    workingDirectory: Directory.current.path,
  );
}
// Luego en execute():
if (input.event == null || input.event!.trim().isEmpty) {
  throw CommandException(code: 'MISSING_EVENT', ...);
}
```

**Archivos afectados**:
- `lib/modules/ape/commands/transition.dart` L24-26 (factory constructor)
- `lib/modules/ape/commands/prompt.dart` L34-36 (factory constructor)

---

## 2. Análisis integral

### Patrón sistémico

Los 3 bugs comparten una **causa raíz única**: el módulo `ape` fue implementado con un patrón de error handling diferente al del módulo `fsm`.

| Aspecto | Módulo `fsm` (correcto) | Módulo `ape` (buggy) |
|---------|------------------------|---------------------|
| Missing flags | `null` aceptado en Input → `CommandException` en execute() | `ArgumentError` en factory constructor |
| Errores de estado | Retorna Output con exit code | `throw StateError(...)` |
| Exit code | Semántico (6=conflict, 7=validation, 64=usage) | 255 (crash) |
| Stacktrace | Nunca visible al usuario | Siempre visible |
| SDK catch | `CommandException` capturado → formatted output | `StateError`/`ArgumentError` escapan |

### Impacto real

1. **Firmware**: El agent.md thin que orquesta el dual-FSM loop va a encontrar estos stacktraces cuando el LLM intente comandos incorrectos. El LLM puede interpretar el stacktrace como un crash en vez de un error de validación, causando confusión o retries innecesarios.

2. **Scripting**: Scripts que parsean exit codes no pueden distinguir entre 255 (crash) y un error de dominio.

3. **UX**: El usuario ve 10 líneas de stacktrace por un error simple ("no hay APE activo").

### Relación entre bugs

```
BUG-3 (missing flags) ──→ ArgumentError ──→ stacktrace + exit 255
BUG-1 (domain errors) ──→ StateError   ──→ stacktrace + exit 255
BUG-2 (END re-init)   ──→ lógica incorrecta en updateState()
```

BUG-1 y BUG-3 son **el mismo problema de patrón** (excepción incorrecta en vez de `CommandException`). BUG-2 es independiente — un bug lógico en el effect executor.

### Riesgo de la corrección

- **BUG-1+3**: Bajo. Cambiar `throw StateError/ArgumentError` → `throw CommandException`. Los tests existentes verifican `throwsA(isA<StateError>())` → deben actualizarse a `throwsA(isA<CommandException>())`.
- **BUG-2**: Bajo. Agregar lógica condicional en `updateState()`. Tests existentes no cubren este caso (no hay test para `updateState('END')` con basho ya activo).

---

## 3. Plan TDD para corrección

### Fix A — BUG-3: Missing flags en `ape` commands (prerequisito)

> Se resuelve primero porque el constructor es el primer punto de fallo.

#### RED

```dart
// test/ape_transition_test.dart — nuevo test
test('throws CommandException when event flag is missing', () async {
  writeState(state: 'ANALYZE', issue: '99', apeName: 'socrates', apeState: 'clarification');

  // Simular fromCliRequest con event null → delegar a execute()
  final cmd = ApeTransitionCommand(
    ApeTransitionInput(event: '', workingDirectory: tmpDir.path),
  );

  expect(
    () => cmd.execute(),
    throwsA(
      isA<CommandException>()
        .having((e) => e.code, 'code', 'MISSING_EVENT')
        .having((e) => e.exitCode, 'exitCode', ExitCode.validationFailed),
    ),
  );
});

// test/ape_prompt_test.dart — nuevo test
test('throws CommandException when name flag is missing', () async {
  writeState(state: 'ANALYZE');

  final cmd = ApePromptCommand(
    ApePromptInput(name: '', workingDirectory: tmpDir.path),
  );

  expect(
    () => cmd.execute(),
    throwsA(
      isA<CommandException>()
        .having((e) => e.code, 'code', 'MISSING_NAME')
        .having((e) => e.exitCode, 'exitCode', ExitCode.validationFailed),
    ),
  );
});
```

#### GREEN

**`transition.dart`** — hacer Input nullable-safe y mover validación:

```dart
class ApeTransitionInput extends Input {
  final String? event;  // nullable ahora
  ...
  factory ApeTransitionInput.fromCliRequest(CliRequest req) {
    return ApeTransitionInput(
      event: req.flagString('event', aliases: const ['e']),
      workingDirectory: Directory.current.path,
    );
  }
}

// En execute():
Future<ApeTransitionOutput> execute() async {
  if (input.event == null || input.event!.trim().isEmpty) {
    throw CommandException(
      code: 'MISSING_EVENT',
      message: 'Usage: iq ape transition --event <event>',
      exitCode: ExitCode.validationFailed,
    );
  }
  ...
}
```

**`prompt.dart`** — mismo patrón:

```dart
class ApePromptInput extends Input {
  final String? name;  // nullable ahora
  ...
  factory ApePromptInput.fromCliRequest(CliRequest req) {
    return ApePromptInput(
      name: req.flagString('name', aliases: const ['n']),
      subState: req.flagString('state', aliases: const ['s']),
      workingDirectory: Directory.current.path,
    );
  }
}

// En execute():
Future<ApePromptOutput> execute() async {
  if (input.name == null || input.name!.trim().isEmpty) {
    throw CommandException(
      code: 'MISSING_NAME',
      message: 'Usage: iq ape prompt --name <name> [--state <sub_state>]',
      exitCode: ExitCode.validationFailed,
    );
  }
  ...
}
```

#### Tests existentes que se actualizan

Ninguno — los tests existentes construyen `ApeTransitionInput(event: 'next', ...)` con valor explícito, no pasan por `fromCliRequest`. El factory ya no lanza, así que no rompe nada.

---

### Fix B — BUG-1: Domain errors como CommandException (principal)

> Se resuelve segundo porque depende de que Fix A ya haya movido la validación de flags.

#### RED

Actualizar los tests existentes que esperan `StateError` → `CommandException`:

```dart
// test/ape_transition_test.dart — modificar tests existentes

test('throws CommandException for NO_ACTIVE_APE', () async {
  writeState(state: 'IDLE');

  final cmd = ApeTransitionCommand(
    ApeTransitionInput(event: 'next', workingDirectory: tmpDir.path),
  );

  expect(
    () => cmd.execute(),
    throwsA(
      isA<CommandException>()
        .having((e) => e.code, 'code', 'NO_ACTIVE_APE')
        .having((e) => e.exitCode, 'exitCode', ExitCode.conflict),
    ),
  );
});

test('throws CommandException for APE_COMPLETED', () async {
  writeState(state: 'ANALYZE', issue: '145', apeName: 'socrates', apeState: '_DONE');

  final cmd = ApeTransitionCommand(
    ApeTransitionInput(event: 'next', workingDirectory: tmpDir.path),
  );

  expect(
    () => cmd.execute(),
    throwsA(
      isA<CommandException>()
        .having((e) => e.code, 'code', 'APE_COMPLETED')
        .having((e) => e.exitCode, 'exitCode', ExitCode.conflict),
    ),
  );
});

test('throws CommandException for INVALID_APE_EVENT', () async {
  writeState(state: 'ANALYZE', issue: '145', apeName: 'socrates', apeState: 'clarification');

  final cmd = ApeTransitionCommand(
    ApeTransitionInput(event: 'explode', workingDirectory: tmpDir.path),
  );

  expect(
    () => cmd.execute(),
    throwsA(
      isA<CommandException>()
        .having((e) => e.code, 'code', 'INVALID_APE_EVENT')
        .having((e) => e.exitCode, 'exitCode', ExitCode.validationFailed),
    ),
  );
});

// test/ape_prompt_test.dart — modificar tests existentes

test('throws CommandException for APE_NOT_FOUND', () async {
  ...
  expect(
    () => cmd.execute(),
    throwsA(
      isA<CommandException>()
        .having((e) => e.code, 'code', 'APE_NOT_FOUND')
        .having((e) => e.exitCode, 'exitCode', ExitCode.notFound),
    ),
  );
});

test('throws CommandException for APE_NOT_ACTIVE', () async {
  ...
  expect(
    () => cmd.execute(),
    throwsA(
      isA<CommandException>()
        .having((e) => e.code, 'code', 'APE_NOT_ACTIVE')
        .having((e) => e.exitCode, 'exitCode', ExitCode.conflict),
    ),
  );
});
```

#### GREEN

**`transition.dart`** — reemplazar todos los `throw StateError(...)`:

```dart
// L92 NO_ACTIVE_APE
throw CommandException(
  code: 'NO_ACTIVE_APE',
  message: 'No APE is active in state ${inquiryState.state}',
  exitCode: ExitCode.conflict,
);

// L97 APE_COMPLETED
throw CommandException(
  code: 'APE_COMPLETED',
  message: '"${inquiryState.apeName}" has already completed (_DONE). '
           'Transition the main FSM to advance.',
  exitCode: ExitCode.conflict,
);

// L110 APE_NOT_FOUND
throw CommandException(
  code: 'APE_NOT_FOUND',
  message: 'No definition for "${inquiryState.apeName}" at $yamlPath',
  exitCode: ExitCode.notFound,
);

// L119 INVALID_APE_STATE
throw CommandException(
  code: 'INVALID_APE_STATE',
  message: '"${inquiryState.apeName}" has no state "$fromState"',
  exitCode: ExitCode.conflict,
);

// L133 INVALID_APE_EVENT
throw CommandException(
  code: 'INVALID_APE_EVENT',
  message: '"${input.event}" is not valid from '
           '"${inquiryState.apeName}:$fromState". Valid events: [$valid]',
  exitCode: ExitCode.validationFailed,
);
```

**`prompt.dart`** — reemplazar 2 `throw StateError(...)`:

```dart
// L121 APE_NOT_FOUND
throw CommandException(
  code: 'APE_NOT_FOUND',
  message: 'No definition found for "${input.name}" at $yamlPath',
  exitCode: ExitCode.notFound,
);

// L130 APE_NOT_ACTIVE
throw CommandException(
  code: 'APE_NOT_ACTIVE',
  message: '"${input.name}" is not active in state ${currentState.value}. '
           'Active APEs: ${activeApes.join(', ')}',
  exitCode: ExitCode.conflict,
);
```

#### Tests existentes que se actualizan

| Archivo | Test | Cambio |
|---------|------|--------|
| `ape_transition_test.dart` | `throws NO_ACTIVE_APE` | `isA<StateError>()` → `isA<CommandException>()` |
| `ape_transition_test.dart` | `throws APE_COMPLETED` | ídem |
| `ape_transition_test.dart` | `throws INVALID_APE_EVENT` | ídem |
| `ape_transition_test.dart` | `throws APE_NOT_FOUND` | ídem |
| `ape_prompt_test.dart` | `throws for nonexistent APE` | `isA<StateError>()` → `isA<CommandException>()` |
| `ape_prompt_test.dart` | `socrates in EXECUTE throws not active` | ídem |
| `ape_prompt_test.dart` | `descartes in ANALYZE throws not active` | ídem |
| `ape_prompt_test.dart` | `any APE in IDLE throws not active` | ídem |
| `ape_prompt_test.dart` | `auto-read throws not active in IDLE` | ídem |

---

### Fix C — BUG-2: END re-inicializa APE

#### RED

```dart
// test/effect_executor_test.dart — nuevo test

test('preserves APE _DONE state when transitioning to END (same APE)', () {
  // basho already in _DONE
  File('${tempDir.path}/.inquiry/state.yaml')
      .writeAsStringSync(
        'state: EXECUTE\nissue: "145"\nape:\n  name: basho\n  state: _DONE\n',
      );

  final apesDir = Directory('${tempDir.path}/assets/apes');
  apesDir.createSync(recursive: true);
  File('assets/apes/basho.yaml').copySync('${apesDir.path}/basho.yaml');

  final executor = EffectExecutor(workingDirectory: tempDir.path);
  executor.updateState('END');

  final content =
      File('${tempDir.path}/.inquiry/state.yaml').readAsStringSync();
  expect(content, contains('name: basho'));
  expect(content, contains('state: _DONE'));  // NOT 'implement'
});

test('re-initializes APE when transitioning to state with DIFFERENT APE', () {
  // socrates in _DONE, transitioning to PLAN (descartes)
  File('${tempDir.path}/.inquiry/state.yaml')
      .writeAsStringSync(
        'state: ANALYZE\nissue: "145"\nape:\n  name: socrates\n  state: _DONE\n',
      );

  final apesDir = Directory('${tempDir.path}/assets/apes');
  apesDir.createSync(recursive: true);
  File('assets/apes/descartes.yaml').copySync('${apesDir.path}/descartes.yaml');

  final executor = EffectExecutor(workingDirectory: tempDir.path);
  executor.updateState('PLAN');

  final content =
      File('${tempDir.path}/.inquiry/state.yaml').readAsStringSync();
  expect(content, contains('name: descartes'));
  expect(content, contains('state: decomposition'));  // re-init correcto
});
```

#### GREEN

**`effect_executor.dart`** — modificar `updateState()` para preservar sub-estado cuando el APE no cambia:

```dart
void updateState(String newState, {String? issue}) {
  final currentState = InquiryState.load(workingDirectory);
  String? resolvedIssue = issue;

  if (newState == 'IDLE') {
    resolvedIssue = null;
  } else {
    resolvedIssue ??= currentState.issue;
  }

  // Auto-activate APE
  String? apeName;
  String? apeInitialState;
  final ape = _stateApes[newState];
  if (ape != null) {
    apeName = ape;
    // Preserve sub-state if same APE continues
    if (currentState.apeName == ape && currentState.apeState != null) {
      apeInitialState = currentState.apeState;
    } else {
      apeInitialState = _resolveInitialState(ape);
    }
  }

  final updated = InquiryState(
    state: newState,
    issue: resolvedIssue,
    apeName: apeName,
    apeState: apeInitialState,
  );
  updated.save(workingDirectory);
}
```

#### Tests existentes que NO se rompen

- `activates basho when transitioning to EXECUTE` — APE anterior era descartes → APE cambia → re-init a implement ✓
- `activates darwin when transitioning to EVOLUTION` — APE anterior era basho → APE cambia → re-init a observe ✓
- `clears ape when transitioning to IDLE` — IDLE no tiene APE → null ✓
- `activates socrates when transitioning to ANALYZE` — IDLE no tenía APE → nuevo → re-init a clarification ✓

---

### Orden de ejecución

```
Fix A (BUG-3) ──→ Fix B (BUG-1) ──→ Fix C (BUG-2)
     │                   │                  │
     │    input nullability    domain errors    logic fix
     │    + validate in        StateError →     preserve
     │    execute()            CommandException  sub-state
     │                   │                  │
     └── 2 tests nuevos  └── ~9 tests mod  └── 2 tests nuevos
```

**Fix A antes de B** porque B necesita que los inputs sean nullable para que `execute()` sea el punto único de validación.

**Fix C es independiente** pero se ejecuta al final para minimizar diff en cada commit.

### Verificación post-fix

```bash
dart analyze                    # 0 issues
dart test                       # 285+ tests, all pass
dart compile exe bin/main.dart -o bin/iq

# Re-ejecutar secciones 5, 7, 8, 11, 13 del QA
./code/cli/bin/iq ape transition --event next    # en IDLE → error limpio, exit 6
./code/cli/bin/iq ape prompt --name socrates     # en IDLE → error limpio, exit 6
./code/cli/bin/iq ape transition                 # sin flag → error limpio, exit 7
./code/cli/bin/iq ape prompt                     # sin flag → error limpio, exit 7

# BUG-2: verificar END preserva _DONE
# (transicionar hasta EXECUTE, completar basho, finish_execute)
cat .inquiry/state.yaml                          # ape: basho, state: _DONE
```
