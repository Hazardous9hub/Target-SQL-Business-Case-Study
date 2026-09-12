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
