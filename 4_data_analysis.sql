-- Short DATA ANALYSIS.


-- Looking at the average salary_annual throughout the whole dataset.
SELECT ROUND(AVG(salary_annual))
FROM salary_survey_us;


-- Which industry pays the most?
-- IT and Tech
-- The averages calculated here are often higher than the average salaries found online.
-- The reason for this might be that there are many people in relatively high positions
-- throughout the dataset.
SELECT
    industry,
    ROUND(AVG(salary_annual))
FROM salary_survey_us
    WHERE industry IS NOT NULL
GROUP BY industry
ORDER BY ROUND(AVG(salary_annual)) DESC;


-- ------------------------------------------------------------------
-- ADDITIONAL COMPENSATION

-- Overview
-- The results show that the higher amounts of additional compensation are spread out througout
-- the whole range of salaries, with a slight tendency of clustering in the upper range.
SELECT
    salary_annual,
    additional_compensation,
    ROUND(additional_compensation / salary_annual *100) AS additional_compensation_percent
FROM salary_survey_us
    WHERE additional_compensation IS NOT NULL
ORDER BY salary_annual DESC;


-- Average additional_compensation as percentage of the salary_annual
-- 13 percent
SELECT
    ROUND(AVG(additional_compensation / salary_annual *100)) AS avg_additional_compensation_percent
FROM salary_survey_us;


-- Average additional_compensation as percentage of the salary_annual per industry/sector
-- The highest is paid in the sales industry, followed by IT and tech and the energy sector.
-- Note: the last column I am calculating here holds the factor showing how much higher
-- the average additional_compensation of a given industry is compared to the overall average (13).
-- The average additional_compensation in sales is therefore 2.06 times higher than the average
-- throughout all the industries.
SELECT
    industry,
    ROUND(AVG(salary_annual)) AS avg_salary_annual,
    ROUND(AVG(additional_compensation)) AS avg_additional_compensation,
    ROUND(AVG(additional_compensation / salary_annual *100)) AS avg_additional_compensation_percent,
    ROUND(AVG(additional_compensation / salary_annual *100) / 13, 2) AS factor_vs_overall
FROM salary_survey_us
    WHERE additional_compensation IS NOT NULL
    AND industry IS NOT NULL
GROUP BY industry
ORDER BY avg_additional_compensation_percent DESC;


-- ------------------------------------------------------------------
-- EXPERIENCE 

-- Correlation: salary_annual vs. experience_in_field per industry/sector
-- Generally, salaries do increase with years of experience, as one would expect.
-- However, in this dataset, the two classes with the most experience are often paid
-- less than the classes before, sometimes the highest class is the least paid of all.
SELECT
    industry,
    experience_in_field, 
    ROUND(AVG(salary_annual))
FROM salary_survey_us
    WHERE industry IS NOT NULL
GROUP BY industry, experience_in_field
ORDER BY industry, cast(experience_in_field AS UNSIGNED);


-- Counting the entries per experience_in_field class.
-- The reason for the above could be that there are far less people who have that much
-- experience in their field, so they are underrepresented. For the highest experience
-- class, there are only 22 entries.
SELECT 
    experience_in_field,
    COUNT(*) AS 'count'
FROM salary_survey_us
GROUP BY experience_in_field
ORDER BY cast(experience_in_field AS UNSIGNED);


-- Correlation: salary_annual vs. experience_in_field, independent of industry/sector.
-- This confirms the general tendency noticed above.
SELECT 
    experience_in_field,
    ROUND(AVG(salary_annual))
FROM salary_survey_us
GROUP BY experience_in_field
ORDER BY cast(experience_in_field AS UNSIGNED);


-- This pattern is the same given the experience_overall instead.
SELECT
    industry,
    experience_overall,
    ROUND(AVG(salary_annual))
FROM salary_survey_us
    WHERE industry IS NOT NULL
GROUP BY industry, experience_overall
ORDER BY industry, cast(experience_overall AS UNSIGNED);


-- Counting entries for each experience_overall class.
SELECT 
    experience_overall,
    COUNT(*) AS 'count'
FROM salary_survey_us
GROUP BY experience_overall
ORDER BY cast(experience_overall AS UNSIGNED);


-- Correlation: salary_annual vs. experience_overall,
-- independently of industry/sector
SELECT 
    experience_overall,
    ROUND(AVG(salary_annual))
FROM salary_survey_us
GROUP BY experience_overall
ORDER BY cast(experience_overall AS UNSIGNED);


-- Sweet Spot experience_in_field vs. experience_overall. How much of a person's experience should
-- be in a given field to reach a higher salary?

-- Creating a new column, which holds the proportion of
-- experience_in_field vs. experience_overall.
ALTER TABLE salary_survey_us
    ADD COLUMN experience_proportion INT
    AFTER experience_in_field;

-- I use the numbers before the hyphens in each experience category for the calculation.
-- This is the only possibility, since there are no exact years in the survey.
-- Note: The column is of the type VARCHAR, so I need to cast these numbers as integers.
-- I cannot divide by 0, so 0-1 years must result in 1 insted of 0 being used
-- for the calculation.
UPDATE salary_survey_us
    SET experience_proportion =
        CASE
            WHEN experience_in_field = '0-1 years' THEN '1'
            ELSE ROUND(cast(SUBSTRING(experience_in_field, 1, LOCATE('-', experience_in_field) -1) AS UNSIGNED) /
                 cast(SUBSTRING(experience_overall, 1, LOCATE('-', experience_overall) -1) AS UNSIGNED) * 100)
        END;


-- Correlation: experience_proportion vs. salary_annual.
-- The highest average salary is reached at 68 percent. Therefore, 68 percent of the experience_overall
-- should be in the respective field in order to reach the highest average annual salary.
-- NOTE: This calculation is not perfect, since the two experience columns hold no exact years.
SELECT
    experience_proportion,
    ROUND(AVG(salary_annual))
FROM salary_survey_us
    WHERE industry IS NOT NULL
GROUP BY experience_proportion
ORDER BY ROUND(AVG(salary_annual)) DESC;


-- Looking at this per industry/sector shows that this point can vary greatly.
-- The conclusion is that the above 68 percent are not a proper guide.
-- There is of course the rather obvious tendency of increasing salaries with
-- higher percentages of experience_in_field.
SELECT
    industry,
    experience_proportion,
    ROUND(AVG(salary_annual))
FROM salary_survey_us
    WHERE industry IS NOT NULL
GROUP BY industry, experience_proportion
ORDER BY industry, ROUND(AVG(salary_annual)) DESC;


-- ------------------------------------------------------------------
-- EDUCATION

-- Correlation: salary_annual vs. education.
-- A professional degree correlates most with high salaries, followed by a PhD.
SELECT 
    education,
    ROUND(AVG(salary_annual))
FROM salary_survey_us
    WHERE education IS NOT NULL
GROUP BY education
ORDER BY ROUND(AVG(salary_annual)) DESC;


-- Correlation: salary_annual vs. education per industry/sector
SELECT
    industry,
    education,
    ROUND(AVG(salary_annual))
FROM salary_survey_us
    WHERE industry IS NOT NULL
    AND education IS NOT NULL
GROUP BY industry, education
ORDER BY industry, ROUND(AVG(salary_annual)) DESC;


-- ------------------------------------------------------------------
-- GENDER

-- Correlation: salary_annual vs. gender.
-- Men are paid most on average.
SELECT 
    gender,
    ROUND(AVG(salary_annual))
FROM salary_survey_us
GROUP BY gender
ORDER BY ROUND(AVG(salary_annual)) DESC;


-- Correlation: salary_annual vs. gender per industry/sector.
-- The pattern is mostly the same.
SELECT
    industry,
    gender,
    ROUND(AVG(salary_annual))
FROM salary_survey_us
    WHERE industry IS NOT NULL
GROUP BY industry, gender
ORDER BY industry, ROUND(AVG(salary_annual)) DESC;


-- ------------------------------------------------------------------
-- RACE

-- Correlation: salary_annual vs. race_simplified.
-- This survey actually shows a different outcome than many publications found online.
SELECT 
    race_simplified,
    ROUND(AVG(salary_annual))
FROM salary_survey_us
GROUP BY race_simplified
ORDER BY ROUND(AVG(salary_annual)) DESC;


-- Correlation: salary_annual vs. race_simplified per industry/sector.
-- The correlation also varies a lot for the different industries.
SELECT
    industry,
    race_simplified,
    ROUND(AVG(salary_annual))
FROM salary_survey_us
    WHERE industry IS NOT NULL
GROUP BY industry, race_simplified
ORDER BY industry, ROUND(AVG(salary_annual)) DESC;


-- For confirmation, I am doing the same with the original race column.
-- Here, I look for the same race options used for the race_simplified column.
-- The pattern is the same, showing that my column does not distort the data,
-- but still provides a better overview.
SELECT 
    race,
    ROUND(AVG(salary_annual))
FROM salary_survey_us
GROUP BY race
ORDER BY ROUND(AVG(salary_annual)) DESC;