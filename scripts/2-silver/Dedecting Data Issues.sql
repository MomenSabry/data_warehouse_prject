-- **************************************************************************************************
-- Purpose: This script explores and identifies data quality issues within all Bronze layer tables.  
-- It performs checks for:
--   - Null and missing values in each column  
--   - Duplicate records and invalid primary key logic  
--   - Inconsistent or invalid data types  
--   - Extra spaces and text quality problems in string columns  
--   - Logical inconsistencies in date and numeric fields  
--   - Referential integrity between tables (foreign key validation)  
--
-- The results from this exploration guide the cleaning and transformation logic 
-- applied later in the Silver layer.
-- **************************************************************************************************



/*
 Select * from bronze.crm_cust_info
 Select * from bronze.erp_cust_az12
 Select * from bronze.erp_loc_101

 Select * from bronze.crm_prd_info
 Select * from bronze.erp_px_cat_g1v2

 Select * from bronze.crm_sales_details
*/


----------------------------------------------------------crm_cust_info--------------------------------------------
-------------------------------------------------------------------------------------------------------------------
--Select * from bronze.crm_cust_info
/* *****Check Nulls in columns*****
DECLARE @sql NVARCHAR(MAX) = '';
SELECT @sql = @sql +
    'SELECT ''' + COLUMN_NAME + ''' AS column_Name, ' +
    'COUNT(*) - COUNT(' + COLUMN_NAME + ') AS null_count, ' +
    'CAST((COUNT(*) - COUNT(' + COLUMN_NAME + ')) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS null_percent ' +
    'FROM bronze.crm_cust_info UNION ALL '
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'crm_cust_info'
  AND TABLE_SCHEMA = 'bronze';

SET @sql = LEFT(@sql, LEN(@sql) - 10); -- Remove last UNION ALL
EXEC(@sql);

--We found there is 3 null record in cst_id(Not Null & Unique Key)
--We found that Null Percentage in cst_gndr Column is around 25%,
So we need to check if the data qulity for this column in erp_cust_az12 table is better
*/

/* *****Check Duplicate In PK Column*****
SELECT 
cst_id,
COUNT(*) --OVER (PARTITION BY cst_id) AS DuplicateCount
FROM bronze.crm_cust_info
where cst_id is not null
group by cst_id
having COUNT(*) > 1

--There is Duplicate in some records so we will take the last updated record(cst_create_date) for the customer
*/

/* ********Check if there is a diff between cst_id and cst_key******
 select 
	cst_id,
	RIGHT(cst_key,5)
 from bronze.crm_cust_info
 where convert(varchar(25),cst_id)  != RIGHT(cst_key,5)

select 
	left(cst_key,5),
	count(left(cst_key,5))
from bronze.crm_cust_info
--where cst_id is not null
group by left(cst_key,5)

--The cst_key Column = 'AW000' + cst_id
There is no diff but there is 3 records has null values in all column except cst_key
*/
/*Check Column Data Type
We found no problem
*/

/* Check If there is spaces in string Columns
select
	cst_firstname
from bronze.crm_cust_info
where cst_firstname != trim(cst_firstname)

select
	cst_lastname
from bronze.crm_cust_info
where cst_lastname != trim(cst_lastname)


There is a qulity issue so we will use trim wiht all text columns
*/

----------------------------------------------------------erp_cust_az12--------------------------------------------
-------------------------------------------------------------------------------------------------------------------
-- Select * from bronze.erp_cust_az12

/* *****Check Nulls in columns*****
DECLARE @sql NVARCHAR(MAX) = '';
SELECT @sql = @sql +
    'SELECT ''' + COLUMN_NAME + ''' AS column_Name, ' +
    'COUNT(*) - COUNT(' + COLUMN_NAME + ') AS null_count, ' +
    'CAST((COUNT(*) - COUNT(' + COLUMN_NAME + ')) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS null_percent ' +
    'FROM bronze.erp_cust_az12 UNION ALL '
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'erp_cust_az12'
  AND TABLE_SCHEMA = 'bronze';

SET @sql = LEFT(@sql, LEN(@sql) - 10); -- Remove last UNION ALL
EXEC(@sql);

--There is no Null values in cid(Primary Key)
--We found that Null Percentage in gen column is around 8%,
So we can use this column instead of cst_gndr column in crm_cust_info after merging in gold layer
*/

/* **********Modify cid column to conect with crm_cust_info table***********
with updated_cid As
(
select
	case
	when cid like '___AW000%' then SUBSTRING(cid,4,len(cid)-3)
	else cid
	End cid,
	bdate,
	gen
from bronze.erp_cust_az12
)
-- Check
select
	c.*,
	t.bdate,
	t.gen
from silver.crm_cust_info c
inner join updated_cid t on t.cid = c.cst_key

-- Done
-- We found that all the customer in silver.crm_cust_info has record in erp_cust_az12
*/

/* *****Check Duplicate In PK Column*****
select 
	cid,
	count(cid)
from updated_cid
group by cid
having COUNT(cid) > 1

--There is No Duplicate.
*/


/*Check Column Data Type
We found no problem
*/

/* Check If there is spaces in string Columns
Select Distinct(gen) from bronze.erp_cust_az12

select
	gen
from bronze.erp_cust_az12
where gen != trim(gen)

There is no Spaces detected
*/
/* ******Check if there is not logical bdate******
select 
bdate
from bronze.erp_cust_az12
where bdate > getdate()

*/


----------------------------------------------------------erp_loc_101--------------------------------------------
-------------------------------------------------------------------------------------------------------------------
-- Select * from bronze.erp_loc_101

/* *****Check Nulls in columns*****
DECLARE @sql NVARCHAR(MAX) = '';
SELECT @sql = @sql +
    'SELECT ''' + COLUMN_NAME + ''' AS column_Name, ' +
    'COUNT(*) - COUNT(' + COLUMN_NAME + ') AS null_count, ' +
    'CAST((COUNT(*) - COUNT(' + COLUMN_NAME + ')) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS null_percent ' +
    'FROM bronze.erp_loc_101 UNION ALL '
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'erp_loc_101'
  AND TABLE_SCHEMA = 'bronze';

SET @sql = LEFT(@sql, LEN(@sql) - 10); -- Remove last UNION ALL
EXEC(@sql);

--There is no Null values in cid(Primary Key)
*/


/* **********Modify cid column to conect with crm_cust_info table***********
with updated_cid As
(
select
	REPLACE(cid,'-','') cid,
	cntry
from bronze.erp_loc_101
)
-- Check
select
	c.*,
	t.cntry
from silver.crm_cust_info c
inner join updated_cid t on t.cid = c.cst_key

-- Done
-- We found that all the customer in silver.crm_cust_info has record in erp_loc_101
*/

/* *****Check Duplicate In PK Column*****

select 
	cid,
	count(cid)
from updated_cid
group by cid
having COUNT(cid) > 1

--There is No Duplicate.
*/


/*Check Column Data Type
We found no problem
*/



/* Check The Quality of text Columns
select
	cntry
from bronze.erp_loc_101
where cntry != trim(cntry)

Select Distinct(cntry) from bronze.erp_loc_101;

with updated_country as
(
Select
  CASE COALESCE(upper(trim(cntry)),'')
    WHEN 'DE' THEN 'Germany'
    WHEN 'FR' THEN 'France'
    WHEN 'US' THEN 'United States'
    WHEN 'USA' THEN 'United States'
	WHEN '' then 'n/a'
    ELSE cntry
  END AS cntry
from bronze.erp_loc_101
)

Select Distinct(cntry) from updated_country;

-- If a large number of abbreviations are detected in the future, they should be managed in a separate table for abbreviations.
*/
/* ******Check if there is not logical bdate******
select 
bdate
from bronze.erp_cust_az12
where bdate > getdate()

*/

----------------------------------------------------------crm_prd_info--------------------------------------------
-------------------------------------------------------------------------------------------------------------------
-- Select * from bronze.crm_prd_info

/* *****Check Nulls in columns*****
DECLARE @sql NVARCHAR(MAX) = '';
SELECT @sql = @sql +
    'SELECT ''' + COLUMN_NAME + ''' AS column_Name, ' +
    'COUNT(*) - COUNT(' + COLUMN_NAME + ') AS null_count, ' +
    'CAST((COUNT(*) - COUNT(' + COLUMN_NAME + ')) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS null_percent ' +
    'FROM bronze.crm_prd_info UNION ALL '
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'crm_prd_info'
  AND TABLE_SCHEMA = 'bronze';

SET @sql = LEFT(@sql, LEN(@sql) - 10); -- Remove last UNION ALL
EXEC(@sql);

--There is no Null values in prd_id(Primary Key)
*/


/* *****Check Duplicate In PK Column*****

select 
	prd_id,
	count(prd_id)
from bronze.crm_prd_info
group by prd_id
having COUNT(prd_id) > 1

--There is No Duplicate.
*/


/*Check Column Data Type
We found no problem
*/

/* Check The Quality of text Columns
select
	prd_line
from bronze.crm_prd_info
where prd_line != trim(prd_line)


Select Distinct(prd_line) from 
(
 select
	case  upper(trim(prd_line))
	when 'M' then 'Mountain'
	when 'R' then 'Road'
	when 'T' then 'Tournig'
	when 'S' then 'Othen Sales'
	else 'n/a'
	end prd_line
from bronze.crm_prd_info
)t

-- Done.
*/




/* ********Check the prd_key as FK*********
select
	prd_id,
	Replace(left(prd_key,5),'-','_') cat_id,
	SUBSTRING(prd_key,7,len(prd_key)-6) prd_key
from bronze.crm_prd_info
--where Replace(left(prd_key,5),'-','_') not in (select id from bronze.erp_px_cat_g1v2)
--where SUBSTRING(prd_key,7,len(prd_key)-6) Not in (  Select sls_prd_key from bronze.crm_sales_details )

*/

/* Check The qulity of int columns

 Select * from bronze.crm_prd_info order by prd_cost

 SELECT ISNULL(prd_cost, 0) prd_cost
FROM bronze.crm_prd_info
ORDER BY prd_cost;  -- Assume that this is the business requirement

*/

/* ******Check if there is not logical date******

select 
	*
from bronze.crm_prd_info
where prd_start_dt > prd_end_dt
order by prd_end_dt


select 
	*,
	dateadd(day,-1,lead(prd_start_dt,1) over(partition by prd_key order by prd_start_dt)) new_end_date
from bronze.crm_prd_info
order by prd_key

-- The prd_end_dt value precedes the prd_start_dt, which indicates an inconsistency in the product data. Reversing the dates is not a valid correction,
as there are overlapping date ranges associated with the same product key. To resolve this issue,
we will set the current record’s end date (prd_end_dt) to be one day prior to the next record’s start date (next_prd_start_dt - 1 day) 
within the same product key.
*/



----------------------------------------------------------crm_sales_details--------------------------------------------
-------------------------------------------------------------------------------------------------------------------
-- select * from bronze.crm_sales_details

/* *****Check Nulls in columns*****
DECLARE @sql NVARCHAR(MAX) = '';
SELECT @sql = @sql +
    'SELECT ''' + COLUMN_NAME + ''' AS column_Name, ' +
    'COUNT(*) - COUNT(' + COLUMN_NAME + ') AS null_count, ' +
    'CAST((COUNT(*) - COUNT(' + COLUMN_NAME + ')) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS null_percent ' +
    'FROM bronze.crm_sales_details UNION ALL '
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'crm_sales_details'
  AND TABLE_SCHEMA = 'bronze';

SET @sql = LEFT(@sql, LEN(@sql) - 10); -- Remove last UNION ALL
EXEC(@sql);

--There is no Null values in prd_id(Primary Key)
*/

/* *****Check Duplicate In PK Column*****

select 
	sls_ord_num,
	count(sls_ord_num)
from bronze.crm_sales_details
group by sls_ord_num
having COUNT(sls_ord_num) > 1

--As each row corresponds to a specific product within an order, the table lacks a natural primary key. 
A composite key will be derived by concatenating the order_key and prd_key to uniquely identify each record.

with newtable as
(
select
	concat(sls_ord_num,'-',sls_prd_key) new_key,
	*
from bronze.crm_sales_details
)
select 
	new_key,
	count(new_key)
from newtable
group by new_key
having COUNT(new_key) > 0
*/


/* ********Check The Quality of text Columns********
select
	sls_prd_key
from bronze.crm_sales_details
where sls_prd_key != trim(sls_prd_key)

-- Done.
*/



/* Check The qulity of int columns

select
	*
from bronze.crm_sales_details
where sls_sales != sls_quantity * sls_price
or sls_sales is null or sls_quantity is null or sls_price is null
or sls_sales <=0 or sls_quantity <=0 or sls_price <=0;

-- We found negative ,Null and Zero values so we will follow this rules to clean the data
1- IF sales is negative , Null or Zero derive it using Quantity and Price
2- IF price is negative then convert it to positve
3- IF price is null or zero then calculate it using sales and quatatity

with t as
(
select
	case 
	when isnull(sls_sales,0) <= 0 or sls_sales != abs(sls_quantity) * abs(sls_price) then abs(sls_quantity) * abs(sls_price)
	else sls_sales
	end sls_sales,
	sls_quantity,
	case
	when isnull(sls_price,0) <= 0 then abs(sls_sales) / nullif(abs(sls_quantity),0)
	when sls_price < 0 then abs(sls_price)
	else sls_price
	end sls_price
from bronze.crm_sales_details
)

select
	sls_sales,
	sls_quantity,
	sls_price
from t
where sls_sales != sls_quantity * sls_price
or sls_sales is null or sls_quantity is null or sls_price is null
or sls_sales <=0 or sls_quantity <=0 or sls_price <=0;


*/



/* ********Check the prd_key as FK*********
select
	prd_id,
	Replace(left(prd_key,5),'-','_') cat_id,
	SUBSTRING(prd_key,7,len(prd_key)-6) prd_key
from bronze.crm_prd_info
--where Replace(left(prd_key,5),'-','_') not in (select id from bronze.erp_px_cat_g1v2)
--where SUBSTRING(prd_key,7,len(prd_key)-6) Not in (  Select sls_prd_key from bronze.crm_sales_details )

*/

/*Check Column Data Type
We found no problem
*/


/* ******Check if there is not logical date******



with new as
(
select
	CONCAT(sls_ord_num,'-',sls_prd_key) transaction_key,
	sls_ord_num,
	sls_prd_key,
	case 
	when len(sls_order_dt) = 8 then CONVERT(date, CONVERT(char(8), sls_order_dt))
	else DATEADD(day,-7,CONVERT(date, CONVERT(char(8), sls_ship_dt)))
	end sls_order_dt,
	CONVERT(date, CONVERT(char(8), sls_ship_dt)) sls_ship_dt,
	CONVERT(date, CONVERT(char(8), sls_due_dt)) sls_due_dt
from bronze.crm_sales_details
where len(sls_order_dt) != 8
)
select 
	*,
	DATEDIFF(day,sls_order_dt,sls_ship_dt) order_ship
from new
order by DATEDIFF(day,sls_order_dt,sls_ship_dt)


-- we found there is null values in order date so after exploring date columns we found that always ship date after order date with 7 days and due date after 
ship date with 5 days, so we will fill the missing order date wiht 7 days before shipping date
*/



----------------------------------------------------------erp_px_cat_g1v2-----------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------
-- select * from bronze.crm_sales_details

/* *****Check Nulls in columns*****
DECLARE @sql NVARCHAR(MAX) = '';
SELECT @sql = @sql +
    'SELECT ''' + COLUMN_NAME + ''' AS column_Name, ' +
    'COUNT(*) - COUNT(' + COLUMN_NAME + ') AS null_count, ' +
    'CAST((COUNT(*) - COUNT(' + COLUMN_NAME + ')) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS null_percent ' +
    'FROM bronze.erp_px_cat_g1v2 UNION ALL '
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'erp_px_cat_g1v2'
  AND TABLE_SCHEMA = 'bronze';

SET @sql = LEFT(@sql, LEN(@sql) - 10); -- Remove last UNION ALL
EXEC(@sql);

--There is no Null values in prd_id(Primary Key)
*/


/* *****Check Duplicate In PK Column*****

select count(distinct(id)) - count(*) from bronze.erp_px_cat_g1v2

-- Done
*/

/* ********Check The Quality of text Columns********
select
	*
from bronze.erp_px_cat_g1v2
where id != trim(id) or cat != trim(cat) or subcat != trim(subcat) or manitenance != trim(manitenance)

 select distinct(cat) from bronze.erp_px_cat_g1v2
 select distinct(manitenance) from bronze.erp_px_cat_g1v2

-- Done.
*/