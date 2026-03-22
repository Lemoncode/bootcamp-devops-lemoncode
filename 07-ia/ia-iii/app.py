# app.py
# API de Stickers con FastAPI — aplicación de ejemplo para practicar con GitHub Copilot.
#
# Ejecutar:  python app.py
# API:       http://localhost:8000/docs
# Web:       http://localhost:8000

from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from pathlib import Path
import uvicorn

from routes import router

app = FastAPI(title="Sticker Pack API", version="1.0.0")

BASE_DIR = Path(__file__).resolve().parent

app.include_router(router)
app.mount("/", StaticFiles(directory=BASE_DIR / "static", html=True), name="static")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
