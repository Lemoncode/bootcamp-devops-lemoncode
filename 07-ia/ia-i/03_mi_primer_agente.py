import os
import asyncio
from pydantic import Field
from typing_extensions import Annotated
from agent_framework import tool
from agent_framework.openai import OpenAIChatClient
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


@tool(approval_mode="never_required")
def get_weather(
    location: Annotated[str, Field(description="The location to get the weather for.")],
):
    # Simulación de obtener el clima de una ubicación
    weather_data = {
        "Madrid": "Soleado, 25°C",
        "Barcelona": "Nublado, 22°C",
        "Valencia": "Lluvioso, 18°C",
    }
    return weather_data.get(
        location, "No se dispone de información del clima para esa ubicación."
    )


async def main():
    # Crear un cliente de OpenAI
    client = OpenAIChatClient(
        base_url=LLM_ENDPOINT, api_key=LLM_API_KEY, model_id=model
    )

    # Crear un agente con el cliente de OpenAI
    agent = client.as_agent(
        name="WeatherAgent",
        instructions="Un agente que proporciona información sobre el clima en diferentes ubicaciones.",
        tools=get_weather,
    )

    # Registrar la función get_weather como una herramienta que el agente puede usar
    # agent.register_tool("get_weather", get_weather)

    # Definir el prompt para el agente
    prompt = "¿Cuál es el clima en Madrid?"

    # Ejecutar el agente con el prompt
    response = await agent.run(prompt)

    console.print(Markdown(f"Respuesta del agente: {response}"))


if __name__ == "__main__":
    asyncio.run(main())
