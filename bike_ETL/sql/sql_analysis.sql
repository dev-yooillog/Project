-- 시간대별 대여 패턴
SELECT
    rental_hour,
    COUNT(*)                                           AS rental_cnt,
    ROUND(AVG(usage_minutes), 1)                       AS avg_minutes,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM clean_bike_rental
GROUP BY rental_hour
ORDER BY rental_hour;


-- 요일별 대여 패턴
SELECT
    CASE rental_weekday
        WHEN 0 THEN '월'
        WHEN 1 THEN '화'
        WHEN 2 THEN '수'
        WHEN 3 THEN '목'
        WHEN 4 THEN '금'
        WHEN 5 THEN '토'
        WHEN 6 THEN '일'
    END AS weekday,
    rental_weekday,
    COUNT(*)                     AS rental_cnt,
    ROUND(AVG(usage_minutes), 1) AS avg_minutes
FROM clean_bike_rental
GROUP BY rental_weekday
ORDER BY rental_weekday;


-- 인기 대여 스테이션 TOP 15
SELECT
    rental_station_no,
    rental_station_name,
    COUNT(*) AS rental_cnt
FROM clean_bike_rental
GROUP BY rental_station_no, rental_station_name
ORDER BY rental_cnt DESC
LIMIT 15;


-- 인기 반납 스테이션 TOP 15
SELECT
    return_station_no,
    return_station_name,
    COUNT(*) AS return_cnt
FROM clean_bike_rental
GROUP BY return_station_no, return_station_name
ORDER BY return_cnt DESC
LIMIT 15;


-- 많이 이용된 대여→반납 구간 TOP 10
SELECT
    rental_station_name,
    return_station_name,
    COUNT(*)                                        AS trip_cnt,
    ROUND(AVG(usage_minutes), 1)                    AS avg_minutes,
    ROUND(AVG(usage_distance)::NUMERIC, 2)          AS avg_m
FROM clean_bike_rental
WHERE rental_station_name <> return_station_name
GROUP BY rental_station_name, return_station_name
ORDER BY trip_cnt DESC
LIMIT 10;


-- 연령대별 이용 패턴
SELECT
    CASE
        WHEN birth_year = 0                   THEN '미상'
        WHEN birth_year >= 2000               THEN '20대 이하'
        WHEN birth_year BETWEEN 1990 AND 1999 THEN '30대'
        WHEN birth_year BETWEEN 1980 AND 1989 THEN '40대'
        WHEN birth_year BETWEEN 1970 AND 1979 THEN '50대'
        WHEN birth_year BETWEEN 1960 AND 1969 THEN '60대'
        ELSE '70대 이상'
    END AS age_group,
    COUNT(*)                                           AS rental_cnt,
    ROUND(AVG(usage_minutes), 1)                       AS avg_minutes,
    ROUND(AVG(usage_distance)::NUMERIC, 2)             AS avg_m,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM clean_bike_rental
GROUP BY age_group
ORDER BY rental_cnt DESC;


-- 성별 × 시간대별 교차 분석
SELECT
    gender,
    rental_hour,
    COUNT(*) AS rental_cnt
FROM clean_bike_rental
WHERE gender IN ('M', 'F')
GROUP BY gender, rental_hour
ORDER BY gender, rental_hour;


-- 회원 유형별 평균 이용 시간 / 거리
SELECT
    user_type,
    COUNT(*)                                AS rental_cnt,
    ROUND(AVG(usage_minutes), 1)            AS avg_minutes,
    ROUND(AVG(usage_distance)::NUMERIC, 2)  AS avg_m,
    ROUND(MAX(usage_distance)::NUMERIC, 2)  AS max_m
FROM clean_bike_rental
GROUP BY user_type
ORDER BY rental_cnt DESC;


-- 자전거 타입별 이용 현황
SELECT
    bike_type,
    COUNT(*)                               AS rental_cnt,
    ROUND(AVG(usage_minutes), 1)           AS avg_minutes,
    ROUND(AVG(usage_distance)::NUMERIC, 2) AS avg_m
FROM clean_bike_rental
GROUP BY bike_type
ORDER BY rental_cnt DESC;


-- 시간대 × 요일 히트맵용 집계
SELECT
    rental_weekday,
    rental_hour,
    COUNT(*) AS rental_cnt
FROM clean_bike_rental
GROUP BY rental_weekday, rental_hour
ORDER BY rental_weekday, rental_hour;