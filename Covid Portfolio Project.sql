select *
from PortfolioProject..CovidDeaths2
order by 3,4

-- select * from PortfolioProject..CovidVaccinations
-- order by 3,4

-- Select data that we are going to be using
Select Location, date, total_cases, New_cases, total_deaths, population
From PortfolioProject..CovidDeaths2
Order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Asia
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths2
Where location = 'asia'
and continent is not null
Order by 1,2


-- Looking at total cases vs population
-- Shows percentage of population who contracted covid
Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths2
Where location = 'asia'
Order by 1,2

-- Looking at countries with highest infection rate compared to population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths2
Group by location, population
Order by PercentPopulationInfected desc


-- Showing countries with Highest death count per population
Select Location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths2
where continent is not null
Group by location
Order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with highest death count per population

Select continent, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths2
where continent is not null
Group by continent
Order by TotalDeathCount desc


-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths2
where continent is not null
order by 1,2


-- Looking at Total Population vs Vaccinations
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths2 dea
join PortfolioProject..CovidVaccinations vac
    on dea.location=vac.location
    and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths2 dea
join PortfolioProject..CovidVaccinations vac
    on dea.location=vac.location
    and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP TABLE
Create TABLE #PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
)

Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths2 dea
join PortfolioProject..CovidVaccinations vac
    on dea.location=vac.location
    and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store date for later visualisations
Create view PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths2 dea
join PortfolioProject..CovidVaccinations vac
    on dea.location=vac.location
    and dea.date=vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated