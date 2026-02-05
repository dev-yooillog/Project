CREATE DATABASE IF NOT EXISTS Ddareungi;
USE Ddareungi;

CREATE TABLE bike_usage (
    usage_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    rental_ym VARCHAR(6),
    station_id INT,
    station_name VARCHAR(100),
    rental_type VARCHAR(10),
    gender VARCHAR(10),
    age_group VARCHAR(10),
    ride_count INT,
    exercise FLOAT,
    co2 FLOAT,
    distance_m FLOAT,
    duration_min FLOAT
);

SELECT COUNT(*) FROM bike_usage;
SELECT * FROM bike_usage LIMIT 5;

SELECT COUNT(*) - COUNT(ride_count) AS missing_ride_count 
FROM bike_usage;
SELECT MIN(distance_m), MAX(distance_m) 
FROM bike_usage;

-- ALTER TABLE bike_usage
-- ADD COLUMN usage_id BIGINT AUTO_INCREMENT PRIMARY KEY;