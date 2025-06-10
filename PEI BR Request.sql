-- BR Request 1 total amount spent and the country for the Pending delivery status

SELECT
    c.country_name,
    SUM(o.amount) as total_amount
FROM 
    orders_log o
LEFT JOIN customers_attributes ca ON o.customer_id = ca.customer_id
LEFT JOIN countries_attributes c ON ca.country_code = c.country_code
LEFT JOIN shipping_attributes s ON o.order_id = s.order_id
WHERE s.current_status = 'Pending'
GROUP BY 1
ORDER BY 2 DESC;

-- the total number of transactions, total quantity sold, and total amount spent for each customer

WITH order_stats AS (
    SELECT
        o.customer_id,
        cu.name as customer_name,
        COUNT(DISTINCT order_id) as transaction_count,
        COUNT(DISTINCT order_id) as total_quantity,
        SUM(amount) as total_amount
    FROM orders_log o
    LEFT JOIN customers_attributes cu ON o.customer_id = cu.customer_id
    GROUP BY 1,2
),
product_list AS (
    SELECT
        o.customer_id,
        LISTAGG(DISTINCT p.product_name, ' | ') WITHIN GROUP (ORDER BY p.product_id) as products_purchased
    FROM orders_log o
    JOIN products_attributes p ON o.product_id = p.product_id
    GROUP BY 1
)
SELECT
    os.customer_id,
    os.customer_name,
    pl.products_purchased,
    os.transaction_count,
    os.total_quantity,
    os.total_amount
FROM order_stats os
LEFT JOIN product_list pl ON os.customer_id = pl.customer_id
ORDER BY 6 DESC;

-- maximum product purchased for each country

DROP TABLE IF EXISTS product_sales_at_country_level;

CREATE TEMP TABLE product_sales_at_country_level AS

SELECT
    c.country_name,
    p.product_name,
    COUNT(DISTINCT o.order_id) as purchase_count,
    -- Future proof to select top 3 products across Countries
    DENSE_RANK() OVER (PARTITION BY c.country_name ORDER BY COUNT(o.order_id) DESC) as orders_rank
FROM
    orders_log o
LEFT JOIN customers_attributes cu ON o.customer_id = cu.customer_id
LEFT JOIN countries_attributes c ON cu.country_code = c.country_code
LEFT JOIN products_attributes p ON o.product_id = p.product_id
GROUP BY 1,2;

SELECT
    country_name,
    product_name,
    purchase_count
FROM
    product_sales_at_country_level
WHERE orders_rank = 1;

-- most purchased product based on the age category

DROP TABLE IF EXISTS product_sales_at_age_group_level;

CREATE TEMP TABLE product_sales_at_age_group_level AS

SELECT
    CASE WHEN Age < 30 THEN 'Under 30' ELSE 'Above 30' END AS age_group,
    p.product_name,
    COUNT(DISTINCT o.order_id) as purchase_count,
    DENSE_RANK() OVER (PARTITION BY age_group ORDER BY purchase_count DESC) as rank
FROM
    orders_log o
LEFT JOIN customers_attributes cu ON o.customer_id = cu.customer_id
LEFT JOIN products_attributes p ON o.product_id = p.product_id
GROUP BY 1,2;

SELECT
    age_group,
    product_name,
    purchase_count
FROM
    product_sales_at_age_group_level
WHERE
    rank = 1;

-- country that had minimum transactions and sales amount

SELECT
    c.country_name,
    COUNT(o.order_id) as transaction_count,
    SUM(o.amount) as total_amount
FROM
    orders_log o
LEFT JOIN customers_attributes cu ON o.customer_id = cu.customer_id
LEFT JOIN countries_attributes c ON cu.country_code = c.country_code
GROUP BY 1
ORDER BY 2,3 ASC
LIMIT 1;

SELECT
    c.country_name,
    COUNT(o.order_id) as transaction_count,
    SUM(o.amount) as total_amount,
    AVG(o.amount) as avg_amount
FROM
    orders_log o
LEFT JOIN customers_attributes cu ON o.customer_id = cu.customer_id
LEFT JOIN countries_attributes c ON cu.country_code = c.country_code
GROUP BY 1
ORDER BY 2,3 asc;
