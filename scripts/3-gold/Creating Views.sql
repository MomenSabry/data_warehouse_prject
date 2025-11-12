/****************************************************************************************************
Gold Layer (Data Warehouse Presentation Layer)
Description: 
    This script creates the Gold Layer views for the Data Warehouse project. 
    The Gold Layer serves as the presentation layer, providing clean, 
    analytics-ready views for business users and BI tools.

    It includes:
      - dim_customers:   Customer dimension containing demographic details.
      - dim_products:    Product dimension with category and cost information.
      - fact_sales:      Sales fact table connecting customers and products.

Notes:
    • This layer focuses on providing business-friendly, analytical views.
    • Source system names (e.g., silver.crm_cust_info) are abstracted from the end user.
    • Cleaning, transformations, and validation are assumed completed in the Silver Layer.
****************************************************************************************************/


----------------------------------------------------------------------------------------------------
-- View: gold.dim_customers
-- Purpose: Provides customer information including demographics and account creation details.
----------------------------------------------------------------------------------------------------
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,       -- Surrogate key for analytics
    ci.cst_id AS customer_number,                                 
    ci.cst_key AS customer_id,                                    
    ci.cst_firstname AS first_name,                               
    ci.cst_lastname AS last_name,                                
    cl.cntry AS country,                                          
    ci.cst_marital_status AS marital_status,                      
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr                -- Prefer CRM gender if valid
        ELSE COALESCE(gen, 'n/a') 
    END AS gender,                                                
    ca.bdate AS birthdate,                                        
    ci.cst_create_date AS create_date                             
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_101 AS cl ON ci.cst_key = cl.cid;
----------------------------------------------------------------------------------------------------



----------------------------------------------------------------------------------------------------
-- View: gold.dim_products
-- Purpose: Contains product information including category, cost, and start date.
----------------------------------------------------------------------------------------------------
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY pf.prd_start_dt, pf.prd_key) AS product_key,  -- Surrogate key
    pf.prd_id AS product_number,                                              
    pf.prd_key AS product_id,                                                 
    pf.prd_nm AS product_name,                                              
    pf.cat_id AS category_id,                                               
    pc.cat AS category,                                                      
    pc.subcat AS subcategory,                                              
    pc.manitenance AS maintenance,                                            
    pf.prd_cost AS cost,                                                  
    pf.prd_line AS product_line,                                            
    pf.prd_start_dt AS start_date                                             
FROM silver.crm_prd_info AS pf
LEFT JOIN silver.erp_px_cat_g1v2 AS pc ON pf.cat_id = pc.id
WHERE pf.prd_end_dt IS NULL;                                                 -- Active products only
----------------------------------------------------------------------------------------------------



----------------------------------------------------------------------------------------------------
-- View: gold.fact_sales
-- Purpose: Central fact table containing sales transaction details. 
--           Links to dim_customers and dim_products for analysis.
----------------------------------------------------------------------------------------------------
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT
    o.sls_transaction_key AS transaction_key,       -- Unique transaction key
    o.sls_ord_num AS order_number,                  
    p.product_key,                                  -- Foreign key to dim_products
    c.customer_key,                                 -- Foreign key to dim_customers
    o.sls_order_dt AS order_date,                  
    o.sls_ship_dt AS shipping_date,                
    o.sls_due_dt AS due_date,                       
    o.sls_sales AS sales_amount,                   
    o.sls_quantity AS quantity,                     
    o.sls_price AS price                            
FROM silver.crm_sales_details AS o
LEFT JOIN gold.dim_products AS p ON o.sls_prd_key = p.product_id
LEFT JOIN gold.dim_customers AS c ON o.sls_cust_id = c.customer_number;
----------------------------------------------------------------------------------------------------
