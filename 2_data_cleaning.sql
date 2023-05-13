-- DATA CLEANING
-- Note: Here I focus on US data exclusively, 
-- although I clean some of the columns for the whole dataset.


-- Deleting empty rows.
DELETE FROM salary_survey
    WHERE `age` IS NULL
    AND industry IS NULL
    AND job_title IS NULL
    AND job_context IS NULL
    AND salary_annual IS NULL
    AND additional_compensation IS NULL
    AND currency IS NULL
    AND currency_other IS NULL
    AND income_context IS NULL
    AND country IS NULL
    AND us_state IS NULL
    AND city IS NULL
    AND experience_overall IS NULL
    AND experience_in_field IS NULL
    AND education IS NULL
    AND gender IS NULL
    AND race IS NULL;


-- Finding and deleting duplicated rows.
-- For this purpose, I temporarily create an ID column.
ALTER TABLE salary_survey
ADD `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY;

-- Selecting all duplicated rows for an overview.
SELECT * FROM (
    SELECT
        `id`,
        `age`,
        salary_annual,
        industry,
        job_title,
        job_context,
        city,
        ROW_NUMBER() OVER (
            PARTITION BY 
                `age`,
                salary_annual,
                industry,
                job_title,
                job_context,
                city
            ORDER BY salary_annual
        ) AS row_num
    FROM salary_survey
    ) t
WHERE row_num > 1
ORDER BY row_num DESC;

-- Deleting these after checking that the results are correct.
DELETE FROM salary_survey
    WHERE `id` IN (
        SELECT `id` FROM (
            SELECT
                `id`,
                `age`,
                salary_annual,
                industry,
                job_title,
                job_context,
                city,
                ROW_NUMBER() OVER (
                    PARTITION BY 
                        `age`,
                        salary_annual,
                        industry,
                        job_title,
                        job_context,
                        city
                    ORDER BY salary_annual
                ) AS row_num
            FROM salary_survey
            ) t
        WHERE row_num > 1
    );

-- Dropping the id column, as it is no longer needed.
ALTER TABLE salary_survey
DROP COLUMN `id`;


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


-- Copying the column to clean it without losing the original information.
ALTER TABLE salary_survey
    ADD COLUMN industry_cleaned VARCHAR(255)
        AFTER industry;

UPDATE salary_survey
    SET industry_cleaned = industry;


-- Standardising Education and Academia.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE (industry_cleaned LIKE '%education%'
           OR industry_cleaned LIKE '%academ%'
           OR industry_cleaned LIKE '%universit%')
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
    SET industry_cleaned = 'Education and Academia'
        WHERE (industry_cleaned LIKE '%education%'
               OR industry_cleaned LIKE '%academ%'
               OR industry_cleaned LIKE '%universit%'
               OR industry_cleaned IN (
                'Ed Tech', 'Edtech', 'Educ tech', 'publishing/edtech',
                'School District Pre-K-12')
        )
        AND industry_cleaned NOT IN (
            'Beauty Manufacturing & Education',
            'Childcare (0-5 so does not come under Primary education)',
            'Public health in higher education', 'Music: freelance, performing and education',
            'Academic Medicine', 'Life sciences (not in academia)', 'Science/research non-academic',
            'social science research - not quite academia, not quite nonprofit, not quite consulting'
        );


-- Standardising the Pharma industry.
-- Note: I am going to include the Biotechnology sector here, because most of it is connected
-- to the pharma industry. However, I will filter out those that are clearly not.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE (industry_cleaned LIKE '%pharma%'
           OR industry_cleaned LIKE '%bio%'
    )
    AND industry_cleaned NOT LIKE '%biol%'
    AND industry_cleaned NOT LIKE '%life science%'
    AND industry_cleaned NOT LIKE '%language services%'
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
    SET industry_cleaned = 'Pharma'
        WHERE (industry_cleaned LIKE '%pharma%'
               OR industry_cleaned LIKE '%bio%'
               OR industry_cleaned LIKE '%Bitech%'
        )
        AND industry_cleaned NOT LIKE '%biol%'
        AND industry_cleaned NOT LIKE '%language services%'
        AND industry_cleaned NOT LIKE '%life science%'
        AND industry_cleaned NOT IN (
            'Bioinformatics', 'Biotech/software', 'Bioscience Company', 'Biotech/Food Safety'
        );


-- Standardising the IT and Tech industry.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE (industry_cleaned LIKE '%tech%'
           OR industry_cleaned LIKE '%comput%'
           OR industry_cleaned LIKE '%IT'
           OR industry_cleaned LIKE 'IT%'
           OR industry_cleaned LIKE '%information technology%'
           OR industry_cleaned LIKE '%software%'
           OR industry_cleaned LIKE '%data analy%'
    )
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
               OR industry_cleaned IN (
                'Bioinformatics', 'Analytics', 'Data Breach'
               )
        )
        AND industry_cleaned NOT LIKE '%marketing%'
        AND industry_cleaned NOT LIKE '%life science%'
        AND industry_cleaned NOT IN (
            'Biotech/Food Safety', 'Public Library (technically City Govt.?)',
            'Museum - Nonprofit', 'Museums: Nonprofit', 'Career & Technical Training',
            'Cancer research, not for profit', 'Ecommerce - Technology',
            'Automotive technician', 'Library Tech for a school system',
            'Medical Technology', 'Healthcare technology', 'Technical writing'
        );


-- Standardising the Healthcare industry.
-- Note: I include veterinary personnel in this.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE (industry_cleaned LIKE '%health%'
           OR industry_cleaned LIKE '%med%'
           OR industry_cleaned LIKE '%doct%'
           OR industry_cleaned LIKE '%surg%'
           OR industry_cleaned LIKE '%psych%'
           OR industry_cleaned LIKE '%mental%'
           OR industry_cleaned LIKE '%veterin%'
    )
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
               OR industry_cleaned LIKE '%veterin%'
        )
        AND industry_cleaned NOT LIKE '%environment%'
        AND industry_cleaned NOT LIKE '%research%'
        AND industry_cleaned NOT IN (
            'Enviromental', 'Funding Intermediary', 'Health and fitness', 'Health and Safety',
            'Health Insurance', 'Intergovernmental organization', 'MedComms', 'Medical Sciences',
            'Media & Digital', 'Medical communications', 'Medical Interpreter -(Spanish)',
            'Medical/Pharmaceutical', 'Third sector/non profit - medical membership in UK'
        );


-- Standardising the Finance and Investment industry.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE (industry_cleaned LIKE '%financ%'
           OR industry_cleaned LIKE '%bank%'
           OR industry_cleaned LIKE '%account%'
           OR industry_cleaned LIKE '%invest%'
           OR industry_cleaned LIKE '%stock%'
    )
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
    SET industry_cleaned = 'Finance and Investment'
        WHERE (industry_cleaned LIKE '%financ%'
               OR industry_cleaned LIKE '%bank%'
               OR industry_cleaned LIKE '%account%'
               OR industry_cleaned LIKE '%invest%'
        )
        AND industry_cleaned NOT IN (
            'Corporate accounting in death care (funeral & cemetery)',
            'I work in the finance function of a large global conglomerate',
            'Private investigator at large firm'
        );


-- Standardising the Insurance industry.
UPDATE salary_survey
    SET industry_cleaned = 'Insurance'
        WHERE industry_cleaned = 'Actuarial';


-- Standardising the Architecture industry.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE industry_cleaned LIKE '%architect%'
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
    SET industry_cleaned = 'Architecture'
        WHERE industry_cleaned LIKE '%architect%';


-- Standardising the Aerospace and Defense industry.
-- Note: aerospace and defense are closely connected.
-- This does not include the military, which belongs to the government.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE (industry_cleaned LIKE '%aero%'
           OR industry_cleaned LIKE '%defense%'
    )
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
    SET industry_cleaned = 'Aerospace and Defense'
        WHERE (industry_cleaned LIKE '%aero%'
               OR industry_cleaned LIKE '%defense%'
        );


-- Standardising the Hospitality and Events industry.
-- Note: for the food services, this includes distribution, not manufacturing.
-- "Food industry" or just "Food & Beverages" e.g. could mean either
-- production or distribution and I decide to include such cases here rather than
-- in the manufacturing industry.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE (industry_cleaned LIKE '%hotel%'
           OR industry_cleaned LIKE '%event%'
           OR industry_cleaned LIKE '%food%'
           OR industry_cleaned LIKE '%beverage%'
           OR industry_cleaned LIKE '%drink%'
           OR industry_cleaned LIKE '%restaurant%'
    )
    AND industry_cleaned NOT LIKE '%manufact%'
    AND industry_cleaned NOT LIKE '%production%'
    AND industry_cleaned NOT LIKE '%processing%'
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
    SET industry_cleaned = 'Hospitality and Events'
        WHERE (industry_cleaned LIKE '%hotel%'
               OR industry_cleaned LIKE '%event%'
               OR industry_cleaned LIKE '%food%'
               OR industry_cleaned LIKE '%beverage%'
               OR industry_cleaned LIKE '%restaurant%'
               OR industry_cleaned IN (
                'Beer sales'
               )
        )
        AND industry_cleaned NOT LIKE '%manufac%'
        AND industry_cleaned NOT LIKE '%production%'
        AND industry_cleaned NOT LIKE '%processing%'
        AND industry_cleaned NOT IN (
            'Graduate assistant and also events', 'Biotech/Food Safety',
            'Research and Development, Food and Beverage', 'Warehouse- Food and Beverage'
        );


-- Standardising Engineering or Manufacturing.
-- Note: The original survey contains this industry. It is very broad, 
-- but I use it as such, including the Food and Beverage manufacturing industry.
-- I also include research and development tied to it.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE (industry_cleaned = 'Manufacturing'
           OR industry_cleaned LIKE '%manufact%'
           OR industry_cleaned LIKE '%food%'
           OR industry_cleaned LIKE '%beverage%'
           OR industry_cleaned LIKE '%drink%'
    )
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
    SET industry_cleaned = 'Engineering or Manufacturing'
        WHERE (industry_cleaned = 'Manufacturing'
               OR industry_cleaned LIKE '%food%'
               OR industry_cleaned LIKE '%beverage%'
               OR industry_cleaned LIKE '%drink%'
               OR industry_cleaned = 'Brewing'
        );

-- Standardising the HR and Recruitment industry.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE (industry_cleaned LIKE '%HR%'
           OR industry_cleaned LIKE '%human res%'
           OR industry_cleaned LIKE '%recruit%'
           OR industry_cleaned LIKE '%hiring%'
    )
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
    SET industry_cleaned = 'HR and Recruitment'
        WHERE (industry_cleaned LIKE '%HR%'
               OR industry_cleaned LIKE '%human res%'
               OR industry_cleaned LIKE '%recruit%'
               OR industry_cleaned LIKE '%hiring%'
        )
        AND industry_cleaned NOT IN ('Philanthropy', 'HRO');


-- Standardising the Marketing industry.
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
               OR industry_cleaned IN (
                'Market research', 'Administration in MLM'
               )
        )
        AND industry_cleaned NOT LIKE 'University tech%';


-- Standardising the Construction industry.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE industry_cleaned LIKE '%construction%'
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
    SET industry_cleaned = 'Construction'
        WHERE industry_cleaned LIKE '%construction%'
        OR industry_cleaned = 'Concrete';


-- Standardising Government and Law Enforcement
-- I merge government and public administration with political positions,
-- law enforcement and military, and even government contracting.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE (industry_cleaned LIKE '%government%'
           OR industry_cleaned LIKE '%politic%'
           OR industry_cleaned LIKE '%police%'
           OR industry_cleaned LIKE '%enforcement%'
           OR industry_cleaned LIKE '%military%'
    )
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
    SET industry_cleaned = 'Government and Law Enforcement'
        WHERE (industry_cleaned LIKE '%government%'
               OR industry_cleaned LIKE '%politic%'
               OR industry_cleaned LIKE '%enforcement%'
               OR industry_cleaned LIKE '%military%'
        )
        AND industry_cleaned NOT LIKE '%public library%';


-- Standardising Cultural Heritage/Cultural Resource Management.
-- Includes museums, galleries and archeology, among others.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE (industry_cleaned LIKE '%cultural%'
           OR industry_cleaned LIKE '%archeo%'
           OR industry_cleaned LIKE '%art%'
           OR industry_cleaned LIKE '%museum%'
           OR industry_cleaned LIKE '%galler%'
    )
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
    SET industry_cleaned = 'Cultural Heritage'
        WHERE (industry_cleaned LIKE '%cultural%'
            OR industry_cleaned LIKE '%archeo%'
            OR industry_cleaned LIKE '%art%'
            OR industry_cleaned LIKE '%museum%'
            OR industry_cleaned LIKE '%galler%'
            OR industry_cleaned IN (
                'Archaeologist', 'Culture', 'Archaeology')
        )
        AND industry_cleaned NOT IN (
            'Art & Design', 'art appraisal', 'Earth sciences', 'Performing Arts',
            'Library science / part-time work/study', 'Nonprofit - legal department'
        );

-- Standardising Art and Design.
-- This industry is already part of the salary survey.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE industry_cleaned LIKE '%art%'
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
    SET industry_cleaned = 'Art and Design'
        WHERE industry_cleaned IN (
            'Art & Design', 'art appraisal', 'Performing Arts'
        );


-- Standardising the Business and Consulting industry.
-- Note: I will not include those that say consulting without reference to business.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE (industry_cleaned LIKE '%business%'
           OR industry_cleaned LIKE '%consulting%'
           OR industry_cleaned LIKE '%e comm%'
           OR industry_cleaned LIKE '%e-comm%'
           OR industry_cleaned LIKE '%EComm%'
           OR industry_cleaned LIKE '%e-comm%'
    )
    AND industry_cleaned NOT LIKE '%environment%'
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
    SET industry_cleaned = 'Business and Consulting'
        WHERE industry_cleaned LIKE '%business%'
        OR industry_cleaned LIKE '%e comm%'
        OR industry_cleaned LIKE '%e-comm%'
        OR industry_cleaned LIKE '%EComm%'
        OR industry_cleaned LIKE '%e-comm%'
        OR industry_cleaned IN (
                'Consulting / Professional Services', 'Consulting Operations- Big 4'
        )
        AND industry_cleaned != 'Utilities & Telecommunications';


-- Standardising the Information Services industry.
-- These are mostly libraries and archives within this dataset.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE (industry_cleaned LIKE '%librar%'
           OR industry_cleaned LIKE '%archiv%'
           OR industry_cleaned LIKE '%information%'
    )
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
    SET industry_cleaned = 'Information Services'
        WHERE (industry_cleaned LIKE '%librar%'
               OR industry_cleaned LIKE '%archiv%'
               OR industry_cleaned LIKE '%information%'
        )
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


-- Standardising the Media and Entertainment industry.
-- Renaming Media & Digital to Media and Entertainment.
-- I include journalism here rather than in the publishing industry below.
UPDATE salary_survey
    SET industry_cleaned = 'Media and Entertainment'
        WHERE industry_cleaned = 'Media & Digital'
        OR industry_cleaned IN (
            'Freelance Journalism', 'Journalism', 'Writing and journalism'
        );


-- Standardising the Entertainment industry.
-- This industry is already present in the salary survey.
-- I will also merge the video games industry and theatres into it.
UPDATE salary_survey
    SET industry_cleaned = 'Entertainment'
        WHERE industry_cleaned IN (
            'Entertainment data', 'Game development', 'Games development',
            'Tabletop Games Publishing', 'Video Game Industry', 'Video Games'
        )
        OR industry_cleaned LIKE '%theat%';


-- Standardising the Publishing industry.
-- Note: publishing of books, journals, blogs, etc.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE industry_cleaned LIKE '%publish%'
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
    SET industry_cleaned = 'Publishing'
        WHERE industry_cleaned LIKE '%publish%'
        AND industry_cleaned NOT IN (
            'Customer service/publishing-adjacent', 'Information sciences',
            'Tabletop Games Publishing'
        );


-- Standardising Science and Research
-- Note: this is especially arbitrary, as the different sciences not only diverge greatly,
-- but are often interwoven into other industries. Many of them could also be included in academia.
-- I exclude some research and development entries, as these are often tied into business
-- rather than science. Of course there are exceptions as well.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE (industry_cleaned LIKE '%science%'
           OR industry_cleaned LIKE '%research%'
           OR industry_cleaned LIKE '%academ%'
    )
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
    SET industry_cleaned = 'Science and Research'
        WHERE (industry_cleaned LIKE '%science%'
               OR industry_cleaned LIKE '%research%'
        )
        AND industry_cleaned NOT IN (
            'Education and Academia', 'Commercial Real Estate Data and Analytics/Research',
            'Consumer Research', 'Contract Research', 'Contract research organisation',
            'Policy research', 'Public Opinion Research', 'not-for-profit health research consulting',
            'Research and Development, Food and Beverage', 'Research & Development',
            'Research and Evaluation', 'Specialist policy consulting/research',
            'User Experience (UX) Research', 'UX Research', 'Wealth advisor Research'
        );


-- Standardising the Environment industry.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE industry_cleaned LIKE '%environment%'
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
    SET industry_cleaned = 'Environment'
        WHERE industry_cleaned LIKE '%environment%'
        OR industry_cleaned IN (
            'Enviromental', 'Environmnetal', 'Ecology'
        )
        AND industry_cleaned != 'Public/Environmental Health';


-- Standardising the Energy industry.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE (industry_cleaned LIKE '%energy%'
           OR industry_cleaned LIKE '%oil%'
           OR industry_cleaned LIKE '%gas%'
    )
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
    SET industry_cleaned = 'Energy'
        WHERE (industry_cleaned LIKE '%energy%'
               OR industry_cleaned LIKE '%oil%'
               OR industry_cleaned LIKE '%gas%'
               OR industry_cleaned = 'Petroleum'
        );


-- Standardising the Utilities & Telecommunications industry.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE industry_cleaned IN (
        'Telecommunications', 'Telecommunications (GPS)'
    );

UPDATE salary_survey
    SET industry_cleaned = 'Utilities & Telecommunications'
        WHERE industry_cleaned IN (
            'Telecommunications', 'Telecommunications (GPS)'
        );


-- Standardising Agriculture or Forestry
UPDATE salary_survey
    SET industry_cleaned = 'Agriculture or Forestry'
        WHERE industry_cleaned IN (
            'Agriculture/Agriculture Chemical'
        );


-- Standardising the Real Estate industry.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE industry_cleaned LIKE '%real estate%'
ORDER BY industry_cleaned ASC;

UPDATE salary_survey
SET industry_cleaned = 'Real Estate'
    WHERE industry_cleaned LIKE '%real estate%'
ORDER BY industry_cleaned ASC;


-- Standardising Leisure, Sport & Tourism. 
UPDATE salary_survey
SET industry_cleaned = 'Leisure, Sport & Tourism'
    WHERE industry_cleaned IN (
        'Fitness'
    );


-- Replacing some entries with NULL, because they are not specifying an industry.
UPDATE salary_survey
    SET industry_cleaned = NULL
        WHERE industry_cleaned IN (
            'accessibility', 'Administration', 'Administrative', 'Administrative Support',
            'Administrative Work', "Wherever I'm assigned via the union", 'PhD', 'Philanthropy',
            'Planning', 'Per Sitter', 'Data Entry'
        );


-- The following queries I used continuously to check the outcome of
-- the industry cleaning process.

-- Selecting all distinct entries with their respective counts.
SELECT
    industry_cleaned,
    COUNT(*) AS 'count'
FROM salary_survey
GROUP BY industry_cleaned
ORDER BY `count`DESC;

-- Counting how many rows are part of the cleaned industries.
SELECT COUNT(*)
FROM salary_survey
    WHERE industry_cleaned IN (
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

-- Selecting all industry options which are not part of the ones I cleaned.
SELECT DISTINCT(industry_cleaned)
FROM salary_survey
    WHERE industry_cleaned NOT IN (
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
ORDER BY industry_cleaned ASC;


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
-- Not only is the following query logically necessary, but it also standardises
-- most variants for the country name.
UPDATE salary_survey
    SET country = 'USA'
        WHERE us_state IS NOT NULL;

UPDATE salary_survey
    SET country = 'USA'
        WHERE country IN (
            'U.S.', 'United States', 'United States of America', 'US', 'USA-- Virgin Islands'
        );


-- ------------------------------------------------------------------------------------------
-- COLUMN: us_state


SELECT COUNT(DISTINCT(us_state))
FROM salary_survey
    WHERE country = 'USA';

SELECT COUNT(DISTINCT(city))
FROM salary_survey
    WHERE country = 'USA';


-- Removing the white spaces from both columns, as I will use the city column to clean
-- the us_state column.
UPDATE salary_survey
    SET city = TRIM(city),
        us_state = TRIM(us_state);


-- Looking at all distinct us_state entries.
-- Right away it is clear that there are entries with multiple states. In these cases,
-- I need to make a decision based on the city column. If there are multiple entries in both
-- columns, it cannot be cleaned.
SELECT DISTINCT(us_state)
FROM salary_survey
    WHERE country = 'USA'
ORDER BY us_state ASC;

-- I use this query to find entries where the us_state is NULL, but the city column may help
-- filling in the missing values. The "city LIKE..." clause varies, but I will not keep all the
-- different queries here.
SELECT
    city, us_state
FROM salary_survey
    WHERE country = 'USA'
    AND us_state IS NULL
    AND city LIKE '%york%';

-- Looking specifically at entries with multiple states.
SELECT
    city,
    us_state    
FROM salary_survey
    WHERE country = 'USA'
    AND us_state LIKE '%,%'
ORDER BY us_state ASC;


-- Cleaning some of these based on the city column.
-- Note: I don't filter for the city where the us_state entry is unique.
UPDATE salary_survey
    SET us_state = 'Arizona'
        WHERE country = 'USA'
        AND us_state LIKE '%,%'
        AND city = 'Tempe, AZ';

-- Apart from country = 'USA', there are two conditions here:
-- 1. There is a comma in the us_state column (multiple entries) and the city
--    is either LA or San Francisco.
-- 2. The us_state column returns one of the options of a certain array, all
--    of which correspond to a city entry in California, based on a SELECT query.
UPDATE salary_survey
    SET us_state = 'California'
        WHERE country = 'USA'
        AND (city IN (
                'Los Angeles', 'San Francisco', 'Redwood City, CA', 'Walnut Creek, California'
            )
            OR us_state IN (
                'Alabama, California', 'Arizona, California', 'California, New Jersey'
            )
        );

UPDATE salary_survey
    SET us_state = 'Colorado'
        WHERE country = 'USA'
        AND us_state IN (
            'California, Colorado', 'Colorado, Nevada'
        );

-- D.C. is not a state, of course, but there is no other option.
-- DMV is somewhat complicated in general, I add the last city entry here as it is valid
-- and doesn't present another option.
UPDATE salary_survey
    SET us_state = 'District of Columbia'
        WHERE country = 'USA'
        AND city IN (
            'DC', 'Washington DC', 'Washington, DC', 'Washington, DC Primarily',
            'Washington, D.C.', 'Washington D.C.', 'Washington, District of Columbia',
            'DMV Metro Area', 'DC Metro Area'
        );
        
UPDATE salary_survey
    SET us_state = 'Illinois'
        WHERE country = 'USA'
        AND us_state IN (
            'Arkansas, Illinois', 'Illinois, Wisconsin'
        );

UPDATE salary_survey
    SET us_state = 'Iowa'
        WHERE country = 'USA'
        AND us_state IN (
            'Arkansas, Iowa, Massachusetts, Ohio, Wyoming', 'Iowa, Utah, Vermont'
        );       

UPDATE salary_survey
    SET us_state = 'Kansas'
        WHERE country = 'USA'
        AND us_state IN (
            'Alabama, Kansas', 'Kansas, Missouri'
        );

UPDATE salary_survey
    SET us_state = 'Kentucky'
        WHERE country = 'USA'
        AND us_state = 'Illinois, Kentucky';

UPDATE salary_survey
    SET us_state = 'Maryland'
        WHERE country = 'USA'
        AND us_state IN (
            'Alaska, Maryland', 'District of Columbia, Maryland',
            'District of Columbia, Maryland, Pennsylvania, Virginia'
        );

UPDATE salary_survey
    SET us_state = 'Massachusetts'
        WHERE country = 'USA'
        AND (us_state = 'Indiana, Massachusetts'
             OR city IN (
                'Boston, MA', 'Cambridge, MA', 'Raleigh; role based out of Boston MA'
             )
        );

UPDATE salary_survey
    SET us_state = 'Michigan'
        WHERE country = 'USA'
        AND us_state = 'Michigan, South Carolina';

UPDATE salary_survey
    SET us_state = 'Minnesota'
        WHERE country = 'USA'
        AND us_state = 'Alabama, Minnesota, Nevada';

UPDATE salary_survey
    SET us_state = 'Missouri'
        WHERE country = 'USA'
        AND us_state = 'Mississippi, Missouri';

UPDATE salary_survey
    SET us_state = 'Montana'
        WHERE country = 'USA'
        AND us_state = 'California, Montana';

UPDATE salary_survey
    SET us_state = 'Nebraska'
        WHERE country = 'USA'
        AND (us_state = 'Iowa, Nebraska'
             OR city = 'Omaha, NE'
        );

UPDATE salary_survey
    SET us_state = 'New Jersey'
        WHERE country = 'USA'
        AND (us_state LIKE '%,%'
             AND city IN (
                'Marlton', 'Florham Park'
             )
             OR city = 'Jersey City, NJ'
        );

-- The second condition is based on a SELECT query looking for the rows where us_state
-- is NULL, but city is NYC.
UPDATE salary_survey
    SET us_state = 'New York'
        WHERE country = 'USA'
        AND (us_state LIKE '%,%'
             AND city IN (
                'New York', 'New York City', 'NYC', 'Brooklyn', 'Albany'
            )
        )    
        OR us_state IS NULL
        AND (city LIKE '%nyc%'
             OR city IN (
                'New York City', 'Albany, NY'
            )
        );

UPDATE salary_survey
    SET us_state = 'North Carolina'
        WHERE country = 'USA'
        AND (city = 'Charlotte, NC'
             OR us_state IN (
                'Maine, Massachusetts, New Hampshire, North Carolina', 'North Carolina, Utah',
                'California, Illinois, Massachusetts, North Carolina, South Carolina, Virginia'
            )
        );

UPDATE salary_survey
    SET us_state = 'Ohio'
        WHERE country = 'USA'
        AND us_state IN (
            'Indiana, Ohio', 'Kentucky, Ohio'
        );

UPDATE salary_survey
    SET us_state = 'Oregon'
        WHERE country = 'USA'
        AND us_state LIKE '%,%'
        AND city IN (
            'Oregon City', 'Portland', 'Portland, OR (remote for a company in CA)'
        );

UPDATE salary_survey
    SET us_state = 'Pennsylvania'
        WHERE country = 'USA'
        AND city != "Marlton"
        AND us_state IN (
            'California, Pennsylvania', 'New Jersey, Pennsylvania', 'Massachusetts, Pennsylvania',
            'Pennsylvania, Rhode Island'
        );

UPDATE salary_survey
    SET us_state = 'Rhode Island'
        WHERE country = 'USA'
        AND us_state = 'Massachusetts, Rhode Island';

UPDATE salary_survey
    SET us_state = 'Tennessee'
        WHERE country = 'USA'
        AND us_state = 'Georgia, Tennessee';

UPDATE salary_survey
    SET us_state = 'Texas'
        WHERE country = 'USA'
        AND us_state IN (
            'California, Texas', 'Michigan, Texas, Washington'
        );

UPDATE salary_survey
    SET us_state = 'Vermont'
        WHERE country = 'USA'
        AND us_state = 'Massachusetts, Vermont';

UPDATE salary_survey
    SET us_state = 'Virginia'
        WHERE country = 'USA'
        AND us_state IN (
            'District of Columbia, Virginia', 'Texas, Virginia'
        );

UPDATE salary_survey
    SET us_state = 'Virginia'
        WHERE country = 'USA'
        AND us_state = 'Maryland, Virginia'
        AND city = 'Reston';

UPDATE salary_survey
    SET us_state = 'Washington'
        WHERE country = 'USA'
        AND us_state IN (
            'Arizona, Washington', 'Georgia, Washington', 'Louisiana, Washington',
            'Ohio, Washington'
        );

UPDATE salary_survey
    SET us_state = 'Wisconsin'
        WHERE country = 'USA'
        AND us_state = 'Florida, New Hampshire, Wisconsin';

UPDATE salary_survey
    SET us_state = 'Wyoming'
        WHERE country = 'USA'
        AND city = 'Cheyenne, Wy';


-- ------------------------------------------------------------------------------------------
-- COLUMN: city
-- Note: since this column has more than 3000 distinct entries, I will not clean all of them,
-- since the outcome will not be worth the effort in this case. However, I will especially
-- deal with major cities.
-- I will include suburbs and smaller towns around major cities in these cities
-- and melt them together.
-- Also, I will update the us_state column where the cleaning of the city column makes it possible.

-- Looking at all the distinct city entries.
SELECT DISTINCT(city)
FROM salary_survey
    WHERE country = 'USA'
ORDER BY city ASC;

-- Distinct city entries ordered by the length of the entry, which shows
-- mostly unclean entries first.
SELECT DISTINCT(city)
FROM salary_survey
    WHERE country = 'USA'
ORDER BY LENGTH(city) DESC;


SELECT
    city,
    us_state
FROM salary_survey
    WHERE country = 'USA'
    AND city LIKE '%work%'
ORDER BY city ASC;

-- First I quickly scroll through the results and replace some of them with NULL.
-- I also use some key words to find additional ones, such as 'small', 'large', etc.
-- I come back to this query throughout the cleaning process to add more.
UPDATE salary_survey
    SET city = NULL
        WHERE country = 'USA'
        AND (city IN (
                '12043', '', '-', '--', '-----', '.', '0', '46901', 'Xx', 'xxx', 'Xxxx',
                'A major one', 'all over N CA', 'All, travel', 'Not saying',
                'Based on current client project', 'O', 'Not provided', 
                'Nope', 'Eastern MA (not Boston)', 'Not Detroit', 'Traveling',
                'NA (remote). Live near Boston, work is based in upstate NY',
                'I travel every week to different cities.', 'Northeast Ohio suburb',
                'I work majority for companies in the state of California.',
                'This would narrow things down too much, sorry!', 'Idaho' 'NW WI',
                'Montclair (not actual city, but same region for anonymity)',
                'Eastern WI City; approx. pop 50,000', 'Suburban School District',
                'This info will make me identifiable', 'This identifies my employer',
                'This is too identifying', 'This would help identify me',
                'This would probably out me', 'This would definitely reveal my identity',
                'My city + industry would ID my employer', 'Major Metro Area',
                'Major metropolitan area', 'Major state metro area', 'metro', 'Metro west',
                'Metro-west', 'West Metro', 'City', 'Small City', 'Mid-size city',
                'Midsized city', 'Medium size city', 'Central IL', 'Central Iowa',
                'Central KY', 'Central Maine', 'Central MD', 'Central NJ', 'Central NY',
                'Central Ohio', 'Central PA', 'Central Valley', 'Central Virginia',
                'Northcentral WI', 'N.A.', 'na', 'My house', 'near San Antonio',
                'No', 'none', 'Normal', 'Normal I’ll', 'NoVA', 'Pennsylvania',
                'redacted (sorry)', 'Regional', 'remove', 'Sorry, no', 'South Texas',
                'Southeast WI', 'southern IL', 'Southern California', 'Southern CA',
                'Southern Maine', 'Southern Maryland', 'Southern MN', 'Telecommute',
                'To Much Detail', 'Truth or Consequences', 'USA', 'Utah', 'Utah County',
                'Virtual', 'Work across the whole state', 'Few hours outside Columbus',
                'Not identifying, but the Central Valley, CA', 'Illinois, Iowa, Missouri'
                'Stillwater: WI based company, office in MN', 'NY', 'NW', 'SC', 'WA', 'TBD',
                'RTP', 'QAC', 'CDA', 'Anon', 'Blank', 'CFL', 'dino', 'Skip', 'Free', 'Iowa',
                'city in Middle Georgia', 'Research Triangle region'
                )
            OR city LIKE '%n/a%'
            OR city LIKE '%small%'
            OR city LIKE '%large%'
            OR city LIKE '%prefer%'
            OR city LIKE '%answer%'
            OR city LIKE '%share%'
            OR city LIKE '%disclose%'
            OR city LIKE '%say%'
            OR city LIKE '%anonymous%'
            OR city LIKE '%applicable%'
            OR city LIKE '%vari%'
            OR city LIKE '%multiple%'
            OR city LIKE '%decline%'
            OR city LIKE '%rural%'
        )
        AND city NOT IN (
            'Small City', 'Small Town Ohio', 'Fuquay Varina', 'Minneapolis, MN/Atlanta, GA'
        );

UPDATE salary_survey
    SET city = 'Albany'
        WHERE country = 'USA'
        AND city = 'Near Albany';

UPDATE salary_survey
    SET city = 'Arlington',
        us_state = 'Virginia'
        WHERE country = 'USA'
        AND city LIKE '%arlington, va%';

UPDATE salary_survey
    SET city = 'Atlanta'
        WHERE country = 'USA'
        AND city IN (
            'Atlanta suburb', 'Atlanta metro area', 'Greater Atlanta Area',
            'Metro Atlanta', 'Atlanta Metro'
        );

UPDATE salary_survey
    SET city = 'Austin'
        WHERE country = 'USA'
        AND city = 'Austin Metro Area';

UPDATE salary_survey
    SET city = 'Baltimore'
        WHERE country = 'USA'
        AND city LIKE '%baltimore%'
        AND city NOT IN (
            'Baltimore', 'Washington, DC - Baltimore, MD area.'
        );

UPDATE salary_survey
    SET city = 'Belfast'
        WHERE country = 'USA'
        AND city LIKE '%Belfast - for context%';
        
-- These happen to be either Boston or in the greater Boston area,
-- therefore I will change them to Boston.
UPDATE salary_survey
    SET city = 'Boston'
        WHERE country = 'USA'
        AND us_state = 'Massachusetts'
        AND city LIKE '%boston%'
        AND city != 'Boston';

UPDATE salary_survey
    SET city = 'Boston',
        us_state = 'Massachusetts'
        WHERE city = 'San Francisco, but company is Boston based';

UPDATE salary_survey
    SET city = 'Buffalo'
        WHERE country = 'USA'
        AND city = 'near Buffalo, NY';

-- I noticed this on the go, New Hampshire has a New Boston.
UPDATE salary_survey
    SET city = 'New Boston'
        WHERE country = 'USA'
        AND us_state = 'New Hampshire'
        AND city LIKE '%boston%';

-- All of these have us_state "Illinois" and are in the Chicago area.
UPDATE salary_survey
    SET city = 'Chicago'
        WHERE country = 'USA'
        AND (us_state = 'Illinois'
             AND city LIKE '%chicago%'
             AND city != 'Chicago'
        );

-- Now those that don't have the state Illinois yet.
UPDATE salary_survey
    SET city = 'Chicago'
        WHERE country = 'USA'
        AND (us_state NOT IN (
                'Illinois', 'Colorado, Illinois'
             )
             AND city LIKE '%chicago%'
             OR us_state IS NULL
             AND city LIKE '%chicago%'
        );

-- Based on the cleaned city, I update the us_state.
UPDATE salary_survey
    SET us_state = 'Illinois'
        WHERE country = 'USA'
        AND city = 'Chicago';

UPDATE salary_survey
    SET city = 'Cincinnati',
        us_state = 'Ohio'
        WHERE country = 'USA'
        AND city = 'Payroll is out of Cincinnati';

UPDATE salary_survey
    SET city = 'Denver'
        WHERE country = 'USA'
        AND city IN (
            'Denver Metro Area', 'Denver metro', 'Denver-metro'
        );

UPDATE salary_survey
    SET city = 'Detroit'
        WHERE country = 'USA'
        AND city IN (
            'Suburban Deteoit', 'Detroit Area', 'Detroit Metro area', 'Metro Detroit area',
            'Metro Detroit', 'Detroit metro', 'Metro-Detroit'
        );

UPDATE salary_survey
    SET city = 'Eufaula'
        WHERE country = 'USA'
        AND city = 'Huntsville but company is in Eufaula';

UPDATE salary_survey
    SET city = 'Frankfort'
        WHERE country = 'USA'
        AND city = 'Bardstown, KY.  Store is located in Frankfort';

UPDATE salary_survey
    SET city = 'Glendale',
        us_state = 'California'
        WHERE country = 'USA'
        AND city = 'Company is in Glendale, California I am in Barrie, Ontario';

UPDATE salary_survey
    SET city = 'Greeley'
        WHERE country = 'USA'
        AND city = 'Greeley surrounding area';

UPDATE salary_survey
    SET city = 'Houston'
        WHERE country = 'USA'
        AND city IN (
            'Houston Area', 'Houston metro area', 'Houston-Galveston-Brazoria area'
        );

UPDATE salary_survey
    SET city = 'Indianapolis'
        WHERE country = 'USA'
        AND city IN (
            'Suburb of Indianapolis', 'Near Indianapolis',
            'Drop down menur was not working. Indianapolis Indiana.'
        );

UPDATE salary_survey
    SET city = 'Jacksonville'
        WHERE country = 'USA'
        AND city = 'Jax';

UPDATE salary_survey
    SET city = 'Los Angeles'
        WHERE country = 'USA'
        AND city IN (
            'LA', 'Los Angeles area', 'Los Angeles metro area', 'Los Angeles, CA',
            'Los Angeles, or I travel for work',
            'Los Angeles, but I work with people in Europe including the company owner'
        );

UPDATE salary_survey
    SET city = 'McLean',
        us_state = 'Virginia'
        WHERE country = 'USA'
        AND city IN (
            'McLean though I travel some', 'Mclean, VA outside of DC'
        );

UPDATE salary_survey
    SET city = 'Miami'
        WHERE country = 'USA'
        AND city IN (
            'Miami area', 'Miami FTL metro area'
        );

UPDATE salary_survey
    SET city = 'Milwaukee'
        WHERE country = 'USA'
        AND city IN (
            'Milwaukee Area', 'Milwaukee metro area', 'Milwaukee metro'
        );

UPDATE salary_survey
    SET city = 'Minneapolis'
        WHERE country = 'USA'
        AND city IN (
            'Greater Minneapolis metro area', 'Minneapolis metro', 'Minnepolis',
            'Minnespolis'
        );

UPDATE salary_survey
    SET city = 'Nashville'
        WHERE country = 'USA'
        AND city LIKE '%nashville%'
        AND city != 'Nashville';

UPDATE salary_survey
    SET city = 'New Orleans'
        WHERE country = 'USA'
        AND city IN (
            'Greater New Orleans Metro Region', 'Nola'
        );

UPDATE salary_survey
    SET city = 'New York City'
        WHERE country = 'USA'
        AND us_state = 'New York'
        AND (city LIKE '%new york%'
            OR city LIKE '%nyc%'
            OR city LIKE '%manhattan%'
            OR city LIKE '%brooklyn%'
            OR city LIKE '%bronx%'
            OR city = 'NY'
        )
        AND city NOT IN (
            'New York City', 'NYC, remotely for a Boston company'
        );

UPDATE salary_survey
    SET city = 'New York City',
        us_state = 'New York'
        WHERE country = 'USA'
        AND city IN (
            'Denver (but remote - company is NYC)', 'NY Suburb',
            'Work remotely for a NYC business from Portland, ME',
            'Greater NYC area', 'NYC', 'Nyc metro', 'NYC metro area',
            'NY Metro', 'New York City, New York', 'Suburb city in Metro NY area'
        );

UPDATE salary_survey
    SET city = 'Oklahoma City'
        WHERE country = 'USA'
        AND city = 'OKC';

UPDATE salary_survey
    SET city = 'Orlando',
        us_state = 'Florida'
        WHERE country = 'USA'
        AND city IN (
            "Dillard (I’m a telecommuter for an office based in Orlando FL)",
            'Orlando, I work in United States at a Consulate for Mexican Government',
            'Orlando metro area'
        );

UPDATE salary_survey
    SET city = 'Philadelphia',
        us_state = 'Pennsylvania'
        WHERE country = 'USA'
        AND city IN (
            'Philadelphia (suburbs)', 'Philadelphia suburb', 'Philadelphia suburbs',
            'Philadelphia, PA Suburbs', 'Suburb of Philadelphia', 'Suburban Philadelphia',
            'Suburbs of Philadelphia', 'Greater Philadelphia area', 'Philadelphia area',
            'OUtside Philadelphia', 'Phialdelphia', 'Philadelphia (but clients everywhere)',
            'Philadelphiai', 'Philadlephia', 'Philiadelpia', 'Philadelphia, PA'
        );

UPDATE salary_survey
    SET city = 'Phoenix'
        WHERE country = 'USA'
        AND city = 'Phx';

UPDATE salary_survey
    SET city = 'Pittsburgh',
        us_state = 'Pennsylvania'
        WHERE country = 'USA'
        AND city IN (
            'Pittsburg', 'Pittsburgh area', 'Pittsburgh, PA'
        );

UPDATE salary_survey
    SET city = 'Portland'
        WHERE country = 'USA'
        AND city IN (
            'Beaverton, OR (Portland suburb)', 'Portland area', 'Portland Metro area',
            'Portland metro', 'South portland', 'North of Portland'
        );

UPDATE salary_survey
    SET city = 'Rancho Cucamonga'
        WHERE country = 'USA'
        AND city = 'Telecommute from Anaheim, CA; employer office in Rancho Cucamonga, CA';

UPDATE salary_survey
    SET city = 'Salt Lake City'
        WHERE country = 'USA'
        AND city IN (
            'Near Salt Lake City', 'Slc'
        );

UPDATE salary_survey
    SET city = 'San Diego'
        WHERE country = 'USA'
        AND city = 'I work remotely, but based in San Diego';

UPDATE salary_survey
    SET city = 'San Francisco',
    us_state = 'California'
        WHERE country = 'USA'
        AND city IN (
            'SF', 'San Fransico', 'San Fransisco', 'South San Francisco'
        );

UPDATE salary_survey
    SET city = 'Seattle',
        us_state = 'Washington'
        WHERE country = 'USA'
        AND city IN (
            'Yakima but my employer is based in Seattle', 'Seattle Area',
            'Greater Seattle area', 'Seattle metro', 'Near Seattle'
        );

UPDATE salary_survey
    SET city = 'St. Louis'
        WHERE country = 'USA'
        AND city = 'STL';

UPDATE salary_survey
    SET city = 'Washington, D.C.'
        WHERE country = 'USA'
        AND us_state = 'District of Columbia'
        AND (city LIKE '%washington%'
             OR city LIKE '%DC%'
             OR city LIKE '%D.C%'
        );

UPDATE salary_survey
    SET us_state = 'District of Columbia',
        city = 'Washington, D.C.'
        WHERE city IN (
            'DC area', 'DC metro area, mostly DC and Montgomery County MD', 'DC suburb',
            'Northern Virginia (Washington, DC metro)', 'D.C.', 'Hjsjs',
            'Washington DC metro area', 'DMV Metro Area'
        );

-- Looking at city entries that contain terms like "remote" and 'work from home".
-- In case an entry clearly specifies the location of the company, I will change it accordingly. Otherwise I will standardise the entries to contain just "Remote".
-- Often this is not fully clear, e.g. when it looks like "City (remote)", where it is
-- not clear whether the location of the company, or of the person's remote office is meant.
-- In such cases, I choose to replace the entry with "Remote" as well, so it will be excluded
-- from analysis using geographic data.
SELECT
    city,
    us_state
FROM salary_survey
    WHERE country = 'USA'
    AND city != 'Remote'
    AND (city LIKE '%remote%'
         OR city LIKE '%wfh%'
         OR city LIKE '%work from home%'
         OR city LIKE '%home%'
    )
ORDER BY city ASC;

UPDATE salary_survey
    SET city = 'Remote'
        WHERE country = 'USA'
        AND (city LIKE '%remote%'
            OR city LIKE '%wfh%'
            OR city LIKE '%work from home%'
            OR city LIKE '%home%'
        )
        AND city NOT IN (
            'Remote', 'Durham (remote employee in Vermont; salaries based on HQ in Durham)',
            'Fully remote job (Denver area)', "Glendale, but I'm full time remote.",
            'Harlingen, TX (Remote Work)', 'Houston but I am fully remote permanently',
            'Houston, but the job is remote', 'Office: Lansing, MI and wfh Ypsilani MI',
            'Huntington (remote, HQ is in Charleston)', 'Los Angeles (but my job is remote)',
            'I work remotely. My company is based out of Pittsburgh, PA', 'Mahomet',
            'Memphis (but work 100% remote)', 'Redwood City, remotely in San Carlos',
            'NYC, remotely for a Boston company', 'Remote - HQ is in DC',
            'Remote (HQ in San Fran, based in LA)', 'Rochester (remote-company based in SF, CA)',
            'Salem (remote for Boston Mass)', 'the office is in Schaumburg; I work remotely',
            'Seven Hills, but really Remote', 'Remotely - Stamford HQ',
            'San Francisco (nominally; I work from home now due to COVID)',
            'Tacoma (we are now permanently WFH, but our office was based in Tacoma)'
        );

-- Based on the outcome, I can run the above select query again and adapt all the results
-- to hold the cities and respective us_states. 
UPDATE salary_survey
    SET city = 'Durham'
        WHERE country = 'USA'
        AND city = 'Durham (remote employee in Vermont; salaries based on HQ in Durham)';

UPDATE salary_survey
    SET city = 'Denver'
        WHERE country = 'USA'
        AND city = 'Fully remote job (Denver area)';

UPDATE salary_survey
    SET city = 'Glendale'
        WHERE country = 'USA'
        AND city = "Glendale, but I'm full time remote.";

UPDATE salary_survey
    SET city = 'Harlingen'
        WHERE country = 'USA'
        AND city = 'Harlingen, TX (Remote Work)';

UPDATE salary_survey
    SET city = 'Houston'
        WHERE country = 'USA'
        AND city IN (
            'Houston but I am fully remote permanently',
            'Houston, but the job is remote'
        );

UPDATE salary_survey
    SET city = 'Charleston'
        WHERE country = 'USA'
        AND city = 'Huntington (remote, HQ is in Charleston)';

UPDATE salary_survey
    SET city = 'Pittsburgh',
        us_state = 'Pennsylvania'
        WHERE country = 'USA'
        AND city = 'I work remotely. My company is based out of Pittsburgh, PA';

UPDATE salary_survey
    SET city = 'Los Angeles',
        us_state = 'California'
        WHERE country = 'USA'
        AND city IN (
            'Los Angeles (but my job is remote)',
            'Oaxaca de Juarez (home). Company I work for is based in Los Ángeles'
        );

UPDATE salary_survey
    SET city = 'Memphis'
        WHERE country = 'USA'
        AND city = 'Memphis (but work 100% remote)';

UPDATE salary_survey
    SET city = 'Boston',
        us_state = 'Massachusetts'
        WHERE country = 'USA'
        AND city = 'NYC, remotely for a Boston company';

UPDATE salary_survey
    SET city = 'Lansing',
        us_state = 'Michigan'
        WHERE country = 'USA'
        AND city = 'Office: Lansing, MI and wfh Ypsilani MI';

UPDATE salary_survey
    SET city = 'Redwood City'
        WHERE country = 'USA'
        AND city = 'Redwood City, remotely in San Carlos';

UPDATE salary_survey
    SET city = 'Washington, D.C.',
        us_state = 'District of Columbia'
        WHERE country = 'USA'
        AND city = 'Remote - HQ is in DC';

UPDATE salary_survey
    SET city = 'San Francisco',
    us_state = 'California'
        WHERE country = 'USA'
        AND city IN (
            'Remote (HQ in San Fran, based in LA)',
            'Rochester (remote-company based in SF, CA)',
            'San Francisco (nominally; I work from home now due to COVID)'
        );

UPDATE salary_survey
    SET city = 'Stamford'
        WHERE country = 'USA'
        AND city = 'Remotely - Stamford HQ';

UPDATE salary_survey
    SET city = 'Salem'
        WHERE country = 'USA'
        AND city = 'Salem (remote for Boston Mass)';

UPDATE salary_survey
    SET city = 'Seven Hills'
        WHERE country = 'USA'
        AND city = 'Seven Hills, but really Remote';

UPDATE salary_survey
    SET city = 'Tacoma'
        WHERE country = 'USA'
        AND city = 'Tacoma (we are now permanently WFH, but our office was based in Tacoma)';

UPDATE salary_survey
    SET city = 'Schaumburg'
        WHERE country = 'USA'
        AND city = 'the office is in Schaumburg; I work remotely';


-- Looking at "leftover" options, the results of which I include in queries
-- above where it makes sense.
SELECT
    city,
    us_state
FROM salary_survey
    WHERE country = 'USA'
    AND us_state IS NULL
    AND city LIKE '%,%'
    AND city != 'Washington, D.C.'
ORDER BY city ASC;

SELECT
    city,
    us_state
FROM salary_survey
    WHERE country = 'USA'
    AND (city LIKE '%area%'
         OR city LIKE '%metro%'
         OR city LIKE '%central%'
         OR city LIKE '%near%'
    )
ORDER BY city ASC;


-- SF Bay Area is too large an area to just merge it into San Francisco, in my opinion.
UPDATE salary_survey
    SET city = 'San Francisco Bay Area'
        WHERE country = 'USA'
        AND us_state = 'California'
        AND city IN (
            'SF Bay Area', 'Bay Area', 'Bay Area / Palo Alto', 'Belmont, CA (SF Bay Area)',
            'Central Valley/Bay Area', 'East Bay area', 'Bay Area, CA', 'north bay',
            'Walnut Creek (SF Bay Area)', 'East Bay'
        );

-- The Twin Cities are Minneapolis and Saint Paul in Minnesota.
-- Since these are two cities, I cannot merge them together.
UPDATE salary_survey
    SET city = 'Twin Cities',
        us_state = 'Minnesota'
        WHERE country = 'USA'
        AND (city LIKE '%twin cities%'
             OR city IN (
                'Minneapolis/St Paul metro area', 'Minneapolis-St Paul',
                'Minneapolis/St Paul', 'Minneapolis-St. Paul',
                'St. Paul/Minniapolis area'
             )
        );

-- Another area consisting of multiple cities, which I cannot merge together.
-- Although one could argue that it makes sense to merge it into Dallas, since
-- Dallas and Fort Worth are geographically merged already.
UPDATE salary_survey
    SET city = 'Dallas–Fort Worth metroplex',
        us_state = 'Texas'
        WHERE country = 'USA'
        AND city = 'DFW';

-- As many entries try to specify the location of their small towns/suburbs
-- by adding the cardinal directions, I am looking for these.
SELECT
    city,
    us_state
FROM salary_survey
    WHERE country = 'USA'
    AND (city LIKE '%north%'
         OR city LIKE '%east%'
         OR city LIKE '%south%'
         OR city LIKE '%west%'
    )
ORDER BY city ASC;

-- The following ones don't specify a city, therefore I replace them with NULL.
UPDATE salary_survey
    SET city = NULL
        WHERE city IN (
                'East Coast USA', 'Eastern', 'Eastern Iowa', 'Eastern MA', 'Eastern Washington',
                'Key West', 'Metrowest area', 'Midwest', 'Midwest area', 'Midwest IL',
                'Midwest region', 'North Coast', 'North Carolina', 'North East', 'North Georgia',
                'North Jersey', 'Northeast Florida', 'Northeast Ohio', 'Northern California',
                'northern CO', 'Northern Michigan', 'Northern VA', 'northern vermont',
                'Northern Virginia', 'Northwest', 'Northwest Georgia', 'Northwest Lower MI',
                'South', 'south central AK', 'Southwest MI', 'West TN', 'Western KS',
                'Western MA', 'Western Mass', 'Western MD', 'Western US', 'East Rutherford',
                'Eastern WA', 'South Jersey'
        );

UPDATE salary_survey
    SET city = 'Lansing'
        WHERE city = 'East Lansing';

UPDATE salary_survey
    SET city = 'Brunswick'
        WHERE city = 'East Brunswick';

UPDATE salary_survey
    SET city = 'Clarendon'
        WHERE city = 'North Clarendon';

UPDATE salary_survey
    SET city = 'Los Angeles'
        WHERE city = 'West Hollywood';

UPDATE salary_survey
    SET city = 'West Palm Beach'
        WHERE city = 'West Palm Beaxh';


-- ------------------------------------------------------------------------------------------
-- COLUMN: salary_annual
-- Note: This column cannot be cleaned for the whole dataset in any case,
-- since currencies are different.


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
-- So, here I am using SUBSTRING to select only the first number in the string, which I then
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