Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4


--Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Total Cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%Philippines%'
ORDER BY 1,2

-- Total Cases vs Population
-- %  of Population got Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 as case_percentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%Philippines%'
ORDER BY 1,2

-- Highest Infection Rate
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/population)*100 as InfectedRate
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY InfectedRate DESC

SELECT Location, date, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/population)*100 as InfectedRate
FROM PortfolioProject..CovidDeaths
GROUP BY location, population, date
ORDER BY 1,2

-- Highest Death Count by Location
SELECT location, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY HighestDeathCount DESC

-- Highest Death Count by Continent
SELECT continent, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY HighestDeathCount DESC

-- Highest Death Count by Continent
SELECT continent, 
		SUM(CAST(total_deaths AS INT)) AS totalDeaths, 
		SUM(population) as totalPopulation,
		(SUM(CAST(total_deaths AS INT))/SUM(population))*100 AS TotalDeathsPerPopulation
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent


-- Global Numbers
SELECT SUM(CAST(new_cases AS INT)) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths,
		(SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS DeathRate
From PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2

--Total Death Count
SELECT continent, SUM(cast(new_deaths as int)) as TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeaths DESC


-- Total Population vs Vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(float, vac.new_vaccinations)) OVER 
		(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Using Common Table Expression 
WITH
	VaccsPerPopulation (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
	AS
	(
		SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
			SUM(CONVERT(float, vac.new_vaccinations)) OVER 
			(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
		FROM PortfolioProject..CovidDeaths dea
		JOIN PortfolioProject..CovidVaccinations vac
			ON dea.location = vac.location
			AND dea.date = vac.date
		WHERE dea.continent IS NOT NULL
	)
SELECT *, (RollingPeopleVaccinated/population)*100 AS VaccsPercentage
FROM VaccsPerPopulation
ORDER BY 1,2


-- Moving data to TEMP/New table

DROP TABLE IF EXISTS #PercentPopulationVaccinated

--CREATE THE TABLE
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

--Insert the DATA
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(float, vac.new_vaccinations)) OVER 
		(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

--Show the DATA
SELECT *, (RollingPeopleVaccinated/population)*100 AS VaccsPercentage
FROM #PercentPopulationVaccinated
ORDER BY 1,2




CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(float, vac.new_vaccinations)) OVER 
		(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


 