/*
/*===============================================================================
Overview – Analytical Queries for Sales, Customer, and Product Performance
===============================================================================
This section contains a collection of analytical SQL queries designed to explore
sales trends, customer behaviors, and product performance over time. The queries
cover several types of business analysis, including:

1. **Change Over Time Analysis**
   - Monthly and yearly sales trends.
   - Customer activity levels by time period.
   - Quantity sold and revenue ranking.
   - Running totals and moving averages.

2. **Performance Analysis (YoY & MoM)**
   - Year-over-year change in product revenue.
   - Comparison of each product's annual sales to its historical average.
   - Identification of performance trends (Increase, Decrease, No Change).

3. **Data Segmentation Analysis**
   - Customer segmentation into VIP, Regular, and New based on lifecycle and
     spending thresholds.
   - Summary counts of customers by segment.

4. **Part-to-Whole Analysis**
   - Contribution of each product category to overall company revenue.
   - Percentage share of category sales.

These queries support exploratory analysis, dashboard creation, and deeper 
insights into business performance trends across customers, products, and 
time periods.
===============================================================================*/





--===============================================================================
--Change Over Time Analysis

SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity,
	RANK() over(order by SUM(sales_amount) desc) total_sales_rank
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);


SELECT
    YEAR(order_date) AS order_year,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity,
	RANK() over(order by SUM(sales_amount) desc) total_sales_rank
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date)
-- Noting that there is only one month in 2010 and 2014


SELECT
    MONTH(order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity,
	RANK() over(order by SUM(sales_amount) desc) total_sales_rank
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY  MONTH(order_date)
ORDER BY  MONTH(order_date);

----------------------------------------------------
-- Calculate the total sales per month 
-- and the running total of sales over time 
SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
	AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
FROM
(
    SELECT 
        DATETRUNC(year, order_date) AS order_date,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM gold.fact_sales
    GROUP BY DATETRUNC(year, order_date)
) t




===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Analyze the yearly performance of products by comparing their sales 
to both the average sales performance of the product and the previous year's sales 



with t as
(
select 
	year(s.order_date) order_year,
	p.product_key,
	p.product_name,
	sum(s.sales_amount) yearly_sales
from gold.dim_products p
left join gold.fact_sales s on s.product_key = p.product_key
group by year(s.order_date), p.product_key,p.product_name
having sum(s.sales_amount) is not null
--order by p.product_name
)

select
	*,
	avg(yearly_sales) over(partition by product_key) avg_sales,
	diff_avg = yearly_sales - avg(yearly_sales) over(partition by product_key),
	case 
	when yearly_sales - avg(yearly_sales) over(partition by product_key) > 0 then 'Above Avg'
	when yearly_sales - avg(yearly_sales) over(partition by product_key) < 0 then 'Below Avg'
	else 'Avg'
	end avg_change,
	last_year_sales = lag(yearly_sales,1) over(partition by product_key order by order_year),
	last_year_diff = yearly_sales - lag(yearly_sales,1) over(partition by product_key order by order_year),
	case
	when yearly_sales - lag(yearly_sales,1) over(partition by product_key order by order_year) > 0 then 'Increase'
	when yearly_sales - lag(yearly_sales,1) over(partition by product_key order by order_year) < 0 then 'Decrease'
	when yearly_sales - lag(yearly_sales,1) over(partition by product_key order by order_year) = 0 then 'No Change'
	when yearly_sales - lag(yearly_sales,1) over(partition by product_key order by order_year) is null then 'No Previous year'
	--else 'constant'
	end last_year_diff
from t
order by product_name

*/


/*
select
	cost_range,
	count(cost_range) total_products
from
(
	select 
		case
		when cost < 100 then 'Below 100'
		when cost between 100 and 500 then '100 - 500'
		when cost between 500 and 1000 then '500 - 1000'
		else 'Above 1000'
		end cost_range
	from gold.dim_products
)t
group by cost_range
order by count(cost_range) desc



===============================================================================
Data Segmentation Analysis
==============================================================================

Group customers into three segments based on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than €5,000.
	- Regular: Customers with at least 12 months of history but spending €5,000 or less.
	- New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
WITH customer_order_summary AS (
    SELECT 
        c.customer_key,
        MIN(s.order_date) AS first_order,
        MAX(s.order_date) AS last_order,
        DATEDIFF(month, MIN(s.order_date), MAX(s.order_date)) AS lifecycle_months,
        SUM(s.sales_amount) AS total_sales
    FROM gold.dim_customers c
    LEFT JOIN gold.fact_sales s
        ON s.customer_key = c.customer_key
    GROUP BY c.customer_key
),
customer_tags AS (
    SELECT 
        customer_key,
        lifecycle_months,
        total_sales,
        CASE 
            WHEN lifecycle_months >= 12 AND total_sales > 5000 THEN 'VIP'
            WHEN lifecycle_months >= 12 AND total_sales <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_order_summary
)

SELECT 
    customer_segment,
    COUNT(*) AS customer_count
FROM customer_tags
GROUP BY customer_segment;



===============================================================================
Part-to-Whole Analysis
===============================================================================
-- Which categories contribute the most to overall sales?
with category_sales as
(
	select 
		p.category,
		sum(s.sales_amount) category_sales
	from gold.dim_products p
	left join gold.fact_sales s
	on p.product_key = s.product_key
	group by p.category
	having sum(s.sales_amount) is not null
)

select 
	*,
	total_sales = sum(category_sales) over(),
	category_contruibution= ROUND((CAST(category_sales AS FLOAT) / SUM(category_sales) OVER ()) * 100, 2)
from category_sales
*/