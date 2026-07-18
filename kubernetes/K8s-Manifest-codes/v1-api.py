import os
from fastapi import FastAPI

app = FastAPI(title="Env Reader")

# List the env vars you want to expose
ENV_KEYS = [
    "NAME",
    "DATABASE_PASSWORD",
    "DATABASE_USER",
    "DATABASE_HOST",
]


@app.get("/")
def root():
    return {"status": "alive"}


@app.get("/health")
def health():
    return {"status": "healthy"}


@app.get("/env")
def read_env():
    return {
        key: os.getenv(key)
        for key in ENV_KEYS
    }