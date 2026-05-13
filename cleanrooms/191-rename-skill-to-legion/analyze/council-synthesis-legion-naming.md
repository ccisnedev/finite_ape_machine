# Council of Experts — Síntesis: Naming de la Skill (LEGION vs Invoke-ExpertCouncil)

## Problema analizado

Decisión de naming para promoción pública de la skill: ¿usar el nombre semántico `Invoke-ExpertCouncil` o el nombre evocativo `LEGION` como identidad comercial/pública del proyecto?

## Expertos convocados

| # | Persona | Perspectiva | Confianza |
|---|---------|-------------|-----------|
| 1 | Developer Advocate (OSS) | Adopción y comunidad open source | Alta |
| 2 | Semiólogo Cultural | Resonancia cross-cultural del signo | Alta |
| 3 | Technical Writer / API Designer | Discoverability, coherencia de naming | Alta |
| 4 | Product Marketing Manager | SEO, shareability, growth | Alta |
| 5 | CS Publication Strategist | Citabilidad, naming académico | Alta |

## Dictámenes individuales

### Expert: Developer Advocate (OSS)
**Perspectiva:** Adopción, ergonomía, coherencia con framework

**Findings:**
- `/legion` (7 chars) vs `/Invoke-ExpertCouncil` (21 chars) — ergonomía clara
- "I used LEGION" viaja mejor en conversación que "I used Invoke-ExpertCouncil"
- El framework ya entrena a usuarios en naming evocativo (SOCRATES, DESCARTES...)
- La referencia bíblica ha sido secularizada por pop-culture (X-Men, Mass Effect, gaming)

**Risks:** Connotación demoníaca (mitigable con tagline), colisión de namespace (mitigable con contexto)

**Recommendation:** LEGION — la convención existente es el factor decisivo.

**Confidence:** Alta

---

### Expert: Semiólogo Cultural
**Perspectiva:** Resonancia cross-cultural del signo LEGION

**Findings:**
- El signo tiene polisemia a favor: militares romanos → sistemas distribuidos → inteligencia colectiva
- Pop-culture ha secularizado completamente la referencia para developers <45
- La convención del framework (nombres intelectuales) protege la interpretación
- No hay riesgo en East Asia (レギオン = colectivo sci-fi/gaming)
- Riesgo menor en audiencias conservadoras cristianas (~2% objección fuerte)

**Risks:** Developers conservadores en US South/Brazil/Philippines (bajo). Islam no tiene cognado directo.

**Recommendation:** LEGION funciona cross-culturally. El contexto del framework protege la interpretación.

**Confidence:** Alta

---

### Expert: Technical Writer / API Designer
**Perspectiva:** Discoverability, coherencia de registros de naming

**Findings:**
- El framework tiene dos registros: operacional (descriptivo) e identidad (evocativo)
- Las skills existentes son TODAS descriptivas: `doc-read`, `issue-create`, `issue-start`
- LEGION cruza la frontera de registro — podría confundir: "¿es un APE o una skill?"
- `Invoke-ExpertCouncil` tiene zero-doc discoverability (el nombre es la documentación)
- La ventaja de longitud es débil (se invoca 1 vez por sesión, no en loops)

**Risks:** LEGION rompe el patrón de naming de skills. Confusión APE vs Skill.

**Recommendation:** `Invoke-ExpertCouncil` — consistencia de registro > memorabilidad individual.

**Confidence:** Alta

---

### Expert: Product Marketing Manager
**Perspectiva:** GTM, shareability, growth de open source

**Findings:**
- "I ran LEGION on it" es meme-able; "I ran Invoke-ExpertCouncil" no lo es
- Conference CFP: "LEGION — when one expert isn't enough" > título descriptivo
- GitHub star psychology: nombres curiosos generan clicks
- SEO: "LEGION" es ruidoso day-1 pero ownable como nicho en ~4 semanas
- Todos los dev tools exitosos eligieron evocativo (Docker, Kubernetes, Terraform)

**Risks:** SEO disambiguation (~4 semanas). Colisión con otros proyectos "Legion".

**Recommendation:** LEGION como nombre público. `Invoke-ExpertCouncil` como skill ID interno.

**Confidence:** Alta

---

### Expert: CS Publication Strategist
**Perspectiva:** Citabilidad, naming en papers académicos

**Findings:**
- Papers citados usan nombres cortos: BERT, GPT, RAFT, STORM, CAMEL, MetaGPT
- `Invoke-ExpertCouncil` es impronunciable en talks e incitable en prosa
- LEGION tiene backronym natural: **L**LM **E**xpert **G**roup for **I**ndependent **O**pinion **N**egotiation
- Colisión con papers existentes (Legion 2019) — mitigable con backronym + dominio
- "a LEGION run" funciona gramaticalmente; "an Invoke-ExpertCouncil run" no

**Risks:** Name collision con distributed systems paper (2019). Mitigable.

**Recommendation:** LEGION con backronym en abstract del paper.

**Confidence:** Alta

---

## Consensos

1. **LEGION es el nombre público/comercial/académico.** 4 de 5 expertos recomiendan LEGION sin reservas. El quinto (Technical Writer) lo reconoce como viable pero prefiere consistencia interna.

2. **`Invoke-ExpertCouncil` debe mantenerse como identificador técnico interno.** Todos coinciden en que es un nombre excelente para el archivo SKILL.md, el path, y el skill ID programático.

3. **La convención del framework es el factor decisivo.** SOCRATES, DESCARTES, BASHŌ, DARWIN, DEWEY — LEGION extiende el patrón; `Invoke-ExpertCouncil` lo rompe.

4. **La referencia bíblica no es un riesgo material.** Pop-culture la secularizó. El contexto del framework la reinterpreta. Audiencia target (developers globales) la lee como "cool" no como "religioso".

5. **SEO es solvable, memorabilidad no.** Descriptive naming tiene ventaja day-1 que desaparece con contenido. Evocative naming construye brand equity compuesta.

## Disensos

- **Technical Writer vs todos los demás:** El TW argumenta que las skills usan registro descriptivo y LEGION cruza fronteras. Contraargumento: LEGION es la primera skill *universal* — su naturaleza es diferente de `doc-read` o `issue-create`. La frontera de registro puede no aplicar uniformemente.

## Puntos ciegos

1. **Dual naming burden.** Si LEGION es el nombre público pero `Invoke-ExpertCouncil` es el skill ID interno, hay un costo cognitivo: el usuario debe saber que son lo mismo. Mitigación: alias `/legion` → `Invoke-ExpertCouncil`.

2. **Evolución del catálogo.** Si en el futuro hay más skills universales (una familia "LEGION"), ¿cada una tendrá nombre evocativo? Podría crear inconsistencia acumulativa. Pero es un problema futuro, no presente.

## Recomendación final

**LEGION es el nombre público.** `Invoke-ExpertCouncil` se mantiene como skill ID técnico.

La estrategia dual:

| Contexto | Nombre |
|----------|--------|
| Artículos, papers, blog posts, talks | LEGION |
| GitHub README, documentation landing | LEGION (con subtítulo: "Council of Experts") |
| Archivo SKILL.md, path en repo | `Invoke-ExpertCouncil/SKILL.md` |
| Invocación en chat | `/legion` (alias de `Invoke-ExpertCouncil`) |
| Backronym académico | LLM Expert Group for Independent Opinion Negotiation |

Esta dualidad no es nueva — Docker (nombre comercial) vs `dockerd` (binario técnico). Kubernetes (nombre) vs `kubectl` (comando). El nombre público captura imaginación; el ID técnico captura función.

---

*Council of Experts — producido via Invoke-ExpertCouncil (LEGION) — Mayo 2026*
