--  What is the total amount each customer spent at the restaurant?
  select sales.customer_id, sum(menu.price) as "Total_Ammount" from sales
  inner join menu
  on sales.product_id = menu.product_id
  group by 1
  
-- How many days has each customer visited the restaurant?
  select sales.customer_id, count(distinct sales.order_Date) as "Total_Visit" from members
  inner join sales
  on members.customer_id = sales.customer_id
  group by 1
  
-- What was the first item from the menu purchased by each customer?
SELECT customer_id, product_name
FROM (
 select sales.customer_id, menu.product_name, sales.order_date,
 DENSE_RANK() OVER (PARTITION BY sales.customer_id ORDER BY sales.order_date) AS dense
 from sales
inner join menu
on sales.product_id = menu.product_id
) subquery
WHERE dense = 1;

  
-- What is the most purchased item on the menu and how many times was it purchased by all customers?
select product_name, total_purchased from
(
select  menu.product_name, count(menu.product_name) as 
total_purchased from sales
inner join menu
on sales.product_id = menu.product_id
group by 1
)subtable
order by 2 DESC
limit 1

--  Which item was the most popular for each customer?
select customer_id, product_name, Total as total_ordered from
(
select  customer_id, product_name, Total,
DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY Total DESC) AS dense
from
(
select sales.customer_id, menu.product_name, count(menu.product_name) as 
Total from sales
inner join menu
on sales.product_id = menu.product_id
group by 2, 1
order by 3 desc) bb
)cc
where dense = 1

-- Which item was purchased first by the customer after they became a member?
select customer_id, customer_id, order_date from
(
 select sales.customer_id, sales.product_id, menu.product_name, members.join_date, sales.order_date,
 DENSE_RANK() OVER (PARTITION BY members.customer_id ORDER BY sales.order_date) AS dense
 from members
  inner join sales
  on members.customer_id = sales.customer_id
  inner join menu
  on sales.product_id = menu.product_id
  where sales.order_date >= members.join_date
  order by members.customer_id, sales.order_date
  ) subtable
  where dense = 1

-- Which item was purchased just before the customer became a member?
select customer_id, customer_id, order_date from
(
 select sales.customer_id, sales.product_id, menu.product_name, members.join_date, sales.order_date,
 DENSE_RANK() OVER (PARTITION BY members.customer_id ORDER BY sales.order_date DESC) AS dense
 from members
  inner join sales
  on members.customer_id = sales.customer_id
  inner join menu
  on sales.product_id = menu.product_id
  where sales.order_date < members.join_date
  order by members.customer_id, sales.order_date
  ) subtable
  where dense = 1
  
-- What is the total items and amount spent for each member before they became a member?
 select sales.customer_id, count(sales.product_id) as Total_Item, sum(menu.price) as Total_Amount from members
  inner join sales
  on members.customer_id = sales.customer_id
  inner join menu
  on sales.product_id = menu.product_id
  where sales.order_date < members.join_date
  group by 1
  
-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select customer_id, sum(Total_Points) as total_points
from(
 select sales.customer_id, 
 case 
 when menu.product_name = 'sushi' 
 then menu.price * 20
 else menu.price * 10 end as Total_Points from sales
  inner join menu
  on sales.product_id = menu.product_id
  ) subtable
  group by 1

-- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
 select sales.customer_id, count(sales.product_id) as Total_Item, sum(menu.price * 20) as Total_Points from members
  inner join sales
  on members.customer_id = sales.customer_id
  inner join menu
  on sales.product_id = menu.product_id
  where sales.order_date between members.join_date and DATE_ADD(members.join_date, INTERVAL 7 DAY)
  group by 1
