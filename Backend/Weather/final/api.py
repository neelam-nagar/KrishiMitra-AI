from fastapi import FastAPI
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
        return get_weather_for_chatbot(
            json_path,
            district,
            tehsil,
            village
        )
    except Exception as e:
        return {"error": str(e)}