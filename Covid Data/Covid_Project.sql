

use Covid_portfolio

/*Covid-19 Data Exploration*/

Select * From CovidDeaths
Where continent is not null 
order by 3,4

-- Select Data that we are going to be starting with
Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases,total_deaths, (total_deaths/total_cases) * 100 as DeathsPercentage
From CovidDeaths
where location like '%Pakistan'
and continent is not null
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of people is infected with covid
Select location,date,total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
order by 1,2

-- Countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Group by location, population
order by PercentPopulationInfected desc

--Showing countries with highest death count per population
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by location
order by TotalDeathCount desc

-- GLOBAL NUMBERS
-- Calaculating Total cases, Total deaths and death percentage globally 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null 
--Group By date
order by 1,2


-- Looking at Total population vs Vaccination
Select d.continent, d.location, d.date,d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
From CovidDeaths d
Join CovidVaccinations v
	ON d.location = v.location
	and d.date = v.date
where d.continent is not null 
order by 2,3

--Using CTE to perform Calculation on Partition By in previous query
With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
Select d.continent, d.location, d.date,d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
From CovidDeaths d
Join CovidVaccinations v
	ON d.location = v.location
	and d.date = v.date
where d.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100 
FROM PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select d.continent, d.location, d.date,d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
From CovidDeaths d
Join CovidVaccinations v
	ON d.location = v.location
	and d.date = v.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select d.continent, d.location, d.date,d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
From CovidDeaths d
Join CovidVaccinations v
	ON d.location = v.location
	and d.date = v.date
where d.continent is not null  