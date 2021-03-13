-- Q4. Plane Capacity Histogram

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q4 CASCADE;

CREATE TABLE q4 (
	airline CHAR(2),
	tail_number CHAR(5),
	very_low INT,
	low INT,
	fair INT,
	normal INT,
	high INT
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS intermediate_step CASCADE;
DROP VIEW IF EXISTS twenty CASCADE;
DROP VIEW IF EXISTS forty CASCADE;
DROP VIEW IF EXISTS sixty CASCADE;
DROP VIEW IF EXISTS eighty CASCADE;
DROP VIEW IF EXISTS hundred CASCADE;

-- Define views for your intermediate steps here:
CREATE VIEW twenty AS
SELECT plane.airline AS airline, tail_number, count(DISTINCT flight.id) AS very_low
FROM flight, plane, booking
WHERE flight.id = booking.flight_id AND plane.airline = flight.airline AND plane.tail_number = flight.plane
GROUP BY plane.airline, tail_number, flight.id
HAVING ((100 * count(pass_id))/(capacity_economy+capacity_business+capacity_first)) BETWEEN 0 AND 19;

CREATE VIEW forty AS
SELECT plane.airline AS airline, tail_number, count(DISTINCT flight.id) AS low
FROM flight, plane, booking
WHERE flight.id = booking.flight_id AND plane.airline = flight.airline AND plane.tail_number = flight.plane
GROUP BY plane.airline, tail_number, flight.id
HAVING ((100 * count(pass_id))/(capacity_economy+capacity_business+capacity_first)) BETWEEN 20 AND 39;

CREATE VIEW sixty AS
SELECT plane.airline AS airline, tail_number, count(DISTINCT flight.id) AS fair
FROM flight, plane, booking
WHERE flight.id = booking.flight_id AND plane.airline = flight.airline AND plane.tail_number = flight.plane
GROUP BY plane.airline, tail_number, flight.id
HAVING ((100 * count(pass_id))/(capacity_economy+capacity_business+capacity_first)) BETWEEN 40 AND 59;

CREATE VIEW eighty AS 
SELECT plane.airline AS airline, tail_number, count(DISTINCT flight.id) AS normal
FROM flight, plane, booking 
WHERE flight.id = booking.flight_id AND plane.airline = flight.airline AND plane.tail_number = flight.plane
GROUP BY plane.airline, tail_number, flight.id
HAVING ((100 * count(pass_id))/(capacity_economy+capacity_business+capacity_first)) BETWEEN 60 AND 79;

CREATE VIEW hundred AS
SELECT plane.airline AS airline, tail_number, count(DISTINCT flight.id) AS high
FROM flight, plane, booking
WHERE flight.id = booking.flight_id AND plane.airline = flight.airline AND plane.tail_number = flight.plane
GROUP BY plane.airline, tail_number, flight.id
HAVING ((100 * count(pass_id))/(capacity_economy+capacity_business+capacity_first)) >= 80;


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q4
SELECT airline, tail_number, CASE WHEN very_low is NULL THEN 0 ELSE very_low END AS very_low,
CASE WHEN low is NULL THEN 0 ELSE low END AS low,
CASE WHEN fair is NULL THEN 0 ELSE fair END AS fair,
CASE WHEN normal is NULL THEN 0 ELSE normal END AS normal,
CASE WHEN high is NULL THEN 0 ELSE high END AS high
FROM twenty NATURAL FULL JOIN forty NATURAL FULL JOIN sixty NATURAL FULL JOIN eighty NATURAL FULL JOIN hundred;
