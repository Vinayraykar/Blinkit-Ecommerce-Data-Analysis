-- Q1. Identify the top 10 products by revenue generated in the last quarter.

SELECT p.product_name as Products,
ROUND(SUM(oi.quantity * oi.unit_price),2) as Revenue

FROM order_items as oi  JOIN orders as o
ON oi.order_id = o.order_id
JOIN products as p
ON p.product_id = oi.product_id

WHERE o.order_date >= '1/1/2024 1:57'
AND o.order_date <= '9/9/2024 23:44'
GROUP BY Products
ORDER BY Revenue DESC;


-- Q2. Analyze the average delivery time and identify areas with the most delivery delays.

SELECT c.area AS Area,
ROUND(AVG(dp.delivery_time_minutes)) AS Avg_Delivery_time,

o.delivery_status as Delivery_Status
FROM  orders as o JOIN customers as c
ON o.customer_id = c.customer_id
JOIN delivery_performance as dp
ON dp.order_id = o.order_id

WHERE o.delivery_status in ('Slightly Delayed', 'Significantly Delayed')

GROUP BY Area, Delivery_Status
ORDER BY Avg_Delivery_time DESC;


-- Q3. Find the customer segment with the highest lifetime value based on total orders and revenue.
SELECT c.customer_segment as Segment,
SUM(c.total_orders) as Total_orders,
ROUND(SUM(c.total_orders * c.avg_order_value),2) as Revenue

from customers as c
GROUP BY Segment, Total_orders
ORDER BY Revenue DESC;

-- Q4. Determine the effect of marketing campaign spend on revenue and ROAS for each channel.
SELECT mp.channel as Channel,
ROUND(SUM(mp.spend),2) as Spends,
ROUND(SUM(mp.roas),2) as Roas,
ROUND(SUM(mp.revenue_generated),2) AS Revenue

FROM marketing_performance as mp

GROUP BY Channel
ORDER BY Revenue DESC; 



-- Q5. Calculate the monthly inventory damage rate by product category and suggest improvements.
select p.category as Product_Category,
DATE_FORMAT(MONTH(inew.date), "%D - %M - %Y") as Monthly_Damage,
ROUND(SUM(inew.stock_received / inew.damaged_stock)*100,2) As Damage_Pct_rate
FROM products as p JOIN inventorynew as inew
ON p.product_id = inew.product_id

GROUP BY Product_Category, Monthly_Damage
ORDER BY Damage_Pct_rate DESC;
 

-- Q6. Identify customers who have not placed an order in the last 6 months but have high order frequency historically.
SELECT c.customer_id AS Customer_ID,
		c.total_orders as High_order_freq
FROM customers as c
WHERE 
	c.total_orders >= c.total_orders/2 
    AND c.customer_id NOT IN (
			SELECT DISTINCT customer_id 
            FROM orders
			WHERE order_date >= curdate() - INTERVAL -6 MONTH)

ORDER BY High_order_freq DESC;

-- Q7. Analyze customer feedback sentiments linked to delivery times and product quality ratings.
SELECT  cf.customer_id as Customer_id,
cf.sentiment as Sentiment,
o.actual_delivery_time as Delivery_Time,
cf.rating as Rating,
COUNT(*) AS Feedback_count

FROM customer_feedback as cf JOIN orders as o
ON cf.customer_id = o.customer_id AND cf.order_id = o.order_id

GROUP BY Sentiment, Delivery_Time, Rating, Customer_id
ORDER BY Rating Desc;


-- Q8. Create a report showing order count and total sales by payment method and delivery status.
SELECT o.payment_method as Payment_Method,
o.delivery_status as Delivery_Status,
COUNT(DISTINCT o.order_id) as Order_Count,
ROUND(SUM(oi.quantity * oi.unit_price),2) as Total_sales

FROM orders as o JOIN order_items as oi
ON o.order_id = oi.order_id

GROUP BY Payment_Method, Delivery_Status
ORDER BY Total_sales DESC;


-- Q9. Detect outliers in order quantities and unit prices to find potential data entry errors or fraud.
WITH stats AS (
SELECT	AVG(oi.quantity) AS AVG_quantity,
        STDDEV(oi.quantity) AS Std_quantity,
        AVG(unit_price) AS AVG_unit_price,
        STDDEV(unit_price) AS Std_unit_price
        FROM order_items oi
),
OUTLINERS AS (
	SELECT order_id, 
		product_id, 
		quantity, 
		unit_price
        FROM order_items, stats
WHERE 
		quantity > AVG_quantity + 3 * Std_quantity OR
		quantity < AVG_quantity - 3 * Std_quantity OR
        unit_price > AVG_unit_price + 3 * Std_unit_price OR
        unit_price < AVG_unit_price - 3 * Std_unit_price
)
SELECT * FROM OUTLINERS;
    



-- Q10. Generate a trend analysis of product stock levels over the past 12 months to forecast restocking needs.

SELECT p.product_name as Product_Name,
DATE_FORMAT(o.order_date, '%Y-%M') AS Month,
AVG(p.max_stock_level) as AVG_stock_level,
p.max_stock_level as Max_level,
p.min_stock_level as Min_level


FROM products as p JOIN order_items as oi
ON p.product_id OR oi.product_id 
JOIN orders as o
ON o.order_id AND oi.order_id

WHERE o.order_date >= current_date() - INTERVAL 12 month

GROUP BY Product_Name, DATE_FORMAT(o.order_date, '%Y-%M'), p.max_stock_level, p.min_stock_level
ORDER BY Product_Name, Month;


 
 select adddate(order_date, interval 12 month)
 from orders;





