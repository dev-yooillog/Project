#%%
import os
from dotenv import load_dotenv

load_dotenv()

MYSQL_CONFIG = {
    "host":     os.getenv("MYSQL_HOST", "localhost"),
    "port":     int(os.getenv("MYSQL_PORT", 3306)),
    "database": os.getenv("MYSQL_DATABASE", "target_ecommerce"),
    "user":     os.getenv("MYSQL_USER", "root"),
    "password": os.getenv("MYSQL_PASSWORD", ""),
}

SPARK_CONFIG = {
    "app_name": "TargetEcommerceUserLogETL",
    "master":   "local[*]",
}

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LOG_PATH  = os.path.join(BASE_DIR, "data", "processed", "ecommerce_logs.csv")  
# %%
