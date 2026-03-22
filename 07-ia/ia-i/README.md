# 🤖 Introducción a la IA Generativa

> **Objetivo:** Al terminar esta clase, sabrás qué es la IA Generativa, cómo funciona por dentro, y serás capaz de llamar a un LLM desde código, hacer RAG básico y construir un agente sencillo. Sin humo, con las manos en la masa.

---

### 1.1 ¿Qué es la IA Generativa?

La IA Generativa es una rama de la inteligencia artificial capaz de **crear contenido nuevo**: texto, imágenes, código, audio, vídeo...

A diferencia de la IA tradicional (que clasifica o predice), la IA Generativa **genera**.

**Ejemplos que ya usas (o deberías):**
- **ChatGPT / Claude / Gemini** → generan texto
- **GitHub Copilot** → genera código
- **DALL·E / Stable Diffusion / Midjourney** → generan imágenes
- **Suno / ElevenLabs** → generan audio

> 💡 **Para DevOps:** piensa en IA Generativa como un componente más de tu stack. Una API que acepta texto y devuelve texto (o código, o JSON...).

---

### 1.2 ¿Cómo funciona un LLM?

**LLM = Large Language Model** (Modelo de Lenguaje Grande)

#### El mecanismo básico: predecir el siguiente token

Un LLM no "entiende" el lenguaje como tú. Lo que hace es **predecir, token a token, cuál es la siguiente palabra más probable** dado el contexto anterior.

```
Input:  "El cielo es de color"
Output: "azul" (con alta probabilidad)
```

**¿Qué es un token?**
- Aproximadamente 3/4 de una palabra en inglés, algo menos en español
- "DevOps" → 1-2 tokens
- 1000 palabras ≈ 1300-1500 tokens
- Los modelos tienen un **límite de contexto** (context window): cuántos tokens pueden procesar a la vez

#### El proceso de entrenamiento (simplificado)

```
1. Pre-training    → El modelo lee internet entero (Wikipedia, GitHub, libros...)
                     Aprende patrones del lenguaje
                     
2. Fine-tuning     → Se especializa en seguir instrucciones
                     (RLHF: Reinforcement Learning from Human Feedback)
                     
3. Inferencia      → Tú mandas un prompt, el modelo genera la respuesta
```

#### Parámetros clave que verás en las APIs

| Parámetro | Qué hace | Valores típicos |
|-----------|----------|-----------------|
| `temperature` | Aleatoriedad de la respuesta. 0 = determinista, 2 = caótico | 0.0 – 1.0 |
| `max_tokens` | Longitud máxima de la respuesta | 256 – 4096+ |
| `top_p` | Nucleus sampling. Alternativa a temperature | 0.9 – 1.0 |
| `system` | Instrucciones de comportamiento del modelo | "Eres un experto en..." |

> 💡 **Para DevOps:** `temperature=0` cuando quieras respuestas consistentes y reproducibles (CI/CD, scripts). `temperature>0.5` para creatividad.

---

### 1.3 Arquitectura de una solución con LLMs (10 min)

En producción, nunca es "solo el modelo". El patrón más habitual:

```
┌─────────────────────────────────────────────────────┐
│                   Tu Aplicación                      │
│                                                      │
│  ┌──────────┐    ┌──────────┐    ┌──────────────┐   │
│  │  Usuario │───▶│  Prompt  │───▶│  LLM (API)   │   │
│  │          │    │ Engineer │    │              │   │
│  └──────────┘    └──────────┘    └──────┬───────┘   │
│                                         │           │
│                                    Respuesta        │
│                                         │           │
│  ┌──────────────────────────────────────▼───────┐   │
│  │            Post-processing / Acción          │   │
│  │   (parsear JSON, ejecutar código, guardar)   │   │
│  └──────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

**Componentes habituales:**
- **Prompt** → la instrucción que mandas al modelo
- **Context / Memory** → historial de conversación
- **Tools / Functions** → acciones que el modelo puede "pedir" que se ejecuten
- **Vector Store** → base de datos de embeddings para RAG
- **Guardrails** → filtros de seguridad y validación

---

### 1.4 Conceptos esenciales (10 min)

#### Prompt Engineering

El arte de escribir buenas instrucciones para el modelo.

**Anatomía de un buen prompt:**

```
[ROL]        Eres un experto en infraestructura cloud con 10 años de experiencia.

[CONTEXTO]   El equipo usa Kubernetes en GKE con Helm charts versionados en Git.

[TAREA]      Analiza el siguiente error de deploy y propón una solución paso a paso.

[RESTRICCIONES] Responde en español. No uses kubectl deprecated. Máximo 5 pasos.

[INPUT]      <error>
             Error: UPGRADE FAILED: another operation is in progress
             </error>
```

**Técnicas básicas:**
- **Zero-shot** → le preguntas directamente sin ejemplos
- **Few-shot** → le das 2-3 ejemplos antes de la pregunta real
- **Chain of Thought** → le pides que "piense paso a paso" (mejora razonamiento)
- **Role prompting** → le asignas un rol experto

#### Embeddings

Representaciones numéricas (vectores) del significado semántico de un texto.

```
"Kubernetes falla al hacer deploy"  →  [0.23, -0.87, 0.45, ...]  (1536 dimensiones)
"Error en el despliegue de K8s"    →  [0.24, -0.85, 0.44, ...]  (muy similar!)
"Me gusta la pizza"                →  [0.91, 0.12, -0.67, ...]  (muy diferente)
```

**¿Para qué sirven?** → Para búsqueda semántica. La base de RAG.

#### RAG (Retrieval-Augmented Generation)

El modelo no sabe nada de tu infraestructura, tus runbooks, tu documentación interna. **RAG es la solución.**

```
Sin RAG:  "¿Cómo hago rollback en producción?" → respuesta genérica

Con RAG:  1. Busca en tus runbooks internos los fragmentos más relevantes
          2. Los inyecta en el prompt como contexto
          3. "¿Cómo hago rollback en producción?" → respuesta basada en TU documentación
```

#### Agentes (Agents)

Un LLM que puede **tomar decisiones y usar herramientas** de forma autónoma.

```
Usuario: "Analiza el estado de mi cluster y dime si hay algún problema"

Agente:
  1. Decide: necesito ver los pods → llama a kubectl get pods
  2. Ve pods en CrashLoopBackOff → decide: necesito los logs → llama a kubectl logs
  3. Analiza los logs → genera un informe con el diagnóstico y la solución
```

> 💡 **Para DevOps:** los agentes son el futuro de la automatización. Un agente puede monitorizar, diagnosticar y remediar sin intervención humana.

---

### 1.5 El ecosistema: modelos y proveedores (5 min)

#### 🆓 Opciones GRATUITAS que usaremos en clase

| Herramienta | Qué es | Instalación |
|-------------|--------|-------------|
| **[Ollama](https://ollama.com)** | Modelos locales, API compatible OpenAI | `brew install ollama` / [descarga](https://ollama.com/download) |
| **[LM Studio](https://lmstudio.ai)** | GUI para modelos locales | [Descarga directa](https://lmstudio.ai) |
| **[GitHub Models](https://github.com/marketplace/models)** | API gratis en la nube (con límites) | Solo necesitas cuenta de GitHub |
| **[Docker Model Runner](https://docs.docker.com/desktop/features/model-runner/)** | Modelos en contenedores Docker | Docker Desktop con la feature habilitada |

> 💡 **Ventaja:** Todas estas opciones son **100% gratuitas** y tienen API compatible con OpenAI. El código que escribas funcionará con cualquiera de ellas.

#### Modelos recomendados (según tu hardware)

| RAM disponible | Modelo recomendado | Comando |
|----------------|-------------------|----------|
| 8 GB | `llama3.2:3b`, `qwen2.5:3b` | `ollama pull llama3.2:3b` |
| 16 GB | `llama3.2`, `qwen2.5:7b`, `mistral` | `ollama pull llama3.2` |
| 32 GB+ | `llama3.3`, `qwen2.5:32b` | `ollama pull llama3.3` |

> 🔍 **¿No sabes qué modelo puede correr tu máquina?** Usa [canirun.ai](https://www.canirun.ai/) — una web creada por midudev que analiza tu hardware y te recomienda modelos compatibles.

#### Proveedores de pago (referencia)

| Proveedor | Modelos destacados | Puntos fuertes |
|-----------|-------------------|----------------|
| **OpenAI** | GPT-4o, o3, o4-mini | El más popular, gran ecosistema |
| **Anthropic** | Claude 3.5 Sonnet, Claude 4 | Excelente para código y razonamiento |
| **Google** | Gemini 2.0 Flash, Pro | Context window enorme (1M tokens) |
| **Mistral** | Mistral Large, Codestral | Muy bueno para código |

---

## ☕ BREAK — 10 minutos

---

## 🛠️ BLOQUE 2 — Práctica (60 min)

### Requisitos previos

#### Opción A: Ollama (recomendada si tu máquina lo soporta)

```bash
# 1. Instalar Ollama
# macOS:
brew install ollama
# O descarga desde https://ollama.com/download
```

A día de hoy es muy fácil de usar porque nada más tenerlo instalado puedes ejecutar simplemente:

```bash
ollama
```
Y te aparecerá un asistente que te permitirá descargar modelos. Aparecen algunos recomendados como parte del asistente. Por otro lado ahora tiene una aplicación de escritorio que también te facilita el uso y probar los modelos.




#### Opción B: GitHub Models (si tu hardware no da)

```bash
# 1. Ve a https://github.com/settings/tokens
# 2. Genera un token (clásico) con permisos mínimos
# 3. Guárdalo en .env como GITHUB_TOKEN
```

#### Opción C: Docker Model Runner

```bash
# 1. Abre Docker Desktop
# 2. Ve a Settings > Features in development
# 3. Activa "Docker Model Runner"
# 4. Descarga un modelo desde la UI o CLI:
docker model pull llama3.2
```

#### Instalar dependencias Python

```bash
# Python 3.10+
python --version

# Instalar dependencias
pip install -r requirements.txt
# O manualmente:
pip install openai chromadb sentence-transformers python-dotenv
```

#### Configurar variables de entorno

Crea un archivo `.env` copiando `.env.example`:
```bash
cp .env.example .env
```

Edita `.env` según la opción que uses:
```bash
# Para Ollama (no necesita nada, pero puedes configurar la URL)
OLLAMA_BASE_URL=http://localhost:11434/v1

# Para GitHub Models
GITHUB_TOKEN=ghp_xxxxxxxxxxxx

# Para Docker Model Runner
DOCKER_MODEL_HOST=http://localhost:12434/engines/llama.cpp/v1
```

---

### Ejercicio 1 — Tu primera llamada a un LLM (15 min)

Empezamos por lo más básico: llamar a la API y entender la estructura de la respuesta.

**🏠 Con Ollama (recomendado):**

```python
# ejercicio1_ollama.py
from openai import OpenAI

# Ollama expone una API compatible con OpenAI
client = OpenAI(
    base_url="http://localhost:11434/v1",
    api_key="ollama"  # Ollama no necesita API key, pero el cliente la requiere
)

response = client.chat.completions.create(
    model="llama3.2",  # El modelo que descargaste con 'ollama pull'
    messages=[
        {
            "role": "system",
            "content": "Eres un chef experto. Respondes de forma clara y práctica."
        },
        {
            "role": "user",
            "content": "Dame una receta rápida de tortilla de patatas para 2 personas."
        }
    ],
    temperature=0.7,
    max_tokens=500
)

print(response.choices[0].message.content)
```

**☁️ Con GitHub Models (alternativa en la nube, gratis):**

```python
# ejercicio1_github_models.py
import os
from openai import OpenAI
from dotenv import load_dotenv

load_dotenv()

# GitHub Models usa la API de OpenAI con otro endpoint
client = OpenAI(
    base_url="https://models.inference.ai.azure.com",
    api_key=os.getenv("GITHUB_TOKEN")  # Tu Personal Access Token de GitHub
)

response = client.chat.completions.create(
    model="gpt-4o-mini",  # GitHub ofrece acceso gratuito a varios modelos
    messages=[
        {
            "role": "system",
            "content": "Eres un chef experto. Respondes de forma clara y práctica."
        },
        {
            "role": "user",
            "content": "Dame una receta rápida de tortilla de patatas para 2 personas."
        }
    ],
    temperature=0.7,
    max_tokens=500
)

print(response.choices[0].message.content)
```

**🐳 Con Docker Model Runner:**

```python
# ejercicio1_docker.py
from openai import OpenAI

# Docker Model Runner expone una API compatible
client = OpenAI(
    base_url="http://localhost:12434/engines/llama.cpp/v1",
    api_key="docker"  # No necesita API key real
)

response = client.chat.completions.create(
    model="ai/llama3.2",  # Prefijo ai/ para modelos en Docker
    messages=[
        {
            "role": "system",
            "content": "Eres un chef experto. Respondes de forma clara y práctica."
        },
        {
            "role": "user", 
            "content": "Dame una receta rápida de tortilla de patatas para 2 personas."
        }
    ],
    temperature=0.7,
    max_tokens=500
)

print(response.choices[0].message.content)
```

**🧪 Experimenta:**
- Cambia `temperature` entre 0 y 1.5 y observa las diferencias
- Prueba a cambiar el rol en el `system` prompt
- Cambia entre Ollama, GitHub Models y Docker Model Runner — ¡el código es casi idéntico!

---

### Ejercicio 2 — Prompt Engineering: el arte de hablar con los LLMs (10 min)

Vamos a ver cómo un buen prompt marca la diferencia usando un ejemplo cotidiano: analizar reseñas de productos.

```python
# ejercicio2_prompt_engineering.py
from openai import OpenAI

# Usamos Ollama local (cámbialo a GitHub Models si prefieres)
client = OpenAI(
    base_url="http://localhost:11434/v1",
    api_key="ollama"
)
MODEL = "llama3.2"  # o "gpt-4o-mini" con GitHub Models

# Texto de ejemplo: una reseña de producto
reseña = """
Compré esta cafetera hace 3 meses. Al principio funcionaba genial, el café 
salía muy bueno y caliente. Pero desde hace 2 semanas hace un ruido raro 
y a veces gotea agua por abajo. El servicio técnico tarda mucho en contestar.
Lo bueno es que es muy fácil de limpiar y ocupa poco espacio en la cocina.
No la recomendaría por el precio que tiene (89€).
"""

# ❌ Prompt malo (vago, sin estructura)
def prompt_malo(texto):
    response = client.chat.completions.create(
        model=MODEL,
        messages=[{"role": "user", "content": f"Analiza esto: {texto}"}]
    )
    return response.choices[0].message.content

# ✅ Prompt bueno (rol + contexto + formato de salida específico)
def prompt_bueno(texto):
    response = client.chat.completions.create(
        model=MODEL,
        temperature=0,  # Queremos respuestas consistentes
        messages=[
            {
                "role": "system",
                "content": """Eres un analista de reseñas de productos. Tu trabajo es extraer 
información estructurada de las opiniones de clientes.

Responde SIEMPRE en este formato JSON exacto:
{
    "sentimiento": "positivo" | "negativo" | "mixto",
    "puntuacion": 1-5,
    "aspectos_positivos": ["lista de puntos buenos"],
    "aspectos_negativos": ["lista de puntos malos"],
    "problema_principal": "descripción breve o null",
    "recomendaria": true | false
}"""
            },
            {
                "role": "user",
                "content": f"Analiza esta reseña de producto:\n\n{texto}"
            }
        ]
    )
    return response.choices[0].message.content

print("=== PROMPT MALO ===")
print(prompt_malo(reseña))

print("\n=== PROMPT BUENO ===")
print(prompt_bueno(reseña))
```

---

### Ejercicio 3 — RAG con PDF real: el temario del Bootcamp (20 min)

RAG completo: descarga un PDF → convierte a markdown → divide en chunks → embeddings → búsqueda semántica → genera respuestas.

En este ejercicio usamos el **temario real del Bootcamp DevOps de Lemoncode** como fuente de conocimiento.

```python
# ejercicio3_rag_basico.py
import tempfile
import httpx
from markitdown import MarkItDown
from openai import OpenAI
import chromadb
from chromadb.utils import embedding_functions

# ── Configuración ──────────────────────────────────────────────────────────

# URL del PDF del temario del Bootcamp DevOps
PDF_URL = "https://static1.squarespace.com/static/56cdb491a3360cdd18de5e16/t/6836ace3c7d40d787c8c84de/1748413667559/Temario+Bootcamp+DevOps+VI.pdf"

# LLM: Ollama local
llm_client = OpenAI(
    base_url="http://localhost:11434/v1",
    api_key="ollama"
)
MODEL = "llama3.2"

# Embeddings: sentence-transformers (LOCAL y GRATIS)
embedding_fn = embedding_functions.SentenceTransformerEmbeddingFunction(
    model_name="all-MiniLM-L6-v2"
)

# ── PASO 1: Descargar el PDF y convertirlo a Markdown ──────────────────────

def descargar_y_convertir_pdf(url: str) -> str:
    """Descarga un PDF desde una URL y lo convierte a markdown."""
    print(f"📥 Descargando PDF desde: {url[:50]}...")
    
    response = httpx.get(url, follow_redirects=True, timeout=60)
    response.raise_for_status()
    
    with tempfile.NamedTemporaryFile(suffix=".pdf", delete=False) as tmp:
        tmp.write(response.content)
        tmp_path = tmp.name
    
    print(f"📄 PDF descargado ({len(response.content) / 1024:.1f} KB)")
    
    # Convertir a markdown con markitdown
    print("🔄 Convirtiendo PDF a Markdown...")
    md = MarkItDown()
    result = md.convert(tmp_path)
    
    print(f"✅ Conversión completada ({len(result.text_content)} caracteres)")
    return result.text_content

# ── PASO 2: Dividir el documento en chunks ─────────────────────────────────

def dividir_en_chunks(texto: str, chunk_size: int = 500, overlap: int = 50) -> list[dict]:
    """Divide un texto largo en chunks más pequeños para indexar."""
    chunks = []
    palabras = texto.split()
    inicio = 0
    chunk_id = 0
    
    while inicio < len(palabras):
        fin = min(inicio + chunk_size, len(palabras))
        chunk_texto = " ".join(palabras[inicio:fin])
        
        chunks.append({
            "id": f"chunk-{chunk_id}",
            "titulo": f"Sección {chunk_id}",
            "contenido": chunk_texto
        })
        
        chunk_id += 1
        inicio = fin - overlap
    
    return chunks

# ── PASO 3: Crear la base de datos vectorial e indexar ─────────────────────

markdown_content = descargar_y_convertir_pdf(PDF_URL)
chunks = dividir_en_chunks(markdown_content)

chroma_client = chromadb.Client()
collection = chroma_client.create_collection(
    name="bootcamp_devops",
    embedding_function=embedding_fn
)

for chunk in chunks:
    collection.add(
        ids=[chunk["id"]],
        documents=[chunk["contenido"]],
        metadatas=[{"titulo": chunk["titulo"]}]
    )

print(f"✅ {len(chunks)} chunks indexados")

# ── PASO 4: RAG — Búsqueda + Generación ───────────────────────────────────

def preguntar_con_rag(pregunta: str) -> str:
    resultados = collection.query(query_texts=[pregunta], n_results=3)
    contexto = "\n\n".join(resultados["documents"][0])
    
    response = llm_client.chat.completions.create(
        model=MODEL,
        temperature=0,
        messages=[
            {"role": "system", "content": "Responde basándote SOLO en el contexto proporcionado."},
            {"role": "user", "content": f"Contexto:\n{contexto}\n\nPregunta: {pregunta}"}
        ]
    )
    return response.choices[0].message.content

# ── Demo ───────────────────────────────────────────────────────────────────

preguntas = [
    "¿Qué tecnologías de contenedores se enseñan en el bootcamp?",
    "¿El bootcamp incluye formación en Kubernetes?",
    "¿Qué herramientas de CI/CD se cubren?",
]

for pregunta in preguntas:
    print(f"\n❓ {pregunta}")
    print(preguntar_con_rag(pregunta))
```

---

### Ejercicio 4 — Agente básico con tools (15 min)

Un agente que puede "ejecutar" comandos de kubectl para diagnosticar el cluster.

> ⚠️ **Nota:** Function calling funciona mejor con modelos más grandes. Si usas Ollama, prueba con `llama3.3` o `qwen2.5:7b`. Si tienes hardware limitado, usa GitHub Models.

```python
# ejercicio4_agente.py
import json
import os
from openai import OpenAI

# ── Configuración ──────────────────────────────────────────────────────────

# Opción 1: Ollama local (necesita modelo >= 7B para function calling)
client = OpenAI(
    base_url="http://localhost:11434/v1",
    api_key="ollama"
)
MODEL = "llama3.2"  # Mejor: llama3.3 o qwen2.5:7b si tu hardware lo soporta

# Opción 2: GitHub Models (descomenta si prefieres la nube)
# from dotenv import load_dotenv
# load_dotenv()
# client = OpenAI(
#     base_url="https://models.inference.ai.azure.com",
#     api_key=os.getenv("GITHUB_TOKEN")
# )
# MODEL = "gpt-4o-mini"

# ── Simulamos las "herramientas" del agente ────────────────────────────────
# En producción estas funciones llamarían a APIs reales

# Base de datos simulada
lista_compra = []

def consultar_tiempo(ciudad: str) -> str:
    """Simula consultar el tiempo en una ciudad"""
    tiempos = {
        "madrid": {"temp": 18, "estado": "Soleado", "humedad": 45},
        "barcelona": {"temp": 16, "estado": "Parcialmente nublado", "humedad": 60},
        "sevilla": {"temp": 22, "estado": "Soleado", "humedad": 35},
    }
    ciudad_lower = ciudad.lower()
    if ciudad_lower in tiempos:
        t = tiempos[ciudad_lower]
        return f"En {ciudad}: {t['estado']}, {t['temp']}°C, humedad {t['humedad']}%"
    return f"No tengo datos del tiempo para {ciudad}"

def buscar_receta(ingrediente: str) -> str:
    """Busca recetas que contengan un ingrediente"""
    recetas = {
        "pollo": ["Pollo al ajillo (30 min)", "Pollo asado con limón (1h)", "Fajitas de pollo (25 min)"],
        "pasta": ["Carbonara (20 min)", "Pasta con tomate y albahaca (15 min)", "Macarrones con queso (25 min)"],
        "huevo": ["Tortilla española (25 min)", "Huevos revueltos (5 min)", "Huevos benedictinos (20 min)"],
    }
    ingrediente_lower = ingrediente.lower()
    if ingrediente_lower in recetas:
        return f"Recetas con {ingrediente}: " + ", ".join(recetas[ingrediente_lower])
    return f"No encontré recetas con {ingrediente}"

def gestionar_lista_compra(accion: str, item: str = None) -> str:
    """Gestiona la lista de la compra: añadir, quitar, ver"""
    global lista_compra
    
    if accion == "ver":
        if not lista_compra:
            return "La lista de la compra está vacía"
        return "Lista de la compra: " + ", ".join(lista_compra)
    elif accion == "añadir" and item:
        lista_compra.append(item)
        return f"Añadido '{item}' a la lista. Total: {len(lista_compra)} items"
    elif accion == "quitar" and item:
        if item in lista_compra:
            lista_compra.remove(item)
            return f"Quitado '{item}' de la lista"
        return f"'{item}' no está en la lista"
    return "Acción no reconocida"

# Mapa de funciones disponibles
TOOLS_MAP = {
    "consultar_tiempo": consultar_tiempo,
    "buscar_receta": buscar_receta,
    "gestionar_lista_compra": gestionar_lista_compra,
}

# Definición de tools para la API de OpenAI
TOOLS = [
    {
        "type": "function",
        "function": {
            "name": "consultar_tiempo",
            "description": "Consulta el tiempo atmosférico en una ciudad española",
            "parameters": {
                "type": "object",
                "properties": {
                    "ciudad": {"type": "string", "description": "Nombre de la ciudad"}
                },
                "required": ["ciudad"]
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "buscar_receta",
            "description": "Busca recetas que contengan un ingrediente específico",
            "parameters": {
                "type": "object",
                "properties": {
                    "ingrediente": {"type": "string", "description": "El ingrediente principal"}
                },
                "required": ["ingrediente"]
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "gestionar_lista_compra",
            "description": "Gestiona la lista de la compra del usuario",
            "parameters": {
                "type": "object",
                "properties": {
                    "accion": {"type": "string", "enum": ["ver", "añadir", "quitar"]},
                    "item": {"type": "string", "description": "El producto a añadir o quitar"}
                },
                "required": ["accion"]
            }
        }
    }
]

# ── El bucle del agente ────────────────────────────────────────────────────

def ejecutar_agente(tarea: str) -> str:
    print(f"\n🤖 Agente iniciado con tarea: '{tarea}'\n")
    
    messages = [
        {
            "role": "system",
            "content": """Eres un asistente personal útil y amigable. Puedes:
            1. Consultar el tiempo en ciudades españolas
            2. Buscar recetas por ingrediente
            3. Gestionar una lista de la compra
            
            Usa las herramientas disponibles para ayudar al usuario."""
        },
        {"role": "user", "content": tarea}
    ]
    
    # Bucle agéntico: el modelo decide cuándo ha terminado
    iteracion = 0
    max_iteraciones = 5
    
    while iteracion < max_iteraciones:
        iteracion += 1
        print(f"🔄 Iteración {iteracion}...")
        
        response = client.chat.completions.create(
            model=MODEL,
            messages=messages,
            tools=TOOLS,
            tool_choice="auto"
        )
        
        assistant_message = response.choices[0].message
        messages.append(assistant_message)
        
        # ¿El modelo quiere usar alguna herramienta?
        if assistant_message.tool_calls:
            for tool_call in assistant_message.tool_calls:
                nombre = tool_call.function.name
                args = json.loads(tool_call.function.arguments)
                
                print(f"  🛠️  Usando herramienta: {nombre}({args})")
                
                # Ejecutamos la función real
                resultado = TOOLS_MAP[nombre](**args)
                print(f"  📋 Resultado: {resultado}")
                
                # Devolvemos el resultado al modelo
                messages.append({
                    "role": "tool",
                    "tool_call_id": tool_call.id,
                    "content": resultado
                })
        else:
            # El modelo ha terminado (no pidió más herramientas)
            print(f"\n✅ Agente completado en {iteracion} iteraciones\n")
            return assistant_message.content

    return "Máximo de iteraciones alcanzado"

# ── Demo ───────────────────────────────────────────────────────────────────

# Ejemplo: tarea que usa múltiples herramientas
respuesta = ejecutar_agente(
    "Quiero hacer algo con pollo para cenar. Mira qué recetas hay y añade "
    "pollo, ajo y limón a la lista de la compra."
)

print("=" * 60)
print("📋 RESPUESTA DEL AGENTE:")
print("=" * 60)
print(respuesta)
```

---

## 🗺️ ¿Y ahora qué? — Próximos pasos

### Herramientas y recursos para seguir aprendiendo

**Frameworks para construir con LLMs:**
- **[LangChain](https://python.langchain.com)** — El más popular, muchos conectores
- **[LlamaIndex](https://docs.llamaindex.ai)** — Especializado en RAG
- **[Instructor](https://python.useinstructor.com)** — Para extraer JSON estructurado de LLMs
- **[Pydantic AI](https://ai.pydantic.dev)** — Agentes con tipado fuerte, muy pythónico

**Plataformas para explorar modelos:**
- **[Hugging Face](https://huggingface.co)** — El GitHub de los modelos de IA
- **[OpenRouter](https://openrouter.ai)** — Una API, todos los modelos
- **[Groq](https://groq.com)** — Inferencia ultrarrápida, free tier generoso
- **[Google AI Studio](https://aistudio.google.com)** — Gemini gratis con límites altos

**Para DevOps específicamente:**
- Integra LLMs en tus pipelines de CI/CD para análisis de logs y PRs
- Usa RAG sobre tu documentación interna con [Ollama](https://ollama.com) + [Open WebUI](https://openwebui.com)
- Explora [Dagger AI](https://dagger.io) para pipelines con IA integrada

---

## 📝 Resumen de conceptos clave

| Concepto | En una frase |
|----------|--------------|
| **LLM** | Modelo que predice texto token a token, entrenado con datos masivos |
| **Token** | Unidad mínima de texto (~¾ de palabra en inglés) |
| **Temperatura** | Controla la aleatoriedad de las respuestas (0=determinista) |
| **Prompt Engineering** | El arte de escribir instrucciones efectivas para el modelo |
| **Embedding** | Vector numérico que representa el significado semántico de un texto |
| **RAG** | Inyectar contexto relevante en el prompt para respuestas precisas |
| **Agente** | LLM que puede tomar decisiones y usar herramientas de forma autónoma |
| **Context Window** | Límite de tokens que el modelo puede procesar en una llamada |
| **Ollama** | Herramienta para correr modelos LLM en tu máquina local |

---

## 🔜 En la próxima clase...

**Model Context Protocol (MCP)** — el protocolo abierto que permite a los LLMs conectarse con fuentes de datos y herramientas externas de forma estándar.

Veremos cómo MCP está cambiando la forma en que construimos aplicaciones con IA:
- Qué problema resuelve y por qué es importante
- Cómo funciona la arquitectura cliente-servidor
- Servidores MCP para DevOps: GitHub, Docker, Kubernetes...
- Cómo construir tu propio servidor MCP

---

*¡Nos vemos 👋🏻!*


