import psycopg2
from psycopg2.extras import execute_batch
from config import DB_CONFIG

def get_connection():
    return psycopg2.connect(**DB_CONFIG)

def insert_dataframe(df, table_name):
    cols = ",".join(df.columns)
    values = ",".join(["%s"] * len(df.columns))
    query = f"INSERT INTO {table_name} ({cols}) VALUES ({values})"
    data = [tuple(row) for row in df.itertuples(index=False)]

    with psycopg2.connect(**DB_CONFIG) as conn:
        with conn.cursor() as cur:
            execute_batch(cur, query, data, page_size=1000)