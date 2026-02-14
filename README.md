# Retail Sales & Customer Behaviour Analysis

## Introduction
RetailMart is an e-commerce company operating in the retail industry, selling products online across multiple locations. Despite healthy sales activity, management is concerned about order cancellations, failed payments, low-value customers, and overall product performance.
This project uses SQL analysis to understand customer purchasing behavior, evaluate sales performance, and identify operational issues affecting order completion and revenue realization.

## Problem Statement
RetailMart needs to understand why a large number of orders are not completed, how payments impact order success, and which customers and products drive revenue.
This analysis aims to answer key business questions around order status distribution, customer revenue contribution, purchasing frequency, and sales performance to support better data-driven decisions.

## Data Sourcing 
The dataset was sourced from a relational database and imported into MySQL. It consists of five tables representing an e-commerce transaction system:
  - customers
  - orders
  - order_items
  - payments
  - products
    
The data covers transactions for 2024 to mid 2025 across different customers and products.

## Data Transformation & Cleaning 
Initial data checks were performed in MySQL to validate data quality. The dataset was reviewed for: 
- duplicate records
- missing values in key fields
- invalid prices (negative prices)
- broken relationships between tables
  
No data anomalies were found, no duplicates were found and no corrective cleaning actions were required before analysis.

## Analysis 
### 1. Total revenue per product
```sql
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
```

### 2. Total revenue per customer 
```sql
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
```

### 3. Total orders by status (Completed, Pending, Cancelled)
```sql
ELECT order_status,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;
```
### 5. Which customers place the most orders?
```sql
 SELECT c. customer_id, c.customer_name,
COUNT(o.order_id) AS total_order
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY customer_id, customer_name
ORDER BY total_order DESC;
```
### 6. What % of orders are completed, pending, cancelled?
```sql
SELECT COUNT(order_id) AS total_orders,
SUM(CASE WHEN order_status = "Completed" THEN 1 ELSE 0 END) AS completed_orders,
SUM(CASE WHEN order_status = "Pending" THEN 1 ELSE 0 END) AS pending_orders,
SUM(CASE WHEN order_status = "Cancelled" THEN 1 ELSE 0 END) AS cancelled_orders,
ROUND( 100.0 * SUM(CASE WHEN order_status = "Completed" THEN 1 ELSE 0 END)/ COUNT(order_id), 2) AS completion_rate_percentage,
ROUND( 100.0 * SUM(CASE WHEN order_status = "Pending" THEN 1 ELSE 0 END)/ COUNT(order_id), 2) AS pending_rate_percentage,
ROUND( 100.0 * SUM(CASE WHEN order_status = "Cancelled" THEN 1 ELSE 0 END)/ COUNT(order_id), 2) AS cancel_rate_percentage
FROM orders;
```
### 7. How much orders do each customer place every month?
```sql
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
```

### 8. Which locations generate the most sales? 
```sql
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
```

## Key Insights & Findings 
1. Total gross revenue #423,334.
2. In 2024, total sales revenue actualized irrespective of order_status was #294,095.
3. Sales by Jan - June of 2025, we have already actualized close to 50% of the revenue generated in the past year which tells us that business has been the same; no change in customer purchase behaviour.
4. Overall bags of rice was the product that generated the highest total sales of #129,850 which makes sense because it is consumed on a regular by customers.
5. Cancelled orders are more compared to pending and completed orders; which is only 1/3 of the total orders.
6.  Anna Ojo is the customer that places the most orders followed by John Okafor, Peter Williams, James Okoye, Daniel Ahmed. These customers should be given rewards at the end of purchase year and placed on discounts for certain products for customer retention.
7.  Only 31.58% of orders are completed, while 68.42% are either pending (33.25%) or cancelled (35.17%). This indicates a significant drop-off after order placement, suggesting issues in payment completion or
customer follow-through. The high cancellation rate represents lost revenue, and the large share of pending orders highlights opportunities to improve conversion through better payment reliability, reminders, or checkout optimization.
8. The customer with the highest number of orders is not necessarily the highest revenue generator, indicating that some customers place frequent low-value orders while others place fewer high-value purchases.
 Revenue is driven more by order value than order frequency, highlighting the importance of targeting high-spend customers.
9. Lagos generates the highest sales, contributing ₦147,400, significantly outperforming other locations. This is followed by Abuja (₦104,089), Ibadan (₦87,878), and Port Harcourt (₦83,967).
 The results indicate that sales revenue is heavily concentrated in Lagos, suggesting stronger customer demand or higher purchasing power in that location compared to others.

## Recommendations
- Allocate more marketing spend, inventory, or promotional campaigns to Lagos to maximize returns, as it consistently generates the highest sales. As a high performing market, it'll give the fastest ROI.
- Abuja shows strong sales performance and could benefit from targeted campaigns or product bundles to close the gap with Lagos. Abuja is high-potential
- Conduct further analysis on Ibadan and Port Harcourt to identify barriers such as customer volume, order frequency, or payment success rates, and address them through localized strategies.
- Maintain separate reporting for sales (successful payments) and order fulfillment (order status) to improve clarity in business decision-making.
- Investigate failed payment patterns and optimize the payment process to improve order completion and increase overall sales revenue.


## Conclusion
This project used SQL joins and analytical queries to evaluate RetailMart’s sales performance, customer behavior, and order completion issues.

The analysis highlights major revenue leakage due to cancellations and payment failures while identifying key revenue-driving customers and products.
Future analysis could include customer segmentation, lifetime value estimation, and deeper payment failure diagnostics.

