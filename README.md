# 🛒 Target Brazil E-Commerce: Logistics Disparity & Revenue Scaling Case Study

<div align="center">

![Google BigQuery](https://img.shields.io/badge/Google_BigQuery-669DF6?style=for-the-badge&logo=googlecloud&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Advanced_Queries-4479A1?style=for-the-badge&logo=postgresql&logoColor=white)
![Scaler DSML](https://img.shields.io/badge/Scaler_DSML-Fellowship_Project-FF4B4B?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Completed-success?style=for-the-badge)

**An Enterprise SQL Business Case Study analyzing 99,000+ orders across 27 Brazilian states using Google BigQuery**  
*(Solved as part of Scaler Academy's Data Science & Machine Learning Fellowship Program)*

[View Case Study PDF](reports/Shivaling-TARGET%20SQL%20Business%20Case.pdf) • [Dataset (8 CSVs)](https://drive.google.com/drive/folders/1TGEc66YKbD443nslRi1bWgVd238gJCnb) • [Live Portfolio](https://iamshivalingbattarki09.vercel.app/) • [LinkedIn](https://www.linkedin.com/in/shivaling-93000/)

</div>

---

### 📌 Recruiter Fast-Pass: Key Findings at a Glance

| Metric | Quantitative Value | Operational Insight |
|---|---|---|
| **Dataset Scale** | **99,441 Orders** across 27 States | Comprehensive coverage spanning Sept 2016 to Aug 2018 |
| **YoY Revenue Growth** | **+137.38%** (2017 vs 2018 Jan-Aug) | Fast-scaling demand requiring proportional fulfillment expansion |
| **Regional Lead-Time Disparity** | **3.5x Gap** (RR: 29.3 days vs SP: 8.3 days) | Significant logistics bottlenecks in northern / remote territories |
| **Peak Ordering Window** | **13:00 – 18:00 (Afternoon)** | Peak user transaction volume across weekdays |
| **Customer Concentration** | **Top 3 States: SP, RJ, MG** | Accounts for majority of customer footprint and order volume |
| **Payment Preferences** | **Credit Card (75%+)** | Strong reliance on multi-installment financing up to 10 installments |

---

## 📋 Table of Contents

- [🎯 Business Problem & Context](#-business-problem--context)
- [🏗️ Relational Data Architecture](#️-relational-data-architecture)
- [🔍 Detailed SQL Analysis & Insights](#-detailed-sql-analysis--insights)
  - [1. Data Exploration & Baseline Overview](#1-data-exploration--baseline-overview)
  - [2. Order Volume Trends & Seasonality](#2-order-volume-trends--seasonality)
  - [3. Regional Distribution & State Footprint](#3-regional-distribution--state-footprint)
  - [4. Economic Impact, Revenue Growth & Freight Disparity](#4-economic-impact-revenue-growth--freight-disparity)
  - [5. Logistics & Delivery Performance](#5-logistics--delivery-performance)
  - [6. Payment Methods & Financing Behavior](#6-payment-methods--financing-behavior)
- [💡 Summary of Findings](#-summary-of-findings)
- [🎯 Strategic Business Recommendations](#-strategic-business-recommendations)
- [📁 Repository Structure](#-repository-structure)
- [🚀 How to Run Queries in BigQuery](#-how-to-run-queries-in-bigquery)
- [👨‍💻 Author & Contact](#-author--contact)

---

## 🎯 Business Problem & Context

Target is a globally recognized retail brand. In this case study, we evaluate Target's e-commerce operations in Brazil. 

Between late 2016 and mid-2018, the platform experienced rapid consumer adoption. However, rapid growth across an expansive geography like Brazil presents severe operational hurdles:
1. **Fulfillment Bottlenecks:** Are customers in distant states experiencing unacceptable delivery delays?
2. **Freight Economics:** Are high shipping costs penalizing customers in specific regions?
3. **Revenue Velocity:** Is top-line sales growth sustainable across different quarters?
4. **Consumer Purchasing Habits:** When do customers order, and how do they finance high-ticket items?

As a Data Analyst, my goal was to query the relational data warehouse on **Google BigQuery**, formulate multi-table joins, Common Table Expressions (CTEs), and analytical window functions to translate raw transactional logs into clear, actionable business strategies.

---

## 🏗️ Relational Data Architecture

The analysis spans 6 relational tables within Google BigQuery:

```
+--------------------+       +-----------------------+       +---------------------+
|     CUSTOMERS      |       |        ORDERS         |       |     ORDER_ITEMS     |
+--------------------+       +-----------------------+       +---------------------+
| customer_id (PK)   |<----->| order_id (PK)         |<----->| order_id (FK)       |
| customer_unique_id |       | customer_id (FK)      |       | order_item_id       |
| customer_zip_code  |       | order_status          |       | product_id (FK)     |
| customer_city      |       | order_purchase_time   |       | seller_id (FK)      |
| customer_state     |       | order_delivered_cust  |       | price               |
+--------------------+       | order_estimated_date  |       | freight_value       |
                             +-----------------------+       +---------------------+
                                         |                              |
                                         v                              v
                             +-----------------------+       +---------------------+
                             |       PAYMENTS        |       |      PRODUCTS       |
                             +-----------------------+       +---------------------+
                             | order_id (FK)         |       | product_id (PK)     |
                             | payment_sequential    |       | product_category    |
                             | payment_type          |       | product_weight_g    |
                             | payment_installments  |       +---------------------+
                             | payment_value         |
                             +-----------------------+
```

---

## 🔍 Detailed SQL Analysis & Insights

### 1. Data Exploration & Baseline Overview

#### 1.1 Temporal Window of Orders
To understand the observation window for delivered orders:
```sql
SELECT 
  MIN(DATE(order_purchase_timestamp)) AS first_order_placed,
  MAX(DATE(order_purchase_timestamp)) AS latest_order_placed,
  DATE_DIFF(MAX(DATE(order_purchase_timestamp)),
            MIN(DATE(order_purchase_timestamp)), MONTH) AS order_month_span
FROM `target_sql.orders`
WHERE order_status = 'delivered';
```
* **Insight:** Delivered orders span from **September 09, 2016 to August 29, 2018** (a 23-month window), providing a complete view of multi-year operational maturity.

#### 1.2 Geographic Reach
```sql
SELECT 
  COUNT(DISTINCT c.customer_state) AS count_of_states,
  COUNT(DISTINCT c.customer_city) AS count_of_cities
FROM `target_sql.customers` c 
JOIN `target_sql.orders` o
  ON c.customer_id = o.customer_id;
```
* **Insight:** The platform serves **4,119 distinct cities across all 27 Brazilian states**, confirming a nationwide consumer footprint.

---

### 2. Order Volume Trends & Seasonality

#### 2.1 Multi-Year Order Growth
```sql
SELECT 
  EXTRACT(YEAR FROM order_purchase_timestamp) AS years,
  COUNT(order_id) AS total_orders
FROM `target_sql.orders`
GROUP BY EXTRACT(YEAR FROM order_purchase_timestamp)
ORDER BY years;
```
* **Insight:** The number of orders placed shows continuous expansion year-over-year, confirming growing platform adoption.

#### 2.2 Monthly Seasonality
```sql
SELECT
  FORMAT_DATE('%B', order_purchase_timestamp) AS months,
  COUNT(order_id) AS total_orders
FROM `target_sql.orders`
GROUP BY FORMAT_DATE('%B', order_purchase_timestamp),
  EXTRACT(MONTH FROM order_purchase_timestamp)
ORDER BY EXTRACT(MONTH FROM order_purchase_timestamp);
```
* **Insight:** Peak order volume concentrates in **May, July, and August** (exceeding 10K orders each). Conversely, late Q4 experiences lower demand, indicating ideal windows for targeted promotional campaigns.

#### 2.3 Time-of-Day Ordering Behavior
```sql
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
```
* **Insight:** Brazilian consumers predominantly purchase during the **Afternoon (13:00 - 18:00)**, with average order times clustering around 14:00–15:00. This informs server traffic maintenance schedules and customer support staffing.

---

### 3. Regional Distribution & State Footprint

#### 3.1 Customer Concentration by State
```sql
SELECT 
  customer_state,
  COUNT(customer_unique_id) AS total_customers
FROM `target_sql.customers`
GROUP BY customer_state
ORDER BY total_customers DESC;
```
* **Insight:** **São Paulo (SP), Rio de Janeiro (RJ), and Minas Gerais (MG)** account for the majority of the customer base. Most other states hold less than half the average customer volume of these top 3 states, highlighting significant untapped geographic potential.

---

### 4. Economic Impact, Revenue Growth & Freight Disparity

#### 4.1 YoY Revenue Growth Rate (Jan – Aug Comparison via Window `LAG()`)
```sql
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
```
* **Insight:** Total transaction value between January and August surged by **+137.38% from 2017 to 2018**, proving strong revenue momentum and validation of business campaigns.

#### 4.2 State-Level Order Value & Average Order Value (AOV)
```sql
-- Aggregating at Order Level first to preserve true basket value:
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
  ROUND(SUM(order_total_price), 2) AS total_order_value,
  ROUND(AVG(order_total_price), 2) AS avg_order_value
FROM cte1
GROUP BY customer_state
ORDER BY total_order_value DESC;
```
* **Insight:** Average order value varies noticeably across states, reflecting regional purchasing power and product mix differences.

#### 4.3 Regional Freight Disparity via `DENSE_RANK()`
```sql
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
```
* **Insight:** Average freight cost in **Roraima (RR: 48.59 BRL)** is nearly **2.8x higher** than in **São Paulo (SP: 17.37 BRL)**, creating friction for northern customers due to warehouse distance.

---

### 5. Logistics & Delivery Performance

#### 5.1 Lead Time Disparity: Top 5 Highest vs Lowest Delivery States
```sql
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
```
* **Insight:** Roraima (RR) experiences an average delivery time of **29.3 days**, whereas São Paulo (SP) averages **8.3 days**—a **~3.5x lead-time gap**. This indicates an urgent need for localized regional fulfillment hubs in northern Brazil.

#### 5.2 Delivery Performance vs Estimated SLA
```sql
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
```
* **Insight:** Negative difference values demonstrate that high-performing states consistently receive deliveries **well ahead of the promised estimated date**, proving that southeastern transport networks can serve as an operational benchmark.

---

### 6. Payment Methods & Financing Behavior

#### 6.1 Payment Installment Distribution
```sql
SELECT 
  payment_installments,
  COUNT(DISTINCT order_id) AS total_orders
FROM `target_sql.payments`
GROUP BY payment_installments
ORDER BY total_orders DESC, payment_installments;
```
* **Insight:** While single-installment transactions dominate overall volume, multi-installment options (spanning up to 10 installments) represent a substantial portion of customer transactions, highlighting the importance of credit accessibility for cart conversions.

---

## 💡 Summary of Findings

1. **Robust Top-Line Momentum:** Transaction value surged **+137.38% YoY**, reflecting expanding brand adoption across Brazil.
2. **Severe Regional Disparities:** A **3.5x lead time disparity** (29 days in RR vs 8 days in SP) and a **2.8x freight disparity** directly threaten customer retention outside the Southeast corridor.
3. **Predictable Peak Activity:** Afternoons (13:00 - 18:00) cluster the highest transaction volumes, providing clear guidelines for infrastructure scalability and operational support.
4. **Credit & Installment Reliance:** Multi-installment financing is vital to consumer affordability in Brazilian e-commerce.

---

## 🎯 Strategic Business Recommendations

1. **Establish Northern Regional Fulfillment Hubs:** Partner with local third-party logistics (3PL) providers and micro-fulfillment centers in northern/northeastern hubs to cut the 29-day delivery cycle down to acceptable levels.
2. **Subsidize or Standardize Freight Tiers:** High freight in distant states acts as a barrier to cart checkout; tiered freight subsidies or minimum order threshold promotions can boost adoption in low-penetration states.
3. **Optimize System Reliability for Afternoon Traffic:** Ensure cloud database and e-commerce server uptime between 13:00 and 18:00 to avoid checkout friction during peak buying hours.
4. **Expand Flexible Financing:** Introduce zero-fee multi-installment programs to improve conversion rates on higher-ticket merchandise.

---

## 📁 Repository Structure

```
Target-SQL-Business-Case-Study/
│
├── sql/
│   ├── 01_dataset_overview_and_schema.sql
│   ├── 02_order_trends_and_seasonality.sql
│   ├── 03_customer_and_regional_distribution.sql
│   ├── 04_economic_impact_and_freight.sql
│   ├── 05_delivery_performance_and_logistics.sql
│   ├── 06_payment_and_installment_analysis.sql
│   └── all_target_queries.sql
│
├── reports/
│   └── Shivaling-TARGET SQL Business Case.pdf
│
├── docs/
│   └── Problem_Statement.md
│
├── assets/
│   └── screenshots/
│
├── .gitignore
└── README.md
```

---

## 🚀 How to Run Queries in BigQuery

1. Open your [Google Cloud Console](https://console.cloud.google.com/) and navigate to **BigQuery**.
2. Create a dataset named `target_sql`.
3. Import the tables (`customers`, `orders`, `order_items`, `payments`, `products`, `sellers`).
4. Execute queries sequentially from the `/sql` directory or run `sql/all_target_queries.sql`.

---

## 👨‍💻 Author & Contact

**Shivaling Battarki**  
*Data Analyst | Ex-BPCL | Scaler DSML Fellow*  
Mechanical Engineering Graduate (8.67 CGPA) with hands-on experience in operations analytics, SQL data modeling, and business problem solving.

- 🌐 **Live Portfolio:** [iamshivalingbattarki09.vercel.app](https://iamshivalingbattarki09.vercel.app/)
- 💼 **LinkedIn:** [linkedin.com/in/shivaling-93000](https://www.linkedin.com/in/shivaling-93000/)
- 🏆 **HackerRank:** [5-Star Gold SQL Profile](https://www.hackerrank.com/profile/shivalingb09)
- 📧 **Email:** [shivalingb09@gmail.com](mailto:shivalingb09@gmail.com)
