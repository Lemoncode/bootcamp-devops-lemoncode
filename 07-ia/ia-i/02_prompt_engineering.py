import os

from dotenv import load_dotenv
from openai import OpenAI
from rich.console import Console
from rich.markdown import Markdown

load_dotenv()

console = Console()

# Debes tener un archhivo .env con las variables de entornos elegidas. Estas pueden ser  para Ollama, Docker, GitHub Models, Foundry.
LLM_PROVIDER = os.getenv("LLM_PROVIDER", "ollama")
LLM_MODEL = os.getenv("LLM_MODEL")
LLM_ENDPOINT = os.getenv("LLM_ENDPOINT")
LLM_API_KEY = os.getenv("LLM_API_KEY")

# Se crea un cliente de OpenAI con el endpoint y la API Key para el mismo
client = OpenAI(base_url=LLM_ENDPOINT, api_key=LLM_API_KEY)
# Guardamos el modelo en una variable para usarlo luego en la llamada al LLM
model = LLM_MODEL

console.print(f"🔌 Proveedor: {LLM_PROVIDER}")
console.print(f"🔍 Endpoint: {LLM_ENDPOINT}")
console.print(f"🧠 Modelo: {model}")


# System prompt para dar contexto al modelo sobre cómo debe comportarse y qué información tiene disponible. Es importante para guiar la respuesta del modelo.
system_prompt = """Eres un entrenador personal que ayuda a las personas a mantenerse activas con ejercicios sencillos que puedan hacer en casa, sin necesidad de material y que no les lleven más
de 10 minutos. Tienes en cuenta que el tipo de usuario puede variar en edad, nivel de condición física y posibles limitaciones físicas. 
Lo más probable es que el usuario no tenga experiencia previa con el ejercicio físico, por lo que tus recomendaciones deben ser accesibles y fáciles de seguir. 
Además, siempre debes incluir una breve explicación de cada ejercicio y sus beneficios para motivar al usuario a mantenerse activo."""

console.print(f"\n📋 System Prompt:\n{system_prompt}\n")

# la llamada al modelo con el system prompt y un mensaje de usuario
response = client.chat.completions.create(
    model=model,
    messages=[
        {
            "role": "system",
            "content": system_prompt,
        },
        {
            "role": "user",
            "content": """Soy programadora, trabajo 10 horas sentada y mi único ejercicio 
es ir a la nevera. Dame 5 ejercicios que pueda hacer en casa para mantenerme activa, sin necesidad de material y que no me lleven más de 10 minutos.""",
        },
    ],
)

# La respuesta
console.print(Markdown(response.choices[0].message.content))

# Métricas de uso (si el proveedor las devuelve)
if response.usage:
    console.print("\n📊 Tokens usados:")
    console.print(f"  - Input:  {response.usage.prompt_tokens}")
    console.print(f"  - Output: {response.usage.completion_tokens}")
    console.print(f"  - Total:  {response.usage.total_tokens}")
