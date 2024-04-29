USE NorthwindDW24
GO



--Always load ALL dimensions before loading a fact

--Transform and load Employees from staging
INSERT INTO NorthwindDW24.dbo.DimEmployee(EmployeeID, EmployeeName, EmployeeTitle)
SELECT --Serves as values section of normal insert
	EmployeeID,
	--employee name (fname lname)
	FirstName + ' ' + LastName,
	Title
	--CANNOT use into as DW is already defined and need to add emp key, use insert instead
FROM NWStaging24.dbo.stgEmployees
;


--Transform and load Customers
INSERT INTO NorthwindDW24.dbo.DimCustomer(CustomerID, CompanyName, ContactName, ContactTitle, CustomerCountry, CustomerRegion, CustomerCity, CustomerPostalCode)
SELECT --91 rows
	CustomerID,
	CompanyName,
	ContactName,--messed up staging table, drop table in NWstaging and redefine
	ContactTitle,
	Country,
	--Region,
	CASE WHEN Region is NULL THEN 'N/A' ELSE Region END,
	City,
	--PostalCode
	CASE WHEN PostalCode is NULL THEN 'N/A' ELSE PostalCode END
FROM NWStaging24.dbo.stgCustomers
;


--Transform and LOAD Products
INSERT INTO NorthwindDW24.dbo.DimProduct(ProductID, ProductName, Discontinued, SupplierName, CategoryName)
SELECT --77 rows
	ProductID,
	ProductName,
	Discontinued,
	CompanyName,
	CategoryName
FROM NWStaging24.dbo.stgProducts
;

--Transform and Load Date
INSERT INTO NorthwindDW24.dbo.DimDate(DateKey, [Date], FullDateUSA, [DayOfWeek], [DayName], [DayOfMonth], [DayOfYear], WeekOfYear, [MonthName], MonthOfYear, [Quarter], QuarterName, [Year], IsWeekday)
SELECT --1827 rows
	DateKey,
	[Date],
	FullDateUSA,
	[DayOfWeek],
	[DayName],
	[DayOfMonth],
	[DayOfYear],
	WeekOfYear,
	[MonthName],
	MonthOfYear,
	[Quarter],
	QuarterName,
	[Year],
	IsWeekday
FROM NWStaging24.dbo.stgDimDate
;



--Transform and load Sales_fact
--add dimensions one after another

--add customerDim
SELECT
	c.CustomerKey, s.*
FROM NWStaging24.dbo.stgSalesFact s
	JOIN NorthwindDW24.dbo.DimCustomer c
	on s.CustomerID = c.CustomerID
;

--add employeeDim, need to delete data cause i have double the amount
SELECT
	c.CustomerKey, e.EmployeeKey, s.*
FROM NWStaging24.dbo.stgSalesFact s
	JOIN NorthwindDW24.dbo.DimCustomer c
	on s.CustomerID = c.CustomerID
	JOIN NorthwindDW24.dbo.DimEmployee e
	on s.EmployeeID = e.EmployeeID
;

--add ProductDim
SELECT
	c.CustomerKey, e.EmployeeKey, p.ProductKey, s.*
FROM NWStaging24.dbo.stgSalesFact s
	JOIN NorthwindDW24.dbo.DimCustomer c
	on s.CustomerID = c.CustomerID
	JOIN NorthwindDW24.dbo.DimEmployee e
	on s.EmployeeID = e.EmployeeID
	JOIN NorthwindDW24.dbo.DimProduct p
	on s.ProductID = p.ProductID
;

--add measures of facts
INSERT INTO NorthwindDW24.dbo.FactSales(
	ProductKey,
	CustomerKey,
	EmployeeKey,
	OrderDateKey,
	OrderID,
	Quantity,
	ExtendedPriceAmount,
	DiscountAmount,
	SoldAmount
)
SELECT
	p.ProductKey, c.CustomerKey, e.EmployeeKey,
	--s.OrderDate, into datekey
	convert(varchar(8), s.orderDate, 112) as OrderDateKey,
	s.orderID,
	s.Quantity, 
	s.Quantity * s.UnitPrice as ExtendedPriceAmount, 
	s.Quantity * s.UnitPrice * s.Discount as DiscountAmount,
	s.Quantity * s.UnitPrice * (1- s.Discount) as SoldAmount
FROM NWStaging24.dbo.stgSalesFact s
	JOIN NorthwindDW24.dbo.DimCustomer c
	on s.CustomerID = c.CustomerID
	JOIN NorthwindDW24.dbo.DimEmployee e
	on s.EmployeeID = e.EmployeeID
	JOIN NorthwindDW24.dbo.DimProduct p
	on s.ProductID = p.ProductID
;

SELECT * FROM NorthwindDW24.dbo.FactSales;

--Find the top ten valuable customer who had top total amount of $ in Northwind DB 
SELECT TOP 10 C.CompanyName, ROUND(SUM(D.Quantity * D.UnitPrice * (1-D.Discount)), 2) AS Total 
FROM Northwind.dbo.Customers C
	JOIN Northwind.dbo.Orders O 
	ON C.CustomerID = O.CustomerID
	JOIN Northwind.dbo.[Order Details] D
	ON O.OrderID = D.OrderID
GROUP BY C.CompanyName
ORDER BY Total DESC
;

--Find the top ten valuable customer who had top total amount of $ in Northwind DW
SELECT TOP 10 C.CompanyName, ROUND(SUM(SoldAmount), 2) as Total
FROM NorthwindDW24.dbo.FactSales F
	JOIN NorthwindDW24.dbo.DimCustomer C
	ON F.CustomerKey = C.CustomerKey
GROUP BY C.CompanyName
ORDER BY Total Desc
;