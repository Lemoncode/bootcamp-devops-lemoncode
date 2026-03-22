from fastapi import APIRouter, HTTPException
from models import Sticker
import data

router = APIRouter(prefix="/api")


@router.get("/stickers", response_model=list[Sticker])
def get_stickers():
    """Devuelve todos los stickers."""
    return list(data.stickers_db.values())


@router.get("/stickers/{sticker_id}", response_model=Sticker)
def get_sticker(sticker_id: int):
    """Devuelve un sticker por su ID."""
    if sticker_id not in data.stickers_db:
        raise HTTPException(status_code=404, detail="Sticker no encontrado")
    return data.stickers_db[sticker_id]


@router.post("/stickers", response_model=Sticker, status_code=201)
def create_sticker(sticker: Sticker):
    """Crea un nuevo sticker."""
    sticker.id = data.next_id
    data.stickers_db[data.next_id] = sticker
    data.next_id += 1
    return sticker
