---
id: diagnosis
title: "Diagnosis: APE VS Code Extension v0.0.1"
date: 2026-04-19
status: active
tags: [vscode, extension, diagnosis, marketplace]
author: socrates
---

# Diagnosis: APE VS Code Extension v0.0.1

> Resultado de 4 rondas de análisis socrático sobre el Issue #82.
> Este documento refleja lo que realmente se descubrió, no lo que se deseaba descubrir.

---

## 1. Problema Definido

**No hay un problema que resolver.**

Durante las 4 rondas de análisis, el usuario admitió explícitamente:

- *"No hay un problema real, una extensión nunca ha sido necesaria."*
- La afirmación de que los usuarios no pueden ejecutar comandos fue *"especulación sin fundamento."*
- La extensión es *"una mejora, no una necesidad — un lujo, un extra."*

Lo que sí existe es una **oportunidad**: usar el VS Code Marketplace como canal de descubrimiento para APE CLI. Cada instalación es un usuario que encontró APE a través del Marketplace, no a través de la terminal.

### Propósito real (doble)

1. **Canal de descubrimiento:** La página del Marketplace (README, screenshots, descripción) funciona como landing page para desarrolladores que buscan herramientas de automatización.
2. **Companion para usuarios existentes:** Para quien ya usa APE CLI, la extensión ofrece visibilidad del estado FSM sin salir del editor.

La extensión no resuelve un dolor. La extensión *es* el producto.

---

## 2. Decisiones Tomadas

### D1: La extensión es un canal de marketing, no una solución a un problema

**Justificación:** En la Ronda 3, al cuestionar la evidencia de que los usuarios necesitan una interfaz visual, el usuario reconoció que no existe tal evidencia. La motivación real es presencia en el Marketplace — como sqlite-inspector, que con 15K instalaciones demuestra que el canal funciona.

### D2: v0.0.1 solo refleja capacidades existentes del CLI

**Justificación:** En la Ronda 2, el usuario pivotó de una visión ambiciosa ("centro de mando") a un alcance mínimo: solo lo que APE CLI ya implementa hoy. Nada futuro, nada especulativo. Esto evita construir UI para features que no existen en el backend.

### D3: Aproximación "de menos a más"

**Justificación:** El usuario definió el enfoque como incremental. v0.0.1 es el mínimo publicable. Las features adicionales se agregan solo si hay demanda o necesidad demostrada.

### D4: La página del Marketplace es parte del producto

**Justificación:** En la Ronda 4, el usuario confirmó que *"el producto es la extensión misma"*, incluyendo la página del Marketplace. El README, las capturas de pantalla, y la descripción son tan importantes como el código.

### D5: Publicable desde día uno

**Justificación:** El usuario tiene experiencia publicando extensiones (sqlite-inspector, ccisnedev publisher, v0.0.2, 15K instalaciones, MIT). La infraestructura de publicación ya existe. No hay razón para retrasar la publicación.

---

## 3. Alcance v0.0.1

### 3.1 Lo que ENTRA (4 features)

| # | Feature | Descripción | Fuente de datos |
|---|---------|-------------|-----------------|
| 1 | Detección de `.ape/` | Activar la extensión solo cuando existe `.ape/` en el workspace | `fs.existsSync` / `workspaceContains` |
| 2 | Toggle de evolución | Activar/desactivar `evolution.enabled` en `.ape/config.yaml` | Lectura/escritura de `.ape/config.yaml` |
| 3 | Estado FSM en tiempo real | Mostrar fase del ciclo + número de tarea en status bar | `FileSystemWatcher` sobre `.ape/state.yaml` |
| 4 | Añadir mutaciones | Agregar notas a `.ape/mutations.md` desde command palette | Append a `.ape/mutations.md` |

### 3.2 Lo que NO ENTRA

| Feature excluida | Razón |
|------------------|-------|
| Detector/instalador de CLI | No ejecutar ni descargar binarios en v0.0.1 |
| Runner de comandos CLI | No invocar `ape` desde VS Code |
| Transiciones FSM desde VS Code | Requeriría ejecutar CLI |
| Doctor TreeView | Feature futura, no existe demanda |
| Plan TreeView con checkboxes | Feature futura |
| WebView del diagrama de ciclo | Status bar es suficiente para v0.0.1 |
| Atajos de teclado | Prematuro sin uso real |
| Verificador de actualizaciones | Complejidad innecesaria en v0.0.1 |
| Iconos SVG de estado | Usar codicons existentes |

### 3.3 Criterio de frontera

La regla es simple: **si requiere ejecutar el binario `ape` o implementar lógica que el CLI no tiene, está fuera de v0.0.1.** La extensión solo lee y escribe archivos YAML/Markdown dentro de `.ape/`.

---

## 4. Restricciones Técnicas y Riesgos

### Restricciones

| Restricción | Implicación |
|-------------|-------------|
| TypeScript + webpack | Mismo stack que sqlite-inspector. Sin curva de aprendizaje. |
| Publisher: ccisnedev | Ya verificado y activo en el Marketplace |
| Ubicación: `code/vscode/` | Dentro del monorepo finite_ape_machine |
| `.ape/config.yaml` puede no existir | La extensión debe manejar creación del archivo y de la clave `evolution.enabled` |
| `.ape/state.yaml` formato | `cycle.phase` y `cycle.task` — la extensión depende de este esquema |

### Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|-------------|---------|------------|
| Nadie instala la extensión | Alta | Bajo | El costo de desarrollo es bajo. Incluso 5 instalaciones son 5 usuarios nuevos. |
| Formato de `state.yaml` cambia | Media | Alto | Definir esquema en el spec. Versionar el contrato. |
| `config.yaml` no existe en workspaces actuales | Alta | Medio | La extensión crea el archivo si no existe, con valores por defecto. |
| Marketplace rechaza la extensión | Baja | Medio | El publisher ya está verificado. Seguir guías de publicación. |

---

## 5. Estrategia de Marketplace

La página del Marketplace no es un accesorio — es el producto principal de descubrimiento.

### 5.1 Elementos clave

| Elemento | Propósito |
|----------|-----------|
| **Nombre:** APE — Finite APE Machine | Reconocible, buscable |
| **Descripción corta** | Una línea que explique qué hace APE CLI y qué ofrece la extensión |
| **README con screenshots** | Mostrar status bar con estado FSM, command palette, toggle de evolución |
| **Badges** | Versión, licencia, installs |
| **Categorías** | Other (o Visualization) — no hay categoría perfecta |
| **Tags** | `cli`, `automation`, `fsm`, `ai`, `workflow` |

### 5.2 Lo que aprendimos de sqlite-inspector

- ccisnedev como publisher funciona y está verificado
- 15K instalaciones demuestran que el canal genera tráfico orgánico
- MIT como licencia es la elección probada
- v0.0.2 como versión publicada indica iteración rápida post-lanzamiento

### 5.3 Flujo de descubrimiento esperado

```
Desarrollador busca en Marketplace
  → encuentra "APE — Finite APE Machine"
  → lee README, ve screenshots
  → instala extensión
  → descubre APE CLI a través de la documentación
  → (opcionalmente) instala APE CLI
```

El éxito no se mide en instalaciones, sino en que la extensión exista como punto de entrada.

---

## 6. Referencias

| Documento | Ubicación | Relevancia |
|-----------|-----------|------------|
| Spec de la extensión | `code/vscode/docs/ape_vscode_extension.md` | Arquitectura y visión original (draft, anterior al análisis socrático) |
| Research de Flutter ext | `code/vscode/docs/flutter_vscode_extension.md` | Análisis de Dart-Code como referencia de arquitectura |
| sqlite-inspector | [Marketplace](https://marketplace.visualstudio.com/items?itemName=ccisnedev.sqlite-inspector) | Extensión existente del mismo publisher, referencia de publicación |
| APE CLI state.yaml | `.ape/state.yaml` | Contrato de datos para la feature de estado FSM |
| APE CLI config.yaml | `.ape/config.yaml` | Contrato de datos para el toggle de evolución |
| APE CLI mutations.md | `.ape/mutations.md` | Contrato de datos para la feature de mutaciones |

---

## Veredicto

La extensión APE VS Code no resuelve un problema. No hay usuarios pidiendo una GUI. No hay dolor que aliviar.

Lo que sí hace es crear un **punto de presencia** en el ecosistema VS Code — el editor donde viven los desarrolladores. Es un canal de descubrimiento con utilidad real pero modesta: ver el estado FSM, togglear evolución, anotar mutaciones.

El alcance de v0.0.1 es deliberadamente mínimo: 4 features que leen y escriben archivos dentro de `.ape/`. Nada de ejecutar binarios, nada de features futuras, nada de especulación.

*"Hagamos la extensión, punto."*
