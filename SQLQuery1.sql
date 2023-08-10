/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/



Select * 
FROM PortfolioProject ..CovidDeaths
WHERE continent is not null
order by 3,4;



-- Select Data that we are going to be starting with

Select location,date,total_cases,new_cases,total_deaths,population 
From PortfolioProject..CovidDeaths
order by 1,2;



--Total Cases vs Total Deaths 

--Shows likelihood of dying(Death Percentage) if you contract with Covid in your Country

--ALTER TABLE CovidDeaths
--ALTER COLUMN total_deaths float;

--ALTER TABLE CovidDeaths
--ALTER COLUMN total_cases float;

--ALTER TABLE CovidDeaths
--ADD DeathPercentage float;

--UPDATE CovidDeaths
--SET DeathPercentage=(total_deaths/total_cases)*100
--WHERE total_cases is not null and total_deaths is not null;

--SELECT total_cases,total_deaths,DeathPercentage FROM CovidDeaths;


Select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths
WHERE location like 'India' 
order by 1,2;


--TotalCases Vs Population
--Shows what percentage of population got Covid infected

Select location,date,population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
WHERE location like 'India' and total_cases is not null
order by 1,2;


--Countries with Highest Infection rate compared to Population

Select location, population,MAX(total_cases) as HighestInfectionRate , MAX(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
GROUP BY location,population
order by PercentPopulationInfected desc;


--Countries with Highest Death Count per Population


Select location, population,MAX(total_deaths) as TotalDeathCount 
From PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location,population
order by population desc,TotalDeathCount desc;


--LET'S BREAK DATA DOWN BY CONTINENT

--Showing contintents with the highest death count per population

Select CONTINENT,MAX(total_deaths) as TotalDeathCount 
From PortfolioProject..CovidDeaths
WHERE continent is NOT null
GROUP BY CONTINENT
order by TotalDeathCount desc;


--Continent Level Death_Percent today date due to Covid

Select continent,SUM(cast(new_deaths as float)) as Total_Deaths,SUM(cast(new_cases as float)) AS Total_Cases ,
(SUM(cast(new_deaths as float))/SUM(cast(new_cases as float)))*100 as Death_Percentage 
From PortfolioProject..CovidDeaths
WHERE continent is NOT null 
GROUP BY continent
--HAVING SUM(cast(new_cases as int)) <> 0
order by Death_Percentage desc;

--Global Level Death_Percent today date due to Covid

Select SUM(cast(new_deaths as float)) as Total_Deaths,SUM(cast(new_cases as float)) AS Total_Cases ,
(SUM(cast(new_deaths as float))/SUM(cast(new_cases as float)))*100 as Death_Percentage 
From PortfolioProject..CovidDeaths
WHERE continent is NOT null 
order by Death_Percentage desc;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float))  OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From CovidVaccinations as vac
Join CovidDeaths as dea
On dea.location=vac.location
and dea.date=vac.date
WHERE dea.continent is not null and vac.new_vaccinations is not null
--order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopVsVac  (Continent, Location, Date, Population ,New_Vaccinations, RollingPeopleVaccinated)
as
(Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float))  OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From CovidVaccinations as vac
Join CovidDeaths as dea
On dea.location=vac.location
and dea.date=vac.date
WHERE dea.continent is not null and vac.new_vaccinations is not null
--order by 2,3
)
Select * ,(RollingPeopleVaccinated /Population)*100 as Percentage
From PopVsVac;


-- Using Temp Table to perform Calculation on Partition By in previous query


Create Table #PercentPopulatedVaccination
(
  Continent nvarchar(255),
  Location nvarchar(255),
  Date datetime,
  Population numeric,
  New_vaccinations numeric,
  RollingPeopleVaccinated numeric
  )


  Insert into 
  Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float))  OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
From CovidVaccinations as vac
Join CovidDeaths as dea
On dea.location=vac.location
and dea.date=vac.date
WHERE dea.continent is not null and vac.new_vaccinations is not null
--order by 2,3

Select * ,(RollingPeopleVaccinated /Population)*100 as Percentage
From #PercentPopulatedVaccination;


-- Creating view to store data for later Visualisations

Create View  PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float))  OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
From CovidVaccinations as vac
Join CovidDeaths as dea
On dea.location=vac.location
and dea.date=vac.date
WHERE dea.continent is not null and vac.new_vaccinations is not null
--order by 2,3

Select * FROM
PercentPopulationVaccinated;
