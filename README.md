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

- **Data Architecture**: Designing a modern data warehouse using Bronze, Silver, and Gold layers.  
- **ETL Pipelines**: Extracting, transforming, and loading data from source systems into the warehouse.  
- **Data Modeling**: Creating fact and dimension tables optimized for analytics.  
- **Analytics & Reporting**: SQL-based reports and dashboards to extract insights on customer behavior, product performance, and sales trends.

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
- **Scope**: Latest dataset only; historical tracking not required.  
- **Data Quality**: Handle nulls, inconsistent codes, invalid dates, and duplicates.  
- **Integration**: Combine sources into a single unified model optimized for analytics.  

### Analytics & Reporting

- **Objective**: Deliver SQL-based insights on customer behavior, product performance, and sales trends.  
- **Outcome**: Enable stakeholders to make data-driven decisions efficiently.  

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

## 🌟 About Me

Hi! I'm **Moamen Sabry Eldabea**, a data enthusiast working on SQL-based data engineering and analytics projects.

📧 [mommensabry@gmail.com](mailto:mommensabry@gmail.com)  
🔗 [![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=flat-square&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/moamen-sabry-88306b1b3/)

---

Thank you for visiting my repository! 🚀
