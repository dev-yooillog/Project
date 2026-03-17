Use ddareungi;

SELECT *
FROM bike_usage
LIMIT 10;

-- 요일별 이용 패턴 분석
SELECT
    day_type,
    SUM(ride_count) AS total_rides,
    ROUND(AVG(distance_km),2) AS avg_distance_km,
    ROUND(AVG(duration_min),2) AS avg_duration
FROM bike_usage
GROUP BY day_type
ORDER BY total_rides DESC;

-- 성별 이용 패턴 분석 
SELECT
    gender,
    SUM(ride_count) AS total_rides,
    ROUND(AVG(distance_km),2) AS avg_distance,
    ROUND(AVG(speed_kmh),2) AS avg_speed
FROM bike_usage
GROUP BY gender
ORDER BY total_rides DESC;

-- 대여 타입별 이용 분석
SELECT
    rental_type,
    SUM(ride_count) AS total_rides,
    ROUND(AVG(duration_min),2) AS avg_duration,
    ROUND(AVG(distance_km),2) AS avg_distance
FROM bike_usage
GROUP BY rental_type
ORDER BY total_rides DESC;

-- 평균 속도 기반 이용 패턴 분석
SELECT
    age_group,
    ROUND(AVG(speed_kmh),2) AS avg_speed,
    ROUND(MAX(speed_kmh),2) AS max_speed
FROM bike_usage
GROUP BY age_group
ORDER BY avg_speed DESC;

-- 환경 기여 분석 
SELECT
    SUM(co2) AS total_co2_saved,
    ROUND(AVG(co2),2) AS avg_co2_per_ride
FROM bike_usage;

-- 장거리 이용 상위 20
SELECT
    station_name,
    distance_km,
    duration_min
FROM bike_usage
ORDER BY distance_km DESC
LIMIT 20;

