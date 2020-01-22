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

