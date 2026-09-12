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
