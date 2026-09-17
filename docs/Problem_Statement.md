# 🛒 Target Brazil E-Commerce: Business Problem, Context & Relational Schema
**Academic Program:** Scaler Academy — Data Science & Machine Learning (DSML) Program  
**Author:** Shivaling Battarki (Data Analyst | Ex-BPCL | Scaler DSML Fellow)  
**Platform:** Google BigQuery (SQL)  
**Dataset Source:** [Target Brazil E-Commerce Dataset (8 CSVs)](https://drive.google.com/drive/folders/1TGEc66YKbD443nslRi1bWgVd238gJCnb)

---

## 📌 Business Context
Target is a globally renowned brand and a prominent retailer in the United States. Target makes itself a preferred shopping destination by offering outstanding value, inspiration, innovation, and an exceptional guest experience that no other retailer can deliver.

This business case study focuses on the operations of Target in Brazil and analyzes **100,000 orders placed between 2016 and 2018**. The dataset offers a comprehensive multi-dimensional view across:
- Order status & fulfillment lifecycles
- Pricing strategies & economic volume
- Payment & freight performance
- Customer demographics across 27 states and 4,119 cities
- Product attributes & categories
- Customer satisfaction & review scores

By querying and modeling this relational dataset in **Google BigQuery**, we extract actionable operational insights to solve delivery bottlenecks, identify freight disparities, evaluate multi-installment financing habits, and measure YoY revenue expansion.

---

## 🏗️ Relational Schema & 8 CSV Data Files

The dataset is partitioned into 8 core relational tables:

### 1. customers.csv (99,441 rows)
| Column Name | Type | Description |
|---|---|---|
| customer_id | STRING (PK) | Unique per-order customer transaction ID |
| customer_unique_id | STRING | Unique ID of the consumer (tracks repeat buyers) |
| customer_zip_code_prefix | INTEGER | First 5 digits of consumer zip code |
| customer_city | STRING | City where order was placed |
| customer_state | STRING | State code (e.g., SP, RJ, RR, MG) |

### 2. orders.csv (99,441 rows)
| Column Name | Type | Description |
|---|---|---|
| order_id | STRING (PK) | Unique ID of order placed by consumer |
| customer_id | STRING (FK) | Foreign key referencing customers table |
| order_status | STRING | Status of order ('delivered', 'shipped', 'canceled', etc.) |
| order_purchase_timestamp | TIMESTAMP | Timestamp of purchase |
| order_approved_at | TIMESTAMP | Payment approval timestamp |
| order_delivered_carrier_date | TIMESTAMP | Date/time carrier took possession of shipment |
| order_delivered_customer_date | TIMESTAMP | Actual delivery date to customer |
| order_estimated_delivery_date | TIMESTAMP | Promised estimated delivery SLA date |

### 3. order_items.csv (112,650 rows)
| Column Name | Type | Description |
|---|---|---|
| order_id | STRING (FK) | Unique ID of order |
| order_item_id | INTEGER | Item sequence number within the order |
| product_id | STRING (FK) | Foreign key referencing products table |
| seller_id | STRING (FK) | Foreign key referencing sellers table |
| shipping_limit_date | TIMESTAMP | Seller shipping deadline date |
| price | FLOAT64 | Actual item price in BRL |
| reight_value | FLOAT64 | Shipping fee charged per item |

### 4. payments.csv (103,886 rows)
| Column Name | Type | Description |
|---|---|---|
| order_id | STRING (FK) | Unique ID of order |
| payment_sequential | INTEGER | Sequential payment transaction number |
| payment_type | STRING | Mode of payment ('credit_card', 'boleto', 'voucher', 'debit_card') |
| payment_installments | INTEGER | Number of EMI/credit installments |
| payment_value | FLOAT64 | Total transaction monetary value in BRL |

### 5. sellers.csv (3,095 rows)
| Column Name | Type | Description |
|---|---|---|
| seller_id | STRING (PK) | Unique ID of registered seller |
| seller_zip_code_prefix | INTEGER | Seller location zip code |
| seller_city | STRING | Seller city |
| seller_state | STRING | Seller state code |

### 6. products.csv (32,951 rows)
| Column Name | Type | Description |
|---|---|---|
| product_id | STRING (PK) | Unique product identifier |
| product_category_name | STRING | Name of product category |
| product_name_lenght | INTEGER | Length of product name string |
| product_description_lenght| INTEGER | Character length of product description |
| product_photos_qty | INTEGER | Number of published photos |
| product_weight_g | FLOAT64 | Weight in grams |
| product_length_cm | FLOAT64 | Length in centimeters |
| product_height_cm | FLOAT64 | Height in centimeters |
| product_width_cm | FLOAT64 | Width in centimeters |

### 7. geolocation.csv (1,000,163 rows)
| Column Name | Type | Description |
|---|---|---|
| geolocation_zip_code_prefix | INTEGER | First 5 digits of Zip Code |
| geolocation_lat | FLOAT64 | Latitude |
| geolocation_lng | FLOAT64 | Longitude |
| geolocation_city | STRING | City name |
| geolocation_state | STRING | State code |

### 8. 
eviews.csv (99,224 rows)
| Column Name | Type | Description |
|---|---|---|
| 
eview_id | STRING (PK) | Unique review identifier |
| order_id | STRING (FK) | Order identifier |
| 
eview_score | INTEGER | Customer rating score (1 to 5) |
| 
eview_comment_title | STRING | Review title |
| 
eview_comment_message | STRING | Textual feedback |
| 
eview_creation_date | TIMESTAMP | Date review was submitted |
| 
eview_answer_timestamp | TIMESTAMP | Date review response was recorded |

---

## 🎯 Analytical Roadmap: Questions Solved

1. **Initial Exploratory Data Analysis (EDA):**
   - Data types of all columns in customers
   - Distinct time range and date span of delivered orders
   - Total distinct states and cities served
2. **Order Volume & Temporal Seasonality:**
   - Multi-year order growth trend
   - Monthly order seasonality
   - Time-of-day purchase distribution:
     - Dawn: 00:00 – 06:00
     - Morning: 07:00 – 12:00
     - Afternoon: 13:00 – 18:00
     - Night: 19:00 – 23:00
3. **Regional Distribution:**
   - Month-on-month order evolution per state
   - Customer concentration across all 27 Brazilian states
4. **Macroeconomic & Freight Impact:**
   - YoY order cost percentage increase (Jan–Aug 2017 vs 2018 using LAG())
   - Total and Average Order Value (AOV) per state
   - Total and Average freight value per state
5. **Logistics & Delivery SLA Performance:**
   - Single-query calculation of:
     - $\text{time\_to\_deliver} = \text{order\_delivered\_customer\_date} - \text{order\_purchase\_timestamp}$
     - $\text{diff\_estimated\_delivery} = \text{order\_delivered\_customer\_date} - \text{order\_estimated\_delivery_date}$
   - Top 5 states with Highest & Lowest average freight value (DENSE_RANK())
   - Top 5 states with Highest & Lowest average delivery time (DENSE_RANK())
   - Top 5 fastest delivery states compared to estimated delivery date (DENSE_RANK())
6. **Payment & Financing Habits:**
   - MoM order distribution across payment types
   - Order volume by installment count (EMI patterns)
