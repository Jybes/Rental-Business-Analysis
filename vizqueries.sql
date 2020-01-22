/*VISUALIZATION QUERY 1: TO OBTAIN THE TOTAL RENTAL ORDERS BY EACH FAMILY_FRIENDLY FILM CATEGORY*/
SELECT name, SUM(rental_count)
FROM (SELECT T2.title, T2.name, T3.rental_count
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
ORDER BY 2, 1) AS T4
GROUP BY 1;



/*VISUALIZATION QUERY 2: TO OBTAIN THE AVERAGE LENGTH OF RENTAL DURATION FOR ALL MOVIES AND FAMILY-FRIENDLY MOVIES*/
SELECT T3.all_movies, T4.family_movies
FROM (SELECT name, AVG (rental_duration) OVER()         AS all_movies
      FROM (SELECT f.title, c.name, f.rental_duration, NTILE(4) OVER (PARTITION BY c.name ORDER BY rental_duration) AS standard_quartile
	        FROM film f
	  		JOIN film_category fc
	  		ON f.film_id = fc.film_id
	  		JOIN category c
	  		ON c.category_id = fc.category_id) AS T1)   AS T3

JOIN (SELECT name, AVG (rental_duration) OVER() 	  AS family_movies
	  FROM (SELECT f.title, c.name, f.rental_duration, NTILE(4) OVER (PARTITION BY c.name ORDER BY rental_duration) AS standard_quartile
			FROM film f
			JOIN film_category fc
			ON f.film_id = fc.film_id
			JOIN category c
			ON c.category_id = fc.category_id
     		WHERE name  IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')) AS T2) 
      AS T4
ON T3.name = T4.name
LIMIT 1



/*VISUALIZATION QUERY 3: TO OBTAIN A CLEARER VIEW OF QUERY 3.1*/
WITH T1 AS
	(SELECT f.title, c.name, f.rental_duration, NTILE(4) OVER (PARTITION BY c.name ORDER BY rental_duration) AS standard_quartile
	 FROM film f
	 JOIN film_category fc
	 ON f.film_id = fc.film_id
	 JOIN category c
	 ON c.category_id = fc.category_id),
    
T2 AS
	(SELECT COUNT(*) AS animation, CASE WHEN standard_quartile = 1 THEN '1st Quartile'
WHEN standard_quartile = 2 THEN '2nd Quartile'
WHEN standard_quartile = 3 THEN '3rd Quartile'
ELSE '4th Quartile' END AS standard_quartile 
	 FROM T1
	 WHERE name = 'Animation'
	 GROUP BY 2
	 ORDER BY 2),

T3 AS
	(SELECT COUNT(*) AS children, CASE WHEN standard_quartile = 1 THEN '1st Quartile'
WHEN standard_quartile = 2 THEN '2nd Quartile'
WHEN standard_quartile = 3 THEN '3rd Quartile'
ELSE '4th Quartile' END AS standard_quartile 
	 FROM T1
	 WHERE name = 'Children'
	 GROUP BY 2
	 ORDER BY 2),
    
T4 AS
	(SELECT COUNT(*) AS classics, CASE WHEN standard_quartile = 1 THEN '1st Quartile'
WHEN standard_quartile = 2 THEN '2nd Quartile'
WHEN standard_quartile = 3 THEN '3rd Quartile'
ELSE '4th Quartile' END AS standard_quartile 
	 FROM T1
	 WHERE name = 'Classics'
	 GROUP BY 2
	 ORDER BY 2),
    
T5 AS
	(SELECT COUNT(*) AS comedy, CASE WHEN standard_quartile = 1 THEN '1st Quartile'
WHEN standard_quartile = 2 THEN '2nd Quartile'
WHEN standard_quartile = 3 THEN '3rd Quartile'
ELSE '4th Quartile' END AS standard_quartile 
	 FROM T1
	 WHERE name = 'Comedy'
	 GROUP BY 2
	 ORDER BY 2),
    
T6 AS
	(SELECT COUNT(*) AS family, CASE WHEN standard_quartile = 1 THEN '1st Quartile'
WHEN standard_quartile = 2 THEN '2nd Quartile'
WHEN standard_quartile = 3 THEN '3rd Quartile'
ELSE '4th Quartile' END AS standard_quartile 
	 FROM T1
	 WHERE name = 'Family'
	 GROUP BY 2
	 ORDER BY 2),
    
T7 AS
	(SELECT COUNT(*) AS music, CASE WHEN standard_quartile = 1 THEN '1st Quartile'
WHEN standard_quartile = 2 THEN '2nd Quartile'
WHEN standard_quartile = 3 THEN '3rd Quartile'
ELSE '4th Quartile' END AS standard_quartile 
	 FROM T1
	 WHERE name = 'Music'
	 GROUP BY 2
	 ORDER BY 2)

SELECT T2.standard_quartile, T2.animation, T3.children, T4.classics, T5.comedy, T6.family, T7.music
FROM T2
JOIN T3
ON T2.standard_quartile = T3.standard_quartile
JOIN T4
ON T3.standard_quartile = T4.standard_quartile
JOIN T5
ON T4.standard_quartile = T5.standard_quartile
JOIN T6
ON T5.standard_quartile = T6.standard_quartile
JOIN T7
ON T6.standard_quartile = T7.standard_quartile



/*VISUALIZATION QUERY 4: TO SHOW THE TOP TEN PAYING CUSTOMERS AND THEIR TOTAL PAYMENT */
WITH T1 AS (SELECT DATE_TRUNC('month', p.payment_date) AS paymonth, CONCAT(c.first_name, ' ', c.last_name) AS fullname, COUNT(*) AS pay_countpermon, SUM(p.amount) AS pay_amount
FROM payment p
JOIN customer c
ON p.customer_id = c.customer_id
GROUP BY 1, 2
ORDER BY 2, 1)

SELECT fullname, SUM(pay_amount) AS tot_sum
FROM T1
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10