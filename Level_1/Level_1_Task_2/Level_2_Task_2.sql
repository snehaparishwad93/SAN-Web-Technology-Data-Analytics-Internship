CREATE DATABASE IF NOT EXISTS store_db;
USE store_db;
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    region VARCHAR(50)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    category VARCHAR(50),
    unit_price DECIMAL(10,2)
);

CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    order_date DATE,
    quantity INT,
    revenue DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);


INSERT INTO customers VALUES 
(1, 'Customer_1', 'North'), (2, 'Customer_2', 'South'), (3, 'Customer_3', 'East'), (4, 'Customer_4', 'West'), (5, 'Customer_5', 'North');

INSERT INTO products VALUES 
(1, 'Laptop', 'Electronics', 1200.00), (2, 'Headphones', 'Electronics', 150.00),
(3, 'Jacket', 'Apparel', 80.00), (4, 'Shoes', 'Apparel', 100.00),
(5, 'Blender', 'Home & Kitchen', 60.00);

INSERT INTO transactions VALUES 
(1, 1, 1, '2025-01-10', 1, 1200.00),
(2, 2, 3, '2025-01-12', 2, 160.00),
(3, 3, 2, '2025-01-15', 1, 150.00),
(4, 4, 5, '2025-01-18', 3, 180.00),
(5, 5, 4, '2025-01-20', 1, 100.00);



-- 1. Multi-Table Join
SELECT t.transaction_id, c.customer_name, c.region, p.product_name, t.revenue 
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
JOIN products p ON t.product_id = p.product_id;



-- 2. Category Performance (Aggregations)
SELECT p.category, COUNT(t.transaction_id) AS total_orders, SUM(t.revenue) AS total_revenue
FROM transactions t
JOIN products p ON t.product_id = p.product_id
GROUP BY p.category;

-- 3. CASE Expressions for Order Tiering
SELECT transaction_id, revenue,
    CASE 
        WHEN revenue > 500 THEN 'High Value'
        WHEN revenue BETWEEN 150 AND 500 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS order_tier
FROM transactions;

-- 4. CTE for Regional Share
WITH RegionalSales AS (
    SELECT c.region, SUM(t.revenue) AS regional_rev
    FROM transactions t
    JOIN customers c ON t.customer_id = c.customer_id
    GROUP BY c.region
)
SELECT region, regional_rev FROM RegionalSales;

-- 5. Window Function (RANK)
SELECT p.category, p.product_name, SUM(t.revenue) AS prod_rev,
    RANK() OVER (PARTITION BY category ORDER BY SUM(t.revenue) DESC) AS revenue_rank
FROM transactions t
JOIN products p ON t.product_id = p.product_id
GROUP BY p.category, p.product_name;

-- 6. Window Function (Running Total)
SELECT transaction_id, order_date, revenue,
    SUM(revenue) OVER (ORDER BY order_date, transaction_id) AS running_total
FROM transactions;

-- 7. Left Join to Find Inactive Customers
SELECT c.customer_id, c.customer_name 
FROM customers c
LEFT JOIN transactions t ON c.customer_id = t.customer_id
WHERE t.transaction_id IS NULL;

-- 8. Average Order Value by Region
SELECT c.region, AVG(t.revenue) AS avg_order_value
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
GROUP BY c.region;

-- 9. Top Spending Customer using CTE and LIMIT
WITH CustomerSpending AS (
    SELECT c.customer_name, SUM(t.revenue) AS total_spent
    FROM transactions t
    JOIN customers c ON t.customer_id = c.customer_id
    GROUP BY c.customer_name
)
SELECT customer_name, total_spent 
FROM CustomerSpending 
ORDER BY total_spent DESC LIMIT 1;

-- 10. Monthly Revenue Summary
SELECT DATE_FORMAT(order_date, '%Y-%m') AS order_month, SUM(revenue) AS monthly_revenue
FROM transactions
GROUP BY order_month;




