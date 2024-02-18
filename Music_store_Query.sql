--#senior most employee
SELECT first_name, last_name
FROM employee
WHERE reports_to is NULL;

--2) which countries have most invoices

SELECT billing_country,count(*) as invoice_count
FROM invoice
group by billing_country
order by invoice_count desc
limit 1;

--3) top 3 values of total invoice

SELECT customer_id,billing_country,total 
FROM invoice
ORDER BY total desc
limit 3;

--4) city has the best customers

SELECT billing_city, SUM(total) as sum_revenue
FROM invoice
GROUP BY billing_city
ORDER BY sum_revenue DESC
LIMIT 1;

--5) best customer

SELECT cus.customer_id, first_name, last_name, SUM(total) as cust_rev
FROM invoice inv
JOIN customer cus ON inv.customer_id = cus.customer_id
GROUP BY cus.customer_id
ORDER BY cust_rev DESC
LIMIT 1;

--#Rock music listeners

SELECT DISTINCT email, first_name, last_name
FROM customer cus
JOIN invoice inv on cus.customer_id = inv.customer_id
JOIN invoice_line invln on inv.invoice_id = invln.invoice_id
WHERE track_id IN (
SELECT track_id
FROM track
WHERE genre_id IN (SELECT genre_id
FROM genre
WHERE name = 'Rock'))
ORDER BY email;

--#Rock bands

SELECT artist.artist_id, artist.name, COUNT(artist.artist_id) as number_of_songs
FROM track 
JOIN album  on album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name = 'Rock'
GROUP BY artist.artist_id
order by number_of_songs DESC
limit 10;

--#Song duration comparison

SELECT track.name,milliseconds 
FROM track WHERE milliseconds > (SELECT AVG(milliseconds) AS avg_trk_length
FROM track)
ORDER BY milliseconds DESC;

--#customer vs artists

WITH best_selling_artists as (SELECT artist.artist_id,artist.name as artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) as total_rev
FROM invoice_line
JOIN track on track.track_id = invoice_line.track_id
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id	= album.artist_id	
GROUP BY artist.artist_id
ORDER BY total_rev DESC
LIMIT 1)

SELECT cus.customer_id,cus.first_name,cus.last_name,ba.artist_name, SUM(il.unit_price*il.quantity) as total_amt
FROM customer cus
JOIN invoice i ON cus.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track on track.track_id = il.track_id
JOIN album ON album.album_id = track.album_id
JOIN best_selling_artists ba ON ba.artist_id = album.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 desc;

--Countries vs genre

WITH top_gen as (SELECT customer.country AS country,genre.name as genre, COUNT(il.quantity) AS N_purchases, ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(il.quantity) DESC) AS rn
FROM invoice_line il
JOIN invoice i ON i.invoice_id = il.invoice_id
JOIN customer ON customer.customer_id = i.customer_id
JOIN track on track.track_id = il.track_id
JOIN genre on genre.genre_id = track.genre_id
GROUP BY 1,2
ORDER BY 1,3 DESC)

SELECT country,genre,rn
from top_gen
where rn=1

---Customer & country data

WITH customer_with_country as (SELECT cust.customer_id, first_name,last_name,billing_country, SUM(total), ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS rn
FROM invoice i
JOIN customer cust ON cust.customer_id = i.customer_id
GROUP BY 1,2,3,4
ORDER BY 4,5 DESC)

SELECT *
FROM customer_with_country
WHERE rn=1

