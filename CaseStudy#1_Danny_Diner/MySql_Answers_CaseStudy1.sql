-- 1. What is the total amount each customer spent at the restaurant?
SELECT distinct(s.customer_id), concat('$', sum(price)) as total_spending
FROM sales as s
INNER JOIN menu as m
ON s.product_id = m.product_id
GROUP by s.customer_id
ORDER BY s.customer_id ASC
;

-- 2. How many days has each customer visited the restaurant?
SELECT distinct(customer_id), count(distinct order_date) as nbr_of_visits
FROM sales
GROUP BY customer_id
ORDER BY customer_id ASC
;

-- 3. What was the first item from the menu purchased by each customer?
	-- a. This kind of question can be answered with a window function, because it requires to "order" the values based on the order_date for each customer
WITH CTE as (
SELECT customer_id, product_name, DENSE_RANK() OVER (Partition by customer_id Order by order_date ASC) as rnk
	-- even though values are ordered ASC by default, it is good practice to write it down for the window functions
FROM sales as s
INNER JOIN menu as m
ON s.product_id = m.product_id 
)
SELECT distinct customer_id, product_name as first_order
FROM CTE
WHERE rnk = 1
ORDER BY customer_id ASC
;
	-- The above code will return each product_name that each customer ordered the first time at this restaurant.
	-- However, customer A ordered 2 diff items (curry and sushi). Let's have these items written on the same line:
WITH CTE as (
SELECT customer_id, product_name, DENSE_RANK() OVER (Partition by customer_id Order by order_date) as rnk
	-- even though values are ordered ASC by default, it is good practice to write it down for the window functions
FROM sales as s
INNER JOIN menu as m
ON s.product_id = m.product_id 
)
SELECT distinct customer_id, group_concat(distinct product_name) as first_order
	-- group_concat function will "concat" the values of the column called based on the grouped function
FROM CTE
WHERE rnk = 1
GROUP BY customer_id
ORDER BY customer_id ASC
;

	-- b. That question can also be answered by using the MIN() function on order_date:
SELECT s.customer_id, s.order_date, group_concat(m.product_name) as first_order
FROM sales as s
JOIN menu as m
USING(product_id)
INNER JOIN (
SELECT customer_id, min(order_date) as min_date
FROM sales
GROUP BY customer_id)
as sub
ON s.customer_id = sub.customer_id AND s.order_date = sub.min_date
GROUP BY s.customer_id
ORDER BY s.customer_id
	-- Explanation:
	-- In the subquery, I apply the min() function on the order_date column to get only the first order date for all customers
	-- Then I group my min_date rows PER customer_id
	-- Then I join the outer query with the suquery on a common column AND on the SAME order_date to filter in only these dates 
	-- Finally I group by customer_id 
;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT product_name, count(order_date) as most_purchased_item
FROM sales as s
INNER JOIN menu as m
USING (product_id)
GROUP BY product_name
ORDER BY cnt DESC
LIMIT 1
;

-- 5. Which item was the most popular for each customer?
	-- I can use a window function to "order" the items per nbr of times they were ordered by each customer 
WITH ordering AS (
SELECT customer_id, product_name, count(product_id) as cnt, DENSE_RANK() OVER(partition by customer_id order by count(order_date) DESC) as rnk
FROM sales as s
INNER JOIN menu as m
USING (product_id)
GROUP BY customer_id, product_name
)
SELECT customer_id, group_concat(product_name)
FROM ordering
WHERE rnk = 1
GROUP BY customer_id;

	-- I would use the column 'cnt' to show how many times the most popular item per customer has been ordered
	-- Also, add the group by 'product_name' to be sure to return all popular items (in the case there are several - see customer B)
SELECT customer_id, product_name, cnt
FROM ordering
WHERE rnk = 1
GROUP BY customer_id, product_name
;

-- 6. Which item was purchased first by the customer after they became a member?
	-- This question implies a condition: order_date > join_date
	-- Then return the min(order_date) 

WITH details as (
SELECT s.customer_id, mem.join_date, s.order_date, m.product_name, 
dense_rank() over(partition by customer_id order by order_date ASC) as rnk
FROM sales as s
INNER JOIN members as mem
USING (customer_id)
INNER JOIN menu as m
USING (product_id)
WHERE s.order_date >= mem.join_date
GROUP BY s.customer_id, mem.join_date, s.order_date, m.product_name
ORDER BY s.order_date ASC
)
SELECT distinct customer_id, join_date, order_date, group_concat(product_name) as first_order
FROM details
WHERE rnk = 1
GROUP BY customer_id
ORDER BY customer_id
;
	-- Note: by using dense_rank() window function, the ranking count will restart from 1 for each partition

-- 7. Which item was purchased just before the customer became a member?
WITH purchase_details as (
SELECT s.customer_id, mem.join_date, s.order_date, m.product_name, 
dense_rank() over(partition by customer_id order by order_date DESC) as rnk -- DESC to have the last order_date on the top
FROM sales as s
INNER JOIN members as mem
USING (customer_id)
INNER JOIN menu as m
USING (product_id)
WHERE s.order_date < mem.join_date
GROUP BY s.customer_id, mem.join_date, s.order_date, m.product_name
ORDER BY s.order_date ASC
)
SELECT distinct customer_id, join_date, order_date, group_concat(product_name) as first_order
FROM purchase_details
WHERE rnk = 1
GROUP BY customer_id
ORDER BY customer_id
;

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT s.customer_id, count(s.product_id) as total_items, concat('$', sum(price)) as amnt_spent
FROM sales as s
INNER JOIN menu as m
ON s.product_id = m.product_id
INNER JOIN members as mem
ON s.customer_id = mem.customer_id
WHERE s.order_date < mem.join_date
GROUP BY s.customer_id
ORDER BY s.customer_id
;

-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
	-- This question implies a condition:
	-- points WHEN product_name LIKE '%sushi%' THEN price * 10
	-- points WHEN product_name NOT LIKE '%sushi%' THEN price * 2
    -- We can use the CASE WHEN() on the SELECT clause to create a new column: points
SELECT s.customer_id,
SUM(CASE WHEN m.product_name NOT LIKE '%sushi%' then price*10 else price*2 end) as points
FROM sales as s
INNER JOIN menu as m
USING (product_id)
GROUP BY s.customer_id
ORDER BY s.customer_id
;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
