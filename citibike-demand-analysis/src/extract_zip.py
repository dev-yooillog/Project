import zipfile
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent

zip_dir = BASE_DIR / "data" / "raw" / "citibike_zip"
csv_dir = BASE_DIR / "data" / "processed" / "citibike_csv"

csv_dir.mkdir(parents=True, exist_ok=True)

for zip_file in zip_dir.glob("*.zip"):
    
    with zipfile.ZipFile(zip_file, 'r') as zip_ref:
        zip_ref.extractall(csv_dir)

print("ZIP → CSV extraction complete")