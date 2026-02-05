#%% 
import pandas as pd
import sqlite3
from pathlib import Path
from sqlalchemy import create_engine
from sqlalchemy import text
import numpy as np

#%%
PROJECT_ROOT = Path(__file__).parent.parent
DATA_DIR = PROJECT_ROOT / "data/raw"
PROCESSED_DIR = PROJECT_ROOT / "data/processed"
PROCESSED_DIR.mkdir(parents=True, exist_ok=True)

files = [
    DATA_DIR / "서울특별시 공공자전거 이용정보(월별)_23.1-6.csv",
    DATA_DIR / "서울특별시 공공자전거 이용정보(월별)_23.7-12.csv",
    DATA_DIR / "서울특별시 공공자전거 이용정보(월별)_24.1-6.csv",
    DATA_DIR / "서울특별시 공공자전거 이용정보(월별)_24.7-12.csv",
    DATA_DIR / "서울특별시 공공자전거 이용정보(월별)_25.1-6.csv"
]

#%% 
dfs = [pd.read_csv(f, encoding='cp949') for f in files]
bike_df = pd.concat(dfs, ignore_index=True)

#%% 4. 컬럼명 정리 
bike_df = bike_df.rename(columns={
    '대여년월':'rental_ym',
    '대여소번호':'station_id',
    '대여소명':'station_name',
    '대여구분코드':'rental_type',
    '성별':'gender',
    '연령대코드':'age_group',
    '이용건수':'ride_count',
    '운동량':'exercise',
    '탄소량':'co2',
    '이동거리(M)':'distance_m',
    '이용시간(분)':'duration_min'
})

#%% 5. 결측치 처리 및 타입 변환
bike_df.replace('\\N', np.nan, inplace=True)

int_cols = ['station_id', 'ride_count']
float_cols = ['exercise', 'co2', 'distance_m', 'duration_min']

bike_df[int_cols] = bike_df[int_cols].fillna(0).astype(int)
bike_df[float_cols] = bike_df[float_cols].fillna(0.0).astype(float)

#%% 6. CSV 저장
processed_csv = PROCESSED_DIR / "bike_usage.csv"
bike_df.to_csv(processed_csv, index=False, encoding='utf-8-sig')

#%% 7. SQLite DB 적재
sqlite_db = PROCESSED_DIR / "bike_usage.db"
conn = sqlite3.connect(sqlite_db)
bike_df.to_sql('bike_usage', conn, if_exists='replace', index=False)
conn.close()
print(f"SQLite 적재 완료: {sqlite_db}")

#%% 8. MySQL 적재
username = "root"
password = "Korea2025"
host = "localhost"
database = "Ddareungi"

engine = create_engine(f"mysql+pymysql://{username}:{password}@{host}/{database}")

bike_df.to_sql('bike_usage', con=engine, if_exists='replace', index=False)
print("MySQL 적재 완료")

#%% 9. MySQL 적재 확인
from sqlalchemy import text

#%% 9. MySQL 적재 확인

with engine.connect() as conn:
    total_rows = conn.execute(text("SELECT COUNT(*) FROM bike_usage")).fetchone()[0]
    print(f"MySQL bike_usage 테이블 총 행 수: {total_rows}")

# %%
