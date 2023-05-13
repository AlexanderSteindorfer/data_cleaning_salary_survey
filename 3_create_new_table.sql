-- Looking at some of the outcome of the cleaning process first.

-- 27,029 are rows left after the cleaning.
SELECT COUNT(*) FROM salary_survey;

-- 22,258 rows contain US data.
SELECT COUNT(*)
FROM salary_survey
    WHERE currency = 'USD'
    AND country = 'USA';

-- 21,723 of these are included within the industries/sectors I cleaned.
-- The 535 entries which are not included are spread over approximately 400 distinct industry 
-- options entered by people.
-- From this I conclude that the time needed to clean the rest of the industries column
-- is not worth the outcome, as no single industry would receive considerably more data
-- through this process, and so the outcome of an analysis would remain almost the same.
SELECT COUNT(*)
FROM salary_survey
    WHERE currency = 'USD'
    AND country = 'USA'
    AND industry_cleaned IN (
        'Education and Academia', 'Pharma', 'IT and Tech', 'Healthcare', 'Cultural Heritage',
        'Finance and Investment', 'Architecture', 'Aerospace and Defense', 'Retail',
        'Hospitality and Events', 'HR and Recruitment', 'Marketing', 'Construction',
        'Government and Law Enforcement', 'Art and Design', 'Business and Consulting',
        'Information Services', 'Science and Research', 'Environment', 'Energy',
        'Nonprofits', 'Engineering or Manufacturing', 'Law', 'Media and Entertainment',
        'Insurance', 'Utilities & Telecommunications', 'Transport or Logistics', 'Sales',
        'Social Work', 'Entertainment', 'Agriculture or Forestry', 'Publishing', 'Real Estate',
        'Leisure, Sport & Tourism'
    );


-- Creating a new table which will contain only USA/USD data and only the industries I cleaned.
-- I include the entries where the industry was not entered, since the data can still be used.
CREATE TABLE `salary_survey_us`
    AS SELECT * FROM salary_survey
        WHERE currency = 'USD'
        AND country = 'USA'
        AND (industry_cleaned IN (
        'Education and Academia', 'Pharma', 'IT and Tech', 'Healthcare', 'Cultural Heritage',
        'Finance and Investment', 'Architecture', 'Aerospace and Defense', 'Retail',
        'Hospitality and Events', 'HR and Recruitment', 'Marketing', 'Construction',
        'Government and Law Enforcement', 'Art and Design', 'Business and Consulting',
        'Information Services', 'Science and Research', 'Environment', 'Energy',
        'Nonprofits', 'Engineering or Manufacturing', 'Law', 'Media and Entertainment',
        'Insurance', 'Utilities & Telecommunications', 'Transport or Logistics', 'Sales',
        'Social Work', 'Entertainment', 'Agriculture or Forestry', 'Publishing', 'Real Estate',
        'Leisure, Sport & Tourism'
        )  
        OR industry_cleaned IS NULL
        );


-- Removing the original industry column, renaming the new one.
ALTER TABLE salary_survey_us
    DROP COLUMN industry,
    CHANGE industry_cleaned industry VARCHAR(255);


-- The new table holds 21,809 rows, which is about 98% of the US data.
SELECT COUNT(*) FROM salary_survey_us;