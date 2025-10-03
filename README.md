Absolutely! Here’s the **full professional README** in a single copy-paste-ready format:

---

# World_Layoffs_Analysis

## Project Overview

This project performs **data cleaning, transformation, and exploratory data analysis (EDA)** on a dataset of company layoffs worldwide. The aim is to understand trends, identify top-affected companies, industries, and countries, and gain insights into layoffs over time.

The project uses **MySQL** for data cleaning and analysis, ensuring the data is accurate, consistent, and ready for business intelligence purposes.

## Dataset

* **File:** `layoffs.csv`
* **Source:** Publicly available dataset
* **Description:** Contains records of layoffs across companies worldwide with attributes such as:

  * `company`
  * `location`
  * `industry`
  * `total_laid_off`
  * `percentage_laid_off`
  * `date`
  * `stage`
  * `country`
  * `funds_raised_millions`

## Repository Structure

```
world_layoffs_project/
│
├── data/
│   └── layoffs.csv               # Raw dataset
│
├── sql/
│   ├── cleaned_layoffs.sql       # SQL script for data cleaning and preprocessing
│   └── eda_queries.sql           # SQL script containing all exploratory analysis queries
│
├── README.md                     # Project documentation
```

## Data Cleaning Steps

The data cleaning workflow ensures the dataset is accurate and ready for analysis:

1. **Create Staging Table**

   * Raw data is copied into a staging table (`layoffs_staging`) to preserve the original dataset.

2. **Remove Duplicates**

   * Duplicates are identified using `ROW_NUMBER()` and removed by creating a secondary staging table (`layoffs_staging2`).

3. **Standardize Data**

   * Trim whitespace from textual columns (company, industry, country).
   * Standardize industry names (e.g., all “Crypto” variations unified).
   * Remove trailing characters from country names.
   * Convert the `date` column from `TEXT` to `DATE` format.

4. **Handle Null and Blank Values**

   * Rows with both `total_laid_off` and `percentage_laid_off` null are removed.
   * Missing industry or company values are filled using related rows.

5. **Finalize Cleaned Table**

   * Remove unnecessary columns (e.g., `row_num`).
   * The cleaned table (`layoffs_staging2`) is ready for analysis.

## Exploratory Data Analysis (EDA)

The EDA addresses key business questions to understand layoffs trends:

1. Maximum layoffs in a single record.
2. Companies that went completely under (100% layoffs).
3. Total count and list of companies with 100% layoffs.
4. Total layoffs per company.
5. Total layoffs per industry.
6. Total layoffs per country.
7. Total layoffs per date (most recent to oldest).
8. Total layoffs per date, ordered by volume.
9. Total layoffs per stage.
10. Total layoffs per year.
11. Time range of layoffs data (earliest and latest dates).
12. Total layoffs per month (YYYY-MM).
13. Monthly layoffs with cumulative rolling totals.
14. Total layoffs per company per year.
15. Top 3 companies with highest layoffs per year using ranking.

## Key SQL Techniques Used

* **Aggregation:** `SUM()`, `COUNT()`, `MAX()`, `MIN()`
* **Window Functions:** `ROW_NUMBER()`, `DENSE_RANK()`, `SUM() OVER()`
* **CTEs (Common Table Expressions):** Organize intermediate calculations
* **Date Handling:** `YEAR()`, `SUBSTRING()` for grouping by month or year
* **Data Cleaning:** `TRIM()`, `UPDATE`, `DELETE`
* **Combining Queries:** `UNION ALL`, subqueries

## How to Use This Repository

1. Clone the repository:

   ```bash
   git clone <repository_url>
   ```
2. Open MySQL and create the database:

   ```sql
   CREATE DATABASE world_layoffs;
   USE world_layoffs;
   ```
3. Load the raw CSV into the `layoffs` table:

   ```sql
   LOAD DATA INFILE 'data/layoffs.csv'
   INTO TABLE layoffs
   FIELDS TERMINATED BY ','
   ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 ROWS;
   ```
4. Run `cleaned_layoffs.sql` to clean the data.
5. Run `eda_queries.sql` to perform all exploratory analysis queries.

## Author

**Akashreddy Biyyam**

* SQL & Data Analysis enthusiast
* GitHub: [Your GitHub URL]
* mail:[akashreddybiyyam@gmail.com]

---

