Select *
From [Covid Vax]..Covid_Deaths
Where continent is not null 
order by 3,4

Select *
From [Covid Vax]..Covid_vaccinations
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From [Covid Vax]..Covid_Deaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Covid Vax]..Covid_Deaths
Where location like '%states%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From [Covid Vax]..Covid_Deaths
--Where location like '%states%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [Covid Vax]..Covid_Deaths
Where location is NOT NULL
Group by Location, Population
order by PercentPopulationInfected desc;


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Covid Vax]..Covid_Deaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc;



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Covid Vax]..Covid_Deaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc;



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Covid Vax]..Covid_Deaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2;


-- Total Population vs Vaccinations

SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
FROM [Covid Vax]..Covid_Deaths dea
JOIN [Covid Vax]..Covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
Order By 2,3;

-- Shows Percentage of Population that has recieved at least one Covid Vaccine
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)  AS Rolling_Count
FROM [Covid Vax]..Covid_Deaths dea
JOIN [Covid Vax]..Covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
Order By 2,3;

--USING CTE

WITH popvsvac (continent, location, date, population, new_vaccination, Rolling_count)
AS (
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(ISNULL(vac.new_vaccinations,0) AS float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)  AS Rolling_Count
FROM [Covid Vax]..Covid_Deaths dea
JOIN [Covid Vax]..Covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--Order By 2,3;
)
SELECT location, Max(Rolling_count*100/population) As Percentage_vaccinated
FROM popvsvac
GROUP BY location
ORDER BY Percentage_vaccinated DESC;

--USING TEMPTABLE
DROP TABLE if exists #Percantpolpulationvaccinated
CREATE Table #Percantpolpulationvaccinated
(	
	Continent nVarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population Float,
	New_vaccination float,
	RollingPeoplevaccinated float
)

INSERT INTO #Percantpolpulationvaccinated
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(ISNULL(vac.new_vaccinations,0) AS float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)  AS Rolling_Count
FROM [Covid Vax]..Covid_Deaths dea
JOIN [Covid Vax]..Covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--Order By 2,3;

Select *, (RollingPeoplevaccinated/population)*100
FROM #Percantpolpulationvaccinated;

--Creating view to store data for Later visualisations

Create view Percantpolpulationvaccinated AS
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(ISNULL(vac.new_vaccinations,0) AS float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)  AS Rolling_Count
FROM [Covid Vax]..Covid_Deaths dea
JOIN [Covid Vax]..Covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--Order By 2,3;

Select * FROM Percantpolpulationvaccinated;