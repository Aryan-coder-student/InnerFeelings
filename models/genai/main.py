from fastapi import FastAPI
from routers.generation import router as generation_router
app = FastAPI(title="Journal Media Generator API", version="1.0.0")
app.include_router(generation_router, prefix="/api")

@app.get("/health")
def health():
    return {"status": "ok"}
