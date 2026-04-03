from fastapi import FastAPI, HTTPException
from fetch_weather import get_weather_for_chatbot
import os
import json

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

@app.get("/districts")
def get_districts():
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    return [d["district"] for d in data["districts"]]


@app.get("/tehsils")
def get_tehsils(district: str):
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    district_data = next((d for d in data["districts"] if d["district"].lower() == district.lower()), None)
    if not district_data:
        return []

    return [t["tehsil"] for t in district_data["tehsils"]]


@app.get("/villages")
def get_villages(district: str, tehsil: str):
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    district_data = next((d for d in data["districts"] if d["district"].lower() == district.lower()), None)
    if not district_data:
        return []

    tehsil_data = next((t for t in district_data["tehsils"] if t["tehsil"].lower() == tehsil.lower()), None)
    if not tehsil_data:
        return []

    return [v["village"] for v in tehsil_data["villages"]]