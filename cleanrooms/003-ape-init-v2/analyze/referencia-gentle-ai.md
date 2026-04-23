---
id: referencia-gentle-ai
title: "Referencia: patrones de gentle-ai relevantes para APE"
date: 2026-04-16
status: active
tags: [referencia, gentle-ai, adapter-pattern, assets, targets, evidencia]
author: socrates
---

# Referencia: patrones de gentle-ai

gentle-ai es un proyecto open-source en Go que configura 11 AI coding tools. Patrones extraídos como evidencia para APE v0.0.2.

## 1. Adapter pattern

Cada target implementa `Adapter`:

```go
type Adapter interface {
    GlobalConfigDir(homeDir) string
    SystemPromptFile(homeDir) string
    SkillsDir(homeDir) string
    SystemPromptStrategy() Strategy
    SupportsSkills() bool
    SupportsSubAgents() bool
}
```

Los componentes llaman métodos del adapter. Cero switch statements en lógica de negocio.

## 2. Skills: compartidas, no transformadas

Las skills se copian **idénticas** a todos los targets. Solo cambia el directorio destino (`adapter.SkillsDir()`). 11 targets distintos, mismo archivo.

## 3. Agentes: sí requieren adaptación

Los prompts principales varían por target. Tres estrategias de inyección:

| Estrategia | Targets | Comportamiento |
|------------|---------|----------------|
| MarkdownSections | Claude | Inyecta entre `<!-- markers -->` preservando contenido del usuario |
| FileReplace | OpenCode, Cursor | Reemplaza archivo completo |
| AppendToFile | Otros | Agrega al final |

Existen assets específicos por target (`internal/assets/claude/`, `internal/assets/cursor/agents/`, etc.).

## 4. Embedding via `//go:embed`

Todo embebido en el binario. APE usa archivos en disco (D5) — trade-off aceptable: más fácil de depurar, requiere copiar `assets/`.

## 5. Sync idempotente

Rastrea cambios reales. Flag `NoOp` detecta cuando nada cambió. Solo escribe si hay diferencia.

## 6. Estado persistente

`~/.gentle-ai/state.json` rastrea agentes instalados. Sync solo toca lo explícitamente instalado.

## 7. Install script (install.ps1)

Descarga ZIP desde GitHub Releases, verifica SHA256, extrae a `%LOCALAPPDATA%\gentle-ai\bin\`, agrega al PATH. Mismo patrón que APE adoptará (D11).
