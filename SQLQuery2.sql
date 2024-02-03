select *
from portfolio_project..coviddeaths
order by 3,4

--select *
--from portfolio_project..covidvacsinations
--order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from portfolio_project..coviddeaths
order by 1,2

--total caces vs total deaths

use portfolio_project

EXEC sp_help 'dbo.coviddeaths'

alter table dbo.coviddeaths
alter column total_deaths float

alter table dbo.coviddeaths
alter column total_cases float

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as deaths_persentage
from portfolio_project..coviddeaths
where location like '%Pakistan%'
order by 1,2


--total caeses vs population

select location,date,total_cases,population, 
round((total_cases/population)*100,2) as positive_population_rate
from portfolio_project..coviddeaths
where location like '%Pakistan%'
order by 1,2

--countries with highest infection rate

select location,population,MAX(total_cases) AS HIGHEST_RATE , 
max((total_cases/population))*100 as positive_population_rate
from portfolio_project..coviddeaths
--where location like '%Pakistan%'
group by population,location
order by positive_population_rate desc

--countries with highest death count per population

select location,max(total_deaths) as total_death_count
from portfolio_project..coviddeaths
--where location like '%Pakistan%'
where continent is not null
group by location
order by total_death_count desc

-- by continents

select location,max(total_deaths) as total_death_count
from portfolio_project..coviddeaths
--where location like '%Pakistan%'
where continent is null
group by location
order by total_death_count desc

--continents with highest death rate

select continent,max(total_deaths) as total_death_count
from portfolio_project..coviddeaths
--where location like '%Pakistan%'
where continent is not null
group by continent
order by total_death_count desc


--globaly

select date,sum(new_cases) as total_cases,sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as deaths_persentage
from portfolio_project..coviddeaths
--where location like '%Pakistan%'
where continent is not null
group by date
order by 1,2

--grand total 


select sum(new_cases) as total_cases,sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as deaths_persentage
from portfolio_project..coviddeaths
--where location like '%Pakistan%'
where continent is not null
--group by date
order by 1,2

--total population vs vacinated

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from portfolio_project..coviddeaths dea
join portfolio_project..covidvacsinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use cte

with popvsvac (continent,location,date,population,new_vaccination,rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from portfolio_project..coviddeaths dea
join portfolio_project..covidvacsinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(rollingpeoplevaccinated/population)*100
from popvsvac


--temp table
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from portfolio_project..coviddeaths dea
join portfolio_project..covidvacsinations vac
on dea.location = vac.location and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *,(rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated

--creating view to store data for later visualizations 

create view percentpopulationvaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from portfolio_project..coviddeaths dea
join portfolio_project..covidvacsinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from percentpopulationvaccinated

