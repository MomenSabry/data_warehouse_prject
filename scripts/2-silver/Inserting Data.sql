----------------------------------------------------
-- PROCEDURE: silver.load_Silver
----------------------------------------------------------
-- Purpose:
-- This stored procedure loads and transforms data from the 
-- Bronze Layer into the Silver Layer.
--
-- Key Responsibilities:
-- 1. Cleans, standardizes, and deduplicates Bronze data.
-- 2. Converts data types (especially dates).
-- 3. Applies light business rules (e.g., gender, marital status).
-- 4. Ensures consistent formatting for text fields.
-- 5. Logs load metrics such as before/after row counts 
--    and total load durations for transparency and debugging.
--
-- Structure:
--   Step 1 - Load CRM tables (Customer, Product, Sales)
--   Step 2 - Load ERP tables (Location, Customer, Category)
--
-- Error handling is included using TRY...CATCH to ensure 
-- the process logs any failure instead of stopping abruptly.
----------------------------------------------------------

--Exec silver.load_Silver
Create or Alter Procedure silver.load_Silver As
Begin
	Declare @start_time datetime, @end_time datetime 
	Declare @batch_start_time datetime, @batch_end_time datetime 	
	Declare @before_update INT, @after_update INT;

	Begin Try
		Set @batch_start_time = GETDATE()
		Print '*****************************************************';
		Print 'Loading Silver Layer';
		Print '*****************************************************';
		Print ''

		------------------------------------------------------
		-- 1. LOADING CRM TABLES
		------------------------------------------------------
		Print '------------------------------------------------------';
		Print '1-Loading CRM Tables';
		Print '------------------------------------------------------';

		------------------------------------------------------
		-- 1.1 Load silver.crm_cust_info
		-- Deduplicate and standardize customer data
		------------------------------------------------------
		SELECT @before_update = COUNT(*) FROM silver.crm_cust_info;
		set @start_time = GETDATE();
		PRINT '1-1 crm_cust_info ';
		Print 'Truncating Table: silver.crm_cust_info';
		Print 'Count of Rows Before Update = ' + CAST(@before_update AS VARCHAR(20));

		TRUNCATE TABLE silver.crm_cust_info;

		INSERT INTO silver.crm_cust_info (
			cst_id, 
			cst_key, 
			cst_firstname, 
			cst_lastname, 
			cst_marital_status, 
			cst_gndr,
			cst_create_date
		)
		SELECT 
			cst_id,
			cst_key,
			TRIM(cst_firstname) AS cst_firstname,
			TRIM(cst_lastname) AS cst_lastname,
			CASE 
				WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				ELSE 'n/a'
			END AS cst_marital_status,
			CASE 
				WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				ELSE 'n/a'
			END AS cst_gndr,
			cst_create_date
		FROM (
			SELECT *,
				   ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_id, cst_create_date DESC) AS Duplicate
			FROM bronze.crm_cust_info
			WHERE cst_id IS NOT NULL
		) T
		WHERE Duplicate = 1;

		Print 'Inserting New Data Into: silver.crm_cust_info'; 
		set @end_time = GETDATE();
		SELECT @after_update = COUNT(*) FROM silver.crm_cust_info;

		IF (@after_update - @before_update >= 0)
			PRINT 'New rows loaded compared to previous batch: ' + CAST(@after_update - @before_update AS VARCHAR(20)) + ' Rows';
		ELSE
			PRINT 'Warning: Negative row difference detected: ' + CAST(@after_update - @before_update AS VARCHAR(20)) + ' Rows';
		Print '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' Seconds';


		------------------------------------------------------
		-- 1.2 Load silver.crm_prd_info
		-- Clean product data and map categories
		------------------------------------------------------
		SELECT @before_update = COUNT(*) FROM silver.crm_prd_info;
		set @start_time = GETDATE();
		PRINT '1-2 crm_prd_info ';
		Print 'Truncating Table: silver.crm_prd_info';
		Print 'Count of Rows Before Update = ' + CAST(@before_update AS VARCHAR(20));

		TRUNCATE TABLE silver.crm_prd_info;

		INSERT INTO silver.crm_prd_info (
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		SELECT
			prd_id,
			REPLACE(LEFT(prd_key,5),'-','_') AS cat_id,
			SUBSTRING(prd_key,7,LEN(prd_key)-6) AS prd_key,
			prd_nm,
			ISNULL(prd_cost, 0) AS prd_cost,
			CASE UPPER(TRIM(prd_line))
				WHEN 'M' THEN 'Mountain'
				WHEN 'R' THEN 'Road'
				WHEN 'T' THEN 'Touring'
				WHEN 'S' THEN 'Other Sales'
				ELSE 'n/a'
			END AS prd_line,
			prd_start_dt,
			DATEADD(DAY,-1,LEAD(prd_start_dt,1) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)) AS prd_end_dt
		FROM bronze.crm_prd_info;

		Print 'Inserting New Data Into: silver.crm_prd_info'; 
		set @end_time = GETDATE();
		SELECT @after_update = COUNT(*) FROM silver.crm_prd_info;

		IF (@after_update - @before_update >= 0)
			PRINT 'New rows loaded compared to previous batch: ' + CAST(@after_update - @before_update AS VARCHAR(20)) + ' Rows';
		ELSE
			PRINT 'Warning: Negative row difference detected: ' + CAST(@after_update - @before_update AS VARCHAR(20)) + ' Rows';
		Print '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' Seconds';


		------------------------------------------------------
		-- 1.3 Load silver.crm_sales_details
		-- Validate and calculate sales and prices
		------------------------------------------------------
		SELECT @before_update = COUNT(*) FROM silver.crm_sales_details;
		set @start_time = GETDATE();
		PRINT '1-3 crm_sales_details ';
		Print 'Truncating Table: silver.crm_sales_details';
		Print 'Count of Rows Before Update = ' + CAST(@before_update AS VARCHAR(20));

		TRUNCATE TABLE silver.crm_sales_details;

		INSERT INTO silver.crm_sales_details (
			sls_transaction_key,
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		SELECT
			CONCAT(sls_ord_num,'-',sls_prd_key) AS sls_transaction_key,
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE 
				WHEN LEN(sls_order_dt) = 8 THEN CONVERT(date, CONVERT(char(8), sls_order_dt))
				ELSE DATEADD(day,-7,CONVERT(date, CONVERT(char(8), sls_ship_dt)))
			END AS sls_order_dt,
			CONVERT(date, CONVERT(char(8), sls_ship_dt)) AS sls_ship_dt,
			CONVERT(date, CONVERT(char(8), sls_due_dt)) AS sls_due_dt,
			CASE 
				WHEN ISNULL(sls_sales,0) <= 0 OR sls_sales != ABS(sls_quantity) * ABS(sls_price)
					THEN ABS(sls_quantity) * ABS(sls_price)
				ELSE sls_sales
			END AS sls_sales,
			sls_quantity,
			CASE
				WHEN ISNULL(sls_price,0) <= 0 THEN ABS(sls_sales) / NULLIF(ABS(sls_quantity),0)
				WHEN sls_price < 0 THEN ABS(sls_price)
				ELSE sls_price
			END AS sls_price
		FROM bronze.crm_sales_details;

		Print 'Inserting New Data Into: silver.crm_sales_details'; 
		set @end_time = GETDATE();
		SELECT @after_update = COUNT(*) FROM silver.crm_sales_details;

		IF (@after_update - @before_update >= 0)
			PRINT 'New rows loaded compared to previous batch: ' + CAST(@after_update - @before_update AS VARCHAR(20)) + ' Rows';
		ELSE
			PRINT 'Warning: Negative row difference detected: ' + CAST(@after_update - @before_update AS VARCHAR(20)) + ' Rows';
		Print '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' Seconds';


		------------------------------------------------------
		-- 2. LOADING ERP TABLES
		------------------------------------------------------
		Print '------------------------------------------------------';
		Print '2-Loading ERP Tables';
		Print '------------------------------------------------------';


		------------------------------------------------------
		-- 2.1 Load silver.erp_loc_101
		-- Standardize country codes and clean customer IDs
		------------------------------------------------------
		SELECT @before_update = COUNT(*) FROM silver.erp_loc_101;
		set @start_time = GETDATE();
		PRINT '2-1 erp_loc_101 ';
		Print 'Truncating Table: silver.erp_loc_101';
		Print 'Count of Rows Before Update = ' + CAST(@before_update AS VARCHAR(20));

		TRUNCATE TABLE silver.erp_loc_101;

		INSERT INTO silver.erp_loc_101 (
			cid,
			cntry
		)
		SELECT 
			REPLACE(cid,'-','') AS cid,
			CASE COALESCE(UPPER(TRIM(cntry)),'')
				WHEN 'DE' THEN 'Germany'
				WHEN 'FR' THEN 'France'
				WHEN 'US' THEN 'United States'
				WHEN 'USA' THEN 'United States'
				WHEN '' THEN 'n/a'
				ELSE cntry
			END AS cntry
		FROM bronze.erp_loc_101;

		Print 'Inserting New Data Into: silver.erp_loc_101'; 
		set @end_time = GETDATE();
		SELECT @after_update = COUNT(*) FROM silver.erp_loc_101;

		IF (@after_update - @before_update >= 0)
			PRINT 'New rows loaded compared to previous batch: ' + CAST(@after_update - @before_update AS VARCHAR(20)) + ' Rows';
		ELSE
			PRINT 'Warning: Negative row difference detected: ' + CAST(@after_update - @before_update AS VARCHAR(20)) + ' Rows';
		Print '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' Seconds';


		------------------------------------------------------
		-- 2.2 Load silver.erp_cust_az12
		-- Validate birthdate and normalize gender
		------------------------------------------------------
		SELECT @before_update = COUNT(*) FROM silver.erp_cust_az12;
		set @start_time = GETDATE();
		PRINT '2-2 erp_cust_az12 ';
		Print 'Truncating Table: silver.erp_cust_az12';
		Print 'Count of Rows Before Update = ' + CAST(@before_update AS VARCHAR(20));

		TRUNCATE TABLE silver.erp_cust_az12;

		INSERT INTO silver.erp_cust_az12 (
			cid,
			bdate,
			gen
		)
		SELECT
			CASE
				WHEN cid LIKE '___AW000%' THEN SUBSTRING(cid,4,15)
				ELSE cid
			END AS cid,
			CASE
				WHEN bdate > GETDATE() THEN NULL
				ELSE bdate
			END AS bdate,
			CASE
				WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
				WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
				ELSE 'n/a'
			END AS gen
		FROM bronze.erp_cust_az12;

		Print 'Inserting New Data Into: silver.erp_cust_az12'; 
		set @end_time = GETDATE();
		SELECT @after_update = COUNT(*) FROM silver.erp_cust_az12;

		IF (@after_update - @before_update >= 0)
			PRINT 'New rows loaded compared to previous batch: ' + CAST(@after_update - @before_update AS VARCHAR(20)) + ' Rows';
		ELSE
			PRINT 'Warning: Negative row difference detected: ' + CAST(@after_update - @before_update AS VARCHAR(20)) + ' Rows';
		Print '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' Seconds';


		------------------------------------------------------
		-- 2.3 Load silver.erp_px_cat_g1v2
		-- Load product category reference data
		------------------------------------------------------
		SELECT @before_update = COUNT(*) FROM silver.erp_px_cat_g1v2;
		set @start_time = GETDATE();
		PRINT '2-3 erp_px_cat_g1v2 ';
		Print 'Truncating Table: silver.erp_px_cat_g1v2';
		Print 'Count of Rows Before Update = ' + CAST(@before_update AS VARCHAR(20));

		TRUNCATE TABLE silver.erp_px_cat_g1v2;

		INSERT INTO silver.erp_px_cat_g1v2 (
			id,
			cat,
			subcat,
			manitenance
		)
		SELECT 
			id,
			cat,
			subcat,
			manitenance
		FROM bronze.erp_px_cat_g1v2;

		Print 'Inserting New Data Into: silver.erp_px_cat_g1v2'; 
		set @end_time = GETDATE();
		SELECT @after_update = COUNT(*) FROM silver.erp_px_cat_g1v2;

		IF (@after_update - @before_update >= 0)
			PRINT 'New rows loaded compared to previous batch: ' + CAST(@after_update - @before_update AS VARCHAR(20)) + ' Rows';
		ELSE
			PRINT 'Warning: Negative row difference detected: ' + CAST(@after_update - @before_update AS VARCHAR(20)) + ' Rows';
		Print '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' Seconds';


		------------------------------------------------------
		-- END OF LOAD PROCESS
		------------------------------------------------------
		Set @batch_end_time = GETDATE();

		Print '*****************************************************';
		Print 'Loading Silver Layer is Completed.';
		Print 'Batch Load Duration: ' + CAST(DATEDIFF(SECOND,@batch_start_time,@batch_end_time) AS NVARCHAR) + ' Seconds';
		Print '*****************************************************';

	End Try
	Begin Catch
		Print '*****************************************************';
		Print 'ERROR OCCURRED DURING LOADING SILVER LAYER';
		Print 'Error Message: ' + ERROR_MESSAGE();
		Print 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		Print 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
		Print '*****************************************************';
	End Catch
End
