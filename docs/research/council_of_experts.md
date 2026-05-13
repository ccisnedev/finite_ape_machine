# Council of Experts — Dictamen: ¿LEGION es Skill o APE?

> **Classification:** Research — dictamen formal de consejo de expertos  
> **Status:** Final  
> **Date:** 2026-05-12  
> **Convocado por:** LEGION Protocol (draft invocation)  
> **Problema:** Determinar si LEGION debe implementarse como Skill (protocolo invocable) o como APE (entidad autónoma con identidad y sub-estados) dentro del Finite APE Machine de Inquiry.

---

## Expertos convocados

| # | Persona | Perspectiva | Selección |
|---|---------|-------------|-----------|
| 1 | Arquitecto de Software (20+ años) | Acoplamiento, cohesión, extensibilidad | Evalúa impacto estructural en el sistema |
| 2 | Investigador en Métodos Formales | FSMs, determinismo, composabilidad | Evalúa impacto en el espacio de estados |
| 3 | Epistemólogo | Métodos vs técnicas de razonamiento | Evalúa si LEGION es un método genuino |
| 4 | Ingeniero de Sistemas Distribuidos | Orquestación, fan-out/fan-in, aislamiento | Evalúa la mecánica real de ejecución |
| 5 | Estratega de Producto | Valor, tiempo-a-valor, posicionamiento | Evalúa pragmática de entrega |

---

## Dictámenes individuales

### Experto 1 — Arquitecto de Software

**Marco:** Principios SOLID, puntos de extensión, invariantes arquitectónicos.

**Hallazgos:**

1. **LEGION viola el invariante 1:1 APE↔Fase.** El mapa `_stateApes` en `prompt.dart` asume un APE por estado FSM. LEGION no pertenece a ninguna fase específica. Hacerlo APE requiere: (a) crear una fase FSM nueva (absurdo), (b) permitir múltiples APEs por fase (rompe prompt composition), o (c) un APE "flotante" que coexiste con el APE de fase — requiere rediseñar el scheduler.

2. **La complejidad interna de LEGION no requiere sub-estados gestionados por runtime.** Su flujo (comprensión → selección → consulta → síntesis) se ejecuta completo en una sola invocación. Un protocolo secuencial en SKILL.md basta.

3. **LEGION como Skill preserva el Open/Closed Principle.** El sistema de skills es el punto de extensión diseñado para agregar capacidades sin modificar el núcleo. Agregar un skill no toca `_stateApes`, `ApeDefinition`, `ApePromptCommand`, ni el scheduler.

4. **La composición de expertos es ortogonal a la identidad de fase.** LEGION no piensa *como* el APE de fase — piensa *para* él. Es una relación herramienta→resultado, no identidad→misión.

5. **La invocación de sub-agentes es una capacidad de runtime, no de definición.** Que LEGION necesite sub-agentes reales no requiere que sea APE. El SKILL.md puede instruir la instanciación de sub-agentes.

**Recomendación:** Skill. **Confianza: alta.**

> "El test definitivo es el acoplamiento a fase. Si no pertenece a una fase, no es un APE."

---

### Experto 2 — Investigador en Métodos Formales

**Marco:** Espacios de estados, funciones de transición, totalidad, composabilidad de autómatas.

**Hallazgos:**

1. **Violación de la biyección $\phi: Q \to \mathcal{A}$.** El mapeo 1:1 entre estados FSM y APEs es el mecanismo que hace el dispatch determinista. LEGION-como-APE lo rompe. La función pasa de $\phi: Q \to \mathcal{A}$ a $\phi': Q \to \mathcal{P}(\mathcal{A}) \setminus \emptyset$ — dispatch no determinista.

2. **Explosión del espacio de estados.** Sub-FSMs concurrentes (APE de fase + LEGION) producen un producto cartesiano. Para $k = 4$ fases elegibles con 5 sub-estados promedio y LEGION con 4 sub-estados: de $5k = 20$ estados efectivos a $5 \times 4 \times k = 80$.

3. **Sincronización indefinida.** Dos sub-FSMs en la misma región (SOCRATES + LEGION durante ANALYZE) no tienen semántica de interleaving, resolución de conflictos, ni sincronización. Comportamiento indefinido a nivel de sub-estado.

4. **El gap de formalismo del skill es seguro.** LEGION tiene secuenciamiento interno que el modelo de skills no puede enforcar, pero el modo de falla es calidad degradada (el LLM se salta un paso), no comportamiento indefinido del sistema. Los skills existentes ya aceptan este trade-off.

5. **Existe una vía de escape formal:** el **autómata de subrutina** (composición call-return de CSP/Statecharts) preserva determinismo mediante anidamiento secuencial. Diferir hasta que la evidencia empírica lo demande.

**Recomendación:** Skill. **Confianza: 85%.**

> "La activación esparsa (seleccionar K de N expertos) mapea a sparse gating, no a estados FSM."

---

### Experto 3 — Epistemólogo

**Marco:** Autonomía epistémica, warrants, modos inferenciales en el ciclo peirciano.

**Hallazgos:**

1. **LEGION carece de autonomía epistémica.** El consejo de expertos no produce juicios *ex nihilo*. Cada perspectiva razona *dentro* de un modo inferencial existente: el físico abduce, el ingeniero deduce, el auditor enumera. LEGION agrega; la agregación no es un acto inferencial primitivo. El elenchus socrático *es* el acto inferencial; LEGION sin métodos-componente no produce nada.

2. **El warrant de LEGION es de segundo orden.** Condorcet y Page justifican la *estrategia de agregar*, no la *verdad de ninguna conclusión particular*. Los warrants de los APEs (elenchus, duda metódica, selección natural) son de primer orden — justifican conclusiones directamente.

3. **LEGION no ocupa una fase inferencial distinta.** El ciclo peirciano de Inquiry (abducción → deducción → inducción → problematización → selección) está agotado por los 5 APEs existentes. LEGION puede aplicarse *dentro* de cualquier fase. Esa ubicuidad trans-fase es la firma de una técnica, no de un método.

4. **La tradición de "sabiduría colectiva" es sociología del conocimiento, no filosofía del razonamiento.** Condorcet, Surowiecki, Page estudian *cómo se agrega* el conocimiento, no *cómo se produce*. No proponen un *organon* nuevo.

5. **Contraargumento parcial:** La deliberación puede generar emergencia epistémica. Pero en Inquiry esa emergencia se produce *mediante* los métodos existentes. LEGION orquesta la diversidad; no la constituye. Es un director de orquesta, no un instrumento.

**Recomendación:** Skill. **Confianza: alta (0.85).**

> "Los APEs son *thinking tools* con tradición warrantista propia. Como Skill, LEGION es más poderoso, no menos: puede ser invocado por cualquier APE en cualquier fase. La ubicuidad es su fuerza — y la ubicuidad es la firma de una técnica, no de un método."

---

### Experto 4 — Ingeniero de Sistemas Distribuidos

**Marco:** Patrones de orquestación, aislamiento de contexto, fan-out/fan-in.

**Hallazgos:**

1. **Fan-out/fan-in es un espejismo parcial.** La ejecución es estrictamente secuencial en el runtime actual. LEGION implementa role-switching con acumulación de outputs, no ejecución paralela real.

2. **Sub-agentes reales (`runSubagent`) entregan aislamiento genuino.** Cada experto arranca con contexto limpio. Los outputs son genuinamente independientes. Esta opción preserva la base teórica (errores no correlacionados).

3. **El aislamiento de contexto es la feature, no la limitación.** Toda la base teórica de LEGION (Condorcet, Page) depende de reducir correlación entre expertos. Sub-agentes reales la entregan; role-play secuencial en un solo contexto la destruye por anclaje progresivo.

4. **La capacidad de sub-agentes no depende de ser APE o Skill.** Un Skill puede instruir la invocación de sub-agentes de la misma forma que un APE. La diferencia es identidad y estado persistente, no capacidad de orquestación.

5. **Riesgo operativo principal:** la calidad de síntesis — un LLM calificando sus propios outputs. Mitigación: protocolo de síntesis con estructura fija (consensos, disensos, puntos ciegos), no estatus de APE.

**Recomendación:** Skill. **Confianza: 0.85.**

> "LEGION se invoca *dentro* de una fase, no *como* fase. Es una capacidad composable, no una etapa de ciclo de vida."

---

### Experto 5 — Estratega de Producto

**Marco:** Valor de usuario, time-to-value, riesgo de over/under-engineering.

**Hallazgos:**

1. **LEGION como Skill se entrega en horas.** Un SKILL.md + un YAML de catálogo + `iq target get`. Sin cambios en el CLI.

2. **LEGION como APE toma semanas.** YAML + modificaciones a prompt assembly + mecanismo de selección de APE por fase + tests + release.

3. **Skill-first no cierra la puerta a APE-later.** Si LEGION como Skill demuestra que necesita estado persistente, eso es evidencia concreta para promoción. Sin esa evidencia, la promoción es especulativa.

4. **Los APEs actuales ya pueden ser consultados como expertos.** SOCRATES, DESCARTES, DARWIN podrían ser perspectivas dentro de un consejo invocado por LEGION. Composición de Skills sobre APEs — el modelo correcto.

5. **El riesgo de over-engineering es real.** LEGION no mapea a una fase → rompe invariante → requiere cirugía → sin valor de usuario proporcional.

**Recomendación:** Skill. **Confianza: 90%.**

> "Validación primero, integración después. 2-3 semanas de uso real producirán datos concretos."

---

## Síntesis

### Consensos (5/5 coinciden)

1. **LEGION debe ser un Skill, no un APE.** Los cinco expertos coinciden con alta confianza (0.85–0.90). No hay disenso.

2. **La razón estructural es decisiva:** LEGION no pertenece a ninguna fase FSM. El invariante 1:1 APE↔Fase ($\phi: Q \to \mathcal{A}$) es un axioma de diseño que no debe romperse sin evidencia empírica.

3. **La razón epistemológica es complementaria:** LEGION no es un método de razonamiento con warrant propio — es una técnica de agregación que opera *mediante* los métodos existentes. Los APEs son tradiciones filosóficas; LEGION es una capacidad operacional.

4. **Skill-first preserva la opción de APE-later.** Promoción con evidencia, no sin ella.

5. **La capacidad de invocar sub-agentes no depende de ser APE.** Un Skill instruye sub-agentes reales con aislamiento de contexto.

### Disensos

No hay disensos materiales. La variación es de énfasis:

- **Arquitecto:** acoplamiento y SOLID
- **Formalista:** explosión del espacio de estados y determinismo
- **Epistemólogo:** taxonomía método/técnica y ciclo peirciano
- **Ingeniero:** mecánica de ejecución y aislamiento
- **Estratega:** time-to-value y riesgo de over-engineering

La convergencia desde cinco perspectivas genuinamente distintas refuerza la conclusión.

### Puntos ciegos

1. **Experiencia narrativa.** Los APEs tienen nombres filosóficos que crean narrativa memorable. LEGION como Skill pierde esa dimensión estética, aunque el nombre y la identidad del consejo pueden vivir en el SKILL.md.

2. **Modelo intermedio.** ¿Podría existir una categoría entre Skill y APE — un "Tool" con identidad pero sin acoplamiento a fase? Relevante si LEGION demuestra que la taxonomía binaria es insuficiente.

3. **Evidencia empírica inexistente.** Todos los argumentos son a priori. La verdadera prueba es implementar y medir.

### Recomendación final

**LEGION es un Skill.** Su nombre es LEGION. Su mandato es convocar un consejo de expertos. Su implementación es un protocolo invocable (SKILL.md + catálogo YAML) que cualquier APE o usuario puede activar. No tiene fase FSM propia, no tiene sub-estados gestionados por `iq`, no tiene identidad filosófica como thinking tool.

Lo que sí tiene: un nombre memorable, un catálogo extensible, un protocolo de síntesis con estructura formal, y la capacidad de invocar sub-agentes reales con aislamiento de contexto.

**Confianza del consejo: alta (0.87 promedio ponderado).**

### Criterios para revisitar esta decisión

Promover LEGION de Skill a APE subroutine si:
1. El uso empírico muestra que los LLMs consistentemente omiten o reordenan los sub-estados, degradando calidad
2. El sistema necesita *persistir* el sub-estado de LEGION entre turnos de conversación
3. Múltiples capacidades requieren invocación cross-fase de APEs (patrón emergente, no solo LEGION)

---

## Nota metodológica

Este dictamen fue producido invocando 5 sub-agentes en paralelo, cada uno con un prompt-persona distinto y contexto aislado. Los dictámenes individuales son genuinamente independientes (producidos sin acceso a los outputs de los otros expertos). La síntesis fue realizada por el agente orquestador integrando las 5 perspectivas.

Este proceso es una demostración operativa del mecanismo que LEGION formalizará como Skill.

---

## Número óptimo de expertos

### Fundamento teórico

Según la formalización de Dietrich & Spiekermann (2021) del Teorema del Jurado de Condorcet, la probabilidad de corrección de la mayoría $P(\text{Maj}_n)$ crece monotónicamente con $n$ bajo premisas de independencia y competencia — pero los **rendimientos marginales decrecen rápidamente**. Incluso con competencia individual modesta ($p = 0.6$), el grueso del beneficio se captura con $n \leq 7$.

Karotkin & Paroush (2003) demuestran que cuando los miembros tienen **competencia heterogénea** (como los expertos de LEGION), existe un **tamaño óptimo finito**. Agregar expertos menos competentes en el dominio específico puede *reducir* la calidad colectiva porque diluyen la señal.

Section 4.6 de Dietrich & Spiekermann (2021) identifica un factor adicional: la **competencia dependiente del grupo**. En grupos muy grandes, la calidad de la deliberación puede degradarse y la motivación individual puede caer. La competencia individual puede ser una función inicialmente creciente y luego decreciente de $n$.

### Aplicación a LEGION

En LEGION, los "expertos" son prompt-personas sobre el mismo modelo. Las limitaciones son:

1. **Diversidad cognitiva finita**: después de 5-7 perspectivas genuinamente distintas, las nuevas empiezan a redundar con las anteriores. No existe una cantidad infinita de marcos cognitivos mutuamente ortogonales.
2. **Anclaje contextual**: incluso con sub-agentes aislados, la síntesis se hace en un solo contexto. Más de 7 bloques de análisis dificultan una síntesis de calidad.
3. **Page's diversity theorem**: el valor viene de la *diversidad* de perspectivas, no de la *cantidad*. Agregar un octavo experto que es una variante del tercero no añade información nueva.

### Recomendación

| Escenario | Expertos | Justificación |
|-----------|----------|---------------|
| Análisis estándar | **3–5** | Cubre las perspectivas más relevantes sin redundancia. El rango que maximiza diversidad/calidad de síntesis. |
| Problema complejo multi-dominio | **5–7** | Cuando el problema cruza genuinamente muchos dominios (técnico + negocio + seguridad + UX + teoría). |
| Máximo teórico útil | **7** | Más allá de 7, los rendimientos marginales son empíricamente insignificantes y la síntesis se degrada. |

**El default recomendado es 5 expertos.** Este número balancea diversidad cognitiva suficiente con calidad de síntesis. El usuario puede ajustar hacia 3 (problemas focalizados) o 7 (problemas excepcionales).

---

## Referencias formales del dictamen

1. **Condorcet, M. J. A. N. C.** (1785). *Essai sur l'application de l'analyse à la probabilité des décisions*. — Base teórica para la agregación de juicios independientes.

2. **Dietrich, F. & Spiekermann, K.** (2021). *Jury Theorems*. Stanford Encyclopedia of Philosophy. — Formalización moderna, tamaño óptimo de grupo, tensión fundamental independencia/competencia.

3. **Harel, D.** (1987). Statecharts: A visual formalism for complex systems. *Science of Computer Programming*, 8(3). — Máquinas de estados jerárquicas, regiones ortogonales, composición de sub-FSMs.

4. **Jacobs, R. A., Jordan, M. I., Nowlan, S. J., & Hinton, G. E.** (1991). Adaptive Mixtures of Local Experts. *Neural Computation*, 3(1). — Paradigma MoE como metáfora arquitectónica.

5. **Karotkin, D. & Paroush, J.** (2003). Optimum Committee Size: Quality-versus-Quantity Dilemma. *Social Choice and Welfare*, 20(3). — Tamaño óptimo de comités con competencia heterogénea.

6. **Page, S. E.** (2007). *The Difference*. Princeton University Press. — Diversidad cognitiva como fuente de rendimiento colectivo.

---

*Council of Experts — Dictamen producido via LEGION Protocol (draft) — Mayo 2026*
