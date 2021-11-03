Link to Dataset: https://ourworldindata.org/covid-deaths

--Select*
--From PortfolioProjects..CovidDeaths$

--Select*
--From  PortfolioProjects..CovidVaccinations$

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjects..CovidDeaths$
order by 1,2

--Total cases vs Total Deaths

Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths$
Where Location = 'Bangladesh'
order by 1,2


--Total cases vs Population

Select Location, date, Population, total_cases,(total_cases/population)*100 as InfectionRate
From PortfolioProjects..CovidDeaths$
Where Location = 'Bangladesh'
order by 1,2

--Comparing Infection Rate between Countries
Select Location, Population, MAX(total_cases) as total_cases, MAX(total_cases/population)*100 as InfectionRate
From PortfolioProjects..CovidDeaths$
Group by Location, Population
order by InfectionRate desc

--Comparing Death Rate between Countries

Select Location, Population, MAX(cast(total_deaths as int)) as TotalDeaths, MAX(total_deaths/population)*100 as DeathRate
From PortfolioProjects..CovidDeaths$
Where continent is not null
Group by Location, Population
order by DeathRate desc

Select Location,  MAX(cast(total_deaths as int)) as TotalDeaths
From PortfolioProjects..CovidDeaths$
Where continent is null
Group by Location
order by TotalDeaths desc


--Per Day Global Stats

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathRate
From PortfolioProjects..CovidDeaths$
Where continent is not null
Group By date
order by 1,2

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathRate
From PortfolioProjects..CovidDeaths$
Where continent is not null
order by 1,2


--Population vs Vaccination

Select *
From PortfolioProjects..CovidDeaths$ dea
Join PortfolioProjects..CovidVaccinations$ vac
     On dea.location = vac.location
	 and dea.date = vac.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProjects..CovidDeaths$ dea
Join PortfolioProjects..CovidVaccinations$ vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) --Arithmatic Overflow when using int
OVER (Partition by dea.location Order by dea.location, dea.date)
From PortfolioProjects..CovidDeaths$ dea
Join PortfolioProjects..CovidVaccinations$ vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--USING CTE
With PopvsVac (continent, date, location, population, new_vaccinations, PeopleVaccinated) as
(
Select dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) --Arithmatic Overflow when using int
OVER (Partition by dea.location Order by dea.location, dea.date) as PeopleVaccinated
From PortfolioProjects..CovidDeaths$ dea
Join PortfolioProjects..CovidVaccinations$ vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null

)
Select *, (PeopleVaccinated/Population)*100
From PopvsVac
