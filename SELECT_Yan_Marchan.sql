-- Task 1: Highest Revenue by Staff for Each Store in 2017
-- Solution 1
SELECT s.store_id, st.staff_id, SUM(p.amount) AS total_revenue
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN staff st ON r.staff_id = st.staff_id
JOIN store s ON st.store_id = s.store_id
WHERE YEAR(p.payment_date) = 2017
GROUP BY s.store_id, st.staff_id
ORDER BY s.store_id, total_revenue DESC;


-- Solution 2
 WITH RevenueRank AS (
    SELECT s.store_id, st.staff_id, SUM(p.amount) AS total_revenue,
    ROW_NUMBER() OVER(PARTITION BY s.store_id ORDER BY SUM(p.amount) DESC) AS rn
    FROM payment p
    JOIN rental r ON p.rental_id = r.rental_id
    JOIN staff st ON r.staff_id = st.staff_id
    JOIN store s ON st.store_id = s.store_id
    WHERE YEAR(p.payment_date) = 2017
    GROUP BY s.store_id, st.staff_id
)
SELECT store_id, staff_id, total_revenue
FROM RevenueRank
WHERE rn = 1;


-- Task 2: Top Five Rented Movies and Expected Audience Age
-- Solution 1
SELECT f.title, COUNT(r.rental_id) AS rental_count, f.rating
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
GROUP BY f.film_id
ORDER BY rental_count DESC
LIMIT 5;

-- Solution 2
SELECT title, rental_count, rating
FROM (
    SELECT f.title, COUNT(r.rental_id) AS rental_count, f.rating,
    ROW_NUMBER() OVER (ORDER BY COUNT(r.rental_id) DESC) AS rn
    FROM rental r
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film f ON i.film_id = f.film_id
    GROUP BY f.film_id
) AS RankedMovies
WHERE rn <= 5;

-- Task 3: Actors/Actresses with Longest Inactivity Period
-- Solution 1
SELECT a.actor_id, a.first_name, a.last_name, MAX(r.rental_date) AS last_rental_date
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY a.actor_id
ORDER BY last_rental_date ASC;

-- Solution 2
WITH ActorRental AS (
    SELECT a.actor_id, a.first_name, a.last_name, r.rental_date,
    ROW_NUMBER() OVER (PARTITION BY a.actor_id ORDER BY r.rental_date DESC) AS rn
    FROM actor a
    JOIN film_actor fa ON a.actor_id = fa.actor_id
    JOIN film f ON fa.film_id = f.film_id
    JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
)
SELECT actor_id, first_name, last_name, rental_date AS last_rental_date
FROM ActorRental
WHERE rn = 1
ORDER BY last_rental_date ASC;
