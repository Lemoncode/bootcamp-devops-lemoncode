from models import Sticker

stickers_db: dict[int, Sticker] = {
    1: Sticker(
        id=1,
        name="Gatito feliz",
        emoji="😸",
        category="animales",
        description="Un gatito muy contento",
    ),
    2: Sticker(
        id=2,
        name="Fuego",
        emoji="🔥",
        category="emociones",
        description="Cuando algo mola mucho",
    ),
    3: Sticker(
        id=3,
        name="Cohete",
        emoji="🚀",
        category="tech",
        description="Despliegue exitoso",
    ),
    4: Sticker(
        id=4,
        name="Pizza",
        emoji="🍕",
        category="comida",
        description="Viernes de pizza",
    ),
    5: Sticker(
        id=5,
        name="Tormenta",
        emoji="⛈️",
        category="naturaleza",
        description="Se avecinan cambios",
    ),
    6: Sticker(
        id=6,
        name="Robot",
        emoji="🤖",
        category="tech",
        description="Inteligencia artificial",
    ),
    7: Sticker(
        id=7,
        name="Unicornio",
        emoji="🦄",
        category="animales",
        description="Startup valorada en mil millones",
    ),
    8: Sticker(
        id=8,
        name="Pulpo",
        emoji="🐙",
        category="animales",
        description="Multitasking level pro",
    ),
    9: Sticker(
        id=9, name="Taco", emoji="🌮", category="comida", description="Porque sí"
    ),
    10: Sticker(
        id=10, name="Rayo", emoji="⚡", category="emociones", description="Energía pura"
    ),
}

next_id = len(stickers_db) + 1
