# Citi Bike Demand Analysis

뉴욕 Citi Bike 이용 데이터를 기반으로 수요 패턴을 분석하고 시계열 모델로 예측하는 프로젝트입니다.

---

## 프로젝트 구조

citibike-demand-analysis/
│
├── data/
│   ├── raw/citibike_zip/          
│   └── processed/
│       ├── citibike_csv/          
│       └── citibike_parquet/      
│
├── notebooks/
│   ├── 01_data_overview.ipynb     
│   ├── 02_eda.ipynb               
│   ├── 03_feature_engineering.ipynb  # 피처 생성 및 전처리
│   ├── 04_time_series_modeling.ipynb # 시계열 모델링 (Prophet / LightGBM)
│   └── 05_station_analysis.ipynb  # 스테이션별 수요 분석
│
├── src/
│   ├── extract_zip.py             
│   ├── csv_to_parquet.py          
│   └── data_loader.py            
│
├── models/
│   └── prophet_model.pkl       
│
├── outputs/
│   ├── figures/                
│   └── tables/                  
│
├── README.md
└── requirements.txt

---

## 분석 흐름

1. **데이터 준비** `src/`
   - `extract_zip.py` : `data/raw/citibike_zip/*.zip` → `data/processed/citibike_csv/`
   - `csv_to_parquet.py` : CSV → Parquet (타입 보정 포함)

2. **노트북 실행 순서** `notebooks/`
   - `01` 데이터 로드 확인
   - `02` EDA (분포, 패턴, 이상치)
   - `03` 피처 엔지니어링 (duration, 시간 피처, Haversine 거리)
   - `04` 시계열 모델링 (Prophet + LightGBM 비교)
   - `05` 스테이션 분석 (순유입/유출, 인기 경로, 지도 시각화)

---

## 데이터

- 출처: [Citi Bike System Data](https://citibikenyc.com/system-data)
- 기간: 2025년 4월부터 9월 기준
- 주요 컬럼:

| 컬럼 | 설명 |
|---|---|
| ride_id | 이용 고유 ID |
| rideable_type | 자전거 유형 (classic / electric) |
| started_at | 출발 시각 |
| ended_at | 도착 시각 |
| start_station_name | 출발 스테이션명 |
| end_station_name | 도착 스테이션명 |
| start_lat / start_lng | 출발 좌표 |
| end_lat / end_lng | 도착 좌표 |
| member_casual | 회원 유형 (member / casual) |

---

## 설치 및 실행
```bash
pip install -r requirements.txt
```

데이터 준비 (ZIP 파일을 data/raw/citibike_zip/ 에 넣은 후 실행):
```bash
python src/extract_zip.py
python src/csv_to_parquet.py
```

이후 `notebooks/` 를 순서대로 실행합니다.

---

## 모델 성능