-- Q1. Airlines

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q1 CASCADE;

CREATE TABLE q1 (
    pass_id INT,
    name VARCHAR(100),
    airlines INT
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS intermediate_step CASCADE;





-- Define views for your intermediate steps here:
DROP VIEW IF EXISTS atleastone CASCADE;
CREATE VIEW atleastone AS 
SELECT passenger.id AS pass_id, firstname||' '||surname AS name, count(DISTINCT booking.flight_id) AS airlines
FROM passenger, departure, booking
WHERE passenger.id = booking.pass_id and departure.flight_id = booking.flight_id and now()>departure.datetime
GROUP BY passenger.id;

DROP VIEW IF EXISTS noflights CASCADE;
CREATE VIEW noflights AS 
SELECT passenger.id AS pass_id, firstname||' '||surname AS name, 0 AS airlines
FROM passenger, departure, booking
WHERE passenger.id = booking.pass_id and departure.flight_id = booking.flight_id and now()<=departure.datetime
GROUP BY passenger.id;

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q1
SELECT * FROM atleastone UNION SELECT * FROM noflights;