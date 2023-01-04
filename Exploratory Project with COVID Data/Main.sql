/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions,
Creating Views, Converting Data Types
*/

Select *
From Project_Covid_DataBase..CovidDeaths
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From Project_Covid_DataBase..CovidDeaths
Where continent is not null 
order by 1,2

--changing data types of columns
SELECT * INTO backup_CovidDeaths
FROM Project_Covid_DataBase..CovidDeaths;

UPDATE CovidDeaths
SET total_deaths = convert(int,replace(total_deaths, '.0',''))

ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths INT;

UPDATE CovidDeaths
SET total_cases = convert(int,replace(total_cases, '.0',''))

ALTER TABLE CovidDeaths
ALTER COLUMN total_cases INT;

UPDATE CovidDeaths
SET population = convert(FLOAT,replace(population, '.0',''))

ALTER TABLE CovidDeaths
ALTER COLUMN population FLOAT;

UPDATE CovidDeaths
SET new_deaths = convert(float,replace(new_deaths, '.0',''))

ALTER TABLE CovidDeaths
ALTER COLUMN new_deaths float;

UPDATE CovidDeaths
SET new_cases = convert(float,replace(new_cases, '.0',''))

ALTER TABLE CovidDeaths
ALTER COLUMN new_cases float;

UPDATE CovidVaccinations
SET new_vaccinations = convert(float,replace(new_vaccinations, '.0',''))

ALTER TABLE CovidVaccinations
ALTER COLUMN new_vaccinations float;

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, 
(total_deaths)/(total_cases) * 100 as DeathPercentage
From Project_Covid_DataBase..CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population got infected with Covid

Select Location, date, Population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
From Project_Covid_DataBase..CovidDeaths
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Project_Covid_DataBase..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(Total_deaths) as TotalDeathCount
From Project_Covid_DataBase..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(Total_deaths) as TotalDeathCount
From Project_Covid_DataBase..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select date, SUM(new_cases), SUM(new_deaths), 
round((SUM(new_deaths)/SUM(new_cases)*100), 2) as 
DeathPercentage
From Project_Covid_DataBase..CovidDeaths
where continent is not null 
group by date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has received at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER
(Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Project_Covid_DataBase..CovidDeaths as dea
Join Project_Covid_DataBase..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
From Project_Covid_DataBase..CovidDeaths dea
Join Project_Covid_DataBase..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Project_Covid_DataBase..CovidDeaths dea
Join Project_Covid_DataBase..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100 as Percentage_of_RolPeopleVac
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

drop view PercentPopulationVaccinated;
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER 
(Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Project_Covid_DataBase..CovidDeaths dea
Join Project_Covid_DataBase..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

SELECT * FROM PercentPopulationVaccinated
