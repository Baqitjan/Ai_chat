from fastapi import FastAPI, HTTPException
from fastapi.responses import StreamingResponse
from database import Base, engine
import requests
import json

Base.metadata.create_all(bind=engine)

app = FastAPI()

OLLAMA_URL = "http://localhost:11434/api/generate"
MODEL_NAME = "deepseek-coder:6.7b"


@app.post("/chat-stream")
def chat_stream(prompt: str):

    def generate():
        try:
            with requests.post(
                OLLAMA_URL,
                json={
                    "model": MODEL_NAME,
                    "prompt": prompt,
                    "stream": True
                },
                stream=True,
                timeout=300
            ) as r:

                if r.status_code != 200:
                    yield "ERROR\n"
                    return

                for line in r.iter_lines():
                    if not line:
                        continue

                    data = json.loads(line.decode("utf-8"))

                    if "response" in data:
                        yield data["response"]

                    if data.get("done", False):
                        break

        except Exception as e:
            yield f"\n[ERROR: {str(e)}]"

    return StreamingResponse(generate(), media_type="text/plain")


@app.get("/")
def root():
    return {"status": "Backend is working 🚀"}
