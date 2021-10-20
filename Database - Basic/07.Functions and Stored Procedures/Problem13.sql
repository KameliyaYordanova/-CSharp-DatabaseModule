USE Diablo
--13.Scalar Function: Cash in User Games Odd Rows
GO
CREATE FUNCTION ufn_CashInUsersGames(@gameName NVARCHAR(50))
RETURNS TABLE
AS
RETURN SELECT(
				SELECT SUM(Cash) AS SumCash FROM ( 
				SELECT g.[Name], ug.Cash,
				ROW_NUMBER() OVER (PARTITION BY g.[Name] ORDER BY ug.Cash DESC) AS RowNum
				FROM Games g
				JOIN UsersGames ug ON g.Id = ug.GameId
				WHERE g.[Name] = @gameName
              ) AS RowNumQuery
WHERE RowNum % 2 <> 0
			 ) AS SumCash

SELECT * FROM ufn_CashInUsersGames('Love in a mist')

