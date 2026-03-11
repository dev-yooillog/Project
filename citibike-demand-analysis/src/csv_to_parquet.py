import pandas as pd
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent

csv_dir = BASE_DIR / "data" / "processed" / "citibike_csv"
parquet_dir = BASE_DIR / "data" / "processed" / "citibike_parquet"

parquet_dir.mkdir(parents=True, exist_ok=True)

for csv_file in csv_dir.glob("*.csv"):

    print(f"Processing {csv_file.name}")

    df = pd.read_csv(
        csv_file,
        low_memory=False
    )

    if "start_station_id" in df.columns:
        df["start_station_id"] = df["start_station_id"].astype(str)

    if "end_station_id" in df.columns:
        df["end_station_id"] = df["end_station_id"].astype(str)

    parquet_file = parquet_dir / csv_file.with_suffix(".parquet").name

    df.to_parquet(
        parquet_file,
        engine="pyarrow",
        compression="snappy"
    )

print("CSV → Parquet conversion complete")