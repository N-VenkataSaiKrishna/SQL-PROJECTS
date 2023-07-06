
use covid_dataset;

select * from covidvaccince$;

SELECT * FROM coviddeaths$;

/* select required columns from coviddeaths table */

SELECT location, date, total_cases, new_cases, total_deaths, population 
from coviddeaths$
order by 1, 2;

/* check the datatype for total_cases and tottal_deaths */

select data_type from
INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'coviddeaths$'
and COLUMN_NAME = 'total_deaths';

/* change the datatype of the columns */

ALTER TABLE coviddeaths$
alter column total_cases float;

ALTER TABLE coviddeaths$
alter column total_deaths float;

/* get death percentage in respective locations using coviddeaths table */

select location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as Death_Percentage
from coviddeaths$ 
where location like 'in%'
order by 1,2;

/* get the infected percentage in respective locations using coviddeaths table */

select location, date, total_cases, total_deaths, population, (total_cases/population)*100 as infected_Percentage
from coviddeaths$ 
where location like 'in%'
order by 1,2;

 /*know the higest infection rate country */

 select location,population, max(total_cases) as totalcases, max((total_cases/population))*100 as higest_infected_percentage
 from coviddeaths$
 group by location, population
 order by 4 desc;

 /*know the which location has higest deathcount */

 select location, sum(total_deaths) as totaldeathcount
 from coviddeaths$
 where location not in ('world','high income', 'upper middle income', 'lower middle income')
 group by location
 order by 2 desc
 offset 0 rows
 fetch next 3 rows only;

 /* show the top 3 or highest total new_cases based on locations from data */

 select location, sum(new_cases) as total_new_cases from coviddeaths$
 where location not in ('world','high income', 'upper middle income', 'lower middle income')
 group by location
 order by 2 desc
 offset 0 rows
 fetch next 3 rows only ;
 

 /* join the tables */

 select cd.continent, cd.location, cd.date, cd.population,cv.new_vaccinations,
 sum(cast(cv.new_vaccinations as int)) over (partition by cd.location ) as peoplevaccinated
 from coviddeaths$ cd
 join covidvaccince$ cv
 on cd.location = cv.location
 and cd.date = cv.date
 where cd.continent is not null and 
 cd.location  like 'in%'
 order by 2;