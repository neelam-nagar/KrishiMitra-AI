from fastapi import FastAPI, HTTPException
from fetch_weather import get_weather_for_chatbot
import os

app = FastAPI()

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
json_path = os.path.join(BASE_DIR, "final_clean.json")

@app.get("/")
def home():
    return {"message": "Weather API running"}

@app.get("/weather")
def weather(district: str, tehsil: str, village: str):
    try:
        result = get_weather_for_chatbot(
            json_path,
            district,
            tehsil,
            village
        )

        if not result:
            raise HTTPException(status_code=404, detail="Location not found")

        return result

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))