-- I created a Schema, more or less like a container to hold the tables
-- Then I imported the tables using the Table Data IMport Wizard fxn

SELECT * 
FROM customers;





SELECT *
FROM order_items;

SELECT *
FROM orders
LIMIT 10;

SELECT *
FROM payments;

SELECT * 
FROM products; 

-- DATA CLEANING 
-- Check for duplicate customer IDs
SELECT customer_id, COUNT(*) AS cnt
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Checked for NULLs in key columns
SELECT *
FROM customers
WHERE customer_id IS NULL
   OR location IS NULL;
   
-- Orders without dates
SELECT *
FROM orders
WHERE order_date IS NULL;
-- This process was repeated for key columns in all tables. 
-- Data Cleaning & Validation (MySQL):
-- Performed data quality checks in MySQL to identify duplicates, missing values,
 -- invalid records, and broken relationships across all tables. 
 -- The validation queries returned no anomalies, confirming that the dataset was clean and required no 
 -- corrective actions before analysis
 
 -- Key Metrics & Analysis
 -- 1. Total Revenue 
 -- The dataset does not contain refund information. To avoid making unsupported assumptions, revenue is calculated 
 -- based on successful payments only.
 -- Cancelled orders are included because there is no evidence that payments were refunded.
 SELECT SUM(oi.quantity * oi.unit_price) 
 FROM order_items oi
 INNER JOIN payments py
 ON oi.order_id = py.order_id
 WHERE py.payment_status = "Successful";
 -- Total gross revenue #423,334 
 
 -- 2. Total sales in 2024 
 SELECT 
    SUM(oi.quantity * oi.unit_price) AS total_sales_2024
FROM order_items oi
INNER JOIN payments py
    ON oi.order_id = py.order_id
WHERE YEAR(py.payment_date) = 2024 AND py.payment_status = "Successful";
-- In 2024, total sales revenue actualized irrespective of order_status was #294,095. 

 -- Total Sales by mid 2025
 SELECT SUM(oi.quantity * oi.unit_price) AS total_sales_mid_2025
FROM order_items oi
INNER JOIN payments py
    ON oi.order_id = py.order_id
WHERE YEAR(py.payment_date) = 2025 AND py.payment_status = "Successful";
-- Sales by Jan - June of 2025, we have already actualized close to 50% of the revenue generated in the past year 
-- which tells us that business has been the same; no increase or decrease in purchase. 

 
 
-- BUSINESS QUESTIONS
-- 1. Which products generates the highest total sales?
SELECT 
    p.product_name,
    SUM(oi.quantity * oi.unit_price) AS total_sales
FROM order_items oi
JOIN products p 
    ON oi.product_id = p.product_id
JOIN payments py
    ON oi.order_id = py.order_id
WHERE py.payment_status = "Successful"
GROUP BY p.product_name
ORDER BY total_sales DESC;
-- Sales analysis was based on succesful payments irrespective of order_status only to reflect total gross revenue.

-- 2. Which product categories perform best in sales? 
   SELECT
    p.category,
    SUM(oi.quantity * oi.unit_price) AS total_sales
FROM order_items oi
INNER JOIN products p 
ON oi.product_id = p.product_id
INNER JOIN payments py
ON oi.order_id = py.order_id
WHERE py.payment_status = "Successful"
GROUP BY p.category
ORDER BY total_sales DESC;
-- Same as above 

-- 3. How many orders are completed, cancelled, or pending?
SELECT order_status,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;
-- Cancelled orders are more compared to pending and completed orders; which is only 1/3 of the total orders

-- 4. Do failed payments affect order completion
SELECT
		py.payment_status,
		COUNT(DISTINCT o.order_id) AS TotalOrders,
		SUM(CASE WHEN order_status = 'Completed' THEN 1 ELSE 0 END) AS completed_orders,
		ROUND( 100.0 * SUM(CASE WHEN order_status = 'Completed' THEN 1 ELSE 0 END)/ COUNT(DISTINCT o.order_id), 2) AS completion_rate_percentage
		FROM orders o
		INNER JOIN payments py
		ON o.order_id = py.order_id
		GROUP BY py.payment_status;
-- Failed payments have a completion rate of 30.79% while successful payments have a completion rate of 32.42%. 
-- Initial analysis shows similar order completion rates for failed and successful payments (30.79% vs 32.42%),
-- suggesting that payment status alone does not strongly influence order completion. 
-- This may be due to multiple payment attempts per order or alternative payment methods.

-- 5. Which customers place the most orders?
 SELECT c. customer_id, c.customer_name,
COUNT(o.order_id) AS total_order
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY customer_id, customer_name
ORDER BY total_order DESC;
-- Anna Ojo is the customer that places the most orders
-- followed by John Okafor, Peter Williams, James Okoye, Daniel Ahmed. These customers should be given
-- rewards at the end of purchase year and placed on discounts for certain products for  customer retention

-- 6. Which locations generate the most sales? 
SELECT c.location, 
SUM(oi.quantity * oi.unit_price) AS total_sales
FROM customers c 
INNER JOIN orders o 
ON c.customer_id = o.customer_id
INNER JOIN order_items oi
ON o.order_id = oi.order_id
INNER JOIN payments py
ON o.order_id = py.order_id
WHERE py.payment_status = 'Successful'
GROUP BY c.location
ORDER BY total_sales DESC; 
-- Lagos generates the highest sales, contributing ₦147,400, significantly outperforming other locations.
-- This is followed by Abuja (₦104,089), Ibadan (₦87,878), and Port Harcourt (₦83,967).
-- The results indicate that sales revenue is heavily concentrated in Lagos, suggesting stronger customer
-- demand or higher purchasing power in that location compared to others.
-- Recommendation
-- i) Allocate more marketing spend, inventory, or promotional campaigns to Lagos to maximize returns, 
-- as it consistently generates the highest sales. High performing markets give the fastest ROI.
-- ii) Abuja shows strong sales performance and could benefit from targeted campaigns or product
-- bundles to close the gap with Lagos. Abuja is high-potential
-- iii) Conduct further analysis on Ibadan and Port Harcourt to identify barriers such as customer volume,
-- order frequency, or payment success rates, and address them through localized strategies.

-- 7. Do orders increase, remain stable or decline over time?
	SELECT
		YEAR(o.order_date) AS year,
		MONTH(o.order_date) AS month,
		COUNT(*) AS total_orders
		FROM orders o
		GROUP BY YEAR(o.order_date), MONTH(o.order_date)
		ORDER BY year, month;
-- Order volume shows clear seasonality, with a 23.6% spike above the annual average in July 2024 and a 21.0% drop in December. 
-- Average monthly orders increased from 68.4 in Jan–May 2024 to 72.6 in Jan–May 2025 (+6.1% YoY), 
-- indicating modest growth in early 2025. June 2025 data is incomplete and excluded from trend interpretation.
        
-- 8. How much orders do each customer place every month
    SELECT 
    c.customer_name,
    YEAR(o.order_date) AS year,
    COUNT(*) AS total_orders
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_name, YEAR(o.order_date)
ORDER BY c.customer_name, year, total_orders;
-- Calculated yearly order totals per customer to identify high- and low-frequency buyers over time


-- 9. What % of orders are completed, pending, cancelled? 
SELECT COUNT(order_id) AS total_orders,
SUM(CASE WHEN order_status = "Completed" THEN 1 ELSE 0 END) AS completed_orders,
SUM(CASE WHEN order_status = "Pending" THEN 1 ELSE 0 END) AS pending_orders,
SUM(CASE WHEN order_status = "Cancelled" THEN 1 ELSE 0 END) AS cancelled_orders,
ROUND( 100.0 * SUM(CASE WHEN order_status = "Completed" THEN 1 ELSE 0 END)/ COUNT(order_id), 2) AS completion_rate_percentage,
ROUND( 100.0 * SUM(CASE WHEN order_status = "Pending" THEN 1 ELSE 0 END)/ COUNT(order_id), 2) AS pending_rate_percentage,
ROUND( 100.0 * SUM(CASE WHEN order_status = "Cancelled" THEN 1 ELSE 0 END)/ COUNT(order_id), 2) AS cancel_rate_percentage
FROM orders; 
-- Only 31.58% of orders are completed, while 68.42% are either pending (33.25%) or cancelled (35.17%). 
-- This indicates a significant drop-off after order placement, suggesting issues in payment completion or
-- customer follow-through.

-- The high cancellation rate represents lost revenue, and the large share of pending orders highlights 
-- opportunities to improve conversion through better payment reliability, reminders, or checkout optimization.

-- 10. Which customers generate the highest revenue? 
    SELECT 
    c.customer_name,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_name
ORDER BY total_revenue DESC
LIMIT 5;
-- The customer with the highest number of orders is not necessarily the highest revenue generator, 
-- indicating that some customers place frequent low-value orders while others place fewer high-value purchases.
-- Revenue is driven more by order value than order frequency, highlighting the importance of 
-- targeting high-spend customers.

-- 11. 
SELECT 
    c.customer_name,
    YEAR(o.order_date) AS year,
    MONTH(o.order_date) AS month,
    COUNT(*) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_name, YEAR(o.order_date), MONTH(o.order_date)
ORDER BY c.customer_name, year, month;





        
