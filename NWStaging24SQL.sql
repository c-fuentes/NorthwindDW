USE NWStaging24 
GO



---access source data about customer
SELECT 
	CustomerID, 
	CompanyName, 
	ContactName,
	ContactTitle, 
	Country, 
	Region,		
	City, 
	PostalCode
--INTO NWStaging24.dbo.stgCustomers
FROM Northwind.dbo.Customers
;

SELECT
	*
FROM NWStaging24.dbo.stgCustomers
;
--Employee Staging
SELECT
	EmployeeID,
	LastName,
	FirstName, 
	Title
--INTO NWStaging24.dbo.stgEmployees
FROM Northwind.dbo.Employees
;

SELECT
	*
FROM NWStaging24.dbo.stgEmployees
;
--END of employee staging


--Product Staging
SELECT
	ProductID,
	ProductName,
	Discontinued,
	--SupplierName not available so join using Suppliers table
	CompanyName, --got from supplier table
	--CategoryName, same thing as SupplierName
	CategoryName --got from supplier table
--INTO NWStaging24.dbo.stgProducts
FROM Northwind.dbo.Products
	JOIN Northwind.dbo.Suppliers 
		on Northwind.dbo.Products.SupplierID = Northwind.dbo.Suppliers.SupplierID
	JOIN Northwind.dbo.Categories 
		on Northwind.dbo.Products.CategoryID = Northwind.dbo.Categories.CategoryID
;

SELECT * FROM NWStaging24.dbo.stgProducts;
--End of product staging

--Date staging
SELECT
	*
--INTO NWStaging24.dbo.stgDimDate
FROM ExternalSource24.dbo.DimDate
;

SELECT * FROM NWStaging24.dbo.stgDimDate;
--End of date staging

--Sales fact staging

SELECT 
	D.ProductID,
	O.CustomerID,
	O.EmployeeID,
	O.OrderDate,
	O.ShippedDate,
	O.orderID, 
	UnitPrice,
	Quantity,
	Discount
--INTO NWStaging24.dbo.stgSalesFact
FROM Northwind.dbo.Orders O
	JOIN Northwind.dbo.[Order Details] D
	ON O.OrderID = D.OrderID
;

--END of salesfact staging