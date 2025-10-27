/*
BRONZE LAYER TABLE CREATION SCRIPT
Purpose:
  This script creates raw staging tables in the Bronze layer
  of the data warehouse. These tables store data exactly as
  received from CRM and ERP source systems, without any
  transformations, cleansing, or business rules applied.

Notes:
  • Used as the landing zone for bulk load operations
  • Column names and data types directly reflect the sources
  • Data quality and structure will be improved in Silver layer
*/


----------------------------------------------------------
-- CRM Customer Information (raw data from CRM system)
----------------------------------------------------------
If OBJECT_ID('bronze.crm_cust_info','U') is not null
    Drop Table bronze.crm_cust_info;

Create Table bronze.crm_cust_info(
    cst_id int,                      -- Internal customer ID
    cst_key varchar(25),             -- Unique CRM customer identifier
    cst_firstname varchar(50),       -- Customer first name
    cst_lastname varchar(50),        -- Customer last name
    cst_marital_status varchar(25),  -- Marital status field
    cst_gndr varchar(25),            -- Gender information
    cst_create_date date             -- Account or record creation date
);

----------------------------------------------------------
-- CRM Product Information (raw data about product catalog)
----------------------------------------------------------
If OBJECT_ID('bronze.crm_prd_info','U') is not null
    Drop Table bronze.crm_prd_info;

Create Table bronze.crm_prd_info(
    prd_id int,                      -- Product ID
    prd_key varchar(50),             -- Unique CRM product identifier
    prd_nm varchar(50),              -- Product name
    prd_cost int,                    -- Product cost
    prd_line varchar(25),            -- Product line or category
    prd_start_dt Date,               -- Product activation/start date
    prd_end_dt Date                  -- Product end/expiration date
);

----------------------------------------------------------
-- CRM Sales Details (raw sales transactions from CRM)
----------------------------------------------------------
If OBJECT_ID('bronze.crm_sales_details','U') is not null
    Drop Table bronze.crm_sales_details;

Create Table bronze.crm_sales_details(
    sls_ord_num varchar(25),         -- Sales order number
    sls_prd_key varchar(50),         -- Product key reference to crm_prd_info
    sls_cust_id int,                 -- Customer ID reference to crm_cust_info
    sls_order_dt Int,                -- Order date stored as integer (needs transformation later)
    sls_ship_dt Int,                 -- Shipping date stored as integer
    sls_due_dt Int,                  -- Due delivery date stored as integer
    sls_sales Int,                   -- Total sales amount for the line item
    sls_quantity Int,                -- Quantity sold
    sls_price Int                    -- Unit price for the product
);

----------------------------------------------------------
-- ERP Customer Data (raw demographic data from ERP)
----------------------------------------------------------
If OBJECT_ID('bronze.erp_cust_az12','U') is not null
    Drop Table bronze.erp_cust_az12;

Create Table bronze.erp_cust_az12(
    cid varchar(50),                 -- Customer identifier from ERP
    bdate date,                      -- Customer birthdate
    gen varchar(25)                  -- Gender as recorded in ERP
);

----------------------------------------------------------
-- ERP Customer Location Data
----------------------------------------------------------
If OBJECT_ID('bronze.erp_loc_101','U') is not null
    Drop Table bronze.erp_loc_101;

Create Table bronze.erp_loc_101(
    cid varchar(25),                 -- Customer identifier
    cntry varchar(25)                -- Customer country information
);

----------------------------------------------------------
-- ERP Product Category Mapping
----------------------------------------------------------
If OBJECT_ID('bronze.erp_px_cat_g1v2','U') is not null
    Drop Table bronze.erp_px_cat_g1v2;

Create Table bronze.erp_px_cat_g1v2 (
    id varchar(25),                  -- Product identifier
    cat varchar(25),                 -- Main category classification
    subcat varchar(50),              -- Subcategory classification
    manitenance varchar(25)          -- Maintenance or product lifecycle status
);
