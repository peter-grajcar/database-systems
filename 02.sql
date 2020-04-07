/*
 * 01. Vypište seznam všech kin z New Yorku, setříděný sestupně dle kapacity
 */
SELECT *
FROM Cinemas
WHERE City = 'New York'
ORDER BY Capacity DESC;


/*
 * 02. Vypište seznam všech filmů, které nenatočil Cameron, setříděný dle režiséra a dále
 *     sestupně dle žánru
 */
SELECT *
FROM Movies
WHERE Director <> 'Cameron'
ORDER BY Director, Genre DESC;


/*
 * 03. Vypište seznam všech promítání filmu Titanic v únoru 2019 s alespoň 100 prodanými
 *     vstupenkami. Setřiďte výsledek podle data promítání.
 */
SELECT *
FROM Program
WHERE Title = 'Titanic'
  AND Tickets > 100
  AND Day >= '2019-02-01'
  AND Day < '2019-03-01'
ORDER BY Day;


/*
 * 04a. Vypište seznam kin, která promítala alespoň jeden film od Spielberga.
 *      Setřiďte výsledek podle města a dále názvu kina
 *      Bez použití spojení dle normy SQL-92
 */
SELECT DISTINCT Cinemas.*
FROM Cinemas,
     Movies,
     Program
WHERE Program.Title = Movies.Title
  AND Program.Name = Cinemas.Name
  AND Movies.Director = 'Spielberg'
ORDER BY Cinemas.City, Cinemas.Name;


/*
 * 04b. Vypište ten samý výsledek, jako v bodě 04a, ale s pou žitím spojení dle normy SQL-92
 */
SELECT DISTINCT Cinemas.*
FROM Cinemas
         INNER JOIN Program
                    ON Cinemas.Name = Program.Name
         INNER JOIN Movies
                    ON Program.Title = Movies.Title
WHERE Movies.Director = 'Spielberg'
ORDER BY Cinemas.City, Cinemas.Name;


/*
 * 04c. Vypište ten samý výsledek, jako v bodě 04a, ale využijte následující dotaz, a doplňte
 *      pouze část:
 *
 *      select *
 *      from Cinemas as C
 *      where ...
 *      order by C.City, C.Name;
 */
SELECT DISTINCT *
FROM Cinemas AS C
WHERE EXISTS(SELECT *
             FROM Movies AS M
             WHERE M.Director = 'Spielberg'
               AND M.Title IN (SELECT P.Title FROM Program AS P WHERE C.Name = P.Name))
ORDER BY C.City, C.Name;


/*
 * 05. Vypište seznam všech promítání , kdy bylo kino vyprodáno. Setřiďte výsledek dle jména
 *     kina a dále dle data promítání
 */
SELECT *
FROM Program AS P
         INNER JOIN Cinemas AS C
                    ON P.Name = C.Name
WHERE P.Tickets = C.Capacity
ORDER BY C.Name, P.Day;
