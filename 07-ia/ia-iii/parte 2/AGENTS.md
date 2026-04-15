# AGENTS.md — Vacation Swipe

Guía para agentes de IA que trabajen en este repositorio.

## Qué es este proyecto

**Vacation Swipe** es un juego web de deslizar tarjetas (estilo Tinder) con destinos de vacaciones ficticios y humorísticos. El usuario hace swipe derecha (me gusta) o izquierda (no me gusta) en cada destino y al final ve su lista de favoritos.

## Stack

| Capa | Tecnología |
|---|---|
| Backend | FastAPI + Uvicorn |
| Base de datos | SQLite (sin ORM, módulo `sqlite3` nativo) |
| Frontend | Vanilla JS con Web Components (sin frameworks) |
| Modelos | Pydantic v2 |

## Estructura del proyecto

```
app.py              # Entry point de FastAPI; monta router y sirve estáticos
data.py             # Capa de datos SQLite (init_db, CRUD)
models.py           # Pydantic models: Destination, DestinationUpdate
routes.py           # APIRouter con prefijo /api: GET/POST/PUT /destinations
requirements.txt    # fastapi, uvicorn
static/
  index.html        # SPA principal
  styles.css        # Estilos globales
  components/
    destination-card.js   # Web Component <destination-card>
    vacation-game.js      # Web Component <vacation-game> (lógica principal)
```

La base de datos `destinations.db` se genera automáticamente en la raíz al arrancar.

## Cómo ejecutar

```bash
pip install -r requirements.txt
python app.py          # escucha en http://localhost:8000
```

## API

| Método | Ruta | Descripción |
|---|---|---|
| GET | `/api/destinations` | Lista todos los destinos |
| GET | `/api/destinations/{id}` | Obtiene un destino por ID |
| POST | `/api/destinations` | Crea un nuevo destino |
| PUT | `/api/destinations/{id}` | Actualiza campos de un destino |

### Modelo `Destination`

```json
{
  "id": 1,
  "name": "Isla del WiFi Gratis",
  "emoji": "🏝️",
  "tagline": "Donde siempre hay 5 barras",
  "climate": "tropical",
  "vibe": "relax",
  "fun_fact": "El router está alimentado por cocos"
}
```

Valores usados en `climate`: `tropical`, `templado`, `mediterráneo`, `urbano`, `extremo`, `polar`, `árido`.  
Valores usados en `vibe`: `relax`, `aventura`, `fiesta`.

## Skills disponibles

Lee el archivo de skill correspondiente antes de trabajar en esa área.

| Skill | Cuándo usarlo | Archivo |
|---|---|---|
| Accessibility (a11y) | "mejorar accesibilidad", "WCAG", "soporte lector de pantalla", "navegación por teclado" | `.agents/skills/accessibility/SKILL.md` |
| FastAPI Templates | Crear nuevos endpoints, patrones async, inyección de dependencias | `.agents/skills/fastapi-templates/SKILL.md` |
| Frontend Design | Mejorar UI, rediseñar componentes, estilizar páginas | `.agents/skills/frontend-design/SKILL.md` |
| Python Testing | Escribir tests con pytest, fixtures, mocking | `.agents/skills/python-testing-patterns/SKILL.md` |
| SEO | Meta tags, structured data, Open Graph, sitemap | `.agents/skills/seo/SKILL.md` |

## Convenciones

- **Sin DELETE endpoint**: la API no expone borrado de destinos por diseño.
- **Frontend sin bundler**: los Web Components se cargan como ES modules clásicos con `<script src>`. No hay npm, webpack, ni build step.
- **SQLite directo**: no usar SQLAlchemy ni ningún ORM. Mantener el patrón de `get_connection()` en `data.py`.
- **Seed data en `data.py`**: los destinos iniciales están en la constante `SEED_DATA` y se insertan solo si la tabla está vacía.
- **Idioma del contenido**: los destinos son en español con tono humorístico (guiños a la cultura dev).
