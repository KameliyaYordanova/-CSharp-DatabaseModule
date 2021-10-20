--1.Employees with Salary Above 35000
CREATE PROCEDURE usp_GetEmployeesSalaryAbove35000
AS 
SELECT FirstName, LastName 
		FROM Employees
WHERE Salary > 35000

EXEC usp_GetEmployeesSalaryAbove35000

--2.Employees with Salary Above Number
GO
CREATE PROCEDURE usp_GetEmployeesSalaryAboveNumber @Number DECIMAL(18,4) OUTPUT
AS
SELECT FirstName, LastName
		FROM Employees
WHERE Salary >= @Number
GO
EXEC usp_GetEmployeesSalaryAboveNumber @Number = 48100

--3.Town Names Starting With
GO
CREATE PROCEDURE usp_GetTownsStartingWith @Letter NVARCHAR(20) OUTPUT
AS 
SELECT [Name] AS Town
		FROM Towns
WHERE [Name] LIKE @Letter+'%'

EXEC usp_GetTownsStartingWith @Letter = 'B'

--4.Employees from Town
GO
CREATE PROCEDURE usp_GetEmployeesFromTown @TownName NVARCHAR(20)
AS
SELECT FirstName, LastName
	FROM Employees e
JOIN Addresses a ON a.AddressID = e.AddressID
JOIN Towns t ON t.TownID = a.TownID
WHERE t.Name = @TownName
EXEC usp_GetEmployeesFromTown @TownName = 'Sofia'

----5.Salary Level Function
GO
CREATE FUNCTION ufn_GetSalaryLevel(@Salary DECIMAL(18,4))
RETURNS VARCHAR(250)
AS
BEGIN 
		DECLARE @Result VARCHAR(250)
		IF(@Salary < 30000) 
		  SET @Result = 'Low';

		ELSE IF(@Salary <= 50000) 
		  SET @Result = 'Average';

		ELSE 
		  SET @Result ='High';
		RETURN @Result
END
GO
SELECT Salary, dbo.ufn_GetSalaryLevel(Salary) AS [Salary Level]
FROM Employees

--6.Employees by Salary Level
GO
CREATE PROCEDURE usp_EmployeesBySalaryLevel @LevelSalary NVARCHAR(200)
AS
SELECT SalaryLevel.FirstName, SalaryLevel.LastName
FROM (
		SELECT FirstName, LastName, dbo.ufn_GetSalaryLevel(Salary) AS [Level]
		FROM Employees
	 ) AS SalaryLevel
WHERE SalaryLevel.Level = @LevelSalary
EXEC usp_EmployeesBySalaryLevel @LevelSalary = 'High'

--7.Define Function
GO
CREATE FUNCTION ufn_IsWordComprised(@setOfLetters VARCHAR(MAX), @word VARCHAR(MAX))
RETURNS bit AS
BEGIN
		DECLARE @WordLength int = LEN(@word);
		DECLARE @Index int = 1;

		WHILE(@Index <= @WordLength)
			BEGIN
				IF(CHARINDEX(SUBSTRING(@word, @Index, 1), @setOfLetters) = 0)
					 BEGIN
						RETURN 0
					 END
			    SET @Index += 1
			END
		RETURN 1
END

--8.* Delete Employees and Departments
GO
CREATE PROCEDURE usp_DeleteEmployeesFromDepartment (@departmentId INT)
AS
BEGIN
			DELETE FROM EmployeesProjects
			WHERE EmployeeID IN (
									SELECT EmployeeID
									FROM Employees
									WHERE DepartmentID = @departmentId
								)
	       UPDATE Employees
		   SET ManagerID = NULL
		   WHERE ManagerID IN (
								  SELECT EmployeeID
								  FROM Employees
								  WHERE DepartmentID = @departmentId
							  )
		   ALTER TABLE Departments
		   ALTER COLUMN ManagerID INT

		   UPDATE Departments
		   SET ManagerID = NULL
		   WHERE ManagerID IN (
								  SELECT EmployeeID
								  FROM Employees
								  WHERE DepartmentID = @departmentId
							  )
		  DELETE FROM Employees
		  WHERE DepartmentID = @departmentId

		  DELETE FROM Departments
		  WHERE DepartmentID = @departmentId

		  SELECT COUNT(*) FROM Employees
		  WHERE DepartmentID = @departmentId
END

EXEC usp_DeleteEmployeesFromDepartment 1
