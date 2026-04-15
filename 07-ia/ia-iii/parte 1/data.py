import sqlite3
from pathlib import Path
from models import Destination

DB_PATH = Path(__file__).resolve().parent / "destinations.db"

SEED_DATA = [
    (1, "Isla del WiFi Gratis", "🏝️", "Donde siempre hay 5 barras", "tropical", "relax", "El router está alimentado por cocos"),
    (2, "Montaña del Lunes Festivo", "🏔️", "Aquí todos los días son viernes", "templado", "aventura", "Los despertadores están prohibidos por ley"),
    (3, "Pueblito Sin Reuniones", "🏘️", "Prohibido decir 'podría haber sido un email'", "mediterráneo", "relax", "Las salas de reuniones se convirtieron en siestodromes"),
    (4, "Ciudad del Café Infinito", "☕", "Las fuentes públicas son de cold brew", "urbano", "fiesta", "Dormir está bien visto, pero es opcional"),
    (5, "Volcán del Deploy a Producción", "🌋", "Vive al límite (literalmente)", "extremo", "aventura", "Cada erupción es un deploy sin rollback"),
    (6, "Playa del Código Limpio", "🏖️", "Donde todos los PRs se aprueban a la primera", "tropical", "relax", "La arena está hecha de semicolons reciclados"),
    (7, "Selva del Standup Corto", "🌴", "Los standups duran 30 segundos máximo", "tropical", "aventura", "Los monos hacen mejor Scrum que tu equipo"),
    (8, "Glaciar del Inbox Zero", "🧊", "0 emails no leídos, garantizado", "polar", "relax", "Los emails se congelan al llegar y nunca se descongelan"),
    (9, "Desierto del Bug Resuelto", "🏜️", "Aquí los bugs se resuelven solos", "árido", "aventura", "Los cactus dan sombra y también hacen code review"),
    (10, "Archipiélago Sin Jira", "🏝️", "Gestión de proyectos? Qué es eso?", "tropical", "fiesta", "Los tickets se escriben en la arena y la marea los borra"),
]


def get_connection():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def init_db():
    conn = get_connection()
    conn.execute("""
        CREATE TABLE IF NOT EXISTS destinations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            emoji TEXT NOT NULL,
            tagline TEXT NOT NULL,
            climate TEXT NOT NULL,
            vibe TEXT NOT NULL,
            fun_fact TEXT DEFAULT ''
        )
    """)
    count = conn.execute("SELECT COUNT(*) FROM destinations").fetchone()[0]
    if count == 0:
        conn.executemany(
            "INSERT INTO destinations (id, name, emoji, tagline, climate, vibe, fun_fact) VALUES (?, ?, ?, ?, ?, ?, ?)",
            SEED_DATA,
        )
    conn.commit()
    conn.close()


def _row_to_destination(row: sqlite3.Row) -> Destination:
    return Destination(**dict(row))


def get_all_destinations() -> list[Destination]:
    conn = get_connection()
    rows = conn.execute("SELECT * FROM destinations ORDER BY id").fetchall()
    conn.close()
    return [_row_to_destination(r) for r in rows]


def get_destination(destination_id: int) -> Destination | None:
    conn = get_connection()
    row = conn.execute("SELECT * FROM destinations WHERE id = ?", (destination_id,)).fetchone()
    conn.close()
    return _row_to_destination(row) if row else None


def create_destination(destination: Destination) -> Destination:
    conn = get_connection()
    cursor = conn.execute(
        "INSERT INTO destinations (name, emoji, tagline, climate, vibe, fun_fact) VALUES (?, ?, ?, ?, ?, ?)",
        (destination.name, destination.emoji, destination.tagline, destination.climate, destination.vibe, destination.fun_fact),
    )
    conn.commit()
    destination.id = cursor.lastrowid
    conn.close()
    return destination


def update_destination(destination_id: int, fields: dict) -> Destination | None:
    if not fields:
        return get_destination(destination_id)
    set_clause = ", ".join(f"{k} = ?" for k in fields)
    values = list(fields.values()) + [destination_id]
    conn = get_connection()
    conn.execute(f"UPDATE destinations SET {set_clause} WHERE id = ?", values)
    conn.commit()
    result = get_destination(destination_id)
    conn.close()
    return result
