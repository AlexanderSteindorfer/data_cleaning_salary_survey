-- Creating a new table which will contain only USA/USD data and only
-- those industries I cleaned.
-- I include the entries where the industry was not entered, since the data can still be used.
CREATE TABLE `salary_survey_us`
    AS SELECT * FROM salary_survey
        WHERE currency = 'USD'
        AND country = 'USA'
        AND (industry_cleaned IN (
            'Education and Academia', 'Pharma', 'IT and Tech', 'Healthcare',
            'Finance and Investment', 'Architecture', 'Aerospace and Defense', 'Tourism and Events',
            'HR and Recruitment', 'Marketing', 'Construction', 'Government and Law Enforcement',
            'Arts and Museums', 'Business and Consulting', 'Information Services', 'Science and Research',
            'Environment', 'Energy', 'Nonprofits', 'Engineering or Manufacturing', 'Law', 'Media & Digital',
            'Insurance', 'Utilities & Telecommunications', 'Transport or Logistics', 'Sales', 'Social Work',
            'Entertainment', 'Agriculture or Forestry', 'Publishing', 'Real Estate'
        )   OR industry_cleaned IS NULL);


-- Removing the original industry column, renaming the new one.
ALTER TABLE salary_survey_us
    DROP COLUMN industry,
    CHANGE industry_cleaned industry VARCHAR(255);