USE imdb;

/* Let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/
 
-- Segment 1:

-- Total number of rows in each table of the schema
SELECT table_name, table_rows
FROM INFORMATION_SCHEMA.tables
WHERE TABLE_SCHEMA = 'imdb';


-- Columns in the movie table having null values
SELECT 
		SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS ID_nulls, 
		SUM(CASE WHEN title IS NULL THEN 1 ELSE 0 END) AS title_nulls, 
		SUM(CASE WHEN year IS NULL THEN 1 ELSE 0 END) AS year_nulls,
		SUM(CASE WHEN date_published IS NULL THEN 1 ELSE 0 END) AS date_published_nulls,
		SUM(CASE WHEN duration IS NULL THEN 1 ELSE 0 END) AS duration_nulls,
		SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS country_nulls,
		SUM(CASE WHEN worlwide_gross_income IS NULL THEN 1 ELSE 0 END) AS worlwide_gross_income_nulls,
		SUM(CASE WHEN languages IS NULL THEN 1 ELSE 0 END) AS languages_nulls,
		SUM(CASE WHEN production_company IS NULL THEN 1 ELSE 0 END) AS production_company_nulls

FROM movie;

-- Observations: Four columns of the movie table has null values. 


-- Total number of movies released each year. Checking the trend month-wise.
-- (Output expected)
/* Output format for the first part:
+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+
Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */

select year , count(*) as total_movies from movie
group by year
order by count(*) desc;

-- part 2
select month(date_published)as months ,COUNT(*) as totoal_movies from movie
group by MONTH(date_published)
order by months ;

/* Observations: The highest number of movies is produced in March. 
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produce a huge number of movies each year.
Lets find the number of movies produced by USA or India for the last year.*/



-- Movies produced in the USA or India in the year 2019??
/*
select count(*),year from movie
where country = 'USA' or country = 'india'
group by year;
*/
SELECT COUNT(id) AS movie
FROM movie
WHERE (country LIKE '%USA%' OR country LIKE '%India%') AND year = 2019;

/* Observations: USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/



-- The unique list of the genres present in the data set?
SELECT DISTINCT genre
FROM genre;

/* Observations: RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number
of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */



-- Genre having the highest number of movies produced overall
select genre,count(*) as count_movies from movie inner join genre on movie.id = genre.movie_id
group by genre
order by count_movies desc
limit 1;

/* Observations: Based on the insight that we drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/



-- Movies belonging to only one genre
with ct_genre AS
(
	SELECT movie_id, 
			COUNT(genre) AS number_of_movies
	FROM genre
	GROUP BY movie_id
	HAVING COUNT(genre) =1
)

SELECT COUNT(movie_id) AS number_of_movies
FROM ct_genre;

/* Observations: There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/



-- Average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)
/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

select genre , round(avg(duration),2) as avg_duration  from movie inner join genre
on movie.id = genre.movie_id
group by genre.genre 
order by avg(duration) desc;


/* Observations: Movies of genre 'Drama' (produced highest in number in 2019) has an average duration of 106.77 mins.
Let's find where the movies of genre 'thriller' based on number of movies.*/

-- Finding the rank of the ‘thriller’ 
-- Genre of movies among all the genres in terms of number of movies produced 
-- ( Rank Function)

/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
/*
select genre,count(movie_id),RANK() over (order by count(movie_id) desc) as sakfj from genre
group by genre
*/

with genre_rank AS
(
	SELECT genre, COUNT(movie_id) AS movie_count,
			RANK() OVER(ORDER BY COUNT(movie_id) DESC) AS genre_rank
	FROM genre
	GROUP BY genre
)
SELECT *
FROM genre_rank
WHERE genre='thriller';

/* Observations: Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/



-- Segment 2:

-- Minimum and maximum values in  each column of the ratings table except the movie_id column
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/

select * from ratings;

select min(avg_rating) as min_avg_rating , max(avg_rating) as max_avg_rating ,
min(total_votes) as min_total_votes, max(total_votes) as max_total_votes,
min(median_rating) as min_median_rating , max(median_rating) as max_median_rating from ratings;

/* Observations: Minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 


-- Finding the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/

-- It's ok if RANK() or DENSE_RANK() is used too

SELECT title,AVG(avg_rating) AS avg_rating,
RANK() OVER (ORDER BY AVG(avg_rating) DESC) AS avg_rating_rank
FROM movie INNER JOIN ratings ON movie.id = ratings.movie_id
GROUP BY title
limit 10;

/* Observations: Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6?
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/



-- Summarise the rating table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */

-- Observations: Order by is good to have
select * from ratings;

select median_rating , count(movie_id) as movie_count from ratings
group by median_rating
order by count(movie_id) desc;

/* Observations: Movies with a median rating of 7 is highest in number. 



Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Checking the production house that has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

select * from ratings;

select movie.production_company, count(*) as movie_count , 
DENSE_RANK() OVER(ORDER BY COUNT(id) DESC) AS prod_company_rank from movie inner join ratings
 on movie.id = ratings.movie_id
 where  ratings.avg_rating >8 and movie.production_company is not null
 group by movie.production_company
 ORDER BY movie_count DESC;


-- Movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:
+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */

SELECT g.genre, COUNT(g.movie_id) AS movie_count
FROM genre AS g
INNER JOIN ratings AS r
ON g.movie_id = r.movie_id
INNER JOIN movie AS m
ON m.id = g.movie_id
WHERE m.country='USA' AND r.total_votes>1000 AND MONTH(date_published)=3 AND year=2017
GROUP BY g.genre
ORDER BY movie_count DESC;


-- Lets try to analyse with a unique problem statement.


-- Finding movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/

select title, avg_rating , genre from ratings inner join genre on ratings.movie_id = genre.movie_id
inner join movie on movie.id = genre.movie_id
where title like 'the%' and avg_rating > 8;


-- Also check the median rating and check whether the ‘median rating’ column gives any significant insights.
-- Movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?

select count(*) as count_rating , median_rating from ratings inner join movie on ratings.movie_id = movie.id
where (movie.date_published  between '2018-04-01' and '2019-04-01') and (ratings.median_rating = 8);


-- Checking if German movies get more votes than Italian movies? 
-- Finding the total number of votes for both German and Italian movies.

SELECT country, sum(total_votes) as total_votes
FROM movie AS m
	INNER JOIN ratings as r ON m.id=r.movie_id
WHERE country = 'Germany' or country = 'Italy'
GROUP BY country;

-- Answer is Yes


/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/



-- Segment 3:
-- Columns in the names table having null values
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/

SELECT 
		SUM(CASE WHEN name IS NULL THEN 1 ELSE 0 END) AS name_nulls, 
		SUM(CASE WHEN height IS NULL THEN 1 ELSE 0 END) AS height_nulls,
		SUM(CASE WHEN date_of_birth IS NULL THEN 1 ELSE 0 END) AS date_of_birth_nulls,
		SUM(CASE WHEN known_for_movies IS NULL THEN 1 ELSE 0 END) AS known_for_movies_nulls
		
FROM names;

/* Observations: There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/


-- Top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:
+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */

WITH top_3_genres AS
(
   SELECT
      genre,
      COUNT(m.id) AS movie_count,
      RANK() OVER(ORDER BY COUNT(m.id) DESC) AS genre_rank
   FROM
      movie AS m
      INNER JOIN genre AS g ON g.movie_id = m.id
      INNER JOIN ratings AS r ON r.movie_id = m.id
   WHERE
      avg_rating > 8
   GROUP BY
      genre
   LIMIT 3
)
SELECT
   n.NAME AS director_name,
   COUNT(d.movie_id) AS movie_count
FROM
   director_mapping AS d
   INNER JOIN genre G USING (movie_id)
   INNER JOIN names AS n ON n.id = d.name_id
   INNER JOIN top_3_genres USING (genre)
   INNER JOIN ratings USING (movie_id)
WHERE
   avg_rating > 8
GROUP BY
   NAME
ORDER BY
   movie_count DESC
LIMIT 3;

/* Observation: James Mangold can be hired as the director for RSVP's next project. Do you remember his movies, 
'Logan' and 'The Wolverine'. 


Now, let’s find out the top two actors.*/

-- Top two actors whose movies have a median rating >= 8?
/* Output format:
+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */

SELECT DISTINCT name AS actor_name, COUNT(r.movie_id) AS movie_count
FROM ratings AS r
INNER JOIN role_mapping AS rm
ON rm.movie_id = r.movie_id
INNER JOIN names AS n
ON rm.name_id = n.id
WHERE median_rating >= 8 AND category = 'actor'
GROUP BY name
ORDER BY movie_count DESC
LIMIT 2;



RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/
-- Top three production houses based on the number of votes received by their movies
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/

SELECT production_company, SUM(total_votes) AS vote_count,
		DENSE_RANK() OVER(ORDER BY SUM(total_votes) DESC) AS prod_comp_rank
FROM movie AS m
INNER JOIN ratings AS r
ON m.id = r.movie_id
GROUP BY production_company
LIMIT 3;

/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

WITH actor_summary AS (
SELECT NAME AS actor_name,Sum(total_votes) AS total_votes,
Count(a.movie_id) AS movie_count,Round(Sum(avg_rating * total_votes) / Sum(total_votes), 2) AS actor_avg_rating 
FROM role_mapping a 
INNER JOIN names b 
ON a.name_id = b.id 
INNER JOIN ratings c 
ON a.movie_id = c.movie_id 
INNER JOIN movie d 
ON a.movie_id = d.id 
WHERE category = 'actor' AND country LIKE '%India%' 
GROUP BY name_id, NAME
HAVING Count(DISTINCT a.movie_id) >= 5)
SELECT *, DENSE_Rank() OVER (ORDER BY actor_avg_rating DESC) AS actor_rank 
FROM actor_summary;

-- Observation: Top actor is Vijay Sethupathi

-- Top five actresses in Hindi movies released in India based on their average ratings 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Using weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie-breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
SELECT
    NAME AS actress_name,
    SUM(r.total_votes) AS total_votes,
    COUNT(m.id) AS movie_count,
    ROUND(SUM(avg_rating * total_votes) / SUM(total_votes), 2) AS actress_avg_rating,
    RANK() OVER(ORDER BY ROUND(SUM(avg_rating * total_votes) / SUM(total_votes), 2) DESC) AS actress_rank
FROM
    movie AS m
INNER JOIN ratings AS r ON m.id = r.movie_id
INNER JOIN role_mapping AS rm ON m.id = rm.movie_id
INNER JOIN names AS nm ON rm.name_id = nm.id
WHERE
    rm.category = 'actress'
    AND m.country LIKE '%India%'
    AND m.languages LIKE '%Hindi%'
GROUP BY
    NAME
HAVING
    SUM(m.country = 'India') >= 3
LIMIT 5;

/* Observations: Taapsee Pannu tops with average rating 7.74. 


Now let us divide all the thriller movies into the following categories and find out their numbers.*/
/* Thriller movies as per AVG rating and classify them into the following categories: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
SELECT title, r.avg_rating,
		CASE WHEN avg_rating > 8 THEN 'Superhit movies'
			 WHEN avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
             WHEN avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
			 WHEN avg_rating < 5 THEN 'Flop movies'
		END AS avg_rating_category
FROM movie AS m
INNER JOIN genre AS g
ON m.id=g.movie_id
INNER JOIN ratings as r
ON m.id=r.movie_id
WHERE genre='thriller';



-- Segment 4:

-- The genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
SELECT genre,
		ROUND(AVG(duration),2) AS avg_duration,
        SUM(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS UNBOUNDED PRECEDING) AS running_total_duration,
        AVG(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS 10 PRECEDING) AS moving_avg_duration
FROM movie AS m 
INNER JOIN genre AS g 
ON m.id= g.movie_id
GROUP BY genre
ORDER BY genre;

-- Observations: Round is good to have and not a must-have; Same thing applies to sorting


-- Let us find the top 5 movies of each year with the top 3 genres.
-- The five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/


-- Top 3 Genres based on most number of movies

WITH top_genres AS (
SELECT genre,COUNT(m.id) AS movie_count,RANK() OVER (ORDER BY COUNT(m.id) DESC) AS genre_rank
FROM movie AS m
INNER JOIN genre AS g
ON g.movie_id = m.id
INNER JOIN ratings AS r
ON r.movie_id = m.id
WHERE avg_rating > 8
GROUP BY genre
LIMIT 3),movie_summary AS (
SELECT g.genre,m.year,m.title AS movie_name,
    CAST(REPLACE(REPLACE(IFNULL(m.worlwide_gross_income, 0), 'INR', ''), '$', '') AS DECIMAL(10)) AS worlwide_gross_income,
    DENSE_RANK() OVER (PARTITION BY m.year ORDER BY CAST(REPLACE(REPLACE(IFNULL(m.worlwide_gross_income, 0), 'INR', ''), '$', '') AS DECIMAL(10)) DESC) AS movie_rank
FROM movie AS m
INNER JOIN genre AS g
ON m.id = g.movie_id
WHERE g.genre IN (SELECT genre FROM top_genres)
GROUP BY g.genre, m.year, movie_name, m.worlwide_gross_income
)
SELECT *
FROM movie_summary
WHERE movie_rank <= 5
ORDER BY year;


-- Top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies.
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/

SELECT production_company,
		COUNT(m.id) AS movie_count,
        ROW_NUMBER() OVER(ORDER BY count(id) DESC) AS prod_comp_rank
FROM movie AS m 
INNER JOIN ratings AS r 
ON m.id=r.movie_id
WHERE median_rating>=8 AND production_company IS NOT NULL AND POSITION(',' IN languages)>0
GROUP BY production_company
LIMIT 2;

-- Observations: Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

WITH actress_summary AS(
SELECT n.NAME AS actress_name,
       SUM(total_votes) AS total_votes,
	   Count(r.movie_id) AS movie_count,
       Round(Sum(avg_rating*total_votes)/Sum(total_votes),2) AS actress_avg_rating
FROM movie AS m
INNER JOIN ratings AS r
ON m.id=r.movie_id
INNER JOIN role_mapping AS rm
ON m.id = rm.movie_id
INNER JOIN names AS n
ON rm.name_id = n.id
INNER JOIN GENRE AS g
ON g.movie_id = m.id
WHERE category = 'ACTRESS' AND avg_rating>8 AND genre = "Drama"
GROUP BY NAME)
SELECT *,Rank() OVER(ORDER BY movie_count DESC) AS actress_rank
FROM actress_summary
LIMIT 3;



/* The following details for the top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/

WITH published_summary AS(
SELECT d.name_id,NAME,d.movie_id,duration,r.avg_rating,total_votes,m.date_published,
	Lead(date_published,1) OVER(partition BY d.name_id ORDER BY date_published,movie_id ) AS next_date_published
FROM director_mapping AS d
INNER JOIN names AS n
ON n.id = d.name_id
INNER JOIN movie AS m
ON m.id = d.movie_id
INNER JOIN ratings AS r
ON r.movie_id = m.id ), top_director_summary AS
(SELECT *,Datediff(next_date_published, date_published) AS date_difference
FROM published_summary )
SELECT name_id AS director_id,NAME AS director_name,
         Count(movie_id) AS number_of_movies,
         Round(Avg(date_difference),2) AS avg_inter_movie_days,
         Round(Avg(avg_rating),2) AS avg_rating,
         Sum(total_votes) AS total_votes,
         Min(avg_rating) AS min_rating,
         Max(avg_rating) AS max_rating,
         Sum(duration) AS total_duration
FROM top_director_summary
GROUP BY director_id
ORDER BY Count(movie_id) DESC
LIMIT 9;








