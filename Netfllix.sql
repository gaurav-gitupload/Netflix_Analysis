--Netflix Project
--Create table to import data
Create table netflix(
	show_id	varchar(10),
	type varchar(15),
	title varchar(150),
	director varchar(210),
	casts varchar (1000),
	country varchar(150),
	date_added varchar(50),
	release_year int,
	rating varchar(10),
	duration varchar(15),
	listed_in varchar(25),
	description varchar(250)

);
-- getting error due to less size aloted to the listed column
Alter table netflix
alter column listed_in type varchar(250);

select * from netflix;
--cross check we had imported data correctly or not
Select Count(*) as total_rows 
from netflix;
-- check distinct type 
Select 
	Distinct type
from netflix;




-- 15 Business Problems & Solutions

--1. Count the number of Movies vs TV Shows

select 
	type, 
	count(*) As no_of_record
from netflix
group by type;

--2. Find the most common rating for movies and TV shows
--select rating from netflix
select type,rating
from
(	select
	type,
	rating,
	count(rating) as most_common_rating,
	--problem is rating tv-ma is common in both type to solve this we use rank ,over
	rank() over(partition by type order by count(rating) desc) as ranking
	-- count desc to make rank suitable
	from netflix
	group by type,rating 
) as t1
where ranking = 1;
--order by 1,ranking desc;

--3. List all movies released in a specific year (e.g., 2020)
Select * from netflix;

select Title
from netflix 
where type = 'Movie' and release_year = 2020;


--4. Find the top 5 countries with the most content on Netflix
Select * from netflix;
--country , title 
Select country, Count(title) as no_of_Content
from netflix
where country is not null
group by country
order by no_of_Content desc
limit 5;
-- above is not prefect because some of rows have multiple country to solve we use [string to array function]
Select new_country,
sum(total_content) as total_content
from 
(select 
	unnest(string_to_array(country,',')) as new_country,
	count(show_id) as total_content
from netflix
group by 1) as country_data
group by new_country
order by 2 desc
limit 5;

select Country,
string_to_array (country,',')
from netflix; 

--replace the extra space to remove duplicate united states 
SELECT 
    TRIM(new_country) AS new_country, 
    sum(total_content) AS total_content
FROM (
    SELECT 
        TRIM(unnest(string_to_array(country, ','))) AS new_country,
        COUNT(show_id) AS total_content
    FROM netflix
    GROUP BY 1
) AS country_data
GROUP BY new_country
ORDER BY total_content DESC
LIMIT 5;

--5. Identify the longest movie
select * from netflix;

select 
	duration,title 
from netflix
 where type = 'Movie' and duration is not null
 order by duration desc;
--but in this case we have to apply limit we are unaware about last limit so this is not appropiate 
select title, duration
from netflix
where type= 'Movie' and duration = (select max(duration) from netflix)

6. Find content added in the last 5 years
/*select * from netflix;
select title, max(date_added) 
from netflix 
where date_added is not null 
group by date_added , title
order by date_added desc

select * from netflix
where 
	date added = current_date - interval '% years  vdcsaxa'
*/

-- to_date function use to convert data type to date type
select * from netflix
where to_date(date_added, 'Month DD ,YYYY') >= current_date - Interval '5 years'



7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
select title, type,director
from netflix
where director ilike '%Rajiv Chilaka%' -- ilike work with case sensitive







8. List all TV shows with more than 5 seasons


select title,type,duration --, split_part(duration, ' ',1) as season
from netflix
where type = 'TV Show' and split_part(duration, ' ',1):: numeric > 5 

9. Count the number of content items in each genre

select * from netflix
-- we rename column listed_in to genre
alter table netflix 
rename column listed_in to genre

select 
trim(unnest(string_to_array(genre, ','))) as Genre,
count(show_id) as no_of_show
from netflix
group by 1
order by 2 desc;

10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

select 
	extract(year from to_date(date_added, 'month dd, yyyy')) as year,
	count(*),
	round(
	count(*)::numeric/ (select count(*)::numeric from netflix where country= 'India') * 100
	,2)as avg_content
from netflix
where country = 'India'
group by 1
order by 3 desc
limit 5
11. List all movies that are documentaries
select title as Movies_name
from netflix
where genre ilike '%Documentaries%'


12. Find all content without a director
select *
from netflix
where director is null


13. Find how many movies actor 'Salman Khan' appeared in last 15 years!

Select * 
from  netflix
where casts ilike '%Salman Khan%'
	and release_year > extract(Year from current_date) - 15




14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

select trim (unnest(string_to_array(casts, ','))) as actors
 , count(show_id)
from netflix
where country ilike '%India%' and type ilike '%Movie%'
group by 1 
order by 2 desc
limit 10


15.
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.



select * from netflix

alter table netflix
drop column if exists keyword



select *, 
case 
when description ilike '%Kill%' 
or description ilike '%violence%' then 'Bad Content'
else 'Good Content'
end category 
from netflix
