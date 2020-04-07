/*
 * 01. Vypište seznam kin, která nepromítala žádný film od Camerona.
 *     Setřiďte výsledek podle města a dále názvu kina
 */

SELECT Cinemas.*
FROM Cinemas
WHERE NOT EXISTS(SELECT *
                 FROM Program
                          INNER JOIN Movies ON Program.Title = Movies.Title
                 WHERE Movies.Director = 'Cameron'
                   AND Program.Name = Cinemas.Name)
ORDER BY Cinemas.City, Cinemas.Name


/*
 * 02. Vypište seznam kin, která promítala právě tři filmy od Camerona (filmy, ne promítání).
 *     Setřiďte výsledek podle města a dále názvu kina
 */
SELECT Cinemas.*
FROM Cinemas,
     (SELECT Cinema.Name, COUNT(Cameron.Title) AS Count
      FROM Cinemas AS Cinema,
           (SELECT DISTINCT Program.Title, Cinemas.Name
            FROM Program
                     INNER JOIN Cinemas ON Program.Name = Cinemas.Name
                     INNER JOIN Movies ON Program.Title = Movies.Title
            WHERE Movies.Director = 'Cameron') as Cameron
      WHERE Cinema.Name = Cameron.Name
      GROUP BY Cinema.Name) AS CameronMovies
WHERE CameronMovies.Name = Cinemas.Name
  AND CameronMovies.Count = 3
ORDER BY Cinemas.City, Cinemas.Name;


/*
 * 03. Vypište seznam kin, která promítala jenom filmy od Camerona.
 *     Setřiďte výsledek podle města a dále názvu kina
 */
SELECT Cinemas.*
FROM Cinemas
WHERE NOT EXISTS(SELECT *
                 FROM Program
                          INNER JOIN Movies ON Program.Title = Movies.Title
                 WHERE Movies.Director <> 'Cameron'
                   AND Program.Name = Cinemas.Name)
ORDER BY Cinemas.City, Cinemas.Name


/*
 * 04. (těžký) Vypište seznam kin, která promítala všechny filmy od Camerona.
 *     Setřiďte výsledek podle města a dále názvu kina
 */
SELECT Cinemas.*
FROM Cinemas,
     (SELECT Cinema.Name, COUNT(Cameron.Title) AS Count
      FROM Cinemas AS Cinema,
           (SELECT DISTINCT Program.Title, Cinemas.Name
            FROM Program
                     INNER JOIN Cinemas ON Program.Name = Cinemas.Name
                     INNER JOIN Movies ON Program.Title = Movies.Title
            WHERE Movies.Director = 'Cameron') AS Cameron
      WHERE Cinema.Name = Cameron.Name
      GROUP BY Cinema.Name) AS CameronMovies
WHERE CameronMovies.Name = Cinemas.Name
  AND CameronMovies.Count = (SELECT COUNT(T.Title)
                             FROM (SELECT DISTINCT Movies.Title
                                   FROM Movies
                                   WHERE Movies.Director = 'Cameron') AS T)
ORDER BY Cinemas.City, Cinemas.Name;

/*
 * 05. (hodně těžký) Vypište seznam dvojic kin (jen jména), která promítala stejné filmy (stejnou
 *     množinu filmů).
 */
SELECT C1.Name AS Name1, C2.Name AS Name2
FROM Cinemas AS C1,
     Cinemas AS C2
WHERE C1.Name < C2.Name
  AND 1 = ALL (
    SELECT CASE WHEN T.A = T.B THEN 1 ELSE 0 END AS A
    FROM (SELECT CC1.Name       AS N1,
                 CC2.Name       AS N2,
                 CASE
                     WHEN M.Title IN (SELECT DISTINCT Program.Title
                                      FROM Program
                                      WHERE Program.Name = CC1.Name)
                         THEN 1
                     ELSE 0 END AS A,
                 CASE
                     WHEN M.Title IN (SELECT DISTINCT Program.Title
                                      FROM Program
                                      WHERE Program.Name = CC2.Name)
                         THEN 1
                     ELSE 0 END AS B
          FROM Cinemas AS CC1,
               Cinemas AS CC2,
               Movies AS M
         ) AS T
    WHERE T.N1 = C1.Name
      AND T.N2 = C2.Name);