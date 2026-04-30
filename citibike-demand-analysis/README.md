# Citi Bike Demand Analysis

뉴욕 Citi Bike 이용 데이터를 기반으로 수요 패턴을 분석하고,  
시계열 모델(Prophet / LightGBM)로 시간별 수요를 예측하는 프로젝트입니다.

---

## 프로젝트 구조
```
citibike-demand-analysis/
│
├── data/
│   ├── raw/citibike_zip/              # 원본 ZIP 파일
│   └── processed/
│       ├── citibike_csv/              # ZIP 압축 해제 CSV
│       └── citibike_parquet/          # CSV → Parquet 변환본
│
├── notebooks/
│   ├── 01_data_overview.ipynb         # 데이터 로드 및 기본 확인
│   ├── 02_eda.ipynb                   # 탐색적 데이터 분석
│   ├── 03_feature_engineering.ipynb   # 피처 생성 및 전처리
│   ├── 04_time_series_modeling.ipynb  # 시계열 모델링 (Prophet / LightGBM)
│   └── 05_station_analysis.ipynb      # 스테이션별 수요 분석
│
├── src/
│   ├── extract_zip.py                 # ZIP → CSV 압축 해제
│   ├── csv_to_parquet.py              # CSV → Parquet 변환
│   └── data_loader.py                 # Parquet 데이터 로드
│
├── models/
│   └── prophet_model.pkl              # 학습된 Prophet 모델
│
├── README.md
└── requirements.txt
```

---

## 데이터

- **출처**: [Citi Bike System Data](https://citibikenyc.com/system-data)
- **분석 기간**: 2025년 4월 ~ 9월 (6개월)
- **총 레코드**: 28,206,527건 (이상치 제거 후 28,165,708건)

| 컬럼 | 설명 |
|---|---|
| ride_id | 이용 고유 ID |
| rideable_type | 자전거 유형 (classic_bike / electric_bike) |
| started_at | 출발 시각 |
| ended_at | 도착 시각 |
| start_station_name | 출발 스테이션명 |
| end_station_name | 도착 스테이션명 |
| start_lat / start_lng | 출발 위도/경도 |
| end_lat / end_lng | 도착 위도/경도 |
| member_casual | 회원 유형 (member / casual) |

---

## 설치 및 실행
```bash
pip install -r requirements.txt
```

데이터 준비 (`data/raw/citibike_zip/` 에 ZIP 파일을 넣은 후 실행):
```bash
python src/extract_zip.py
python src/csv_to_parquet.py
```

이후 `notebooks/` 를 순서대로 실행합니다.

---

## 분석 흐름

### 01. 데이터 로드
`src/data_loader.py` 의 `load_data()` 로 Parquet 파일을 로드합니다.

### 02. EDA
- 결측치: end_lat/lng 0.30%, start_lat 0.04%
- 자전거 유형: electric_bike **70.16%** / classic_bike 29.84%
- 회원 유형: member **80.07%** / casual 19.93%
- 평균 이용 시간: **13.71분** (중앙값 9.38분)
- 이상치: duration > 180분 40,819건 제거

### 03. 피처 엔지니어링
- **시간 피처**: hour, dayofweek, month, is_weekend, time_of_day
- **거리 피처**: Haversine distance_km (평균 2.08km)
- **수요 집계**: 시간별 ride_count (hourly_demand)
- **Lag / Rolling**: lag 1·2·3·24·48·168h, rolling_mean/std 24·168h

### 04. 시계열 모델링

Train / Test split: 마지막 7일(168시간)을 Test로 분리 (시간 순 split)

| Model | MAE | RMSE |
|---|---|---|
| Baseline (lag_24) | 1,627.56 | 2,406.12 |
| Prophet | 1,779.94 | 2,312.01 |
| **LightGBM** | **404.19** | **621.97** |

→ LightGBM이 Baseline 대비 **MAE 75% · RMSE 74% 개선**

### 05. 스테이션 분석
- 출발 Top 1: **W 21 St & 6 Ave** (97,197건)
- 출발 스테이션 수: 2,180개 / 도착: 2,263개
- 순유입/유출 분석으로 자전거 재배치 우선순위 도출
- Top 20 스테이션 × 24시간 히트맵으로 혼잡도 시각화

---

## 주요 인사이트

- **통근 수요**: member는 평일 8시·17~18시 피크, casual은 주말 낮 시간대 집중
- **electric_bike** 이용 비중이 70%로 과반 → 전동 자전거 중심 운영 필요
- **lag·rolling 피처**가 수요 예측에 가장 중요한 피처로 작용
- **W 21 St & 6 Ave** 등 상위 스테이션에 수요 집중 → 재배치 우선 대상
