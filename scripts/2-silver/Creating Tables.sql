----------------------------------------------------------
-- SILVER LAYER TABLE CREATION SCRIPT
----------------------------------------------------------
-- Purpose:
-- The Silver Layer stores cleansed and standardized data.
-- It is built from the Bronze Layer after applying 
-- data quality checks, type conversions, and light transformations.
--
-- Key Points:
-- 1. Dates are converted to proper DATE format.
-- 2. Surrogate keys and relationships are introduced.
-- 3. Each table includes [dwh_create_date] to track load/update time.
-- 4. Data here is ready to be used for analytical modeling 
--    and the creation of the Gold Layer (data marts, facts, and dimensions).
----------------------------------------------------------


----------------------------------------------------------
-- CRM Customer Information (clean and standardized)
----------------------------------------------------------
If OBJECT_ID('silver.crm_cust_info','U') is not null
    Drop Table silver.crm_cust_info;

Create Table silver.crm_cust_info(
    cst_id int,                      -- Unique customer ID
    cst_key varchar(25),             -- Customer unique key
    cst_firstname varchar(50),       -- Customer first name
    cst_lastname varchar(50),        -- Customer last name
    cst_marital_status varchar(25),  -- Marital status
    cst_gndr varchar(25),            -- Gender
    cst_create_date date,            -- Customer creation date
    dwh_create_date datetime2 default getdate() -- Load timestamp for data lineage
);


----------------------------------------------------------
-- CRM Product Information (clean and enriched)
----------------------------------------------------------
If OBJECT_ID('silver.crm_prd_info','U') is not null
    Drop Table silver.crm_prd_info;

Create Table silver.crm_prd_info(
    prd_id int,                      -- Unique Product ID
    cat_id varchar(25),              -- Linked Category ID (from ERP mapping)
    prd_key varchar(50),             -- Product unique key
    prd_nm varchar(50),              -- Product name
    prd_cost int,                    -- Product cost
    prd_line varchar(25),            -- Product line/category
    prd_start_dt Date,               -- Product start/activation date
    prd_end_dt Date,                 -- Product end/discontinuation date
    dwh_create_date datetime2 default getdate() -- Load timestamp for auditing
);


----------------------------------------------------------
-- CRM Sales Details (cleansed transaction data)
----------------------------------------------------------
If OBJECT_ID('silver.crm_sales_details','U') is not null
    Drop Table silver.crm_sales_details;

Create Table silver.crm_sales_details(
    sls_transaction_key varchar(50), -- Unique transaction key (surrogate key)
    sls_ord_num varchar(25),         -- Sales order number
    sls_prd_key varchar(50),         -- Product key reference
    sls_cust_id int,                 -- Customer ID reference
    sls_order_dt Date,               -- Properly formatted order date
    sls_ship_dt Date,                -- Shipping date
    sls_due_dt Date,                 -- Due delivery date
    sls_sales Int,                   -- Sales amount
    sls_quantity Int,                -- Quantity sold
    sls_price Int,                   -- Unit price
    dwh_create_date datetime2 default getdate() -- Timestamp for ETL tracking
);


----------------------------------------------------------
-- ERP Customer Demographic Data (standardized)
----------------------------------------------------------
If OBJECT_ID('silver.erp_cust_az12','U') is not null
    Drop Table silver.erp_cust_az12;

Create Table silver.erp_cust_az12(
    cid varchar(50),                 -- Customer identifier from ERP
    bdate date,                      -- Customer birthdate
    gen varchar(25),                 -- Gender
    dwh_create_date datetime2 default getdate() -- Load timestamp
);


----------------------------------------------------------
-- ERP Customer Location (cleansed)
----------------------------------------------------------
If OBJECT_ID('silver.erp_loc_101','U') is not null
    Drop Table silver.erp_loc_101;

Create Table silver.erp_loc_101(
    cid varchar(25),                 -- Customer identifier
    cntry varchar(25),               -- Customer country
    dwh_create_date datetime2 default getdate() -- Load timestamp
);


----------------------------------------------------------
-- ERP Product Category Reference (enriched category data)
----------------------------------------------------------
If OBJECT_ID('silver.erp_px_cat_g1v2','U') is not null
    Drop Table silver.erp_px_cat_g1v2;

Create Table silver.erp_px_cat_g1v2 (
    id varchar(25),                  -- Product identifier
    cat varchar(25),                 -- Main category
    subcat varchar(50),              -- Subcategory
    manitenance varchar(25),         -- Maintenance/lifecycle status
    dwh_create_date datetime2 default getdate() -- Load timestamp
);
