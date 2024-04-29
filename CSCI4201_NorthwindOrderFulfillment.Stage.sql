USE NWStaging24
GO

SELECT
	ShipperID,
	CompanyName
INTO NWStaging24.dbo.stgShippers
FROM Northwind.dbo.Shippers
;

SELECT
	SupplierID,
	CompanyName,
	ContactName,
	ContactTitle
INTO NWStaging24.dbo.stgSuppliers
FROM Northwind.dbo.Suppliers
;

SELECT
	D.ProductID,
	O.EmployeeID,
	O.OrderDate,
	O.ShipVia,
	P.SupplierID,
	O.OrderID,
	O.ShippedDate
INTO NWStaging24.dbo.stgFulfillmentFact
FROM Northwind.dbo.Orders O
	JOIN Northwind.dbo.[Order Details] D
	ON O.OrderID = D.OrderID
	JOIN Northwind.dbo.Products P
	ON D.ProductID = P.ProductID
;