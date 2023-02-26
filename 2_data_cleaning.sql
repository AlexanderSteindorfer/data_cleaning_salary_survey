-- Data Cleaning
-- Note: In this project, I will be focusing on US data exclusively.

-- ------------------------------------------------------------------------------------------
-- COLUMN: industry
-- Note: Not all of these are "industries" in the strict sense of the term.
-- It is often difficult to decide where an entry belongs and industries often overlap.
-- There is therefore often a subjective element to it.
-- I use SELECT statements to filter some results and decide how to clean them before
-- I do the actual updating.


-- We got 1092 distinct entries here, which is not suitable for an analysis.
SELECT COUNT(DISTINCT(industry))
FROM salary_survey;


SELECT DISTINCT(industry)
FROM salary_survey;


-- Removing white spaces, which happens to decrease the number of distinct entries as well.
UPDATE salary_survey
    SET industry = TRIM(industry);


-- Copying the column to clean and simplify it without losing the original information.
ALTER TABLE salary_survey
    ADD COLUMN industry_cleaned VARCHAR(255)
        AFTER industry;

UPDATE salary_survey
    SET industry_cleaned = industry;


-- Standardising education and academia.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE (industry_cleaned LIKE '%education%'
    OR industry_cleaned LIKE '%academ%')
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
    SET industry_cleaned = 'Education and Academia'
        WHERE (industry_cleaned LIKE '%education%'
        OR industry_cleaned LIKE '%academ%'
        OR industry_cleaned IN ('Ed Tech', 'Edtech', 'Educ tech', 'publishing/edtech'))
        AND industry_cleaned NOT IN (
            'Beauty Manufacturing & Education',
            'Childcare (0-5 so does not come under Primary education)',
            'Public health in higher education', 'Music: freelance, performing and education',
            'Academic Medicine', 'Life sciences (not in academia)', 'Science/research non-academic',
            'social science research - not quite academia, not quite nonprofit, not quite consulting'
        );


-- Standardising the pharma industry.
-- Note: I am going to include the Biotechnology sector here, because most of it is connected to the
-- pharma industry. However, I will filter out those that are clearly not.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE (industry_cleaned LIKE '%pharma%'
    OR industry_cleaned LIKE '%bio%')
    AND industry_cleaned NOT LIKE '%biol%'
    AND industry_cleaned NOT LIKE '%life science%'
    AND industry_cleaned NOT LIKE '%language services%'
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
    SET industry_cleaned = 'Pharma'
        WHERE (industry_cleaned LIKE '%pharma%'
        OR industry_cleaned LIKE '%bio%'
        OR industry_cleaned LIKE '%Bitech%')
        AND industry_cleaned NOT LIKE '%biol%'
        AND industry_cleaned NOT LIKE '%language services%'
        AND industry_cleaned NOT LIKE '%life science%'
        AND industry_cleaned NOT IN (
            'Bioinformatics', 'Biotech/software', 'Bioscience Company', 'Biotech/Food Safety'
        );


-- Standardising the IT and tech industry.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE (industry_cleaned LIKE '%tech%'
    OR industry_cleaned LIKE '%comput%'
    OR industry_cleaned LIKE '%IT'
    OR industry_cleaned LIKE 'IT%'
    OR industry_cleaned LIKE '%information technology%'
    OR industry_cleaned LIKE '%software%'
    OR industry_cleaned LIKE '%data analy%')
    AND industry_cleaned NOT LIKE '%marketing%'
    AND industry_cleaned NOT LIKE '%life science%'
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
    SET industry_cleaned = 'IT and Tech'
        WHERE (industry_cleaned LIKE '%tech%'
        OR industry_cleaned LIKE '%comput%'
        OR industry_cleaned LIKE '%IT'
        OR industry_cleaned LIKE 'IT%'
        OR industry_cleaned LIKE '%information technology%'
        OR industry_cleaned LIKE '%software%'
        OR industry_cleaned LIKE '%data analy%'
        OR industry_cleaned = 'Bioinformatics')
        AND industry_cleaned NOT LIKE '%marketing%'
        AND industry_cleaned NOT LIKE '%life science%'
        AND industry_cleaned NOT IN (
            'Biotech/Food Safety', 'Public Library (technically City Govt.?)', 'Museum - Nonprofit',
            'Museums: Nonprofit', 'Career & Technical Training', 'Cancer research, not for profit',
            'Ecommerce - Technology', 'Automotive technician', 'Library Tech for a school system',
            'Medical Technology', 'Healthcare technology', 'Technical writing'
        );


-- Standardising the healthcare industry.
-- Note: I include veterinary personnel in this.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE (industry_cleaned LIKE '%health%'
    OR industry_cleaned LIKE '%med%'
    OR industry_cleaned LIKE '%doct%'
    OR industry_cleaned LIKE '%surg%'
    OR industry_cleaned LIKE '%psych%'
    OR industry_cleaned LIKE '%mental%'
    OR industry_cleaned LIKE '%veterin%')
    AND industry_cleaned NOT LIKE '%environment%'
    AND industry_cleaned NOT LIKE '%research%'
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
    SET industry_cleaned = 'Healthcare'
        WHERE (industry_cleaned LIKE '%health%'
        OR industry_cleaned LIKE '%med%'
        OR industry_cleaned LIKE '%doct%'
        OR industry_cleaned LIKE '%surg%'
        OR industry_cleaned LIKE '%psych%'
        OR industry_cleaned LIKE '%mental%'
        OR industry_cleaned LIKE '%veterin%')
        AND industry_cleaned NOT LIKE '%environment%'
        AND industry_cleaned NOT LIKE '%research%'
        AND industry_cleaned NOT IN (
            'Enviromental', 'Funding Intermediary', 'Health and fitness', 'Health and Safety',
            'Health Insurance', 'Intergovernmental organization', 'MedComms', 'Medical Sciences',
            'Media & Digital', 'Medical communications', 'Medical Interpreter -(Spanish)',
            'Medical/Pharmaceutical', 'Third sector/non profit - medical membership in UK'
        );


-- Standardising the finance and investment industry.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE (industry_cleaned LIKE '%financ%'
    OR industry_cleaned LIKE '%bank%'
    OR industry_cleaned LIKE '%account%'
    OR industry_cleaned LIKE '%invest%'
    OR industry_cleaned LIKE '%stock%')
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
    SET industry_cleaned = 'Finance and Investment'
        WHERE (industry_cleaned LIKE '%financ%'
        OR industry_cleaned LIKE '%bank%'
        OR industry_cleaned LIKE '%account%'
        OR industry_cleaned LIKE '%invest%')
        AND industry_cleaned NOT IN (
            'Corporate accounting in death care (funeral & cemetery)',
            'I work in the finance function of a large global conglomerate',
            'Private investigator at large firm'
        );


-- Standardising the architecture industry.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE industry_cleaned LIKE '%architect%'
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
    SET industry_cleaned = 'Architecture'
        WHERE industry_cleaned LIKE '%architect%';


-- Standardising the aerospace and defense industry.
-- Note: aerospace and defense are closely connected.
-- This does not include the military, which belongs to the government.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE (industry_cleaned LIKE '%aero%'
    OR industry_cleaned LIKE '%defense%')
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
    SET industry_cleaned = 'Aerospace and Defense'
        WHERE (industry_cleaned LIKE '%aero%'
        OR industry_cleaned LIKE '%defense%');


-- Standardising the tourism and events industry.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE (industry_cleaned LIKE '%hotel%'
    OR industry_cleaned LIKE '%tourism%'
    OR industry_cleaned LIKE '%event%')
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
    SET industry_cleaned = 'Tourism and Events'
        WHERE (industry_cleaned LIKE '%hotel%'
        OR industry_cleaned LIKE '%tourism%'
        OR industry_cleaned LIKE '%event%')
        AND industry_cleaned NOT IN ('Graduate assistant and also events');


-- Standardising the HR and recruitment industry.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE (industry_cleaned LIKE '%HR%'
    OR industry_cleaned LIKE '%human res%'
    OR industry_cleaned LIKE '%recruit%'
    OR industry_cleaned LIKE '%hiring%')
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
    SET industry_cleaned = 'HR and Recruitment'
        WHERE (industry_cleaned LIKE '%HR%'
        OR industry_cleaned LIKE '%human res%'
        OR industry_cleaned LIKE '%recruit%'
        OR industry_cleaned LIKE '%hiring%')
        AND industry_cleaned NOT IN ('Philanthropy', 'HRO');


-- Standardising the marketing industry.
-- Note: from my research I conclude that medical communications is part of marketing.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE (industry_cleaned LIKE '%marketing%'
    OR industry_cleaned LIKE '%MedComms%'
    OR industry_cleaned LIKE '%Medical communications%')
    AND industry_cleaned NOT LIKE 'University tech%'
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
    SET industry_cleaned = 'Marketing'
        WHERE (industry_cleaned LIKE '%marketing%'
        OR industry_cleaned LIKE '%MedComms%'
        OR industry_cleaned LIKE '%Medical communications%'
        OR industry_cleaned = 'Market research')
        AND industry_cleaned NOT LIKE 'University tech%';


-- Standardising the construction industry.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE industry_cleaned LIKE '%construction%'
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
    SET industry_cleaned = 'Construction'
        WHERE industry_cleaned LIKE '%construction%';


-- Standardising government and law enforcement
-- I merge government and public administration with political positions,
-- law enforcement and military, and even government contracting.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE (industry_cleaned LIKE '%government%'
    OR industry_cleaned LIKE '%politic%'
    OR industry_cleaned LIKE '%police%'
    OR industry_cleaned LIKE '%enforcement%'
    OR industry_cleaned LIKE '%military%')
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
    SET industry_cleaned = 'Government and Law Enforcement'
        WHERE (industry_cleaned LIKE '%government%'
        OR industry_cleaned LIKE '%politic%'
        OR industry_cleaned LIKE '%enforcement%'
        OR industry_cleaned LIKE '%military%')
        AND industry_cleaned NOT LIKE '%public library%';


-- Standardising arts and museums.
-- Note: museums are also closely connected to tourism, events
-- and the entertainment industry as well.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE (industry_cleaned LIKE '%museum%'
    OR industry_cleaned LIKE '%art%')
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
    SET industry_cleaned = 'Arts and Museums'
        WHERE (industry_cleaned LIKE '%museum%'
        OR industry_cleaned LIKE '%art%')
        AND industry_cleaned NOT IN ('Earth sciences', 'Nonprofit - legal department');


-- Standardising business and consulting
-- Note: I will not include those that say consulting without reference to business.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE (industry_cleaned LIKE '%business%'
    OR industry_cleaned LIKE '%consulting%')
    AND industry_cleaned NOT LIKE '%environment%'
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
    SET industry_cleaned = 'Business and Consulting'
        WHERE (industry_cleaned LIKE '%business%'
        OR industry_cleaned IN (
            'Consulting / Professional Services', 'Consulting Operations- Big 4'
        ));


-- Standardising Engineering or Manufacturing.
-- Note: I am just merging two options together.
UPDATE salary_survey
    SET industry_cleaned = 'Engineering or Manufacturing'
        WHERE industry_cleaned = 'Manufacturing';


-- Standardising the information services industry.
-- These are mostly libraries and archives within this dataset.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE (industry_cleaned LIKE '%librar%'
    OR industry_cleaned LIKE '%archiv%'
    OR industry_cleaned LIKE '%information%')
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
    SET industry_cleaned = 'Information Services'
        WHERE (industry_cleaned LIKE '%librar%'
        OR industry_cleaned LIKE '%archiv%'
        OR industry_cleaned LIKE '%information%')
        AND industry_cleaned NOT IN ('Information', 'Information sciences');


-- The following shows that most librarians still don't fall into the category
-- created above. This is fine in my opinion, since a person in a certain function
-- can work for different industries.
-- But the takeaway is that the outcome can depend on the person cleaning the data.
SELECT 
    industry_cleaned,
    job_title
FROM salary_survey
    WHERE job_title LIKE '%librar%';


-- Standardising the publishing industry.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE industry_cleaned LIKE '%publish%'
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
    SET industry_cleaned = 'Publishing'
        WHERE industry_cleaned LIKE '%publish%'
        AND industry_cleaned NOT IN (
            'Customer service/publishing-adjacent', 'Information sciences'
        );


-- Standardising science and research
-- Note: this is especially arbitrary, as the different sciences not only diverge greatly,
-- but are often interwoven into other industries. Many of them could also be included in academia.
-- I exclude some research and development entries, as these are often tied into business
-- rather than science. Of course there are exceptions as well.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE (industry_cleaned LIKE '%science%'
    OR industry_cleaned LIKE '%research%'
    OR industry_cleaned LIKE '%academ%')
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
    SET industry_cleaned = 'Science and Research'
        WHERE (industry_cleaned LIKE '%science%'
        OR industry_cleaned LIKE '%research%')
        AND industry_cleaned NOT IN (
            'Education and Academia', 'Commercial Real Estate Data and Analytics/Research',
            'Consumer Research', 'Contract Research', 'Contract research organisation',
            'Policy research', 'Public Opinion Research', 'not-for-profit health research consulting',
            'Research and Development, Food and Beverage', 'Research & Development',
            'Research and Evaluation', 'Specialist policy consulting/research',
            'User Experience (UX) Research', 'UX Research', 'Wealth advisor Research'
        );


-- Standardising the environment industry.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE industry_cleaned LIKE '%environment%'
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
    SET industry_cleaned = 'Environment'
        WHERE industry_cleaned LIKE '%environment%'
        AND industry_cleaned NOT IN ('Public/Environmental Health');


-- Standardising the energy industry.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE (industry_cleaned LIKE '%energy%'
    OR industry_cleaned LIKE '%oil%'
    OR industry_cleaned LIKE '%gas%')
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
    SET industry_cleaned = 'Energy'
        WHERE (industry_cleaned LIKE '%energy%'
        OR industry_cleaned LIKE '%oil%'
        OR industry_cleaned LIKE '%gas%');


-- The following queries I used continuously to check the outcome of
-- the industry cleaning process.

-- Selecting all distinct entries with their respective counts.
SELECT
    industry_cleaned,
    COUNT(*) AS 'count'
FROM salary_survey
GROUP BY industry_cleaned
ORDER BY `count`DESC;

-- Counting how many entries are part of the cleaned options.
SELECT COUNT(*)
FROM salary_survey
    WHERE industry_cleaned IN (
        'Education and Academia', 'Pharma', 'IT and Tech', 'Healthcare',
        'Finance and Investment', 'Architecture', 'Aerospace and Defense', 'Tourism and Events',
        'HR and Recruitment', 'Marketing', 'Construction', 'Government and Law Enforcement',
        'Arts and Museums', 'Business and Consulting', 'Information Services', 'Science and Research',
        'Environment', 'Energy',
        'Nonprofits', 'Engineering or Manufacturing', 'Law', 'Media & Digital', 'Insurance',
        'Utilities & Telecommunications', 'Transport or Logistics', 'Sales', 'Social Work',
        'Entertainment', 'Agriculture or Forestry', 'Publishing', 'Real Estate'
    );


-- ------------------------------------------------------------------------------------------
-- COLUMN: country


-- Looking at the different countries entered.
SELECT DISTINCT(country)
FROM salary_survey
ORDER BY country ASC;


-- Removing both leading and trailing spaces from the column.
UPDATE salary_survey
    SET country = TRIM(country);


-- Standardising the USA entries.
UPDATE salary_survey
    SET country = 'USA'
        WHERE country IN (
            '🇺🇸', "USA, but for foreign gov't", 'USA-- Virgin Islands',
            'USA tomorrow', 'US of A', 'Untied States', 'The US', 'The United States'
            'Unted States', 'Uniyes States', 'Uniyed states', 'Unitied States',
            'Unites States', 'Uniter Statez', 'Unitef Stated', 'Uniteed States', 
            'UnitedStates', 'United Sttes', 'United Statws', 'United Status', 'United Statues',
            'United Stattes', 'United Statss', 'United statew', 'United Statesp',
            'United States of Americas', 'United States of American', 'United States of America',
            'United States is America', 'United States', 'United Statees', 'United Stateds',
            'United States (I work from home and my clients are all over the US/Canada/PR',
            'United Stated', 'United Statea', 'United State of America', 'United State',
            'United Stares', 'United Sates of America', 'United Sates', 'United  States',
            'Unite States', 'Uniited States', 'U.SA', 'U.S>', 'U.S.A.', 'U.S.A', 'U.S.',
            'U.S', 'U. S.', 'U. S', 'Usa', 'usa'
        );


-- ------------------------------------------------------------------------------------------
-- COLUMN: salary_annual


-- Overview
SELECT * FROM salary_survey
    WHERE currency = 'USD'
    AND country = 'USA'
ORDER BY `salary_annual` DESC;


-- Removing white spaces from the job_title column, since I will often use it here.
UPDATE salary_survey
    SET job_title = TRIM(job_title);


-- The note in the original Excel sheet asks people with part-time jobs
-- to enter an annualised equivalent of their salary.
-- Looking for entries that seem to ignore this.
SELECT
    job_title,
    job_context,
    salary_annual
FROM salary_survey
    WHERE (job_title LIKE '%part-time%'
    OR job_title LIKE '%parttime%'
    OR job_title LIKE '%part time%'
    OR job_context LIKE '%part-time%'
    OR job_context LIKE '%parttime%'
    OR job_context LIKE '%part time%')
    AND currency = 'USD'
    AND country = 'USA'
ORDER BY salary_annual DESC;

-- Deleting affected rows.
-- Note: the amount at the bottom of the query is a guess.
DELETE FROM salary_survey
    WHERE (job_title LIKE '%part-time%'
    OR job_title LIKE '%parttime%'
    OR job_title LIKE '%part time%'
    OR job_context LIKE '%part-time%'
    OR job_context LIKE '%parttime%'
    OR job_context LIKE '%part time%')
    AND currency = 'USD'
    AND country = 'USA'
    AND salary_annual < 25000;


-- Removing salaries of 500k or more, because most of these seem highly unrealistic,
-- or I am simply not sure about them.
DELETE FROM salary_survey
    WHERE salary_annual > 499000
    AND currency = 'USD'
    AND country = 'USA';


-- Removing rows based on the job_title and salary_annual.
-- These seem unrealistic as well, so I prefer to remove them from a data set which I would
-- use for an analysis.
DELETE FROM salary_survey
    WHERE salary_annual > 299000
    AND currency = 'USD'
    AND country = 'USA'
    AND job_title IN (
        'Desktop Supporg', 'High School Math Teacher', 'Professor',
        'Senior Software Engineer', 'Assistant Underwriter', 'Brand Consultant',
        'Operations', 'Software Engineer', 'Ceramic Artist', 'Associate',
        'Associate (Attorney)', 'People Consultant', 'Customer Support Coordinator',
        'Programmer', 'UX Manager', 'Principal Software Development Engineer',
        'Computer scientist', 'Research Analyst', 'Senior product manager'
    );


-- I saw before that there are many very well paid librarians in this data set.
-- However, they are either not deviating extremely from the average salary, or
-- the job_title and/or job_context provides an explanation.
SELECT * FROM salary_survey
    WHERE salary_annual > 90000
    AND job_title LIKE '%librarian%'
    AND currency = 'USD'
    AND country = 'USA'
ORDER BY salary_annual DESC;


-- Looking at the salary_annual in ascending order
SELECT
    `age`,
    industry,
    job_title,
    job_context,
    salary_annual,
    additional_compensation
FROM salary_survey
    WHERE currency = 'USD'
    AND country = 'USA'
ORDER BY salary_annual ASC;


-- Deleting all rows with salary_annual below 20,000, since they seem either unrealistic,
-- or mistakingly entered as part-time salary.
DELETE FROM salary_survey
    WHERE salary_annual < 20000
    AND currency = 'USD'
    AND country = 'USA';


-- Removing more rows below 30,000, either because their job title seems incomplete/wrong,
-- or because the salary seems unrealistic.
DELETE FROM salary_survey
    WHERE salary_annual < 30000
    AND currency = 'USD'
    AND country = 'USA'
    AND job_title IN (
        'PhD student', 'Graduate Student TA', 'Certified Pharmacy technician',
        'Key Holder', 'Ta', 'Data Analyst', 'Financial Aid Specialist', 'Graduate Student',
        'Sales Manager', 'Pharmacy clerk', 'Doctoral Candidate', 'Insurance Agent',
        'Director of admissions', 'Scientific aid', 'Logistics Specialist', 'Doctoral Researcher',
        'Accounts Payable/Accounts Receivable', 'Accounts payable'
    );


-- Looking at the salary_annual based on the industry_cleaned column.
-- This provides a better overview for comparison within industries.
-- Note: I don't save separate queries here, but just exchange the industry title. 
SELECT 
    job_title,
    job_context,
    experience_in_field,
    salary_annual
FROM salary_survey
    WHERE currency = 'USD'
    AND country = 'USA'
    AND industry_cleaned = 'Real Estate'
ORDER BY `salary_annual` DESC;

-- And based on this I will delete more.
DELETE FROM salary_survey
    WHERE salary_annual > 250000
    AND currency = 'USD'
    AND country = 'USA'
    AND job_title IN (
        'ML/AI Scientist', 'Lead analyst', 'Security Engineer', 'Senior Software Engineer',
        'Web Developer', 'National Sales Coordinator', 'Inpatient LCSW'
    );


-- ------------------------------------------------------------------------------------------
-- COLUMN: additional_compensation


-- Overview
SELECT
    `age`,
    industry,
    job_title,
    job_context,
    salary_annual,
    additional_compensation
FROM salary_survey
    WHERE currency = 'USD'
    AND country = 'USA'
    AND additional_compensation IS NOT NULL
ORDER BY additional_compensation DESC;


-- There are both NULL and 0 entries in the column.
-- I will replace all instances of 0 with NULL to have no entry in case of no
-- additional compensation.
SELECT NULLIF(additional_compensation, 0)
FROM salary_survey;

UPDATE salary_survey
    SET additional_compensation = NULLIF(additional_compensation, 0);


-- Looking at rows where the additional_compensation is higher than the base salary.
SELECT
    `age`,
    industry,
    job_title,
    job_context,
    salary_annual,
    additional_compensation
FROM salary_survey
    WHERE currency = 'USD'
    AND country = 'USA'
    AND additional_compensation > salary_annual 
ORDER BY additional_compensation DESC;


-- Deleting rows where the additional_compensation exceeds the salary_annual,
-- as the resulsts appear highly unrealistic.
DELETE FROM salary_survey
    WHERE additional_compensation > salary_annual
    AND currency = 'USD'
    AND country = 'USA';


-- Looking at the smallest additional compensations. No need for action here.
SELECT additional_compensation
FROM salary_survey
    WHERE currency = 'USD'
    AND country = 'USA'
    AND additional_compensation IS NOT NULL
ORDER BY additional_compensation ASC;


-- ------------------------------------------------------------------------------------------
-- COLUMNS: experience_overall / experience_in_field


SELECT DISTINCT(experience_overall)
FROM salary_survey;


-- Making the classes consistent and easier to use for an analysis.
UPDATE salary_survey
    SET experience_overall =
        CASE
            WHEN experience_overall = '1 year or less' THEN '0-1 years'
            WHEN experience_overall = '2 - 4 years' THEN '2-4 years'
            WHEN experience_overall = '5-7 years' THEN '5-7 years'
            WHEN experience_overall = '8 - 10 years' THEN '8-10 years'
            WHEN experience_overall = '11 - 20 years' THEN '11-20 years'
            WHEN experience_overall = '21 - 30 years' THEN '21-30 years'
            WHEN experience_overall = '31 - 40 years' THEN '31-40 years'
            WHEN experience_overall = '41 years or more' THEN '41- years'
            ELSE experience_overall
        END;


SELECT DISTINCT(experience_in_field)
FROM salary_survey;

UPDATE salary_survey
    SET experience_in_field =
        CASE
            WHEN experience_in_field = '1 year or less' THEN '0-1 years'
            WHEN experience_in_field = '2 - 4 years' THEN '2-4 years'
            WHEN experience_in_field = '5-7 years' THEN '5-7 years'
            WHEN experience_in_field = '8 - 10 years' THEN '8-10 years'
            WHEN experience_in_field = '11 - 20 years' THEN '11-20 years'
            WHEN experience_in_field = '21 - 30 years' THEN '21-30 years'
            WHEN experience_in_field = '31 - 40 years' THEN '31-40 years'
            WHEN experience_in_field = '41 years or more' THEN '41- years'
            ELSE experience_in_field
        END;


-- Looking for entries where the experience_in_field is higher than the experience_overall,
-- which is not possible.
SELECT
    experience_overall,
    experience_in_field
FROM salary_survey
    WHERE cast(experience_in_field AS UNSIGNED) > cast(experience_overall AS UNSIGNED);

-- Deleting these.
-- Note: for this I renamed the experience class "41 years or more" to "41- years".
-- Otherwise the SUBSTRING function would not work here and while the above SELECT query
-- works completely fine, it is not possible to DELETE in the same way.
-- So here I am using SUBSTRING to select only the first number in the string, which I then
-- cast into an integer to use it for a comparison in the WHERE clause of my DELETE statement.
DELETE FROM salary_survey
    WHERE cast(SUBSTRING(experience_in_field, 1, LOCATE('-', experience_in_field) -1) AS UNSIGNED) 
            > cast(SUBSTRING(experience_overall, 1, LOCATE('-', experience_overall) -1) AS UNSIGNED);


-- ------------------------------------------------------------------------------------------
-- COLUMN: gender


SELECT DISTINCT(gender)
FROM salary_survey;


-- Making the column consistent.
-- There is no need for two options which include "prefer not to answer".
-- Also, I will take NULL as "prefer not to answer", as an answer was not given.
UPDATE salary_survey
    SET gender = 'Other or prefer not to answer'
        WHERE (gender = 'Prefer not to answer'
        OR gender IS NULL);


-- ------------------------------------------------------------------------------------------
-- COLUMN: race


-- Overview
SELECT DISTINCT(race)
FROM salary_survey
ORDER BY race ASC;


-- Shortening the alternative option.
-- Again, I will take NULL as "prefer not to answer"
UPDATE salary_survey
    SET race = 'Other or prefer not to answer'
        WHERE (race = 'Another option not listed here or prefer not to answer'
        OR race IS NULL);


-- As it is, it is difficult to use this column for any analysis.
-- I therefore create another one, which will contain simplified information.
-- This way we gain a column that is more suitable for analysis without losing
-- insight into the particular ancestry of a person, since this info is still in
-- the original column.
ALTER TABLE salary_survey
    ADD COLUMN race_simplified VARCHAR(255);

UPDATE salary_survey
    SET race_simplified = race;


-- Merging the very diverse options together into one category for this column.
UPDATE salary_survey
    SET race_simplified = 'Multiracial'
        WHERE race NOT IN (
            'Other or prefer not to answer',
            'Asian or Asian American', 'Black or African American',
            'Hispanic, Latino, or Spanish origin', 'Middle Eastern or Northern African',
            'Native American or Alaska Native', 'White'
        );


-- Checking the outcome, which is now much more suitable for an analysis.
SELECT DISTINCT(race_simplified)
FROM salary_survey
ORDER BY race_simplified ASC;


-- ------------------------------------------------------------------------------------------

-- Looking at the overall outcome before I create a new table.

-- There are 19,962 entries from the USA.
SELECT COUNT(*)
FROM salary_survey
    WHERE currency = 'USD'
    AND country = 'USA';

-- 19,038 of these are included within the industries/sectors I cleaned.
-- This shows that the cleaning of the industry column went quite well.
SELECT COUNT(*)
FROM salary_survey
    WHERE currency = 'USD'
    AND country = 'USA'
    AND industry_cleaned IN (
        'Education and Academia', 'Pharma', 'IT and Tech', 'Healthcare',
        'Finance and Investment', 'Architecture', 'Aerospace and Defense', 'Tourism and Events',
        'HR and Recruitment', 'Marketing', 'Construction', 'Government and Law Enforcement',
        'Arts and Museums', 'Business and Consulting', 'Information Services', 'Science and Research',
        'Environment', 'Energy',
        'Nonprofits', 'Engineering or Manufacturing', 'Law', 'Media & Digital', 'Insurance',
        'Utilities & Telecommunications', 'Transport or Logistics', 'Sales', 'Social Work',
        'Entertainment', 'Agriculture or Forestry', 'Publishing', 'Real Estate'
    );

-- The 924 entries which are not included in the industries above are spread over
-- more than 500 distinct industry options entered by people. These are all very diverse.
-- From this I conclude that the input needed to clean the rest of the distinct industries
-- is not worth the outcome, as no single industry would receive considerably more data
-- through this process, and so the outcome of an analysis would remain almost the same.
SELECT COUNT(DISTINCT(industry_cleaned))
FROM salary_survey;