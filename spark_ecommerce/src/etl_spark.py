import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from pyspark.sql import SparkSession
from config.settings import SPARK_CONFIG, LOG_PATH
from transformations import calculate_user_metrics
from load_mysql import write_mysql

def main():
    spark = SparkSession.builder \
        .appName(SPARK_CONFIG["app_name"]) \
        .master(SPARK_CONFIG["master"]) \
        .config("spark.jars", r"C:\mysql-connector\mysql-connector-j-8.0.33.jar") \
        .getOrCreate()

    logs_df = spark.read.csv(LOG_PATH, header=True, inferSchema=True)
    user_metrics_df = calculate_user_metrics(logs_df)
    write_mysql(user_metrics_df, "user_metrics")

    spark.stop()
    print("ETL 완료")

if __name__ == "__main__":
    main()