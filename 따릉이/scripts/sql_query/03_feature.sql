USE Ddareungi;

-- -----------------------------------------------------
-- 1. 파생 컬럼 추가 (중복 실행 안전)
-- -----------------------------------------------------

-- distance_km
SET @col_exists := (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE table_schema = 'Ddareungi'
      AND table_name   = 'bike_usage'
      AND column_name  = 'distance_km'
);

SET @sql := IF(
    @col_exists = 0,
    'ALTER TABLE bike_usage ADD COLUMN distance_km FLOAT',
    'DO 0'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


-- speed_kmh
SET @col_exists := (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE table_schema = 'Ddareungi'
      AND table_name   = 'bike_usage'
      AND column_name  = 'speed_kmh'
);

SET @sql := IF(
    @col_exists = 0,
    'ALTER TABLE bike_usage ADD COLUMN speed_kmh FLOAT',
    'DO 0'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


-- day_type
SET @col_exists := (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE table_schema = 'Ddareungi'
      AND table_name   = 'bike_usage'
      AND column_name  = 'day_type'
);

SET @sql := IF(
    @col_exists = 0,
    'ALTER TABLE bike_usage ADD COLUMN day_type VARCHAR(10)',
    'DO 0'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- -----------------------------------------------------
-- 2. 파생 컬럼 계산
-- -----------------------------------------------------

-- 거리 (m → km)
UPDATE bike_usage
SET distance_km = distance_m / 1000
WHERE usage_id >= 1
  AND distance_km IS NULL
  AND distance_m IS NOT NULL;


-- 평균 속도 (km/h)
UPDATE bike_usage
SET speed_kmh = distance_km / (duration_min / 60)
WHERE usage_id >= 1
  AND speed_kmh IS NULL
  AND duration_min > 0
  AND distance_km IS NOT NULL;


-- 주중 / 주말
UPDATE bike_usage
SET day_type = CASE
    WHEN DAYOFWEEK(
        STR_TO_DATE(CONCAT(rental_ym, '01'), '%Y%m%d')
    ) IN (1, 7) THEN 'Weekend'
    ELSE 'Weekday'
END
WHERE usage_id >= 1
  AND day_type IS NULL;

-- -----------------------------------------------------
-- 3. 검증
-- -----------------------------------------------------

SELECT
    COUNT(*)                     AS total_rows,
    COUNT(distance_km)            AS distance_km_rows,
    COUNT(speed_kmh)              AS speed_kmh_rows,
    COUNT(day_type)               AS day_type_rows
FROM bike_usage;