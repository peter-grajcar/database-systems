/*
 * 01. Vypište seznam všech letů
 */
SELECT *
FROM Flights;


/*
 * 02. Vypište seznam všech letů zajišťovaných společnosti CSA
 */
SELECT *
FROM Flights
WHERE Company = 'CSA';


/*
 * 03. Vypište seznam všech letů zajišťovaných společnosti CSA setříděný sestupně dle počtu
 */
SELECT *
FROM Flights
WHERE Company = 'CSA'
ORDER BY Passengers DESC;


/*
 * 04. Vypište seznam letů spolu s letadly, které mají dostatečnou kapacitu pro jejich realizaci
 *     setříděný dle čísla letu a následně dle letadla
 */
SELECT *
FROM Flights,
     Planes
WHERE Flights.Passengers <= Planes.Capacity
ORDER BY Flights.Flight, Planes.Plane;


/*
 * 05. Vypište seznam letů spolu s letadly, které mají dostatečnou kapacitu pro jejich realizaci
 *     setříděný dle počtu sedadel, které budou za letu neobsazené, a dále dle čísla letu
 */
SELECT *
FROM Flights,
     Planes
WHERE Flights.Passengers <= Planes.Capacity
ORDER BY Planes.Capacity - Flights.Passengers, Flights.Flight;


/*
 * 06. Vypište lety s více, než 150 pasažéry
 */
SELECT *
FROM Flights
WHERE Passengers > 150;


/*
 * 07. Vypište počet letů s více, než 150 pasažéry (kolik takových letů je?)
 */
SELECT COUNT(*) AS Nr_of_Flights
FROM Flights
WHERE Passengers > 150;


/*
 * 08. Vypište seznam všech leteckých společností, které zajišťují lety
 */
SELECT DISTINCT Flights.Company
FROM Flights;