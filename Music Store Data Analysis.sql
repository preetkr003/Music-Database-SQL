-- EASY
-- Who is the Senior most employee based on job title?
Select *
From employee
Order By levels Desc
Limit 1;

-- Which countries have the most Invoices?
Select billing_country, Count(*) AS Invoices
From invoice
Group By billing_country
Order By Invoices Desc;

-- What are top 3 values of invoice?
Select *
From invoice
Order By total DESC
Limit 3;

-- Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
--Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals.
Select billing_city AS city, SUM(total) AS total
From invoice
Group By billing_city
Order By total Desc
Limit 1;

-- Who is the best customer? The customer who has spent the most money will be declared the best customer. 
--Write a query that returns the person who has spent the most money.
Select customer.customer_id, customer.first_name, customer.last_name, Sum(invoice.total) AS total
From customer
Inner Join invoice ON customer.customer_id = invoice.customer_id
Group By customer.customer_id
Order By total Desc
Limit 1;


-- MEDIUM
--WAQ to return the email, first_name, last_name and genre of all Rock Music listeners. 
--Return your list ordered alphabetically by email starting with A.
Select Distinct c.first_name, c.last_name, c.email AS email
From customer AS c
Join invoice ON c.customer_id = invoice.customer_id
Join invoice_line ON invoice.invoice_id = invoice_line.invoice_id
Join track ON track.track_id = invoice_line.track_id
Join genre ON genre.genre_id = track.genre_id
Where genre.name = 'Rock'
Order By email;
-- OR
Select Distinct c.first_name, c.last_name, c.email AS email
From customer AS c
Join invoice ON c.customer_id = invoice.customer_id
Join invoice_line ON invoice.invoice_id = invoice_line.invoice_id
Where track_id IN(
	Select track_id 
	From track
	Join genre ON track.genre_id = genre.genre_id
	Where genre.name = 'Rock'
)
Order By email;

-- Let's invite the artists who have written the most rock music in our dataset. 
-- WAQ that returns the Artist name & total track count of the top 10 rock bands.
Select artist.artist_id, artist.name, Count(artist.artist_id) AS number_of_songs
From artist
Join album ON artist.artist_id = album.artist_id
Join track ON album.album_id = track.album_id
Join genre ON track.genre_id = genre.genre_id
Where genre.name = 'Rock'
Group By artist.artist_id
Order By number_of_songs Desc
Limit 10;

--Return all the track names that have a song length longer than the average song length. Return the Name & Milliseconds for each track.
-- Order by the song length with the longest songs listed first.
Select name, milliseconds 
From track
Where milliseconds > (
	Select Avg(milliseconds)
	From track
)
Order By milliseconds Desc;


-- HARD
-- Find how much amount spent by each customer on artists? WAQ to return customer name, artist name & total spent.
WITH best_selling_artist AS (
	Select artist.artist_id AS artist_id_num,
		artist.name AS artist_name,
		Sum(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	From invoice_line
	Join track ON invoice_line.track_id = track.track_id
	Join album ON track.album_id = album.album_id
	Join artist ON album.artist_id = artist.artist_id
	Group By artist_id_num
	Order By total_sales Desc
	Limit 1
)
Select c.customer_id,
		c.first_name,
		c.last_name,
		bsa.artist_name,
		Sum(invoice_line.unit_price*invoice_line.quantity) AS amount_spent
From invoice
Join customer AS c ON c.customer_id = invoice.customer_id
Join invoice_line ON invoice_line.invoice_id = invoice.invoice_id
Join track ON invoice_line.track_id = track.track_id
Join album ON track.album_id = album.album_id
Join best_selling_artist AS bsa ON album.artist_id = bsa.artist_id_num
Group By c.customer_id,
			c.first_name,
			c.last_name,
			bsa.artist_name
Order By amount_spent Desc;

-- We want to find out the most popular music genre for each of the country. 
-- We determine most popular genre as the genre with the highest amount of purchases. WAQ that returns each country along with top genre.
-- For countries where the maximum number of purchases is shared return all genres.
WITH popular_genre AS
(
	Select Count(invoice_line.quantity) AS purchases,
			customer.country,
			genre.genre_id,
			genre.name,
			Row_Number() Over(Partition By customer.country Order By Count(invoice_line.quantity) Desc) AS RowNo
	From invoice_line
	Join invoice ON invoice_line.invoice_id = invoice.invoice_id
	Join customer ON invoice.customer_id = customer.customer_id
	Join track ON invoice_line.track_id = track.track_id
	Join genre On track.genre_id = genre.genre_id
	Group By customer.country,
				genre.genre_id,
				genre.name
	Order By customer.country ASC,
				purchases Desc
)
Select *
From popular_genre
Where RowNo <= 1;

-- 	WAQ that determines the customer that has spent the most on music for each country.
-- WAQ that returns the country along with the top customer & how much they spent. 
-- For countries whre the top amount spent is shared, provide all customers who spent this amount.
WITH Customer_with_country AS
(
	Select customer.customer_id,
			customer.first_name,
			customer.last_name,
			invoice.billing_country,
			Sum(invoice.total) AS total_spending,
			Row_Number() Over(Partition By invoice.billing_country Order By Sum(invoice.total) Desc) AS RowNo
	From invoice
	Join customer ON invoice.customer_id = customer.customer_id
	Group By customer.customer_id,
				customer.first_name,
				customer.last_name,
				invoice.billing_country
	Order By invoice.billing_country ASC,
				RowNo Desc
)
Select *
From Customer_with_country
Where RowNo <=1;