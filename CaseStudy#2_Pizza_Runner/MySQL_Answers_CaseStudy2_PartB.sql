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
-- the column distance will give us this info: 

SELECT distinct customer_id,
	round(avg(distance),2) as 'avg distance (in km)'
FROM customer_orders_clean
inner join runner_orders_clean 
using (order_id)
where distance is not null
group by customer_id;

-- 5. What was the difference between the longest and shortest delivery times for all orders?

SELECT 
	min(duration) as shortest_delivery_time,
    max(duration) as longest_delivery_time,
	(max(duration)- min(duration)) as delivery_difference
FROM runner_orders_clean;


-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
-- speed = (distance / time)

SELECT distinct 
	COALESCE(runner_id, 'All runners') AS runner_id, 
	coalesce(order_id, 'avg speed per runner') as order_id,
    round(avg((distance*60)/duration),2) as 'avg speed (in mins)'
FROM runner_orders_clean
where cancellation is null
GROUP BY runner_id, order_id with rollup;

-- 7. What is the successful delivery percentage for each runner?

SELECT 
	runner_id,
    count(pickup_time) as 'nbr of delivery', -- count(column) is handy as it will return the number of non-null values
    round(count(pickup_time)/count(*)*100) as 'percentage of delivery'
from runner_orders_clean
group by runner_id
order by 3 desc; -- here "3" refers to the second column in the select statement ('percentage of delivery')






