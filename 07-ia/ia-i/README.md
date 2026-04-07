# 🤖 Introducción a la IA Generativa

> **Objetivo:** Entender qué es la IA Generativa, cómo funciona por dentro, y ser capaz de llamar a un LLM desde código, hacer prompt engineering, construir un agente con tools y hacer RAG básico.

Este bloque esta pensado para ir de menos a mas:
- primero una llamada simple a un modelo,
- luego una llamada con mejor contexto usando `system prompt`,
- despues un agente con tools,
- y por ultimo un ejemplo sencillo de RAG con Qdrant.

---

## ✨ ¿Qué es la IA Generativa?

La IA Generativa es una rama de la inteligencia artificial capaz de **crear contenido nuevo**: texto, imágenes, código, audio, vídeo...

A diferencia de la IA tradicional (que clasifica o predice), la IA Generativa **genera**.

---

## 🧠 ¿Cómo funciona un LLM?

**LLM = Large Language Model** (Modelo de Lenguaje Grande)

Un LLM no "entiende" el lenguaje. Lo que hace es **predecir, token a token, cuál es la siguiente palabra más probable** dado el contexto anterior.

```
Input:  "El cielo es de color"
Output: "azul" (con alta probabilidad)
```

**¿Qué es un token?**
- Aproximadamente 3/4 de una palabra en inglés, algo menos en español
- Los modelos tienen un **límite de contexto** (context window): cuántos tokens pueden procesar a la vez

### 🏋️ El proceso de entrenamiento (simplificado)

```
1. Pre-training    → El modelo lee internet entero (Wikipedia, GitHub, libros...)
                     Aprende patrones del lenguaje

2. Fine-tuning     → Se especializa en seguir instrucciones
                     (RLHF: Reinforcement Learning from Human Feedback)

3. Inferencia      → Tú mandas un prompt, el modelo genera la respuesta
```

### 🎛️ Parámetros clave de las APIs

| Parámetro | Qué hace | Valores típicos |
|-----------|----------|-----------------|
| `temperature` | Aleatoriedad de la respuesta. 0 = determinista, 2 = caótico | 0.0 – 1.0 |
| `max_tokens` | Longitud máxima de la respuesta | 256 – 4096+ |
| `top_p` | Nucleus sampling. Alternativa a temperature | 0.9 – 1.0 |
| `system` | Instrucciones de comportamiento del modelo | "Eres un experto en..." |

---

## 🧩 Conceptos clave

### ✍️ Prompt Engineering

El arte de escribir buenas instrucciones para el modelo.

**Anatomía de un buen prompt:**

```
[ROL]            Eres un experto en...
[CONTEXTO]       El equipo usa Kubernetes en GKE con Helm charts.
[TAREA]          Analiza el siguiente error y propón una solución.
[RESTRICCIONES]  Responde en español. Máximo 5 pasos.
[INPUT]          <error>...</error>
```

**Tecnicas basicas:**
- **Zero-shot** → le preguntas directamente sin ejemplos
- **Few-shot** → le das 2-3 ejemplos antes de la pregunta real
- **Chain of Thought** → le pides que "piense paso a paso"
- **Role prompting** → le asignas un rol experto

### 🔢 Embeddings

Representaciones numéricas (vectores) del significado semántico de un texto.

```
"Kubernetes falla al hacer deploy"  →  [0.23, -0.87, 0.45, ...]  (vectores similares)
"Error en el despliegue de K8s"    →  [0.24, -0.85, 0.44, ...]

"Me gusta la pizza"                →  [0.91, 0.12, -0.67, ...]  (vector diferente)
```

**¿Para qué sirven?** → Para búsqueda semántica. La base de RAG.

### 📚 RAG (Retrieval-Augmented Generation)

El modelo no sabe nada de tu documentación interna. **RAG es la solución:**

```
1. Busca en tus documentos internos los fragmentos más relevantes
2. Los inyecta en el prompt como contexto
3. El LLM genera una respuesta basada en TU documentación
```

### 🧰 Agentes (Agents)

Un LLM que puede **tomar decisiones y usar herramientas** de forma autónoma.

```
Usuario: "Busca recetas con pollo y añade los ingredientes a la lista de la compra"

Agente:
  1. Decide: necesito buscar recetas → llama a buscar_receta("pollo")
  2. Recibe recetas → decide: necesito añadir ingredientes → llama a gestionar_lista_compra(...)
  3. Genera un resumen con las recetas y la lista actualizada
```

---

## 🌐 El ecosistema: modelos y proveedores

### 🆓 Opciones gratuitas

| Herramienta | Qué es | Instalación |
|-------------|--------|-------------|
| **[Ollama](https://ollama.com)** | Modelos locales, API compatible OpenAI | `brew install ollama` / [descarga](https://ollama.com/download) |
| **[LM Studio](https://lmstudio.ai)** | GUI para modelos locales | [Descarga directa](https://lmstudio.ai) |
| **[GitHub Models](https://github.com/marketplace/models)** | API gratis en la nube (con límites) | Solo necesitas cuenta de GitHub |
| **[Docker Model Runner](https://docs.docker.com/desktop/features/model-runner/)** | Modelos en contenedores Docker | Docker Desktop con la feature habilitada |

> 🔌 Todas estas opciones tienen API compatible con OpenAI. El código que escribas funcionara con cualquiera de ellas.

### 💻 Modelos recomendados (segun tu hardware)

| RAM disponible | Modelo recomendado | Comando |
|----------------|-------------------|----------|
| 8 GB | `llama3.2:3b`, `qwen2.5:3b` | `ollama pull llama3.2:3b` |
| 16 GB | `llama3.2`, `qwen2.5:7b`, `mistral` | `ollama pull llama3.2` |
| 32 GB+ | `llama3.3`, `qwen2.5:32b` | `ollama pull llama3.3` |

> 🔍 Usa [canirun.ai](https://www.canirun.ai/) para saber qué modelo puede correr tu máquina.

### 💳 Proveedores de pago (referencia)

| Proveedor | Modelos destacados |
|-----------|-------------------|
| **OpenAI** | GPT-4o, o3, o4-mini |
| **Anthropic** | Claude 3.5 Sonnet, Claude 4 |
| **Google** | Gemini 2.0 Flash, Pro |
| **Mistral** | Mistral Large, Codestral |

---

## ⚙️ Setup

```bash
cd 07-ia/ia-i

# Crear entorno virtual
python -m venv .venv
source .venv/bin/activate  # macOS/Linux

# Instalar dependencias
pip install -r requirements.txt

# Configurar variables de entorno
cp .env.example .env
# La plantilla deja GitHub Models como opcion activa por defecto.
# Edita .env si prefieres usar Ollama, Docker Model Runner, LM Studio u otro proveedor.
```

---

## 🧪 Ejemplos

### 01 — 🚀 Tu primera llamada a un LLM (`01_primer_prompt.py`)

La llamada mas basica posible: un mensaje de usuario y una respuesta del modelo usando el SDK de OpenAI compatible con distintos proveedores.

```bash
python 01_primer_prompt.py
```

### 02 — 🧭 Prompt Engineering (`02_prompt_engineering.py`)

Como usar el `system prompt` para dar contexto al modelo y guiar sus respuestas. Muestra la diferencia entre preguntar sin contexto y preguntar con instrucciones mas claras.

```bash
python 02_prompt_engineering.py
```

### 03 — 🤖 Mi primer agente (`03_mi_primer_agente.py`)

Un agente con una tool local en Python. El modelo decide si necesita usar esa herramienta para responder y luego compone la respuesta final.

```bash
python 03_mi_primer_agente.py
```

### 04 — 📦 Bonus: RAG básico (`04_bonus_rag.py` y `05_bonus_rag_chat.py`)

RAG local con recetas de la abuela de Zoe dividido en dos scripts para que el proceso se vea con claridad:
- `04_bonus_rag.py` genera los embeddings y rellena la base de datos vectorial en Qdrant.
- `05_bonus_rag_chat.py` abre el modo chat y responde preguntas recuperando primero las recetas mas relevantes.

Para GitHub Models, el ejemplo queda preparado con `openai/text-embedding-3-large`.

```bash
docker run --rm -p 6333:6333 -v qdrant_storage:/qdrant/storage qdrant/qdrant
python 04_bonus_rag.py
python 05_bonus_rag_chat.py
```

---

## 📝 Resumen de conceptos

| Concepto | En una frase |
|----------|--------------|
| **LLM** | Modelo que predice texto token a token, entrenado con datos masivos |
| **Token** | Unidad mínima de texto (~¾ de palabra en inglés) |
| **Temperatura** | Controla la aleatoriedad de las respuestas (0 = determinista) |
| **Prompt Engineering** | El arte de escribir instrucciones efectivas para el modelo |
| **Embedding** | Vector numérico que representa el significado semántico de un texto |
| **RAG** | Inyectar contexto relevante en el prompt para respuestas precisas |
| **Agente** | LLM que puede tomar decisiones y usar herramientas de forma autónoma |
| **Context Window** | Límite de tokens que el modelo puede procesar en una llamada |

---

## 🔗 Recursos

**🛠️ Frameworks para construir con LLMs:**
- [LangChain](https://python.langchain.com) — El más popular, muchos conectores
- [LlamaIndex](https://docs.llamaindex.ai) — Especializado en RAG
- [Instructor](https://python.useinstructor.com) — Para extraer JSON estructurado de LLMs
- [Pydantic AI](https://ai.pydantic.dev) — Agentes con tipado fuerte

**🔎 Plataformas para explorar modelos:**
- [Hugging Face](https://huggingface.co) — El GitHub de los modelos de IA
- [OpenRouter](https://openrouter.ai) — Una API, todos los modelos
- [Groq](https://groq.com) — Inferencia ultrarrápida, free tier generoso


