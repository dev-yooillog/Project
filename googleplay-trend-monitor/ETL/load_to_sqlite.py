# ETL/load_to_sqlite.py

import sqlite3
import pandas as pd
import os
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROCESSED_DIR = os.path.join(BASE_DIR, "data", "processed")
DB_PATH = os.path.join(BASE_DIR, "db", "googleplay.db")

if not os.path.exists(os.path.dirname(DB_PATH)):
    os.makedirs(os.path.dirname(DB_PATH))

apps_csv = os.path.join(PROCESSED_DIR, "apps_clean.csv")
reviews_csv = os.path.join(PROCESSED_DIR, "reviews_clean.csv")

apps_df = pd.read_csv(apps_csv)
reviews_df = pd.read_csv(reviews_csv)

logging.info(f"Apps CSV loaded: {apps_df.shape}")
logging.info(f"Reviews CSV loaded: {reviews_df.shape}")

# SQLite 연결
conn = sqlite3.connect(DB_PATH)
logging.info(f"SQLite DB created/connected: {DB_PATH}")

# 테이블로 적재
apps_df.to_sql("apps", conn, if_exists="replace", index=False)
reviews_df.to_sql("reviews", conn, if_exists="replace", index=False)
logging.info("Data loaded into SQLite tables: apps, reviews")

# sample 
query = """
SELECT a.Category, COUNT(*) AS Num_Apps, ROUND(AVG(a.Rating),2) AS Avg_Rating
FROM apps a
GROUP BY a.Category
ORDER BY Num_Apps DESC
LIMIT 5;
"""

result = pd.read_sql(query, conn)
logging.info("Top 5 Categories by number of apps:\n" + str(result))

conn.close()
logging.info("SQLite connection closed.")