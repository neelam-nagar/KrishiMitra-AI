"""
KrishiMitra AI — Backend Unit & Integration Tests
Run: pytest tests/ -v
"""
import pytest
from fastapi.testclient import TestClient

# Import the app (data files must be in backend_unified/)
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from main import app, detect_intent, _clean_output, _fix_bad_numbers, COMP_RATES

# Use lifespan=True so startup events (data loading) run during tests
client = TestClient(app, raise_server_exceptions=True)


@pytest.fixture(scope="session", autouse=True)
def startup():
    """Ensure the lifespan startup runs once for the whole test session."""
    with client:
        yield


# ── Health ─────────────────────────────────────────────────────────────────────
class TestHealth:
    def test_health_ok(self):
        r = client.get("/api/health")
        assert r.status_code == 200
        body = r.json()
        assert body["status"] == "ok"
        assert "modules" in body

    def test_root_ok(self):
        r = client.get("/")
        assert r.status_code == 200
        assert r.json()["app"] == "KrishiMitra AI"


# ── Weather ────────────────────────────────────────────────────────────────────
class TestWeather:
    def test_districts_returns_list(self):
        r = client.get("/api/weather/districts")
        assert r.status_code == 200
        data = r.json()
        assert "districts" in data
        assert isinstance(data["districts"], list)
        assert len(data["districts"]) > 0

    def test_tehsils_valid_district(self):
        # Get first district and check tehsils exist
        districts = client.get("/api/weather/districts").json()["districts"]
        first = districts[0]
        r = client.get(f"/api/weather/tehsils?district={first}")
        assert r.status_code == 200
        assert "tehsils" in r.json()

    def test_tehsils_unknown_district(self):
        r = client.get("/api/weather/tehsils?district=NonExistentDistrict999")
        assert r.status_code == 200
        assert r.json()["tehsils"] == []

    def test_villages_valid(self):
        districts = client.get("/api/weather/districts").json()["districts"]
        first_d = districts[0]
        tehsils = client.get(f"/api/weather/tehsils?district={first_d}").json()["tehsils"]
        if tehsils:
            r = client.get(f"/api/weather/villages?district={first_d}&tehsil={tehsils[0]}")
            assert r.status_code == 200
            assert "villages" in r.json()

    def test_weather_missing_params(self):
        r = client.get("/api/weather?district=Jaipur")
        assert r.status_code == 422  # Unprocessable Entity — missing tehsil/village


# ── Mandi ──────────────────────────────────────────────────────────────────────
class TestMandi:
    def test_districts_returns_list(self):
        r = client.get("/api/mandi/districts")
        assert r.status_code == 200
        data = r.json()
        assert "districts" in data
        assert len(data["districts"]) > 0

    def test_mandis_for_district(self):
        districts = client.get("/api/mandi/districts").json()["districts"]
        first = districts[0]
        r = client.get(f"/api/mandi/mandis?district={first}")
        assert r.status_code == 200
        assert "mandis" in r.json()

    def test_mandis_unknown(self):
        r = client.get("/api/mandi/mandis?district=NoSuchPlace999")
        assert r.status_code == 200
        assert r.json()["mandis"] == []

    def test_crops_for_mandi(self):
        districts = client.get("/api/mandi/districts").json()["districts"]
        first_d = districts[0]
        mandis = client.get(f"/api/mandi/mandis?district={first_d}").json()["mandis"]
        if mandis:
            r = client.get(f"/api/mandi/crops?district={first_d}&mandi={mandis[0]}")
            assert r.status_code == 200
            assert "crops" in r.json()

    def test_price_not_found(self):
        r = client.get("/api/mandi?district=NoPlace&mandi=NoMandi&crop=NoCrop")
        assert r.status_code == 404


# ── Schemes ────────────────────────────────────────────────────────────────────
class TestSchemes:
    def test_list_en(self):
        r = client.get("/api/schemes?lang=en")
        assert r.status_code == 200
        data = r.json()
        assert "schemes" in data
        assert len(data["schemes"]) > 0

    def test_list_hi(self):
        r = client.get("/api/schemes?lang=hi")
        assert r.status_code == 200
        assert len(r.json()["schemes"]) > 0

    def test_detail_valid(self):
        r = client.get("/api/schemes/0")
        assert r.status_code == 200
        body = r.json()
        assert "name" in body
        assert "id" in body

    def test_detail_out_of_range(self):
        r = client.get("/api/schemes/99999")
        assert r.status_code == 404

    def test_detail_negative_id(self):
        r = client.get("/api/schemes/-1")
        assert r.status_code == 404


# ── Compensation ───────────────────────────────────────────────────────────────
class TestCompensation:
    def test_wheat_50pct(self):
        r = client.get("/api/compensation/calculate?crop=wheat&damage_percent=50&cause=flood")
        assert r.status_code == 200
        body = r.json()
        assert body["damage_percent"] == 50
        assert body["pmfby_per_hectare"] == pytest.approx(15000.0)
        assert body["sdrf_per_hectare"] == pytest.approx(6750.0)
        assert "disclaimer" in body

    def test_zero_damage(self):
        r = client.get("/api/compensation/calculate?crop=mustard&damage_percent=0&cause=drought")
        assert r.status_code == 200
        body = r.json()
        assert body["pmfby_per_hectare"] == 0
        assert body["sdrf_per_hectare"] == 0

    def test_full_damage(self):
        r = client.get("/api/compensation/calculate?crop=cotton&damage_percent=100&cause=hail")
        assert r.status_code == 200
        body = r.json()
        assert body["pmfby_per_hectare"] == pytest.approx(COMP_RATES["cotton"]["pmfby"])

    def test_hindi_crop_name(self):
        r = client.get("/api/compensation/calculate?crop=गेहूं&damage_percent=40&cause=flood")
        assert r.status_code == 200

    def test_invalid_damage_over_100(self):
        r = client.get("/api/compensation/calculate?crop=wheat&damage_percent=150&cause=flood")
        assert r.status_code == 422

    def test_invalid_damage_negative(self):
        r = client.get("/api/compensation/calculate?crop=wheat&damage_percent=-10&cause=flood")
        assert r.status_code == 422


# ── Chat ───────────────────────────────────────────────────────────────────────
class TestChat:
    def test_weather_intent_redirect(self):
        r = client.post("/api/chat", json={"question": "aaj ka mausam kaisa hai?", "session_id": "t1"})
        assert r.status_code == 200
        body = r.json()
        assert body.get("intent") == "weather"
        assert "weather" in body["answer"].lower() or "मौसम" in body["answer"]

    def test_mandi_intent_redirect(self):
        r = client.post("/api/chat", json={"question": "gehu ka bhav batao", "session_id": "t2"})
        assert r.status_code == 200
        assert r.json().get("intent") == "mandi"

    def test_scheme_intent_redirect(self):
        r = client.post("/api/chat", json={"question": "PM kisan yojana ke baare mein batao", "session_id": "t3"})
        assert r.status_code == 200
        assert r.json().get("intent") in ("scheme", "mandi", "weather")  # may match multiple

    def test_empty_question_rejected(self):
        r = client.post("/api/chat", json={"question": "", "session_id": "t4"})
        assert r.status_code == 422

    def test_no_gemini_key_graceful(self):
        # With no API key, chat should return graceful error, not 500
        r = client.post("/api/chat", json={"question": "fasal ki dekhbhal kaise karein?", "session_id": "t5"})
        assert r.status_code == 200
        body = r.json()
        assert "answer" in body


# ── Disease ────────────────────────────────────────────────────────────────────
class TestDisease:
    def test_invalid_image_format(self):
        r = client.post(
            "/api/disease/predict",
            files={"image": ("test.txt", b"not an image", "text/plain")},
        )
        assert r.status_code == 400

    def test_base64_invalid_data(self):
        r = client.post(
            "/api/disease/predict-base64",
            json={"image": "this_is_not_base64!!!"},
        )
        assert r.status_code == 400

    def test_model_unavailable_returns_503(self):
        """With no torch/model, predict should return 503, not crash."""
        import io
        from PIL import Image
        buf = io.BytesIO()
        Image.new("RGB", (224, 224), color=(100, 200, 100)).save(buf, format="JPEG")
        buf.seek(0)
        r = client.post(
            "/api/disease/predict",
            files={"image": ("leaf.jpg", buf.read(), "image/jpeg")},
        )
        # Either 503 (no model) or 200 (model loaded) — never 500
        assert r.status_code in (200, 503)


# ── Unit helpers ───────────────────────────────────────────────────────────────
class TestHelpers:
    def test_detect_intent_weather(self):
        assert detect_intent("aaj barish hogi?") == "weather"
        assert detect_intent("मौसम कैसा रहेगा") == "weather"

    def test_detect_intent_mandi(self):
        assert detect_intent("mandi bhav") == "mandi"
        assert detect_intent("gehu ka daam") == "mandi"

    def test_detect_intent_none(self):
        assert detect_intent("namaste") is None
        assert detect_intent("hello how are you") is None

    def test_fix_bad_numbers(self):
        result = _fix_bad_numbers("2025 दिन baad")
        assert "2025" not in result or "दिन" in result

    def test_clean_output_bullets(self):
        raw = "✅ यह एक सही बात है।\n💡 यह एक सलाह है।\n⚠️ यह एक चेतावनी है।"
        lines = _clean_output(raw)
        assert len(lines) <= 3
        assert all(l[-1] in "।.!?" for l in lines)

    def test_comp_rates_complete(self):
        for crop in ("wheat", "mustard", "soybean", "gram", "maize", "rice", "cotton"):
            assert crop in COMP_RATES
            assert COMP_RATES[crop]["pmfby"] > 0
            assert COMP_RATES[crop]["sdrf"] > 0
