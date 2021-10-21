USE SoftUni
--21. Employees with Three Projects
GO
CREATE PROCEDURE usp_AssignProject(@emloyeeId INT, @projectID INT)
AS
BEGIN TRANSACTION
DECLARE @numberOfProjects INT = (SELECT EmployeeID FROM EmployeesProjects
									WHERE EmployeeID = @emloyeeId)
IF(@numberOfProjects >= 3)
BEGIN
		ROLLBACK
	    RAISERROR('The employee has too many projects!',16,1)
		RETURN
END;
INSERT INTO EmployeesProjects (EmployeeID, ProjectID)
			VALUES (@emloyeeId, @projectID)
COMMIT

EXEC usp_AssignProject 2,25
SELECT * FROM Employees

--22.Delete Employees
GO
CREATE TRIGGER tr_DeleteEmployees ON Employees FOR DELETE
AS
INSERT INTO Deleted_Employees
(FirstName, LastName, MiddleName, JobTitle, DepartmentId, Salary)
SELECT
		FirstName,
		LastName,
		MiddleName,
		JobTitle, 
		DepartmentID, 
		Salary
FROM deleted;
