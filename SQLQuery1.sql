Select * 
FROM PortfolioProject ..CovidDeaths
WHERE continent is not null
order by 3,4;


--Select * 
--From PortfolioProject..CovidVaccinations
--order by 3,4;

--Select location,date,total_cases,new_cases,total_deaths,population 
--From PortfolioProject..CovidDeaths
--order by 1,2;
USE PortfolioProject;


--Looking at total cases/total deaths in percent

--Show likelihood of dying(Death Percentage) if you contract with Covid in your Country

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


Select location,date,total_cases,total_deaths,DeathPercentage, (total_deaths/total_cases)*100 as Percentage
From PortfolioProject..CovidDeaths
WHERE location like 'India' 
order by 1,2;


--Looking at TotalCases Vs Population
--Shows what percentage of population got Covid

Select location,date,population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
WHERE location like 'India' and total_cases is not null
order by 1,2;


--Looking at countries with Highest Infection rate compared to Population

Select location, population,MAX(total_cases) as HighestInfectionRate , MAX(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
GROUP BY location,population
order by PercentPopulationInfected desc;


--Show countries with Highest Death Count


Select location, population,MAX(total_deaths) as TotalDeathCount 
From PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location,population
order by population desc,TotalDeathCount desc;


--LET'S BREAK DATA DOWN BY CONTINENT

Select CONTINENT,MAX(total_deaths) as TotalDeathCount 
From PortfolioProject..CovidDeaths
WHERE continent is NOT null
GROUP BY CONTINENT
order by TotalDeathCount desc;


--WORLD LEVEL DATA ANALYSATION 

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


--Covid Vaccination and CovidDeaths Data Analysation
--Select * from CovidVaccinations;
Select dea.continent,dea.date,SUM(cast(vac.new_vaccinations as int)) as Total_Vaccinations
From CovidVaccinations as vac
Join CovidDeaths as dea
On dea.location=vac.location
and dea.date=vac.date
WHERE dea.continent is not null and vac.new_vaccinations is not null
GROUP BY dea.date,dea.continent 
order by dea.continent ASC,Total_Vaccinations desc;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

--Using CTE to perform Calculation on Partition By in previous query

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

--TEMP TABLE

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

--Creating view to store data for later Visualisations

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