# 🤖 Desarrollo con GitHub Copilot y Python

> **Objetivo:** Aprender a usar GitHub Copilot como herramienta de desarrollo en el día a día,
> desde el autocompletado de código hasta la personalización avanzada con custom agents y MCP servers.

---

## ¿Qué es GitHub Copilot?

GitHub Copilot es una herramienta de asistencia al desarrollo basada en IA que se integra directamente
en el IDE. No es solo autocompletado — es un asistente que puede:

- **Autocompletar código** mientras escribes
- **Chatear en lenguaje natural** para generar, explicar o corregir código
- **Ejecutar acciones** como un agente autónomo (crear archivos, ejecutar tests, etc.)
- **Revisar código** antes de hacer commit
- **Generar mensajes de commit** basados en los cambios realizados
- **Trabajar en el terminal** sugiriendo comandos

### ¿Qué necesito para empezar?

1. **VS Code** instalado
2. **Cuenta de GitHub** — existe un plan gratuito (Copilot Free: 2000 code completions y 50 mensajes en el chat)

---

## Formas de interactuar con GitHub Copilot

### Code Completion (desde los archivos)

Mientras escribes código, Copilot sugiere completaciones que puedes aceptar con `Tab` o ignorar.
Funciona con el contexto del archivo abierto y archivos relacionados del proyecto.

### Chat

El chat tiene varios modos:

| Modo | Qué hace |
|------|----------|
| **Ask** | Le preguntas y te devuelve la respuesta en el chat. Puedes insertar el código manualmente |
| **Edit** | La sugerencia se inyecta directamente en el código, detectando otros ajustes necesarios |
| **Agent** | Modo autónomo: crea archivos, ejecuta comandos, instala dependencias... |

Además puedes:
- Usar **Chat Inline** (`Cmd+I`) para pedir cosas directamente desde cualquier punto del código
- Usar **Slash commands** (`/fix`, `/doc`, `/tests`...) como acciones rápidas
- Adjuntar **imágenes** (computer vision) para que el modelo las use como contexto
- Usar el **navegador integrado** para seleccionar elementos y usarlos como contexto del prompt
- Usar **Plan mode** para que Copilot te haga preguntas antes de generar código

### Terminal

El terminal integrado de VS Code también tiene asistencia de Copilot para sugerir comandos.

### GitHub.com

Copilot también está disponible directamente en GitHub.com para interactuar con repositorios.

---

## Corrección y mejora de código

Si tienes un problema en tu código, puedes:

- Seleccionar el código problemático y usar `/fix` en el chat
- Describir el problema en lenguaje natural
- Pedirle que revise tu código antes de hacer commit (**Review agent**)

---

## Generación de nuevo código

### Agent mode

Describe lo que necesitas y Copilot generará los archivos necesarios automáticamente.

**Ejemplo de prompt:**
> *"Quiero crear dentro de este proyecto un sitio web que se sirva a través del código que ya tengo
> con FastAPI y que me permita pintar mi galería de memes con la información que sirve la API.
> No quiero usar frameworks ni nada complejo, solo HTML, Tailwind CSS y JavaScript"*

### Generación de mensajes de commit

Copilot puede generar los mensajes de commit basándose en los cambios realizados.

---

## Personalización de GitHub Copilot

GitHub Copilot se puede personalizar a varios niveles:

| Técnica | ¿Qué es? | Cuándo usarla |
|---------|----------|---------------|
| **Prompt files** (`*.prompt.md`) | Instrucciones reusables que se cargan en el chat | Prompts comunes que quieres reutilizar para tareas concretas |
| **Instructions files** (`*.instructions.md`) | Preferencias y contexto persistente sobre tu proyecto | Directrices generales: estilo de código, tecnologías, estructura |
| **Custom instructions** (`.github/copilot-instructions.md`) | Instrucciones a nivel de repositorio | Contexto del proyecto que aplica a todas las tareas |
| **AGENTS.md** | Manual del proyecto para agentes autónomos | Guiar a agentes en repos grandes o complejos |
| **Custom agents** (`*.agent.md`) | Agentes especializados con nombre, prompt y herramientas propias | Automatizar flujos de trabajo con comportamiento consistente |
| **Skills** (`SKILL.md`) | Subcarpetas con habilidades que Copilot carga automáticamente | Tareas complejas que requieren pasos detallados o herramientas |
| **MCP Servers** (`mcp.json`) | Servidores que exponen herramientas externas | Interactuar con sistemas externos (GitHub, Playwright, etc.) |
| **Copilot Spaces** (GitHub.com) | Agrupan contexto de múltiples fuentes (repos, issues, docs...) | Preguntas basadas en múltiples fuentes de un proyecto |

### Custom instructions

Crea un archivo `.github/copilot-instructions.md` en tu repositorio con las instrucciones
que quieras que Copilot tenga en cuenta siempre. ¿No sabes qué incluir? Copilot puede generar
este archivo por ti.

### Custom agents y Skills

Puedes crear agentes especializados (`.agent.md`) y skills (`SKILL.md` en subcarpetas)
que se activan automáticamente cuando la tarea encaja con su descripción.
Las skills globales se ubican en `~/.copilot/skills/`.

---

## Aplicación de ejemplo

Usamos un **Sticker Pack** — una API de stickers con FastAPI (backend) y una web con
**Web Components** nativos (frontend, sin frameworks). FastAPI sirve tanto la API como
los archivos estáticos.

### Setup

```bash
cd 07-ia/ia-iii

# Crear entorno virtual
python -m venv .venv
source .venv/bin/activate  # macOS/Linux

# Instalar dependencias
pip install -r requirements.txt

# Ejecutar la app
python app.py
# Web:  http://localhost:8000
# API:  http://localhost:8000/docs
```

### Lo que puedes practicar con esta app

1. **Code completion** — Abre `app.py` y empieza a escribir un nuevo endpoint (ej. `DELETE /api/stickers/{id}`). Copilot debería sugerirte el código
2. **Chat Ask** — Pide a Copilot que te genere el endpoint DELETE y luego insértalo manualmente
3. **Chat Edit** — Pide lo mismo en modo Edit y observa cómo lo inyecta directamente
4. **Chat Agent** — Pide que añada un formulario a la web para crear stickers nuevos
5. **Fix** — Introduce un bug a propósito y usa `/fix` para que Copilot lo detecte y corrija
6. **Review** — Haz cambios y pide una revisión antes de hacer commit
7. **Personalización** — Crea un `.github/copilot-instructions.md` con reglas del proyecto

---

## Recursos

| Recurso | URL |
|---------|-----|
| Documentación GitHub Copilot | [docs.github.com/copilot](https://docs.github.com/en/copilot) |
| Custom instructions | [docs.github.com/.../add-repository-instructions](https://docs.github.com/es/copilot/how-tos/configure-custom-instructions/add-repository-instructions) |
| Awesome Copilot Customizations | [github.com/github/awesome-copilot](https://github.com/github/awesome-copilot) |
| Customization library | [docs.github.com/.../customization-library](https://docs.github.com/en/copilot/tutorials/customization-library/custom-instructions) |