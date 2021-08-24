SELECT * FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--select * from PortfolioProject..CovidVaccinations
--order by 3,4

-- Selecting Data
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths 
ORDER BY 1,2

-- Total Cases vs Deaths (in Australia)
-- Likelihood of dying if contracted with covid in Australia (DeathPercentage)
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths 
WHERE location like '%stralia%'
ORDER BY 1,2 


-- Total Cases vs Population
SELECT location, date, total_cases, population, ROUND((total_cases/population)*100,5) as CasesPercentage
FROM PortfolioProject..CovidDeaths 
--WHERE location like '%stralia%'
ORDER BY 1,2 


-- Most affected countries copared to population 

SELECT location, population , MAX(total_cases) AS HighestAffectedCount, ROUND(MAX(total_cases/population)*100,5) AS AffectedPercentage
FROM PortfolioProject..CovidDeaths 
--WHERE location like '%stralia%'
GROUP BY location, population
ORDER BY AffectedPercentage DESC



-- Countries with highest death count vs population.

SELECT location, MAX(CAST(total_deaths as INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths 
WHERE continent is not null
--WHERE location like '%stralia%'
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Continent wise 



-- Showing the continents with the heighest death counts
SELECT continent, MAX(CAST(total_deaths as INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths 
WHERE continent is not null
--WHERE location like '%stralia%'
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS (Across the world)
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths 
--WHERE location like '%stralia%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2 


--Overall 
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths 
--WHERE location like '%stralia%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2 

--212064171 cases, 4432503 deaths overall 2.09%


-- Joining the tables

SELECT *
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vac
ON death.location = vac.location
AND death.date = vac.date


--Looking at Total Population vs vaccination
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated --Rolling Count 
-- We cant use the variable just created, hence using CTE or Temp table  
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE death.continent is not null
ORDER BY 2,3


-- USING CTE
WITH PopulationVsVaccination(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated --Rolling Count 
-- We cant use the variable just created, hence using Temp table  
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE death.continent is not null
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/population) *100 AS RollingPeopleVaccinatedPercentage
FROM PopulationVsVaccination



-- USING TEMP table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated --Rolling Count 
-- We cant use the variable just created, hence using Temp table  
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE death.continent is not null
--ORDER BY 2,3


Select *, (RollingPeopleVaccinated/population) *100 AS RollingPeopleVaccinatedPercentage
FROM #PercentPopulationVaccinated



--Creating View to store data for later visualizations

CREATE View PercentPopulationVaccinated AS
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated --Rolling Count 
-- We cant use the variable just created, hence using Temp table  
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE death.continent is not null
--ORDER BY 2,3

