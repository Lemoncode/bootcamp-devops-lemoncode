import asyncio
import os

from agent_framework import Agent, AgentSession, MCPStdioTool
from agent_framework.openai import OpenAIChatClient
from dotenv import load_dotenv
from rich.console import Console

# 🔐 Carga las variables de entorno desde un fichero .env para no hardcodear credenciales.
load_dotenv()

console = Console()

# 🧩 Esta configuración permite cambiar proveedor, modelo y endpoint sin tocar el código.
LLM_PROVIDER = os.getenv("LLM_PROVIDER")
LLM_MODEL = os.getenv("LLM_MODEL")
LLM_ENDPOINT = os.getenv("LLM_ENDPOINT")
LLM_API_KEY = os.getenv("LLM_API_KEY")
# 🌍 URL que el agente usará como fuente de información para responder preguntas.
LEMONCODE_BOOTCAMP_URL = "https://lemoncode.net/lemoncode-blog/2025/5/23/bootcamp-devops-online-lemoncode-calendario-vi-edicion"
# 📁 Directorio actual del script, útil para limitar qué parte del sistema de archivos expone el MCP.
ROOT_DIR = os.path.dirname(os.path.abspath(__file__))


async def main() -> None:
    # 🗂️ Este servidor MCP expone operaciones sobre archivos locales al agente.
    filesystem_mcp = MCPStdioTool(
        name="Filesystem MCP",
        command="npx",
        args=["-y", "@modelcontextprotocol/server-filesystem", ROOT_DIR],
        tool_name_prefix="fs",
        description="Servidor MCP externo para explorar el repositorio local.",
        load_prompts=False,  # No cargamos los prompts por defecto para este MCP, ya que no los necesitamos en este ejemplo.
    )

    # 🌐 Este servidor MCP permite controlar un navegador para consultar la web del bootcamp.
    playwright_mcp = MCPStdioTool(
        name="Playwright MCP",
        command="npx",
        args=["-y", "@playwright/mcp", "--browser=msedge"],
        tool_name_prefix="web",
        description="Servidor MCP externo para navegar al temario del bootcamp de Lemoncode",
        load_prompts=False,  # No cargamos los prompts por defecto para este MCP, ya que no los necesitamos en este ejemplo.
    )

    # 🔄 Abrimos los MCPs y el agente dentro del mismo contexto para inicializar y liberar recursos correctamente.
    async with (
        filesystem_mcp,
        playwright_mcp,
        Agent(
            # 🧠 El cliente del modelo conecta con el LLM configurado por variables de entorno.
            client=OpenAIChatClient(
                base_url=LLM_ENDPOINT,
                api_key=LLM_API_KEY,
                model_id=LLM_MODEL,
            ),
            name="DemoMCPExterno",
            instructions=(
                # 📝 Estas instrucciones indican al agente qué objetivo tiene y qué herramienta debe usar.
                f"Eres el ayudante de Lemoncode que permite ayudar a los alumnos a buscar clases"
                f"dentro del temario del bootcamp de devops de Lemoncode en esta url:{LEMONCODE_BOOTCAMP_URL}"
                f"Usa el mcp server de playwright para navegar por la url y encontrar la información que te piden los alumnos."
                f"Escribe en un archivo de texto el resultado de tu búsqueda usando el mcp server de filesystem para que el alumno pueda leerlo después."
            ),
            # 🧰 Aquí registramos qué herramientas puede invocar el agente durante la conversación.
            tools=[filesystem_mcp, playwright_mcp],
        ) as agent,
    ):
        session = AgentSession()

        console.print("Escribe una pregunta para el agente o 'salir' para terminar.\n")

        while True:
            # 💬 Leemos la pregunta del usuario desde consola para enviársela al agente.
            prompt = input("Tu pregunta: ").strip()

            if not prompt:
                continue

            # 🚪 Permitimos varias palabras habituales para salir cómodamente del programa.
            if prompt.lower() in {"salir", "exit", "quit"}:
                break

            # 📡 `stream=True` hace que la respuesta llegue por fragmentos, como en un chat en tiempo real.
            response = agent.run(
                prompt,
                stream=True,
                session=session,  # Reutilizamos la misma sesión para mantener contexto entre preguntas.
            )

            async for chunk in response:
                # 🧱 Cada fragmento puede contener parte del texto generado; lo mostramos según llega.
                if chunk.text:
                    console.print(chunk.text, end="")

            console.print()


if __name__ == "__main__":
    # ▶️ Ejecutamos la función asíncrona principal arrancando el bucle de eventos de asyncio.
    asyncio.run(main())
