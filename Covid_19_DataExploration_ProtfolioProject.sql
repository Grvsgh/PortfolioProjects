/*
Covid-19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4


-- Selecting Data that we are going to be start working with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2


--Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%india%'
and continent is not null 
order by 1,2
-- Result of above query based on data present till 7th october 2021 DeathPercentage is about 1.32% in India



-- Total Cases vs Population
-- Shows what percentage of population infected in India with Covid
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%india%'
order by 1,2
-- The result of above query based on data present till 7th october 2021. 
--Total percernt of indian population is infected with covid is about 2.43%



-- Countries with Highest Infection Rate compared to Population.
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%India%'
Group by Location, Population
order by PercentPopulationInfected desc
-- India ranks 115th based on data present till 10th october 2021.
--With infection rate of 2.43% as compared to Population of our counrty.
--Where as total no of cases in India till 7th october 2021 Count as 33915569.




-- Countries with Highest Death Count per Population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%india%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc
-- Result of above query based on data present till 7th October 2021.
-- U.S ranks First in TotalDeathCount - 710173
-- India Ranks Third in TotalDeathCount - 450127




-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%india%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc






-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2
--Total DeathPercentage of World is about 2.04% as per total no of people got infected by covid till 7th october 2021.




-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea

Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.location like '%india%'
--Where dea.continent is not null 
order by 2,3
-- From above Query 
--Total no of vaccinated people in india till 7th october 2021 is - 857889600



-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.location like '%india%'
--where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as VaccinationPercentage
From PopvsVac
-- From above Query  61% of the population of India got vaccinated at least one dose.
-- Data present till 7th october 2021.
-- where as India started its vaccination program from 16th january 2021





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
, SUM(CONVERT(Bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

