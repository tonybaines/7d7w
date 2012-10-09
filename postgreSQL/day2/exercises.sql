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

