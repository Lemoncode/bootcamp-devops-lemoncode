from pydantic import BaseModel


class Destination(BaseModel):
    id: int
    name: str
    emoji: str
    tagline: str
    climate: str
    vibe: str
    fun_fact: str = ""


class DestinationUpdate(BaseModel):
    name: str | None = None
    emoji: str | None = None
    tagline: str | None = None
    climate: str | None = None
    vibe: str | None = None
    fun_fact: str | None = None
