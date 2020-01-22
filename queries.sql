**SET1 QUESTION1**

/*QUERY 1.1: TO OBTAIN THE RENTAL COUNT OF EACH FILM*/
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

/*QUERY 1.2: TO OBTAIN FAMILY-FRIENDLY FILM CATEGORY*/
(SELECT f.title, c.name
 FROM film f 
 JOIN film_category fc
 ON f.film_id = fc.film_id
 JOIN category c
 ON c.category_id = fc.category_id
 WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')) AS T2;

/*QUERY 1.3: TO OBTAIN THE RENTAL COUNT OF EACH FAMILY-FRIENDLY FILM (REQUIRED TABLE)*/
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



**SET1 QUESTION 2**

/*QUERY 2.1: TO OBTAIN THE QUARTILE OF THE RENTAL DURATION OF EACH FILM (REQUIRED TABLE)*/
SELECT f.title, c.name, f.rental_duration, NTILE(4) OVER (ORDER BY rental_duration) AS standard_quartile
FROM film f
JOIN film_category fc
ON f.film_id = fc.film_id
JOIN category c
ON c.category_id = fc.category_id

/*QUERY 2.2: TO OBTAIN THE AVERAGE RENTAL DURATION OF ALL FILMS*/
SELECT AVG (rental_duration) AS avg_rental_overall
FROM     (SELECT f.title, c.name, f.rental_duration, NTILE(4) OVER (PARTITION BY c.name ORDER BY rental_duration) AS standard_quartile
          FROM film f
	  JOIN film_category fc
	  ON f.film_id = fc.film_id
	  JOIN category c
	  ON c.category_id = fc.category_id) AS T1

/*QUERY 2.3: TO OBTAIN THE QUARTILE OF THE RENTAL DURATION OF FAMILY-FRIENDLY FILMS*/
SELECT f.title, c.name, f.rental_duration, NTILE(4) OVER (PARTITION BY c.name ORDER BY rental_duration) AS standard_quartile
FROM film f
JOIN film_category fc
ON f.film_id = fc.film_id
JOIN category c
ON c.category_id = fc.category_id
WHERE name  IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')

/*QUERY 2.4: TO OBTAIN THE AVERAGE RENTAL DURATION OF FAMILY-FRIENDLY FILMS*/
SELECT AVG (rental_duration) AS avg_duration_family_movies
FROM   	   (SELECT f.title, c.name, f.rental_duration, NTILE(4) OVER (PARTITION BY c.name ORDER BY rental_duration) AS standard_quartile
	    FROM film f
	    JOIN film_category fc
	    ON f.film_id = fc.film_id
	    JOIN category c
	    ON c.category_id = fc.category_id
     	    WHERE name  IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')) AS T2