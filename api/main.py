from fastapi import FastAPI, HTTPException
from fastapi.responses import HTMLResponse, JSONResponse
from pydantic import BaseModel
from dotenv import load_dotenv
import mangum
import uvicorn
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

BUCKET_NAME = os.getenv("BUCKET_NAME")
AWS_REGION = os.getenv("REGION")

app = FastAPI()

class Body(BaseModel):
	text: str
	temperature: float = 0.5

load_dotenv()

@app.post("/predict")
async def question(body: Body):
	try:
		bucket_name = event["Records"][0]["s3"]["bucket"]["name"]
    	object_key = event["Records"][0]["s3"]["object"]["key"]
		predict = 10
		logger.info(f"Predicted value: {predict}")
	except Exception as e:
		raise HTTPException(status_code=500, detail=str(e))
	return JSONResponse({"result": predict})

handler = mangum.Mangum(app)

def lambda_handler(event, context):
    """AWS Lambda function handler."""
    return {"statusCode": 200, "body": json.dumps("Successful!")}


if __name__ == "__main__":
	uvicorn.run(app, host="0.0.0.0", port=8080)
