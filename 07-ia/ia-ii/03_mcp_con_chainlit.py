# 03_mcp_con_chainlit.py
# Chainlit con configuración dinámica de MCP Servers HTTP desde la interfaz.
#
# Qué hace este ejemplo:
# - Muestra un chat web con Chainlit
# - Permite configurar URLs de servidores MCP desde la barra lateral
# - Recrea el agente usando esos servidores en cada mensaje
# - Puede pedir aprobación antes de ejecutar una tool MCP
#
# Ejecutar: chainlit run 03_mcp_con_chainlit.py --port 8001

import json
import os
import inspect
from contextlib import AsyncExitStack
from typing import Any

import chainlit as cl
from agent_framework import Agent, AgentSession, Content, MCPStreamableHTTPTool
from agent_framework.openai import OpenAIChatCompletionClient
from chainlit.input_widget import Select, Switch, TextInput
from dotenv import load_dotenv

# 🔐 Cargamos variables de entorno desde `.env` para no exponer claves en el código.
load_dotenv()

# 🧩 Esta configuración permite cambiar modelo y endpoint sin modificar el script.
LLM_MODEL = os.getenv("LLM_MODEL")
LLM_ENDPOINT = os.getenv("LLM_ENDPOINT")
LLM_API_KEY = os.getenv("LLM_API_KEY")
DEFAULT_SYSTEM_PROMPT = "Eres un asistente útil. Responde en español."
# 🌐 URL por defecto del MCP Server que el usuario puede cambiar desde la UI.
DEFAULT_MCP_URL = "http://localhost:8000/mcp"


def crear_chat_client() -> OpenAIChatCompletionClient:
    """Crea el cliente OpenAI usando la API de chat completions.

    Este cliente suele ser más compatible con endpoints OpenAI-like que no
    implementan todavía la API `/responses`.
    """
    # 🔎 Algunas versiones del SDK usan `model` y otras `model_id`.
    # Inspeccionamos la firma para ser compatibles con ambas.
    signature = inspect.signature(OpenAIChatCompletionClient.__init__)

    common_kwargs = {
        "base_url": LLM_ENDPOINT,
        "api_key": LLM_API_KEY,
    }

    if "model_id" in signature.parameters:
        return OpenAIChatCompletionClient(model_id=LLM_MODEL, **common_kwargs)

    return OpenAIChatCompletionClient(model=LLM_MODEL, **common_kwargs)


def obtener_configuracion() -> dict[str, Any]:
    """Recupera la configuración activa de la sesión o devuelve los valores por defecto."""
    # 🧠 `user_session` permite guardar estado por usuario dentro de Chainlit.
    config = cl.user_session.get("app_settings")
    if config:
        return {
            "system_prompt": config.get("system_prompt", DEFAULT_SYSTEM_PROMPT),
            "mcp_enabled": bool(config.get("mcp_enabled", True)),
            "mcp_url": config.get("mcp_url", DEFAULT_MCP_URL),
            "approval_mode": config.get("approval_mode", "never_require"),
        }

    return {
        "system_prompt": DEFAULT_SYSTEM_PROMPT,
        "mcp_enabled": True,
        "mcp_url": DEFAULT_MCP_URL,
        "approval_mode": "never_require",
    }


def guardar_configuracion(settings: dict[str, Any]) -> dict[str, Any]:
    """Normaliza y guarda la configuración recibida desde Chainlit."""
    # 🧹 Limpiamos la URL para evitar espacios accidentales al pegarla en el formulario.
    mcp_url = (settings.get("MCPServerURL") or DEFAULT_MCP_URL).strip()

    config = {
        "system_prompt": settings.get("SystemPrompt") or DEFAULT_SYSTEM_PROMPT,
        "mcp_enabled": bool(settings.get("MCPEnabled", True)),
        "mcp_url": mcp_url,
        "approval_mode": settings.get("ApprovalMode", "never_require"),
    }
    cl.user_session.set("app_settings", config)
    return config


def crear_formulario(config: dict[str, Any]) -> cl.ChatSettings:
    """Construye el formulario lateral de Chainlit para configurar MCP dinámicamente."""
    # 🧰 Este formulario aparece en la barra lateral y el usuario puede cambiarlo en caliente.
    approval_values = ["never_require", "always_require"]
    approval_index = approval_values.index(config["approval_mode"])

    return cl.ChatSettings(
        [
            TextInput(
                id="SystemPrompt",
                label="System Prompt",
                initial=config["system_prompt"],
                multiline=True,
                description="Instrucciones base del asistente.",
            ),
            Switch(
                id="MCPEnabled",
                label="Activar MCP",
                initial=config["mcp_enabled"],
                description="Si está desactivado, el chat funcionará sin tools MCP.",
            ),
            TextInput(
                id="MCPServerURL",
                label="MCP Server HTTP",
                initial=config["mcp_url"],
                description="URL del servidor MCP que quieres usar en este chat.",
            ),
            Select(
                id="ApprovalMode",
                label="Aprobación de Tools MCP",
                values=approval_values,
                initial_index=approval_index,
                description="Controla si Chainlit debe pedir confirmación antes de usar una tool MCP.",
            ),
        ]
    )


async def crear_agente(
    stack: AsyncExitStack, config: dict[str, Any]
) -> tuple[Agent, str | None]:
    """Crea el agente con un único MCP opcional, igual que en el ejemplo de terminal."""
    # 🧺 `tools` contendrá el MCP remoto si la integración está activada y la conexión funciona.
    tools: list[MCPStreamableHTTPTool] = []
    mcp_warning: str | None = None

    if config["mcp_enabled"] and config["mcp_url"]:
        try:
            # 🔌 Abrimos la conexión con el MCP Server dentro de un `AsyncExitStack`
            # para que Chainlit pueda cerrarla correctamente al terminar el mensaje.
            mcp_server = await stack.enter_async_context(
                MCPStreamableHTTPTool(
                    name="Asistente Personal MCP",
                    url=config["mcp_url"],
                    approval_mode=config["approval_mode"],
                )
            )
            tools.append(mcp_server)
        except Exception as exc:
            # ⚠️ Si el MCP falla, el chat sigue funcionando como LLM puro.
            mcp_warning = (
                "⚠️ No pude conectar con el MCP Server configurado. "
                f"Seguiré sin tools MCP.\n\n- {config['mcp_url']} ({type(exc).__name__}: {exc})"
            )

    # 🤖 El agente se crea en cada mensaje para aplicar la configuración actual de la UI.
    agent = await stack.enter_async_context(
        Agent(
            client=crear_chat_client(),
            name="AsistentePersonal",
            instructions=config["system_prompt"],
            tools=tools,
        )
    )

    return agent, mcp_warning


async def pedir_aprobacion_ui(request: Content) -> Content:
    """Pide aprobación al usuario desde la interfaz web antes de ejecutar una tool."""
    # 🧠 Igual que en el ejemplo de terminal, el framework nos entrega una petición
    # de aprobación que contiene la tool y sus argumentos.
    function_call = request.function_call
    tool_name = getattr(function_call, "tool_name", None) or getattr(
        function_call, "name", "tool_desconocida"
    )
    arguments = getattr(function_call, "arguments", None)

    if isinstance(arguments, str):
        try:
            arguments_text = json.dumps(
                json.loads(arguments), ensure_ascii=False, indent=2
            )
        except json.JSONDecodeError:
            arguments_text = arguments
    else:
        arguments_text = json.dumps(arguments or {}, ensure_ascii=False, indent=2)

    # 🙋 En vez de pedir aprobación por consola, Chainlit muestra botones en la UI.
    response = await cl.AskActionMessage(
        content=(
            f"🛑 El agente quiere usar la tool MCP **{tool_name}**.\n\n"
            f"Argumentos:\n```json\n{arguments_text}\n```"
        ),
        actions=[
            cl.Action(
                name="approve_tool", payload={"approved": True}, label="Permitir"
            ),
            cl.Action(name="deny_tool", payload={"approved": False}, label="Denegar"),
        ],
        timeout=120,
    ).send()

    # ✅ Convertimos la acción pulsada en una respuesta de aprobación entendible por el agente.
    approved = bool(response and response.get("payload", {}).get("approved"))
    return request.to_function_approval_response(approved=approved)


async def ejecutar_agente_en_chainlit(
    agent: Agent, prompt_o_respuesta: str | Content, session: AgentSession
) -> str:
    """Ejecuta el agente y resuelve aprobaciones en la UI, igual que el ejemplo de terminal."""
    # 🔁 `pending_input` puede ser texto normal del usuario o una aprobación/denegación.
    pending_input: str | Content = prompt_o_respuesta

    # 💬 Creamos un mensaje vacío y lo vamos rellenando a medida que el agente produce texto.
    outgoing_message = cl.Message(content="")
    await outgoing_message.send()

    while True:
        # 📡 El agente se ejecuta en streaming para que la UI vea la respuesta progresivamente.
        response = agent.run(pending_input, stream=True, session=session)
        saw_text = False

        async for chunk in response:
            # 🛑 Si aparece una solicitud de aprobación, no imprimimos texto todavía;
            # se resolverá al finalizar este ciclo.
            if chunk.user_input_requests:
                continue

            if chunk.text:
                saw_text = True
                await outgoing_message.stream_token(chunk.text)

        # 📦 Recuperamos la respuesta final consolidada para comprobar si quedaron aprobaciones pendientes.
        final_response = await response.get_final_response()
        approval_requests = final_response.user_input_requests

        if not approval_requests:
            if not saw_text and not outgoing_message.content:
                outgoing_message.content = final_response.text or "(sin respuesta)"
                await outgoing_message.update()
            return final_response.text

        # ▶️ Si el modelo quiere usar una tool, pedimos confirmación al usuario y reanudamos el flujo.
        pending_input = await pedir_aprobacion_ui(approval_requests[0])


@cl.on_chat_start
async def start():
    """Inicializa la sesión del chat y muestra el formulario de configuración dinámica."""
    # ⚙️ Al abrir el chat, pintamos la configuración lateral con valores por defecto.
    config = obtener_configuracion()
    settings = await crear_formulario(config).send()
    config = guardar_configuracion(settings)

    # 🗂️ La sesión conserva el contexto conversacional aunque el agente se recree en cada mensaje.
    cl.user_session.set("agent_session", AgentSession())

    await cl.Message(
        content=(
            "👋 Hola. Este ejemplo usa Chainlit + Agent Framework y te deja configurar MCP HTTP "
            "desde la barra lateral.\n\n"
            f"MCP inicial: {config['mcp_url']}"
        )
    ).send()


@cl.on_settings_update
async def on_settings_update(settings: dict[str, Any]):
    """Se ejecuta cuando el usuario cambia la configuración lateral de Chainlit."""
    config = guardar_configuracion(settings)

    # 🔄 Reiniciamos la sesión del agente para que la nueva configuración empiece limpia.
    cl.user_session.set("agent_session", AgentSession())

    estado_mcp = "activado" if config["mcp_enabled"] else "desactivado"

    await cl.Message(
        content=(
            f"⚙️ Configuración actualizada. MCP {estado_mcp}.\n\n"
            f"Aprobación: `{config['approval_mode']}`\n"
            f"Servidor MCP: {config['mcp_url']}\n\n"
            "He reiniciado el contexto del agente para aplicar los cambios."
        )
    ).send()


@cl.on_message
async def on_message(message: cl.Message):
    """Procesa cada mensaje creando el agente con la configuración MCP activa en ese momento."""
    # 📥 Leemos la configuración actual y recuperamos la sesión para mantener el contexto.
    config = obtener_configuracion()
    session = cl.user_session.get("agent_session") or AgentSession()
    cl.user_session.set("agent_session", session)

    # 🧱 Este contexto agrupa y cierra automáticamente el MCP y el agente al terminar la petición.
    async with AsyncExitStack() as stack:
        agent, mcp_warning = await crear_agente(stack, config)

        if mcp_warning:
            await cl.Message(content=mcp_warning).send()

        # ▶️ Lanzamos la ejecución del agente usando el mismo patrón que en el ejemplo de terminal,
        # pero adaptado a la interfaz web de Chainlit.
        await ejecutar_agente_en_chainlit(agent, message.content, session)
