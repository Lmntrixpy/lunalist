import os

def count_lines_in_directory(directory):
    total_lines = 0

    for root, dirs, files in os.walk(directory):
        for file in files:
            file_path = os.path.join(root, file)

            try:
                with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
                    total_lines += sum(1 for _ in f)
            except Exception as e:
                print(f"Übersprungen (Fehler bei Datei): {file_path}")

    return total_lines


if __name__ == "__main__":
    folder_path = input("Pfad zum Ordner: ")
    total = count_lines_in_directory(folder_path)
    print(f"Gesamtanzahl der Zeilen: {total}")