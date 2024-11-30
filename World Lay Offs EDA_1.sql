-- Exploratory Data Analysis

SELECT *
FROM layoffs_staging_tweaking2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging_tweaking2;

#Finding out the date range of data provided
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging_tweaking2;

#See which industry got hit the hardest
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging_tweaking2
GROUP BY industry
ORDER BY 2 DESC;

#Finding out which country got hit the hardest by layoffs within date range
SELECT country, SUM(total_laid_off)
FROM layoffs_staging_tweaking2
GROUP BY country
ORDER BY 2 DESC;

#Sum of ppl laid off per year
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging_tweaking2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

#Company stage with most sum of lay offs
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging_tweaking2
GROUP BY stage
ORDER BY 1 DESC;

#Rolling total of lay offs per month
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging_tweaking2
GROUP BY `MONTH` 
ORDER BY 1 ASC;

WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging_tweaking2
GROUP BY `MONTH` 
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off
,SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;

#Ranking top companies with the most lay offs per year
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging_tweaking2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;


WITH Company_Year (company, years, total_laid_off) AS
( 
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging_tweaking2
GROUP BY company, YEAR(`date`)
) 
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking #group all 2023 desc then all 2024 desc and ranks which got most lay offs
FROM Company_Year
WHERE years IS NOT NULL
ORDER BY Ranking ASC;

#Rank top 5 of each year (2 CTEs)
WITH Company_Year (company, years, total_laid_off) AS
( 
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging_tweaking2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking 
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5
;