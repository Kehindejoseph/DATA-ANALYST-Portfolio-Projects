-- 1.
 CREATE DATABASE WalmartSalesData


-- 2. Create Dulicating the Table
CREATE TABLE [dbo].[Sales] (
    [Invoice_ID]              NVARCHAR (50) NOT NULL,
    [Branch]                  NVARCHAR (50) NOT NULL,
    [City]                    NVARCHAR (50) NOT NULL,
    [Customer_type]           NVARCHAR (50) NOT NULL,
    [Gender]                  NVARCHAR (50) NOT NULL,
    [Product_line]            NVARCHAR (50) NOT NULL,
    [Unit_price]              FLOAT (53)    NOT NULL,
    [Quantity]                TINYINT       NOT NULL,
    [Tax_5]                   FLOAT (53)    NOT NULL,
    [Total]                   FLOAT (53)    NOT NULL,
    [Date]                    DATE          NOT NULL,
    [Time]                    TIME (7)      NOT NULL,
    [Payment]                 NVARCHAR (50) NOT NULL,
    [cogs]                    FLOAT (53)    NOT NULL,
    [gross_margin_percentage] FLOAT (53)    NOT NULL,
    [gross_income]            FLOAT (53)    NOT NULL,
    [Rating]                  FLOAT (53)    NOT NULL,
    [row_num]                 INT
)
GO

-- To check
SELECT *
FROM WalmartSalesData.dbo.Sales

-- To check for duplicates
--Step 1
SELECT *,
    ROW_NUMBER() OVER (PARTITION BY Invoice_ID, Branch, City, Customer_type, Gender, Product_line, Unit_price, Quantity, Tax_5, 
    Total, Date, Time, Payment, cogs,gross_margin_percentage, gross_income, Rating ORDER BY Date) AS row_num
FROM WalmartSalesData;

--Step 2
WITH duplicate_cte AS
(
SELECT *,
    ROW_NUMBER() OVER (PARTITION BY Invoice_ID, Branch, City, Customer_type, Gender, Product_line, Unit_price, Quantity, Tax_5, 
    Total, Date, Time, Payment, cogs,gross_margin_percentage, gross_income, Rating ORDER BY Date) AS row_num
FROM WalmartSalesData
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

--Step 3
INSERT INTO Sales
SELECT *,
    ROW_NUMBER() OVER (PARTITION BY Invoice_ID, Branch, City, Customer_type, Gender, Product_line, Unit_price, Quantity, Tax_5, 
    Total, Time, Payment, cogs,gross_margin_percentage, gross_income, Rating ORDER BY date) AS row_num
FROM WalmartSalesData

--Step 4
SELECT *
FROM WalmartSalesData.dbo.sales



/************************************************************************************************************************************
******************************                    FEATURING ENGINEERING               ***********************************************
************************************************************************************************************************************/

SELECT *
FROM WalmartSalesData.dbo.Sales

-- 1. time_of_day

SELECT 
    time,
    CASE
        WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'  
        WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_of_day
FROM WalmartSalesData.dbo.Sales;

-- a.) Add column(time_of_day) to the Sales Table

ALTER TABLE WalmartSalesData.dbo.Sales
ADD time_of_day VARCHAR(20);

-- b.) Update time_of_day
UPDATE WalmartSalesData.dbo.Sales
SET time_of_day =     CASE
        WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'  
        WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
END;

-- Dropped row_num
DROP COLUMN row_num;


-- 2.  day_name

-- a.) Add column(day_name) to the Sales Table
SELECT 
    Date,
    DATENAME(WEEKDAY, Date) AS day_name
FROM WalmartSalesData.dbo.Sales;

-- Add column(day_name) to the Sales Table

ALTER TABLE WalmartSalesData.dbo.Sales
ADD day_name VARCHAR(20);

-- b.) To Update Table with day_name values
UPDATE WalmartSalesData.dbo.Sales
SET day_name = DATENAME(WEEKDAY, Date);

-- 3. month_name

SELECT 
    date,
    DATENAME(MONTH, date) AS month_name
FROM WalmartSalesData.dbo.Sales;

-- a.) Add column(month_name) to the Sales Table
ALTER TABLE WalmartSalesData.dbo.Sales
ADD month_name VARCHAR(20);

-- b.) To Update Table with month_name values
UPDATE WalmartSalesData.dbo.Sales
SET month_name = DATENAME(MONTH, date);


/************************************************************************************************************************************
******************************                 EXPLANATORY DATA ANALYSIS              ***********************************************
************************************************************************************************************************************/


------------------------------------------------------------------------------------------------------------------
----------------------   Generic  ---------------------------
SELECT *
FROM WalmartSalesData.dbo.Sales;


SELECT city
FROM WalmartSalesData.dbo.Sales

-- 1. How many unique cities does the data have?
SELECT
DISTINCT city 
FROM WalmartSalesData.dbo.Sales;

-- 2. In which city is each branch
SELECT 
    DISTINCT city, branch
FROM WalmartSalesData.dbo.Sales;


/******************************************************************
--------------  BUSINESS QUESTIONS TO ANSWER --------------
*******************************************************************/

-------------------------------------------------
-----  (A)  Product      ------------------------
-------------------------------------------------
SELECT *
FROM WalmartSalesData.dbo.Sales;


-- 1. How  many unique product does the data have?
SELECT
    DISTINCT product_line
FROM WalmartSalesData.dbo.Sales;

-- 2. What is the most common payment method?
SELECT
    DISTINCT Payment, COUNT(Payment) AS payment_count
FROM WalmartSalesData.dbo.Sales
GROUP BY Payment
ORDER BY payment_count DESC;

-- 3. What is the most selling product line?
SELECT
    product_line,
    COUNT(Product_line) AS Product_line_count
FROM WalmartSalesData.dbo.Sales
GROUP BY product_line
ORDER BY Product_line_count DESC;

-- 4. What is the total revenue by month?
SELECT
    month_name AS month, 
    SUM(total) AS total_revenue
FROM WalmartSalesData.dbo.Sales
GROUP BY month_name
ORDER BY total_revenue DESC;

-- 5. What month had the largest Cost Of Goods sold(COGS)?
SELECT
    month_name AS month, 
    SUM(cogs) AS SUM_cogs
FROM WalmartSalesData.dbo.Sales
GROUP BY month_name
ORDER BY SUM_cogs DESC;

-- 6. What product line had the largest revenue?
SELECT
    Product_line, 
    SUM(total) AS total_revenue
FROM WalmartSalesData.dbo.Sales
GROUP BY Product_line
ORDER BY total_revenue DESC;

-- 7. What is the city with the largest revenue?
SELECT
    city, branch,
    SUM(total) AS total_revenue
FROM WalmartSalesData.dbo.Sales
GROUP BY city, Branch
ORDER BY total_revenue DESC;

-- 8. What product line had the largest VAT?
SELECT
    Product_line, 
    AVG(Tax_5) AS AVG_Tax
FROM WalmartSalesData.dbo.Sales
GROUP BY Product_line
ORDER BY AVG_Tax DESC;

-- 9. Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
SELECT 
    product_line,
    Quantity,
    CASE
        WHEN Quantity > avg_quantity THEN 'Good'
        ELSE 'Bad'
    END AS Sales_Status
FROM (
    SELECT 
        product_line,
        Quantity,
        AVG(Quantity) OVER (PARTITION BY product_line) AS avg_quantity
    FROM WalmartSalesData.dbo.Sales
) AS subquery_alias;

-- 10. Which branch sold more products than average product sold?
SELECT 
    branch,
    SUM(quantity) AS total_quantity,
    AVG(SUM(quantity)) OVER () AS avg_quantity_across_branches,
    CASE
        WHEN SUM(quantity) > AVG(SUM(quantity)) OVER () THEN 'Above Average'
        ELSE 'Below Average'
    END AS sales_comparison
FROM WalmartSalesData.dbo.Sales
GROUP BY branch;

-- 11. What is the most common product line by gender?
SELECT
    gender,
    product_line,
    COUNT(gender) AS product_count
FROM WalmartSalesData.dbo.Sales
GROUP BY gender, product_line
ORDER BY gender, product_count DESC;

-- 12. What is the average rating of each product line?
SELECT
    product_line,
    ROUND(AVG(rating), 2) AS avg_rating         -- rounding it to 2 decimal place
FROM WalmartSalesData.dbo.Sales
GROUP BY product_line
ORDER BY avg_rating DESC;


---------------------------------------------
---  (B)  Sales      ------------------------
---------------------------------------------
SELECT *
FROM WalmartSalesData.dbo.Sales;

-- 1. Number of sales made in each time of the day per weekday
SELECT 
    time_of_day,
    COUNT(*) AS total_sales
FROM WalmartSalesData.dbo.Sales
WHERE day_name = 'Monday'            -- day_name = 'Tuesday' 
GROUP BY time_of_day
ORDER BY total_sales DESC;

-- 2. Which of the customer types brings the most revenue?
SELECT 
    Customer_type,
    SUM(Total) AS total_revenue
FROM WalmartSalesData.dbo.Sales
GROUP BY Customer_type
ORDER BY total_revenue DESC;

-- 3. Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT
    city,
    ROUND(AVG(Tax_5),2) as VAT
FROM WalmartSalesData.dbo.Sales
GROUP BY City
ORDER BY VAT DESC;

-- 4. Which customer type pays the most in VAT?
SELECT 
    Customer_type,
    SUM(Tax_5) AS VAT_paid
FROM WalmartSalesData.dbo.Sales
GROUP BY Customer_type
ORDER BY VAT_paid DESC;

-------------------------------------------------
-----  (C)  Customer      ------------------------
-------------------------------------------------
SELECT *
FROM WalmartSalesData.dbo.Sales;

-- 1. How many unique customer types does the data have?
SELECT
    DISTINCT Customer_type 
FROM WalmartSalesData.dbo.Sales;

-- 2. How many unique payment methods does the data have?
SELECT
    DISTINCT Payment 
FROM WalmartSalesData.dbo.Sales;

-- 3. What is the most common customer type?
SELECT
    Customer_type,
    COUNT(Customer_type) AS Most_Customer_Type 
FROM WalmartSalesData.dbo.Sales
GROUP BY Customer_type
ORDER BY Most_Customer_Type DESC;

-- 4. Which customer type buys the most?
SELECT
    Customer_type,
    COUNT(*) AS Most_Customer_Quantity 
FROM WalmartSalesData.dbo.Sales
GROUP BY Customer_type
ORDER BY Most_Customer_Quantity DESC;

-- 5. What is the gender of most of the customers?
SELECT
    Gender,
    COUNT(*) AS gender_count 
FROM WalmartSalesData.dbo.Sales
GROUP BY Gender
ORDER BY gender_count DESC;

-- 6. What is the gender distribution per branch?
SELECT
    Gender, Branch,
    COUNT(*) AS gender_count 
FROM WalmartSalesData.dbo.Sales
WHERE Branch ='C'         -- Branch = 'A'
GROUP BY Gender, Branch
ORDER BY gender_count DESC;

-- 7. Which time of the day do customers give most ratings?
SELECT
    time_of_day, 
    AVG(Rating) as AVG_Rating 
FROM WalmartSalesData.dbo.Sales
GROUP BY time_of_day
ORDER BY AVG_Rating DESC;

-- 8. Which time of the day do customers give most ratings per branch?
SELECT
    time_of_day, Branch,
    AVG(Rating) as AVG_Rating 
FROM WalmartSalesData.dbo.Sales
WHERE Branch = 'C'
GROUP BY time_of_day, Branch
ORDER BY AVG_Rating DESC;


-- 9. Which day of the week has the best avg ratings?
SELECT
    day_name,
    AVG(Rating) as AVG_Rating 
FROM WalmartSalesData.dbo.Sales
GROUP BY day_name
ORDER BY AVG_Rating DESC;

-- 10. Which day of the week has the best average ratings per branch?
SELECT
    day_name, Branch,
    AVG(Rating) as AVG_Rating 
FROM WalmartSalesData.dbo.Sales
GROUP BY day_name, Branch
ORDER BY AVG_Rating DESC;
