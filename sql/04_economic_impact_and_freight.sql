-- ====================================================================
-- TARGET BRAZIL E-COMMERCE SQL CASE STUDY
-- Part 4: Economic Impact - Order Values, Revenue Growth & Freight Costs
-- Platform: Google BigQuery
-- Author: Shivaling Battarki
-- ====================================================================

-- 4.1 Get the % increase in the cost of orders from year 2017 to 2018 (Jan to Aug only)
WITH tcs AS (
  SELECT
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS order_year,
    ROUND(SUM(p.payment_value), 2) AS order_total_cost
  FROM `target_sql.orders` o 
  JOIN `target_sql.payments` p
    ON o.order_id = p.order_id
  WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) IN (2017, 2018)
    AND EXTRACT(MONTH FROM o.order_purchase_timestamp) BETWEEN 01 AND 08
  GROUP BY EXTRACT(YEAR FROM o.order_purchase_timestamp)
), 
lags AS (
  SELECT
    order_year,
    order_total_cost,
    LAG(order_total_cost) OVER (ORDER BY order_year) AS pre_year_cost
  FROM tcs
)
SELECT
  order_year,
  order_total_cost,
  pre_year_cost,
  ROUND((order_total_cost - pre_year_cost) / pre_year_cost * 100, 2) AS percentage_growth
FROM lags
ORDER BY order_year;

-- 4.2 Calculate Total & Average value of order price for each state
-- Approach 1: Item-level aggregation to state
SELECT 
  c.customer_state,
  ROUND(SUM(i.price), 2) AS order_total_value,
  ROUND(AVG(i.price), 2) AS order_avg_value
FROM `target_sql.orders` o
JOIN `target_sql.order_items` i ON i.order_id = o.order_id
JOIN `target_sql.customers` c ON c.customer_id = o.customer_id
GROUP BY c.customer_state;

-- Approach 2: Order-level total price first, then state-level averaging
WITH cte1 AS (
  SELECT 
    i.order_id,
    c.customer_state,
    SUM(i.price) AS order_total_price
  FROM `target_sql.order_items` i
  JOIN `target_sql.orders` o ON o.order_id = i.order_id
  JOIN `target_sql.customers` c ON c.customer_id = o.customer_id
  GROUP BY i.order_id, c.customer_state
)
SELECT 
  customer_state,
  SUM(order_total_price) AS total_order_value,
  ROUND(AVG(order_total_price), 2) AS avg_order_value
FROM cte1
GROUP BY customer_state;

-- 4.3 Calculate Total & Average value of order freight for each state
WITH cte1 AS (
  SELECT 
    order_id,
    c.customer_state,
    SUM(freight_value) AS total_freight_value
  FROM `target_sql.orders` o
  JOIN `target_sql.order_items` i USING (order_id)
  JOIN `target_sql.customers` c USING (customer_id)
  GROUP BY order_id, c.customer_state
)
SELECT 
  customer_state,
  ROUND(SUM(total_freight_value), 2) AS total_order_freight_value,
  ROUND(AVG(total_freight_value), 2) AS avg_freight_value
FROM cte1
GROUP BY customer_state
ORDER BY total_order_freight_value DESC;
