USE Ddareungi;

/*
요약 테이블 목적:
- 반복 계산 삭제
- 보고서용 기준 데이터
- 월·성별·연령대 단위 집계
- 유효 데이터 기준 통일
*/

DROP TABLE IF EXISTS bike_usage_summary;

CREATE TABLE bike_usage_summary AS
SELECT
    rental_ym,
    gender,
    age_group,

    /* 이용 규모 */
    SUM(ride_count) AS total_rides,

    /* 이용 행태 */
    AVG(distance_km)  AS avg_distance_km,
    AVG(duration_min) AS avg_duration_min,
    AVG(speed_kmh)    AS avg_speed_kmh,

    /* 부가 지표 */
    AVG(exercise) AS avg_exercise,
    AVG(co2)      AS avg_co2
FROM bike_usage
WHERE distance_km IS NOT NULL
  AND duration_min > 0
GROUP BY rental_ym, gender, age_group;
