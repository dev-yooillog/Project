DROP TABLE IF EXISTS raw_bike_rental;
DROP TABLE IF EXISTS clean_bike_rental;

CREATE TABLE raw_bike_rental (
    bike_id TEXT,
    rental_datetime TEXT,
    rental_station_no BIGINT,
    rental_station_name TEXT,
    rental_dock INT,
    return_datetime TEXT,
    return_station_no BIGINT,
    return_station_name TEXT,
    return_dock INT,
    usage_minutes BIGINT,
    usage_distance FLOAT,
    birth_year INT,
    gender TEXT,
    user_type TEXT,
    rental_station_id TEXT,
    return_station_id TEXT,
    bike_type TEXT
);

CREATE TABLE clean_bike_rental (
    bike_id TEXT,
    rental_datetime TIMESTAMP,
    rental_station_no BIGINT,
    rental_station_name TEXT,
    rental_dock INT,
    return_datetime TIMESTAMP,
    return_station_no BIGINT,
    return_station_name TEXT,
    return_dock INT,
    usage_minutes BIGINT,
    usage_distance FLOAT,
    birth_year INT,
    gender TEXT,
    user_type TEXT,
    rental_station_id TEXT,
    return_station_id TEXT,
    bike_type TEXT,
    rental_hour INT,
    rental_weekday INT
);
