SELECT *
FROM PortfolioProject..CovidDeaths
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population FROM PortfolioProject..CovidDeaths

--Total cases vs total deaths
-- Probability of dying if you get a Covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage FROM PortfolioProject..CovidDeaths
WHERE location like '%Poland%'
ORDER BY 1,2

--Total cases vs population
SELECT location, date, total_cases, total_deaths, (total_cases/population)*100 AS DeathPercentage  FROM PortfolioProject..CovidDeaths
WHERE location like '%Poland%'
ORDER BY 1,2

--Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) AS PercentagePopulationInfected  FROM PortfolioProject..CovidDeaths
GROUP BY  population, Location
ORDER BY PercentagePopulationInfected desc

--Countries with highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount  FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY  Location
ORDER BY TotalDeathCount desc

--Countries with highest death count per population by continent

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount  FROM PortfolioProject..CovidDeaths
WHERE continent is NULL
GROUP BY  location
ORDER BY TotalDeathCount desc

--Total cases and deaths
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Total population vs vaccinations
SELECT dea.continent, dea.location, vac.new_vaccinations, dea.date, dea.population,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY  dea.location, dea.date) AS PeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL 
ORDER BY 1,2

--Using CTE
WITH PopvsVac( Continent, location, date, population, new_vaccinations, PeopleVaccinated)
AS
(
SELECT dea.continent, dea.location,dea.date, dea.population,  vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY  dea.location, dea.date) AS PeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL 
)
SELECT *,  ((PeopleVaccinated/population)*100) AS percentage
FROM PopvsVac


--temp table
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date  datetime,
Population numeric,
new_vaccinations numeric,
PeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location,dea.date, dea.population,  vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY  dea.location, dea.date) AS PeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL 

SELECT *,  ((PeopleVaccinated/population)*100) AS percentage
FROM #PercentPopulationVaccinated


--Creating view
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location,dea.date, dea.population,  vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY  dea.location, dea.date) AS PeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL

SELECT * FROM PercentPopulationVaccinated

