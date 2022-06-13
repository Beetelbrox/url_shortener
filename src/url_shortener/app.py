from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, AnyHttpUrl
from fastapi.responses import RedirectResponse
from .utils import encode, decode

LENGTH = 4
HOST = "http://localhost:8000"

class URL(BaseModel):
    url: AnyHttpUrl

shortened_urls = {}
app = FastAPI()

def register_url(url: str) -> str:
    key = len(shortened_urls)
    shortened_urls[key] = url
    return f"{HOST}/{encode(key)}"

@app.get("/")
def root():
    return "Home page"

@app.get("/{path}")
def redirect_to(path: str):
    key = decode(path)
    if key not in shortened_urls:
        raise HTTPException(status_code=404, detail="Item not found")
    return RedirectResponse(shortened_urls[key])

@app.post("/", status_code=201)
def shorten_url(url: URL):
    shortened_url = register_url(url.url)
    return {"shortened_url": shortened_url}