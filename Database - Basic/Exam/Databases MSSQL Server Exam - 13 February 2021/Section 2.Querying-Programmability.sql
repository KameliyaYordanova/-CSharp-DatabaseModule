--5.Commits
SELECT Id, Message, RepositoryId, ContributorId FROM Commits
ORDER BY Id, Message, RepositoryId, ContributorId

--6.Front-end
SELECT Id, [Name], Size FROM Files
WHERE Size > 1000 AND [Name] LIKE '%html%'
ORDER BY Size DESC, Id, [Name]

--7.Issue Assignment
SELECT i.Id, CONCAT(u.Username,' : ', i.Title) AS IssueAssignee 
FROM Issues i
JOIN Users u ON u.Id = i.AssigneeId
ORDER BY i.Id DESC, I.AssigneeId

--8.Single Files
SELECT fL.Id, fl.[Name], CONCAT(fl.Size, 'KB') AS Size
FROM Files f
RIGHT JOIN Files fl ON f.ParentId = fl.Id
WHERE f.ParentId IS NULL
ORDER BY fl.Id, fl.[Name], fl.Size DESC

--9.Commits in Repositories
SELECT TOP(5) r.Id, r.Name, COUNT(c.Id) AS Commits
FROM Repositories r
JOIN Commits c ON c.RepositoryId = r.Id
JOIN RepositoriesContributors rc ON rc.RepositoryId = r.Id
GROUP BY r.Id, r.Name
ORDER BY Commits DESC, r.Id, r.Name


--10.Average Size
SELECT u.Username, AVG(f.Size) AS Size
FROM Users u
JOIN Commits c ON c.ContributorId = u.Id
JOIN Files f ON f.CommitId = c.Id
GROUP BY Username
ORDER BY Size DESC, Username

--11.All User Commits
GO
CREATE FUNCTION udf_AllUserCommits(@username VARCHAR(30))
RETURNS INT
AS
BEGIN
		DECLARE @result INT = (SELECT COUNT(*) FROM Users u
								JOIN Commits c ON c.ContributorId = u.Id
								WHERE u.Username = @username);
		RETURN @result;
END

SELECT dbo.udf_AllUserCommits('UnderSinduxrein')

--12.Search for Files
GO
ALTER PROCEDURE usp_SearchForFiles(@fileExtension VARCHAR(10))
AS
BEGIN
	SELECT Id, [Name], CONCAT(Size,'KB') AS Size 
					   FROM Files
	WHERE [Name] LIKE CONCAT('%',@fileExtension)
	ORDER BY Id, [Name], Size DESC
END

EXEC usp_SearchForFiles 'txt'