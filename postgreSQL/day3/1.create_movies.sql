CREATE EXTENSION cube;
CREATE EXTENSION fuzzystrmatch;
CREATE EXTENSION tablefunc;
CREATE EXTENSION pg_trgm;
CREATE EXTENSION dict_xsyn;


DROP TABLE genres CASCADE;
DROP TABLE movies CASCADE;
DROP TABLE actors CASCADE;
DROP TABLE movies_actors CASCADE;

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
CREATE TABLE movies_actors (
	movie_id integer REFERENCES movies NOT NULL,
	actor_id integer REFERENCES actors NOT NULL,
	UNIQUE (movie_id, actor_id)
);
CREATE INDEX movies_actors_movie_id ON movies_actors (movie_id);
CREATE INDEX movies_actors_actor_id ON movies_actors (actor_id);
CREATE INDEX movies_genres_cube ON movies USING gist (genre);


CREATE INDEX movies_title_pattern ON movies (lower(title) text_pattern_ops);

CREATE INDEX movies_title_trigram ON movies
USING gist (title gist_trgm_ops);

CREATE INDEX movies_title_searchable ON movies
USING gin(to_tsvector('english', title));


