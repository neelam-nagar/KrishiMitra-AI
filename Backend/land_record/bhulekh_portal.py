import webbrowser
import os

LANG = "en"  # "en" or "hi"


def header(text):
    text = str(text)
    line_len = 40
    print("\n" + "╭" + "─" * line_len + "╮")
    print("│" + text.center(line_len) + "│")
    print("╰" + "─" * line_len + "╯\n")


def select_language():
    global LANG
    header("SELECT LANGUAGE / भाषा चुनें")
    print("  1. English")
    print("  2. हिन्दी")
    print("\n" + "─" * 40)
    choice = input("➡  Enter choice (1/2): ").strip()
    LANG = "hi" if choice == "2" else "en"
    os.system("cls" if os.name == "nt" else "clear")


def main():
    select_language()

    if LANG == "hi":
        header("राजस्थान भूलेख (अपना खाता)")
        question = "क्या आप अपनी जमीन का भुलेख देखना चाहते हैं? (y/n): "
        opening = "\n👉 कृपया प्रतीक्षा करें, Rajasthan Bhulekh खुल रहा है...\n"
        success = "✔ भुलेख पोर्टल आपके ब्राउज़र में खुल गया है।"
        no_open = "❌ ब्राउज़र नहीं खुल पाया, कृपया URL को कॉपी करके ब्राउज़र में खोलें:"
        decline = "\nठीक है, आपने अभी भुलेख नहीं देखने का चयन किया।"
        invalid = "\n❌ अमान्य इनपुट! कृपया केवल y या n दबाएँ।"
    else:
        header("Rajasthan Bhulekh (Apna Khata)")
        question = "Do you want to view your land record (Bhulekh)? (y/n): "
        opening = "\n👉 Please wait, opening Rajasthan Bhulekh in your browser...\n"
        success = "✔ Bhulekh portal has been opened in your browser."
        no_open = "❌ Could not open browser, please copy this URL and open manually:"
        decline = "\nOkay, you chose not to open Bhulekh."
        invalid = "\n❌ Invalid input! Please press only y or n."

    url = "https://apnakhata.rajasthan.gov.in/"
    choice = input(question).strip().lower()

    if choice in ("y", "yes", "ha", "haan", "h"):
        print(opening)
        opened = webbrowser.open(url)
        if opened:
            print(success)
        else:
            print(no_open)
            print("   ", url)
    elif choice in ("n", "no", "na", "nah"):
        print(decline)
    else:
        print(invalid)


if __name__ == "__main__":
    main()
