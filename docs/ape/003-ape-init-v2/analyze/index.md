---
id: index
title: "Análisis 003: ape init v0.0.2 — configurador global de agentes"
date: 2026-04-16
status: active
tags: [ape-init, global, agents, skills, analysis, adapter-pattern]
author: socrates
---

# 003 — ape init v2: Análisis

APE v0.0.2 evoluciona de un creador de directorio vacío (v0.0.1) a una herramienta global que despliega agentes y skills a los paths globales de 5 AI coding tools.

## Documentos

| ID | Título | Estado |
|----|--------|--------|
| alcance-v002 | Alcance v0.0.2: entregables, scope, exclusiones | draft |
| decisiones | Decisiones vigentes (D4–D19) | draft |
| comandos-v002 | Comandos v0.0.2: superficie y semántica | draft |
| arquitectura-assets | Arquitectura de assets: build, distribución, despliegue | draft |
| referencia-gentle-ai | Patrones de gentle-ai relevantes para APE | active |

### Archivados (contexto histórico)

| ID | Título | Razón |
|----|--------|-------|
| estado-actual | Estado previo: dos repos, config global, ape init v0.0.1 | Contexto inicial, superado por el pivote global |
| pivote-global | Documentación del cambio per-repo → global | El pivote ya es el estado actual |

## Decisiones vigentes

| ID | Resumen |
|----|---------|
| D4 | Binario + assets en disco = fuente de verdad |
| D5 | Clase Assets lee archivos .md relativos al ejecutable |
| D6 + D17 | Despliega a todos los targets, sin selección |
| D8 | Build: `build/bin/` + `build/assets/` |
| D11 | Distribución: GitHub Release + install.ps1 (Windows-only) |
| D12 | APE es herramienta global (paths del sistema) |
| D13 | 5 targets: Copilot, Claude, Codex, Crush, Gemini |
| D14 | Adapter pattern por target |
| D15 + D19 | Tres módulos: `target` (en alcance), `bin` y `repo` (diferidos) |
| D16 | Install script ejecuta `ape target get` |
| D18 | `ape target get` es idempotente (clean + redeploy) |

## Entregables

| # | Entregable | Depende de |
|---|-----------|------------|
| E1 | Clase Assets + archivos .md fuente | — |
| E2 | Adapter pattern (5 targets) | — |
| E3 | Módulo `target` (get + clean) | E1 + E2 |
| E4 | install.ps1 + GitHub Release | E3 |
