
-- See http://www.codinghorror.com/blog/2007/10/a-visual-explanation-of-sql-joins.html
-- for a good overview of teh different types of JOIN

DROP table events;
CREATE TABLE events (
event_id SERIAL PRIMARY KEY,
title varchar(255),
starts TIMESTAMP,
ends TIMESTAMP,
venue_id integer REFERENCES venues
);


insert into events (title, starts, ends, venue_id, event_id) VALUES
('LARP Club', '2012-02-15 17:30:00',  '2012-02-15 19:30:00', 2, 1),
('April Fools Day', '2012-04-01 00:00:00', '2012-04-01 23:59:00', NULL, 2),
('Christmas Day', '2012-12-25 00:00:00', '2012-12-25 23:59:00', NULL, 3)
;

-- All My tables
select * from pg_class where relkind='r' and relowner=16384;


SELECT c.country_name
FROM countries c
JOIN venues v ON c.country_code=v.country_code
JOIN events e ON e.venue_id = v.venue_id AND e.title='LARP Club';


ALTER TABLE venues ADD COLUMN active BOOLEAN DEFAULT true;
