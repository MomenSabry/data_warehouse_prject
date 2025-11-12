# **Naming Conventions**

This document outlines the naming conventions used for schemas, tables, views, columns, and other objects in the Data Warehouse project.

## **Table of Contents**

1. [General Principles](#general-principles)  
2. [Table Naming Conventions](#table-naming-conventions)  
   - [Bronze Rules](#bronze-rules)  
   - [Silver Rules](#silver-rules)  
   - [Gold Rules](#gold-rules)  
3. [Column Naming Conventions](#column-naming-conventions)  
   - [Surrogate Keys](#surrogate-keys)  
   - [Technical Columns](#technical-columns)  
4. [Stored Procedure Naming Conventions](#stored-procedure-naming-conventions)

---

## **General Principles**

- **Naming Conventions**: Use `snake_case` for all names, with lowercase letters and underscores (`_`) separating words.  
- **Language**: Use English for all object names.  
- **Avoid Reserved Words**: Do not use SQL reserved words as names for tables, columns, or views.  
- **Consistency**: Apply the same naming rules across all layers (Bronze, Silver, Gold).  
- **Readability**: Names should clearly describe the content or purpose of the object.  

---

## **Table Naming Conventions**

### **Bronze Rules**
- The Bronze layer contains **raw source data** with minimal transformation.  
- Table names must follow the pattern:  
  **`<source_system>_<entity>`**  
  - `<source_system>`: The name of the source system (e.g., `crm`, `erp`).  
  - `<entity>`: The name of the entity or dataset as it exists in the source system.  
- Use exact source table names whenever possible.  
- The prefix `bronze.` is used as the schema name.  

**Example:**  
`bronze.crm_customer_info` → Raw customer information extracted from the CRM system.

---

### **Silver Rules**
- The Silver layer contains **cleaned and standardized** data.  
- Table names must follow the pattern:  
  **`<source_system>_<entity>`**  
  - `<source_system>`: The name of the original data source (e.g., `crm`, `erp`).  
  - `<entity>`: A descriptive name aligned with the business concept.  
- The prefix `silver.` is used as the schema name.  
- Data is modeled but still closely reflects its source.  

**Example:**  
`silver.crm_sales_details` → Cleaned and standardized sales data from the CRM system.

---

### **Gold Rules**
- The Gold layer contains **business-ready views and fact/dimension tables** used for reporting and analytics.  
- Table names must follow the pattern:  
  **`<category>_<entity>`**  
  - `<category>`: Identifies the type of table, such as `dim` (dimension) or `fact` (fact table).  
  - `<entity>`: A meaningful business name describing the dataset.  
- The prefix `gold.` is used as the schema name.  
- Names should reflect **business meaning** rather than source origin.  

**Examples:**  
- `gold.dim_customers` → Dimension table containing customer attributes.  
- `gold.fact_sales` → Fact table containing sales transaction details.  

#### **Glossary of Category Patterns**

| Pattern   | Meaning               | Example(s)                   |
|------------|------------------------|-------------------------------|
| `dim_`     | Dimension table        | `dim_customer`, `dim_product` |
| `fact_`    | Fact table             | `fact_sales`                  |
| `report_`  | Reporting summary view | `report_sales_monthly`        |

---

## **Column Naming Conventions**

### **Surrogate Keys**
- All primary keys in dimension tables must use the suffix `_key`.  
- **`<entity>_key`**  
  - `<entity>`: The name of the table or entity.  
  - `_key`: Indicates that the column is a surrogate key generated within the Data Warehouse.  

**Example:**  
`customer_key` → Surrogate key in the `dim_customers` table.

---

### **Technical Columns**
- All system-generated or metadata columns must start with the prefix `dwh_`.  
- **`dwh_<column_name>`**  
  - `dwh`: Identifies the column as a Data Warehouse technical or metadata field.  
  - `<column_name>`: Describes the column’s purpose.  

**Examples:**  
- `dwh_create_date` → Timestamp when the record was created in the warehouse.  
- `dwh_update_date` → Timestamp when the record was last updated.  

---

## **Stored Procedure Naming Conventions**

- All stored procedures must follow a **verb-first pattern** and reference the **target layer**.  
- **`load_<layer>`**  
  - `<layer>`: The Data Warehouse layer being loaded (e.g., `bronze`, `silver`, `gold`).  
- Procedure names should describe their purpose clearly.  

**Examples:**  
- `load_bronze` → Procedure that ingests data into the Bronze layer.  
- `load_silver` → Procedure that transforms and loads data into the Silver layer.  
- `load_gold` → Procedure that populates analytical models or views in the Gold layer.  

---

**End of Document**
