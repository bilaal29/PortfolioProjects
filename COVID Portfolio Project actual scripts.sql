SELECT *
FROM PortfolioProject..CovidDeaths$
Where continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
Where continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
where location like '%states%'and continent is not null
ORDER BY 1,2

SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths$
where location like '%nigeria%' and continent is not null

-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID
SELECT location, date,population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths$
--where location like '%NIGERAI%'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location,population, MAX(total_cases) AS HighestInfectionCount, Max(total_cases/population)*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths$
--where location like '%NIGERAI%'
Group by Location, population
ORDER BY PercentagePopulationInfected desc


-- Showing Countries with Highest Death Count per Popuation

SELECT location, MAX (Cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--where location like '%NIGERAI%'
Where continent is null
Group by Location
ORDER BY TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX (Cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--where location like '%NIGERAI%'
Where continent is not null
Group by continent
ORDER BY TotalDeathCount desc

--SHOWING THE CONTINENT WITH THE HIGHEST DEATH COUNT PER POPULATION

SELECT continent, MAX (Cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--where location like '%NIGERAI%'
Where continent is not null
Group by continent
ORDER BY TotalDeathCount desc



--GLOBAL NUMBER

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--where location like '%states%'
WHERE continent is not null
--GROUP BY DATE
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to store data  for later visualizations

Create View PercentPopolationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopolationVaccinated