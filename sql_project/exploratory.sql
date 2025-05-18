-- covid_deaths_exploration.sql
-- SQL Exploratory Queries on the covid_deaths Table

-- 1. Check the structure of the table (column names and types)
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'covid_deaths';

-- 2. View a sample of the data (first 10 rows)
SELECT *
FROM covid_deaths
LIMIT 10;

-- 3. Find the range of dates in the dataset
SELECT MIN(date) AS start_date, MAX(date) AS end_date
FROM covid_deaths;

-- 4. Count total rows and distinct locations in the dataset
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT location) AS total_locations
FROM covid_deaths;

-- 5. Total cases and total deaths worldwide
SELECT 
    SUM(total_cases) AS world_total_cases,
    SUM(total_deaths) AS world_total_deaths
FROM covid_deaths
WHERE date = (SELECT MAX(date) FROM covid_deaths);

SELECT *
FROM covid_deaths
WHERE date = (SELECT MAX(date) FROM covid_deaths) AND new_cases IS NOT NULL
LIMIT 5;


-- 6. Countries with the highest total deaths
SELECT location, MAX(total_deaths) AS max_deaths
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY max_deaths DESC
LIMIT 10;

-- 7. New cases per day globally (trend overview)
SELECT date, SUM(new_cases) AS daily_new_cases
FROM covid_deaths
GROUP BY date
ORDER BY date;

-- 8. Death rate per location (total_deaths / total_cases)
SELECT location,
       MAX(total_cases) AS total_cases,
       MAX(total_deaths) AS total_deaths,
       ROUND(MAX(total_deaths) * 100.0 / NULLIF(MAX(total_cases), 0), 2) AS death_rate_percent
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY death_rate_percent DESC
LIMIT 10;


-- 10. ICU(Intense Care Unit) patients per million - top 10 latest entries
SELECT location, date, icu_patients_per_million
FROM covid_deaths
WHERE icu_patients_per_million IS NOT NULL
ORDER BY date DESC, icu_patients_per_million DESC
LIMIT 10;

-- 11. Compare hospital and ICU patients for top 5 affected countries
SELECT location, 
       MAX(icu_patients) AS max_icu_patients,
       MAX(hosp_patients) AS max_hosp_patients
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY max_icu_patients DESC
LIMIT 5;

-- 12. Weekly hospital admissions trends for a specific country (e.g., Italy)
SELECT date, weekly_hosp_admissions
FROM covid_deaths
WHERE location = 'Italy'
  AND weekly_hosp_admissions IS NOT NULL
ORDER BY date;

-- 13. Case trend in Africa (new cases over time)
SELECT date, SUM(new_cases) AS new_cases_in_africa
FROM covid_deaths
WHERE continent = 'Africa'
GROUP BY date
ORDER BY date;

-- 14. Locations with missing data for total_cases or total_deaths
SELECT location, COUNT(*) AS missing_entries
FROM covid_deaths
WHERE total_cases IS NULL OR total_deaths IS NULL
GROUP BY location
ORDER BY missing_entries DESC;

-- 15. Countries with highest new deaths per million (latest date)
SELECT location, new_deaths_per_million
FROM covid_deaths
WHERE date = (SELECT MAX(date) FROM covid_deaths)
  AND new_deaths_per_million IS NOT NULL
ORDER BY new_deaths_per_million DESC
LIMIT 10;

-- covid_deaths_advanced_exploration.sql
-- More SQL Exploratory Queries on the covid_deaths Table

-- 1. Total new cases per continent on the latest date
SELECT continent, SUM(new_cases) AS total_new_cases
FROM covid_deaths
WHERE date = (SELECT MAX(date) FROM covid_deaths)
  AND continent IS NOT NULL
GROUP BY continent
ORDER BY total_new_cases DESC;

-- 2. 7-day moving average of new cases for a specific country (e.g., India)
SELECT date, new_cases_smoothed
FROM covid_deaths
WHERE location = 'India'
  AND new_cases_smoothed IS NOT NULL
ORDER BY date;

-- 3. Compare total cases vs. population (as percentage) for each country
SELECT location,
       MAX(total_cases) AS total_cases,
       MAX(population) AS population,
       ROUND(MAX(total_cases) * 100.0 / NULLIF(MAX(population), 0), 2) AS percent_infected
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY percent_infected DESC
LIMIT 15;

-- 4. Countries with the highest hospital patient rates per million
SELECT location, MAX(hosp_patients_per_million) AS peak_hospitalization_rate
FROM covid_deaths
WHERE hosp_patients_per_million IS NOT NULL
GROUP BY location
ORDER BY peak_hospitalization_rate DESC
LIMIT 10;

-- 5. Days with the highest global new deaths
SELECT date, SUM(new_deaths) AS total_new_deaths
FROM covid_deaths
GROUP BY date
ORDER BY total_new_deaths DESC
LIMIT 10;

-- 6. Countries with continuous reporting (number of dates reported)
SELECT location, COUNT(DISTINCT date) AS reporting_days
FROM covid_deaths
GROUP BY location
ORDER BY reporting_days DESC
LIMIT 15;

-- 7. Calculate case fatality ratio (CFR) for each continent
SELECT continent,
       SUM(total_deaths) AS total_deaths,
       SUM(total_cases) AS total_cases,
       ROUND(SUM(total_deaths) * 100.0 / NULLIF(SUM(total_cases), 0), 2) AS cfr_percent
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY cfr_percent DESC;

-- 8. Average ICU patients over time (worldwide)
SELECT date, ROUND(AVG(icu_patients), 2) AS avg_icu_patients
FROM covid_deaths
WHERE icu_patients IS NOT NULL
GROUP BY date
ORDER BY date;

-- 9. Total deaths by country in Africa
SELECT location, MAX(total_deaths) AS total_deaths
FROM covid_deaths
WHERE continent = 'Africa'
GROUP BY location
ORDER BY total_deaths DESC;

-- 10. Highest new deaths in a single day by country
SELECT location, date, new_deaths
FROM covid_deaths
WHERE new_deaths IS NOT NULL
ORDER BY new_deaths DESC
LIMIT 10;


-- 11. Number of countries per continent in the dataset
SELECT continent, COUNT(DISTINCT location) AS num_countries
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent;

-- 12. Find all countries with reproduction rate consistently over 1.5
SELECT DISTINCT location
FROM covid_deaths
WHERE reproduction_rate > 1.5;

-- 13. Trend of total cases for a specific country (e.g., Cameroon)
SELECT date, total_cases
FROM covid_deaths
WHERE location = 'Cameroon'
ORDER BY date;

-- 14. Top 5 countries with most ICU patients on the latest date
SELECT location, icu_patients
FROM covid_deaths
WHERE date = (SELECT MAX(date) FROM covid_deaths)
  AND icu_patients IS NOT NULL
ORDER BY icu_patients DESC
LIMIT 5;

-- Total Cases vs Total Deaths

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
WHERE continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(cv.new_vaccinations) OVER (Partition by cd.location Order by cd.location, cd.date) as rolling_people_vaccinated
From covid_deaths AS cd
Join covid_vaccinations AS cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 
order by 2,3
 

SELECT * FROM covid_deaths;

-- Examning the the death percentage from the cases reported
-- Can add filters such as Location
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
FROM covid_deaths
WHERE total_cases != 0
ORDER BY location, total_cases;

-- Examning the the percentage of the population reported for covid
-- Can add filters such as Location
SELECT location, date, total_cases, population, (total_cases/population)*100 as cases_percentage
FROM covid_deaths
-- WHERE total_cases != 0
ORDER BY location, total_cases;

-- Examning the country with the highest infection rates with respect to their population
-- Can add filters such as Location
SELECT location, MAX(total_cases) as highest_infection_count, population, MAX((total_cases/population))*100 AS infection_rate
FROM covid_deaths
GROUP BY location, population
ORDER BY infection_rate DESC;

-- Examning the countries with highest death counts per population
-- Can add filters such as Location
SELECT location, MAX(total_deaths) as highest_death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY highest_death_count DESC;

-- Examning the continents with highest death counts per population
-- Can add filters such as Location
SELECT continent, MAX(total_deaths) as highest_death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY highest_death_count DESC;