SELECT * FROM project..CovidDeaths
where continent is not null
order by 3,4

SELECT * FROM project..CovidVaccinations
order by 3,4

SELECT location,date,total_cases,new_cases, total_deaths, population
FROM project..CovidDeaths
where continent is not null
order by 1,2

-- shows likelihood of death if you contact covid
SELECT location,date,total_cases,total_deaths,
        CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)* 100 AS death_percentage
FROM project..CovidDeaths
where location like '%states%' and continent is not null
order by 1,2

-- shows what percentage of population got covid
SELECT location,date,total_cases,population,
        (CAST(total_deaths AS FLOAT) /population )* 100 AS infected_percentage
FROM project..CovidDeaths
where continent is not null
--where location like '%states%'
order by 1,2

-- Highest Infection rate compared to population
SELECT location,population, MAX(total_cases) as highestcount,
        MAX((CAST(total_deaths AS FLOAT) /population ))* 100 AS infected_percentage
FROM project..CovidDeaths
--where location like '%states%'
where continent is not null
GROUP by location,population
order by infected_percentage desc

-- Highest Death count per population
SELECT continent, MAX(total_deaths) as deathcount
FROM project..CovidDeaths
where continent is not null
GROUP by continent
order by deathcount desc

SELECT location, MAX(total_deaths) as deathcount
FROM project..CovidDeaths
where continent is null
GROUP by location
order by deathcount desc


SELECT SUM(new_cases) as totalcases ,SUM(new_deaths) as totaldeaths, 
SUM(new_deaths)/SUM(new_cases) * 100 as deathpercent 
FROM project..CovidDeaths
where continent is not null
--GROUP by date
order by 1,2


DROP TABLE if exists #percentvaccinated
CREATE TABLE #percentvaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date DATE,
population NUMERIC,
new_vaccinations NUMERIC,
peoplevaccinated NUMERIC
)

INSERT into #percentvaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(cast(v.new_vaccinations as int)) OVER (partition by d.location order by d.location, d.date) as peoplevaccinated
from project..CovidDeaths d 
join project..CovidVaccinations v on d.location = v.location and d.date = v.date
where d.continent is not null


select *, (peoplevaccinated/population)* 100 as percents
FROM #percentvaccinated


-- create view o store data for visulizations
DROP VIEW IF EXISTS percentvaccinated;
GO
CREATE VIEW percentvaccinated AS
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(cast(v.new_vaccinations as int)) OVER (partition by d.location order by d.location, d.date) as peoplevaccinated
from project..CovidDeaths d 
join project..CovidVaccinations v on d.location = v.location and d.date = v.date
where d.continent is not null
GO