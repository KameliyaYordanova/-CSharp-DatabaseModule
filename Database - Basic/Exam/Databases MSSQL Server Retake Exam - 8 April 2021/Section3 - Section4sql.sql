USE Service
--5.Unassigned Reports
SELECT Description, FORMAT(OpenDate, 'dd-MM-yyyy') FROM Reports
WHERE EmployeeId IS NULL
ORDER BY OpenDate, Description

--6.Reports & Categories
SELECT r.Description, c.Name AS CategoryName 
FROM Reports r
JOIN Categories c ON r.CategoryId = c.Id
ORDER BY r.Description, CategoryName

--7.Most Reported Category
SELECT TOP(5) c.Name AS CategoryName, COUNT(*) AS ReportsNumber
FROM Reports r
JOIN Categories c ON r.CategoryId = c.Id
GROUP BY r.CategoryId, c.Name
ORDER BY ReportsNumber DESC, c.Name

--8.Birthday Report
SELECT u.Username, c.Name AS CategoryName 
FROM Reports r
JOIN Users u ON r.UserId = u.Id
JOIN Categories c ON r.CategoryId = c.Id
WHERE DATEPART(MONTH, u.Birthdate) = DATEPART(MONTH, r.OpenDate) AND
DATEPART(DAY, u.Birthdate) = DATEPART(DAY, r.OpenDate)
ORDER BY Username, CategoryName

--9.Users per Employee
SELECT 
e.FirstName + ' ' + e.LastName AS FullName,
COUNT(u.Name) AS UsersCount
FROM Employees e 
LEFT JOIN Reports r ON r.EmployeeId = e.Id
LEFT JOIN Users u ON u.Id = r.UserId
GROUP BY e.FirstName, e.LastName
ORDER BY UsersCount DESC, FullName

--10.Full Info
SELECT  	 
	ISNULL(E.FirstName + ' ' + E.LastName,'None') AS Employee,
	ISNULL(D.Name , 'None') AS Department,
	ISNULL(C.Name,'None' )  AS Category,
	R.Description,
	FORMAT(R.OpenDate,'dd.MM.yyyy') AS OpenDate,
	S.Label AS [Status],
	U.Name AS [User]
FROM Reports		 AS R
LEFT JOIN Employees  AS E ON E.Id = R.EmployeeId
LEFT JOIN Categories AS C ON C.Id = R.CategoryId 
LEFT JOIN [Status]	 AS S ON S.Id = R.StatusId 
LEFT JOIN Users		 AS U ON U.Id = R.UserId
LEFT JOIN Departments AS D ON D.Id = E.DepartmentId
ORDER BY 
	E.FirstName  DESC, 
	E.LastName   DESC,
	D.Name,
	C.Name,
	R.Description,
	R.OpenDate,
	S.Label,
	U.Username

--Section 4. Programmability
--11.Hours to Complete
GO
CREATE FUNCTION udf_HoursToComplete(@StartDate DATETIME, @EndDate DATETIME)
RETURNS INT
AS
BEGIN
	DECLARE @result INT;
			IF @StartDate IS NULL OR @EndDate IS NULL
	BEGIN
		SET @result = 0;
	END
			ELSE
	BEGIN
		SET @result = DATEDIFF(HOUR, @StartDate, @EndDate);
	END

	RETURN @result;
END

SELECT dbo.udf_HoursToComplete(OpenDate, CloseDate) AS TotalHours
   FROM Reports

--12.Assign Employee
GO
CREATE PROCEDURE usp_AssignEmployeeToReport(@EmployeeId INT, @ReportId INT)
AS
	DECLARE @EmployeesDep INT = (SELECT E.DepartmentId
								FROM Employees AS E
								WHERE E.Id = @EmployeeId)

	DECLARE @Report INT = (SELECT C.DepartmentId
						  FROM Reports AS R
						   JOIN Categories AS C ON C.Id = R.CategoryId
						  WHERE R.Id = @ReportId )

	IF @EmployeesDep != @Report
	THROW 50005,'Employee doesn''t belong to the appropriate department!', 1;
	
UPDATE Reports 
SET EmployeeId = @EmployeeId
	WHERE Id = @ReportId

EXEC usp_AssignEmployeeToReport 30, 1