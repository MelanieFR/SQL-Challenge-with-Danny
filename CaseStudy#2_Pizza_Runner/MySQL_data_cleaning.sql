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


