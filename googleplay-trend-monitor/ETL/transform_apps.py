# ETL/transform_apps.py (안전 버전, Installs 오류 수정)

import pandas as pd
import numpy as np
import os
import logging 

# Setting
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_DIR = os.path.join(BASE_DIR, "data")
OUTPUT_DIR = os.path.join(DATA_DIR, "processed")

if not os.path.exists(OUTPUT_DIR):
    os.makedirs(OUTPUT_DIR)
    

# Data load
def load_data(apps_file="googleplaystore.csv", reviews_file="googleplaystore_user_reviews.csv"):
    logging.info("Loading data...")
    apps_path = os.path.join(DATA_DIR, apps_file)
    reviews_path = os.path.join(DATA_DIR, reviews_file)

    apps_df = pd.read_csv(apps_path)
    reviews_df = pd.read_csv(reviews_path)

    logging.info(f"Apps data shape: {apps_df.shape}")
    logging.info(f"Reviews data shape: {reviews_df.shape}")

    return apps_df, reviews_df


# Data cleaning
def clean_apps_data(df):
    drop_cols = ['Last Updated', 'Current Ver', 'Android Ver']
    df = df.drop(columns=[c for c in drop_cols if c in df.columns])

    df['Rating'] = df['Rating'].fillna(df['Rating'].median())
    df['Reviews'] = pd.to_numeric(df['Reviews'], errors='coerce').fillna(0).astype(int)
    df['Category'] = df['Category'].str.strip().str.upper()

    # Size 변환
    def parse_size(x):
        try:
            if 'M' in x:
                return float(x.replace('M','')) * 1e6
            elif 'k' in x:
                return float(x.replace('k','')) * 1e3
            else:
                return float(x)
        except:
            return np.nan

    df['Size'] = df['Size'].astype(str).apply(parse_size).fillna(0).astype(int)

    # Installs 변환
    df['Installs'] = df['Installs'].astype(str).str.replace('[+,]', '', regex=True)
    df['Installs'] = pd.to_numeric(df['Installs'], errors='coerce').fillna(0).astype(int)

    return df

def clean_reviews_data(df):
    drop_cols = ['Translated_Review']
    df = df.drop(columns=[c for c in drop_cols if c in df.columns])

    df['Sentiment'] = df['Sentiment'].fillna('Neutral')
    df['Sentiment_Polarity'] = pd.to_numeric(df['Sentiment_Polarity'], errors='coerce').fillna(0)
    df['Sentiment_Subjectivity'] = pd.to_numeric(df['Sentiment_Subjectivity'], errors='coerce').fillna(0)
    return df


# Data merge
def merge_apps_reviews(apps_df, reviews_df):
    merged_df = reviews_df.merge(apps_df, on='App', how='left')
    logging.info(f"Merged data shape: {merged_df.shape}")
    return merged_df


# Data save
def save_processed_data(df, filename="processed_apps.csv"):
    output_path = os.path.join(OUTPUT_DIR, filename)
    df.to_csv(output_path, index=False)
    

# Main
def main():
    apps_df, reviews_df = load_data()
    apps_df_clean = clean_apps_data(apps_df)
    reviews_df_clean = clean_reviews_data(reviews_df)
    
    save_processed_data(apps_df_clean, "apps_clean.csv")
    save_processed_data(reviews_df_clean, "reviews_clean.csv")

    merged_df = merge_apps_reviews(apps_df_clean, reviews_df_clean)
    save_processed_data(merged_df, "apps_reviews_merged.csv")

if __name__ == "__main__":
    main()