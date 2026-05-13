# LEGION: Council of Experts via Prompt Personas in the Finite APE Machine

**Tipo de documento:** Especificación técnica  
**Versión:** 0.4 (Draft)  
**Fecha:** Mayo 2026  
**Autor:** En elaboración  

---

## Abstract

`legion` es una **skill universal** dentro del ecosistema Inquiry. Su mandato es convocar un consejo de expertos —personas con perspectivas cognitivas genuinamente distintas— para analizar un problema desde múltiples ángulos antes de sintetizar una conclusión. Cada experto es invocado como sub-agente independiente con su propio contexto, herramientas y skills, maximizando la independencia de perspectivas. El propio LLM es la función de gating que decide qué expertos convocar.

A diferencia de las skills inquiry-bound (`doc-read`, `issue-create`, etc.) que requieren el FSM y el CLI `iq` para funcionar, `legion` es **independiente de Inquiry**: su protocolo (selección de expertos → invocación de sub-agentes → síntesis → persistencia .md) funciona con cualquier agente, en cualquier contexto. Inquiry la enriquece con contexto de fase, pero no la requiere.

LEGION es el nombre de la **técnica** que `legion` implementa. La decisión de implementarla como Skill (no como APE) fue tomada mediante un dictamen formal de consejo de expertos documentado en [`council_of_experts.md`](council_of_experts.md).

---

## 1. Introducción

### 1.1 El problema

Un agente generalista produce respuestas generalistas. Cuando se le presenta un problema complejo —un stored procedure que no registra un bono, un diseño de arquitectura con trade-offs sutiles, una decisión de negocio con implicaciones técnicas— el LLM tiende a promediar perspectivas en lugar de articularlas por separado. El resultado es una respuesta competente pero plana, que no revela las tensiones entre dominios.

### 1.2 La hipótesis

**Si se le pide al mismo modelo que razone desde perspectivas genuinamente distintas (un DBA, un analista de negocio, un diseñador autodidacta, un premio Nobel), los framings diferentes producen análisis que cubren regiones distintas del espacio de soluciones.** Los errores de cada perspectiva no se correlacionan entre sí, y la síntesis resultante es más rica que cualquier análisis individual.

Esta hipótesis no requiere independencia estadística perfecta (mismo modelo, mismos pesos). El valor viene del **framing diverso**: cada persona fuerza al modelo a priorizar distintos ejes del problema, revelar distintos riesgos, y proponer distintas soluciones.

### 1.3 Posición en el Finite APE Machine

`legion` es una **skill universal** — invocable por cualquier APE, por el usuario, o por cualquier agente fuera de Inquiry:

- **SOCRATES** puede invocarla durante ANALYZE para obtener perspectivas múltiples
- **DEWEY** puede usarla en IDLE para evaluar si un issue merece trabajo
- **DESCARTES** puede invocarla durante PLAN para validar un diseño
- **DARWIN** puede usarla en EVOLUTION para evaluar mutaciones metodológicas
- **El usuario** puede invocarla directamente en cualquier momento
- **Cualquier agente externo** puede usarla sin Inquiry instalado

La Skill no modifica el FSM. No requiere transiciones nuevas. No tiene sub-estados gestionados por `iq`. Cuando se usa dentro de Inquiry, el APE activo simplemente la invoca como herramienta de pensamiento.

### 1.4 Skill universal vs inquiry-bound

`legion` inaugura una distinción arquitectónica en Inquiry:

| Tipo | Registro | Entrega | Dependencia |
|------|----------|---------|-------------|
| **Universal** | Desplegada al target permanentemente (`.github/copilot/skills/`) | Siempre disponible | Ninguna — funciona con o sin Inquiry |
| **Inquiry-bound** | NO en el target | Bajo demanda via `iq skill get <name>` | Requiere FSM, cleanrooms, CLI `iq` |

Las skills inquiry-bound (`doc-read`, `issue-create`, `issue-start`, `issue-end`) solo tienen sentido con el runtime de Inquiry activo. Registrarlas en el target contamina el namespace del agente con capacidades que no funcionan fuera de un ciclo APE.

`legion` en cambio vive permanentemente en el target porque es útil siempre, con o sin Inquiry. Ver issue [#185](https://github.com/ccisnedev/inquiry/issues/185) para el módulo `iq skill`.

### 1.5 ¿Por qué Skill y no APE?

La decisión fue evaluada formalmente en [`council_of_experts.md`](council_of_experts.md) por un consejo de 5 expertos con perspectivas genuinamente distintas. El veredicto fue unánime (5/5, confianza promedio 0.87). Las razones decisivas:

1. **LEGION no pertenece a ninguna fase FSM.** Los APEs son la manifestación cognitiva de una fase del proceso. LEGION es una capacidad que cualquier fase puede necesitar. El invariante 1:1 APE↔Fase es un axioma de diseño.

2. **LEGION no es un método de razonamiento con warrant propio.** Los APEs representan tradiciones epistemológicas con autonomía inferencial (elenchus, duda metódica, selección natural). LEGION es una técnica de agregación que opera *mediante* los métodos existentes. Su warrant es de segundo orden: justifica la estrategia de agregar, no la verdad de ninguna conclusión.

3. **Skill-first preserva la opción de APE-later.** Si la evidencia empírica demuestra necesidad de estado persistente o identidad propia, la promoción es una evolución natural.

---

## 2. Fundamentos Teóricos

La base teórica de LEGION proviene de múltiples dominios. Se incluyen para dar rigor conceptual al diseño, con una nota honesta sobre las limitaciones de aplicar estos marcos a prompts sobre un mismo modelo.

### 2.1 Teorema del Jurado de Condorcet (1785)

Si cada tomador de decisión tiene probabilidad > 0.5 de acertar de forma independiente, la probabilidad de que la mayoría acierte crece monotónicamente con el número de participantes.

**Aplicación a LEGION:** Los "expertos" de LEGION no son independientes en sentido estricto (comparten el mismo modelo). Sin embargo, el framing distinto de cada persona actúa como un perturbador cognitivo que reduce la correlación de errores. El valor de Condorcet aplica de forma atenuada, no completa. La ejecución como sub-agentes con contexto aislado maximiza la independencia dentro de las limitaciones del sistema.

**Referencia:** Condorcet (1785). *Essai sur l'application de l'analyse à la probabilité des décisions*. Formalización moderna: Dietrich & Spiekermann (2021). *Jury Theorems*. Stanford Encyclopedia of Philosophy.

### 2.2 Diversidad Cognitiva — Page (2007)

Grupos cognitivamente diversos superan a grupos homogéneos cuando los problemas son genuinamente complejos, porque sus errores no se correlacionan.

**Aplicación a LEGION:** El catálogo de personas debe maximizar distancia cognitiva. Un DBA y un desarrollador PL/SQL son cercanos; un DBA y un diseñador autodidacta son lejanos. LEGION busca la segunda combinación. El valor no viene de la cantidad de expertos, sino de la diversidad de sus perspectivas.

**Referencia:** Page, S. E. (2007). *The Difference*. Princeton University Press.

### 2.3 Mixture of Experts (MoE) — Jacobs et al. (1991)

El paradigma MoE propone dividir el espacio de problemas en regiones gobernadas por expertos especializados, con una función de gating que enruta cada input al experto más adecuado.

**Aplicación a LEGION:** LEGION es una implementación de MoE a nivel de prompt engineering, donde **el LLM mismo es la función de gating**. No hay keyword matching, no hay embeddings. LEGION lee el problema, razona sobre qué perspectivas son relevantes, y selecciona del catálogo. El routing es semántico y contextual por naturaleza del modelo.

**Referencia:** Jacobs, R. A., Jordan, M. I., Nowlan, S. J., & Hinton, G. E. (1991). Adaptive Mixtures of Local Experts. *Neural Computation*, 3(1), 79–87.

### 2.4 Hierarchical Mixtures of Experts — Jordan & Jacobs (1994)

Jordan & Jacobs extienden el paradigma MoE a una estructura jerárquica: múltiples niveles de gating donde un router de nivel superior selecciona entre grupos de expertos, y cada grupo tiene su propio router local.

**Aplicación a LEGION:** LEGION opera naturalmente como un HMoE de tres niveles: (1) el APE de fase decide invocar a LEGION, (2) LEGION decide qué personas convocar del catálogo, (3) cada persona razona dentro de su dominio. La jerarquía no es forzada — emerge de la composición Skill-sobre-APE.

**Referencia:** Jordan, M. I. & Jacobs, R. A. (1994). Hierarchical Mixtures of Experts and the EM Algorithm. *Neural Computation*, 6(2), 181–214.

### 2.5 Sparsely-Gated MoE — Shazeer et al. (2017)

Shazeer et al. demuestran que la activación esparsa — seleccionar solo $K$ de $N$ expertos disponibles — produce resultados comparables a la activación completa con una fracción del costo computacional. El concepto clave es el **noisy top-k gating**: un mecanismo de selección que añade ruido antes de seleccionar los $K$ expertos con mayor score, promoviendo exploración.

**Aplicación a LEGION:** LEGION no invoca a todos los expertos del catálogo. Selecciona un subconjunto relevante (típicamente 3–5 de 8+). Esta activación esparsa no es por eficiencia — es por **relevancia**: invocar perspectivas irrelevantes diluye la calidad de la síntesis. El fundamento teórico de Shazeer et al. valida que la selección esparsa no sacrifica calidad.

**Referencia:** Shazeer, N. et al. (2017). Outrageously Large Neural Networks: The Sparsely-Gated Mixture-of-Experts Layer. *ICLR 2017*. https://arxiv.org/abs/1701.06538

### 2.6 MoP — Mixture of Prompts — Wang et al. (2024)

Wang et al. demuestran formalmente que **un único prompt no puede cubrir adecuadamente la diversidad del espacio de problemas** de una tarea compleja. MoP divide el espacio en sub-regiones y asigna prompts especializados a cada una.

**Aplicación a LEGION:** MoP es el antecedente teórico más cercano. LEGION no implementa MoP (no hay clustering de demos, no hay RBJS) — pero la tesis central de que "un prompt no basta" es exactamente la motivación de LEGION. La implementación es más simple: el LLM es el router, las personas son los prompts especializados.

**Referencia:** Wang, R. et al. (2024). One Prompt is not Enough: Automated Construction of a Mixture-of-Expert Prompts. *ICML 2024*, PMLR 235:50043–50064.

### 2.7 PanelGPT — Deliberación entre LLMs (Sun, 2023)

PanelGPT modela discusiones en panel entre LLMs, emulando deliberación de expertos reales con razonamiento paso a paso e integración iterativa.

**Aplicación a LEGION:** El protocolo de síntesis de LEGION se inspira en PanelGPT: cada experto produce un bloque estructurado, y LEGION los integra identificando consensos, disensos, y puntos ciegos.

**Referencia:** Sun, H. (2023). *PanelGPT*. Referenciado en Prompt Engineering Guide.

### 2.8 Limitaciones honestas

- **No hay independencia real completa.** Mismo modelo = mismos sesgos de base. El framing diverso mitiga pero no elimina. La ejecución como sub-agentes aislados maximiza la independencia posible dentro de esta limitación.
- **No es Condorcet completo.** Los expertos no votan sobre una respuesta binaria; producen análisis cualitativos. La síntesis es juicio, no mayoría simple.
- **El valor es empírico.** La técnica funciona en la práctica (council-of-experts es un patrón conocido en prompt engineering), pero no tiene las garantías formales de los teoremas citados.
- **Rendimientos marginales decrecientes.** Según Dietrich & Spiekermann (2021) y Karotkin & Paroush (2003), la probabilidad de corrección colectiva crece monotónicamente pero con rendimientos decrecientes. El grueso del beneficio se captura con 5–7 expertos; más allá, los nuevos expertos tienden a redundar con los existentes o a degradar la calidad de la síntesis.

---

## 3. Arquitectura

### 3.1 Principio de diseño

**Cero infraestructura adicional.** LEGION usa exactamente lo que Inquiry ya tiene:

- Una skill universal (`legion/SKILL.md`) desplegada al target
- Un catálogo de personas (libre en v1, YAML formalizado en futuro)
- El LLM como motor de razonamiento, routing, y síntesis
- Sub-agentes como mecanismo de ejecución aislada
- Dentro de Inquiry: los comandos existentes de `iq` enriquecen el contexto

### 3.2 Flujo operativo

```
[Usuario o APE invoca LEGION con un problema]
         │
         ▼
┌──────────────────────────────────────┐
│  1. COMPRENSIÓN                      │
│  LEGION analiza el problema.         │
│  Si necesita clarificación, puede    │
│  hacer preguntas al usuario.         │
└──────────────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  2. SELECCIÓN DE EXPERTOS            │
│  LEGION lee el catálogo de personas  │
│  y decide cuáles son relevantes.     │
│  El LLM ES la función de gating.    │
│  Anuncia los expertos seleccionados. │
└──────────────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  3. CONSULTA (sub-agentes)           │
│  Cada experto es invocado como       │
│  sub-agente independiente con:       │
│    - Su propia persona (prompt)      │
│    - Contexto aislado                │
│    - Acceso a skills y herramientas  │
│  Produce un dictamen estructurado:   │
│    - Perspectiva                     │
│    - Hallazgos                       │
│    - Riesgos identificados           │
│    - Recomendación                   │
│    - Nivel de confianza              │
└──────────────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  4. SÍNTESIS                         │
│  LEGION integra las perspectivas:    │
│    - Consensos (todos coinciden)     │
│    - Disensos (perspectivas opuestas)│
│    - Puntos ciegos (nadie cubrió)    │
│    - Recomendación final             │
│  El resultado se persiste en .md     │
└──────────────────────────────────────┘
```

### 3.3 Cada experto como sub-agente

Este es un principio de diseño fundamental: **cada experto del consejo es invocado como sub-agente independiente**, no como role-play secuencial dentro de un solo contexto. Esto garantiza:

- **Aislamiento de contexto**: cada experto arranca sin ver los dictámenes anteriores, eliminando anclaje progresivo. Esto preserva la base teórica de Condorcet (errores no correlacionados).
- **Acceso a herramientas**: cada sub-agente puede leer archivos, ejecutar comandos, buscar en el codebase — todo lo que necesite para fundamentar su perspectiva.
- **Acceso a skills**: un experto puede invocar `doc-read` para leer documentación existente, o cualquier otra skill relevante.
- **Independencia genuina**: el output de cada experto es formado sin influencia de los otros.

La síntesis es el único punto donde las perspectivas convergen — y es responsabilidad del agente orquestador, no de los expertos individuales.

### 3.4 Catálogo de personas

Para v1, la skill LEGION opera en **modo libre**: el agente selecciona libremente las características de cada experto según las necesidades de la situación. No hay catálogo fijo — el prompt de la skill instruye al agente a elegir perspectivas que maximicen distancia cognitiva para el problema específico.

En una etapa posterior, puede incorporarse un catálogo YAML formalizado con categorías y clasificación por dominio, donde el comando `iq` entrega expertos según categorías seleccionadas. Este catálogo permitiría escalabilidad y consistencia entre invocaciones.

**Catálogo de referencia** (no prescriptivo — guía de perspectivas cognitivas):

```yaml
# Perspectivas cognitivas de referencia para LEGION
# El agente puede usar estas o definir nuevas según el problema
personas_de_referencia:
  - id: nobel_physicist
    name: "Físico teórico (perfil Nobel)"
    perspective: "Pensamiento desde primeros principios"
    cognitive_style: |
      Descompone el problema hasta sus axiomas fundamentales.
      Busca las leyes subyacentes, no los síntomas.
      Cuestiona las suposiciones que todos dan por sentadas.
      Prefiere modelos elegantes sobre soluciones parcheadas.

  - id: senior_engineer
    name: "Ingeniero Senior (15+ años)"
    perspective: "Pragmatismo basado en experiencia"
    cognitive_style: |
      Piensa en mantenibilidad, deuda técnica, y lo que se rompe a las 3am.
      Valora lo simple que funciona sobre lo elegante que falla.
      Conoce los patrones que escalan y los que no.
      Siempre pregunta: ¿quién va a mantener esto?

  - id: business_analyst
    name: "Analista de negocio"
    perspective: "Valor y proceso desde la perspectiva del usuario"
    cognitive_style: |
      Traduce entre lo técnico y lo humano.
      Se enfoca en el flujo de valor, no en la implementación.
      Identifica reglas de negocio que los técnicos asumen o ignoran.
      Pregunta: ¿qué esperaba el usuario que pasara?

  - id: autodidact_designer
    name: "Diseñadora autodidacta"
    perspective: "Simplicidad radical y experiencia de usuario"
    cognitive_style: |
      Cuestiona la complejidad innecesaria.
      Si un usuario no puede entenderlo en 30 segundos, está mal.
      Piensa en flujos, no en componentes.
      Desconfía de las abstracciones que no simplifican.

  - id: security_auditor
    name: "Auditor de seguridad"
    perspective: "Modelo de amenazas y superficie de ataque"
    cognitive_style: |
      Piensa como un atacante.
      Identifica lo que puede salir mal, no lo que debería salir bien.
      Busca inyecciones, escalación de privilegios, datos expuestos.
      Asume que toda entrada es hostil.

  - id: dba_veteran
    name: "DBA veterano (Oracle/SQL Server)"
    perspective: "Rendimiento y integridad de datos"
    cognitive_style: |
      Piensa en locks, índices, planes de ejecución, y estadísticas.
      Sabe que el 80% de los problemas de rendimiento son queries mal escritas.
      Valora la integridad referencial sobre la conveniencia del desarrollador.
      Siempre revisa: ¿qué pasa bajo carga?

  - id: academic_researcher
    name: "Investigador académico"
    perspective: "Estado del arte y rigor formal"
    cognitive_style: |
      Conoce la literatura. Sabe qué se ha intentado y qué no ha funcionado.
      Distingue entre evidencia anecdótica y resultados reproducibles.
      Busca formalizaciones y pruebas, no opiniones.
      Advierte cuando se reinventa la rueda.
```

El catálogo es extensible. El usuario puede definir personas adicionales según su dominio.

### 3.5 Protocolo de síntesis y persistencia

El output de la síntesis se persiste como archivo `.md` en el directorio apropiado del ciclo activo (típicamente `cleanrooms/<branch>/analyze/`). La persistencia sigue el principio **Memory as Code** de Inquiry: el análisis no depende de la ventana de contexto del agente, sino de los archivos markdown que son versionables, legibles por humanos y por agentes, y sobreviven a resets de sesión.

**Estructura del dictamen:**

```markdown
## Consejo de Expertos — Síntesis

### Problema analizado
[Descripción del problema tal como fue comprendido]

### Expertos convocados
| # | Persona | Perspectiva | Confianza |
|---|---------|-------------|-----------|
| 1 | [nombre] | [perspectiva] | [alta/media/baja] |

### Dictámenes individuales
[Bloque estructurado por cada experto: perspectiva, hallazgos, riesgos, recomendación]

### Consensos
- [Punto en el que todos los expertos coinciden]

### Disensos
- **[Persona A]** vs **[Persona B]**: [descripción del desacuerdo y sus implicaciones]

### Puntos ciegos
- [Aspectos que ningún experto cubrió adecuadamente]

### Recomendación final
[Síntesis que integra las perspectivas, pondera los disensos, y propone una dirección]
```

### 3.6 Número de expertos

Según la investigación del Competence-Sensitive Jury Theorem (Dietrich & Spiekermann, 2021) y el análisis de tamaño óptimo de comités con competencia heterogénea (Karotkin & Paroush, 2003):

| Escenario | Expertos | Justificación |
|-----------|----------|---------------|
| Análisis focalizado | 3 | Problema claro con pocos dominios relevantes |
| **Análisis estándar (default)** | **5** | **Maximiza diversidad/calidad de síntesis** |
| Problema complejo multi-dominio | 5–7 | Cruza genuinamente muchos dominios |
| Máximo teórico útil | 7 | Más allá, rendimientos marginales insignificantes |

El costo de tokens no es un factor limitante — lo que limita es la diversidad cognitiva finita (no existe una cantidad infinita de marcos genuinamente ortogonales) y la calidad de la síntesis (más de 7 bloques dificultan la integración).

---

## 4. Integración con Inquiry

### 4.1 Skill `legion`

`legion` se despliega al target como skill universal — vive permanentemente en `.github/copilot/skills/legion/SKILL.md` (o el equivalente del target). No se entrega via `iq skill get` ni `iq target get`; está siempre disponible.

Dentro de Inquiry, puede ser invocada por cualquier APE en cualquier fase. Fuera de Inquiry, funciona con cualquier agente que soporte skills (GitHub Copilot, Cursor, Claude, etc.).

La técnica que implementa se llama LEGION — *"Mi nombre es LEGION, porque somos muchos."*

### 4.2 Relación con otros APEs

| APE | Relación con LEGION |
|-----|---------------------|
| **SOCRATES** | Complementario. SOCRATES interroga en profundidad; LEGION consulta en amplitud. SOCRATES puede invocar a LEGION como herramienta. |
| **DEWEY** | LEGION puede ayudar a DEWEY a evaluar si un issue merece trabajo, consultando perspectivas diversas sobre su valor. |
| **DESCARTES** | LEGION puede validar un plan desde múltiples perspectivas antes de aprobarlo. |
| **BASHŌ** | No hay interacción directa. BASHŌ implementa; no necesita consejo. |
| **DARWIN** | DARWIN podría invocar a LEGION para evaluar mutaciones metodológicas desde perspectivas diversas. |

### 4.3 Comandos `iq` relevantes (solo dentro de Inquiry)

| Comando | Utilidad para `legion` |
|---------|--------------------------------------|
| `iq fsm state` | Saber en qué fase está para adaptar perspectivas al contexto |
| `iq ape state` | Conocer el sub-estado del APE que invoca al consejo |
| `iq skill get <name>` | Obtener skills inquiry-bound complementarias (futuro, ver [#185](https://github.com/ccisnedev/inquiry/issues/185)) |

Dentro de Inquiry, el consejo recibe el inquiry-context inyectado por el APE activo. Fuera de Inquiry, funciona sin estos comandos — el agente usa su contexto nativo. La persistencia del output usa el patrón `doc-write` cuando está disponible, o persistencia directa a `.md` en caso contrario.

---

## 5. Nombre y filosofía

**LEGION** es tanto el nombre de la **técnica** como de la **skill** (`legion`).

LEGION sigue la convención de identidad de Inquiry: los APEs llevan nombres filosóficos (Sócrates, Descartes, Bashō, Dewey, Darwin). LEGION encarna la **inteligencia colectiva** — *"Mi nombre es LEGION, porque somos muchos."* No es un pensador; es un convocador de pensadores.

La skill se llama `legion` — nombre unificado que refleja directamente la técnica. Aparece en SKILL.md, en paths, en invocaciones.

---

## 6. Trabajo Futuro

- **Módulo `iq skill`** ([#185](https://github.com/ccisnedev/inquiry/issues/185)): comandos `iq skill list` / `iq skill get` para entrega bajo demanda de skills inquiry-bound. Las skills universales como `legion` quedan fuera de este módulo — viven en el target.
- **Catálogo YAML formalizado**: catálogo con categorías, clasificación por dominio, y selección asistida. Permite escalabilidad y consistencia entre invocaciones.
- **Persistencia de sesiones**: guardar la síntesis como artefacto indexado en `cleanrooms/` para que otros APEs la consuman via `doc-read`.
- **Modo interactivo**: permitir que el usuario interactúe con un experto específico después de la síntesis inicial, profundizando en su perspectiva.
- **Promoción a APE subroutine**: si `legion` demuestra valor consistente y necesidad de estado persistente, evaluar integración formal usando el modelo de autómata de subrutina (call-return composition).
- **Métricas**: registrar qué personas fueron invocadas y si la síntesis fue útil, para refinar el catálogo con datos.
- **Página en site**: documentar `legion` en `inquiry.ccisne.dev` como capacidad pública — potencial puerta de entrada a la metodología Inquiry.

---

## 7. Referencias

1. **Condorcet, M. J. A. N. C.** (1785). *Essai sur l'application de l'analyse à la probabilité des décisions rendues à la pluralité des voix*. Imprimerie Royale, Paris.

2. **Dietrich, F. & Spiekermann, K.** (2021). Jury Theorems. *Stanford Encyclopedia of Philosophy*. https://plato.stanford.edu/entries/jury-theorems/

3. **Jacobs, R. A., Jordan, M. I., Nowlan, S. J., & Hinton, G. E.** (1991). Adaptive Mixtures of Local Experts. *Neural Computation*, 3(1), 79–87. https://doi.org/10.1162/neco.1991.3.1.79

4. **Jordan, M. I. & Jacobs, R. A.** (1994). Hierarchical Mixtures of Experts and the EM Algorithm. *Neural Computation*, 6(2), 181–214. https://doi.org/10.1162/neco.1994.6.2.181

5. **Karotkin, D. & Paroush, J.** (2003). Optimum Committee Size: Quality-versus-Quantity Dilemma. *Social Choice and Welfare*, 20(3), 429–441. https://doi.org/10.1007/s003550200190

6. **Page, S. E.** (2007). *The Difference: How the Power of Diversity Creates Better Groups, Firms, Schools, and Societies*. Princeton University Press. ISBN: 978-0-691-12838-2.

7. **Shazeer, N., Mirhoseini, A., Maziarz, K., Davis, A., Le, Q., Hinton, G., & Dean, J.** (2017). Outrageously Large Neural Networks: The Sparsely-Gated Mixture-of-Experts Layer. *International Conference on Learning Representations (ICLR 2017)*. https://arxiv.org/abs/1701.06538

8. **Sun, H.** (2023). PanelGPT: Prompting with Panel Discussions among LLMs. Referenciado en: Prompt Engineering Guide. https://www.promptingguide.ai/techniques/tot

9. **Surowiecki, J.** (2004). *The Wisdom of Crowds*. Doubleday. ISBN: 978-0-385-50386-0.

10. **Wang, R. et al.** (2024). One Prompt is not Enough: Automated Construction of a Mixture-of-Expert Prompts. *ICML 2024*, PMLR 235:50043–50064. (Citado como antecedente teórico; LEGION no implementa MoP — usa el LLM como router directo.)

---

*LEGION — legion Skill — Draft v0.4 — Mayo 2026*
