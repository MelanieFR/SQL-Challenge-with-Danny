-- B. Runner and Customer Experience

-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT 
	week(registration_date) as registration_week,
    count(runner_id) as nbr_of_runners
FROM runners
GROUP BY week(registration_date);

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
-- pickup_time column will give us this info. 
-- The minute() function from MysQL will be handy to return our output. 
-- Note: be sure the argument passed in minute is in datatime format. 
SELECT distinct
	runner_id, 
    round(avg(minute(cast(pickup_time as datetime))),2) as avg_pickup_time
FROM runner_orders_clean
group by runner_id;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
-- (order_time - pickup_time)
-- WITH order_tbl AS (

SELECT
	distinct c.order_id, 
    count(c.order_id) as nbr_pizza_per_order,
    TIMESTAMPDIFF(MINUTE, c.order_time, r.pickup_time) as preparation_time
from customer_orders_clean c
inner join runner_orders_clean r
on c.order_id = r.order_id
where r.pickup_time is not null
group by c.order_id
order by preparation_time desc
;
-- Indeed we notice the prepration time is higher when the number of pizza per order is high

-- 4. What was the average distance travelled for each customer?