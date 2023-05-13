## Data cleaning with MySQL: Ask A Manager Salary Survey 2021

by Alexander Steindorfer<br/><br/>

**Data source**: https://docs.google.com/spreadsheets/d/1IPS5dBSGtwYVbjsfbaMCYIWnOuRmJcbequohNxCyGVw/edit?resourcekey#gid=1625408792<br> 
The survey: https://www.askamanager.org/2021/04/how-much-money-do-you-make-4.html<br>

*Please note that this dataset is not static. At the time you use it, it may include more data, causing your results to differ from mine.
However, I include the csv file which I prepared for the project, based on the Excel file downloaded in January 2023 from the source above.*<br/><br/>

### **Format**<br>
The project includes only sql files, in which MySQL is used.
I restricted myself to MySQL, as this is meant to be an exercise in this particular language.<br/><br/>

### **Contents**<br>
**1.** Creation of the local database and a table in which the dataset is then stored from a csv file.<br>
**2.** Cleaning of the dataset.<br>
**3.** Creation of a new table which only holds US data.<br>
**4.** Short analysis of the cleaned US data.<br/><br/>

### **Goals of this project**<br>
The cleaning of the dataset is the main focus of the project. It is meant to make the survey results usable in an analysis. I focused especially on US data, but I might come back at a later point to clean the data for other locations, as this would also allow different approaches to an analysis.<br>
Furthermore, I decided to include a short analysis of key figures to prove that the cleaning was performed successfully.<br/><br/>

### **What I have learned while working on this project**<br>

* The necessity of balancing input and output in the data cleaning process. A lot of time can be spent on it, but it must be calculated how much effort is reasonable.
* That performing analysis can shed further light on what may be necessary in the cleaning process.
* Different methods and statements in MySQL, such as SUBSTRING and CASE WHEN, which are really useful in the cleaning process, also to get an alternative view on what is to be cleaned.
* How to create a new table, using a SELECT statement to define its contents.
* That reading in a csv file into a SQL server might be the most troublesome part of a project.