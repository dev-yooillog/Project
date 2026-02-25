# quality/data_validation.py

import pandas as pd
import os
import logging

#Setting
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROCESSED_DIR = os.path.join(BASE_DIR, "data", "processed")

# Data Load
def load_processed_data(filename):
    path = os.path.join(PROCESSED_DIR, filename)
    if not os.path.exists(path):
        logging.error(f"{filename} not found")
        return None
    df = pd.read_csv(path)
    logging.info(f"Loaded {filename} with shape {df.shape}")
    return df

#Verification
def validate_apps_data(df):
    logging.info("Validating apps data...")

    # Null 체크
    null_counts = df.isnull().sum()
    logging.info(f"Null counts:\n{null_counts}")

    # Rating 범위 체크
    if df['Rating'].between(0,5).all():
        logging.info("Rating values OK")
    else:
        logging.warning("Rating values out of range detected")

    # Installs 음수 여부
    if (df['Installs'] >= 0).all():
        logging.info("Installs values okay")
    else:
        logging.warning("Negative Installs values detected")

    logging.info(f"Category unique count: {df['Category'].nunique()}")

def validate_reviews_data(df):
    # Null 체크
    null_counts = df.isnull().sum()
    logging.info(f"Null counts:\n{null_counts}")

    # Sentiment 값 확인
    valid_sentiments = {'Positive', 'Negative', 'Neutral'}
    if set(df['Sentiment'].unique()).issubset(valid_sentiments):
        logging.info("Sentiment values OKay")
    else:
        logging.warning(f"Unexpected Sentiment values: {df['Sentiment'].unique()}")


# Main
def main():
    apps_df = load_processed_data("apps_clean.csv")
    reviews_df = load_processed_data("reviews_clean.csv")

    if apps_df is not None:
        validate_apps_data(apps_df)
    if reviews_df is not None:
        validate_reviews_data(reviews_df)

if __name__ == "__main__":
    main()