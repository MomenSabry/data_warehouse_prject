/*
Procedure: bronze.load_bronze
Purpose:
  Loads raw source data into Bronze layer staging tables. Data is fully replaced
  each execution using TRUNCATE+Bulk Insert to ensure exact synchronization with 
  CRM and ERP source files. Performance metrics and row deltas are printed for 
  audit transparency and troubleshooting.

Behavior:
  • Tracks row counts before and after load
  • Prints number of newly inserted rows and duration per table
  • Captures batch duration and error details in Try/Catch
  • Ensures raw landing zone remains untransformed for downstream processing
*/


--Exec bronze.load_bronze
Create or Alter Procedure bronze.load_bronze As
Begin
	Declare @start_time datetime, @end_time datetime Declare @batch_start_time datetime, @batch_end_time datetime 	
	Declare @before_update INT; Declare @after_update INT;
	Begin Try
		Set @batch_start_time = GETDATE()
		Print '*****************************************************';
		Print 'Loading Bronze Layer';
		Print '*****************************************************';
		Print ''

		Print '------------------------------------------------------';
		Print '1-Loading CRM Tables';
		Print '------------------------------------------------------';

		SELECT @before_update = COUNT(*) FROM bronze.crm_cust_info;
		set @start_time = GETDATE();
		PRINT '1-1 crm_cust_info '
		Print 'Trancating Table: bronze.crm_cust_info'
		Print 'Count of Rows Before Update = ' + CAST(@before_update AS VARCHAR(20));

		Truncate table bronze.crm_cust_info
		Bulk insert bronze.crm_cust_info 
		from 'D:\Data Projects\SQL Data Warehouse Project\datasets\source_crm\cust_info.csv'
		with(
			firstrow = 2, 
			fieldterminator = ',',
			tablock
		);

		Print 'Inserting New Data Into: bronze.crm_cust_info' 
		set @end_time = GETDATE();
		SELECT @after_update  = COUNT(*) FROM bronze.crm_cust_info;
		IF (@after_update - @before_update >= 0)
			PRINT 'New rows loaded compared to previous batch: ' + CAST(@after_update - @before_update AS VARCHAR(20)) + ' Rows';
		ELSE
			PRINT '			Warning: Negative row difference detected'+ CAST(@after_update - @before_update AS VARCHAR(20)) + ' Rows';
		Print '>> Load Duration: ' + Cast(datediff(second,@start_time,@end_time) as Nvarchar) + ' Seconds'
		Print '--------------------'
---------------------------------
		SELECT @before_update = COUNT(*) FROM bronze.crm_prd_info;
		set @start_time = GETDATE();
		PRINT '1-2 crm_prd_info '
		Print 'Trancating Table: bronze.crm_prd_info'
		Print 'Count of Rows Before Update = ' + CAST(@before_update AS VARCHAR(20));

		Truncate table bronze.crm_prd_info
		Bulk insert bronze.crm_prd_info 
		from 'D:\Data Projects\SQL Data Warehouse Project\datasets\source_crm\prd_info.csv'
		with(
			firstrow = 2, 
			fieldterminator = ',',
			tablock
		);

		Print 'Inserting New Data Into: bronze.crm_prd_info'
		set @end_time = GETDATE();
		SELECT @after_update  = COUNT(*) FROM bronze.crm_prd_info;
		IF (@after_update - @before_update >= 0)
			PRINT 'New rows loaded compared to previous batch: ' + CAST(@after_update - @before_update AS VARCHAR(20)) + ' Rows';
		ELSE
			PRINT '			Warning: Negative row difference detected'+ CAST(@after_update - @before_update AS VARCHAR(20)) + ' Rows';
		Print '>> Load Duration: ' + Cast(datediff(second,@start_time,@end_time) as Nvarchar) + ' Seconds'
		Print '--------------------'
------------------------------------------------------------------
		SELECT @before_update = COUNT(*) FROM bronze.crm_sales_details;
		set @start_time = GETDATE();
		PRINT '1-3 crm_sales_details '
		Print 'Trancating Table: bronze.crm_sales_details'
		Print 'Count of Rows Before Update = ' + CAST(@before_update AS VARCHAR(20));

		Truncate table bronze.crm_sales_details
		Bulk insert bronze.crm_sales_details 
		from 'D:\Data Projects\SQL Data Warehouse Project\datasets\source_crm\sales_details.csv'
		with(
			firstrow = 2, 
			fieldterminator = ',',
			tablock
		);

		Print 'Inserting New Data Into: bronze.crm_sales_details'
		set @end_time = GETDATE();
		SELECT @after_update  = COUNT(*) FROM bronze.crm_sales_details;
		IF (@after_update - @before_update >= 0)
			PRINT 'New rows loaded compared to previous batch: ' + CAST(@after_update - @before_update AS VARCHAR(20)) + ' Rows';
		ELSE
			PRINT '			Warning: Negative row difference detected'+ CAST(@after_update - @before_update AS VARCHAR(20)) + ' Rows';
		Print '>> Load Duration: ' + Cast(datediff(second,@start_time,@end_time) as Nvarchar) + ' Seconds'
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
		Print '------------------------------------------------------';
		Print '2-Loading ERP Tables';
		Print '------------------------------------------------------';

		SELECT @before_update = COUNT(*) FROM bronze.erp_cust_az12;
		set @start_time = GETDATE();
		PRINT '2-1 erp_cust_az12 '
		Print 'Trancating Table: bronze.erp_cust_az12'
		Print 'Count of Rows Before Update = ' + CAST(@before_update AS VARCHAR(20));

		Truncate table bronze.erp_cust_az12
		Bulk insert bronze.erp_cust_az12 
		from 'D:\Data Projects\SQL Data Warehouse Project\datasets\source_erp\CUST_AZ12.csv'
		with(
			firstrow = 2, 
			fieldterminator = ',',
			tablock
		);

		Print 'Inserting New Data Into: bronze.erp_cust_az12'
		set @end_time = GETDATE();
		SELECT @after_update  = COUNT(*) FROM bronze.erp_cust_az12;
		IF (@after_update - @before_update >= 0)
			PRINT 'New rows loaded compared to previous batch: ' + CAST(@after_update - @before_update AS VARCHAR(20)) + ' Rows';
		ELSE
			PRINT '			Warning: Negative row difference detected'+ CAST(@after_update - @before_update AS VARCHAR(20)) + ' Rows';
		Print '>> Load Duration: ' + Cast(datediff(second,@start_time,@end_time) as Nvarchar) + ' Seconds'
		Print '--------------------'
------------------------------------------------------------------
SELECT @before_update = COUNT(*) FROM bronze.erp_loc_101;
		set @start_time = GETDATE();
		PRINT '2-2 erp_loc_101 '
		Print 'Trancating Table: bronze.erp_loc_101'
		Print 'Count of Rows Before Update = ' + CAST(@before_update AS VARCHAR(20));

		Truncate table bronze.erp_loc_101
		Bulk insert bronze.erp_loc_101 
		from 'D:\Data Projects\SQL Data Warehouse Project\datasets\source_erp\LOC_A101.csv'
		with(
			firstrow = 2, 
			fieldterminator = ',',
			tablock
		);

		Print 'Inserting New Data Into: bronze.erp_loc_101'
		set @end_time = GETDATE();
		SELECT @after_update  = COUNT(*) FROM bronze.erp_loc_101;
		IF (@after_update - @before_update >= 0)
			PRINT 'New rows loaded compared to previous batch: ' + CAST(@after_update - @before_update AS VARCHAR(20)) + ' Rows';
		ELSE
			PRINT '			Warning: Negative row difference detected'+ CAST(@after_update - @before_update AS VARCHAR(20)) + ' Rows';
		Print '>> Load Duration: ' + Cast(datediff(second,@start_time,@end_time) as Nvarchar) + ' Seconds'
		Print '--------------------'
--------------------------------------------------------
		SELECT @before_update = COUNT(*) FROM bronze.erp_px_cat_g1v2;
		set @start_time = GETDATE();
		PRINT '2-3 erp_px_cat_g1v2 '
		Print 'Trancating Table: bronze.erp_px_cat_g1v2'
		Print 'Count of Rows Before Update = ' + CAST(@before_update AS VARCHAR(20));


		Truncate table bronze.erp_px_cat_g1v2
		Bulk insert bronze.erp_px_cat_g1v2 
		from 'D:\Data Projects\SQL Data Warehouse Project\datasets\source_erp\PX_CAT_G1V2.csv'
		with(
			firstrow = 2, 
			fieldterminator = ',',
			tablock
		);

		Print 'Inserting New Data Into: bronze.erp_px_cat_g1v2'
		set @end_time = GETDATE();
		SELECT @after_update  = COUNT(*) FROM bronze.erp_px_cat_g1v2;
		IF (@after_update - @before_update >= 0)
			PRINT 'New rows loaded compared to previous batch: ' + CAST(@after_update - @before_update AS VARCHAR(20)) + ' Rows';
		ELSE
			PRINT '			Warning: Negative row difference detected'+ CAST(@after_update - @before_update AS VARCHAR(20)) + ' Rows';
		Print '>> Load Duration: ' + Cast(datediff(second,@start_time,@end_time) as Nvarchar) + ' Seconds'
		Print '--------------------'


		Set @batch_end_time = GETDATE()

		Print '*****************************************************';
		Print 'Loading Bronze Layer is Completed.';
		print 'Batch Load Duration: ' + Cast(datediff(second,@batch_start_time,@batch_end_time) as Nvarchar) + ' Seconds';
		Print '*****************************************************';
	End Try
	Begin Catch
		Print '*****************************************************'
		Print 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		Print 'Error Message ' + Error_Message();
		Print 'Error Message ' + cast(Error_Number() As Nvarchar);
		Print 'Error Message ' + cast(Error_State()As Nvarchar);
		Print '*****************************************************'


	End Catch
End