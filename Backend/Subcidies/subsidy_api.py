import json
import os
import sys
with open("scheme.json", "r", encoding="utf-8") as f:
    SCHEMES = json.load(f)

LANG = "en"  # "en" or "hi"



def header(text):
    text = str(text)
    line_len = 54
    print("╭" + "─" * line_len + "╮")
    print("│" + text.center(line_len) + "│")
    print("╰" + "─" * line_len + "╯")


def line():
    print("─" * 60)



def select_language():
    global LANG
    header("SELECT LANGUAGE / भाषा चुनें")
    print("  1. English")
    print("  2. हिन्दी")
    print("\n" + "─" * 60)
    choice = input("➡  Enter choice (1/2): ").strip()
    if choice == "2":
        LANG = "hi"
    else:
        LANG = "en"
    os.system("cls" if os.name == "nt" else "clear")


def t(obj, default=""):
    """
    Pick text for current language from dict like {"en": "...", "hi": "..."}.
    """
    if isinstance(obj, dict):
        return obj.get(LANG) or obj.get("en") or default
    return str(obj)


def show_scheme_list():
    if LANG == "hi":
        title = "कृषि एवं किसान योजनाएँ (राजस्थान)"
        prompt = "🔍 योजना नंबर, नाम या 0 (बाहर निकलने के लिए): "
    else:
        title = "FARMER SCHEMES (RAJASTHAN)"
        prompt = "🔍 Enter Scheme Number, Name or 0 to Exit: "

    header(title)

    for i, s in enumerate(SCHEMES, 1):
        print(f"  {i:02d}. {t(s['name'])}")

    # Exit option दिखाएँ
    print("\n  00. " + ("Exit / बाहर निकलें" if LANG == "hi" else "Exit"))

    print("\n" + "─" * 60)
    return input(prompt).strip()



def show_scheme_details(scheme):
    name = t(scheme["name"])
    header(name)

    # Labels based on language
    if LANG == "hi":
        lbl_type = "प्रकार"
        lbl_link = "लिंक"
        lbl_elig = "पात्रता"
        lbl_docs = "आवश्यक दस्तावेज़"
        lbl_apply = "आवेदन प्रक्रिया"
        back_msg = "👉 वापस जाने के लिए ENTER दबाएँ..."
    else:
        lbl_type = "Type"
        lbl_link = "Link"
        lbl_elig = "Eligibility"
        lbl_docs = "Required Documents"
        lbl_apply = "Apply Process"
        back_msg = "👉 Press ENTER to go back..."

    print(f"🏷  {lbl_type}: {scheme['type']}")
    print(f"🔗  {lbl_link}: {scheme['link']}")

    print(f"\n📍 {lbl_elig}:")
    # eligibility is dict {en,hi}
    elig_text = t(scheme["eligibility"])
    for e in str(elig_text).split("\n"):
        print(f"   • {e}")

    print(f"\n📄 {lbl_docs}:")
    # docs is list of dicts [{en,hi}, ...]
    for d in scheme["docs"]:
        print(f"   • {t(d)}")

    print(f"\n📝 {lbl_apply}:")
    apply_text = t(scheme["apply_process"])
    print(f"   {apply_text}")

    print("\n" + "─" * 60)
    input(back_msg)


# -----------------------------
# Main loop
# -----------------------------
def main():
    os.system("cls" if os.name == "nt" else "clear")

    # first choose language
    select_language()

    while True:
        choice = show_scheme_list()

        # exit by word
        if choice.lower() == "exit":
            msg = "THANK YOU ❤️" if LANG == "en" else "धन्यवाद ❤️"
            header(msg)
            break

        # exit by number 0
        if choice == "0":
            msg = "THANK YOU ❤️" if LANG == "en" else "धन्यवाद ❤️"
            header(msg)
            break

        # If number entered
        if choice.isdigit():
            idx = int(choice)
            if 1 <= idx <= len(SCHEMES):
                show_scheme_details(SCHEMES[idx - 1])
            else:
                print("❌ Invalid choice!\n" if LANG == "en" else "❌ गलत विकल्प!\n")
            continue

        # If name entered (partial match, both languages)
        found = None
        q = choice.lower()
        for s in SCHEMES:
            name_en = s["name"].get("en", "").lower()
            name_hi = s["name"].get("hi", "").lower()
            if q in name_en or q in name_hi:
                found = s
                break

        if found:
            show_scheme_details(found)
        else:
            print("❌ Scheme not found!\n" if LANG == "en" else "❌ योजना नहीं मिली!\n")


# Run app
if __name__ == "__main__":
    # Make sure stdout can handle UTF-8 in most terminals
    if os.name == "nt":
        try:
            import ctypes
            ctypes.windll.kernel32.SetConsoleOutputCP(65001)
        except Exception:
            pass

    main()
