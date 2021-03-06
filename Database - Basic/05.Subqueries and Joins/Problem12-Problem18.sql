USE Geography
--12.Highest Peaks in Bulgaria
SELECT * FROM Rivers
SELECT * FROM Countries

SELECT mc.CountryCode, m.MountainRange, p.PeakName, p.Elevation
	 FROM Mountains m
JOIN Peaks p ON m.Id = p.MountainId
JOIN MountainsCountries mc ON mc.MountainId = m.Id
WHERE p.Elevation > 2835 AND mc.CountryCode = 'BG'
ORDER BY p.Elevation DESC

--13.Count Mountain Ranges
SELECT mc.CountryCode, COUNT(*) AS MountainRanges
	FROM Mountains m
JOIN MountainsCountries mc ON mc.MountainId = m.Id
WHERE mc.CountryCode IN ('RU', 'BG', 'US')
GROUP BY mc.CountryCode

--14.Countries with Rivers
SELECT TOP(5) c.CountryName, r.RiverName
		FROM Rivers r
RIGHT JOIN CountriesRivers cr ON
cr.RiverId = r.Id
RIGHT JOIN Countries c ON
cr.CountryCode = c.CountryCode
WHERE c.ContinentCode = 'AF'
ORDER BY c.CountryName

--15.*Continents and Currencies
SELECT ContinentCode, CurrencyCode, CurrencyCount AS CurrencyUsage 
	FROM (
			SELECT ContinentCode, CurrencyCode, CurrencyCount,
					DENSE_RANK() OVER(PARTITION BY ContinentCode ORDER BY CurrencyCount DESC)
					AS CurrencyRank
			FROM (
						SELECT ContinentCode, CurrencyCode, COUNT(*) AS CurrencyCount
						FROM Countries
						GROUP BY ContinentCode, CurrencyCode
				) AS CurrencyCountQuery
			WHERE CurrencyCount > 1
		) AS CurrencyRankingQuery
WHERE CurrencyRank = 1
ORDER BY ContinentCode

--16.Countries Without Any Mountains
SELECT COUNT(*) AS Count
FROM (
	SELECT CountryName FROM Countries c
	LEFT JOIN MountainsCountries mc ON
	mc.CountryCode = c.CountryCode
	WHERE mc.CountryCode IS NULL 
	) AS CountryWithoutMountains

--17.Highest Peak and Longest River by Country
SELECT TOP(5) CountryName,
	MAX(p.Elevation) AS HighestPeakElevation,
	MAX(r.[Length]) AS LongestRiverLength
	FROM Countries c 
LEFT JOIN CountriesRivers cr ON
cr.CountryCode = c.CountryCode
LEFT JOIN Rivers r ON
cr.RiverId = r.Id
LEFT JOIN MountainsCountries mc ON
c.CountryCode = mc.CountryCode
LEFT JOIN Mountains m ON
mc.MountainId = m.Id
LEFT JOIN Peaks p ON
p.MountainId = m.Id
GROUP BY c.CountryName
ORDER BY HighestPeakElevation DESC, LongestRiverLength DESC, CountryName

--18.Highest Peak Name and Elevation by Country
SELECT TOP(5) Country,
	   CASE 
			WHEN PeakName IS NULL THEN '(no highest peak)'
			ELSE PeakName
		END AS [Highest Peak Name],
	   CASE 
			WHEN Elevation IS NULL THEN 0
			ELSE Elevation
        END AS [Highest Peak Elevation],
	   CASE
			WHEN MountainRange IS NULL THEN '(no mountain)'
			ELSE MountainRange
		END AS [Mountain]
				FROM ( 
							SELECT * ,
								  DENSE_RANK() OVER
						(PARTITION BY Country ORDER BY Elevation DESC) AS PeakRank
					FROM   ( 
									SELECT CountryName AS Country,
										   p.PeakName,
										   p.Elevation,
										   m.MountainRange
									FROM Countries c
									LEFT JOIN MountainsCountries mc ON
									mc.CountryCode = c.CountryCode
									LEFT JOIN Mountains m ON
									mc.MountainId = m.Id
									LEFT JOIN Peaks p ON
									p.MountainId = m.Id
						   ) AS FullInfoQuery
				) AS PeakRankingsQuery
WHERE PeakRank = 1
ORDER BY Country, [Highest Peak Name]