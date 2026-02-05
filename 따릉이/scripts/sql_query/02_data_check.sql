USE ddareungi;

-- 1. 전체 행 수 확인
SELECT COUNT(*) AS total_rows FROM bike_usage;

-- 2. 컬럼별 결측치 확인
SELECT 
    SUM(CASE WHEN ride_count IS NULL THEN 1 ELSE 0 END) AS missing_ride_count,
    SUM(CASE WHEN distance_m IS NULL THEN 1 ELSE 0 END) AS missing_distance,
    SUM(CASE WHEN duration_min IS NULL THEN 1 ELSE 0 END) AS missing_duration
FROM bike_usage;

-- 3. 기본 통계 확인 (거리, 시간, 운동량 등)
SELECT 
    MIN(distance_m) AS min_distance,
    MAX(distance_m) AS max_distance,
    AVG(distance_m) AS avg_distance,
    STD(distance_m) AS std_distance,
    MIN(duration_min) AS min_duration,
    MAX(duration_min) AS max_duration,
    AVG(duration_min) AS avg_duration,
    STD(duration_min) AS std_duration
FROM bike_usage;

-- 4. 이상치 확인
-- 거리 0 또는 50km 이상, 지속시간 0, 평균 속도 비정상
SELECT *
FROM bike_usage
WHERE distance_m = 0 OR distance_m > 50000 OR duration_min = 0;

-- 5. ride_count 분포 확인 (중복, 비정상값)
SELECT ride_count, COUNT(*) AS cnt
FROM bike_usage
GROUP BY ride_count
ORDER BY cnt DESC;


