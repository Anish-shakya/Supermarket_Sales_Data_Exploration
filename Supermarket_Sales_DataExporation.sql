select * from supermarket_sales

-----Rounding Off columns data to zero decimal -----
UPDATE supermarket_sales
SET Unit_price = ROUND(Unit_price,0),Tax = ROUND(TAX,0),
Total = ROUND(Total,0), Cost_of_good_sold = ROUND(Cost_of_good_sold,0),
gross_income = ROUND(gross_income,0), gross_margin_percentage = ROUND(gross_margin_percentage,1),Rating = ROUND(Rating,0)





------------------------------------------Formating Date-----------------------------------
-----Extracting Year and Month from date 

SELECT 
	Date,
	YEAR(Date) AS DateYear,
	MONTH(Date) AS DateMonth
FROM supermarket_sales

---creating seperate column for year and month
ALTER TABLE supermarket_sales
ADD Year int ,Month varchar(20)
	
UPDATE supermarket_sales
SET Year = YEAR(Date), Month =DATENAME(MONTH,Date)


--------Creating View With required Column for further analysis --------------

CREATE VIEW SalesData AS
SELECT Invoice_ID , Branch,City , Year,Month,Customer_type,Gender,Product_line,Unit_price,Quantity,Tax,Total,Payment,Cost_of_good_sold,gross_margin_percentage,gross_income,Rating
FROM supermarket_sales
WHERE Invoice_ID IS NOT NULL
GO

SELECT * FROM SalesData


------checking city with highest sales -------------

SELECT City,SUM(Total) AS TotalSales
FROM SalesData
GROUP BY City
ORDER BY TotalSales DESC


----- Checking total sales by catagory in each city------
SELECT City,Product_line,sum(Total) As TotalSales
FROM SalesData
GROUP BY City,Product_line
ORDER BY City,TotalSales DESC


------Checking which Product_line sell most in each city-----
-----we can achive the output by using the sub queires-------

---above solution break down---------

--This will show total sales of each catagory in each city 
SELECT ts.City,ts.Product_line,ts.TotalSales           
FROM(
	SELECT City,Product_line,SUM(Total) AS TotalSales
	FROM SalesData
	GROUP BY  City,Product_line
) ts

--This will show the highest sold Product_line in each city 
SELECT ms.City,MAX(TotalSales) AS MaxSales
	FROM (
		SELECT City,Product_line,SUM(Total) AS TotalSales
		FROM SalesData
		GROUP BY City,Product_line
	)ms
	GROUP BY ms.City

--now self joining the table to filter the output--

SELECT ts.City,ts.Product_line,ts.TotalSales
FROM(
	SELECT City,Product_line,SUM(Total) AS TotalSales
	FROM SalesData
	GROUP BY  City,Product_line
) ts
JOIN (
	SELECT ms.City,MAX(TotalSales) AS MaxSales
	FROM (
		SELECT City,Product_line,SUM(Total) AS TotalSales
		FROM SalesData
		GROUP BY City,Product_line
	)ms
	GROUP BY ms.City
) J ON J.City = ts.City AND  ts.TotalSales = j.MaxSales
ORDER BY ts.TotalSales DESC

--------Checking Total On the Basic of Customer_Type------

SELECT Customer_type, Sum(Total) AS TotalSales
FROM SalesData
Group BY Customer_type
ORDER BY TotalSales DESC


--------Checking highest Sales On the Basic of Customer_Type IN Each City------

SELECT ts.City,ts.Customer_type,ts.TotalSales
FROM(
	SELECT City,Customer_type,SUM(Total) AS TotalSales
	FROM SalesData
	GROUP BY City,Customer_type
)ts
JOIN (
	SELECT ms.City,MAX(TotalSales) AS MaxSales
	FROM(
	SELECT City,Customer_type,SUM(Total) AS TotalSales
	FROM SalesData
	GROUP BY City,Customer_type
	)ms
	GROUP BY ms.City
)j ON j.City = ts.City AND ts.TotalSales = j.MaxSales


---- Checking total payment from different payment mode----
SELECT Payment,SUM(Total) AS TotalPayment
FROM SalesData
GROUP BY Payment	
ORDER BY TotalPayment DESC


---- Counting Total number of People using cash,Ewallet , Credit Card

SELECT 
    Payment, 
    COUNT(Invoice_ID ) AS total_customers 
FROM 
    SalesData
GROUP BY Payment


---- Counting Total number of People using cash,Ewallet , Credit Card in each city

SELECT City,Payment,COUNT(Invoice_ID) AS total_customer
FROM SalesData
GROUP BY City,Payment  
ORDER BY City


---- checking City with popular medium of payment cash or Ewallet or Credit Card 
SELECT c.City,c.Payment,c.Users
FROM(
	SELECT City,Payment,COUNT(Invoice_ID) AS Users 
	FROM SalesData	
	GROUP BY City,Payment
) c
JOIN (
	SELECT m.City,MAX(Users) As Maxuser
	FROM(
		SELECT City,Payment,COUNT(Invoice_ID) AS Users
		FROM SalesData
		GROUP BY City,Payment 
		) m
		GROUP BY m.City
) j ON j.city = c.City AND j.MaxUser = c.Users
ORDER BY c.City


select * from SalesData


-----Checking cost of good sold of each product line with total profit  form each product line

SELECT Product_line, SUM(Cost_of_good_sold) AS total_cogs , SUM(gross_income) AS total_profit
FROM SalesData
GROUP BY Product_line
ORDER BY total_profit DESC

----filter by Yangon city
SELECT Product_line, SUM(Cost_of_good_sold) AS total_cogs , SUM(gross_income) AS total_profit
FROM SalesData
WHERE City = 'Yangon'
GROUP BY Product_line
ORDER BY total_profit DESC





