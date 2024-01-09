CREATE TABLE appleStore_description_combined AS

SELECT * FROM appleStore_description1
UNION ALL
SELECT * FROM appleStore_description2
UNION ALL 
SELECT * FROM appleStore_description3
UNION ALL
SELECT * FROM appleStore_description4


**Exploratory Data Analysis**
--check the number of unique apps in both tablesAppleStore

SELECT count(DISTINCT id) AS UniqueAppIDs
FROM AppleStore

SELECT count(DISTINCT id) AS UniqueAppIDs
FROM appleStore_description_combined

--check for any missing values in key fieldsAppleStore

SELECT COUNT(*) AS MissingValues
FROM AppleStore
WHERE track_name is NULL or user_rating is NULL OR prime_genre IS NULL

SELECT COUNT(*) as MissingValues
FROM appleStore_description_combined
WHERE app_desc is NULL

--Find out the number of apps per genre

SELECT prime_genre, COUNT(*) AS NumApps
FROM AppleStore
GROUP BY prime_genre
ORDER BY NumApps DESC

--Get an overview of apps ratings

SELECT min(user_rating) AS MinRating,
       max(user_rating) AS MaxRating,
       avg(user_rating) AS AvgRating
From AppleStore


**DATA ANALYSIS**
--Determine whether paid apps have higher ratings than free apps

SELECT CASE
			WHEN price > 0 THEN 'Paid'
            Else 'Free'
        end as App_Type,
        avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY App_Type

--Check if apps with more supported languages have higher ratings

SELECT CASE
			WHEN lang_num < 10 THEN '<10 languages'
            WHEN lang_num BETWEEN 10 AND 30 THEN '10-30 languages'
            ELSE '>30 languages'
         END AS language_bucket,
         avg(user_rating) AS Avg_Rating
FROM AppleStore
Group by language_bucket
ORDER BY Avg_Rating DESC


--Check genres with low ratings

SELECT prime_genre,
	   avg(user_rating) AS Avg_Rating
from AppleStore
GROUP by prime_genre
Order by Avg_Rating ASC
LIMIT 10

--Check if there is correlation between the length of the app description and the user rating


SELECT CASE
			WHEN length(b.app_desc) <500 THEN 'Short'
            WHEN length(b.app_desc) between 500 and 1000 then 'Medium'
            ELSE 'Long'
          END AS description_length_bucket,
          avg(a.user_rating) AS average_rating
FROM
    AppleStore as a
JOIN
    appleStore_description_combined as b 
ON a.id = b.id

GROUP by description_length_bucket
ORDER BY average_rating DESC


--Check top-rated app for each genre

SELECT prime_genre,
	   track_name,
       user_rating
FROM (
       SELECT
  		prime_genre
  		track_name
  		user_rating
  		RANK() OVER( PARTITION BY prime_genre ORDER BY user_rating DESC, rating_count_tot DESC) AS rank
        fROM 
        applestore
  ) AS a
  WHERE 
  a.rank = 1