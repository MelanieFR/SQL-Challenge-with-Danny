-- 1. How many pizzas were ordered?

SELECT count(pizza_id) as total_nbr_pizza
FROM customer_orders;

-- 2. How many unique customer orders were made?
SELECT count(distinct order_id) as nbr_customer_orders
FROM customer_orders;

-- 3. How many successful orders were delivered by each runner?
	-- the cancellation column will give me the reason why a customer cancelled the order. So, applying the inverse logic I'll be able to identify the delivered orders
SELECT runner_id, count(distinct order_id) as nbr_customer_orders
FROM runner_orders_clean
WHERE cancellation IS NULL
GROUP BY runner_id
;

-- 4. How many of each type of pizza was delivered?

SELECT p.pizza_id, pizza_name as pizza_type, count(pizza.pizza_id) as delivered
FROM (
SELECT  pizza_id
FROM customer_orders_clean as c
INNER JOIN runner_orders_clean as r
ON c.order_id = r.order_id
WHERE cancellation IS NULL) as pizza
INNER JOIN pizza_names as p
ON pizza.pizza_id = p.pizza_id
GROUP BY p.pizza_id, pizza_name
ORDER BY pizza_type


-- 3. How many successful orders were delivered by each runner?
-- 4. How many of each type of pizza was delivered?
-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
-- 6. What was the maximum number of pizzas delivered in a single order?
-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
-- 8. How many pizzas were delivered that had both exclusions and extras?
-- 9. What was the total volume of pizzas ordered for each hour of the day?
-- 10. What was the volume of orders for each day of the week?