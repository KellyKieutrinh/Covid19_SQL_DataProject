USE [PortfolioProject]
GO

Select *
From PortfolioProject.dbo.CovidDeaths
order by 3,4

--Select *
--From PortfolioProject.dbo.CovidVacinations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2

-- total cases vs total death in USA, percentage per total case for death in USA

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2



-- total cases vs population in united State, percentage of population got covid
Select location, date, total_cases, total_deaths, population, (total_cases/population)*100 as CasePercentage
From PortfolioProject.dbo.CovidDeaths
Where location like '%state%'
order by 1,2

-- Countries with highest infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCases, Max((total_cases/population)*100) as CasePercentage
From PortfolioProject.dbo.CovidDeaths
Where continent IS NOT NULL
Group by location, population
order by HighestInfectionCases desc

-- Countries with highest death rate compared to population
Select location, population, MAX(total_deaths) as HighestDeathCases, Max((total_deaths/population)*100) as Death_Population_Percentage
From PortfolioProject.dbo.CovidDeaths
Where continent IS not NULL
Group by location, population
order by HighestDeathCases desc

-- the highest death count per population with continients
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- Global numbers over new case, new death cases, and percentage of total new death case vs total all new case
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
where continent is not null 
order by 1,2

-- CTE
With PopvsVac(continent, location, date, population, new_vaccinations,RollingPeopleVacination)
AS(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVacination
From dbo.CovidDeaths dea JOIN dbo.CovidVacinations vac
	ON dea.location = vac.location AND dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVacination/population)*100 as PeopleVacperPopulation
From PopvsVac

-- TEMP Table

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
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVacination
From dbo.CovidDeaths dea JOIN dbo.CovidVacinations vac
	ON dea.location = vac.location AND dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 as PeopleVacperPopulation
From #PercentPopulationVaccinated 

GO
-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea Join CovidVacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null