import sys
from pathlib import Path
import pandas as pd
sys.path.append(str(Path(__file__).resolve().parent))

from extract import extract_csv
from transform import transform, COLUMN_NAMES
from load import insert_dataframe
from config import RAW_TABLE, CLEAN_TABLE, CURRENT_YEAR


def main():
    print("따릉이 ETL 시작")

    for i, chunk in enumerate(extract_csv(), start=1):
        print(f"Chunk {i} 처리")

        chunk.columns = COLUMN_NAMES 

        # 정수 컬럼 변환
        int_cols = {
            "usage_minutes":      (0, 1440),
            "rental_station_no":  (0, 99999),
            "return_station_no":  (0, 99999),
            "rental_dock":        (0, 50),
            "return_dock":        (0, 50),
            "birth_year":         (1900, CURRENT_YEAR), 
        }

        for col, (lo, hi) in int_cols.items():
            chunk[col] = (
                pd.to_numeric(chunk[col], errors="coerce")
                .clip(lower=lo, upper=hi)
                .fillna(0)
                .astype(int)
            )

        # float 컬럼 변환
        chunk["usage_distance"] = (
            pd.to_numeric(chunk["usage_distance"], errors="coerce")
            .clip(lower=0.0, upper=200_000.0)
            .fillna(0.0)
        )
        # RAW 적재
        insert_dataframe(chunk, RAW_TABLE)

        # CLEAN 적재
        clean_df = transform(chunk)
        insert_dataframe(clean_df, CLEAN_TABLE)

    print("ETL DONE")

if __name__ == "__main__":
    main()