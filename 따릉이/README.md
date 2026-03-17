# 따릉이 이용 현황 분석

> 서울시 공공자전거 따릉이 이용 데이터를 수집·정제·분석하여 이용 패턴 및 친환경 효과를 도출하는 데이터 파이프라인

---

## 프로젝트 개요

2023년 1월부터 2025년 6월까지의 서울시 공공자전거 따릉이 월별 이용 데이터를 전처리하고 MySQL 및 SQLite에 적재합니다. SQL 기반 분석을 통해 월별 KPI, 성별·연령대별 이용 패턴, 대여소 성과, 친환경 효과 등을 산출하며, BI 도구(Tableau 등) 연계를 위한 View를 제공합니다.

---

## 데이터

| 파일 | 기간 |
|------|------|
| 서울특별시 공공자전거 이용정보(월별)_23.1-6.csv | 2023년 1월 ~ 6월 |
| 서울특별시 공공자전거 이용정보(월별)_23.7-12.csv | 2023년 7월 ~ 12월 |
| 서울특별시 공공자전거 이용정보(월별)_24.1-6.csv | 2024년 1월 ~ 6월 |
| 서울특별시 공공자전거 이용정보(월별)_24.7-12.csv | 2024년 7월 ~ 12월 |
| 서울특별시 공공자전거 이용정보(월별)_25.1-6.csv | 2025년 1월 ~ 6월 |

**주요 컬럼 (정제 후)**

| 컬럼 | 설명 |
|------|------|
| `rental_ym` | 대여 년월 |
| `station_id` | 대여소 번호 |
| `station_name` | 대여소명 |
| `rental_type` | 대여 구분 코드 |
| `gender` | 성별 |
| `age_group` | 연령대 코드 |
| `ride_count` | 이용 건수 |
| `exercise` | 운동량 |
| `co2` | 탄소 절감량 |
| `distance_m` | 이동 거리 (m) |
| `duration_min` | 이용 시간 (분) |

---

## 파이프라인 구조

```
data/raw/
└── *.csv (5개 파일)
        ↓ preprocess_bike.py
data/processed/
├── bike_usage.csv
└── bike_usage.db (SQLite)

MySQL (Ddareungi DB)
└── bike_usage 테이블
        ↓ sql_query/03_feature.sql
        파생 컬럼 추가: distance_km, speed_kmh, day_type
        ↓ sql_query/04_analysis.sql
        분석 쿼리 실행
        ↓ sql_query/05_summary.sql
        bike_usage_summary 요약 테이블 생성
        ↓ sql_query/06_BI.sql
        v_bike_usage_bi View 생성 (BI 연계)
```

---

## 파일 구조

```
.
├── preprocess_bike.py                  # 전처리 및 DB 적재
├── sql_query/
│   ├── 01_create_and_check.sql        # DB/테이블 생성 및 기본 확인
│   ├── 02_data_check.sql              # 결측치·이상치 탐색
│   ├── 03_feature.sql                 # 파생 컬럼 추가 및 계산
│   ├── 04_analysis.sql                # 이용 패턴 분석
│   ├── 05_summary.sql                 # 요약 테이블 생성
│   ├── 06_BI.sql                      # BI 전용 View 생성
│   └── ddareungi_additional_analysis.sql  # 추가 심화 분석
├── data/
│   ├── raw/                           # 원본 CSV 파일
│   └── processed/                     # 정제 결과 (자동 생성)
```

---

## 모듈 설명

### preprocess_bike.py

원시 CSV 파일을 병합·정제하고 SQLite 및 MySQL에 적재합니다.

- 5개 월별 CSV 파일을 하나의 DataFrame으로 병합
- 컬럼명 한국어 → 영문 변환
- 결측치(`\N`) 처리 및 컬럼 타입 변환
- `data/processed/bike_usage.csv` 저장
- SQLite(`bike_usage.db`) 및 MySQL(`Ddareungi.bike_usage`) 적재

### sql_query/01_create_and_check.sql

MySQL 데이터베이스 및 테이블 생성, 기본 확인 쿼리를 포함합니다.

### sql_query/02_data_check.sql

적재된 데이터의 품질을 점검합니다.

- 전체 행 수 확인
- 결측치 현황 확인
- 기본 통계(거리, 시간) 산출
- 이상치 탐지 (거리 0 또는 50km 초과, 이용 시간 0)

### sql_query/03_feature.sql

분석에 필요한 파생 컬럼을 추가하고 계산합니다. 중복 실행 방지 로직이 포함되어 있습니다.

| 컬럼 | 계산 방법 |
|------|-----------|
| `distance_km` | `distance_m / 1000` |
| `speed_kmh` | `distance_km / (duration_min / 60)` |
| `day_type` | `rental_ym` 기준 주중(Weekday) / 주말(Weekend) 분류 |

### sql_query/04_analysis.sql

다각도 이용 패턴 분석 쿼리를 포함합니다.

- 월별 핵심 KPI (총 이용 건수, 평균 거리·시간·속도)
- 성별·연령대별 월별 이용 패턴
- 대여소별 성과 (상위/하위 10개소)
- 주말/주중 이용 비교
- 거리-이용 시간 상관관계
- 이용 시간 구간 분포 및 속도 유형 분류
- 연령대별 이용 강도
- 월별 탄소 절감 효과
- 30분 기준 장·단기 이용 현황

### sql_query/05_summary.sql

반복 계산을 줄이고 보고서용 기준 데이터를 제공하는 요약 테이블 `bike_usage_summary`를 생성합니다. 월·성별·연령대 단위로 집계합니다.

### sql_query/06_BI.sql

Tableau 등 BI 도구 연계를 위한 View `v_bike_usage_bi`를 생성합니다. 월·요일 유형·대여소·성별·연령대 단위로 핵심 지표를 집계합니다.

### sql_query/ddareungi_additional_analysis.sql

주요 분석 주제별 심화 쿼리를 포함합니다.

- 요일 유형(주중/주말)별 이용 패턴
- 성별 이용 패턴 (총 이용 건수, 평균 거리, 평균 속도)
- 대여 타입별 이용 분석
- 연령대별 평균·최대 속도
- 전체 탄소 절감 효과 집계
- 장거리 이용 상위 20건

---

## 실행 방법

```bash
# 의존성 설치
pip install pandas numpy sqlalchemy pymysql

# 1단계: 전처리 및 DB 적재
python preprocess_bike.py

# 2단계: MySQL에서 SQL 쿼리 순서대로 실행
# 01 → 02 → 03 → 04 → 05 → 06
```

> **주의**: `preprocess_bike.py`의 MySQL 접속 정보(`username`, `password`, `host`, `database`)를 환경에 맞게 수정한 후 실행하세요.

---

## 기술 스택

- **언어**: Python 3.x, SQL
- **데이터 처리**: pandas, numpy
- **데이터베이스**: MySQL, SQLite
- **ORM/연결**: SQLAlchemy, pymysql, sqlite3
- **BI 연계**: Tableau (View 기반)
***
## ① Project Title

서울시 따릉이 이용 데이터 기반 이용 패턴 분석 및 운영 인사이트 도출

---

## ② 프로젝트 배경 & 문제 정의

서울시 공공자전거 따릉이는 대규모 이용 데이터를 보유하고 있으나, 월별·이용자 특성·대여소 단위로 구조화된 분석 기준이 부족해 운영 의사결정에 직접 활용하기 어려운 상태였다. 특히 거리·시간·속도와 같은 핵심 이용 행태 지표가 원천 데이터에 존재하지 않거나, 반복 집계로 인해 분석 일관성이 떨어지는 문제가 있었다.

본 프로젝트는 **원천 CSV → DB 적재 → 파생 지표 설계 → 분석/BI용 기준 데이터 구축**까지 전 과정을 설계하여, 운영·정책·보고서에 바로 활용 가능한 데이터 구조를 만드는 것을 목표로 했다.

---

## ③ 데이터 & 기술 스택

* 데이터: 서울시 공공자전거 이용정보 (2023.01 ~ 2025.06, 월별 CSV)
* 규모: 약 수백만 건의 이용 기록
* 기술 스택

  * Python: Pandas, NumPy, SQLAlchemy
  * DB: SQLite (로컬 검증), MySQL
  * SQL: 데이터 품질 점검, 파생 컬럼, 분석 쿼리

---

## ④ 수행 내용

### 1) ETL 및 데이터 표준화

* 월별 CSV 5개 파일 병합 및 컬럼 영문 표준화
* 결측치(\N) 처리 및 타입 정합성 확보
* CSV → SQLite → MySQL 이중 적재로 검증 가능한 파이프라인 구성

### 2) 데이터 품질 점검

* ride_count, distance, duration 결측 여부 확인
* 거리 0, 비정상 장거리(50km 이상), 시간 0인 레코드 탐지
* 기초 통계(MIN/MAX/AVG/STD) 기반 데이터 분포 검증

### 3) 파생 지표 설계

* distance_km: 이동거리(km)
* speed_kmh: 평균 속도(km/h)
* day_type: rental_ym 기준 주중/주말 구분
* 중복 실행을 고려한 ALTER TABLE 안전 로직 설계

### 4) 분석 쿼리 및 KPI 도출

* 월별 핵심 KPI: 총 이용량, 평균 거리·시간·속도
* 성별·연령대별 이용 패턴 비교
* 대여소 상·하위 성과 분석
* 주중/주말 이용 차이
* 거리–이용시간 상관관계 계산
* 이용 시간·속도 구간별 분포 분석
* 친환경 효과(CO₂ 절감량) 집계

### 5) 분석 결과 재사용 구조화

* 요약 테이블(bike_usage_summary): 월·성별·연령대 기준 집계
* BI 전용 View(v_bike_usage_bi): Tableau/대시보드 즉시 연결 가능 구조

---

## ⑤ 주요 결과 & 인사이트

* 월별 이용량과 평균 이용 거리/시간의 계절성 패턴 확인
* 연령대별 이용 강도 차이 명확화 (특정 연령대에서 평균 거리 우위)
* 소수 대여소에 이용이 집중되는 구조 확인 → 운영 자원 재배치 근거
* 주말 대비 주중 이용은 짧고 반복적인 이동 비중이 높음
* 거리–시간 간 높은 양의 상관관계 확인 → 속도 기반 이용 유형 분류 가능

