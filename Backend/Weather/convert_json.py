import json
import sys

def convert(input_file, output_file="converted.json"):
    with open(input_file, "r") as f:
        data = json.load(f)

    district_name = data["district"]
    tehsils = data["tehsils"]

    cleaned_tehsils = []

    for tehsil_obj in tehsils:
        tehsil_name = tehsil_obj["tehsil"]
        village_list = tehsil_obj["villages"]

        cleaned_villages = []

        for v in village_list:

            # if village is string → convert into {village: name, lat: None}
            if isinstance(v, str):
                cleaned_villages.append({
                    "village": v,
                    "lat": None,
                    "lon": None
                })

            # if already in correct format
            elif isinstance(v, dict):
                name = v.get("village")
                lat = v.get("lat")
                lon = v.get("lon")

                cleaned_villages.append({
                    "village": name,
                    "lat": lat,
                    "lon": lon
                })

        cleaned_tehsils.append({
            "tehsil": tehsil_name,
            "villages": cleaned_villages
        })

    final_output = {
        "district": district_name,
        "tehsils": cleaned_tehsils
    }

    with open(output_file, "w") as f:
        json.dump(final_output, f, indent=4)

    print(f"✔ Clean JSON saved in: {output_file}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python convert_json.py <input.json> [output.json]")
    else:
        outfile = sys.argv[2] if len(sys.argv) == 3 else "converted.json"
        convert(sys.argv[1], outfile)