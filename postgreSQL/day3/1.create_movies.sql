CREATE EXTENSION cube;


DROP TABLE genres CASCADE;
DROP TABLE movies CASCADE;
DROP TABLE actors CASCADE;

CREATE TABLE genres (
	name text UNIQUE,
	position integer
);
CREATE TABLE movies (
	movie_id SERIAL PRIMARY KEY,
	title text,
	genre cube
);
CREATE TABLE actors (
	actor_id SERIAL PRIMARY KEY,
	name text
);

