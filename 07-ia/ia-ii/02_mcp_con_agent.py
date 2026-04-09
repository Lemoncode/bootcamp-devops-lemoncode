# 02_mcp_con_agent.py
# Conecta a un MCP Server remoto y usa un LLM para orquestar las herramientas.
#
# Usa Microsoft Agent Framework con MCPStreamableHTTPTool, que se encarga de:
#   - Conectar al MCP Server por HTTP
#   - Descubrir las herramientas disponibles via protocolo MCP
#   - Convertirlas al formato que necesita el LLM
#   - Ejecutar el bucle agéntico automáticamente
#
# Requisito: el MCP Server debe estar corriendo (python 01_mcp_server.py)
# Ejecutar:  python 02_mcp_con_agent.py

import os
import asyncio
from agent_framework import Agent, AgentSession, MCPStreamableHTTPTool
from agent_framework.openai import OpenAIChatClient
from dotenv import load_dotenv
from rich.console import Console

load_dotenv()
console = Console()

LLM_PROVIDER = os.getenv("LLM_PROVIDER")
LLM_MODEL = os.getenv("LLM_MODEL")
LLM_ENDPOINT = os.getenv("LLM_ENDPOINT")
LLM_API_KEY = os.getenv("LLM_API_KEY")
MCP_SERVER_URL = "http://localhost:8000/mcp"


async def main():
    async with (
        MCPStreamableHTTPTool(
            name="Asistente Personal MCP",
            url=MCP_SERVER_URL,
        ) as mcp_server,
        Agent(
            client=OpenAIChatClient(
                base_url=LLM_ENDPOINT,
                api_key=LLM_API_KEY,
                model_id=LLM_MODEL,
            ),
            name="AsistentePersonal",
            instructions="Eres un asistente personal útil. Usa las herramientas MCP disponibles para ayudar al usuario con recetas, listas de la compra y conversiones. Responde en español.",
            tools=[mcp_server],
        ) as agent,
    ):
        prompt = (
            "Quiero hacer algo con pollo para cenar. Busca recetas, "
            "y añade a la lista de la compra: pollo, ajo y limón. "
            "Ah, y dime cuántas libras son 2 kg de pollo."
        )

        session = AgentSession()

        console.print(f"🔌 Conectado al MCP Server en {MCP_SERVER_URL}")

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
    asyncio.run(main())
