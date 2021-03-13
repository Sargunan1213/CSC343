-- Q3. North and South Connections

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q3 CASCADE;

CREATE TABLE q3 (
    outbound VARCHAR(30),
    inbound VARCHAR(30),
    direct INT,
    one_con INT,
    two_con INT,
    earliest timestamp
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS intermediate_step CASCADE;
DROP VIEW IF EXISTS direct CASCADE;
DROP VIEW IF EXISTS one_con CASCADE;
DROP VIEW IF EXISTS two_con CASCADE;
DROP VIEW IF EXISTS cities CASCADE;
-- Define views for your intermediate steps here:
CREATE VIEW direct AS
SELECT a.city AS outbound, b.city AS inbound, count(flight.outbound) AS direct, min(flight.s_arv) AS d
FROM airport a, airport b, flight
WHERE ((a.country = 'Canada' AND b.country = 'USA') OR
(a.country='USA' AND b.country = 'Canada')) AND a.city <> b.city AND
flight.outbound = a.code AND flight.inbound = b.code AND flight.s_dep BETWEEN '2021-04-30 00:00' AND '2021-04-30 23:59' AND flight.s_arv BETWEEN '2021-04-30 00:00' AND '2021-04-30 23:59'
GROUP BY a.city, b.city; 

CREATE VIEW one_con AS
SELECT a.city AS outbound, b.city AS inbound, count(f.outbound) AS one_con, min(g.s_arv) AS o
FROM airport a, airport b, flight f, flight g
WHERE ((a.country = 'Canada' AND b.country = 'USA') OR
(a.country='USA' AND b.country = 'Canada')) AND a.city <> b.city AND
f.outbound = a.code AND f.inbound = g.outbound AND g.inbound = b.code AND EXTRACT(EPOCH FROM f.s_arv - g.s_dep)/3600 >= 0.5
AND f.s_dep BETWEEN '2021-04-30 00:00' AND '2021-04-30 23:59' AND g.s_arv BETWEEN '2021-04-30 00:00' AND '2021-04-30 23:59'
GROUP BY a.city, b.city; 

CREATE VIEW two_con AS
SELECT a.city AS outbound, b.city AS inbound, count(f.outbound) AS two_con, min(h.s_arv) AS t
FROM airport a, airport b, flight f, flight g, flight h
WHERE ((a.country = 'Canada' AND b.country = 'USA') OR
(a.country='USA' AND b.country = 'Canada')) AND a.city <> b.city
AND f.outbound = a.code AND f.inbound = g.outbound AND g.inbound = h.outbound AND h.inbound = b.code 
AND EXTRACT(EPOCH FROM f.s_arv - g.s_dep)/3600 >= 0.5 
AND EXTRACT(EPOCH FROM g.s_arv - h.s_dep)/3600 >= 0.5
AND f.s_dep BETWEEN '2021-04-30 00:00' AND '2021-04-30 23:59' AND h.s_arv BETWEEN '2021-04-30 00:00' AND '2021-04-30 23:59'
GROUP BY a.city, b.city; 

CREATE VIEW cities AS 
SELECT a.city AS outbound, b.city AS inbound
FROM airport a, airport b
WHERE ((a.country = 'Canada' AND b.country = 'USA') OR
(a.country='USA' AND b.country = 'Canada')) AND a.city <> b.city;
-- Your query that answers the question goes below the "insert into" line:
INSERT into q3
SELECT outbound, inbound, CASE WHEN direct is NULL THEN 0 ELSE direct END AS direct,
CASE WHEN one_con is NULL THEN 0 ELSE one_con END AS one_con,
CASE WHEN two_con is NULL THEN 0 ELSE two_con END AS two_con,
LEAST(d,o,t) AS earliest
FROM direct NATURAL FULL JOIN one_con NATURAL FULL JOIN two_con NATURAL FULL JOIN cities
GROUP BY outbound, inbound, direct, one_con, two_con, d,o,t;
