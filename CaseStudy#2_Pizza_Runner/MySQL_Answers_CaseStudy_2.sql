-- A. Pizza Metrics

-- 1. How many pizzas were ordered?
SELECT count(pizza_id) as total_nbr_pizza
FROM customer_orders;

-- 2. How many unique customer orders were made?
SELECT count(distinct order_id) as nbr_customer_orders
FROM customer_orders;

-- 3. How many successful orders were delivered by each runner?
	-- the cancellation column will give me the reason why a customer cancelled the order. So, applying the inverse logic I'll be able to identify the delivered orders
    
SELECT 
	runner_id, 
    count(distinct order_id) as nbr_customer_orders
FROM runner_orders_clean
WHERE cancellation IS NULL
GROUP BY runner_id
;

-- 4. How many of each type of pizza was delivered?

SELECT 
	p.pizza_id, 
    pizza_name as pizza_type, 
    count(pizza.pizza_id) as delivered
FROM (
	SELECT pizza_id
FROM customer_orders_clean as c
INNER JOIN runner_orders_clean as r
ON c.order_id = r.order_id
WHERE cancellation IS NULL) as pizza
INNER JOIN pizza_names as p
ON pizza.pizza_id = p.pizza_id
GROUP BY p.pizza_id, pizza_name
ORDER BY pizza_type;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT 
	distinct customer_id,
	SUM(CASE WHEN c.pizza_id = 1 THEN 1 ELSE 0 END) AS Meatlovers_count,
	SUM(CASE WHEN c.pizza_id = 2 THEN 1 ELSE 0 END) AS Vegetarian_count
FROM customer_orders_clean as c
INNER JOIN pizza_names as p
ON c.pizza_id = p.pizza_id
GROUP BY customer_id
ORDER BY customer_id;

-- 6. What was the maximum number of pizzas delivered in a single order?

SELECT 
	c.customer_id, 
    c.order_id, count(c.pizza_id) as cnt
FROM customer_orders_clean as c
INNER JOIN runner_orders_clean as r
ON c.order_id = r.order_id
WHERE cancellation IS NULL
GROUP BY c.customer_id, c.order_id
ORDER BY cnt DESC;
-- LIMIT 1 to return the first row of the query

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
-- this question implies a condition
-- Is considered a change any added or removed topping : sum(exclusions) >= 1 OR sum(extras) >=1

SELECT distinct 
	customer_id, 
	sum(CASE WHEN exclusions >=1 OR extras >=1 THEN 1 ELSE 0 END) as changed_pizza,
	sum(CASE WHEN exclusions IS NULL AND extras IS NULL then 1 ELSE 0 END) as no_changed_pizza -- Here we use AND because both conditions have to be valid to be considered
FROM customer_orders_clean
INNER JOIN runner_orders_clean USING (order_id)
WHERE cancellation IS NULL
GROUP BY customer_id
ORDER BY customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras?
-- We can reuse a piece of the above code:

SELECT 
	customer_id, 
    sum(CASE WHEN exclusions >=1 AND extras >=1 THEN 1 ELSE 0 END) as changed_pizza -- we update the previous OR condition with AND condition
FROM customer_orders_clean
INNER JOIN runner_orders_clean USING (order_id)
WHERE cancellation IS NULL
GROUP BY customer_id
ORDER BY changed_pizza DESC;

-- 9. What was the total volume of pizzas ordered for each hour of the day?
-- I define the volume as the quantity
-- Let's get each order_date, and from that date extract the hour + the count() of pizza ordered. 
-- We'll use the hour() function 
SELECT distinct 
	CAST(order_time as date) as order_date, 
    hour(order_time) as order_hour, 
    count(order_id) as qty_of_pizza_ordered
FROM customer_orders_clean
GROUP BY day(order_time), hour(order_time)
ORDER BY order_date, order_hour;

-- 10. What was the volume of orders for each day of the week?
-- we can use the dayofweek() from MySQL, for example: 
SELECT distinct
	dayofweek(CAST(order_time as date)) -- that function returns a number (from 1 to 7) that we have to convert to the day (from Monday to Sunday) 
FROM customer_orders_clean;

-- or we can use dayname(date_argument) which will retrieve the name of the day 
SELECT distinct
	dayname(CAST(order_time as date)) as order_day,
    count(order_id) as qty_of_pizza_ordered
FROM customer_orders_clean
GROUP BY dayname(order_time)
ORDER BY qty_of_pizza_ordered desc