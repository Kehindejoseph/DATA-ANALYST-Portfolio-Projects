CREATE DATABASE sales 

SELECT *
FROM sales.dbo.output

-- Find Top 10 highest revenue generating products
SELECT TOP 10 product_id, SUM(sale_price) AS sales
FROM sales.dbo.output
GROUP BY product_id
ORDER BY sales DESC

-- Find Top 5 highest selling products in each region
WITH CTE AS( 
SELECT DISTINCT region, product_id, SUM(sale_price) AS sales
FROM sales.dbo.output
GROUP BY region, product_id)
SELECT *
FROM (
SELECT *,
    row_number() OVER (PARTITION BY region ORDER BY sales DESC) AS rn
FROM CTE) A
WHERE rn <= 5

-- Find month over month growth comparision for 2022 and 2023 sales. e.g : Jan 2022 vs Jan 2023
WITH CTE AS (
SELECT YEAR(order_date) AS order_year, 
    MONTH(order_date) AS order_month, 
    SUM(sale_price) AS sales
FROM sales.dbo.output
GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT order_month,
    SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM CTE
GROUP BY order_month
ORDER BY order_month

--For each category, which month has highest sales

WITH CTE AS (
    SELECT category, 
           RIGHT(CONVERT(VARCHAR(6), order_date, 112), 6) AS order_year_month,
           SUM(sale_price) AS sales
    FROM sales.dbo.output
    GROUP BY category, RIGHT(CONVERT(VARCHAR(6), order_date, 112), 6)
)
SELECT category, order_year_month, sales
FROM (
    SELECT category, order_year_month, sales,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY sales DESC) AS rn
    FROM CTE
) A
WHERE rn = 1;

--Which sub category had the highest growth in profit in 2023 compare to 2022
WITH CTE AS (
SELECT sub_category,year(order_date) AS order_year,
SUM(sale_price) AS sales
FROM sales.dbo.output
GROUP BY sub_category,year(order_date)
--order by year(order_date),month(order_date)
	)
, CTE2 AS (
SELECT sub_category
, sum(CASE WHEN order_year=2022 THEN sales ELSE 0 END) AS sales_2022
, sum(CASE WHEN order_year=2023 THEN sales ELSE 0 END) AS sales_2023
FROM CTE 
GROUP BY sub_category
)
SELECT TOP 1 *
,(sales_2023-sales_2022)
FROM  CTE2
ORDER BY (sales_2023-sales_2022) DESC