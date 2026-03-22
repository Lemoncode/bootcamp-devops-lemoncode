from pydantic import BaseModel


class Sticker(BaseModel):
    id: int
    name: str
    emoji: str
    category: str
    description: str = ""
