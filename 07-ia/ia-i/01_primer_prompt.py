import os
from openai import OpenAI
from dotenv import load_dotenv
from rich.console import Console
from rich.markdown import Markdown

load_dotenv()

console = Console()

# Debes tener un archhivo .env con las variables de entornos elegidas. Estas pueden ser  para Ollama, Docker, GitHub Models, Foundry.
LLM_PROVIDER = os.getenv("LLM_PROVIDER")
LLM_MODEL = os.getenv("LLM_MODEL")
LLM_ENDPOINT = os.getenv("LLM_ENDPOINT")
LLM_API_KEY = os.getenv("LLM_API_KEY")

# Se crea un cliente de OpenAI con el endpoint y la API Key para el mismo
client = OpenAI(base_url=LLM_ENDPOINT, api_key=LLM_API_KEY)
# Guardamos el modelo en una variable para usarlo luego en la llamada al LLM
model = LLM_MODEL

print(f"🔌 Proveedor: {LLM_PROVIDER}")
print(f"🔍 Endpoint: {LLM_ENDPOINT}")
print(f"🧠 Modelo: {model}")

SIMPLE_PROMPT = "¿Cuál es la capital de España?"

DETAILED_PROMPT = """Soy programadora, trabajo 10 horas sentada y mi único ejercicio 
es ir a la nevera. Dame 5 ejercicios que pueda hacer en casa para mantenerme activa, sin necesidad de material y que no me lleven más de 10 minutos."""

user_prompt = SIMPLE_PROMPT

# la llamada más básica posible: un mensaje de usuario y una respuesta del modelo
with console.status("[bold green]Esperando respuesta del modelo...", spinner="dots"):
    response = client.chat.completions.create(
        model=model,
        messages=[
            {
                "role": "user",
                "content": user_prompt,
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
