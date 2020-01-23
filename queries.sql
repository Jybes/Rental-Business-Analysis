/*QUESTION 1: We want to understand more about the movies that families are watching. The following categories are considered family movies: Animation, Children, Classics, Comedy, Family and Music.
Create a query that lists each movie, the film category it is classified in, and the number of times it has been rented out.*/

/*QUERY 1.1: To obtain the rental count of each film*/
(SELECT film_id, title, COUNT(*) AS rental_count
FROM   (SELECT f.film_id, f.title, inv.inventory_id, r.rental_id
          FROM film f
          JOIN inventory inv
            ON f.film_id = inv.film_id
          JOIN rental r
            ON inv.inventory_id = r.inventory_id) AS T1
GROUP BY 1, 2
ORDER BY 2
) AS T3;

/*QUERY 1.2: To obtain family-friendly film categories*/
(SELECT f.title, c.name
 FROM film f
 JOIN film_category fc
 ON f.film_id = fc.film_id
 JOIN category c
 ON c.category_id = fc.category_id
 WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')) AS T2;

/*QUERY 1.3: To obtain the rental count of each family-friendly film (the required table)*/
SELECT T2.title, T2.name, T3.rental_count
FROM
	(SELECT film_id, title, COUNT(*) rental_count
	 FROM (SELECT f.film_id, f.title, 	inv.inventory_id, r.rental_id
	       FROM film f
	       JOIN inventory inv
	       ON f.film_id = inv.film_id
	       JOIN rental r
	       ON inv.inventory_id = r.inventory_id) AS T1
	 GROUP BY 1, 2
	 ORDER BY 2) AS T3
JOIN
        (SELECT f.title, c.name
     	 FROM film f
 	 JOIN film_category fc
         ON f.film_id = fc.film_id
         JOIN category c
         ON c.category_id = fc.category_id
         WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')) AS T2
ON T2.title = T3.title
ORDER BY 2, 1;



/*QUESTION 2: Now we need to know how the length of rental duration of these family-friendly movies compares to the duration that all movies are rented for. Provide a table with the movie titles and divide them into 4 levels (first_quarter, second_quarter, third_quarter, and final_quarter) based on the quartiles (25%, 50%, 75%) of the rental duration for movies across all categories. Make sure to also indicate the category that these family-friendly movies fall into.*/

/*QUERY 2.1: To obtain the quartile of the rental duration of each film*/
SELECT f.title, c.name, f.rental_duration, NTILE(4) OVER (ORDER BY rental_duration) AS standard_quartile
FROM film f
JOIN film_category fc
ON f.film_id = fc.film_id
JOIN category c
ON c.category_id = fc.category_id

/*QUERY 2.2: To obtain the average rental duration of all films*/
SELECT AVG (rental_duration) AS avg_rental_overall
FROM     (SELECT f.title, c.name, f.rental_duration, NTILE(4) OVER (PARTITION BY c.name ORDER BY rental_duration) AS standard_quartile
          FROM film f
	  JOIN film_category fc
	  ON f.film_id = fc.film_id
	  JOIN category c
	  ON c.category_id = fc.category_id) AS T1

/*QUERY 2.3: To obtain the quartile of the rental duration of family-friendly films*/
SELECT f.title, c.name, f.rental_duration, NTILE(4) OVER (PARTITION BY c.name ORDER BY rental_duration) AS standard_quartile
FROM film f
JOIN film_category fc
ON f.film_id = fc.film_id
JOIN category c
ON c.category_id = fc.category_id
WHERE name  IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')

/*QUERY 2.4: To obtain the average rental duration of family-friendly films*/
SELECT AVG (rental_duration) AS avg_duration_family_movies
FROM   	   (SELECT f.title, c.name, f.rental_duration, NTILE(4) OVER (PARTITION BY c.name ORDER BY rental_duration) AS standard_quartile
	    FROM film f
	    JOIN film_category fc
	    ON f.film_id = fc.film_id
	    JOIN category c
	    ON c.category_id = fc.category_id
     	    WHERE name  IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')) AS T2



/*QUESTION 3: Provide a table with the family-friendly film category, each of the quartiles, and the corresponding count of movies within each combination of film category for each corresponding rental duration category. The resulting table should have three columns: Category, Rental length category, and Count.*/

/*QUERY 3.1: To obtain a count of each quartile level per family-friendly film category (required table)*/
WITH T1 AS
   (SELECT f.title, c.name, f.rental_duration, NTILE(4) OVER (PARTITION BY c.name ORDER BY rental_duration) AS standard_quartile
	FROM film f
	JOIN film_category fc
	ON f.film_id = fc.film_id
	JOIN category c
	ON c.category_id = fc.category_id
	WHERE name  IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music'))

SELECT name, standard_quartile, COUNT(*)
FROM T1
GROUP BY 1, 2
ORDER BY 1, 2



/*QUESTION 4: We would like to know who were our top 10 paying customers, how many payments they made on a monthly basis during 2007, and what was the amount of the monthly payments. Write a query to capture the customer name, month and year of payment, and total payment amount for each month by these top 10 paying customers.*/

/*QUERY 4.1: To obtain the pay month, customer's full name, monthly pay count, and amount paid*/
WITH T1 AS (SELECT DATE_TRUNC('month', p.payment_date) AS paymonth, CONCAT(c.first_name, ' ', c.last_name) AS fullname, COUNT(*) AS pay_countpermon, SUM(p.amount) AS pay_amount
FROM payment p
JOIN customer c
ON p.customer_id = c.customer_id
GROUP BY 1, 2
ORDER BY 2, 1),

/*QUERY 4.2: To obtain the top ten paying customers*/
T2 AS (SELECT fullname, SUM(pay_amount) AS tot_sum
FROM T1
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10)

/*QUERY 4.3: To select from query 4.1 only the top ten paying customers*/
SELECT T1.paymonth, T1.fullname, T1.pay_countpermon, T1.pay_amount
FROM T1
JOIN T2
ON T1.fullname = T2.fullname
