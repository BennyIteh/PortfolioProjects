SELECT * 
FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Looking at the Total cases vs Total Deaths (DeathPercentage)
-- Shows the likelihood of you dying if contract Covid-19 in your country
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Nigeria%'
and continent is not null
ORDER BY 1,2

--Looking at the Total cases vs The Population
-- Shows what percentage of population got Covid
SELECT location, date, population, total_cases, (total_cases / population) * 100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2 

--Looking at countries with infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases / population)) * 100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC 

--Showing countries with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Breakdown by Continent
--Showing the continents with the highest Death Count
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Global Numbers
--Total Numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Nigeria%'
WHERE continent is not null
ORDER BY 1,2 

--Total Numbers by Date
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Nigeria%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2 

--Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--USE CTE
With PopsVac(Conitnent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT * , (RollingPeopleVaccinated / population) * 100
from PopsVac


--USE TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT * , (RollingPeopleVaccinated / population) * 100
from #PercentPopulationVaccinated


--Creating View to store for later Visualization
CREATE VIEW PercentPopulationVaccinated
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated