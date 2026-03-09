# 🚴 서울 따릉이 대여 데이터 ETL 파이프라인

서울시 공공자전거(따릉이) 대여이력 데이터를 CSV에서 PostgreSQL로 적재하고 분석하는 ETL 파이프라인

---

## 프로젝트 구조

```
bike_ETL/
├── data/
│   └── 서울특별시 공공자전거 대여이력 정보_2501.csv
├── src/
│   ├── config.py        # DB 설정, 경로, 상수
│   ├── extract.py       # CSV 청크 읽기
│   ├── transform.py     # 데이터 정제 및 파생 변수 생성
│   ├── load.py          # PostgreSQL 적재
│   └── etl_bike.py      # ETL 메인 실행
├── sql/
│   ├── create_tables.sql  # 테이블 생성
│   ├── validate.sql       # 데이터 검증 쿼리
│   └── analysis.sql       # 분석 쿼리
├── visualize.ipynb        # 시각화 노트북
└── README.md
```

---

## 환경 설정

### 요구사항

- Python 3.10+
- PostgreSQL 14+

### 패키지 설치

```bash
pip install pandas psycopg2-binary matplotlib seaborn jupyter
```

### DB 설정

`src/config.py`에서 PostgreSQL 접속 정보를 수정하세요:

```python
DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "bike",
    "user": "postgres",
    "password": "your_password"
}
```

---

## 실행 방법

### 1단계 — 테이블 생성

pgAdmin 또는 psql에서 실행:

```sql
\i sql/create_tables.sql
```

### 2단계 — ETL 실행

```bash
python src/etl_bike.py
```

청크(100,000건) 단위로 처리하며, 완료 시 `ETL DONE` 출력.

### 3단계 — 데이터 검증

```sql
\i sql/validate.sql
```

### 4단계 — 시각화

```bash
jupyter notebook visualize.ipynb
```

---

## 테이블 설명

| 테이블 | 설명 |
|---|---|
| `raw_bike_rental` | 원본 데이터 (datetime을 TEXT로 보관) |
| `clean_bike_rental` | 정제된 데이터 (TIMESTAMP 변환, 파생 변수 추가) |

### clean_bike_rental 추가 컬럼

| 컬럼 | 설명 |
|---|---|
| `rental_hour` | 대여 시간 (0~23) |
| `rental_weekday` | 대여 요일 (0=월 ~ 6=일) |

---

## 데이터 검증 결과 (2501 기준)

| 항목 | 결과 |
|---|---|
| 총 건수 | 1,704,336건 |
| NULL 비율 | 전 컬럼 0% |
| raw = clean 건수 | 일치 |
| 반납시각 역전 | 0건 |
| 데이터 기간 | 2025년 1월 |

---

## 주요 분석 결과

- **출근(8시), 퇴근(18시)** 피크 타임 확인
- **금요일** 대여 최다, **주말**은 평균 이용시간이 더 길어 여가 목적 이용 확인
- **마곡나루역** 일대가 대여·반납 모두 TOP 스테이션
- **30대**가 전체 이용의 33%로 핵심 이용층
- **외국인**은 평균 56분, 4.7km로 관광 목적 이용 패턴
- `usage_distance` 단위는 **미터(m)**

---

## 참고

- 데이터 출처: [서울 열린데이터광장](https://data.seoul.go.kr)
- `birth_year = 0`은 미입력 사용자, 분석 시 `미상`으로 처리
- `rental_station_no = 0`인 행은 미상 스테이션으로 스테이션 분석 시 제외 권장