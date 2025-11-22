# Data Warehouse and Analytics Project

Welcome to the **Data Warehouse and Analytics Project** repository! 🚀  
This project demonstrates a comprehensive data warehousing and analytics solution, from building a data warehouse to generating actionable insights. Designed as a portfolio project, it highlights industry best practices in data engineering and analytics.

---

## 🏗️ Data Architecture

The data architecture follows Medallion Architecture **Bronze**, **Silver**, and **Gold** layers:

1. **Bronze Layer**: Stores raw data as-is from the source systems. Data is ingested from CSV files into SQL Server.  
2. **Silver Layer**: Cleansing, standardization, and normalization processes prepare data for analysis.  
3. **Gold Layer**: Business-ready data modeled into a star schema for reporting and analytics.

---

## 📖 Project Overview

This project includes:

- **Data Architecture**: Modern DW design using Bronze–Silver–Gold layers.  
- **ETL Pipelines**: Extraction, transformation, and loading from source systems into the warehouse.  
- **Data Modeling**: Fact and dimension tables optimized for BI workloads.  
- **Analytics & Reporting**: SQL-based reports and analyses covering customers, products, sales, and performance trends.

---

## 🆕 Newly Added SQL Analysis Files

Three major SQL files were added to extend the analytical depth of the project:

### 1. **Customer & Product Reporting (Gold Layer Views)**
This file introduces two production-ready analytical views:

- `gold.report_customers`  
  - Customer segmentation (VIP, Regular, New)  
  - Total sales, total orders, recency, lifespan  
  - Average order value and average monthly spend  
  - Age group classification  

- `gold.report_products`  
  - Product performance segmentation (High-Performer, Mid-Range, Low-Performer)  
  - Revenue, quantity sold, customer counts  
  - Lifespan, recency, average selling price  

These views represent clean, business-ready datasets ideal for dashboards and BI tools.

---

### 2. **Exploratory Data Analysis (EDA) Queries**
This file contains a rich set of SQL queries used for:

- Inspecting schema and table structures  
- Profiling customers, products, and sales  
- Computing global KPIs (total sales, orders, quantity, ASP)  
- Demographic breakdowns (age/gender/country)  
- Category performance and contribution analysis  
- Ranking (top products, top customers, bottom performers)  

These queries support early data discovery, validation, and exploration before model building.

---

### 3. **Advanced Performance & Trend Analysis**
This file includes advanced analytical SQL such as:

- **Time-series analysis:**  
  - Monthly and yearly sales trends  
  - Running totals  
  - Moving averages  

- **Year-over-Year (YoY) product performance:**  
  - Annual revenue per product  
  - Comparison to historical average  
  - A classification of performance (Increase, Decrease, No Change)

- **Customer lifecycle segmentation**  
  Helps determine customer maturity and behavior over time.

These analyses support deeper business insights and strategic decision-making.

---

## 🛠️ Tools Used

| Tool / Platform | Purpose |
|-----------------|---------|
| **MS SQL Server** | Data warehouse engine and ETL processes |
| **Excel** | Data preview, validation, and reporting |
| **Notion** | Documentation, project planning, and tracking |
| **Draw.io** | Architecture and data flow diagrams |

---

## 🚀 Project Requirements

### Data Engineering
- **Objective**: Build a modern data warehouse consolidating ERP and CRM data into analytical models.  
- **Scope:** Latest dataset only; historical tracking not required.  
- **Data Quality:** Handle nulls, inconsistent codes, invalid dates, and duplicates.  
- **Integration:** Combine sources into a single unified model optimized for analytics.  

### Analytics & Reporting
- **Objective:** Deliver SQL-based insights on customer behavior, product performance, and sales trends.  
- **Outcome:** Enable stakeholders to make data-driven decisions efficiently.  

---

## 📊 Layers Overview

- **Bronze Layer**: Raw, unprocessed source data.  
- **Silver Layer**: Cleaned and standardized data ready for business logic.  
- **Gold Layer**: Business-ready models (dimension and fact tables) for reporting.  

---

## 📌 Naming Conventions

- **Tables**: `dim_` for dimensions, `fact_` for facts.  
- **Columns**: `snake_case`, `_key` suffix for surrogate keys.  
- **Stored Procedures**: `load_<layer>` pattern.  
Refer to [naming-conventions.md](docs/naming-conventions.md) for full details.

---

## 🛡️ License

This project is licensed under the [MIT License](LICENSE). You are free to use, modify, and distribute this project with proper attribution.

---

Thank you for visiting my repository! 🚀
