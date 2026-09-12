# 🛒 Target Brazil E-Commerce: Business Problem & Relational Data Architecture

## 📌 Context
Target is one of the world's most recognizable retail powerhouses. This case study focuses on Target's operations in Brazil, analyzing 100,000 orders placed between September 2016 and August 2018.

The business objective is to analyze customer purchasing behavior, macroeconomic order value growth, regional fulfillment bottlenecks, freight cost variations, and payment preferences across 27 Brazilian states.

---

## 🏗️ Relational Schema & Tables

The dataset consists of 6 core relational tables queried in Google BigQuery:

1. **`customers`** (`99,441 rows`):
   - `customer_id` (PK / per-order customer key)
   - `customer_unique_id` (Unique identifier for returning customers)
   - `customer_zip_code`, `customer_city`, `customer_state`
2. **`orders`** (`99,441 rows`):
   - `order_id` (PK)
   - `customer_id` (FK to customers)
   - `order_status` ('delivered', 'shipped', 'canceled', etc.)
   - `order_purchase_timestamp`
   - `order_approved_at`
   - `order_delivered_carrier_date`
   - `order_delivered_customer_date`
   - `order_estimated_delivery_date`
3. **`order_items`** (`112,650 rows`):
   - `order_id` (FK to orders)
   - `order_item_id` (Sequential number of items in order)
   - `product_id` (FK to products)
   - `seller_id` (FK to sellers)
   - `shipping_limit_date`
   - `price` (Item unit price in BRL)
   - `freight_value` (Shipping / freight cost per item)
4. **`payments`** (`103,886 rows`):
   - `order_id` (FK to orders)
   - `payment_sequential`
   - `payment_type` ('credit_card', 'boleto', 'voucher', 'debit_card')
   - `payment_installments` (Number of installment months)
   - `payment_value` (Total transaction value)
5. **`products`** (`32,951 rows`):
   - `product_id` (PK)
   - `product_category_name`
   - `product_weight_g`, dimensions (`product_length_cm`, `product_height_cm`, `product_width_cm`)
6. **`sellers`** (`3,095 rows`):
   - `seller_id` (PK)
   - `seller_zip_code`, `seller_city`, `seller_state`

---

## 🎯 Analytical Objectives & Scope

1. **Data Exploration & Baseline Metrics**:
   - Inspect data types, schema integrity, temporal order span, and geographic breadth (states and cities).
2. **Order Trends & Seasonality**:
   - Evaluate multi-year volume growth, peak monthly seasonality, and time-of-day buying windows.
3. **Customer & Regional Footprint**:
   - Month-on-month order trends by state, geographic concentration, and penetration gaps.
4. **Economic Impact & Freight Dynamics**:
   - YoY revenue growth percentage (using window `LAG()`), Average Order Value (AOV), and freight costs per state.
5. **Logistics & Delivery SLA Performance**:
   - Order fulfillment lead time, actual vs estimated delivery variances, and identifying the top 5 highest/lowest freight and delivery duration states using window ranking (`DENSE_RANK()`).
6. **Payment & Financing Habits**:
   - Customer payment channels and multi-installment financing behavior.
