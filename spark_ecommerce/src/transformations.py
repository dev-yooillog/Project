from pyspark.sql.functions import col, count, when

def calculate_user_metrics(df):
    metrics = df.groupBy("user_id").agg(
        count(when(col("event_type") == "click", True)).alias("click_count"),
        count(when(col("event_type") == "purchase", True)).alias("purchase_count")
    )

    metrics = metrics.withColumn(
        "conversion_rate",
        col("purchase_count") / col("click_count")
    )

    metrics = metrics.withColumn(
        "churn_flag",
        when((col("click_count") > 0) & (col("purchase_count") == 0), 1).otherwise(0)
    )

    return metrics
