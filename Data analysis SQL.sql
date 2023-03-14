create database world;
use world;

 create table Employee(employee_id int primary key, last_name varchar(250), first_name varchar(250), title varchar(250),
 reports_to varchar(250), levels varchar(100),birthdate varchar(50), hire_date varchar(100), address varchar(250), city varchar(100), 
 state varchar(100), country varchar(200),postal_code varchar(100), phone varchar(100), fax varchar(100), email varchar(100));
 select * from employee;
 
 create table customer(customer_id int primary key, first_name varchar(200), last_name varchar(200), company varchar(200) default null, 
 address varchar(200), city varchar(200), state varchar(200) default null, country varchar(200), postal_code varchar(200) default null,
 phone varchar(200) default null, fax varchar(200) default null, email varchar(200), 
 support_rep_id int not null ,constraint rk_contraint_support_rep_id foreign key (support_rep_id) references Employee(employee_id) on update cascade on delete cascade);
 select * from customer;
 
 
 create table invoice(invoice_id int primary key, customer_id int not null, invoice_date varchar(200), billing_address varchar(200), billing_city varchar(200),
  billing_state varchar(200), billing_country varchar(200), billing_postal_code varchar(200), total decimal(5,2), constraint rk_contraint_customer_id 
  foreign key (customer_id) references customer(customer_id) on update cascade on delete cascade);
select * from invoice;

create table artist(artist_id int primary key not null, aname varchar(200));
select * from artist;

create table album(album_id int primary key not null, title varchar(200), artist_id int not null, constraint rk_constraint_artist_id 
foreign key (artist_id) references artist(artist_id) on update cascade on delete cascade);
select * from album;

create table genre(genre_id int primary key not null, gname varchar(200));
select * from genre;

create table media_type(media_type_id int primary key not null, mname varchar(200));
select * from media_type;
  
create table track(track_id int primary key not null, tname varchar(200), album_id int not null, media_type_id int not null, genre_id int not null, 
composer varchar(200)default null,milliseconds int, bytes int, unit_price decimal(5,2),constraint rk_constraint_media_type_id
 foreign key (media_type_id) references media_type(media_type_id) on update cascade on delete cascade, constraint rk_constraint_genre_id
 foreign key (genre_id) references genre(genre_id) on update cascade on delete cascade, constraint rk_constraint_album_id foreign key
 (album_id) references album(album_id) on update cascade on delete cascade);
select * from track;
  
create table invoice_line(invoice_line_id int primary key not null, invoice_id int not null, track_id int not null, 
unite_price decimal(5,2) not null, quantity int not null, constraint rk_constraint_invoice_id foreign key (invoice_id) references
invoice(invoice_id) on update cascade on delete cascade, constraint rk_constraint_track_id foreign key (track_id) references track(track_id)
on update cascade on delete cascade);
select * from invoice_line;

create table playlist(playlist_id int primary key not null, pname varchar(200));
select * from playlist;

create table playlist_track(playlist_id int not null, track_id int not null, constraint rk_constraint_playlist_id foreign key
 (playlist_id) references playlist(playlist_id) on update cascade on delete cascade, constraint rk_constraint2_track_id foreign key (track_id) 
 references track(track_id) on update cascade on delete cascade);
 select * from playlist_track;
 
 
 #################### Question Set 1 - Easy ###################

## Who is the senior most employee based on job title?
select title, last_name, first_name from employee order by levels desc limit 1;

## Which countries have the most Invoices?
select billing_city, count(*) as numinvoices from invoice group by billing_city order by numinvoices desc limit 1;

## What are the top 3 values of total invoice?
select invoice_id , sum(total) as total_amount from invoice group by invoice_id order by total_amount desc limit 3;

## Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money.
### Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals
select billing_city as cityname, sum(total) as totalinvoices from invoice group by billing_city order by totalinvoices desc limit 1;

## Who is the best customer? The customer who has spent the most money will be declared the best customer. 
### Write a query that returns the person who has spent the most money
select c.customer_id, c.first_name, c.last_name, sum(i.total) as total_spent from customer c, invoice i where c.customer_id = i.customer_id 
group by c. customer_id order by total_spent desc limit 1;

######################## Question Set 2 – Moderate ###########################


# Write a query to return the email, first name, last name, & Genre of all Rock Music listeners. 
## Return your list ordered alphabetically by email starting with A
select distinct email, first_name, last_name, gname from customer inner join invoice on customer.customer_id = invoice.customer_id 
inner join invoice_line on invoice.invoice_id = invoice_line.invoice_id inner join track on invoice_line.track_id = track.track_id 
inner join genre on track.genre_id = genre.genre_id where genre.gname ='Rock' order by email;

## Let's invite the artists who have written the most rock music in our dataset. 
### Write a query that returns the Artist name and total track count of the top 10 rock bands
select artist.aname as artist_name, count(track.track_id) as total_track_count from artist join album on artist.artist_id = album.artist_id 
join track on album.album_id = track.album_id join genre on track.genre_id = genre.genre_id where genre.gname = 'Rock'
 group by artist.aname order by total_track_count desc limit 10;
 
 ## Return all the track names that have a song length longer than the average song length. 
 ### Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first
 select tname, milliseconds from track where milliseconds > (select avg(milliseconds) from track) order by milliseconds desc;
 
 ################################ Question Set 3 – Advance ########################

## Find how much amount is spent by each customer on artists? Write a query to return customer name, artist name and total spent
select concat(customer.first_name,'',customer.last_name) as 'customer name', artist.aname as 'artist name', sum(invoice_line.unite_price  
* invoice_line.quantity) as 'total spent' from customer inner join invoice on customer.customer_id = invoice.customer_id  inner join 
invoice_line on invoice.invoice_id = invoice_line.invoice_id inner join track on invoice_line.track_id = track.track_id inner join 
album on track.album_id = album.album_id inner join artist on album.artist_id = artist.artist_id group by customer.customer_id ,
artist.artist_id order by 'customer name', 'total spent' desc;

## We want to find out the most popular music Genre for each country. 
### We determine the most popular genre as the genre with the highest amount of purchases. 
### Write a query that returns each country along with the top Genre. 
### For countries where the maximum number of purchases is shared return all Genres
select c.country as country, gname as TOP_genre, sum(il.quantity) as purchases from customer c inner join invoice i 
on c.customer_id = i.customer_id join invoice_line il on i.invoice_id = il.invoice_id join track t on il.track_id = t.track_id
join genre g on t.genre_id = g.genre_id
group by gname,c.country
order by c.country;

## Write a query that determines the customer that has spent the most on music for each country. 
### Write a query that returns the country along with the top customer and how much they spent. 
### For countries where the top amount spent is shared, provide all customers who spent this amount
select c.country as Country, concat(c.first_name,' ',c.last_name) as Customer_Name,  sum(invoice_line.unite_price) 
as Total_Spent from customer c join invoice on c.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
group by c.country, Customer_Name
order by Country;

