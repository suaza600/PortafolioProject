select*
From CovidsVacuna
Order By 3, 4

select*
From CovidsDeath
Order By 3, 4

--Select Data that we are going to be using 

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidsDeath
Order By 1, 2
--Convertir Tipo de Data

ALTER TABLE CovidsDeath ALTER COLUMN total_cases float
ALTER TABLE CovidsDeath ALTER COLUMN total_deaths float

--Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Porcentaje,
CASE
WHEN (total_deaths/total_cases)*100 < = 1 THEN 'BAJO'
WHEN (total_deaths/total_cases)*100 < 2.5  THEN 'MEDIO'
WHEN (total_deaths/total_cases) < 5  THEN 'ALTO'
ELSE 'REVISION'
END AS 'Clasificación'
From CovidsDeath
WHERE Location like '%olombia' and continent is not null
Order By 1, 2

--Conteo de Clasificación Subquery FROM

Select resultados.Clasificación, Count(Clasificación)
From
(Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Porcentaje,
CASE
WHEN (total_deaths/total_cases)*100 < = 1 THEN 'BAJO'
WHEN (total_deaths/total_cases)*100 < 2.5  THEN 'MEDIO'
WHEN (total_deaths/total_cases) < 5  THEN 'ALTO'
ELSE 'REVISION'
END AS 'Clasificación'
From CovidsDeath
WHERE Location like '%olombia' and continent is not null
) as Resultados
GROUP BY Clasificación

--Conteo de Clasifación Creación de Tabla
WITH TablasdePromedio AS 
(Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Porcentaje,
CASE
WHEN (total_deaths/total_cases)*100 < = 1 THEN 'BAJO'
WHEN (total_deaths/total_cases)*100 < 2.5  THEN 'MEDIO'
WHEN (total_deaths/total_cases) < 5  THEN 'ALTO'
ELSE 'REVISION'
END AS 'Clasificación'
From CovidsDeath
WHERE Location like '%olombia' and continent is not null
)

SELECT clasificación, count(clasificación)
FROM TablasdePromedio 
Group by clasificación


--Promedio de Porcentaje de Muertes vs casos

SELECT AVG(total_deaths/total_cases)*100 AS Promedio
FROM CovidsDeath
WHERE Location = 'Colombia' and continent is not null
ORDER BY Promedio desc

--Looking at Total Cases vs Population

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS DeathPercentage
FROM CovidsDeath
WHERE Location = 'Colombia' and continent is not null
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate Compared to Population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS MAXDeathPercentage
FROM CovidsDeath
WHERE continent is not null
GROUP BY location, population 
ORDER BY 4 DESC

--Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(Total_deaths as int)) as TotaldeathCount
FROM CovidsDeath
WHERE continent is not null
GROUP BY location
ORDER BY 2 DESC

--LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(cast(Total_deaths as int)) as TotaldeathCount
FROM CovidsDeath
WHERE continent is not null
GROUP BY continent
ORDER BY 2 DESC

--Showing Continents with the highest death count per population

SELECT continent, MAX(cast(Total_deaths as int)) as TotaldeathCount
FROM CovidsDeath
WHERE continent is not null
GROUP BY continent
ORDER BY 2 DESC

--GLOBAL NUMBERS

SELECT  date, SUM(new_cases) as Newcases, Sum(new_deaths) as Newdeaths, Sum(new_deaths)/SUM(new_cases)*100 as deathscases
FROM CovidsDeath
--WHERE Location = 'Colombia' and continent is not null
WHERE continent is not null and new_cases <> 0
GROUP BY date
ORDER BY 1,2

--Looking at Total Population vs vaccinations 

SELECT DEA.continent, DEA.location, DEA.DATE, DEA.POPULATION, VAC.new_vaccinations 
, SUM(cast(VAC.new_vaccinations as FLOAT)) OVER (Partition by DEA.LOCATION ORDER BY DEA.location) as RollingPeoplevaccunation,
--(RollingPeoplevaccunation/population)*100
FROM CovidsDeath AS DEA
Inner Join CovidsVacuna AS VAC
ON  DEA.location = VAC.location
and DEA.date= VAC.date
WHERE DEA.continent is not null
ORDER BY 2,3

-- CTE

WITH  PopVAC (Continent, location, date, population,New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT DEA.continent, DEA.location, DEA.DATE, DEA.POPULATION, VAC.new_vaccinations 
, SUM(cast(VAC.new_vaccinations as FLOAT)) OVER (Partition by DEA.LOCATION ORDER BY DEA.location) as RollingPeoplevaccunation
--(RollingPeoplevaccunation/population)*100
FROM CovidsDeath AS DEA
Inner Join CovidsVacuna AS VAC
ON  DEA.location = VAC.location
and DEA.date= VAC.date
WHERE DEA.continent is not null
--ORDER BY 2,3
)
Select*, (RollingPeopleVaccinated/population)*100
From PopVAC 

-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated

(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT DEA.continent, DEA.location, DEA.DATE, DEA.POPULATION, VAC.new_vaccinations 
, SUM(cast(VAC.new_vaccinations as FLOAT)) OVER (Partition by DEA.LOCATION ORDER BY DEA.location) as RollingPeoplevaccunation
--(RollingPeoplevaccunation/population)*100
FROM CovidsDeath AS DEA
Inner Join CovidsVacuna AS VAC
ON  DEA.location = VAC.location
and DEA.date= VAC.date
--WHERE DEA.continent is not null
--ORDER BY 2,3

Select*, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualitaion

Create view ViewPercentPopulationVaccinated as
SELECT DEA.continent, DEA.location, DEA.DATE, DEA.POPULATION, VAC.new_vaccinations 
, SUM(cast(VAC.new_vaccinations as FLOAT)) OVER (Partition by DEA.LOCATION ORDER BY DEA.location) as RollingPeoplevaccunation
--(RollingPeoplevaccunation/population)*100
FROM CovidsDeath AS DEA
Inner Join CovidsVacuna AS VAC
ON  DEA.location = VAC.location
and DEA.date= VAC.date
WHERE DEA.continent is not null
--ORDER BY 2,3

Select*
FROM ViewPercentPopulationVaccinated