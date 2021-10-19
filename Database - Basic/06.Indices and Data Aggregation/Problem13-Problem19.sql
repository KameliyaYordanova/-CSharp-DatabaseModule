USE SoftUni
--13.Departments Total Salaries
SELECT DepartmentID, SUM(Salary) AS TotalSalary
		FROM Employees 
GROUP BY DepartmentID
ORDER BY DepartmentID

--14.Employees Minimum Salaries
SELECT DepartmentID, MIN(Salary) AS MinimumSalary
		FROM Employees
WHERE DepartmentID IN (2,5,7) AND HireDate > '2000-01-01'
GROUP BY DepartmentID

--15.Employees Average Salaries
SELECT * INTO EmployeSalaryOver30000
	FROM Employees
WHERE Salary > 30000

DELETE FROM EmployeSalaryOver30000
WHERE ManagerID = 42

UPDATE EmployeSalaryOver30000
SET Salary += 5000
WHERE DepartmentID = 1

SELECT DepartmentID, AVG(Salary) AS AverageSalary
	FROM EmployeSalaryOver30000
GROUP BY DepartmentID

--16.Employees Maximum Salaries
SELECT DepartmentID, MAX(Salary) AS MaxSalary
		FROM Employees
GROUP BY DepartmentID
HAVING MAX(Salary) < 30000 OR MAX(Salary) > 70000

--17.Employees Count Salaries
SELECT COUNT(*) AS [Count]
		FROM Employees
WHERE ManagerID IS NULL

--18.3rd Highest Salary
SELECT DepartmentID, Salary AS ThirdHighestSalary
		FROM (
				SELECT DepartmentID, Salary,
				DENSE_RANK() OVER (PARTITION BY DepartmentID ORDER BY Salary DESC) AS Ranked
				FROM Employees
				GROUP BY DepartmentID, Salary
		     ) AS ThirdSalary
WHERE Ranked = 3
SELECT * FROM Employees
ORDER BY DepartmentID, Salary DESC

--19.Salary Challenge
SELECT TOP (10) FirstName, LastName, DepartmentID
		FROM Employees e1
WHERE e1.Salary > ( SELECT AVG(Salary) AS AverageSalary
						FROM Employees AS e2
						WHERE e2.DepartmentID = e1.DepartmentID
					GROUP BY DepartmentID
				  )
ORDER BY DepartmentID 

