---
id: comandos-v002
title: "Comandos v0.0.2"
date: 2026-04-16
status: draft
tags: [comandos, v002, modulos, target, modular-cli-sdk]
author: socrates
---

# Comandos v0.0.2

## Superficie de comandos

```
ape target get      # Despliega agentes + skills a los 5 targets globales
ape target clean    # Elimina archivos desplegados de todos los targets
ape version         # Imprime versión del binario
```

## Semántica

- `ape target get`: idempotente (D18). Limpia y redespliega. Sin flags de selección (D17). Despliega a los 5 targets siempre.
- `ape target clean`: elimina lo desplegado sin redesplegar.
- `ape version`: ya existe desde v0.0.1.

## Alineamiento con modular_cli_sdk

```dart
final cli = ModularCli();

cli.command<VersionInput, VersionOutput>(
  'version', (req) => VersionCommand(VersionInput.fromCliRequest(req)),
);

cli.module('target', (m) {
  m.command<TargetGetInput, TargetGetOutput>(
    'get', (req) => TargetGetCommand(TargetGetInput.fromCliRequest(req)),
  );
  m.command<TargetCleanInput, TargetCleanOutput>(
    'clean', (req) => TargetCleanCommand(TargetCleanInput.fromCliRequest(req)),
  );
});
```

## Flujo de instalación

```
install.ps1:
  1. Descarga build/ desde GitHub Release
  2. Extrae a ubicación local
  3. Agrega bin/ al PATH
  4. Ejecuta: ape target get       ← despliega archivos globales (D16)
  5. Verifica: ape version
```

## Diferidos

| Comando | Razón |
|---------|-------|
| `ape bin upgrade` | Módulo `bin` diferido |
| `ape bin uninstall` | Módulo `bin` diferido |
| `ape repo init` | Módulo `repo` diferido |
