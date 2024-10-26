-- EDA on COVID Data

SELECT *
FROM PortfolioProject..CovidDeaths
--WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Select Data that will be used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS MortalityRate
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS MortalityRate
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Max Mortality rate in the US?

SELECT MAX (total_deaths/total_cases)*100 AS MortalityRate
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'

--Mortality Rate in the US by date?

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS MortalityRate
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 5 DESC

--Looking at Total Cases vs Population
--Percentage of the Population Infected

SELECT location, date, total_cases, population, (total_cases/population)*100 AS InfectionRate
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

SELECT location, date, total_cases, population, (total_cases/population)*100 AS InfectionRate
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at Countries with the Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectionRate
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC

--Countries with the highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS INT)) As TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY TotalDeathCount DESC

--Breaking things down by continent

--SELECT location, MAX(CAST(total_deaths AS INT)) As TotalDeathCount
--FROM PortfolioProject..CovidDeaths
--WHERE continent IS NULL
--GROUP BY location
--ORDER BY TotalDeathCount DESC

--Continents with the highest Death Count per Population

SELECT continent, MAX(CAST(total_deaths AS INT)) As TotalDeathCount
FROM PortfolioProject..CovidDeaths
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global numbers

SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS TotalMortalityRate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS TotalMortalityRate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL

--Looking at the Vaccinations table

SELECT *
FROM PortfolioProject..CovidVaccinations

--Joining the two tables

SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

--Total Population Vaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPopulationVaccinated
, --(RollingPopulationVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Using CTE

WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPopulationVaccinated
 --,(RollingPopulationVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS RollingPercentVaccinated
FROM PopVsVac

--TEMP TABLE (different solution)

DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPopulationVaccinated
 --,(RollingPopulationVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 AS RollingPercentVaccinated
FROM PercentPopulationVaccinated

--Creating a View to play with in Tableau

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPopulationVaccinated
 --,(RollingPopulationVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated

--Making some more views for vizualization