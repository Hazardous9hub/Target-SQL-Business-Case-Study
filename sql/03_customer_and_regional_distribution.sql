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
