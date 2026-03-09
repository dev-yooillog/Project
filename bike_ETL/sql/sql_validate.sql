-- Data Validate

-- 1. 건수 확인
SELECT
    'raw_bike_rental'   AS table_name, COUNT(*) AS row_count 
FROM raw_bike_rental
UNION ALL
SELECT
    'clean_bike_rental' AS table_name, COUNT(*) AS row_count 
FROM clean_bike_rental;

-- 2. NULL 비율 확인
SELECT
    COUNT(*)                                                        AS total,
    ROUND(100.0 * SUM(CASE WHEN bike_id            IS NULL 
    	THEN 1 ELSE 0 END) / COUNT(*), 2) AS bike_id_null_pct,
    ROUND(100.0 * SUM(CASE WHEN rental_datetime    IS NULL 
	    THEN 1 ELSE 0 END) / COUNT(*), 2) AS rental_datetime_null_pct,
    ROUND(100.0 * SUM(CASE WHEN return_datetime    IS NULL 
		THEN 1 ELSE 0 END) / COUNT(*), 2) AS return_datetime_null_pct,
    ROUND(100.0 * SUM(CASE WHEN rental_station_no  IS NULL 
		THEN 1 ELSE 0 END) / COUNT(*), 2) AS rental_station_no_null_pct,
    ROUND(100.0 * SUM(CASE WHEN usage_minutes      IS NULL 
		THEN 1 ELSE 0 END) / COUNT(*), 2) AS usage_minutes_null_pct,
    ROUND(100.0 * SUM(CASE WHEN birth_year         IS NULL 
		THEN 1 ELSE 0 END) / COUNT(*), 2) AS birth_year_null_pct,
    ROUND(100.0 * SUM(CASE WHEN gender             IS NULL 
		THEN 1 ELSE 0 END) / COUNT(*), 2) AS gender_null_pct
FROM clean_bike_rental;

-- 3. 이상값 확인
-- 3-1. 이용 시간 이상값 (0분 또는 1440분 = clip 상한에 걸린 것)
SELECT
    usage_minutes,
    COUNT(*) AS cnt
FROM clean_bike_rental
WHERE usage_minutes <= 0 OR usage_minutes >= 1440
GROUP BY usage_minutes
ORDER BY usage_minutes;

-- 3-2. 이용 거리 이상값 (0km 또는 200km = clip 상한)
SELECT
    CASE
        WHEN usage_distance = 0       
		THEN '0m (결측 대체)'
        WHEN usage_distance >= 200000 
		THEN '200km 이상 (clip)'
        ELSE '정상'
    END AS distance_category,
    COUNT(*) AS cnt,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM clean_bike_rental
GROUP BY distance_category;

-- 3-3. 출생연도 이상값
SELECT
    birth_year,
    COUNT(*) AS cnt
FROM clean_bike_rental
WHERE birth_year = 0 OR birth_year < 1930 OR birth_year > 2010
GROUP BY birth_year
ORDER BY birth_year;

-- 3-4. 반납 시각이 대여 시각보다 빠른 경우
SELECT COUNT(*) AS invalid_time_cnt
FROM clean_bike_rental
WHERE return_datetime < rental_datetime;

-- 4. 성별 분포
SELECT
    gender,
    COUNT(*)                                           AS cnt,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM clean_bike_rental
GROUP BY gender
ORDER BY cnt DESC;

-- 5. 회원 유형 분포
SELECT
    user_type,
    COUNT(*)                                           AS cnt,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM clean_bike_rental
GROUP BY user_type
ORDER BY cnt DESC;

-- 6. 자전거 타입 분포
SELECT
    bike_type,
    COUNT(*) AS cnt
FROM clean_bike_rental
GROUP BY bike_type
ORDER BY cnt DESC;

-- 7. 날짜 범위 확인 (데이터가 원하는 기간인지)
SELECT
    MIN(rental_datetime) AS earliest,
    MAX(rental_datetime) AS latest
FROM clean_bike_rental;

-- 8. raw vs clean 건수 일치 여부
SELECT
    (SELECT COUNT(*) FROM raw_bike_rental)   AS raw_cnt,
    (SELECT COUNT(*) FROM clean_bike_rental) AS clean_cnt,
    (SELECT COUNT(*) FROM raw_bike_rental) - (SELECT COUNT(*) FROM clean_bike_rental) AS diff;