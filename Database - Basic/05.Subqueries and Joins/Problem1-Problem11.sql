--1.Employee Address
SELECT Top(5) e.EmployeeID AS EmployeedId, 
			e.JobTitle,
			a.AddressID AS AddressId, 
			a.AddressText
		FROM Employees e
	JOIN Addresses a ON a.AddressID = e.AddressID
		ORDER BY a.AddressID

--2.Addresses with Towns
SELECT TOP(50) e.FirstName,
				e.LastName,
				t.[Name] AS Town,
				a.AddressText
		FROM Employees e
JOIN Addresses a ON a.AddressID = e.AddressID
JOIN Towns t ON t.TownID = a.TownID
ORDER BY FirstName, LastName

--3.Sales Employee
SELECT e.EmployeeID, e.FirstName, e.LastName,
       [Name] AS DepartmentName
       FROM Employees e
JOIN Departments d ON e.DepartmentID = d.DepartmentID
WHERE d.[Name] = 'Sales'
ORDER BY EmployeeID

--4.Employee Departments
SELECT Top(5) e.EmployeeID, 
       e.FirstName, 
	   e.Salary,
	   [Name] AS DepartmentName
	FROM Employees e
JOIN Departments d ON e.DepartmentID = d.DepartmentID
WHERE Salary >= 15000
ORDER BY d.DepartmentID

--5.Employees Without Project
SELECT TOP(3) e.EmployeeID, e.FirstName
	FROM Employees e
LEFT JOIN EmployeesProjects ep ON ep.EmployeeID = e.EmployeeID
WHERE ep.ProjectID IS NULL
ORDER BY EmployeeID

--6.Employees Hired After
SELECT e.FirstName, e.LastName, e.HireDate,
	d.[Name] AS DeptName
	FROM Employees e
JOIN Departments d ON e.DepartmentID = d.DepartmentID
WHERE HireDate > '1999-01-01' AND
d.[Name] IN ('Sales','Finance')
ORDER BY HireDate

--7.Employees with Project
SELECT TOP(5) e.EmployeeID, e.FirstName,
	[Name] AS ProjectName
	FROM Employees e
JOIN EmployeesProjects ep ON e.EmployeeID = ep.EmployeeID
JOIN Projects p ON ep.ProjectID = p.ProjectID
WHERE P.StartDate > '2002-08-13' AND p.EndDate IS NULL
ORDER BY e.EmployeeID

--8.Employee 24
SELECT e.EmployeeID, e.FirstName,
	CASE
	WHEN YEAR(p.StartDate) >= 2005 THEN NULL
	ELSE p.[Name]
	END AS ProjectName
	FROM Employees e
JOIN EmployeesProjects ep ON e.EmployeeID = ep.EmployeeID
JOIN Projects p ON ep.ProjectID = p.ProjectID
WHERE e.EmployeeID = 24

--9.Employee Manager
SELECT e.EmployeeID, e.FirstName, e.ManagerID,
	m.FirstName AS ManagerName
	FROM Employees e
JOIN Employees AS m ON m.EmployeeID = e.ManagerID
WHERE e.ManagerID = 3 OR e.ManagerID = 7
ORDER BY e.EmployeeID

--10.Employee Summary
SELECT TOP(50) 
    CONCAT(e.FirstName,' ',e.LastName) AS EmployeeName,
	CONCAT(m.FirstName,' ',m.LastName) AS ManagerName,
	d.[Name] AS DepartmentName
 	FROM Employees e
JOIN Employees AS m ON e.ManagerID = m.EmployeeID
JOIN Departments d ON e.DepartmentID = d.DepartmentID
ORDER BY e.EmployeeID

--11.Min Average Salary
SELECT TOP(1)
AVG(e.Salary) AS MinAverageSalary
	FROM Employees e
GROUP BY e.DepartmentID
ORDER BY MinAverageSalary