-- Customer Table validation

SELECT
    COUNT(*) AS total_customers, -- Total row count
    COUNT(DISTINCT Customer_id) AS unique_customers, -- Unique count of Customers
    COUNT(DISTINCT CASE WHEN first IS NULL OR last IS NULL OR Age IS NULL OR Country_code IS NULL THEN Customer_id END) AS null_values, -- Check if null values is present
    MIN(Age) AS min_age, -- check if any Outliers in Age columns (negative)
    MAX(Age) AS max_age -- check if any Outliers in Age columns (more than 100)
FROM customer;

SELECT
    DISTINCT Customer_id, COUNT(*) AS unique_customers -- Check if Customer id has duplicate entries
FROM customer
GROUP BY 1
HAVING  unique_customers > 1;

SELECT
    DISTINCT country_code -- check if any Outliers in Countries columns
FROM customer;

SELECT
    COUNT(DISTINCT Customer_id) AS unique_customers_with_outliers -- check if any Outliers in name columns
FROM customer
WHERE first ~ '%[^a-zA-Z]%' or last ~ '%[^a-zA-Z]%';

-- Orders Table validation

SELECT
    COUNT(*) AS total_orders, -- Total row count
    COUNT(DISTINCT order_id) AS unique_orders, -- Unique count of Orders
    COUNT(DISTINCT CASE WHEN item IS NULL OR Amount IS NULL OR Customer_id IS NULL THEN Customer_id END) AS null_values, -- Check if null values is present
    MIN(Amount) AS min_amount, -- check if Outliers in Amount columns
    MAX(Amount) AS max_amount, -- check if Outliers in Amount columns
    COUNT(DISTINCT item) AS unique_items -- Unique count of Items
FROM orders;

SELECT
    DISTINCT order_id, COUNT(*) AS unique_orders -- Check if Order id has duplicate entries
FROM orders
GROUP BY 1
HAVING  unique_orders > 1;

SELECT
    DISTINCT item, amount,COUNT(DISTINCT Order_id) AS unique_orders -- Unique Items and amount
FROM orders
GROUP BY 1,2;

SELECT
    DISTINCT item, AVG(amount) AS avg_amount -- Unique Items and average amount
FROM orders
GROUP BY 1;

SELECT
    COUNT(DISTINCT o.customer_id) AS unique_customers_with_orders, -- Count of Customers with orders
    COUNT(DISTINCT CASE WHEN o.customer_id IS NULL and c.customer_id IS NOT NULL THEN c.customer_id END) AS unique_customers_without_orders, -- Count of Customers without orders
    COUNT(DISTINCT CASE WHEN o.customer_id IS NOT NULL and c.customer_id IS NULL THEN o.customer_id END) AS invalid_customer_ids, -- count of invalid customer id
    COUNT(DISTINCT CASE WHEN o.customer_id IS NOT NULL and c.customer_id IS NULL THEN o.order_id END) AS invalid_customer_orders_count -- count of order and without valid customer id
FROM orders o
FULL OUTER JOIN customer c on c.customer_id = o.customer_id;

-- Shipping Table validation

SELECT
    COUNT(*) AS total_shippings, -- Total row count
    COUNT(DISTINCT shipping_id) AS unique_shippings, -- Unique count of Orders
    COUNT(DISTINCT CASE WHEN Status IS NULL OR customer_id IS NULL THEN shipping_id END) AS null_values -- Check if null values is present
FROM Shipping;

SELECT
    DISTINCT Status -- DISTINCT status check
FROM Shipping;

SELECT
    DISTINCT shipping_id, COUNT(*) AS unique_entries -- Check if shipping id has duplicate entries in status
FROM Shipping
GROUP BY 1
HAVING  unique_entries > 1;

SELECT
    COUNT(DISTINCT CASE WHEN s.customer_id IS NOT NULL and c.customer_id IS NULL THEN s.customer_id END) AS invalid_customer_ids, -- count of invalid customer id
    COUNT(DISTINCT CASE WHEN s.customer_id IS NOT NULL and c.customer_id IS NULL THEN s.shipping_id END) AS invalid_customer_shipping_id_count -- count of shipping id and without valid customer id
FROM Shipping s
FULL OUTER JOIN customer c on c.customer_id = s.customer_id;

-- This shows the customer_id in shipping table is have discrepency and customer_id should be considered has order_id
SELECT
    COUNT(DISTINCT CASE WHEN s.customer_id IS NOT NULL and o.customer_id IS NULL THEN s.customer_id END) AS invalid_customer_ids, -- count of invalid customer id
    COUNT(DISTINCT CASE WHEN s.customer_id IS NOT NULL and o.customer_id IS NULL THEN s.shipping_id END) AS invalid_customer_shipping_id_count -- count of shipping id and without valid customer id
FROM Shipping s
FULL OUTER JOIN orders_log o on o.customer_id = s.customer_id;


SELECT
    COUNT(DISTINCT CASE WHEN s.customer_id IS NOT NULL and o.order_id IS NULL THEN s.customer_id END) AS invalid_customer_ids, -- count of invalid customer id
    COUNT(DISTINCT CASE WHEN s.customer_id IS NOT NULL and o.order_id IS NULL THEN s.shipping_id END) AS invalid_customer_shipping_id_count -- count of shipping id and without valid customer id
FROM Shipping s
FULL OUTER JOIN orders_log o on o.order_id = s.customer_id;
