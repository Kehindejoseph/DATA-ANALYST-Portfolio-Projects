CREATE DATABASE Race

--SELECT Top 10*
--FROM Race.dbo.ultracleanedupdata_output

SELECT *
FROM Race.dbo.ultracleanedupdata_output

--How many States were represented in the race?
SELECT DISTINCT State, COUNT(*) AS State_Rep
FROM Race.dbo.ultracleanedupdata_output
GROUP BY State

-- What was the Average time of Men Vs Women?
SELECT Gender,
    AVG(1.00 * Total_Minutes) AS AVG_Time,
    COUNT(*) as Total_Number
FROM Race.dbo.ultracleanedupdata_output
GROUP BY Gender

-- What were the youngest and oldest ages in the race?
  -- By Gender
SELECT Gender, MIN(Age) AS youngest_age, 
       MAX(Age) as oldest_age 
FROM Race.dbo.ultracleanedupdata_output
GROUP BY Gender

    -- By fullName 
SELECT 
    (SELECT fullName 
     FROM Race.dbo.ultracleanedupdata_output 
     WHERE Age = (SELECT MIN(Age) FROM Race.dbo.ultracleanedupdata_output)) AS youngest_fullname,
    (SELECT Age 
     FROM Race.dbo.ultracleanedupdata_output 
     WHERE Age = (SELECT MIN(Age) FROM Race.dbo.ultracleanedupdata_output)) AS youngest_age,
    (SELECT fullName 
     FROM Race.dbo.ultracleanedupdata_output 
     WHERE Age = (SELECT MAX(Age) FROM Race.dbo.ultracleanedupdata_output)) AS oldest_fullname,
    (SELECT Age 
     FROM Race.dbo.ultracleanedupdata_output 
     WHERE Age = (SELECT MAX(Age) FROM Race.dbo.ultracleanedupdata_output)) AS oldest_age

-- What is the average time for each age group
WITH age_brackets AS (
    SELECT 
        total_minutes,
    CASE 
        WHEN age < 30 then 'age_20-29'
        WHEN age < 40 then 'age_30-39'
        WHEN age < 50 then 'age_40-49'
        WHEN age < 60 then 'age_50-59'
    ELSE
        'age_60+' end as age_group
FROM Race.dbo.ultracleanedupdata_output 
)

SELECT age_group, AVG(total_minutes) AS AVG_race_time
FROM age_brackets
GROUP BY age_group


-- Top 3 Males and Females?
WITH gender_rank as (
    SELECT RANK() OVER (PARTITION BY Gender ORDER BY total_minutes ASC) AS gender_rank,
    fullName,
    Gender,
    total_minutes
    FROM Race.dbo.ultracleanedupdata_output 
)

SELECT *
FROM gender_rank
where gender_rank < 4
ORDER BY total_minutes


SELECT *
FROM Race.dbo.ultracleanedupdata_output
