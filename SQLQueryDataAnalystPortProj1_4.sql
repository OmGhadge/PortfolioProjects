
SELECT * FROM PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--SELECT * FROM PortfolioProject..CovidVaccinations
--order by 3,4

SELECT Location,date,total_cases,total_deaths ,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
and  continent is not null
order by 1,2

-- shows what percentaeg of population got covid
SELECT Location,date,population,total_cases ,(total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2

-- looking at countries with Highest Infection Rate compared to Population
SELECT Location,population,MAX( total_cases) AS HighestInfectionCount ,MAX( (total_cases/population))*100 as
PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Where continent is not null
--Where location like '%states%'
Group by  Location,population
order by PercentPopulationInfected desc

-- Shows the countries with highest death count per population
SELECT Location,MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
--Where location like '%states%'
Group by  Location
order by TotalDeathCount  desc

-- Lets break this down by continent
SELECT location,MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is  null and location <> 'High income' and location <> 'Upper middle income' and location <> 'Lower middle income'
and location <> 'Low income'
--Where location like '%states%'
Group by  location
order by TotalDeathCount  desc

--corrct
SELECT continent,MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
--Where continent is  null and location <> 'High income' and location <> 'Upper middle income' and location <> 'Lower middle income'
--and location <> 'Low income'
--Where location like '%states%'
Group by  continent
order by TotalDeathCount  desc

-- Global nos on a particular date
SELECT date,SUM(new_cases) as total_cases,SUM(cast(new_deaths as int) )as total_deaths ,SUM(cast(new_deaths as int) )/SUM
(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by date
order by 1,2

-- USE CTE
With PopvsVac (Continent,location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations  )) OVER (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    on dea.location =vac.location
	and dea.date =vac.date
where dea.continent is not null
--order by 2,3
)

Select *,(RollingPeopleVaccinated/Population)*100
From PopvsVac


--temp table
DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
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
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3




Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

Create View PercentPopulationVaccinated  as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select * from PercentPopulationVaccinated 