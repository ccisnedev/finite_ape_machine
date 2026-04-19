# Review Log — APE Paper

Registro de revisiones científicas del paper "Finite APE Machine: Cooperative FSM Orchestration for AI-Assisted Software Engineering".

Objetivo: rastrear evolución de calidad del paper a través de revisiones sucesivas.

---

## Review #1 — 2026-04-19

**Reviewer:** AI (Claude Opus 4.6, rol: revisor riguroso)  
**Manuscript version:** First draft (pre-borrador, en construcción activa)  
**Recommendation:** Major Revision  

### Scores

| Dimension | Score | Notes |
|---|---|---|
| Originality | 7/10 | Cross-pollination genuina de 6 campos. Contribuciones overclaimed (10 → ~6 defensibles). |
| Technical soundness | 4/10 | Formalismo como notación, no como herramienta. Sin pruebas formales. |
| Clarity | 7/10 | Bien estructurado. Falta figuras/diagramas. Abstract pendiente (escribir al final). |
| Related work | 8/10 | 36 refs bien usadas. Table 1 excelente. |
| Reproducibility | 2/10 | Sin datos empíricos. Sin metodología de experimentación definida. |
| **Overall** | **4/10** | Ideas interesantes, validación insuficiente para publicación. |

### Key decisions from author response

1. **Paper en construcción** — no es borrador final, es documento vivo durante desarrollo de APE.
2. **Reframe contributions** — de "novel" a "applications of known techniques in a novel context" donde aplique.
3. **DARWIN exists** — funciona como EVOLUTION state, genera issues, lee mutations.md. Necesita documentarse con ejemplo concreto.
4. **"Infinite monkeys"** — reducir a 1 aparición. Autor quiere ver propuestas antes del cambio.
5. **Abstract** — escribir al final cuando paper esté completo. [NOTA: no tocar abstract hasta entonces]
6. **Figuras necesarias** — architecture diagram, tick cycle sequence diagram, FSM diagram.
7. **Experimental methodology needed** — cada issue atendida con APE es un experimento. Falta definir qué documentar y cómo.
8. **Antifragility testing plan** — probar con: (a) Crush + modelo cloud gratuito, (b) modelo local (gemma4). Validar accesibilidad.

### Open questions for next revision

- W6: "What is the failure mode when an ape produces invalid output that passes validation?" — autor pide ejemplos concretos.
- Q3: "How does APE handle LLM refusing to follow δ?" — autor pide ejemplos y contraejemplos.
- Methodology: ¿Qué datos capturar por experimento (issue)? ¿Qué formato? ¿Qué métricas?

### Action items

- [x] Definir metodología experimental (qué documentar por issue/ciclo APE)
- [x] Reducir contribuciones de 10 a ~6 defensibles
- [x] Agregar ejemplo concreto de ciclo DARWIN (antes → lesson → issue generada)
- [ ] Crear figuras: architecture, tick cycle, FSM states
- [x] Eliminar 2 de 3 apariciones de "infinite monkeys" (§10 reescrito con tesis)
- [x] Documentar failure modes con ejemplos concretos
- [ ] Probar APE con Crush + cloud model gratuito (Scenario A validation)
- [ ] Probar APE con modelo local gemma4 (Scenario A validation)
- [x] Nota: paper y ape_cli ambos en construcción (§3.2)
- [x] Nota: roster actual = 4 apes, 7 es diseño aspiracional (§3.2)

---

<!-- Template for future reviews:

## Review #N — YYYY-MM-DD

**Reviewer:**  
**Manuscript version:**  
**Recommendation:**  

### Scores

| Dimension | Score | Notes |
|---|---|---|
| Originality | /10 | |
| Technical soundness | /10 | |
| Clarity | /10 | |
| Related work | /10 | |
| Reproducibility | /10 | |
| **Overall** | **/10** | |

### Key findings

### Action items

-->
