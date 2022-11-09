Select * from CovidDeaths
order by 3,4

select * from CovidVaccinations
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

-- what percentage of total cases were total deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location = 'India'
order by 1,2

-- what percentage of population got covid
Select location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
from CovidDeaths
where location = 'India'
order by 1,2

-- Infection Rate compared to population per country
Select location, MAX(population) as TotalPopulation, MAX(total_cases) as TotalCases, (MAX(total_cases)/MAX(population))*100 as InfectedRatePercentage
from CovidDeaths
group by location
order by InfectedRatePercentage desc

-- Death rate compated to population per country
Select location, MAX(population) as TotalPopulation, MAX(CAST(total_deaths as int)) as TotalDeaths, (MAX(total_deaths)/MAX(population))*100 as DeathRatePercentage
from CovidDeaths
group by location
order by DeathRatePercentage desc

-- Countries with death count
Select location, Max(Cast(total_deaths as int)) as TotalDeaths
From CovidDeaths
where continent is not null
group by location
order by TotalDeaths desc

-- Continents with death count
Select location, Max(Cast(total_deaths as int)) as TotalDeaths
From CovidDeaths
where continent is null and location not like '%income%'
group by location
order by TotalDeaths desc

-- Global Numbers
Select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) TotalDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from CovidDeaths

-- join deaths with vaccinations
Select *
from [dbo].[CovidDeaths] dea
join [dbo].[CovidVaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
order by 3,4

-- Total Population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
from [dbo].[CovidDeaths] dea
join [dbo].[CovidVaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3