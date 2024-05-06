SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER by 3,4

SELECT *
FROM PortfolioProject.dbo.CovidVaccinations
ORDER by 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER by 1,2


-- Looking at Total Cases vsTotal Deaths
-- Shows the livelihood of dying if one contract Covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
where location like '%states'
ORDER by 1,2


-- Looking at the total Cases vs Population

SELECT Location, date, population, total_cases, (total_cases/population)*100 as 
PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
-- where location like '%nigeria'
ORDER by 1,2

-- Looking at countries with Highest Infection Rate compared to Populations

SELECT Location, population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as 
PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY Location, Population
-- where location like '%nigeria'
ORDER by PercentPopulationInfected DESC /** This arranges the data in decending order on the PercentPopulationInfected column**/


-- Showing the Countries with the Highest Deaths Counts per Population

SELECT Location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY Location
-- where location like '%nigeria'
ORDER by TotalDeathCount DESC /** This arranges the data in decending order on the TotalDeathCount column**/


-- LET'S BREAT THINGS DOWN INTO CONTINENT

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is null
GROUP BY location
-- where location like '%nigeria'
ORDER by TotalDeathCount DESC                                  /** This arranges the data in decending order on the TotalDeathCount column**/


-- Showing the continents with Highest Deaths Count

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
-- where location like '%nigeria'
ORDER by TotalDeathCount DESC                                  /** This arranges the data in decending order on the TotalDeathCount column**/


-- GLOBAL NUMBERS  (This shows the total cases and total deaths in each day Globally)

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY date
-- where location like '%nigeria'
ORDER by 1,2                                

            -- (This shows the total cases and total deaths so far Globally)
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
-- where location like '%nigeria'
ORDER by 1,2                                


-- Looking at Total Population vs Vaccinations

/** select *
FROM PortfolioProject.dbo.CovidDeaths as dea
JOIN PortfolioProject.dbo.CovidVaccination as vac
    ON dea.location = vac.location
    and dea.date = vac.date
**/

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert (int, vac.new_vaccinations)) over (partition by 
dea.Location order by dea.Location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths as dea
JOIN PortfolioProject.dbo.CovidVaccination as vac
    ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3


-- USE CTE


WITH PopVsVac (continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated) AS
(
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations, 
        SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.Location, dea.date) AS RollingPeopleVaccinated
    FROM 
        PortfolioProject.dbo.CovidDeaths AS dea
    JOIN 
        PortfolioProject.dbo.CovidVaccination AS vac
    ON 
        dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac;


-- TEMP TABLE

/* NOTE: If you make a mistake and needs to edit the table use the code(DROP Table if exits ) below*/

-- DROP Table if exists #PercentPopulationVaccinated

Create TABLE #PercentPopulationVaccinated
(
continent NVARCHAR(255),
LOCATION NVARCHAR(255),
DATE datetime,
population numeric,
new_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

insert into #PercentPopulationVaccinated
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations, 
        SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION BY dea.LOCATION ORDER BY dea.Location, dea.date) AS RollingPeopleVaccinated
    FROM 
        PortfolioProject.dbo.CovidDeaths AS dea
    JOIN 
        PortfolioProject.dbo.CovidVaccination AS vac
    ON 
        dea.location = vac.location
        AND dea.date = vac.date
    
        order by 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated;


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS


CREATE VIEW PercentPopulationVaccinated as 
SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations, 
        SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION BY dea.LOCATION ORDER BY dea.Location, dea.date) AS RollingPeopleVaccinated
FROM 
        PortfolioProject.dbo.CovidDeaths AS dea
JOIN 
        PortfolioProject.dbo.CovidVaccination AS vac
    ON 
        dea.location = vac.location
        AND dea.date = vac.date
where dea.continent is not NULL   
-- order by 2,3