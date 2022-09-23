--  How many unique nodes are there on the Data Bank system?
SELECT count(distinct node_id ) as unique_node
FROM customer_nodes
;

-- What is the number of nodes per region?
SELECT r.region_name as region, count(node_id) as nbr_node
FROM customer_nodes as c
INNER JOIN regions as r
ON c.region_id = r.region_id
GROUP BY r.region_name
ORDER BY r.region_name ASC
;

-- How many customers are allocated to each region?
SELECT distinct region_name as region, count(distinct customer_id) as nbr_customer
FROM regions as r 
INNER JOIN customer_nodes as c
ON r.region_id = c.region_id
GROUP BY region_name
ORDER BY nbr_customer DESC
;
-- How many days on average are customers reallocated to a different node?
-- Note: First let's see the last "end_date" values to check if every customer has an end_date
SELECT distinct start_date, end_date
FROM customer_nodes
ORDER BY end_date DESC;

SELECT round(avg(datediff(end_date, start_date)),2) as avg_days
FROM customer_nodes
WHERE end_date NOT LIKE '%9999-12-31%'
;
-- What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
-- This question implies to partition the dataset by region => use a window function (RANK, DENSE_RANK, PERCENT_RANK, ROW_NUMBER ...)
-- For readibility purpose I will first create a CTE (Common Table Expression) to create a "view" of the data on which I use my window function on:

WITH temp AS (
SELECT *, PERCENT_RANK() OVER(partition by region_name ORDER BY reallocation_days)*100 as pctile
FROM (
SELECT customer_id, c.region_id, region_name, node_id, datediff(end_date, start_date) as reallocation_days
FROM customer_nodes as c
INNER JOIN regions as r
ON c.region_id = r.region_id 
WHERE end_date != '9999-12-31') as tbl
)
SELECT region_id, region_name, reallocation_days
FROM temp
WHERE pctile > 95
GROUP BY region_id

-- Use the same logic for the 80th and 50th percentile

