-- Q2. Refunds!

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q2 CASCADE;

CREATE TABLE q2 (
    airline CHAR(2),
    name VARCHAR(50),
    year CHAR(4),
    seat_class seat_class,
    refund REAL
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS intermediate_step CASCADE;
DROP VIEW IF EXISTS domestic_five CASCADE;
DROP VIEW IF EXISTS domestic_ten CASCADE;
DROP VIEW IF EXISTS international_eight CASCADE;
DROP VIEW IF EXISTS international_twelve CASCADE;


-- Define views for your intermediate steps here:
CREATE VIEW domestic_five AS 
SELECT airline.code AS airline, airline.name as name, EXTRACT(YEAR FROM departure.datetime) as year, seat_class, 0.35 * sum(price) AS refund
FROM airline, departure, flight, booking, airport a1, airport a2, arrival
WHERE flight.airline = airline.code AND departure.flight_id = booking.flight_id AND arrival.flight_id = arrival.flight_id AND a1.code = flight.outbound and a2.code = flight.inbound AND a1.country = a2.country AND departure.datetime - flight.s_dep >= '0 days 05:00:00' AND departure.datetime - flight.s_dep < '0 days 10:00:00' AND EXTRACT(EPOCH FROM arrival.datetime - flight.s_arv) > (EXTRACT(EPOCH FROM departure.datetime - flight.s_dep)/2) 
GROUP BY airline.code, airline.name, seat_class, year
HAVING sum(price) > 0;


CREATE VIEW domestic_ten AS 
SELECT airline.code AS airline, airline.name as name, EXTRACT(YEAR FROM departure.datetime) as year, seat_class, 0.5 * sum(price) AS refund
FROM airline, departure, flight, booking, airport a1, airport a2, arrival
WHERE flight.airline = airline.code AND departure.flight_id = booking.flight_id AND a1.code = flight.outbound and a2.code = flight.inbound AND a1.country = a2.country AND departure.datetime - flight.s_dep >= '0 days 10:00:00'  AND EXTRACT(EPOCH FROM arrival.datetime - flight.s_arv) > (EXTRACT(EPOCH FROM departure.datetime - flight.s_dep)/2)
GROUP BY airline.code, airline.name, seat_class, year
HAVING sum(price) > 0;


Create VIEW international_eight AS 
SELECT airline.code AS airline, airline.name as name, EXTRACT(YEAR FROM departure.datetime) as year, seat_class, 0.35 * sum(price) AS refund
FROM airline, departure, flight, booking, airport a1, airport a2, arrival
WHERE flight.airline = airline.code AND departure.flight_id = booking.flight_id AND a1.code = flight.outbound and a2.code = flight.inbound AND a1.country <> a2.country AND departure.datetime - flight.s_dep >= '0 days 08:00:00' AND departure.datetime - flight.s_dep < '0 days 12:00:00'  AND EXTRACT(EPOCH FROM arrival.datetime - flight.s_arv) > (EXTRACT(EPOCH FROM departure.datetime - flight.s_dep)/2)
GROUP BY airline.code, airline.name, seat_class, year
HAVING sum(price) > 0;

CREATE VIEW international_twelve AS
SELECT airline.code AS airline, airline.name as name, EXTRACT(YEAR FROM departure.datetime) as year, seat_class, 0.5 * sum(price) AS refund
FROM airline, departure, flight, booking, airport a1, airport a2, arrival
WHERE flight.airline = airline.code AND departure.flight_id = booking.flight_id AND a1.code = flight.outbound and a2.code = flight.inbound AND a1.country <> a2.country AND departure.datetime - flight.s_dep >= '0 days 12:00:00'  AND EXTRACT(EPOCH FROM arrival.datetime - flight.s_arv) > (EXTRACT(EPOCH FROM departure.datetime - flight.s_dep)/2)
GROUP BY airline.code, airline.name, seat_class, year
HAVING sum(price) > 0;

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q2
SELECT * FROM domestic_five UNION SELECT * FROM domestic_ten UNION SELECT * FROM international_eight UNION SELECT * FROM international_twelve;
