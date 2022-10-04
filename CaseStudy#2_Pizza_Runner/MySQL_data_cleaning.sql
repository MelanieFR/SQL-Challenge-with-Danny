-- Proceed to data cleaning first:

SELECT *
FROM customer_orders;

-- The exclusion and extras columns have 'null' values, empty strings (' ') which are not considered NULL by SQL
-- hence we need to clean these columns to standardize the NULL values before creating queries

-- DROP TABLE IF EXISTS customer_orders_clean;

CREATE TABLE customer_orders_clean AS
SELECT order_id,
       customer_id,
       pizza_id,
       CASE
           WHEN exclusions = '' THEN NULL
           WHEN exclusions = 'null' THEN NULL
           ELSE exclusions
       END AS exclusions,
       CASE
           WHEN extras = '' THEN NULL
           WHEN extras = 'null' THEN NULL
           ELSE extras
       END AS extras,
       order_time
FROM customer_orders;

SELECT * FROM customer_orders_clean;

-- Same principle for runner_orders table.
-- We need to clean/ standardize the values in the columns 'pickup_time', 'distance', 'duration', 'cancellation'
-- We will notice that 'distance' and 'duration' columns both have rows with units (respectively km, minutes/min) that we have to trim: 

DROP TABLE IF EXISTS runner_orders_clean;
CREATE TABLE runner_orders_clean AS
SELECT order_id, runner_id,
(CASE WHEN pickup_time LIKE '%null%' then NULL else pickup_time END) AS pickup_time,
(CASE WHEN distance LIKE '%null%' then NULL 
else CAST(regexp_replace(distance, '[a-z]+', '') AS FLOAT) END) AS distance,
-- Note: We can also use the TRIM() function, but it requires an input for each value to replace and is more time-consuming
-- WHEN distance LIKE '%km%' then CAST(TRIM(TRAILING 'km' FROM distance) AS FLOAT)
-- WHEN distance LIKE '% km%' then CAST(TRIM(TRAILING ' km' FROM distance) AS FLOAT)
-- else distance END) AS distance,
(CASE WHEN duration LIKE '%null%' THEN NULL ELSE CAST(regexp_replace(duration, '[a-z]+', '') AS FLOAT) END) AS duration,
(CASE WHEN cancellation LIKE '' THEN NULL
WHEN cancellation LIKE 'null' THEN NULL
ELSE cancellation
END) AS cancellation
FROM runner_orders;


SELECT * FROM runner_orders_clean


