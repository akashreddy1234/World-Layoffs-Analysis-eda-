-- =============================================
-- Exploratory Data Analysis (EDA) on World Layoffs
-- Database: world_layoffs
-- Cleaned Table: layoffs_staging2
-- Author: Akashreddy Biyyam
-- =============================================

-- Use the database
USE world_layoffs;

-- Preview the cleaned data
SELECT * FROM layoffs_staging2;

-- 1. Maximum number of employees laid off in a single record
SELECT MAX(total_laid_off) AS max_laid_off
FROM layoffs_staging2;

-- 2. Companies that had 100% layoffs (completely went under)
SELECT company, location, industry, stage, country
FROM layoffs_staging2
WHERE percentage_laid_off = 1;

-- 3. Count and list of companies that went completely under
-- Using UNION ALL to show names and total count in last row
SELECT company
FROM layoffs_staging2
WHERE percentage_laid_off = 1
UNION ALL
SELECT CONCAT("Total companies: ", COUNT(DISTINCT company))
FROM layoffs_staging2
WHERE percentage_laid_off = 1;

-- Using subquery to count total companies
SELECT company,
       (SELECT COUNT(DISTINCT company) 
        FROM layoffs_staging2
        WHERE percentage_laid_off = 1) AS companies_went_under
FROM layoffs_staging2
WHERE percentage_laid_off = 1
GROUP BY company;

-- Using window function to get total companies
SELECT company, COUNT(*) OVER() AS total_laid_off
FROM layoffs_staging2
WHERE percentage_laid_off = 1
GROUP BY company;

-- 4. Total layoffs per company, ordered by highest layoffs
SELECT company, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY company
ORDER BY total_laid_off DESC;

-- 5. Total layoffs per industry, ordered by highest layoffs
SELECT industry, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY industry
ORDER BY total_laid_off DESC;

-- 6. Total layoffs per country, ordered by highest layoffs
SELECT country, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY country
ORDER BY total_laid_off DESC;

-- 7. Total layoffs per date (most recent to oldest)
SELECT `date`, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY `date`
ORDER BY `date` DESC;

-- 8. Total layoffs per date, ordered by volume (highest layoffs first)
SELECT `date`, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY `date`
ORDER BY total_laid_off DESC;

-- 9. Total layoffs per stage
SELECT stage, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY stage
ORDER BY total_laid_off DESC;

-- 10. Total layoffs per year
SELECT YEAR(`date`) AS year, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY year DESC;

-- 11. Time range of layoffs data (earliest and latest dates)
SELECT MIN(`date`) AS earliest_date, MAX(`date`) AS latest_date
FROM layoffs_staging2;

-- 12. Total layoffs per month (YYYY-MM), ascending by month
SELECT SUBSTRING(`date`,1,7) AS month, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY month
ORDER BY month ASC;

-- Note: SUBSTRING is used to extract YYYY-MM from date for monthly grouping.
-- Example: '2023-05-14' becomes '2023-05'

-- 13. Monthly layoffs along with cumulative (rolling) total over time
WITH rolling_total AS (
    SELECT SUBSTRING(`date`,1,7) AS month,
           SUM(total_laid_off) AS total_off
    FROM layoffs_staging2
    WHERE SUBSTRING(`date`,1,7) IS NOT NULL
    GROUP BY month
    ORDER BY month ASC
)
SELECT month,
       total_off,
       SUM(total_off) OVER (ORDER BY month) AS rolling_total
FROM rolling_total;

-- 14. Total layoffs per company per year
SELECT company, YEAR(`date`) AS year, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY total_laid_off DESC;

-- 15. Top 3 companies with the highest layoffs per year
WITH Company_Year AS (
    SELECT company, YEAR(date) AS year, SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging2
    GROUP BY company, YEAR(date)
),
Company_Year_Rank AS (
    SELECT company, year, total_laid_off,
           DENSE_RANK() OVER (PARTITION BY year ORDER BY total_laid_off DESC) AS ranking
    FROM Company_Year
)
SELECT company, year, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 3
AND year IS NOT NULL
ORDER BY year ASC, total_laid_off DESC;
