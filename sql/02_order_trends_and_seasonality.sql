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
