USE NorthwindDW24
GO

--Transform and load for DimShipper
INSERT INTO NorthwindDW24.dbo.DimShipper(ShipperID, ShipperName)
SELECT
	ShipperID,
	CompanyName
FROM NWStaging24.dbo.stgShippers
;
--END of DimShipper

--Transform and load for DimSupplier
INSERT INTO NorthwindDW24.dbo.DimSupplier(SupplierID, SupplierName, ContactName, ContactTitle)
SELECT
	SupplierID,
	CompanyName,
	ContactName,
	ContactTitle
FROM NWStaging24.dbo.stgSuppliers
;
--END of DimSupplier

SELECT
	P.ProductKey, f.*
FROM NWStaging24.dbo.stgFulfillmentFact f
	JOIN NorthwindDW24.dbo.DimProduct P
	on f.productID = P.ProductID
;

SELECT
	P.ProductKey, E.EmployeeKey, f.*
FROM NWStaging24.dbo.stgFulfillmentFact f
	JOIN NorthwindDW24.dbo.DimProduct P
	on f.productID = P.ProductID
	JOIN NorthwindDW24.dbo.DimEmployee E
	on f.EmployeeID = E.EmployeeID
;

SELECT
	P.ProductKey, E.EmployeeKey, SHP.ShipperKey, f.*
FROM NWStaging24.dbo.stgFulfillmentFact f
	JOIN NorthwindDW24.dbo.DimProduct P
	on f.productID = P.ProductID
	JOIN NorthwindDW24.dbo.DimEmployee E
	on f.EmployeeID = E.EmployeeID
	JOIN NorthwindDW24.dbo.DimShipper SHP
	on f.ShipVia = SHP.ShipperID
;

SELECT
	P.ProductKey, E.EmployeeKey, SHP.ShipperKey, SP.SupplierKey, f.*
FROM NWStaging24.dbo.stgFulfillmentFact f
	JOIN NorthwindDW24.dbo.DimProduct P
	on f.productID = P.ProductID
	JOIN NorthwindDW24.dbo.DimEmployee E
	on f.EmployeeID = E.EmployeeID
	JOIN NorthwindDW24.dbo.DimShipper SHP
	on f.ShipVia = SHP.ShipperID
	JOIN NorthwindDW24.dbo.DimSupplier SP
	on f.SupplierID = SP.SupplierID
;

--Transform and load for FactFulfillment
INSERT INTO NorthwindDW24.dbo.FactFulfillment(
	ProductKey,
	EmployeeKey,
	OrderDateKey,
	ShipperKey,
	SupplierKey,
	OrderID,
	OrderDate,
	ShippedDate,
	DeliveryTime
)
SELECT
	P.ProductKey,
	E.EmployeeKey, 
	convert(varchar(8), f.orderDate, 112) as OrderDateKey,
	SHP.ShipperKey,
	SP.SupplierKey,
	f.OrderID,
	f.OrderDate,
	f.ShippedDate,
	CASE WHEN DATEPART(day, f.ShippedDate - f.OrderDate) IS NULL THEN -1 ELSE DATEPART(day, f.ShippedDate - f.OrderDate) END AS DeliveryTime
FROM NWStaging24.dbo.stgFulfillmentFact f
	JOIN NorthwindDW24.dbo.DimProduct P
	on f.productID = P.ProductID
	JOIN NorthwindDW24.dbo.DimEmployee E
	on f.EmployeeID = E.EmployeeID
	JOIN NorthwindDW24.dbo.DimShipper SHP
	on f.ShipVia = SHP.ShipperID
	JOIN NorthwindDW24.dbo.DimSupplier SP
	on f.SupplierID = SP.SupplierID
;

--END of FactFulfillment
SELECT
*
FROM NorthwindDW24.dbo.FactFulfillment
;

--Best Suppliers
SELECT
	TOP 3 S.SupplierName, COUNT(F.SupplierKey) AS [Number of Orders]
FROM NorthwindDW24.dbo.FactFulfillment F
	JOIN NorthwindDW24.dbo.DimSupplier S
	ON F.ShipperKey = S.SupplierKey
GROUP BY S.SupplierName
ORDER BY [Number of Orders] DESC
;
--Top Sellers
SELECT 
	TOP 10 P.ProductName, COUNT(F.ProductKey) AS [Number of Orders]
FROM NorthwindDW24.dbo.FactFulfillment F
	JOIN NorthwindDW24.dbo.DimProduct P
	ON F.ProductKey = P.ProductKey
GROUP BY P.ProductName
ORDER BY [Number of Orders] DESC
;
--Which Employee places the most orders
SELECT 
	TOP 1 E.EmployeeName, COUNT(F.EmployeeKey) AS [Number of Orders]
FROM NorthwindDW24.dbo.DimEmployee E
	JOIN NorthwindDW24.dbo.FactFulfillment F
	ON E.EmployeeKey = F.EmployeeKey
GROUP BY E.EmployeeName
ORDER BY [Number of Orders] DESC
;
