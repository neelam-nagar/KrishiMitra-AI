import json
import requests
import time
import sys
import os


def get_lat_lon(village, tehsil, district):
    query = f"{village}, {tehsil}, {district}, Rajasthan, India"
    print(f"Fetching: {query}")

    url = f"https://nominatim.openstreetmap.org/search?format=json&q={query}"
    headers = {"User-Agent": "Mozilla/5.0"}

    try:
        r = requests.get(url, headers=headers, timeout=10)
        data = r.json()
    except:
        return None, None

    if not data:
        return None, None

    return data[0].get("lat"), data[0].get("lon")


def save_progress(output_file, final_output):
    """Writes progress to output file safely."""
    temp_file = output_file + ".tmp"

    with open(temp_file, "w", encoding="utf-8") as temp:
        json.dump(final_output, temp, indent=4, ensure_ascii=False)

    os.replace(temp_file, output_file)  # atomic save (no corruption)


def main(input_file):

    with open(input_file, "r", encoding="utf-8") as f:
        data = json.load(f)

    district_name = data["district"]
    tehsils = data["tehsils"]

    output_file = "jhalawar_latlon.json"

    # If file exists (resuming), load it
    if os.path.exists(output_file):
        print("✔ Resuming previous progress...")
        with open(output_file, "r", encoding="utf-8") as f:
            final_output = json.load(f)
    else:
        final_output = {
            "district": district_name,
            "tehsils": []
        }

    print(f"Total tehsils: {len(tehsils)}")

    # Process tehsils
    for tehsil_obj in tehsils:
        tehsil_name = tehsil_obj["tehsil"]
        villages = tehsil_obj["villages"]

        # Check if this tehsil is already processed
        existing_tehsil = next((t for t in final_output["tehsils"] if t["tehsil"] == tehsil_name), None)

        if existing_tehsil:
            print(f"\n⏭ Skipping {tehsil_name} (already completed)")
            continue

        print(f"\n➡ Processing tehsil: {tehsil_name} ({len(villages)} villages)\n")

        updated_villages = []

        # Loop through villages
        for v in villages:
            if isinstance(v, dict):
                village_name = v.get("village")
            else:
                village_name = v  # string

            lat, lon = get_lat_lon(village_name, tehsil_name, district_name)

            updated_villages.append({
                "village": village_name,
                "lat": lat,
                "lon": lon
            })

            # 🔥 Auto-save after every village
            temp_output = final_output.copy()
            temp_output_tehsils = temp_output["tehsils"].copy()
            temp_output["tehsils"] = temp_output_tehsils

            temp_output["tehsils"].append({
                "tehsil": tehsil_name,
                "villages": updated_villages
            })

            save_progress(output_file, temp_output)

            print(f"✔ Saved progress for {village_name}")

            time.sleep(1)

        # After completing full tehsil, update final data
        final_output["tehsils"].append({
            "tehsil": tehsil_name,
            "villages": updated_villages
        })

        save_progress(output_file, final_output)

    print(f"\n🎉 All data saved successfully in {output_file}\n")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python jhalawar_lat_lon.py <input.json>")
    else:
        main(sys.argv[1])