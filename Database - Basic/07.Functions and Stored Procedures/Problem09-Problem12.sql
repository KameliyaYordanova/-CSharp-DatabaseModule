CREATE DATABASE Bank
GO
USE Bank
GO
CREATE TABLE AccountHolders
(
Id INT NOT NULL,
FirstName VARCHAR(50) NOT NULL,
LastName VARCHAR(50) NOT NULL,
SSN CHAR(10) NOT NULL
CONSTRAINT PK_AccountHolders PRIMARY KEY (Id)
)

CREATE TABLE Accounts
(
Id INT NOT NULL,
AccountHolderId INT NOT NULL,
Balance MONEY DEFAULT 0
CONSTRAINT PK_Accounts PRIMARY KEY (Id)
CONSTRAINT FK_Accounts_AccountHolders FOREIGN KEY (AccountHolderId) REFERENCES AccountHolders(Id)
)

INSERT INTO AccountHolders (Id, FirstName, LastName, SSN) VALUES (1, 'Susan', 'Cane', '1234567890');
INSERT INTO AccountHolders (Id, FirstName, LastName, SSN) VALUES (2, 'Kim', 'Novac', '1234567890');
INSERT INTO AccountHolders (Id, FirstName, LastName, SSN) VALUES (3, 'Jimmy', 'Henderson', '1234567890');
INSERT INTO AccountHolders (Id, FirstName, LastName, SSN) VALUES (4, 'Steve', 'Stevenson', '1234567890');
INSERT INTO AccountHolders (Id, FirstName, LastName, SSN) VALUES (5, 'Bjorn', 'Sweden', '1234567890');
INSERT INTO AccountHolders (Id, FirstName, LastName, SSN) VALUES (6, 'Kiril', 'Petrov', '1234567890');
INSERT INTO AccountHolders (Id, FirstName, LastName, SSN) VALUES (7, 'Petar', 'Kirilov', '1234567890');
INSERT INTO AccountHolders (Id, FirstName, LastName, SSN) VALUES (8, 'Michka', 'Tsekova', '1234567890');
INSERT INTO AccountHolders (Id, FirstName, LastName, SSN) VALUES (9, 'Zlatina', 'Pateva', '1234567890');
INSERT INTO AccountHolders (Id, FirstName, LastName, SSN) VALUES (10, 'Monika', 'Miteva', '1234567890');
INSERT INTO AccountHolders (Id, FirstName, LastName, SSN) VALUES (11, 'Zlatko', 'Zlatyov', '1234567890');
INSERT INTO AccountHolders (Id, FirstName, LastName, SSN) VALUES (12, 'Petko', 'Petkov Junior', '1234567890');

INSERT INTO Accounts (Id, AccountHolderId, Balance) VALUES (1, 1, 123.12);
INSERT INTO Accounts (Id, AccountHolderId, Balance) VALUES (2, 3, 4354.23);
INSERT INTO Accounts (Id, AccountHolderId, Balance) VALUES (3, 12, 6546543.23);
INSERT INTO Accounts (Id, AccountHolderId, Balance) VALUES (4, 9, 15345.64);
INSERT INTO Accounts (Id, AccountHolderId, Balance) VALUES (5, 11, 36521.20);
INSERT INTO Accounts (Id, AccountHolderId, Balance) VALUES (6, 8, 5436.34);
INSERT INTO Accounts (Id, AccountHolderId, Balance) VALUES (7, 10, 565649.20);
INSERT INTO Accounts (Id, AccountHolderId, Balance) VALUES (8, 11, 999453.50);
INSERT INTO Accounts (Id, AccountHolderId, Balance) VALUES (9, 1, 5349758.23);
INSERT INTO Accounts (Id, AccountHolderId, Balance) VALUES (10, 2, 543.30);
INSERT INTO Accounts (Id, AccountHolderId, Balance) VALUES (11, 3, 10.20);
INSERT INTO Accounts (Id, AccountHolderId, Balance) VALUES (12, 7, 245656.23);
INSERT INTO Accounts (Id, AccountHolderId, Balance) VALUES (13, 5, 5435.32);
INSERT INTO Accounts (Id, AccountHolderId, Balance) VALUES (14, 4, 1.23);
INSERT INTO Accounts (Id, AccountHolderId, Balance) VALUES (15, 6, 0.19);
INSERT INTO Accounts (Id, AccountHolderId, Balance) VALUES (16, 2, 5345.34);
INSERT INTO Accounts (Id, AccountHolderId, Balance) VALUES (17, 11, 76653.20);
INSERT INTO Accounts (Id, AccountHolderId, Balance) VALUES (18, 1, 235469.89);


--9.Find Full Name
GO
CREATE PROCEDURE usp_GetHoldersFullName
AS
	SELECT CONCAT(FirstName, ' ', LastName) AS FullName
	FROM AccountHolders

GO
EXEC usp_GetHoldersFullName

--10.People with Balance Higher Than
GO
CREATE PROCEDURE usp_GetHoldersWithBalanceHigherThan(@minBalance DECIMAL (18, 4))
AS
BEGIN
			SELECT FirstName, LastName FROM Accounts AS a
			JOIN AccountHolders ah ON a.AccountHolderId = ah.Id
			GROUP BY FirstName, LastName
			HAVING SUM(Balance) > @minBalance
			ORDER BY FirstName, LastName
END
EXEC usp_GetHoldersWithBalanceHigherThan 25000

--11.Future Value Function
GO
CREATE FUNCTION ufn_CalculateFutureValue (@sum DECIMAL(18, 4), @yir FLOAT, @yearsCount INT)
RETURNS DECIMAL(18, 4)
AS
BEGIN
		DECLARE @futureValue DECIMAL(18, 4);
		SET @futureValue = @sum * (POWER((1 + @yir), @yearsCount));
		RETURN @futureValue;
END
GO
SELECT dbo.ufn_CalculateFutureValue(1000, 0.1, 5)

--12.Calculating Interest
GO
CREATE PROCEDURE usp_CalculateFutureValueForAccount(@acountId INT, @insertRate FLOAT)
AS
BEGIN
		SELECT a.Id, ah.FirstName, ah.LastName, a.Balance,
		dbo.ufn_CalculateFutureValue(a.Balance, @insertRate, 5)
			FROM Accounts a
			JOIN AccountHolders ah ON ah.Id = a.AccountHolderId
			WHERE a.Id = @acountId
END
 GO
EXEC usp_CalculateFutureValueForAccount 1, 0.1