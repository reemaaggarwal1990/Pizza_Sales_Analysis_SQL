# Retrieve the total number of orders placed.
select count(*) as Total_order from orders;

# Calculate the total revenue generated from pizza sales.
SELECT round(sum(od.quantity*p.price),2) as total_revenue
from order_details od join pizzas p
on od.pizza_id=p.pizza_id;

# Identify the highest-priced pizza.
SELECT pt.name,p.price from pizza_types pt join pizzas p
on pt.pizza_type_id=p.pizza_type_id
where p.price=(select max(price) from pizzas);

# Identify the most common pizza size ordered.
SELECT p.size,count(od.order_details_id) as total_order 
from pizzas p join order_details od
on p.pizza_id=od.pizza_id
group by p.size
order by total_order desc
limit 1

# List the top 5 most ordered pizza types along with their quantities.
SELECT * FROM pizzahut.order_details;
select pt.name,count(quantity) as quantity
from order_details od join pizzas p 
on od.pizza_id=p.pizza_id join pizza_types pt 
on p.pizza_type_id=pt.pizza_type_id
group by pt.name
order by quantity desc
limit 5;

# Join the necessary tables to find the total quantity 
# of each pizza category ordered.
SELECT pt.category,sum(od.quantity) as quantity 
FROM pizza_types pt join pizzas p on
pt.pizza_type_id=p.pizza_type_id join 
order_details od on od.pizza_id=p.pizza_id
group by pt.category;

# Determine the distribution of orders by hour of the day.
SELECT hour(order_time) as Each_Hour,count(order_id)
FROM pizzahut.orders
group by Each_Hour;

# Join relevant tables to find the category-wise distribution of pizzas.
SELECT count(name) as Variety,category 
FROM pizza_types
group by category;


# Group the orders by date and 
# calculate the average number of pizzas ordered per day.
select round(avg(quantity),0) as Avg_Order_everyday 
from (SELECT sum(od.quantity) 
as quantity,o.order_date
FROM order_details od join orders o on 
od.order_id=o.order_id
group by o.order_date)as total_order;

# Determine the top 3 most ordered pizza types based on revenue.
select pt.name,sum(od.quantity*p.price) as revenue
from pizza_types pt join pizzas p 
on pt.pizza_type_id=p.pizza_type_id join
order_details od on
od.pizza_id=p.pizza_id
group by pt.name
order by revenue desc
limit 3;

# Calculate the percentage contribution of each pizza type 
# to total revenue.
with cte as (select pt.category,sum(od.quantity*p.price) as revenue
from pizza_types pt join pizzas p 
on pt.pizza_type_id=p.pizza_type_id join
order_details od on
od.pizza_id=p.pizza_id
group by pt.category),
cte_1 as(select sum(revenue) as total_sum from cte)
select cte.category,round(cte.revenue/cte_1.total_sum*100,2)
as revenue_pct from cte,cte_1 order by revenue_pct desc;

# Analyze the cumulative revenue generated over time.
with cte as (select o.order_date,round(sum(od.quantity*p.price),2) as revenue
from pizzas p join
order_details od on
od.pizza_id=p.pizza_id join
 orders o on o.order_id=od.order_id
 group by o.order_date)
 select *,round(sum(revenue)
 over(order by order_date),2) as cumulative_revenue from cte
 order by order_date ;

# Determine the top 3 most ordered pizza types based 
# on revenue for each pizza category.
with cte as (select pt.category,pt.name,
round(sum(od.quantity*p.price),2)  as revenue
from pizza_types pt join pizzas p 
on pt.pizza_type_id=p.pizza_type_id join
order_details od on
od.pizza_id=p.pizza_id
group by pt.category,pt.name),
cte_2 as (select category,name,revenue,
dense_rank() over(partition by category order by revenue desc ) 
as Top_3_pizza
from cte)
select * from cte_2 where Top_3_pizza<=3;




