USE Bank
--1.Create Table Logs
CREATE TABLE Logs
(
	LogId INT PRIMARY KEY IDENTITY,
	AcountId INT FOREIGN KEY REFERENCES Accounts(Id),
	OldSum DECIMAL(15,2),
	NewSum DECIMAL(15,2)
)
GO
CREATE TRIGGER tr_InsertAccountInfo ON Accounts FOR UPDATE
AS
	DECLARE @accountId INT = (SELECT Id FROM inserted)
	DECLARE @newSum DECIMAL(15,2) = (SELECT Balance FROM inserted)
	DECLARE @oldSum DECIMAL(15,2) = (SELECT Balance FROM deleted)

INSERT INTO Logs(AcountId, NewSum, OldSum) VALUES
(@accountId, @newSum, @oldSum)
GO

UPDATE Accounts
SET Balance += 10
WHERE Id = 1

SELECT * FROM Accounts
SELECT * FROM Logs

--2.Create Table Emails
CREATE TABLE NotificationEmails
(
	Id INT PRIMARY KEY IDENTITY,
	Recipient INT FOREIGN KEY REFERENCES Accounts(Id),
	[Subject] NVARCHAR(50),
	[Body] NVARCHAR(MAX)
)

GO
CREATE TRIGGER tr_LogEmail ON Logs FOR INSERT
AS
	DECLARE @recipient INT = (SELECT AcountId FROM inserted)
    DECLARE @Subject NVARCHAR(50) = 
	(SELECT 'Balance change for account: ' + CAST(AcountId AS varchar) FROM inserted)

	DECLARE @Body NVARCHAR(MAX) = 
	(SELECT 'On ' + CAST(GETDATE() AS varchar) + ' your balance was changed from ' + 
	CAST(OldSum AS varchar) + ' to ' + CAST(NewSum AS varchar) FROM inserted)

INSERT INTO NotificationEmails(Recipient, [Subject], Body)
VALUES(@Recipient,@Subject,@Body)

UPDATE Accounts
SET Balance += 100
WHERE Id = 1

SELECT * FROM Logs
SELECT * FROM NotificationEmails


--3.Deposit Money
GO
CREATE PROCEDURE usp_DepositMoney @AccountId INT, @MoneyAmount DECIMAL(15, 4)
AS
BEGIN TRANSACTION
		DECLARE @account INT = (SELECT Id FROM Accounts 
									WHERE Id = @AccountId)
		IF(@account = 0)
		BEGIN
				ROLLBACK
				RAISERROR('Invalid account id!', 16, 1)
				RETURN
		END 

		IF(@MoneyAmount < 0)
		BEGIN 
		        ROLLBACK
				RAISERROR('Negative amount!', 16, 1)
				RETURN
		END

UPDATE Accounts 
SET Balance += @MoneyAmount
WHERE Id = @AccountId
COMMIT

SELECT * FROM Accounts 
WHERE Id = 1

EXEC usp_DepositMoney @AccountID = 1, @MoneyAmount = 10

--4.Withdraw Money
GO
CREATE PROCEDURE usp_WithdrawMoney @AccountId INT, @MoneyAmount DECIMAL(15,4)
AS
BEGIN TRANSACTION
DECLARE @accountExsit INT = (SELECT Id FROM Accounts
									WHERE Id = @AccountId)
DECLARE @currentBalance DECIMAL(15,4) = (SELECT Balance FROM Accounts
									       WHERE Id = @AccountId)

IF(@accountExsit = 0)
	BEGIN
			ROLLBACK
			RAISERROR('Invalid account id!', 16, 1)
			RETURN
	END 

IF(@MoneyAmount < 0)
	BEGIN 
		    ROLLBACK
			RAISERROR('Negative amount!', 16, 1)
			RETURN
	END
IF(@currentBalance - @MoneyAmount < 0)
    BEGIN
			ROLLBACK
			RAISERROR('You Don`t have enough money!', 16, 1)
			RETURN
	END

UPDATE Accounts
SET Balance -= @MoneyAmount
WHERE Id = @AccountId
COMMIT


SELECT * FROM Accounts 
WHERE Id = 5

EXEC  usp_WithdrawMoney @AccountID = 5, @MoneyAmount = 25

--5.Money Transfer
GO
CREATE PROCEDURE usp_TransferMoney @SenderId INT, @ReceiverId INT, @Amount DECIMAL(15,4)
AS
BEGIN TRANSACTION
EXECUTE usp_DepositMoney @ReceiverId, @Amount
EXECUTE usp_WithdrawMoney @SenderId, @Amount
COMMIT

SELECT * FROM Accounts WHERE Id = 1
SELECT * FROM Accounts WHERE Id = 5
EXECUTE usp_TransferMoney @SenderId = 5, @ReceiverId = 1, @Amount = 5000