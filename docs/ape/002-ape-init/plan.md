---
id: plan-002
title: "Plan de ejecución — ape init v0.0.1"
date: 2026-04-15
status: approved
tags: [plan, v0.0.1, ape-init, dart, modular-cli-sdk]
---

# Plan de ejecución — ape init v0.0.1

## Referencia

- Alcance: `analyze/alcance-v001.md`
- Decisiones: `analyze/decisiones-arquitectura.md` (D1–D8)
- Convenciones: `modular_cli_sdk/AGENTS.md`, `coding-manifesto.instructions.md`

## Riesgos

| Riesgo | Impacto | Mitigación |
|--------|---------|------------|
| `modular_cli_sdk` no publicado en pub.dev | No se puede usar `dart pub get` normal | Sí esta publicado |
| `cli_router` no publicado en pub.dev | Transitiva de modular_cli_sdk — mismo problema | Sí está publicado |
| El ciclo Command<I,O> no funciona como se espera para I/O de filesystem | Bloqueante | Se detectará en Fase 2; si falla, volver a ANALYZE |

---

Para agregar dependencias usa el comando `dart pub add <package_name>`, no modifiques `pubspec.yaml` manualmente.

---

## Fase 1 — Scaffold del proyecto Dart

Crear la estructura del proyecto en `code/cli/` y verificar que el framework responde.

### TDD — Test primero

```pseudo
test 'el CLI responde a un comando registrado sin error'
  dado: un ModularCli con un comando dummy 'ping' que retorna exit code 0
  cuando: se ejecuta run(['ping'])
  entonces: retorna 0

test 'el CLI retorna exit code 64 para comando desconocido'
  dado: un ModularCli sin comandos registrados
  cuando: se ejecuta run(['inexistente'])
  entonces: retorna 64
```

### Steps

- [ ] 1.1 Crear `code/cli/pubspec.yaml` (sin dependencias — solo metadata y sdk constraint)
- [ ] 1.2 Ejecutar `dart pub add modular_cli_sdk` y `dart pub add --dev test lints`
- [ ] 1.3 Crear `code/cli/analysis_options.yaml` (lints recomendados)
- [ ] 1.4 Escribir tests de scaffold (pseudocódigo arriba) → **RED**
- [ ] 1.5 Crear `code/cli/bin/main.dart` — entry point que delega a `runApe(args)`
- [ ] 1.6 Crear `code/cli/lib/ape_cli.dart` — `runApe()` con ModularCli vacío (sin comandos)
- [ ] 1.7 Ejecutar `dart test` → **GREEN** (segundo test pasa; primero falla porque no hay 'ping')
- [ ] 1.8 Registrar comando dummy 'ping' solo en el test, no en producción → los dos tests pasan
- [ ] 1.9 Ejecutar `dart analyze` — cero errores, cero warnings

**Commit:** `feat(cli): scaffold dart project with modular_cli_sdk`

---

## Fase 2 — Comando `ape init`

Implementar el comando siguiendo el ciclo `Command<I, O>` de `modular_cli_sdk`.

### TDD — Test primero

```pseudo
group 'InitCommand'

  test 'crea .ape/ cuando no existe'
    dado: un directorio temporal vacío
    cuando: se ejecuta InitCommand con ese directorio como cwd
    entonces:
      - .ape/ existe en el directorio temporal
      - output.exitCode == 0
      - output.message indica creación exitosa

  test 'retorna mensaje informativo cuando .ape/ ya existe'
    dado: un directorio temporal que ya contiene .ape/
    cuando: se ejecuta InitCommand con ese directorio como cwd
    entonces:
      - .ape/ sigue existiendo (no se destruye)
      - output.exitCode == 0
      - output.message indica que ya existía
```

### Steps

- [ ] 2.1 Escribir tests del pseudocódigo arriba → **RED**
- [ ] 2.2 Crear `InitInput` — Input DTO (sin campos; `fromCliRequest` ignora el request)
- [ ] 2.3 Crear `InitOutput` — Output DTO con `message` y `exitCode` semántico
- [ ] 2.4 Crear `InitCommand` — Command que:
  - `validate()` → null (sin validación)
  - `execute()` → crea `.ape/` si no existe; retorna mensaje informativo si ya existe
- [ ] 2.5 Ejecutar `dart test` → **GREEN**
- [ ] 2.6 Registrar `init` como root command en `runApe()`
- [ ] 2.7 Ejecutar `dart analyze` — cero errores

**Commit:** `feat(cli): implement ape init command`

---

## Fase 3 — Compilación y validación final

- [ ] 3.1 Ejecutar `dart compile exe bin/main.dart` — genera binario
- [ ] 3.2 Ejecutar el binario compilado con `init` en directorio limpio — crea `.ape/`
- [ ] 3.3 Ejecutar segunda vez — mensaje informativo, no falla
- [ ] 3.4 Documentar limitaciones encontradas en los packages (si existen)
- [ ] 3.5 Ejecutar checklist de entrega del coding manifesto (FE-01 a FE-08)

**Commit:** `chore(cli): verify compilation and document findings`

**Commit:** `chore(cli): verify compilation and document findings`
