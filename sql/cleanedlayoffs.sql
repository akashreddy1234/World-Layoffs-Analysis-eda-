use world_layoffs;
select * from layoffs;

-- 1. remove duplicates 
-- 2. standarize table(ensure all data follows same format)
-- 3.handle null or blank values
-- 4.remove any columns or any rows that are irrelevant

-- first create a staging table so that when we do any mistakes we can always start from raw data 
-- Creates an empty table with the same columns and data types as the raw table
create table layoffs_staging
like layoffs; 

-- now we  can then  insert rows later:
insert into layoffs_staging
select * from layoffs; 

-- visualize the staging table
select * from layoffs_staging;

-- now we will perform row_number() to assign a unique row number 
-- Use ROW_NUMBER() to identify and remove duplicates while keeping one original row

with duplicate_cte as
(
select *,
row_number() over(
partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions
)as row_num
from layoffs_staging
)
select *
from duplicate_cte
where row_num>1;

-- in mysql we cannot delete directly from a cte so we will create another duplicate staging called layoffs_staging
 CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
-- now empty table is created 
select * from layoffs_staging2;
-- we will insert now
 insert into layoffs_staging2
 select *,
row_number() over(
partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions
)as row_num
from layoffs_staging;
-- now we will delete which have row_num>1
delete
from layoffs_staging2
where row_num >1; 

-- 2.standardizing data
select distinct company
from layoffs_staging2;
-- as we can see here theree are white spaces  
-- first trim the data it will remove any white spaces at first or at last 
update layoffs_staging2
set company = trim(company);

select distinct industry
from layoffs_staging2;
-- as we can see in industry column crypto and crypto currencies are same but with different names so we make them to follow same style
-- first we will check how many are starting with crypto
select * from 
layoffs_staging2
where industry like 'Crypto%';
-- now update all of them to crypto
update layoffs_staging2
set industry = 'Crypto'
where Industry like 'Crypto%';

select distinct country
from layoffs_staging
order by 1;
-- as we can observe there is a dot at the end of united states
select distinct country,trim(trailing '.' from country)
from layoffs_staging2
order by 1;
-- now update it 
update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United States%';

-- as we can observe the date column data type is text
select `date`
from layoffs_staging2;

select `date`,
str_to_date(`date`,'%m/%d/%Y')
from layoffs_staging2;
-- now update  
update layoffs_staging2
set `date` = str_to_date(`date`,'%m/%d/%Y');
-- now change the data type of the data column without converting values we should not change data type if we try to do it it will give errors
alter table layoffs_staging2
modify column `date` date;

-- 3.handling null and blank values

-- query indus1
select *
from layoffs_staging2
where industry is null 
or industry = '';
-- query indus2
select *
from layoffs_staging2
where company = 'Airbnb';

-- if we observe indus1 and indus2 we can clearly populate industry with travel where company is airbnb
update layoffs_staging2
set industry = null
where industry = '';

select t1.industry,t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company = t2.company
and t1.location = t2.location
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;
-- updating rows with similar data from same comapnya nd industry
update layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null 
and t2.industry is not null;

-- 4.remove any columns or rows and rows thata re not relevant
select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;
-- we can delete these as both total_laid_off and percentage both are null
delete 
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

select * from 
layoffs_staging2;

-- now we can remove row_num as all data cleaning is done and we dont have any use with it
alter table layoffs_staging2
drop column row_num;