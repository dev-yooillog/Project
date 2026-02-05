USE Ddareungi;

/* 월별 핵심 KPI 요약 (월별 전체 이용량 및 평균 거리, 시간, 속도) */
SELECT rental_ym,
       SUM(ride_count)   AS total_rides,
       AVG(distance_km)  AS avg_distance_km,
       AVG(duration_min) AS avg_duration_min,
       AVG(speed_kmh)    AS avg_speed_kmh,
       AVG(exercise)     AS avg_exercise,
       AVG(co2)          AS avg_co2
FROM bike_usage
WHERE distance_km IS NOT NULL
  AND duration_min > 0
GROUP BY rental_ym
ORDER BY rental_ym;

/* 성별·연령대별 월별 이용 패턴 */
SELECT rental_ym, gender, age_group,
       SUM(ride_count)   AS total_rides,
       AVG(distance_km)  AS avg_distance_km,
       AVG(duration_min) AS avg_duration_min,
       AVG(speed_kmh)    AS avg_speed_kmh
FROM bike_usage
WHERE distance_km IS NOT NULL
  AND duration_min > 0
GROUP BY rental_ym, gender, age_group
ORDER BY rental_ym, gender, age_group;


/* 대여소 성과 분석 (상위 / 하위) */
-- 상위 10
SELECT station_name,
       SUM(ride_count)   AS total_rides,
       AVG(distance_km)  AS avg_distance_km,
       AVG(duration_min) AS avg_duration_min
FROM bike_usage
WHERE distance_km IS NOT NULL
  AND duration_min > 0
GROUP BY station_name
ORDER BY total_rides DESC
LIMIT 10;

-- 하위 10
SELECT station_name,
       SUM(ride_count)   AS total_rides,
       AVG(distance_km)  AS avg_distance_km,
       AVG(duration_min) AS avg_duration_min
FROM bike_usage
WHERE distance_km IS NOT NULL
  AND duration_min > 0
GROUP BY station_name
ORDER BY total_rides ASC
LIMIT 10;

/* 대여소별 월별 이용 추이 */
SELECT station_name, rental_ym,
       SUM(ride_count)  AS total_rides,
       AVG(distance_km) AS avg_distance_km
FROM bike_usage
WHERE distance_km IS NOT NULL
  AND duration_min > 0
GROUP BY station_name, rental_ym
ORDER BY station_name, rental_ym;

/*주말/주중 이용 패턴 비교 */
SELECT rental_ym, day_type,
       SUM(ride_count)   AS total_rides,
       AVG(distance_km)  AS avg_distance_km,
       AVG(duration_min) AS avg_duration_min
FROM bike_usage
WHERE distance_km IS NOT NULL
  AND duration_min > 0
GROUP BY rental_ym, day_type
ORDER BY rental_ym, day_type;

/*거리–시간 상관관계*/

WITH stats AS (
    SELECT
        COUNT(*) AS n,
        SUM(distance_km) AS sum_x,
        SUM(duration_min) AS sum_y,
        SUM(distance_km * duration_min) AS sum_xy,
        SUM(POW(distance_km, 2)) AS sum_x2,
        SUM(POW(duration_min, 2)) AS sum_y2
    FROM bike_usage
    WHERE distance_km IS NOT NULL
      AND duration_min > 0
)
SELECT
    (n * sum_xy - sum_x * sum_y) /
    SQRT(
        (n * sum_x2 - POW(sum_x, 2)) *
        (n * sum_y2 - POW(sum_y, 2))
    ) AS distance_duration_corr
FROM stats;

/*이용 시간 구간 분포*/
SELECT
    CASE
        WHEN duration_min < 10 THEN 'Under 10'
        WHEN duration_min < 30 THEN '10–30'
        WHEN duration_min < 60 THEN '30–60'
        ELSE 'Over 60'
    END AS duration_group,
    COUNT(*) AS rides
FROM bike_usage
WHERE duration_min > 0
GROUP BY duration_group
ORDER BY rides DESC;

/*속도 기반 이용 유형*/
SELECT
    CASE
        WHEN speed_kmh < 10 THEN 'Low speed'
        WHEN speed_kmh < 20 THEN 'Medium speed'
        ELSE 'High speed'
    END AS speed_group,
    COUNT(*) AS rides
FROM bike_usage
WHERE speed_kmh IS NOT NULL
GROUP BY speed_group
ORDER BY rides DESC;

/* 연령대별 평균 이용 강도*/
SELECT age_group,
       AVG(distance_km)  AS avg_distance_km,
       AVG(duration_min) AS avg_duration_min
FROM bike_usage
WHERE age_group IS NOT NULL
  AND distance_km IS NOT NULL
GROUP BY age_group
ORDER BY avg_distance_km DESC;

/*친환경 효과 */
SELECT rental_ym,
       SUM(co2) AS total_co2_reduction
FROM bike_usage
WHERE co2 IS NOT NULL
GROUP BY rental_ym
ORDER BY rental_ym;

/*거리·이용시간 결측 데이터 확인*/
SELECT
    SUM(CASE WHEN distance_km IS NULL THEN 1 ELSE 0 END) AS missing_distance,
    SUM(CASE WHEN duration_min IS NULL THEN 1 ELSE 0 END) AS missing_duration
FROM bike_usage;

/*30분 기준 장·단기 이용 현황*/
SELECT rental_ym,
       SUM(CASE WHEN duration_min >= 30 THEN ride_count ELSE 0 END) AS long_rides,
       SUM(CASE WHEN duration_min < 30 THEN ride_count ELSE 0 END) AS short_rides
FROM bike_usage
WHERE duration_min IS NOT NULL
GROUP BY rental_ym;