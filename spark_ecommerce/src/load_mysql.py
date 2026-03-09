import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from config.settings import MYSQL_CONFIG

def write_mysql(df, table_name):
    url = (
        f"jdbc:mysql://{MYSQL_CONFIG['host']}:{MYSQL_CONFIG['port']}"
        f"/{MYSQL_CONFIG['database']}?useSSL=false"
    )

    df.write \
        .format("jdbc") \
        .option("url",      url) \
        .option("dbtable",  table_name) \
        .option("user",     MYSQL_CONFIG["user"]) \
        .option("password", MYSQL_CONFIG["password"]) \
        .option("driver",   "com.mysql.cj.jdbc.Driver") \
        .mode("overwrite") \
        .save()