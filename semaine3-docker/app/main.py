from fastapi import FastAPI
from prometheus_fastapi_instrumentator import Instrumentator
import os, time

app = FastAPI()
start = time.time()

Instrumentator().instrument(app).expose(app)

@app.get("/")
def root():
    return {"message": "Hello SRE", "uptime": time.time() - start}

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/crash")
def crash():
    return {"message": "endpoint used to crash, now fixed"}