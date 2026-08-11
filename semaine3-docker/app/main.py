from fastapi import FastAPI
import os, time

app = FastAPI()
start = time.time()

@app.get("/")
def root():
    return {"message": "Hello SRE", "uptime": time.time() - start}

@app.get("/health")
def health():
    return {"status": "ok"}

    