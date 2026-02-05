USE Ddareungi;

/*
06_BI.sql
- BI / Tableau 전용 단일 기준 데이터
*/

DROP VIEW IF EXISTS v_bike_usage_bi;

CREATE VIEW v_bike_usage_bi AS
SELECT
    rental_ym,
    day_type,
    station_name,
    gender,
    age_group,

    /* 핵심 지표 */
    SUM(ride_count)   AS total_rides,
    AVG(distance_km)  AS avg_distance_km,
    AVG(duration_min) AS avg_duration_min,
    AVG(speed_kmh)    AS avg_speed_kmh,
    AVG(exercise)     AS avg_exercise,
    AVG(co2)          AS avg_co2
FROM bike_usage
WHERE distance_km IS NOT NULL
  AND duration_min > 0
GROUP BY
    rental_ym,
    day_type,
    station_name,
    gender,
    age_group;


