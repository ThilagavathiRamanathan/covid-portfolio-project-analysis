Select *
From portfolio_project..['covid death$']
order by 3,4

---Select *
---From portfolio_project..['covid vaccinations$']
---order by 3,4

--select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
From portfolio_project..['covid death$']
order by 1,2

--looking total cases and total deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
From portfolio_project..['covid death$']
order by 1,2
---looking for selected country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
From portfolio_project..['covid death$']
--where location like '%India%'
--where total_deaths is not null
order by 1,2

--looking at total cases vs population
select location, date, total_cases, Population, (total_deaths/population)*100 as case_percentage
From portfolio_project..['covid death$']
where location like '%India%'
order by 1,2

---looking at countries with highest infection rate compares to population
select location, MAX(total_cases) as Highest_infection_count, Population, MAX((total_cases/population))*100 as case_percentage
From portfolio_project..['covid death$']
--where location like '%India%'
group by location,population
order by case_percentage desc

--looking countries with highest death count per population
select location, MAX(cast(total_cases as int)) as totaldeathcount
From portfolio_project..['covid death$']
--where location like '%India%'
where continent is not null
group by location,population
order by totaldeathcount desc


--lets break things down by location
select location, MAX(cast(total_cases as int)) as totaldeathcount
From portfolio_project..['covid death$']
--where location like '%India%'
where continent is not null
group by location
order by totaldeathcount desc  

---by continent

select continent, MAX(cast(total_cases as int)) as totaldeathcount
From portfolio_project..['covid death$']
--where location like '%India%'
where continent is not null
group by continent
order by totaldeathcount desc



----GLOBAL NUMBERS

select date, SUM(new_cases) as sumofcase, SUM(cast(new_deaths as int)) as sumofdeath--total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
From portfolio_project..['covid death$']
--where location like '%India%'
where continent is not null
group by date 
order by 1,2

---in percentage
select SUM(new_cases) as sumofcase, SUM(cast(new_deaths as int)) as sumofdeath , 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_percentage
From portfolio_project..['covid death$']
--where location like '%India%'
where continent is not null
--group by date
order by 1,2

----using joins

select *
from portfolio_project..['covid death$'] as dea
join portfolio_project..['covid vaccinations$'] as vac
on dea.location = vac.location
and dea.date = vac.date


------looking at total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from portfolio_project..['covid death$'] as dea
join portfolio_project..['covid vaccinations$'] as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

---adding how many people get vaccination day by day

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) over (PARTITION by dea.location order by dea.location, dea.date) as Rolling_count 
from portfolio_project..['covid death$'] as dea
join portfolio_project..['covid vaccinations$'] as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.location like '%India%'
--where dea.continent is not null
order by 2,3

--how many people get vaccinated(USE CTE)

with popvsvac (continent, location, date, population, new_vaccinations, Rolling_count)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) over (PARTITION by dea.location order by dea.location, dea.date) as Rolling_count 
--(Rolling_count/population)*100
from portfolio_project..['covid death$'] as dea
join portfolio_project..['covid vaccinations$'] as vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.location like '%India%'
where dea.continent is not null
--order by 2,3
)
select *,(Rolling_count/population)*100 from popvsvac as vac_percentage


--TEMP TABLE

DROP Table if exists #percentpopulationvaccinated
Create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
new_vaccinations numeric,
Rolling_count numeric,
population numeric
)
Insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) over (PARTITION by dea.location order by dea.location, dea.date) as Rolling_count 
--(Rolling_count/population)*100
from portfolio_project..['covid death$'] as dea
join portfolio_project..['covid vaccinations$'] as vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.location like '%India%'
where dea.continent is not null
--order by 2,3
select *,(Rolling_count/population)*100 from #percentpopulationvaccinated



---creating view to store data for later visualization
create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) over (PARTITION by dea.location order by dea.location, dea.date) as Rolling_count 
--(Rolling_count/population)*100
from portfolio_project..['covid death$'] as dea
join portfolio_project..['covid vaccinations$'] as vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.location like '%India%'
where dea.continent is not null
--order by 2,3

select * from percentpopulationvaccinated












































 


























