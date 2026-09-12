-- ====================================================================
-- TARGET BRAZIL E-COMMERCE SQL BUSINESS CASE STUDY (COMPLETE SCRIPT)
-- Platform: Google BigQuery
-- Author: Shivaling Battarki (shivalingb09@gmail.com)
-- Dataset: Brazilian E-Commerce operations (99K+ orders, 2016-2018)
-- ====================================================================

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


-- ====================================================================
-- TARGET BRAZIL E-COMMERCE SQL CASE STUDY
-- Part 2: Order Trends & Seasonality Analysis
-- Platform: Google BigQuery
-- Author: Shivaling Battarki
-- ====================================================================

-- 2.1 Is there a growing trend in the no. of orders placed over the past years?
SELECT 
  EXTRACT(YEAR FROM order_purchase_timestamp) AS years,
  COUNT(order_id) AS total_orders
FROM `target_sql.orders`
GROUP BY EXTRACT(YEAR FROM order_purchase_timestamp)
ORDER BY years;

-- 2.2 Can we see some kind of monthly seasonality in terms of the no. of orders being placed?
SELECT
  FORMAT_DATE('%B', order_purchase_timestamp) AS months,
  COUNT(order_id) AS total_orders
FROM `target_sql.orders`
GROUP BY FORMAT_DATE('%B', order_purchase_timestamp),
  EXTRACT(MONTH FROM order_purchase_timestamp)
ORDER BY EXTRACT(MONTH FROM order_purchase_timestamp);

-- 2.3 During what time of the day do Brazilian customers mostly place their orders?
-- Categorization:
-- 0-6 hrs  : Dawn
-- 7-12 hrs : Morning
-- 13-18 hrs: Afternoon
-- 19-23 hrs: Night
WITH hours AS (
  SELECT 
    order_id,
    EXTRACT(HOUR FROM order_purchase_timestamp) AS oh
  FROM `target_sql.orders`
),
tod AS (
  SELECT
    order_id,
    CASE 
      WHEN oh BETWEEN 0 AND 6 THEN 'Dawn'
      WHEN oh BETWEEN 7 AND 12 THEN 'Morning'
      WHEN oh BETWEEN 13 AND 18 THEN 'Afternoon'
      ELSE 'Night' 
    END AS time_of_day
  FROM hours
)
SELECT 
  time_of_day,
  COUNT(order_id) AS total_orders
FROM tod
GROUP BY time_of_day
ORDER BY
  CASE 
    WHEN time_of_day = 'Dawn' THEN 1
    WHEN time_of_day = 'Morning' THEN 2
    WHEN time_of_day = 'Afternoon' THEN 3
    ELSE 4 
  END;


-- ====================================================================
-- TARGET BRAZIL E-COMMERCE SQL CASE STUDY
-- Part 3: Evolution of Orders & Customer Distribution Across States
-- Platform: Google BigQuery
-- Author: Shivaling Battarki
-- ====================================================================

-- 3.1 Get the month on month no. of orders placed in each state
SELECT
  c.customer_state,
  FORMAT_DATETIME('%Y-%m', o.order_purchase_timestamp) AS order_months,
  COUNT(o.order_id) AS total_orders
FROM `target_sql.customers` c 
JOIN `target_sql.orders` o
  ON c.customer_id = o.customer_id
GROUP BY
  c.customer_state,
  FORMAT_DATETIME('%Y-%m', o.order_purchase_timestamp)
ORDER BY c.customer_state, order_months;

-- 3.2 How are customers distributed across all the states?
SELECT 
  customer_state,
  COUNT(customer_unique_id) AS total_customers
FROM `target_sql.customers`
GROUP BY customer_state
ORDER BY total_customers DESC;


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


-- ====================================================================
-- TARGET BRAZIL E-COMMERCE SQL CASE STUDY
-- Part 5: Delivery Performance & Logistics Analysis
-- Platform: Google BigQuery
-- Author: Shivaling Battarki
-- ====================================================================

-- 5.1 Delivery duration (days) and difference between estimated vs actual delivery date
SELECT 
  order_id,
  DATE(order_purchase_timestamp) AS order_placed_date,
  DATE(order_delivered_customer_date) AS order_delivered_cust_date,
  DATE(order_estimated_delivery_date) AS estimated_delivery_date,
  DATE_DIFF(order_delivered_customer_date, order_purchase_timestamp, DAY) AS time_to_deliver,
  DATE_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY) AS diff_estimated_delivery
FROM `target_sql.orders`
WHERE order_delivered_customer_date IS NOT NULL;

-- 5.2 Top 5 states with Highest & Lowest average freight value (using DENSE_RANK)
WITH cte1 AS (
  SELECT 
    order_id,
    c.customer_state,
    ROUND(SUM(i.freight_value), 2) AS order_freight_value
  FROM `target_sql.orders` o
  JOIN `target_sql.order_items` i USING (order_id)
  JOIN `target_sql.customers` c USING (customer_id)
  GROUP BY order_id, customer_state
),
cte2 AS (
  SELECT 
    customer_state,
    ROUND(AVG(order_freight_value), 2) AS total_avg_freight_value,
    DENSE_RANK() OVER (ORDER BY AVG(order_freight_value) DESC) AS highranks,
    DENSE_RANK() OVER (ORDER BY AVG(order_freight_value)) AS lowranks
  FROM cte1
  GROUP BY customer_state
  ORDER BY total_avg_freight_value DESC
)
SELECT 
  customer_state,
  total_avg_freight_value,
  CASE
    WHEN highranks <= 5 THEN 'top 5 highest'
    WHEN lowranks <= 5 THEN 'top 5 lowest'
  END AS top5_high_low
FROM cte2
WHERE highranks <= 5 OR lowranks <= 5
ORDER BY total_avg_freight_value DESC;

-- 5.3 Top 5 states with Highest & Lowest average delivery time (using DENSE_RANK)
WITH dt AS (
  SELECT
    o.order_id,
    c.customer_state,
    DATE_DIFF(order_delivered_customer_date, order_purchase_timestamp, DAY) AS time_to_deliver
  FROM `target_sql.orders` o
  JOIN `target_sql.customers` c USING (customer_id)
  WHERE order_delivered_customer_date IS NOT NULL
),
tr AS (
  SELECT
    customer_state,
    ROUND(AVG(time_to_deliver), 2) AS avg_delivery_time,
    DENSE_RANK() OVER (ORDER BY AVG(time_to_deliver) DESC) AS high_rank,
    DENSE_RANK() OVER (ORDER BY AVG(time_to_deliver)) AS low_rank
  FROM dt
  GROUP BY customer_state
)
SELECT 
  customer_state,
  avg_delivery_time,
  CASE
    WHEN high_rank <= 5 THEN 'top 5 highest'
    WHEN low_rank <= 5 THEN 'top 5 lowest'
  END AS top5_high_low
FROM tr
WHERE high_rank <= 5 OR low_rank <= 5
ORDER BY avg_delivery_time DESC;

-- 5.4 Top 5 states where order delivery was faster than estimated delivery date
WITH dd AS (
  SELECT
    o.order_id,
    c.customer_state,
    DATE_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY) AS del_days_diff
  FROM `target_sql.customers` c 
  JOIN `target_sql.orders` o USING (customer_id)
  WHERE order_delivered_customer_date IS NOT NULL
), 
ddr AS (
  SELECT
    customer_state,
    ROUND(AVG(del_days_diff), 2) AS avg_del_days,
    DENSE_RANK() OVER (ORDER BY AVG(del_days_diff)) AS del_ranks
  FROM dd
  GROUP BY customer_state
)
SELECT
  customer_state,
  avg_del_days,
  del_ranks AS top_5_fastest_delivery
FROM ddr
WHERE del_ranks <= 5
ORDER BY avg_del_days;


-- ====================================================================
-- TARGET BRAZIL E-COMMERCE SQL CASE STUDY
-- Part 6: Payment Methods & Installment Analysis
-- Platform: Google BigQuery
-- Author: Shivaling Battarki
-- ====================================================================

-- 6.1 Month-on-month number of orders placed using different payment types
SELECT
  FORMAT_DATETIME('%Y-%m', o.order_purchase_timestamp) AS order_month,
  p.payment_type,
  COUNT(DISTINCT p.order_id) AS total_orders
FROM `target_sql.payments` p
JOIN `target_sql.orders` o USING (order_id)
GROUP BY
  FORMAT_DATETIME('%Y-%m', o.order_purchase_timestamp),
  p.payment_type
ORDER BY order_month, p.payment_type;

-- 6.2 Number of orders placed on the basis of payment installments
SELECT 
  payment_installments,
  COUNT(DISTINCT order_id) AS total_orders
FROM `target_sql.payments`
GROUP BY payment_installments
ORDER BY total_orders DESC, payment_installments;

