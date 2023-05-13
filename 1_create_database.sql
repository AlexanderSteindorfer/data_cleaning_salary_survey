CREATE DATABASE IF NOT EXISTS salary_survey
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;


CREATE TABLE `salary_survey`(
    `age` VARCHAR(30),
    industry VARCHAR(255),
    job_title VARCHAR(255),
    job_context VARCHAR(255),
    salary_annual INT,
    additional_compensation INT,
    currency VARCHAR(255),
    currency_other VARCHAR(255),
    income_context VARCHAR(255),
    country VARCHAR(255),
    us_state VARCHAR(255),
    city VARCHAR(255),
    experience_overall VARCHAR(255),
    experience_in_field VARCHAR(255),
    education VARCHAR(255),
    gender VARCHAR(255),
    race VARCHAR(255)
);


-- The following can avoid certain errors while importing a csv file.
SET SESSION sql_mode = '';


-- Importing a csv file into the table.
LOAD DATA INFILE 'data/salary_survey.csv'
INTO TABLE salary_survey
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;