/*********************
 *  Initialisation   *
 *********************/

CREATE TABLE MyMovies
(
    Title    VARCHAR(20)
        CONSTRAINT MyMovies_PK PRIMARY KEY,
    Country  VARCHAR(3)  NOT NULL,
    Genre    VARCHAR(20) NOT NULL,
    Director VARCHAR(20) NOT NULL
);

CREATE INDEX MyMovies_Country ON MyMovies (Country);
CREATE INDEX MyMovies_Genre ON MyMovies (Genre);
CREATE INDEX MyMovies_Director ON MyMovies (Director);

CREATE TABLE MyCinemas
(
    Name     VARCHAR(20)
        CONSTRAINT MyCinemas_PK PRIMARY KEY,
    City     VARCHAR(20)   NOT NULL,
    Capacity NUMERIC(3, 0) NOT NULL
);

CREATE INDEX MyCinemas_City ON MyCinemas (City);

CREATE TABLE MyProgram
(
    Name    VARCHAR(20)
        CONSTRAINT MyProgram_FK_MyCinemas
            REFERENCES MyCinemas (Name) ON DELETE CASCADE,
    Title   VARCHAR(20)
        CONSTRAINT MyProgram_FK_MyMovies
            REFERENCES MyMovies (Title) ON DELETE CASCADE,
    Day     DATE          NOT NULL,
    Tickets NUMERIC(3, 0) NOT NULL,
    CONSTRAINT MyProgram_PK
        PRIMARY KEY (Name, Title, Day)
);

CREATE INDEX MyProgram_Day ON MyProgram (Day);

/*********************
 *      Examples     *
 *********************/

/*
 * Example 1
 */

CREATE PROCEDURE New_Cinema @pName VARCHAR(20),
                            @pCity VARCHAR(20),
                            @pCapacity NUMERIC(3, 0)
AS
BEGIN
    -- SET NOCOUNT ON;
    INSERT INTO MyCinemas (Name, City, Capacity)
    VALUES (@pName, @pCity, @pCapacity);
END;
GO

EXEC New_Cinema 'Big Picture', 'Seattle', 170;

/*
 * Example 2
 */

CREATE FUNCTION Cinema_Capacity(@pName VARCHAR(20))
    RETURNS NUMERIC
AS
BEGIN
    DECLARE @ret NUMERIC;

    SELECT @ret = C.Capacity
    FROM MyCinemas AS C
    WHERE C.Name = @pName;

    RETURN @ret;
END;
GO

SELECT "75192764".Cinema_Capacity('Big Picture') AS Capacity;

/*
 * Example 3
 */

CREATE FUNCTION Max_Capacity(@pCity VARCHAR(20))
    RETURNS NUMERIC
AS
BEGIN
    DECLARE @ret NUMERIC;

    SELECT @ret = MAX(C.Capacity)
    FROM MyCinemas AS C
    WHERE C.City = @pCity;

    RETURN @ret;
END;
GO

SELECT "75192764".Max_Capacity('Seattle') AS MaxCapacity;

/*
 * Example 4
 */

SELECT C.*
FROM MyCinemas AS C
WHERE C.Capacity = (SELECT max(X.Capacity) FROM MyCinemas AS X WHERE X.City = C.City);

SELECT C.*
FROM MyCinemas AS C
WHERE C.Capacity = "75192764".Max_Capacity(C.City);

/*
 * Example 5
 */

EXEC New_Cinema 'Central Cinema', 'Seattle', 310
EXEC New_Cinema 'Cinema Village', 'New York', 280
EXEC New_Cinema 'Country Club', 'Boise', 180
EXEC New_Cinema 'Film Forum', 'New York', 350
EXEC New_Cinema 'Quad Cinema', 'New York', 190

CREATE FUNCTION Cinema_List(
    @pCity VARCHAR(20)
) RETURNS VARCHAR(1000)
AS
BEGIN
    DECLARE @ret VARCHAR(1000);

    DECLARE c CURSOR FOR
        SELECT Name
        FROM MyCinemas
        WHERE City = @pCity
        ORDER BY Capacity, Name;
    DECLARE @delimiter VARCHAR(2);
    DECLARE @oneName VARCHAR(20);

    SET @ret = '';
    SET @delimiter = '';

    OPEN c;

    FETCH c INTO @oneName;
    WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @ret = @ret + @delimiter + @oneName; -- strings are concatenated by +
            SET @delimiter = ', ';
            FETCH c INTO @oneName;
        END;

    CLOSE c;
    DEALLOCATE c;

    RETURN @ret;
END
GO

SELECT "75192764".Cinema_List('New York') AS List;

/*
 * Example 6
 */

CREATE TRIGGER Trg_No_Prague_Cinemas
    ON MyCinemas
    AFTER INSERT
    AS
BEGIN
    IF exists(
            SELECT *
            FROM Inserted AS I
            WHERE I.City = 'Prague'
        )
        BEGIN
            RAISERROR ('Cinnemas in Prague cannot be inserted.', 16, 1);
            -- severity 16
            -- state 1
            ROLLBACK TRANSACTION;
        END;
END;

EXEC New_Cinema 'IMAX', 'Prague', 150;

INSERT INTO MyMovies
VALUES ('Avatar', 'USA', 'SCI-FI', 'Cameron'),
       ('Titanic', 'USA', 'Historical', 'Cameron'),
       ('Terminator', 'USA', 'SCI-FI', 'Cameron'),
       ('Minority Report', 'USA', 'SCI-FI', 'Spielberg'),
       ('Jaws', 'USA', 'Horror', 'Spielberg'),
       ('Leon', 'FR', 'Criminal', 'Besson');

INSERT INTO MyProgram
VALUES ('Film Forum', 'Avatar', '01-Jan-2019', 290),
       ('Film Forum', 'Avatar', '02-Jan-2019', 101),
       ('Film Forum', 'Titanic', '03-Feb-2019', 234),
       ('Film Forum', 'Terminator', '04-Mar-2019', 234),
-----------------------------------------------------------------
       ('Cinema Village', 'Avatar', '11-Jan-2019', 179),
       ('Cinema Village', 'Titanic', '15-Feb-2019', 189),
       ('Cinema Village', 'Titanic', '17-Mar-2019', 280),
       ('Cinema Village', 'Terminator', '19-Mar-2019', 280),
       ('Cinema Village', 'Minority Report', '23-Apr-2019', 111),
       ('Cinema Village', 'Jaws', '27-May-2019', 51),
       ('Cinema Village', 'Leon', '29-Jun-2019', 152),
       ('Cinema Village', 'Leon', '30-Jun-2019', 102),
-----------------------------------------------------------------
       ('Quad Cinema', 'Avatar', '01-Jan-2019', 159),
       ('Quad Cinema', 'Titanic', '05-Feb-2019', 99),
       ('Quad Cinema', 'Terminator', '07-Mar-2019', 111),
       ('Quad Cinema', 'Terminator', '09-Mar-2019', 122),
       ('Quad Cinema', 'Minority Report', '13-Apr-2019', 88),
       ('Quad Cinema', 'Jaws', '17-May-2019', 109),
-----------------------------------------------------------------
       ('Central Cinema', 'Leon', '29-Jul-2019', 310),
       ('Central Cinema', 'Leon', '30-Sep-2019', 130),
-----------------------------------------------------------------
       ('Big Picture', 'Avatar', '11-Jan-2019', 158),
       ('Big Picture', 'Titanic', '15-Jan-2019', 99),
       ('Big Picture', 'Terminator', '17-Feb-2019', 170),
       ('Big Picture', 'Minority Report', '19-Feb-2019', 170),
       ('Big Picture', 'Minority Report', '23-Mar-2019', 101),
       ('Big Picture', 'Jaws', '27-Mar-2019', 99),
-----------------------------------------------------------------
       ('Country Club', 'Avatar', '21-Jan-2019', 180),
       ('Country Club', 'Titanic', '25-Feb-2019', 179),
       ('Country Club', 'Minority Report', '30-Apr-2019', 100),
       ('Country Club', 'Jaws', '31-May-2019', 88),
       ('Country Club', 'Leon', '05-Jun-2019', 180);

/*********************
 *    Assignments    *
 *********************/

/*
 * 1. create procedure New_Program, that will add new screening with zero tickets sold.
 */
CREATE PROCEDURE New_Program @pName VARCHAR(20),
                             @pTitle VARCHAR(20),
                             @pDay DATE
AS
BEGIN
    INSERT INTO MyProgram (Name, Title, Day, Tickets) VALUES (@pName, @pTitle, @pDay, 0);
END;
GO

/*
 * 2. create procedure Sell_Ticket @pCnt, @pName, @pTitle, @pDay, that will sell @pCnt of tickets for given screening.
 */
CREATE PROCEDURE Sell_Ticket @pCnt NUMERIC,
                             @pName VARCHAR(20),
                             @pTitle VARCHAR(20),
                             @pDay DATE
AS
BEGIN
    DECLARE @tickets NUMERIC;

    SELECT @tickets = P.Tickets
    FROM MyProgram AS P
    WHERE Name = @pName
      AND Title = @pTitle
      AND Day = @pDay;

    UPDATE MyProgram
    SET Tickets=(@tickets + @pCnt)
    WHERE Name = @pName
      AND Title = @pTitle
      AND Day = @pDay;
END;
GO

EXEC Sell_Ticket 10, 'Cinema Village', 'Jaws', '2019-05-27';

/*
 * 3. create procedure Sell_Ticket_Safely @pCnt, @pName, @pTitle, @pDay, that will sell @pCnt of tickets for given
 *    screening, but only if the number of tickets will not exceed total capacity of the cinema.
 */
CREATE PROCEDURE Sell_Ticket_Safely @pCnt NUMERIC,
                                    @pName VARCHAR(20),
                                    @pTitle VARCHAR(20),
                                    @pDay DATE
AS
BEGIN
    DECLARE @tickets NUMERIC;
    DECLARE @capacity NUMERIC;

    SELECT @tickets = P.Tickets,
           @capacity = C.Capacity
    FROM MyProgram AS P
             INNER JOIN MyCinemas C ON P.Name = C.Name
    WHERE P.Name = @pName
      AND P.Title = @pTitle
      AND P.Day = @pDay;

    IF (@tickets + @pCnt > @capacity)
        BEGIN
            RAISERROR ('Cinema capacity exceeded', 16, 1);
        END;

    UPDATE MyProgram
    SET Tickets=(@tickets + @pCnt)
    WHERE Name = @pName
      AND Title = @pTitle
      AND Day = @pDay;
END;
GO

EXEC Sell_Ticket_Safely 1000, 'Cinema Village', 'Jaws', '2019-05-27';

/*
 * 4. create function Free_Seats(@pName,@pTitle,pDay) that will return number of free seats for given screening
 */
CREATE FUNCTION Free_Seats(@pName VARCHAR(20),
                           @pTitle VARCHAR(20),
                           @pDay DATE) RETURNS NUMERIC
AS
BEGIN
    DECLARE @ret NUMERIC;

    SELECT @ret = C.Capacity - P.Tickets
    FROM MyProgram AS P
             INNER JOIN MyCinemas C ON P.Name = C.Name
    WHERE P.Name = @pName
      AND P.Title = @pTitle
      AND P.Day = @pDay;

    RETURN @ret;
END;
GO

SELECT "75192764".Free_Seats('Big Picture', 'Avatar', '2019-01-11') AS FreeSeats;


/*
 * 5. create trigger Trg_Ins_Upd_Program, that will prevent inserting or updating Program row in such a way, that the
 *    number of tickets sold exceed capacity of the cinema.
 */
CREATE TRIGGER Trg_Ins_Upd_Program
    ON MyProgram
    AFTER UPDATE
    AS
BEGIN
    DECLARE @tickets NUMERIC;
    DECLARE @capacity NUMERIC;

    SELECT @tickets = P.Tickets,
           @capacity = C.Capacity
    FROM inserted AS P
             INNER JOIN MyCinemas C ON P.Name = C.Name

    IF (@tickets > @capacity)
        BEGIN
            RAISERROR ('Cinema capacity exceeded', 16, 1);
            ROLLBACK TRANSACTION;
        END;
END
GO

UPDATE MyProgram SET Tickets=500 WHERE Name='Big Picture' AND Title='Avatar' AND Day='2019-01-11';
