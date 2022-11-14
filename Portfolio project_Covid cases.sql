-- Displaying the tables imported from excel

Select *
From [portfolio project]..CovidDeaths
where continent is not null

Select *
From [portfolio project]..CovidVaccinations
where continent is not null

-- Finding total cases vs deaths
-- Finding likelihood of dying if we get covid in our country

Select location, date, population, total_cases, total_deaths,(total_deaths/total_cases)*100 as Deathspercentage
From [portfolio project]..CovidDeaths
where continent is not null
--and location = 'India'
order by 1, 2

-- Finding total cases vs population
-- Finding likelihood of getting covid in our country

Select location, date, population, total_cases, (total_cases/population)*100 as Infectionspercentage
From [portfolio project]..CovidDeaths
where continent is not null
--and location = 'India'
order by 1, 2

-- Finding countries with highest infection rate

Select location, population, MAX(total_cases/population)*100 as Infectionspercentage
From [portfolio project]..CovidDeaths
where continent is not null
-- and location = 'India'
group by location, population
order by 3 desc

-- Finding countries with highest death rate

Select location, population, MAX(cast(total_deaths as int)) as maxdeaths, MAX(cast(total_deaths as int)/population)*100 as deathspercentage
From [portfolio project]..CovidDeaths
where continent is not null
-- and location = 'India'
group by location, population
order by 3 desc

-- Finding continents with highest death rate

Select continent, MAX(cast(total_deaths as int)) as maxdeaths, MAX(cast(total_deaths as int)/population)*100 as deathspercentage
From [portfolio project]..CovidDeaths
where continent is not null
-- and location = 'India'
group by continent
order by 2 desc

-- Finding continents with highest deathcount per population

Select continent, MAX(cast(total_deaths as int)) as maxdeaths, MAX(cast(total_deaths as int)/population)*100 as deathspercentage
From [portfolio project]..CovidDeaths
where continent is not null
-- and location = 'India'
group by continent
order by 3 desc

-- Global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as total_death_percent
From [portfolio project]..CovidDeaths
where continent is not null
--and location = 'India'
--group by date
order by 1, 2

-- Joining deaths and vaccinations table using location and date columns

Select *
From [portfolio project]..CovidDeaths dea
join [portfolio project]..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date


-- Finding population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From [portfolio project]..CovidDeaths dea
join [portfolio project]..CovidVaccinations vac
    on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- Finding population vs rolling count of new vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingvaccinationscount
From [portfolio project]..CovidDeaths dea
join [portfolio project]..CovidVaccinations vac
    on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- Using temp table for population vs vaccinations

Drop table if exists #popvsvac
Create table #popvsvac
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingvaccinationscount numeric
)

insert into #popvsvac
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingvaccinationscount
From [portfolio project]..CovidDeaths dea
join [portfolio project]..CovidVaccinations vac
    on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
-- order by 2, 3
Select *
From #popvsvac

-- Creating views for visualizations later

Create view populationvaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingvaccinationscount
From [portfolio project]..CovidDeaths dea
join [portfolio project]..CovidVaccinations vac
    on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
-- order by 2, 3

Select *
From #popvsvac