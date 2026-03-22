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
from agent_framework import Agent, MCPStreamableHTTPTool
from agent_framework.openai import OpenAIChatClient
from dotenv import load_dotenv
from rich.console import Console
from rich.markdown import Markdown

load_dotenv()
console = Console()

LLM_MODEL = os.getenv("LLM_MODEL")
LL_ENDPOINT = os.getenv("LL_ENDPOINT")
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
                base_url=LL_ENDPOINT,
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

        console.print(f"🔌 Conectado al MCP Server en {MCP_SERVER_URL}")
        console.print(f"💬 [bold]{prompt}[/bold]\n")

        response = await agent.run(prompt)

        console.print(Markdown(str(response)))


if __name__ == "__main__":
    asyncio.run(main())
