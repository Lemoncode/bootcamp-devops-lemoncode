import os
import json
from pathlib import Path

import httpx
from dotenv import load_dotenv
from openai import OpenAI
from rich.console import Console

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


def get_embeddings(texts: list[str], embedding_model: str) -> list[list[float]]:
    # 🔢 Pedimos al proveedor los embeddings del texto.
    response = client.embeddings.create(model=embedding_model, input=texts)
    return [item.embedding for item in response.data]


def rebuild_recipe_index(http_client: httpx.Client, recipes: list[dict]) -> None:
    # 1️⃣ Generamos los embeddings y rellenamos la base de datos vectorial.
    with console.status(
        "[bold green]Preparando el modelo de embeddings...", spinner="dots"
    ):
        embedding_model = LLM_MODEL_EMBEDDINGS

    with console.status("[bold green]Indexando recetas en Qdrant...", spinner="dots"):
        index_recipes(http_client, embedding_model, recipes)

    console.print("✅ Indice de recetas recreado correctamente.")
    console.print(
        "➡️ Ahora puedes ejecutar 04_bonus_rag_chat.py para hacer preguntas.\n"
    )


def main() -> None:
    recipes = load_recipes()

    console.print(f"🔌 Proveedor: {LLM_PROVIDER}")
    console.print(f"🔍 Endpoint LLM: {LLM_ENDPOINT}")
    console.print(f"🧠 Modelo LLM: {LLM_MODEL}")
    console.print(f"📦 Qdrant: {QDRANT_URL}")
    console.print(f"🧬 Modelo de embeddings: {LLM_MODEL_EMBEDDINGS}")
    console.print(f"📚 Recetas cargadas: {len(recipes)}")

    with httpx.Client(timeout=30.0) as http_client:
        rebuild_recipe_index(http_client, recipes)


if __name__ == "__main__":
    main()
