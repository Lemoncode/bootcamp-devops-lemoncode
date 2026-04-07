import os

from dotenv import load_dotenv
from openai import OpenAI
from rich.console import Console
from rich.markdown import Markdown

load_dotenv()

console = Console()

# ⚙️ Cargamos la configuracion del proveedor desde el archivo .env.
LLM_PROVIDER = os.getenv("LLM_PROVIDER", "ollama")
LLM_MODEL = os.getenv("LLM_MODEL")
LLM_ENDPOINT = os.getenv("LLM_ENDPOINT")
LLM_API_KEY = os.getenv("LLM_API_KEY")

# 🔌 Creamos un cliente OpenAI-compatible con el endpoint y la API key elegidos.
client = OpenAI(base_url=LLM_ENDPOINT, api_key=LLM_API_KEY)
# 🧠 Guardamos el nombre del modelo para reutilizarlo en la llamada.
model = LLM_MODEL

console.print(f"🔌 Proveedor: {LLM_PROVIDER}")
console.print(f"🔍 Endpoint: {LLM_ENDPOINT}")
console.print(f"🧠 Modelo: {model}")

# 🎛️ Estos parametros ayudan a controlar la respuesta del modelo.
temperature = 0.3
max_tokens = 300

# 🧭 El system prompt define el rol del modelo y marca el tono de la respuesta.
system_prompt = """Eres un entrenador personal que ayuda a las personas a mantenerse activas con ejercicios sencillos que puedan hacer en casa, sin necesidad de material y que no les lleven más
de 10 minutos. Tienes en cuenta que el tipo de usuario puede variar en edad, nivel de condición física y posibles limitaciones físicas. 
Lo más probable es que el usuario no tenga experiencia previa con el ejercicio físico, por lo que tus recomendaciones deben ser accesibles y fáciles de seguir. 
Además, siempre debes incluir una breve explicación de cada ejercicio y sus beneficios para motivar al usuario a mantenerse activo."""

console.print(f"\n📋 System Prompt:\n{system_prompt}\n")

# 🚀 Llamamos al modelo enviando un system prompt y un mensaje de usuario.
response = client.chat.completions.create(
    model=model,
    temperature=temperature,
    max_completion_tokens=max_tokens,
    messages=[
        {
            "role": "system",
            "content": system_prompt,
        },
        {
            "role": "user",
            "content": """Soy programadora, trabajo 10 horas sentada y mi único ejercicio 
es ir a la nevera. Dame 5 ejercicios que pueda hacer en casa para mantenerme activa, sin necesidad de material.""",
        },
    ],
)

console.print(f"🌡️ Temperature: {temperature}")
console.print(f"✂️ Max tokens: {max_tokens}")

# 📄 Mostramos la respuesta del modelo con formato Markdown.
console.print(Markdown(response.choices[0].message.content))

# 📊 Si el proveedor devuelve uso de tokens, lo enseñamos en consola.
if response.usage:
    console.print("\n📊 Tokens usados:")
    console.print(f"  - Input:  {response.usage.prompt_tokens}")
    console.print(f"  - Output: {response.usage.completion_tokens}")
    console.print(f"  - Total:  {response.usage.total_tokens}")
