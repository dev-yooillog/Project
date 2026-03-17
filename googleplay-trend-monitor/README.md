# Google Play Trend Monitor

> Google Play 스토어 앱 및 리뷰 데이터를 수집·정제·적재하여 카테고리별 트렌드를 모니터링하는 ETL 파이프라인

---

## 프로젝트 개요

Google Play 스토어의 앱 정보와 사용자 리뷰 데이터를 대상으로 ETL(Extract, Transform, Load) 파이프라인을 구축합니다. 원시 CSV 데이터를 정제하고 SQLite 데이터베이스에 적재하여 카테고리별 앱 현황 및 감성 분석 결과를 추적합니다.

---

## 데이터

| 파일 | 설명 |
|------|------|
| `googleplaystore.csv` | 앱 메타데이터 (카테고리, 평점, 설치 수, 크기 등) |
| `googleplaystore_user_reviews.csv` | 사용자 리뷰 (감성 극성, 주관성 점수 포함) |

**주요 컬럼 (Apps)**

| 컬럼 | 설명 |
|------|------|
| `App` | 앱 이름 |
| `Category` | 앱 카테고리 |
| `Rating` | 평점 (0 ~ 5) |
| `Reviews` | 리뷰 수 |
| `Size` | 앱 크기 (바이트 변환) |
| `Installs` | 설치 수 |

**주요 컬럼 (Reviews)**

| 컬럼 | 설명 |
|------|------|
| `App` | 앱 이름 |
| `Sentiment` | 감성 레이블 (Positive / Negative / Neutral) |
| `Sentiment_Polarity` | 감성 극성 점수 |
| `Sentiment_Subjectivity` | 주관성 점수 |

---

## 파이프라인 구조

```
data/
├── googleplaystore.csv
└── googleplaystore_user_reviews.csv
        ↓ ETL/transform_apps.py
data/processed/
├── apps_clean.csv
├── reviews_clean.csv
└── apps_reviews_merged.csv
        ↓ ETL/load_to_sqlite.py
db/
└── googleplay.db  (apps 테이블, reviews 테이블)
```

---

## 파일 구조

```
.
├── ETL/
│   ├── transform_apps.py     # 데이터 정제 및 변환
│   └── load_to_sqlite.py     # SQLite 적재
├── quality/
│   └── data_validation.py    # 데이터 품질 검증
├── data/
│   ├── googleplaystore.csv
│   ├── googleplaystore_user_reviews.csv
│   └── processed/            # 정제 결과 (자동 생성)
└── db/
    └── googleplay.db         # SQLite DB (자동 생성)
```

---

## 모듈 설명

### ETL/transform_apps.py

원시 CSV 데이터를 정제하고 병합합니다.

- **Apps 정제**: 불필요한 컬럼 제거, 결측값 처리, `Size` 단위 통일(M/k → bytes), `Installs` 숫자 변환
- **Reviews 정제**: 번역 리뷰 컬럼 제거, 감성 결측값 Neutral 처리, 수치형 컬럼 변환
- **병합**: App 이름 기준으로 앱 정보와 리뷰 데이터 병합

**출력 파일**

| 파일 | 설명 |
|------|------|
| `apps_clean.csv` | 정제된 앱 데이터 |
| `reviews_clean.csv` | 정제된 리뷰 데이터 |
| `apps_reviews_merged.csv` | 앱 + 리뷰 병합 데이터 |

### ETL/load_to_sqlite.py

정제된 CSV 파일을 SQLite 데이터베이스에 적재합니다.

- `apps` 테이블과 `reviews` 테이블에 각각 적재 (`replace` 방식)
- 적재 후 카테고리별 앱 수 및 평균 평점 상위 5개 쿼리 검증

### quality/data_validation.py

적재 전 데이터 품질을 검증합니다.

- 결측값(Null) 현황 확인
- Rating 범위(0 ~ 5) 유효성 검사
- Installs 음수 여부 확인
- Sentiment 값 유효성 검사 (Positive / Negative / Neutral)

---

## 실행 방법

```bash
# 의존성 설치
pip install pandas numpy

# 1단계: 데이터 정제 및 변환
python ETL/transform_apps.py

# 2단계: 데이터 품질 검증
python quality/data_validation.py

# 3단계: SQLite 적재
python ETL/load_to_sqlite.py
```

---

## 기술 스택

- **언어**: Python 3.x
- **데이터 처리**: pandas, numpy
- **데이터베이스**: SQLite (sqlite3)
- **로깅**: Python logging 모듈
