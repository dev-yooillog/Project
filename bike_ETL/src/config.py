from pathlib import Path
import datetime

# 프로젝트 루트
BASE_DIR = Path(__file__).resolve().parents[1]
CSV_PATH = BASE_DIR / "data" / "서울특별시 공공자전거 대여이력 정보_2501.csv"

# ETL
CHUNK_SIZE = 100_000

# PostgreSQL 설정
DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "bike",
    "user": "postgres",
    "password": "1234"
}

RAW_TABLE = "raw_bike_rental"
CLEAN_TABLE = "clean_bike_rental"

CURRENT_YEAR = datetime.date.today().year