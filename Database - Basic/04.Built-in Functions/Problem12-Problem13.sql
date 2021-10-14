
--12.Countries Holding ‘A’ 3 or More Times
SELECT [CountryName],[IsoCode] FROM [dbo].[Countries]
WHERE LEN([CountryName]) - 2 > LEN(REPLACE([CountryName],'A',''))
ORDER BY [IsoCode]

--13.Mix of Peak and River Names
SELECT [PeakName],
[RiverName],
CONCAT
(Lower
(SUBSTRING(PeakName,1,Len(PeakName)-1)),Lower(RiverName)) AS Mix 
FROM [Peaks],[Rivers]
WHERE SUBSTRING(PeakName,Len(PeakName),1) = SUBSTRING(RiverName,1,1)
ORDER BY Mix
