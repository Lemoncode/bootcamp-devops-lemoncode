# 🔌 Introducción a MCP (Model Context Protocol)

> **Objetivo:** Entender qué es MCP, por qué existe, y saber construir tu propio MCP Server
> y conectarte a él desde código Python.
>
> **Prerrequisito:** Clase anterior (ia-i) — LLMs, prompt engineering, agentes con tools.

---

## ¿Qué problema resuelve MCP?

En la clase anterior vimos cómo un agente puede usar **tools** para interactuar con el mundo exterior. Pero cada aplicación implementaba sus propias integraciones de forma **ad hoc**: cada cliente tenía que reimplementar la conexión a GitHub, a una base de datos, a una API interna...

**Antes de MCP** — cada cliente reimplementa la misma integración:

```
┌─────────────┐     integración custom     ┌──────────────┐
│  Cliente A  │ ─────────────────────────▶ │   GitHub API │
└─────────────┘                            └──────────────┘

┌─────────────┐     integración custom     ┌──────────────┐
│  Cliente B  │ ─────────────────────────▶ │   GitHub API │
└─────────────┘                            └──────────────┘

┌─────────────┐     integración custom     ┌──────────────┐
│  Tu agente  │ ─────────────────────────▶ │   GitHub API │
└─────────────┘                            └──────────────┘
```

**Con MCP** — un servidor, múltiples clientes. Construyes una vez, funciona en todos:

```
┌─────────────┐                            ┌──────────────┐
│  Cliente A  │ ──────────────────────┐    │              │
└─────────────┘                       │    │  MCP Server  │
                                      ├───▶│   (GitHub)   │───▶ GitHub API
┌─────────────┐    protocolo MCP      │    │              │
│  Cliente B  │ ──────────────────────┤    └──────────────┘
└─────────────┘                       │
                                      │    ┌──────────────┐
┌─────────────┐                       │    │  MCP Server  │
│  Tu agente  │ ──────────────────────┘    │ (tu sistema) │───▶ Tu API interna
└─────────────┘                            └──────────────┘
```

---

## ¿Qué es MCP?

**MCP (Model Context Protocol)** es un protocolo abierto, creado por Anthropic en noviembre de 2024, que estandariza cómo los LLMs se comunican con sistemas externos para obtener contexto y ejecutar acciones.

| Dato | Valor |
|------|-------|
| **Protocolo base** | JSON-RPC 2.0 |
| **Transportes** | `stdio` (local) · `HTTP + SSE` (remoto) · `Streamable HTTP` (moderno) |
| **Open source** | [github.com/modelcontextprotocol](https://github.com/modelcontextprotocol) |

### Los tres primitivos de MCP

| Primitivo | ¿Qué es? | Analogía |
|-----------|----------|----------|
| **Tools** | Funciones que el LLM puede invocar | Una función que ejecuta una acción |
| **Resources** | Datos/ficheros que el LLM puede leer | Un fichero de contexto que el LLM consulta |
| **Prompts** | Plantillas de prompts reutilizables | Snippets de instrucciones |

> En esta clase nos centraremos en **Tools** y **Resources**, que son los más usados.

---

## Arquitectura

### Los roles: Host, Client y Server

```
┌──────────────────────────────────────────────┐
│                HOST (Aplicación)              │
│           Tu app / Tu agente                 │
│                                              │
│  ┌─────────────────────────────────────┐    │
│  │           MCP CLIENT               │    │
│  │  (gestiona la conexión al servidor) │    │
│  └────────────────┬────────────────────┘    │
└───────────────────┼──────────────────────────┘
                    │ JSON-RPC (stdio o HTTP)
                    ▼
┌──────────────────────────────────────────────┐
│              MCP SERVER                       │
│                                              │
│  ┌──────────┐  ┌───────────┐  ┌──────────┐  │
│  │  Tools   │  │ Resources │  │ Prompts  │  │
│  └──────────┘  └───────────┘  └──────────┘  │
│                                              │
│         accede a sistemas externos           │
│  ┌──────────┐  ┌───────────┐  ┌──────────┐  │
│  │  APIs    │  │  Ficheros │  │    BBDDs │  │
│  └──────────┘  └───────────┘  └──────────┘  │
└──────────────────────────────────────────────┘
```

### Flujo de una petición completa

```
1. INICIALIZACIÓN
   Client ──▶ Server: initialize (versión del protocolo, capacidades)
   Server ──▶ Client: capabilities (qué tools y resources tiene)

2. DESCUBRIMIENTO
   Client ──▶ Server: tools/list
   Server ──▶ Client: [{ name, description, inputSchema }, ...]

3. USO (cuando el LLM decide llamar a una tool)
   LLM decide llamar a "buscar_receta"
   Client ──▶ Server: tools/call { name: "buscar_receta", arguments: { ingrediente: "pollo" } }
   Server ──▶ Client: { content: [{ type: "text", text: "Recetas con pollo: ..." }] }
   Client ──▶ LLM: resultado de la tool
```

### Transportes: ¿stdio o HTTP?

| | **stdio** | **HTTP (Streamable)** |
|---|---|---|
| **Cuándo usarlo** | Desarrollo, tools locales | Servidores remotos, producción |
| **Cómo funciona** | El cliente lanza el server como subproceso | El server corre independiente, el cliente se conecta |
| **Seguridad** | Hereda permisos del usuario | Necesita autenticación (OAuth, API keys...) |

---

## Setup

```bash
cd 07-ia/ia-ii

# Crear entorno virtual
python -m venv .venv
source .venv/bin/activate  # macOS/Linux

# Instalar dependencias
pip install -r requirements.txt

# Configurar variables de entorno
cp .env.example .env
# Edita .env con tu proveedor LLM (misma configuración que ia-i)
```

---

## Ejemplos

### 01 — Crear un MCP Server (`01_mcp_server.py`)

Un MCP Server con herramientas de un asistente personal (recetas, lista de la compra,
conversor de unidades) usando **FastMCP** (el SDK oficial de Python).

El servidor expone **tools** (funciones que el LLM puede invocar) y **resources**
(datos de solo lectura que el LLM puede consultar como contexto):

```python
from fastmcp import FastMCP

mcp = FastMCP("MCP Server de Cocina")

@mcp.tool()
def buscar_receta(ingrediente: str) -> str:
    """Busca recetas que contengan un ingrediente"""
    # ... lógica de búsqueda ...

@mcp.resource("recetas://favoritas")
def recetas_favoritas() -> str:
    """Las recetas favoritas de la familia"""
    # ... devuelve datos de contexto ...

if __name__ == "__main__":
    mcp.run(transport="streamable-http", host="0.0.0.0", port=8000)
```

Se expone como servidor HTTP en `http://localhost:8000/mcp`.

```bash
# Arrancar el servidor (se queda escuchando en el puerto 8000)
python 01_mcp_server.py

# Probar con el inspector oficial de MCP (necesita Node.js)
# Conectar a: http://localhost:8000/mcp
npx @modelcontextprotocol/inspector
```

### 02 — Conectar al MCP desde un agente (`02_mcp_con_agent.py`)

Un agente que se conecta al MCP Server por HTTP, **descubre las herramientas
disponibles via el protocolo MCP**, y usa un LLM para decidir cuáles llamar.

Es el mismo patrón de agente con tools de la clase anterior (ia-i), pero ahora
las tools **no están definidas en el código del agente** — vienen del MCP Server.
Esto significa que puedes cambiar las herramientas en el servidor sin tocar el cliente.

```bash
# En otra terminal (el servidor debe estar corriendo)
python 02_mcp_con_agent.py
```

### 03 — Chat UI con Chainlit (`03_mcp_con_chainlit.py`)

Un ejemplo básico de **Chainlit**, un framework que proporciona una interfaz de chat
web (estilo ChatGPT) conectada a un LLM. Sirve como base para luego conectarle
herramientas MCP u otras integraciones.

```bash
chainlit run 03_mcp_con_chainlit.py
# Se abrirá un navegador con la interfaz de chat
```

---

## Recursos

| Recurso | URL |
|---------|-----|
| Spec oficial MCP | [spec.modelcontextprotocol.io](https://spec.modelcontextprotocol.io) |
| SDK Python | [github.com/modelcontextprotocol/python-sdk](https://github.com/modelcontextprotocol/python-sdk) |
| Catálogo de servers | [mcp.so](https://mcp.so) |
| Awesome MCP | [github.com/punkpeye/awesome-mcp-servers](https://github.com/punkpeye/awesome-mcp-servers) |
| Documentación Anthropic | [docs.anthropic.com/mcp](https://docs.anthropic.com/en/docs/agents-and-tools/mcp) |

