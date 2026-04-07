import os
import asyncio
from pydantic import Field
from typing_extensions import Annotated
from agent_framework import AgentSession, tool
from agent_framework.openai import OpenAIChatClient
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


# 🧰 Esta tool es una funcion Python local del agente.
# No es un MCP server: el framework la expone directamente al modelo durante la ejecucion.
@tool(approval_mode="never_required")
def get_weather(
    location: Annotated[str, Field(description="The location to get the weather for.")],
):
    # 🌦️ Simulamos una consulta de clima para varias ciudades.
    weather_data = {
        "Madrid": "☀️ Soleado, 25°C",
        "Barcelona": "☁️ Nublado, 22°C",
        "Valencia": "🌧️ Lluvioso, 18°C",
        "Málaga": "🌤️ Parcialmente nublado, 24°C",
    }
    return weather_data.get(
        location, "No se dispone de información del clima para esa ubicación."
    )


async def main():
    # 🤖 Creamos el cliente de agente que hablara con el modelo.
    client = OpenAIChatClient(
        base_url=LLM_ENDPOINT, api_key=LLM_API_KEY, model_id=model
    )

    # 🧑‍🍳 Construimos el agente y le damos acceso a la tool local.
    agent = client.as_agent(
        name="WeatherAgent",
        instructions="Un agente que proporciona información sobre el clima en diferentes ubicaciones. Incluye emojis en sus respuestas para hacerlas más amenas y alguna recomendación dependiendo del clima.",
        tools=get_weather,
    )

    # 🔗 La tool se registra al crear el agente con tools=get_weather.
    # Aqui no hace falta registrarla aparte.

    # 💬 Ejemplos de preguntas para probar el agente:
    # - ¿Cual es el clima en Madrid?
    # - ¿Que tiempo hace en Barcelona y que me recomiendas hacer?
    # - ¿Como esta el clima en Valencia?
    #
    # 🧠 Si quisieras mantener memoria entre turnos, en este framework es mejor
    # 🧠 reutilizar una sesion compartida, por ejemplo:
    # from agent_framework import AgentSession
    session = AgentSession()
    # Lo dejamos comentado para que se vea la diferencia con este ejemplo,
    # donde cada pregunta va aislada.
    console.print("Escribe una pregunta para el agente o 'salir' para terminar.\n")

    while True:
        prompt = input("Tu pregunta: ").strip()

        if not prompt:
            continue

        if prompt.lower() in {"salir", "exit", "quit"}:
            break

        # 🧠 Ejemplo comentado de memoria entre turnos con sesion compartida:
        # response = await agent.run(prompt, session=session)

        # 🚀 Ejecutamos el agente y dejamos que decida si necesita usar la tool.
        # response = await agent.run(prompt)
        response = await agent.run(prompt, session=session)

        # 📄 Mostramos la respuesta final del agente.
        console.print(Markdown(f"## Respuesta del agente\n\n{response}"))


if __name__ == "__main__":
    asyncio.run(main())
