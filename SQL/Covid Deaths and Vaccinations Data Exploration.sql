-- checking data within the tables
Select * from CovidDeaths
Where continent is not null 
order by 3,4

select * from CovidVaccinations
Where continent is not null 
order by 3,4

-- check data the we are going to work with
Select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
Where continent is not null 
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location = 'India'
and continent is not null 
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
Select location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
from CovidDeaths
--where location = 'India'
order by 1,2

-- Countries with Highest Infection Rate compared to Population
Select location, MAX(population) as TotalPopulation, MAX(total_cases) as TotalCases, (MAX(total_cases)/MAX(population))*100 as InfectedRatePercentage
from CovidDeaths
group by location, population
order by InfectedRatePercentage desc

-- Countries with Highest Death Count per Population
Select location, MAX(population) as TotalPopulation, MAX(CAST(total_deaths as int)) as TotalDeaths, (MAX(total_deaths)/MAX(population))*100 as DeathRatePercentage
from CovidDeaths
where continent is not null 
group by location
order by DeathRatePercentage desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
Select continent, Max(Cast(total_deaths as int)) as TotalDeaths
From CovidDeaths
where continent is not null
group by continent
order by TotalDeaths desc


-- Global Numbers
Select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) TotalDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from CovidDeaths
where continent is not null 
order by 1,2

-- join deaths with vaccinations
Select *
from [dbo].[CovidDeaths] dea
join [dbo].[CovidVaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
order by 3,4

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as int)
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
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
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated  --int was not possible as dat was too large, hence used bigint
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

DROP VIEW PercentPopulationVaccinated;
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select * from PercentPopulationVaccinated;