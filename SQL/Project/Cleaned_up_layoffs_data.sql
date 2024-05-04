CREATE DATABASE world_layoffs
Go
use world_layoffs
go

select *
from layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or blank Values
-- 4. Remove Any Column

-- Create Layoffs_staging table based on the structure of layoffs table
SELECT TOP 0 *
INTO Layoffs_staging
FROM layoffs;

select *
from Layoffs_staging;

INSERT Layoffs_staging
SELECT *
FROM layoffs

/*** I encoutered problem trying to use this method showing this (User
Started executing query at Line 26
Msg 306, Level 16, State 2, Line 2
The text, ntext, and image data types cannot be compared or sorted, except when using IS NULL or LIKE operator.) ***/
SELECT *,
    ROW_NUMBER() OVER (PARTITION BY company, industry, total_laid_off, percentage_laid_off, 'date' ) AS row_num
FROM Layoffs_staging


-- But i was able to solve it using the CAST Method

SELECT *,
    ROW_NUMBER() OVER (PARTITION BY CAST(company AS NVARCHAR(100)), CAST(industry AS NVARCHAR(100)), CAST(total_laid_off AS NVARCHAR(100)), 
    CAST(percentage_laid_off AS NVARCHAR(100)) ORDER BY date) AS row_num
FROM 
    Layoffs_staging;


--- To check for DUPLICATES using CTEs

WITH duplicate_cte AS
(
SELECT *,
    ROW_NUMBER() OVER (PARTITION BY CAST(company AS NVARCHAR(100)), location, CAST(industry AS NVARCHAR(100)), CAST(total_laid_off AS NVARCHAR(100)), 
    CAST(percentage_laid_off AS NVARCHAR(100)), stage, country, funds_raised_millions ORDER BY date) AS row_num
FROM 
    Layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1



-- checking to confirm duplicate example using the company 
SELECT *
FROM Layoffs_staging
WHERE company ='casper'

/*****************************************/
/****** STEPS TO DELETE DUPLICATE *******/
/*****************************************/

-- STEP 1
-- Create a table from duplicating the layoffs_staging but rename it as layoff_staging2

CREATE TABLE [dbo].[Layoffs_staging2](
	[company] [nvarchar](50) NOT NULL,
	[location] [nvarchar](50) NOT NULL,
	[industry] [text] NULL,
	[total_laid_off] [varchar](255) NULL,
	[percentage_laid_off] [varchar](255) NULL,
	[date] [varchar](255) NOT NULL,
	[stage] [nvarchar](50) NOT NULL,
	[country] [nvarchar](50) NOT NULL,
	[funds_raised_millions] [varchar](255) NULL,
    [row_num] [INT] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

--STEP 2
-- Run this to check if the table create

SELECT *
FROM Layoffs_staging2

--STEP 3
INSERT INTO Layoffs_staging2
SELECT *,
    ROW_NUMBER() OVER (PARTITION BY CAST(company AS NVARCHAR(100)), location, CAST(industry AS NVARCHAR(100)), CAST(total_laid_off AS NVARCHAR(100)), 
    CAST(percentage_laid_off AS NVARCHAR(100)), stage, country, funds_raised_millions ORDER BY date) AS row_num
FROM 
    Layoffs_staging

-- STEP 4
DELETE
FROM Layoffs_staging2
WHERE row_num > 1

-- STEP 5
-- Run to check 
SELECT *
FROM Layoffs_staging2
WHERE row_num > 1


SELECT*
FROM Layoffs_staging2


/*****************************************/
/****** STANDARDIZING DATA *******/
/*****************************************/

SELECT company,  TRIM(company) as 'TRIM(company)'
FROM Layoffs_staging2 


-- Trim removes the space at the front of each text in the company rows 
UPDATE Layoffs_staging2
SET company = TRIM(company) 

-- If you run this, you will notice some name showing twice. This is because you are yet to use 'Dintinct' which shows the name just once
SELECT industry
FROM Layoffs_staging2;

-- To use 'distinct here, I had to use CAST because my data in industry was imported in text'

SELECT distinct CAST(industry AS NVARCHAR(100)) industry
FROM Layoffs_staging2 
ORDER BY 1;

-- I noticed industries like crypto and crypto currency which should be the same

SELECT *
FROM Layoffs_staging2
WHERE industry LIKE 'Crypto%';


-- To update to only Crypto

UPDATE Layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

--To check for others
-- For Location
SELECT distinct CAST(location AS NVARCHAR(100)) location
FROM Layoffs_staging2 
ORDER BY 1;

-- For country (I noticed there was a country that was duplicated and has a period'.', 'United States.')
SELECT distinct CAST(country AS NVARCHAR(100)) country
FROM Layoffs_staging2 
ORDER BY 1;

-- There was a problem found(United States)
SELECT distinct CAST(country AS NVARCHAR(100)) country
FROM Layoffs_staging2 
WHERE country LIKE 'United States%'
ORDER BY 1;

-- This helps to remove the '.' in the United States
SELECT distinct(country), TRIM('.' FROM country) AS 'TRIM(Country)'
FROM Layoffs_staging2 
ORDER BY 1;

-- We can then go ahead to update the country
UPDATE layoffs_staging2
SET country = TRIM('.' FROM country)
WHERE country LIKE 'United States%'


/*****************************************/
/****** TO CHANGE THE DATE FORMAT *******/
/*****************************************/
--Going from M/D/YYYY to 

-- This code helps to convert the date

SELECT date, TRY_CONVERT(DATE, date, 101) AS converted_date
FROM Layoffs_staging2;

-- Updating the Date 
UPDATE layoffs_staging2
SET date = TRY_CONVERT(DATE, date, 101)
WHERE date IS NOT NULL;


SELECT date, TRY_CONVERT(DATE, date, 101) AS converted_date
FROM Layoffs_staging2
WHERE date = 'NULL';

UPDATE Layoffs_staging2
SET date = TRY_CONVERT(DATE, date, 101)
WHERE date = 'NULL';

SELECT date
FROM Layoffs_staging2


/*****************************************/
/****** NULL AND BLANCK VALUES *******/
/*****************************************/

SELECT *
FROM Layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


SELECT distinct CAST(industry AS NVARCHAR(100))
FROM Layoffs_staging2


SELECT *
FROM Layoffs_staging2
WHERE industry IS NULL
OR CAST(industry AS NVARCHAR(100)) = '';


SELECT *
FROM Layoffs_staging2
WHERE company = 'Airbnb';

SELECT *
FROM Layoffs_staging2
WHERE company LIKE 'Airbnb';


-- We want the data 'company' with travel in industry to be the same
SELECT t1.industry, t2.industry
FROM Layoffs_staging2 t1
JOIN Layoffs_staging2 t2
    ON t1.company = t2.company
    AND t1.location = t2.location
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Updating the industry with NULL
UPDATE t1
SET t1.industry = t2.industry
FROM Layoffs_staging2 t1
JOIN Layoffs_staging2 t2 ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

DELETE
FROM Layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM Layoffs_staging2
WHERE company = 'Airbnb'
ORDER BY 1