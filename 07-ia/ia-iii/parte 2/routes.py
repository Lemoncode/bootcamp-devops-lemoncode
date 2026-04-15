from fastapi import APIRouter
from models import Destination, DestinationUpdate
import data

router = APIRouter(prefix="/api")


@router.get("/destinations")
def get_destinations():
    return data.get_all_destinations()


@router.get("/destinations/{destination_id}")
def get_destination(destination_id: int):
    dest = data.get_destination(destination_id)

    return dest


@router.post("/destinations")
def create_destination(destination: Destination):
    return data.create_destination(destination)


@router.put("/destinations/{destination_id}")
def update_destination(destination_id: int, updates: DestinationUpdate):
    fields = updates.model_dump(exclude_unset=True)
    return data.update_destination(destination_id, fields)
