# 🪙 Gold Layer Data Catalog

## 📘 File Overview
The **Gold Layer** represents the business-ready data models designed for analytics, reporting, and dashboarding.  
It provides a **semantic layer** that integrates, cleans, and standardizes data from multiple operational systems (CRM and ERP).  
This layer is optimized for ease of use and consistency across business domains such as customers, products, and sales.

---

## 🧍‍♂️ dim_customers
**Purpose:**  
Contains customer-related information providing a unified view of customer profiles, demographics, and attributes.

| Column Name | Data Type | Description |
|--------------|------------|--------------|
| **customer_key** | INT | Surrogate key uniquely identifying each customer. |
| **customer_number** | VARCHAR | Original customer ID. |
| **customer_id** | VARCHAR | Internal CRM key for the customer. |
| **first_name** | VARCHAR | Customer’s first name. |
| **last_name** | VARCHAR | Customer’s last name. |
| **country** | VARCHAR | Country of the customer. |
| **marital_status** | VARCHAR | Customer’s marital status (Married, Single, n/a). |
| **gender** | VARCHAR | Gender of the customer. |
| **birthdate** | DATE | Customer’s date of birth. |
| **create_date** | DATE | Date when the customer was first created. |

---

## 🛒 dim_products
**Purpose:**  
Provides descriptive information about products, including categories, costs, and product lines.

| Column Name | Data Type | Description |
|--------------|------------|--------------|
| **product_key** | INT | Surrogate key uniquely identifying each product. |
| **product_number** | VARCHAR | Original product ID. |
| **product_id** | VARCHAR | Internal key used for product reference. |
| **prodcut_name** | VARCHAR | Name of the product. |
| **category_id** | VARCHAR | Identifier for the product’s category. |
| **categroy** | VARCHAR | Category name. |
| **subcategory** | VARCHAR | Subcategory name. |
| **maintenance** | VARCHAR | Maintenance category or flag. |
| **cost** | DECIMAL | Product cost. |
| **product_line** | VARCHAR | Product line (Mountain, Road, Touring, Other Sales, n/a). |
| **start_date** | DATE | Start date of product validity. |

---

## 💰 fact_sales
**Purpose:**  
Stores all sales transactions and links customers and products for analytical reporting on sales performance.

| Column Name | Data Type | Description |
|--------------|------------|--------------|
| **transaction_key** | VARCHAR | Unique identifier for each sales transaction. |
| **order_number** | VARCHAR | Sales order number. |
| **product_key** | INT | Foreign key referencing `dim_products`. |
| **customer_key** | INT | Foreign key referencing `dim_customers`. |
| **order_date** | DATE | Date the order was placed. |
| **shipping_date** | DATE | Date the order was shipped. |
| **due_date** | DATE | Date the order was due. |
| **sales_amount** | DECIMAL | Total sales amount for the transaction. |
| **quantity** | INT | Number of items sold. |
| **price** | DECIMAL | Unit price of the product. |

---

## 🔗 Relationships
| From Table | Column | To Table | Column | Relationship Type |
|-------------|----------|----------|----------|------------------|
| **fact_sales** | `customer_key` | **dim_customers** | `customer_key` | Many-to-One |
| **fact_sales** | `product_key` | **dim_products** | `product_key` | Many-to-One |

---

## 📊 Usage Notes
- Designed for **Power BI**, **Tableau**, and other BI tools for semantic modeling.  
- Each dimension can be joined to the fact table using the corresponding surrogate key.  
- Columns are standardized for consistent naming and easy querying across reporting environments.  

---

**Author:** Data Engineering Team  
**Layer:** Gold (Analytics-Ready)  
**Version:** 1.0  
**Last Updated:** `YYYY-MM-DD`

