-- Create the database
CREATE DATABASE mydb;
USE mydb;

-- 1. Create Customers Table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    region VARCHAR(50) NOT NULL,
    signup_date DATE NOT NULL,
    segment VARCHAR(50) DEFAULT 'Consumer'
);

-- 2. Create Orders Table
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    category VARCHAR(50) NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

Select* from Customers;
Select* from Orders;

-- Question 1: What are our overall sales metrics?
SELECT 
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS total_units_sold,
    SUM(total_amount) AS gross_revenue,
    ROUND(AVG(total_amount), 2) AS avg_order_value
FROM orders;


-- Question 2: Which orders are considered high-value (>= $150)?
SELECT order_id, customer_id, category, product_name, total_amount
FROM orders
WHERE total_amount >= 150.00
ORDER BY total_amount DESC;


-- Question 3: What is our revenue breakdown by product category?
SELECT 
    category,
    COUNT(order_id) AS total_orders,
    SUM(total_amount) AS total_revenue
FROM orders
GROUP BY category
ORDER BY total_revenue DESC;


-- Question 4: What is the average order spend per category?
SELECT 
    category,
    ROUND(AVG(total_amount), 2) AS category_aov
FROM orders
GROUP BY category
ORDER BY category_aov DESC;


-- Question 5: How are our customers distributed geographically?
SELECT 
    region,
    COUNT(customer_id) AS total_customers
FROM customers
GROUP BY region
ORDER BY total_customers DESC;


-- Question 6: Who are our top customers by Lifetime Value (LTV)?
SELECT 
    c.customer_id,
    c.customer_name,
    SUM(o.total_amount) AS customer_ltv
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY customer_ltv DESC;


-- Question 7: What does the complete transaction log look like?
SELECT 
    o.order_id,
    c.customer_name,
    c.region,
    o.category,
    o.product_name,
    o.total_amount
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
ORDER BY o.order_date ASC;


-- Question 8: Which region generates the most sales revenue?
SELECT 
    c.region,
    COUNT(o.order_id) AS order_count,
    SUM(o.total_amount) AS regional_revenue
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.region
ORDER BY regional_revenue DESC;


-- Question 9: How do customers classify into spend tiers?
SELECT 
    c.customer_name,
    c.segment,
    SUM(o.total_amount) AS total_spent,
    CASE 
        WHEN SUM(o.total_amount) >= 800 THEN 'Tier 1 (VIP)'
        WHEN SUM(o.total_amount) BETWEEN 300 AND 799 THEN 'Tier 2 (Mid-Tier)'
        ELSE 'Tier 3 (Low Volume)'
    END AS account_tier
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name, c.segment
ORDER BY total_spent DESC;


-- Question 10: What is the highest revenue product in each category?
WITH RankedProducts AS (
    SELECT 
        category,
        product_name,
        SUM(total_amount) AS revenue,
        DENSE_RANK() OVER (PARTITION BY category ORDER BY SUM(total_amount) DESC) AS ranking
    FROM orders
    GROUP BY category, product_name
)
SELECT category, product_name, revenue
FROM RankedProducts
WHERE ranking = 1;