select * 
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select *
from PortfolioProject..CovidVaccinations
where continent is not null
order by 3,4

-- select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- looking at the total cases vs total deaths

 --shows the likelihood of dying if you contract the coronavirus in your country
select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

-- looking at the total cases vs population
-- shows what percentage of population got covid

--select location, date, total_cases, Population, (total_cases/population)*100 as percentpopulationinfected
--from PortfolioProject..CovidDeaths	
----where location like '%states%'
--order by 1,2

---- looking at countries with highest infection rate compared to population

select location, MAX(total_cases) as HighestInfectionCount, Population, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths	
--where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc

-- showing the counries with the highest death count per population

select location, MAX(cast(total_Deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths	
--where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc

-- lets break things down by continent
-- showing continents with the highest death count per population

select continent, MAX(cast(total_Deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths	
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- global numbers

select sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

--looking at total population vs vaccinatios

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)* 100
from PopvsVac



--use cte

-- temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

select *, (RollingPeopleVaccinated/Population)* 100
from #PercentPopulationVaccinated



--creating view to store data for later visualizations

Create View PercentPopulationVaccinated as 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated