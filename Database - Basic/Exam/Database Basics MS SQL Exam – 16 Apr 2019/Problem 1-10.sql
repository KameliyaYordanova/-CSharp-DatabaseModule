CREATE DATABASE Airport
USE Airport

--Section 1.DDL (30 pts)
CREATE TABLE Planes
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR (30) NOT NULL,
	Seats INT NOT NULL,
	[Range] INT NOT NULL
)

CREATE TABLE Flights
(
	Id INT PRIMARY KEY IDENTITY,
	DepartureTime DATETIME2,
	ArrivalTime DATETIME2,
	Origin VARCHAR(50) NOT NULL,
	Destination VARCHAR(50) NOT NULL,
	PlaneId INT FOREIGN KEY REFERENCES Planes(Id) NOT NULL
)

CREATE TABLE Passengers 
(
	Id INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(30) NOT NULL,
	LastName VARCHAR(30) NOT NULL,
	Age INT NOT NULL,
	[Address] VARCHAR(30) NOT NULL,
	PassportId CHAR(11) NOT NULL
)

CREATE TABLE LuggageTypes
(
	Id INT PRIMARY KEY IDENTITY,
	[Type] VARCHAR(30) NOT NULL
)

CREATE TABLE Luggages
(
	Id INT PRIMARY KEY IDENTITY,
	LuggageTypeId INT FOREIGN KEY REFERENCES LuggageTypes(Id) NOT NULL,
	PassengerId INT FOREIGN KEY REFERENCES Passengers(Id) NOT NULL
)

CREATE TABLE Tickets
(
	Id INT PRIMARY KEY IDENTITY,
	PassengerId INT FOREIGN KEY REFERENCES Passengers(Id) NOT NULL,
	FlightId INT FOREIGN KEY REFERENCES Flights(Id) NOT NULL,
	LuggageId INT FOREIGN KEY REFERENCES Luggages(Id) NOT NULL,
	Price DECIMAL(15,2) NOT NULL
)

--2.Insert
	INSERT INTO Planes ([Name], Seats, [Range]) VALUES
	('Airbus 336', 112, 5132),
	('Airbus 330', 432, 5325),
	('Boeing 369', 231, 2355),
	('Stelt 297', 254, 2143),
	('Boeing 338', 165, 5111),
	('Airbus 558', 387, 1342),
	('Boeing 128', 345, 5541)

	INSERT INTO LuggageTypes ([Type]) VALUES
	('Crossbody Bag'),
	('School Backpack'),
	('Shoulder Bag')

--3.Update
SELECT Id FROM Flights 
WHERE Destination = 'Carlsbad'

UPDATE Tickets
SET Price += Price * 0.13
WHERE FlightId = (SELECT Id FROM Flights 
				WHERE Destination = 'Carlsbad')

--4.Delete
DELETE FROM Tickets
WHERE FlightId = (SELECT Id FROM Flights
					WHERE Destination = 'Ayn Halagim')
DELETE FROM Flights
WHERE Destination = 'Ayn Halagim'

--5.The "Tr" Planes
SELECT * FROM Planes
WHERE [Name] LIKE '%tr%'
ORDER BY Id, [Name], Seats, [Range]

--06.Flight Profits
SELECT f.Id AS FlightId,
SUM(t.Price) AS Price
FROM Flights f
JOIN Tickets t ON t.FlightId = f.Id
GROUP BY f.Id
ORDER BY SUM(t.Price) DESC, f.Id

--7.Passenger Trips
SELECT CONCAT(p.FirstName, ' ', p.LastName) AS FullName, f.Origin, f.Destination FROM Passengers p
JOIN Tickets t ON t.PassengerId = p.Id
JOIN Flights f ON t.FlightId = f.Id
ORDER BY FullName, Origin, Destination

--8.Non Adventures People
SELECT p.FirstName, p.LastName, p.Age FROM Passengers p
LEFT JOIN Tickets t ON t.PassengerId = p.Id
WHERE t.Id IS NULL
ORDER BY p.Age DESC, p.FirstName, p.LastName

--9.Full Info
SELECT CONCAT(p.FirstName, ' ', p.LastName) AS [Full Name],
pl.[Name],
CONCAT(f.Origin, ' - ', f.Destination) AS Trip,
[Type] AS [Luggage Type]
FROM Passengers p
JOIN Tickets t ON t.PassengerId = p.Id
JOIN Flights f ON f.Id = t.FlightId
JOIN Planes pl ON pl.Id = f.PlaneId
JOIN Luggages l ON l.Id = t.LuggageId
JOIN LuggageTypes lt ON lt.Id = l.LuggageTypeId
ORDER BY [Full Name], pl.[Name], Trip, [Luggage Type]

--10.PSP
SELECT p.[Name], p.Seats, COUNT(t.PassengerId) AS [Passengers Count]
FROM Planes p
LEFT JOIN Flights f ON f.PlaneId = p.Id
LEFT JOIN Tickets t ON t.FlightId = f.Id
GROUP BY p.[Name], p.Seats
ORDER BY [Passengers Count] DESC, p.[Name], p.Seats

--11.Vacation
GO
CREATE FUNCTION udf_CalculateTickets(@origin VARCHAR(50), @destination VARCHAR(50), @peopleCount INT)
RETURNS VARCHAR(70)
AS
BEGIN
		IF(@peopleCount <= 0)
		BEGIN
			RETURN 'Invalid people count!';
		END

		DECLARE @flightId INT = (SELECT TOP(1) Id FROM Flights
								 WHERE Origin = @origin AND
								       Destination = @destination);
		IF(@flightId IS NULL)
		BEGIN
			RETURN 'Invalid flight!';
		END

		DECLARE @pricePersonTicket DECIMAL(15,2) = (SELECT TOP(1) Price FROM Tickets
													WHERE FlightId = @flightId);
		DECLARE @totalPrice DECIMAL(24,2) = @pricePersonTicket * @peopleCount;

		RETURN CONCAT('Total price ', @totalPrice);
END

SELECT dbo.udf_CalculateTickets('Invalid','Rancabolang', 33)

--12.Wrong Data
GO
ALTER PROCEDURE usp_CancelFlights
AS
BEGIN
	UPDATE Flights
	SET DepartureTime = NULL, ArrivalTime = NULL
	WHERE DATEDIFF(SECOND, ArrivalTime, DepartureTime) < 0
END

EXEC usp_CancelFlights