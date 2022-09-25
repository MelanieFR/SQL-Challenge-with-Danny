-- What is the total amount each customer spent at the restaurant?
SELECT distinct(s.customer_id), concat('$', sum(price)) as total_spending
FROM sales as s
INNER JOIN menu as m
ON s.product_id = m.product_id
GROUP by s.customer_id
ORDER BY s.customer_id ASC
;

-- How many days has each customer visited the restaurant?
SELECT distinct(customer_id), count(distinct order_date) as nbr_of_visits
FROM sales
GROUP BY customer_id
ORDER BY customer_id ASC
;

-- What was the first item from the menu purchased by each customer?
-- This kind of question can be answered with a window function, because it requires to "order" the values based on the order_date for each customer
WITH CTE as (
SELECT customer_id, product_name, DENSE_RANK() OVER (Partition by customer_id Order by order_date) as rnk
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

-- That question can also be answered by using the MIN() function on order_date:
SELECT s.customer_id, group_concat(m.product_name)
FROM sales as s
JOIN menu as m
USING(product_id)
INNER JOIN (
SELECT customer_id, min(order_date) as min_date
FROM sales
GROUP BY customer_id)
as sub
ON s.customer_id = sub.customer_id AND s.order_date = sub.min_date
GROUP BY 
s.customer_id ASC

-- In the subquery, I apply the min() function on the order_date column to get only the first order date for all customers
-- Then I group my min_date rows PER customer_id
-- Then I join the outer query with the suquery on a common column AND on the SAME order_date to filter in only these dates 
-- Finally I group by customer_id 
;



-- What is the most purchased item on the menu and how many times was it purchased by all customers?
-- Which item was the most popular for each customer?
-- Which item was purchased first by the customer after they became a member?
-- Which item was purchased just before the customer became a member?
-- What is the total items and amount spent for each member before they became a member?
-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?