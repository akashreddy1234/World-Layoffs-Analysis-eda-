-- exploratorty data analysis
use world_layoffs;
select * from layoffs_staging2;

-- 1.What is the maximum number of employees laid off?
select max(total_laid_off)
from layoffs_staging2;

-- 2.“Which companies had a 100% layoff (i.e., completely went under)?”
select company,location,industry,stage,country
from layoffs_staging2
where percentage_laid_off = 1;

-- 3.“How many companies went completely under, and what are they?”
-- using union
-- List all companies that went 100% under and display the total count in the last row
-- Uses UNION ALL: first part lists company names, second part adds a descriptive total using CONCAT
select company 
from layoffs_staging2
where percentage_laid_off = 1
union all
select concat("total companies:",count(distinct company))
from layoffs_staging2
where percentage_laid_off = 1;
-- using subquery
select company,
(select count(distinct company) 
from layoffs_staging2
where percentage_laid_off = 1
)as companies_went_under
from layoffs_staging2
where percentage_laid_off = 1
group by company;
-- using normal way
select company,count(*) over() as total_laid_off
from layoffs_staging2
where percentage_laid_off = 1
group by company;

-- 4."Which companies laid off the most employees in total, and what are the total layoffs per company?”
select company,sum(total_laid_off) 
from layoffs_staging2
group by company
order by 2 desc;
-- 2 refers to the second column in the SELECT list (SUM(total_laid_off)).

-- 5."Which industries laid off the most employees in total, and what are the total layoffs per industry?”
select industry,sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;

-- 5."Which country laid off the most employees in total, and what are the total layoffs per country?”
select country,sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc;

-- 6.“What are the total layoffs per date, listed from the most recent date to the oldest?”
select `date`,sum(total_laid_off)
from layoffs_staging2
group by `date`
order by 1 desc;

-- 7.what are the total layoffs per data show records in descending order of layoffs
select `date`,sum(total_laid_off)
from layoffs_staging2
group by `date`
order by 2 desc;

-- 8."Which stages laid off the most employees in total, and what are the total layoffs per stage?”
select stage,sum(total_laid_off)
from layoffs_staging
group by stage
order by 2 desc;

-- 9.what are the total layoffs per year
select year(`date`),sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by 1 desc;

-- 10.“What is the time range of the layoffs data? i.e., the earliest and latest layoff dates in the dataset.”
select min(`date`),max(`date`)
from layoffs_staging2;

-- 11.“How many employees were laid off each month, starting from the earliest month up to the most recent month?”
select substring(`date`,1,7) as `month`,sum(total_laid_off)
from layoffs_staging2
where substring(`date`,1,7) is not null
group by month
order by 1 asc;
-- Using SUBSTRING(`date`,1,7) to extract the year and month (YYYY-MM) part from the date.
-- This allows us to group layoffs by month instead of full dates.
-- Example: '2023-05-14' becomes '2023-05', so all May 2023 records are grouped together.

-- 12.calculate the monthly layoffs along with a cumulative (rolling) total of layoffs over time?”
-- step 1:cte that groups layoffs by month
with rolling_total as(
select substring(`date`,1,7) as `month`,sum(total_laid_off) as total_off
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1 asc
)
-- step 2:in the main function using window function to calculate rolling sum
select `month`,total_off,sum(total_off) over(order by `month`) as rolling_data
from rolling_total;

-- “For each company and each year, how many total layoffs were reported?”
select company,year(`date`),sum(total_laid_off)
from layoffs_staging2
group by company,year(`date`)
order by 3 desc;

-- “Which are the top 3 companies with the highest layoffs in each year?”
WITH Company_Year AS 
(
  SELECT company, YEAR(date) AS years, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging2
  GROUP BY company, YEAR(date)
)
, Company_Year_Rank AS (
  SELECT company, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year
)
SELECT company, years, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 3
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;