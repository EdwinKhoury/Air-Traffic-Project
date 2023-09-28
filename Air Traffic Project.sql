
--1) Searching for duplicates 

SELECT Activity_Period, Operating_Airline, Operating_Airline_IATA_Code, Published_Airline, Published_Airline_IATA_Code, GEO_Summary, GEO_Region, Price_Category_Code,Terminal,Boarding_Area, Activity_Type_Code, Passenger_Count, Year, Month
FROM AirTrafficProject..ATPS
GROUP BY Activity_Period, Operating_Airline, Operating_Airline_IATA_Code, Published_Airline, Published_Airline_IATA_Code, GEO_Summary, GEO_Region, Price_Category_Code,Terminal,Boarding_Area, Activity_Type_Code, Passenger_Count, Year, Month
HAVING COUNT (*) > 1 

----------------

--2) Count the null values in each of the columns 

SELECT 
	COUNT(*) - COUNT(Activity_Period) AS Activity_Period,
	COUNT(*) - COUNT(Operating_Airline) AS Operating_Airline,
	COUNT(*) - COUNT(Operating_Airline_IATA_Code) AS Operating_Airline_IATA_Code,
	COUNT(*) - COUNT(Published_Airline) AS Published_Airline,
	COUNT(*) - COUNT(Published_Airline_IATA_Code) AS Published_Airline_IATA_Code,
	COUNT(*) - COUNT(GEO_Summary) AS GEO_Summary,
	COUNT(*) - COUNT(GEO_Region) AS GEO_Region,
	COUNT(*) - COUNT(Price_Category_Code) AS Price_Category_Code,
	COUNT(*) - COUNT(Terminal) AS Terminal,
	COUNT(*) - COUNT(Boarding_Area) AS Boarding_Area,
	COUNT(*) - COUNT( Activity_Type_Code) AS  Activity_Type_Code,
	COUNT(*) - COUNT(Passenger_Count) AS Passenger_Count,
	COUNT(*) - COUNT(Year) AS year,
	COUNT(*) - COUNT(Month) AS month
FROM AirTrafficProject..ATPS
--The Operating_Airline_IATA_Code and Published_Airline_IATA_Code had 54 NULL values.

----------------

--3) Delete rows with NULL values 
DELETE 
FROM AirTrafficProject..ATPS
WHERE Operating_Airline_IATA_Code is NULL
	AND Published_Airline_IATA_Code is NULL

----------------

--4) Number of passenger per year for all GEO regions and operating airlines 
SELECT year, Sum (passenger_count) AS Passenger_per_year
FROM AirTrafficProject..ATPS
GROUP BY Year
ORDER BY Passenger_per_year DESC
--2015 is the year with the highest number of passengers. 
--The data  was only recorded up until March 2016: that explains why 2016 is ranked last when there is a clear increasing path from 2005 to 2015.

----------------

--5) Number of passenger per month per year for all GEO regions and operating airlines 
SELECT
	CASE
        WHEN Month = 'January' THEN 1
        WHEN Month = 'February' THEN 2
        WHEN Month = 'March' THEN 3
        WHEN Month = 'April' THEN 4
        WHEN Month = 'May' THEN 5
        WHEN Month = 'June' THEN 6
        WHEN Month = 'July' THEN 7
        WHEN Month = 'August' THEN 8
        WHEN Month = 'September' THEN 9
        WHEN Month = 'October' THEN 10
        WHEN Month = 'November' THEN 11
        WHEN Month = 'December' THEN 12
     END AS month,
	 year, SUM(passenger_count) AS num_of_passenger
FROM AirTrafficProject..ATPS
GROUP BY Month, year
ORDER BY Year, month

----------------

--6) Number of passenger per month over the years for all GEO regions and operating airlines 

SELECT Month, SUM (passenger_count) AS num_of_passenger
FROM AirTrafficProject..ATPS
GROUP BY month
ORDER BY  num_of_passenger DESC
-- Over the years, August is the month that counts the highest number of passenger with a total of 42,890,522 over 10 years
--whereas February is the month where the population travels the least with a total of 30,545,991 over 10 years.

----------------

--7) Passenger count per year and per airline

SELECT Year, Operating_Airline, SUM (passenger_count) AS total_passengers
FROM AirTrafficProject..ATPS
GROUP BY year, Operating_Airline
ORDER BY year, total_passengers DESC
--From 2005 to 2016, United Airlines had the most passengers every year.

----------------

--8) Most international region visited

SELECT GEO_Summary, GEO_Region, SUM (Passenger_Count) AS total_passengers
FROM AirTrafficProject..ATPS
WHERE GEO_Summary = 'International'
GROUP BY  GEO_Region, GEO_Summary
ORDER BY  total_passengers DESC
--From all the international region visited, Asia had the most passengers with 44,213,277 
--and South America had the least passengers with 250,741 

----------------

--9) Airline with the most international passengers

SELECT GEO_Summary, Operating_Airline, SUM(passenger_count) AS total_passenger
FROM AirTrafficProject..ATPS
WHERE GEO_Summary = 'International'
GROUP BY  Operating_Airline, GEO_Summary
ORDER BY total_passenger DESC
--United Airlines has the highest number of international passengers with a total of 33,849,703 passengers over the years.
--Evergreen International Airlines had only 4 international passengers recorded. 

----------------

--10) Airline with the most domestic passengers

SELECT GEO_Summary, Operating_Airline, SUM (passenger_count) AS total_passenger
FROM AirTrafficProject..ATPS
WHERE GEO_Summary = 'Domestic'
GROUP BY Operating_Airline, GEO_Summary
ORDER BY total_passenger DESC
--United Airlines has the highest number of domestic passengers with a total of 137,445,500 passengers over the years.
--Atlas Air, Inc had only 71 domestic passengers recorded. 

----------------

--11) Number of passenger per month and per GEO region for all operating airlines 

SELECT GEO_Region, year, 
		CASE
            WHEN Month = 'January' THEN 1
            WHEN Month = 'February' THEN 2
            WHEN Month = 'March' THEN 3
            WHEN Month = 'April' THEN 4
            WHEN Month = 'May' THEN 5
            WHEN Month = 'June' THEN 6
            WHEN Month = 'July' THEN 7
            WHEN Month = 'August' THEN 8
            WHEN Month = 'September' THEN 9
            WHEN Month = 'October' THEN 10
            WHEN Month = 'November' THEN 11
            WHEN Month = 'December' THEN 12
        END AS month,
		 SUM(passenger_count) AS total_passengers
FROM  AirTrafficProject..ATPS
GROUP BY GEO_Region, year, month
ORDER BY GEO_Region, year, month

----------------

--12) Rolling average of the total passengers for every region

WITH PassengersTotals AS (
	SELECT GEO_Region, year, month, SUM(passenger_count) AS total_passengers 
	FROM AirTrafficProject..ATPS
	GROUP BY GEO_Region, year, month
),
RollingAverage AS (
	SELECT GEO_Region, year, 
		CASE
            WHEN Month = 'January' THEN 1
            WHEN Month = 'February' THEN 2
            WHEN Month = 'March' THEN 3
            WHEN Month = 'April' THEN 4
            WHEN Month = 'May' THEN 5
            WHEN Month = 'June' THEN 6
            WHEN Month = 'July' THEN 7
            WHEN Month = 'August' THEN 8
            WHEN Month = 'September' THEN 9
            WHEN Month = 'October' THEN 10
            WHEN Month = 'November' THEN 11
            WHEN Month = 'December' THEN 12
         END AS month, 
		 total_passengers, 
		 AVG(total_passengers) OVER (PARTITION BY GEO_Region ORDER BY Year, month ROWS between 11 PRECEDING and CURRENT ROW) AS Rolling_avg
	FROM PassengersTotals
)
SELECT GEO_Region, year, month, total_passengers, rolling_avg
FROM RollingAverage
ORDER BY GEO_Region, year, month

----------------

--13) Since the passenger count in the US is relatively high compared to the rest of the regions, we are going to ommit this region

WITH PassengersTotals AS (
	SELECT GEO_Region, year, month,
		 SUM (passenger_count) AS total_passengers 
	FROM AirTrafficProject..ATPS
	GROUP BY GEO_Region, year, month
),
RollingAverage AS (
	SELECT GEO_Region, year, 
		CASE
            WHEN Month = 'January' THEN 1
            WHEN Month = 'February' THEN 2
            WHEN Month = 'March' THEN 3
            WHEN Month = 'April' THEN 4
            WHEN Month = 'May' THEN 5
            WHEN Month = 'June' THEN 6
            WHEN Month = 'July' THEN 7
            WHEN Month = 'August' THEN 8
            WHEN Month = 'September' THEN 9
            WHEN Month = 'October' THEN 10
            WHEN Month = 'November' THEN 11
            WHEN Month = 'December' THEN 12
         END AS month, 
		 total_passengers, 
		 AVG(total_passengers) OVER (PARTITION BY GEO_Region ORDER BY Year, month ROWS between 11 PRECEDING and CURRENT ROW) AS Rolling_avg

	FROM PassengersTotals
	WHERE GEO_Region != 'US'
)
SELECT GEO_Region, year, month, total_passengers, rolling_avg
FROM RollingAverage
ORDER BY GEO_Region, year, month

----------------

--14) Number of passenger that are either international or domestic

SELECT Geo_Summary, SUM(Passenger_Count) AS total_passengers
FROM AirTrafficProject..ATPS
GROUP BY GEO_Summary
--The total domestic passengers over the years (339,037,809) is greater the international (101,138,719)

----------------

--15) Total number of airlines

SELECT  COUNT(DISTINCT Operating_Airline) AS num_of_airlines
FROM AirTrafficProject..ATPS

----------------

--16) Airlines that fly only domestic, only international, and both

WITH DomesticAirlines AS (
  SELECT DISTINCT Operating_Airline
  FROM AirTrafficProject..ATPS
  WHERE Geo_Summary = 'Domestic'
),
InternationalAirlines AS (
  SELECT DISTINCT Operating_Airline
  FROM AirTrafficProject..ATPS
  WHERE Geo_Summary = 'International'
),
InternationalDomesticAirlines AS (
  SELECT DISTINCT Operating_Airline
  FROM AirTrafficProject..ATPS
  WHERE Operating_Airline IN (SELECT Operating_Airline FROM DomesticAirlines)
    and Operating_Airline IN (SELECT Operating_Airline FROM InternationalAirlines)
)

SELECT 'Only Domestic' AS Flight_type, Operating_Airline 
FROM DomesticAirlines
WHERE Operating_Airline not IN (SELECT Operating_Airline FROM InternationalDomesticAirlines)
UNION

SELECT 'Only International' AS Flight_type, Operating_Airline 
FROM InternationalAirlines
WHERE Operating_Airline not IN (SELECT Operating_Airline FROM InternationalDomesticAirlines)
UNION

SELECT 'International and Domestic' AS Flight_type, Operating_Airline 
FROM InternationalDomesticAirlines

----------------

--17) Number of airlines that fly only domestic, only international, and both

WITH DomesticAirlines AS (
  SELECT distinct Operating_Airline
  FROM AirTrafficProject..ATPS
  WHERE Geo_Summary = 'Domestic'
),
InternationalAirlines AS (
  SELECT distinct Operating_Airline
  FROM AirTrafficProject..ATPS
  WHERE Geo_Summary = 'International'
),
InternationalDomesticAirlines AS (
  SELECT distinct Operating_Airline
  FROM AirTrafficProject..ATPS
  WHERE Operating_Airline IN (SELECT Operating_Airline FROM DomesticAirlines)
    and Operating_Airline IN (SELECT Operating_Airline FROM InternationalAirlines)
)

SELECT 'Only Domestic' AS Flight_type, COUNT(*) AS num_of_operating_airlines
FROM DomesticAirlines
WHERE Operating_Airline not IN (SELECT Operating_Airline FROM InternationalDomesticAirlines)
UNION

SELECT 'Only International' AS Flight_type, COUNT(*) AS num_of_operating_airlines
FROM InternationalAirlines
WHERE Operating_Airline not IN (SELECT Operating_Airline FROM InternationalDomesticAirlines)
UNION

SELECT 'International and Domestic' AS Flight_type, COUNT(*) AS num_of_operating_airlines
FROM InternationalDomesticAirlines

----------------

--18) Airlines and regions where each airline has the most total passenger count

WITH RegionPassengerCounts AS (
  SELECT
    operating_airline,
    GEO_Region,
    SUM(passenger_count) AS total_passenger_count
  FROM AirTrafficProject..ATPS
  GROUP BY operating_airline, GEO_Region
)

SELECT RPC1.Operating_Airline, RPC1.GEO_Region, RPC1.total_passenger_count
FROM RegionPassengerCounts AS RPC1
JOIN (
	SELECT Operating_Airline, MAX (total_passenger_count) AS max_total_pass_count
	FROM RegionPassengerCounts
	GROUP BY  Operating_Airline ) RPC2
ON RPC1.Operating_Airline = RPC2.Operating_Airline
AND RPC1.total_passenger_count = RPC2. max_total_pass_count

ORDER BY RPC1.total_passenger_count DESC
--US is the region where the United Airlines has the highest number of passengers with 137,445,500 in total
--Europe is the region where Lufthansa German Airlines has the highest number of passengers 4,979,907 in total