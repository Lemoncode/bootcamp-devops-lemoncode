from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from pathlib import Path
import uvicorn

from routes import router
import data

app = FastAPI(title="Vacation Swipe API", version="1.0.0")

BASE_DIR = Path(__file__).resolve().parent

data.init_db()

app.include_router(router)
app.mount("/", StaticFiles(directory=BASE_DIR / "static", html=True), name="static")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
