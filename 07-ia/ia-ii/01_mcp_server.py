from fastmcp import FastMCP

mcp = FastMCP("MCP Server de Cocina")

# ── Base de datos en memoria ───────────────────────────────────────────────

lista_compra: list[str] = []

# ── Tools: acciones que el LLM puede ejecutar ─────────────────────────────


@mcp.tool()
def buscar_receta(ingrediente: str) -> str:
    """Busca recetas que contengan un ingrediente"""
    recetas = {
        "pollo": [
            "🍗 Pollo al ajillo (30 min)",
            "🍗 Pollo asado con limón (1h)",
            "🌮 Fajitas de pollo (25 min)",
        ],
        "pasta": [
            "🍝 Carbonara (20 min)",
            "🍝 Pasta con tomate y albahaca (15 min)",
            "🧀 Macarrones con queso (25 min)",
        ],
        "huevo": [
            "🥚 Tortilla española (25 min)",
            "🍳 Huevos revueltos (5 min)",
            "🥞 Tortitas (15 min)",
        ],
        "patata": [
            "🥔 Patatas bravas (30 min)",
            "🥔 Puré de patatas (20 min)",
            "🥘 Guiso de patatas (45 min)",
        ],
    }
    ingrediente_lower = ingrediente.lower()
    if ingrediente_lower in recetas:
        return f"Recetas con {ingrediente}:\n" + "\n".join(
            f"  - {r}" for r in recetas[ingrediente_lower]
        )
    return f"No encontré recetas con '{ingrediente}'. Prueba con: pollo, pasta, huevo, patata."


@mcp.tool()
def gestionar_lista_compra(accion: str, item: str = "") -> str:
    """Gestiona la lista de la compra. Acciones: ver, añadir, quitar, vaciar."""
    global lista_compra

    if accion == "ver":
        if not lista_compra:
            return "🛒 La lista de la compra está vacía."
        return "🛒 Lista de la compra:\n" + "\n".join(
            f"  {i + 1}. {item}" for i, item in enumerate(lista_compra)
        )

    if accion == "añadir" and item:
        lista_compra.append(item)
        return f"✅ Añadido '{item}'. Total: {len(lista_compra)} productos."

    if accion == "quitar" and item:
        if item in lista_compra:
            lista_compra.remove(item)
            return f"🗑️ Quitado '{item}' de la lista."
        return f"'{item}' no está en la lista."

    if accion == "vaciar":
        lista_compra = []
        return "🗑️ Lista vaciada."

    return "Acción no reconocida. Usa: ver, añadir, quitar, vaciar."


@mcp.tool()
def convertir_unidades(valor: float, de: str, a: str) -> str:
    """Convierte entre unidades: km/mi, kg/lb, °C/°F, eur/usd."""
    conversiones = {
        ("km", "mi"): lambda v: v * 0.621371,
        ("mi", "km"): lambda v: v / 0.621371,
        ("kg", "lb"): lambda v: v * 2.20462,
        ("lb", "kg"): lambda v: v / 2.20462,
        ("c", "f"): lambda v: v * 9 / 5 + 32,
        ("f", "c"): lambda v: (v - 32) * 5 / 9,
        ("eur", "usd"): lambda v: v * 1.08,
        ("usd", "eur"): lambda v: v / 1.08,
    }
    key = (de.lower(), a.lower())
    if key in conversiones:
        resultado = conversiones[key](valor)
        return f"📐 {valor} {de} = {resultado:.2f} {a}"
    unidades = ", ".join(f"{a}→{b}" for a, b in conversiones)
    return f"Conversión no soportada. Disponibles: {unidades}"


# ── Resources: datos que el LLM puede leer como contexto ──────────────────


@mcp.resource("recetas://favoritas")
def recetas_favoritas() -> str:
    """Las recetas favoritas de la familia"""
    return """# Recetas favoritas

## 🥘 Tortilla española de la abuela
- 6 huevos, 4 patatas medianas, 1 cebolla, aceite de oliva, sal
- Freír patata y cebolla a fuego lento 20 min
- Batir huevos, mezclar, cuajar 3 min por lado

## 🍝 Pasta carbonara (la auténtica)
- Guanciale (o panceta), pecorino romano, huevos, pimienta negra, espaguetis
- Sin nata. Nunca. Jamás.

## 🍗 Pollo al limón express
- Pechugas, 2 limones, ajo, romero, aceite
- Marinar 30 min, horno 200°C 25 minutos
"""


@mcp.resource("tips://conservacion")
def tips_conservacion() -> str:
    """Tips para conservar alimentos"""
    return """# Tips de conservación

| Alimento | Nevera | Congelador |
|----------|--------|------------|
| Pollo crudo | 1-2 días | 9 meses |
| Carne picada | 1-2 días | 3-4 meses |
| Huevos | 3-5 semanas | No recomendado |
| Pasta cocinada | 3-5 días | 2 meses |
| Verdura fresca | 3-7 días | 8-12 meses |
"""


# ── Arranque ───────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("🚀 MCP Asistente Personal arrancando en http://localhost:8000/mcp")
    mcp.run(transport="streamable-http", host="0.0.0.0", port=8000)
