SELECT *
FROM ProtfolioProject..CovidDeaths
Where continent is not null
ORDER BY 3,4

--SELECT *
--FROM ProtfolioProject..CovidVaccination
--ORDER BY 3,4

--Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM ProtfolioProject..CovidDeaths
ORDER BY 1,2



--Looking at Total cases vs total deaths
-- Shows liklihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM ProtfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


-- looking at total cases vs population
-- shows what percentage of population got covid
SELECT Location, date, population, total_cases,  (total_cases/population)*100 as PopulationCovidPercentage
FROM ProtfolioProject..CovidDeaths
--WHERE location = 'Yemen'
ORDER BY 1,2


-- looking at countries with highest infection rate compared to population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentPopulationInfected
FROM ProtfolioProject..CovidDeaths
--WHERE location = 'Yemen'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- showing countries with highest deathcount per population
SELECT Location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM ProtfolioProject..CovidDeaths
--WHERE location = 'Yemen'
Where continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--breaking things down by continent 

-- showing countries with highest deathcount per population



SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM ProtfolioProject..CovidDeaths
--WHERE location = 'Yemen'
Where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Global numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM ProtfolioProject..CovidDeaths
Where continent is not null
--Group by date
ORDER BY 1,2

-- use CTE

with popvsvac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as (

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER ( PARTITION BY dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 you cant us an alias right away here
FROM ProtfolioProject..CovidDeaths dea
Join ProtfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select *,(RollingPeopleVaccinated/population)*100 
From popvsvac

-- TEMP table

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER ( PARTITION BY dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 you cant us an alias right away here
FROM ProtfolioProject..CovidDeaths dea
Join ProtfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

Select *,(RollingPeopleVaccinated/population)*100 
From #PercentPopulationVaccinated


--Creating view to store data for visualizations
Create view PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER ( PARTITION BY dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 you cant us an alias right away here
FROM ProtfolioProject..CovidDeaths dea
Join ProtfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

Select *
From PercentPopulationVaccinated
