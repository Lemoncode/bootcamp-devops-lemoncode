import asyncio
import os

from agent_framework import Agent, MCPStdioTool
from agent_framework.openai import OpenAIChatClient
from dotenv import load_dotenv
from rich.console import Console

load_dotenv()

console = Console()

LLM_PROVIDER = os.getenv("LLM_PROVIDER")
LLM_MODEL = os.getenv("LLM_MODEL")
LLM_ENDPOINT = os.getenv("LLM_ENDPOINT")
LLM_API_KEY = os.getenv("LLM_API_KEY")
LEMONCODE_BOOTCAMP_URL = "https://lemoncode.net/lemoncode-blog/2025/5/23/bootcamp-devops-online-lemoncode-calendario-vi-edicion"
ROOT_DIR = os.path.dirname(os.path.abspath(__file__))


async def main() -> None:
    filesystem_mcp = MCPStdioTool(
        name="Filesystem MCP",
        command="npx",
        args=["-y", "@modelcontextprotocol/server-filesystem", ROOT_DIR],
        tool_name_prefix="fs",
        description="Servidor MCP externo para explorar el repositorio local.",
        load_prompts=False,  # No cargamos los prompts por defecto para este MCP, ya que no los necesitamos en este ejemplo.
    )

    playwright_mcp = MCPStdioTool(
        name="Playwright MCP",
        command="npx",
        args=["-y", "@playwright/mcp", "--browser=msedge"],
        tool_name_prefix="web",
        description="Servidor MCP externo para navegar al temario del bootcamp de Lemoncode",
        load_prompts=False,  # No cargamos los prompts por defecto para este MCP, ya que no los necesitamos en este ejemplo.
    )

    async with (
        filesystem_mcp,
        playwright_mcp,
        Agent(
            client=OpenAIChatClient(
                base_url=LLM_ENDPOINT,
                api_key=LLM_API_KEY,
                model_id=LLM_MODEL,
            ),
            name="DemoMCPExterno",
            instructions=(
                f"Eres el ayudante de Lemoncode que permite ayudar a los alumnos a buscar clases"
                f"dentro del temario del bootcamp de devops de Lemoncode en esta url:{LEMONCODE_BOOTCAMP_URL}"
                f"Usa el mcp server de playwright para navegar por la url y encontrar la información que te piden los alumnos."
            ),
            tools=[filesystem_mcp, playwright_mcp],
        ) as agent,
    ):
        console.print("Escribe una pregunta para el agente o 'salir' para terminar.\n")

        while True:
            prompt = input("Tu pregunta: ").strip()

            if not prompt:
                continue

            if prompt.lower() in {"salir", "exit", "quit"}:
                break

            response = agent.run(
                prompt,
                stream=True,
            )

            async for chunk in response:
                if chunk.text:
                    console.print(chunk.text, end="")

            console.print()


if __name__ == "__main__":
    asyncio.run(main())
