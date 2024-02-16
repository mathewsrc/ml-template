from fastapi import FastAPI, HTTPException
from fastapi.responses import HTMLResponse
from pydantic import BaseModel
import os
from dotenv import load_dotenv


app = FastAPI()


class Body(BaseModel):
	text: str
	temperature: float = 0.5


load_dotenv()


@app.get("/", response_class=HTMLResponse)
async def root():
	return HTMLResponse(
	"""
    <h1>Welcome to</p>
    """
	)


@app.post("/predict")
async def question(body: Body):
	try:
		print(body.text)
	except Exception as e:
		raise HTTPException(status_code=500, detail=str(e))
	return {"result": body.text}