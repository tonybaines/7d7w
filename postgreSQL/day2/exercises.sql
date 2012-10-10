-- http://www.postgresql.org/docs/9.2/static/functions-aggregate.html

-- I needed to add these records too
insert into cities (name, postal_code, country_code) values ('Ipswich', 'IP4 4QZ', 'gb');
insert into venues (name, postal_code, country_code) values ('My Place', 'IP4 4QZ', 'gb');

INSERT INTO events (title, starts, ends, venue_id)
VALUES ('Moby', '2012-02-06 21:00', '2012-02-06 23:00', (
SELECT venue_id
FROM venues
WHERE name = 'Crystal Ballroom'
)
);


INSERT INTO events (title, starts, ends, venue_id)
VALUES ('Wedding', '2012-02-26 21:00:00', '2012-02-26 23:00:00', (SELECT venue_id FROM venues WHERE name = 'Voodoo Donuts')),
('Dinner with Mom', '2012-02-26 18:00:00', '2012-02-26 20:30:00', (SELECT venue_id FROM venues WHERE name = 'My Place')),
('Valentine''s Day', '2012-02-14 00:00:00', '2012-02-14 23:59:00', NULL)
;

-- INSERT rule
CREATE RULE insert_holidays AS ON INSERT TO holidays DO INSTEAD
INSERT INTO events (title, starts, colors)
VALUES (NEW.name, NEW.date, NEW.colors);

insert into holidays (name, date, colors) values ('Birth Day', '1970-08-02 00:00:00', '{"blue"}');


-- Create a rule that captures DELETEs on venues and instead sets the active
-- flag (created in the Day 1 homework) to FALSE.

CREATE RULE inactivate_venues AS ON DELETE TO venues DO INSTEAD
UPDATE venues
SET active = FALSE
WHERE venue_id = OLD.venue_id; 

--book=# delete from venues where venue_id = 7;
--DELETE 0
--book=# select * from venues;
-- venue_id |       name       | street_address |  type   | postal_code | country_code | active 
------------+------------------+----------------+---------+-------------+--------------+--------
--        1 | Crystal Ballroom |                | public  | 97205       | us           | t
--        2 | Voodoo Donuts    |                | public  | 97205       | us           | t
--        8 | Run's House      |                | public  | 97205       | us           | t
--        7 | My Place         |                | public  | IP4 4QZ     | gb           | f
--(4 rows)



-- A temporary table was not the best way to implement our event calendar
-- pivot table. The generate_series(a, b) function returns a set of records, from
-- a to b. Replace the month_count table SELECT with this.

SELECT * FROM crosstab(
'SELECT extract(year from starts) as year,
extract(month from starts) as month, count(*)
FROM events
GROUP BY year, month',
'SELECT * FROM generate_series(1,12)'
) AS (
year int,
jan int, feb int, mar int, apr int, may int, jun int,
jul int, aug int, sep int, oct int, nov int, dec int
) ORDER BY YEAR;


-- Build a pivot table that displays every day in a single month, where each
-- week of the month is a row and each day name forms a column across
-- the top (seven days, starting with Sunday and ending with Saturday) like a
-- standard month calendar. Each day should contain a count of the number
-- of events for that date or should remain blank if no event occurs.
--
-- From http://www.postgresonline.com/journal/archives/14-CrossTab-Queries-in-PostgreSQL-using-tablefunc-contrib.html
-- There are a couple of key points to keep in mind which apply to both crosstab functions.
--
-- 1. Source SQL must always return 3 columns, first being what to use for row header, second the bucket slot, 
-- and third is the value to put in the bucket.
-- 2. crosstab except for the example crosstab3 ..crosstabN versions return unknown record types. This means 
-- that in order to use them in a FROM clause, you need to either alias them by specifying the result type 
-- or create a custom crosstab that outputs a known type as demonstrated by the crosstabN flavors. Otherwise 
-- you get the common a column definition list is required for functions returning "record" error.
-- 3. A corrollary to the previous statement, it is best to cast those 3 columns to specific data types so you 
-- can be guaranteed the datatype that is returned so it doesn't fail your row type casting.
-- 4. Each row should be unique for row header, bucket otherwise you get unpredictable results

-- event_id |      title      |       starts        |        ends         | venue_id |   colors    
------------+-----------------+---------------------+---------------------+----------+-------------
--        1 | LARP Club       | 2012-02-15 17:30:00 | 2012-02-15 19:30:00 |        2 | 
--        2 | April Fools Day | 2012-04-01 00:00:00 | 2012-04-01 23:59:00 |          | 
--        4 | Wedding         | 2012-02-26 21:00:00 | 2012-02-26 23:00:00 |        2 | 
--        6 | Valentine's Day | 2012-02-14 00:00:00 | 2012-02-14 23:59:00 |          | 
--        7 | Moby            | 2012-02-06 21:00:00 | 2012-02-06 23:00:00 |        1 | 
--        5 | Dinner with Mom | 2012-02-26 18:00:00 | 2012-02-26 20:30:00 |        7 | 
--        8 | House Party     | 2012-05-03 23:00:00 | 2012-05-04 01:00:00 |        8 | 
--        3 | Christmas Day   | 2012-12-25 00:00:00 | 2012-12-25 23:59:00 |          | {red,green}
--        9 | Birth Day       | 1970-08-02 00:00:00 |                     |          | {blue}
--
SELECT * from crosstab(
'SELECT 
	extract(week from starts) as week,
	extract(dow from starts) as dow,
	count(*)
 FROM events
 WHERE extract(month from starts)=2
 GROUP BY week, dow
 ORDER BY week',
'SELECT * from generate_series(0,6)'
)
AS (
Week int,
Sunday int, Monday int, Tuesday int, Wednesday int, Thursday int, Friday int, Saturday int);

-- week | sunday | monday | tuesday | wednesday | thursday | friday | saturday 
--------+--------+--------+---------+-----------+----------+--------+----------
--    6 |        |      1 |         |           |          |        |         
--    7 |        |        |       1 |         1 |          |        |         
--    8 |      2 |        |         |           |          |        |         

