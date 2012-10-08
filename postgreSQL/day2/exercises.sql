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

CREATE RULE insert_holidays AS ON INSERT TO holidays DO INSTEAD
INSERT INTO events (title, starts, ends, venue_id)
