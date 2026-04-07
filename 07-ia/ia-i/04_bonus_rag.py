import os
import json
from pathlib import Path

import httpx
from dotenv import load_dotenv
from openai import OpenAI
from rich.console import Console
from rich.markdown import Markdown
from rich.table import Table

load_dotenv()

console = Console()

# ⚙️ Configuracion del proveedor LLM y del modelo de embeddings.
LLM_PROVIDER = os.getenv("LLM_PROVIDER", "ollama")
LLM_MODEL = os.getenv("LLM_MODEL")
LLM_ENDPOINT = os.getenv("LLM_ENDPOINT")
LLM_API_KEY = os.getenv("LLM_API_KEY")
LLM_MODEL_EMBEDDINGS = os.getenv(
    "LLM_MODEL_EMBEDDINGS", "openai/text-embedding-3-large"
)

QDRANT_URL = os.getenv("QDRANT_URL", "http://localhost:6333")
COLLECTION_NAME = "recetas_abuela_zoe"
TOP_K = 2
RECIPES_PATH = Path(__file__).with_name("recetas_abuela_zoe.json")

client = OpenAI(base_url=LLM_ENDPOINT, api_key=LLM_API_KEY)


def load_recipes() -> list[dict]:
    # 📚 Cargamos las recetas desde un JSON externo para separar datos y codigo.
    with RECIPES_PATH.open(encoding="utf-8") as recipes_file:
        return json.load(recipes_file)


def index_recipes(
    http_client: httpx.Client,
    embedding_model: str,
    recipes: list[dict],
) -> None:
    # 🧬 Convertimos cada receta a embedding para poder buscar por significado.
    recipe_texts = [recipe["text"] for recipe in recipes]
    recipe_vectors = get_embeddings(recipe_texts, embedding_model)

    # 🗂️ Creamos de nuevo la coleccion para partir siempre de un estado limpio.
    http_client.delete(f"{QDRANT_URL}/collections/{COLLECTION_NAME}")
    http_client.put(
        f"{QDRANT_URL}/collections/{COLLECTION_NAME}",
        json={"vectors": {"size": len(recipe_vectors[0]), "distance": "Cosine"}},
    ).raise_for_status()

    points = []
    for recipe, vector in zip(recipes, recipe_vectors):
        points.append(
            {
                "id": recipe["id"],
                "vector": vector,
                "payload": {
                    "title": recipe["title"],
                    "text": recipe["text"],
                },
            }
        )

    upsert_response = http_client.put(
        f"{QDRANT_URL}/collections/{COLLECTION_NAME}/points",
        json={"points": points},
    )
    upsert_response.raise_for_status()


def search_recipes(
    http_client: httpx.Client,
    embedding_model: str,
    user_question: str,
):
    # 🔎 Convertimos la pregunta del usuario a embedding y buscamos similitud en Qdrant.
    query_vector = get_embeddings([user_question], embedding_model)[0]

    response = http_client.post(
        f"{QDRANT_URL}/collections/{COLLECTION_NAME}/points/search",
        json={
            "vector": query_vector,
            "limit": TOP_K,
            "with_payload": True,
        },
    )
    response.raise_for_status()
    return response.json()["result"]


def print_matches(matches) -> None:
    # 📋 Mostramos las recetas que ha recuperado la busqueda semantica.
    table = Table(title="Recetas recuperadas desde Qdrant")
    table.add_column("Receta")
    table.add_column("Score")

    for match in matches:
        table.add_row(match["payload"]["title"], f"{match['score']:.4f}")

    console.print(table)


def build_context(matches) -> str:
    # 🧱 Construimos el contexto que luego enviaremos al LLM.
    chunks = []
    for match in matches:
        payload = match["payload"]
        chunks.append(f"Receta: {payload['title']}\n{payload['text']}")
    return "\n\n".join(chunks)


def ask_llm_with_context(user_question: str, context: str) -> str:
    # 🤖 El modelo responde usando solo las recetas recuperadas como contexto.
    response = client.chat.completions.create(
        model=LLM_MODEL,
        messages=[
            {
                "role": "system",
                "content": (
                    "Eres un ayudante de cocina. Responde solo con la informacion de las recetas "
                    "recuperadas. Si falta informacion, dilo claramente."
                ),
            },
            {
                "role": "user",
                "content": (
                    f"Contexto recuperado:\n\n{context}\n\n"
                    f"Pregunta del usuario: {user_question}"
                ),
            },
        ],
    )
    return response.choices[0].message.content


def get_embeddings(texts: list[str], embedding_model: str) -> list[list[float]]:
    # 🔢 Pedimos al proveedor los embeddings del texto.
    response = client.embeddings.create(model=embedding_model, input=texts)
    return [item.embedding for item in response.data]


def main() -> None:
    # ❓ Esta es la pregunta que haremos sobre nuestras recetas.
    user_question = "Quiero una receta tradicional para comer de plato principal. Cual me recomiendas y por que?"
    recipes = load_recipes()

    console.print(f"🔌 Proveedor: {LLM_PROVIDER}")
    console.print(f"🔍 Endpoint LLM: {LLM_ENDPOINT}")
    console.print(f"🧠 Modelo LLM: {LLM_MODEL}")
    console.print(f"📦 Qdrant: {QDRANT_URL}")
    console.print(f"🧬 Modelo de embeddings: {LLM_MODEL_EMBEDDINGS}")
    console.print(f"📚 Recetas cargadas: {len(recipes)}")

    with httpx.Client(timeout=30.0) as http_client:
        with console.status(
            "[bold green]Generando embeddings de las recetas...", spinner="dots"
        ):
            embedding_model = LLM_MODEL_EMBEDDINGS

        with console.status(
            "[bold green]Indexando recetas en Qdrant...", spinner="dots"
        ):
            index_recipes(http_client, embedding_model, recipes)

        with console.status(
            "[bold green]Buscando recetas relevantes...", spinner="dots"
        ):
            matches = search_recipes(http_client, embedding_model, user_question)

    print_matches(matches)
    context = build_context(matches)

    with console.status(
        "[bold green]Generando respuesta con el LLM...", spinner="dots"
    ):
        answer = ask_llm_with_context(user_question, context)

    console.print(Markdown(f"## Pregunta\n\n{user_question}"))
    console.print(Markdown(f"## Respuesta\n\n{answer}"))


if __name__ == "__main__":
    main()
