# Spark E-commerce ETL & Analytics Pipeline

## 프로젝트 개요
Brazilian E-commerce (Olist) 공개 데이터셋을 기반으로  
사용자 행동 로그(클릭 / 구매)를 생성하고 PySpark ETL 파이프라인을 통해  
유저별 KPI를 집계한 뒤 MySQL에 적재 및 머신러닝 분석까지 수행한 프로젝트

---

## 기술 스택

| 분류 | 기술 |
|------|------|
| 데이터 처리 | PySpark 3.5, Pandas, NumPy |
| 데이터베이스 | MySQL 8.0 (JDBC 적재) |
| 머신러닝 | scikit-learn (분류 / 회귀 / 클러스터링) |
| 시각화 | Matplotlib, Seaborn |
| BI | Tableau Public |
| 환경 관리 | python-dotenv |

---

## 프로젝트 구조
```
spark_ecommerce/
├── config/
│   ├── __init__.py
│   └── settings.py            # DB / Spark 설정 (환경변수 기반)
├── src/
│   ├── __init__.py
│   ├── etl_spark.py           # ETL 메인 진입점
│   ├── transformations.py     # 유저 KPI 계산 로직
│   └── load_mysql.py          # MySQL JDBC 적재
├── notebooks/
│   ├── user_behavior_EDA.ipynb   # 탐색적 데이터 분석
│   └── user_behavior_ML.ipynb    # 머신러닝 모델
├── sql/
│   └── analysis_queries.sql   # 분석 쿼리 모음
├── data/
│   ├── raw/                   # 원본 CSV (Olist)
│   │   ├── customers.csv
│   │   ├── orders.csv
│   │   └── order_items.csv
│   └── processed/
│       └── ecommerce_logs.csv # 합성 이벤트 로그
├── create_log.ipynb           # 이벤트 로그 생성
├── .env.example               # 환경변수 예시
├── .gitignore
└── requirements.txt
```

---

## 데이터 플로우
```
[Olist Raw CSVs]
      │
      ▼
create_log.ipynb
→ purchase 이벤트 추출 + click 이벤트 시뮬레이션
→ data/processed/ecommerce_logs.csv (10,000건 샘플)
      │
      ▼
etl_spark.py (PySpark)
→ CSV 로드 → KPI 집계 → MySQL JDBC 적재
      │
      ▼
MySQL: user_metrics 테이블
      │
      ├── user_behavior_EDA.ipynb  (탐색적 분석)
      └── user_behavior_ML.ipynb   (머신러닝 모델)
```

---

## 주요 KPI (user_metrics 테이블)

| 컬럼 | 설명 |
|------|------|
| click_count | 유저별 총 클릭 수 |
| purchase_count | 유저별 총 구매 수 |
| conversion_rate | 구매 전환율 (click=0이면 null) |
| churn_flag | 이탈 위험 유저 (클릭 있으나 구매 없음: 1) |

---

## EDA 주요 인사이트

- 전체 전환율 확인 (click → purchase)
- 이탈 위험 유저 **84.7%** 차지
- 시간대 / 요일별 이벤트 집중 패턴 확인
- 클릭은 많으나 구매 없는 상품 **70개** 발견

---

## ML 모델

| 모델 | 타겟 | 평가지표 |
|------|------|----------|
| Logistic Regression | 이탈 예측 (분류) | F1 / CV F1 |
| Random Forest Classifier | 구매 전환 예측 (분류) | F1 / CV F1 |
| Random Forest Regressor | 구매 수 예측 (회귀) | RMSE / MAE |
| K-Means (k=3) | 유저 세그멘테이션 | Silhouette Score: 0.9644 |

---

## 유저 세그멘테이션 결과

| 세그먼트 | 설명 | 비율 |
|----------|------|------|
| Churn Risk | 클릭은 있으나 구매 없음 | 84.7% |
| Normal | 구매 1회 | 15.2% |
| High Value | 구매 2회 이상 | 0.1% |

---

## 비즈니스 활용 방안

- **Churn Risk 유저** → 쿠폰 / 리타겟팅 마케팅 집중
- **High Value 유저** → VIP 프로그램 / 프리미엄 상품 노출
- **Dead Products (70개)** → 상세페이지 개선 / 가격 조정 검토

---

## 실행 방법

### 1. 환경 설정
```bash
pip install -r requirements.txt
cp .env.example .env
# .env 파일에 DB 접속 정보 입력
```

### 2. 데이터 준비
Kaggle에서 [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) 다운로드  
→ `data/raw/` 폴더에 저장

### 3. 로그 생성
```
create_log.ipynb 실행
→ data/processed/ecommerce_logs.csv 생성
```

### 4. ETL 실행
```bash
python src/etl_spark.py
```

### 5. 분석
```
notebooks/user_behavior_EDA.ipynb 실행
notebooks/user_behavior_ML.ipynb 실행
```

---

## 환경

| 항목 | 버전 |
|------|------|
| Python | 3.10 |
| PySpark | 3.5.0 |
| Java | 11 |
| MySQL | 8.0 |
| Hadoop | 3.3.6 |

---

## 데이터 출처

[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)