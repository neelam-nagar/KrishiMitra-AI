import json
import sys

def fill_missing_latlon(input_file, output_file):
    with open(input_file, "r") as f:
        data = json.load(f)

    for tehsil in data["tehsils"]:
        villages = tehsil["villages"]

        # ---------- FORWARD FILL ----------
        last_lat = None
        last_lon = None

        for v in villages:
            if v["lat"] is not None and v["lon"] is not None:
                last_lat = v["lat"]
                last_lon = v["lon"]
            else:
                if last_lat is not None:
                    v["lat"] = last_lat
                    v["lon"] = last_lon

        # ---------- BACKWARD FILL ----------
        next_lat = None
        next_lon = None

        for i in range(len(villages) - 1, -1, -1):
            v = villages[i]
            if v["lat"] is not None and v["lon"] is not None:
                next_lat = v["lat"]
                next_lon = v["lon"]
            else:
                if next_lat is not None:
                    v["lat"] = next_lat
                    v["lon"] = next_lon

    # Save final output
    with open(output_file, "w") as f:
        json.dump(data, f, indent=4)

    print(f"\n✔ Missing lat/lon filled successfully → {output_file}\n")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python fill_nearest_latlon.py input.json output.json")
    else:
        fill_missing_latlon(sys.argv[1], sys.argv[2])