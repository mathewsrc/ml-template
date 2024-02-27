from fastapi import FastAPI, HTTPException
from fastapi.responses import HTMLResponse, JSONResponse
from pydantic import BaseModel
from dotenv import load_dotenv
import mangum
import uvicorn
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI()


class Body(BaseModel):
	price: int
	temperature: int = 2


load_dotenv()


@app.post("/predict")
async def question(body: Body):
	try:
		predict = body.price * body.temperature
		logger.info(f"Predicted value: {predict}")
	except Exception as e:
		raise HTTPException(status_code=500, detail=str(e))
	return JSONResponse({"result": predict})


handler = mangum.Mangum(app)


if __name__ == "__main__":
	uvicorn.run(app, host="0.0.0.0", port=8080)
