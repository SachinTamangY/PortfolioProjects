SET SQL_SAFE_UPDATES = 0;

UPDATE Portfolio.covidvaccinations
SET date = STR_TO_DATE(date, '%d/%m/%Y');

Select date
FROM Portfolio.covidvaccinations;

ALTER Table Portfolio.covidvaccinations
modify column date DATE;

Select date
FROM Portfolio.covidvaccinations;

SELECT *
FROM Portfolio.coviddeaths;

UPDATE Portfolio.coviddeaths
SET date = STR_TO_DATE(date, '%d/%m/%Y');

ALTER Table Portfolio.coviddeaths
modify column date DATE;

-- Checking death percentage of Nepal during the peak covid period
SELECT Location, date, total_cases, total_deaths,
round((total_deaths/total_cases) * 100,2) as death_percentage
FROM Portfolio.coviddeaths
Where location = 'Nepal'
Order by 1,2;

-- Looking at Countries with highest infection rate compared to population
Select Location, Population, max(total_cases) as HighestInfectionCount,
round(max((total_cases/population)) * 100,2) as PercentPopulationInfected
From Portfolio.CovidDeaths
group by Location, Population
Order by PercentPopulationInfected Desc;

-- Looking at highest Death count per population
Select Location, Population, max(cast(total_deaths as signed)) as Total_death_count
From Portfolio.CovidDeaths
Where continent is not null
group by Location, Population
Order by Total_death_count Desc;


SET sql_safe_updates = 0;

UPDATE Portfolio.CovidDeaths
SET continent = NULL
WHERE TRIM(continent) = '';
SET sql_safe_updates = 1;


select distinct continent
From Portfolio.CovidDeaths
Where continent is not null;

-- Let's death count data by continent
Select Continent, max(cast(total_deaths as signed)) as Total_death_count
From Portfolio.CovidDeaths
Where continent is not null
group by continent
Order by Total_death_count Desc;

-- Global Numbers
Select date,
SUM(new_cases) as daily_cases,
SUM(cast(new_deaths as signed)) as daily_deaths,
round(SUM(cast(new_deaths as signed))/SUM(new_cases) *100,2) as daily_death_percentage
FROM Portfolio.CovidDeaths
Group by date
Order by 1,2;

-- Looking at Total population vs Vaccinations
WITH PopVsVac(continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS 
(Select death.continent,death.location, death.date, death.population, Vacc.new_vaccinations,
SUM(cast(Vacc.new_vaccinations as signed)) OVER(partition by death.location Order by death.location, death.date) as rolling_people_vaccinated
FROM Portfolio.CovidDeaths death
jOIN Portfolio.CovidVaccinations Vacc
ON death.location = Vacc.location
AND death.date = Vacc.date
where death.continent is not null
-- Order by 1,2,3
)
SELECT *, (rolling_people_vaccinated/population) * 100 as percent_of_vaccinated_population
FROM PopVsVac;




