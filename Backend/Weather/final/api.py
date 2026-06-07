from fastapi import FastAPI
from fetch_weather import get_weather_for_chatbot

app = FastAPI()

@app.get("/")
def home():
    return {"message": "Weather API running"}

@app.get("/weather")
def weather(district: str, tehsil: str, village: str):
    try:
        result = get_weather_for_chatbot(
            "final_clean.json",
            district,
            tehsil,
            village
        )
        return result
    except Exception as e:
        return {
            "status": "error",
            "message": str(e)
        }