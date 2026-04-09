import os
import asyncio
import httpx
from agent_framework import Agent, AgentSession, Content, MCPStreamableHTTPTool
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


async def comprobar_mcp_disponible() -> bool:
    """Comprueba si hay un proceso escuchando en la URL del MCP."""
    try:
        async with httpx.AsyncClient(timeout=2.0) as client:
            await client.get(MCP_SERVER_URL)
        return True
    except httpx.ConnectError:
        return False
    except httpx.HTTPError:
        # Si responde con 404/405 u otro error HTTP, nos basta saber que hay servidor escuchando.
        return True


def pedir_aprobacion(request: Content) -> Content:
    """Pide confirmación en terminal antes de ejecutar una tool MCP."""
    function_call = request.function_call
    tool_name = getattr(function_call, "tool_name", None) or getattr(
        function_call, "name", "tool_desconocida"
    )
    arguments = getattr(function_call, "arguments", None)

    console.print(f"\n🛑 El agente quiere usar la tool: [bold]{tool_name}[/bold]")
    if arguments:
        console.print(f"📦 Argumentos: {arguments}")

    while True:
        decision = input("¿Quieres permitir esta llamada? [s/n]: ").strip().lower()
        if decision in {"s", "si", "sí", "y", "yes"}:
            return request.to_function_approval_response(approved=True)
        if decision in {"n", "no"}:
            return request.to_function_approval_response(approved=False)
        console.print("Respuesta no válida. Escribe 's' o 'n'.")


async def ejecutar_con_aprobacion(
    agent: Agent, prompt_o_respuesta: str | Content, session: AgentSession
) -> None:
    """Ejecuta el agente y resuelve aprobaciones de tools de forma interactiva."""
    pending_input: str | Content = prompt_o_respuesta

    while True:
        response = agent.run(
            pending_input,
            stream=True,
            session=session,
        )

        async for chunk in response:
            # 🔧 Si el modelo solicita aprobación, no imprimimos texto todavía;
            # resolveremos la petición al finalizar este ciclo.
            if chunk.user_input_requests:
                continue

            if chunk.text:
                console.print(chunk.text, end="")

        final_response = await response.get_final_response()
        approval_requests = final_response.user_input_requests

        if not approval_requests:
            console.print()
            return

        # ✅ En este ejemplo resolvemos una aprobación cada vez y reanudamos la conversación.
        pending_input = pedir_aprobacion(approval_requests[0])


async def main():
    if not await comprobar_mcp_disponible():
        console.print("❌ No puedo conectar con el MCP Server.")
        console.print(
            "👉 Arranca primero 01_mcp_server.py y vuelve a lanzar este script."
        )
        console.print(f"🌐 URL esperada: {MCP_SERVER_URL}")
        return

    async with (
        MCPStreamableHTTPTool(
            name="Asistente Personal MCP",
            url=MCP_SERVER_URL,
            approval_mode="always_require",
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
        console.print(
            "🛡️ Confirmación de tools activada: tendrás que aprobar cada llamada MCP."
        )

        console.print("Escribe una pregunta para el agente o 'salir' para terminar.\n")

        while True:
            # 💬 Leemos la pregunta del usuario desde consola para enviársela al agente.
            prompt = input("Tu pregunta: ").strip()

            if not prompt:
                continue

            # 🚪 Permitimos varias palabras habituales para salir cómodamente del programa.
            if prompt.lower() in {"salir", "exit", "quit"}:
                break

            await ejecutar_con_aprobacion(agent, prompt, session)


if __name__ == "__main__":
    asyncio.run(main())
