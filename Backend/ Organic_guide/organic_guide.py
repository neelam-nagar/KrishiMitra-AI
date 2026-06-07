import os
import json

# ================= BASE PATH =================
BASE_PATH = os.path.join(os.path.dirname(__file__), "data")

# ================= UTILITY =================
def load_json(path):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)

def pause():
    input("\nPress ENTER to continue...")

# ================= LANGUAGE =================
def choose_language():
    print("\nChoose Language / भाषा चुनें")
    print("1. हिन्दी")
    print("2. English")
    return "hi" if input("Enter choice: ") == "1" else "en"

# ================= AWARENESS =================
def show_awareness(lang):
    file_path = os.path.join(BASE_PATH, "language", f"organic_awareness_{lang}.json")
    data = load_json(file_path)

    print(f"\n🌱 {data.get('title','Organic Awareness')}\n")
    print(data.get("intro",""))

    print("\nTopics:")
    for t in data.get("sections", []):
        print("•", t)

    pause()

# ================= REGION SELECTION =================
def choose_region(lang):
    regions = [
        ("eastern_rajasthan", "पूर्वी राजस्थान", "Eastern Rajasthan"),
        ("hadoti_region", "हाड़ौती", "Hadoti"),
        ("western_rajasthan", "पश्चिमी राजस्थान", "Western Rajasthan"),
        ("shekhawati_region", "शेखावाटी", "Shekhawati"),
        ("southern_rajasthan", "दक्षिणी राजस्थान", "Southern Rajasthan")
    ]

    print("\nअपना क्षेत्र चुनें / Choose Region\n")
    for i, r in enumerate(regions, 1):
        print(f"{i}. {r[1] if lang=='hi' else r[2]}")

    idx = int(input("Enter number: ")) - 1
    return regions[idx][0].strip()

# ================= REGION MENU =================
def region_menu(region_data, lang):
    while True:
        print("\n🌾", region_data["area"][lang])

        print("1. Soil & Climate")
        print("2. Water Management")
        print("3. Crop Selection")
        print("4. Crop Guide")
        print("5. Monthly Work")
        print("6. District Info")
        print("7. Back")

        choice = input("Choose option: ")

        # -------- SOIL --------
        if choice == "1":
            soil = region_data.get("soil_profile", {})

            print("\n🌱", "मिट्टी और मौसम" if lang=="hi" else "Soil & Climate")

            print("\n🔸", "प्रमुख मिट्टी के प्रकार:" if lang=="hi" else "Major Soil Types:")
            for s in soil.get("major_soil_types", {}).get(lang, []):
                print("•", s)

            print("\n🔸", "मिट्टी की विशेषताएँ:" if lang=="hi" else "Soil Properties:")
            for s in soil.get("soil_properties", {}).get(lang, []):
                print("•", s)

            print("\n🔸", "मिट्टी से जुड़ी समस्याएँ:" if lang=="hi" else "Soil Related Problems:")
            for s in soil.get("soil_related_problems", {}).get(lang, []):
                print("•", s)

            pause()

        # -------- WATER --------
        elif choice == "2":
            water = region_data.get("water_resources", {})

            print("\n💧", "पानी और सिंचाई" if lang=="hi" else "Water Management")

            print("\n🔸", "पानी के स्रोत:" if lang=="hi" else "Water Sources:")
            for w in water.get("sources", {}).get(lang, []):
                print("•", w)

            print("\n🔸", "उपलब्धता:" if lang=="hi" else "Availability:")
            print("•", water.get("water_availability", {}).get(lang, ""))

            print("\n🔸", "जैविक सिंचाई सुझाव:" if lang=="hi" else "Organic Water Guidelines:")
            for g in water.get("organic_water_management_guidelines", {}).get(lang, []):
                print("•", g)

            pause()

        # -------- CROPS --------
        elif choice == "3":
            crops = region_data.get("major_crops_overview", {})

            print("\n🌾", "फसल चयन" if lang=="hi" else "Crop Selection")

            print("\n🔸", "खरीफ फसलें:" if lang=="hi" else "Kharif Crops:")
            for c in crops.get("kharif_crops", {}).get(lang, []):
                print("•", c)

            print("\n🔸", "रबी फसलें:" if lang=="hi" else "Rabi Crops:")
            for c in crops.get("rabi_crops", {}).get(lang, []):
                print("•", c)

            pause()

        # -------- CROP GUIDE --------
        elif choice == "4":
            print("\n📘", "उपलब्ध फसल गाइड:" if lang=="hi" else "Available Crop Guides:")
            for c in region_data.get("crop_wise_detailed_guidance", {}).keys():
                print("•", c)
            pause()

        # -------- MONTHLY (FIXED) --------
        elif choice == "5":
            calendar = region_data.get("month_wise_farming_calendar", {})

            print("\n📅", "महीना अनुसार कार्य" if lang=="hi" else "Monthly Farming Calendar")

            for month, info in calendar.items():
                print(f"\n📌 {month}")
                for task in info.get(lang, []):
                    print("•", task)

            pause()

        # -------- DISTRICT --------
        elif choice == "6":
            districts = region_data.get("district_specific_notes", {})

            print("\n🏘️", "जिला अनुसार जानकारी" if lang=="hi" else "District-wise Information")

            for district, info in districts.items():
                print(f"\n📍 {district}")
                for line in info.get(lang, []):
                    print("•", line)

            pause()

        elif choice == "7":
            break

# ================= MAIN =================
def main():
    lang = choose_language()

    print("\n1. जैविक खेती जागरूकता पढ़ें" if lang=="hi" else "\n1. Read Organic Awareness")
    print("2. सीधे आगे बढ़ें" if lang=="hi" else "2. Skip")

    if input("Enter choice: ") == "1":
        show_awareness(lang)

    region_key = choose_region(lang)
    region_file = os.path.join(BASE_PATH, "regions", f"{region_key}.json")

    if not os.path.isfile(region_file):
        print("\n❌ Region file not found:")
        print(region_file)
        return

    region_data = load_json(region_file)
    region_menu(region_data, lang)

# ================= RUN =================
if __name__ == "__main__":
    main()