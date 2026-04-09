import os
import asyncio
import httpx
from agent_framework import Agent, AgentSession, Content, MCPStreamableHTTPTool
from agent_framework.openai import OpenAIChatClient
from dotenv import load_dotenv
from rich.console import Console

# 🔐 Cargamos variables de entorno desde `.env` para no dejar credenciales en el código.
load_dotenv()
console = Console()

# 🧩 Esta configuración permite cambiar modelo, endpoint o clave sin tocar el script.
LLM_PROVIDER = os.getenv("LLM_PROVIDER")
LLM_MODEL = os.getenv("LLM_MODEL")
LLM_ENDPOINT = os.getenv("LLM_ENDPOINT")
LLM_API_KEY = os.getenv("LLM_API_KEY")
# 🌐 URL donde esperamos encontrar el MCP Server HTTP.
MCP_SERVER_URL = "http://localhost:8000/mcp"


async def comprobar_mcp_disponible() -> bool:
    """Comprueba si hay un proceso escuchando en la URL del MCP."""
    # 🚦 Antes de crear el cliente MCP, comprobamos si el servidor responde.
    # Esto evita mostrar un traceback largo cuando simplemente está apagado.
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
    # 🧠 El framework nos entrega la petición de aprobación como un objeto `Content`.
    # Dentro viene la llamada que el modelo quiere hacer a la tool remota.
    function_call = request.function_call
    tool_name = getattr(function_call, "tool_name", None) or getattr(
        function_call, "name", "tool_desconocida"
    )
    arguments = getattr(function_call, "arguments", None)

    # 🛑 Mostramos al usuario qué tool se quiere ejecutar antes de continuar.
    console.print(f"\n🛑 El agente quiere usar la tool: [bold]{tool_name}[/bold]")
    if arguments:
        console.print(f"📦 Argumentos: {arguments}")

    while True:
        # 🙋 Esperamos una confirmación explícita del usuario, como hace Copilot.
        decision = input("¿Quieres permitir esta llamada? [s/n]: ").strip().lower()
        if decision in {"s", "si", "sí", "y", "yes"}:
            # ✅ Convertimos la petición en una respuesta de aprobación y la devolvemos al agente.
            return request.to_function_approval_response(approved=True)
        if decision in {"n", "no"}:
            # ❌ Si el usuario deniega, el agente recibe esa respuesta y debe reaccionar.
            return request.to_function_approval_response(approved=False)
        console.print("Respuesta no válida. Escribe 's' o 'n'.")


async def ejecutar_con_aprobacion(
    agent: Agent, prompt_o_respuesta: str | Content, session: AgentSession
) -> None:
    """Ejecuta el agente y resuelve aprobaciones de tools de forma interactiva."""
    # 🔁 `pending_input` puede ser texto normal del usuario o una respuesta de aprobación.
    # Gracias a eso podemos reanudar la ejecución del agente después de cada confirmación.
    pending_input: str | Content = prompt_o_respuesta

    while True:
        # 🤖 Lanzamos la ejecución del agente en modo streaming para recibir respuesta por fragmentos.
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

            # 💬 Los fragmentos de texto se van mostrando según llegan, como en un chat.
            if chunk.text:
                console.print(chunk.text, end="")

        # 📦 Al final del stream recuperamos la respuesta consolidada para inspeccionar
        # si el modelo ha pedido aprobaciones pendientes.
        final_response = await response.get_final_response()
        approval_requests = final_response.user_input_requests

        if not approval_requests:
            console.print()
            return

        # ✅ En este ejemplo resolvemos una aprobación cada vez y reanudamos la conversación.
        # Si hubiera varias, el bucle volvería a entrar y las iría procesando una a una.
        pending_input = pedir_aprobacion(approval_requests[0])


async def main():
    # 🔍 Verificamos primero que el servidor MCP está arrancado antes de crear la conexión.
    if not await comprobar_mcp_disponible():
        console.print("❌ No puedo conectar con el MCP Server.")
        console.print(
            "👉 Arranca primero 01_mcp_server.py y vuelve a lanzar este script."
        )
        console.print(f"🌐 URL esperada: {MCP_SERVER_URL}")
        return

    # 🔌 Abrimos a la vez la conexión con el MCP Server y el agente que la usará.
    async with (
        MCPStreamableHTTPTool(
            name="Asistente Personal MCP",
            url=MCP_SERVER_URL,
            # 🛡️ Forzamos que cualquier tool MCP requiera confirmación previa.
            approval_mode="always_require",
        ) as mcp_server,
        Agent(
            # 🧠 Este cliente conecta con el modelo configurado por variables de entorno.
            client=OpenAIChatClient(
                base_url=LLM_ENDPOINT,
                api_key=LLM_API_KEY,
                model_id=LLM_MODEL,
            ),
            name="AsistentePersonal",
            # 📝 Estas instrucciones le dicen al agente qué tipo de ayuda debe ofrecer.
            instructions="Eres un asistente personal útil. Usa las herramientas MCP disponibles para ayudar al usuario con recetas, listas de la compra y conversiones. Responde en español.",
            # 🧰 Registramos el MCP remoto como conjunto de tools disponibles para el agente.
            tools=[mcp_server],
        ) as agent,
    ):
        # 🗂️ La sesión permite mantener contexto entre varias preguntas del usuario.
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

            # ▶️ Delegamos toda la lógica de streaming y aprobación en una función separada.
            await ejecutar_con_aprobacion(agent, prompt, session)


if __name__ == "__main__":
    # 🚀 `asyncio.run` arranca el bucle de eventos y ejecuta la función principal.
    asyncio.run(main())
