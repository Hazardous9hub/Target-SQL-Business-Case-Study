-- ====================================================================
-- TARGET BRAZIL E-COMMERCE SQL CASE STUDY
-- Part 1: Dataset Structure, Schema & Initial Exploration
-- Platform: Google BigQuery
-- Author: Shivaling Battarki
-- ====================================================================

-- 1.1 Data type of all columns in the "customers" table
SELECT *
FROM `target_sql.customers`;

-- 1.2 Get the time range between which the orders were placed (Day-wise & Hourly patterns)
SELECT
  FORMAT_DATE('%a', order_purchase_timestamp) AS day_of_week,
  MIN(EXTRACT(TIME FROM order_purchase_timestamp)) AS earliest_time_of_order,
  MAX(EXTRACT(TIME FROM order_purchase_timestamp)) AS latest_time_of_order,
  AVG(EXTRACT(HOUR FROM order_purchase_timestamp)) AS avg_time_of_ordering
FROM `target_sql.orders`
WHERE order_status = 'delivered'
GROUP BY FORMAT_DATE('%a', order_purchase_timestamp);

-- 1.2 (Contd.) Get the date range between which the orders were placed
SELECT 
  MAX(DATE(order_purchase_timestamp)) AS latest_order_placed,
  MIN(DATE(order_purchase_timestamp)) AS first_order_placed,
  DATE_DIFF(MAX(DATE(order_purchase_timestamp)),
            MIN(DATE(order_purchase_timestamp)), MONTH) AS order_month_span
FROM `target_sql.orders`
WHERE order_status = 'delivered';

-- 1.3 Count the distinct Cities & States of customers who ordered during the given period
SELECT 
  COUNT(DISTINCT c.customer_state) AS count_of_states,
  COUNT(DISTINCT c.customer_city) AS count_of_cities
FROM `target_sql.customers` c 
JOIN `target_sql.orders` o
  ON c.customer_id = o.customer_id;
