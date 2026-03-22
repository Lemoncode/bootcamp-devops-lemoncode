# 03_mcp_con_chainlit.py
# Ejemplo básico de Chainlit: chat con un LLM usando OpenAI SDK.
#
# Chainlit proporciona una interfaz de chat (estilo ChatGPT).
#
# Ejecutar:  chainlit run 03_mcp_con_chainlit.py
#   Se abrirá un navegador con la interfaz de chat.

import os
import chainlit as cl
from openai import AsyncOpenAI
from dotenv import load_dotenv

load_dotenv()


@cl.on_chat_start
async def start():
    """Inicializa el historial de mensajes cuando se abre el chat."""
    cl.user_session.set(
        "messages",
        [
            {
                "role": "system",
                "content": "Eres un asistente útil. Responde en español.",
            }
        ],
    )
    await cl.Message(
        content="👋 ¡Hola! Soy tu asistente. ¿En qué puedo ayudarte?"
    ).send()


@cl.on_message
async def on_message(message: cl.Message):
    """Se ejecuta cada vez que el usuario envía un mensaje."""
    messages = cl.user_session.get("messages")
    messages.append({"role": "user", "content": message.content})

    client = AsyncOpenAI(
        base_url=os.getenv("LLM_ENDPOINT"),
        api_key=os.getenv("LLM_API_KEY"),
    )

    response = await client.chat.completions.create(
        model=os.getenv("LLM_MODEL"),
        messages=messages,
    )

    reply = response.choices[0].message
    messages.append(reply)

    await cl.Message(content=reply.content or "(sin respuesta)").send()
