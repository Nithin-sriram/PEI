DROP TABLE IF EXISTS customers_attributes;

CREATE TABLE customers_attributes (
    customer_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    age INT NOT NULL,
    country_code CHAR(3) NOT NULL
  );

  INSERT INTO customers_attributes (customer_id, name, age, country_code)
  SELECT
      customer_ID,
      -- Remove special characters and numbers from names
      REGEXP_REPLACE(First, '[^a-zA-Z]', '') || ' ' || REGEXP_REPLACE(Last, '[^a-zA-Z]', '') AS name,
      Age,
      CASE WHEN country_code = 'USA' THEN 'USA'
          WHEN country_code = 'UK' THEN 'GBR'
          WHEN country_code = 'UAE' THEN 'ARE'
      END AS country_code
  FROM customer;

DROP TABLE IF EXISTS countries_attributes;

CREATE TABLE countries_attributes (
    country_code CHAR(3) PRIMARY KEY,
    country_name VARCHAR(50) NOT NULL
);

INSERT INTO countries_attributes (country_code, country_name)
VALUES
('USA', 'United States'),
('GBR', 'United Kingdom'),
('ARE', 'United Arab Emirates');

DROP TABLE IF EXISTS products_attributes;

CREATE TABLE products_attributes (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50) NOT NULL,
    price DECIMAL(10,2) NOT NULL
);

-- Insert products from order data with average prices
INSERT INTO products_attributes (product_id, product_name, price)
VALUES
(1, 'Keyboard', 400.00),
(2, 'Mouse', 300.00),
(3, 'Monitor', 12000.00),
(4, 'Mousepad', 225.00), -- Average of 200 and 250
(5, 'Harddisk', 5000.00),
(6, 'Webcam', 350.00),
(7, 'DDR RAM', 1500.00),
(8, 'Headset', 900.00);

DROP TABLE IF EXISTS orders_log;

CREATE TABLE orders_log (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL
);

INSERT INTO orders_log (order_id, customer_id, product_id, amount)
SELECT
    o.order_ID,
    o.customer_ID,
    CASE o.Item
        WHEN 'Keyboard' THEN 1
        WHEN 'Mouse' THEN 2
        WHEN 'Monitor' THEN 3
        WHEN 'Mousepad' THEN 4
        WHEN 'Harddisk' THEN 5
        WHEN 'Webcam' THEN 6
        WHEN 'DDR RAM' THEN 7
        WHEN 'Headset' THEN 8
    END AS product_id,
    o.Amount
FROM orders o
-- Filter customer that part of customers_attributes
WHERE o.customer_ID IN (SELECT customer_id FROM customers_attributes);

DROP TABLE IF EXISTS shipping_attributes;

CREATE TABLE shipping_attributes (
    shipping_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    current_status VARCHAR(20) NOT NULL
);

INSERT INTO shipping_attributes (shipping_id, order_id, current_status)
SELECT
    s.shipping_id,
    s.customer_id as order_id,
    s.status AS current_status
FROM Shipping s
-- Filter customer that part of customers_attributes
WHERE s.customer_ID IN (SELECT customer_id FROM customers_attributes);
