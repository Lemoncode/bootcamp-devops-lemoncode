from fastapi import APIRouter, HTTPException
from models import Destination, DestinationUpdate
import data

router = APIRouter(prefix="/api")


@router.get("/destinations", response_model=list[Destination])
def get_destinations():
    return data.get_all_destinations()


@router.get("/destinations/{destination_id}", response_model=Destination)
def get_destination(destination_id: int):
    dest = data.get_destination(destination_id)
    if not dest:
        raise HTTPException(status_code=404, detail="Destino no encontrado")
    return dest


@router.post("/destinations", response_model=Destination, status_code=201)
def create_destination(destination: Destination):
    return data.create_destination(destination)


@router.put("/destinations/{destination_id}", response_model=Destination)
def update_destination(destination_id: int, updates: DestinationUpdate):
    existing = data.get_destination(destination_id)
    if not existing:
        raise HTTPException(status_code=404, detail="Destino no encontrado")
    fields = updates.model_dump(exclude_unset=True)
    return data.update_destination(destination_id, fields)
