--1.
SELECT *
  FROM [Warehouse].[StockItems]
  where ([StockItemName] like '%urgent%') or ([StockItemName] like 'Animal%');
--2.
SELECT ps.*
  FROM [Purchasing].[Suppliers] ps
  where not exists(select 1 from [Purchasing].[PurchaseOrders] po
    where po.[SupplierID] = ps.[SupplierID]);

SELECT ps.*
  FROM [Purchasing].[Suppliers] ps
    left join [Purchasing].[PurchaseOrders] po on po.[SupplierID] = ps.[SupplierID]
  where po.[SupplierID] is null;
--3.
SELECT distinct so.*
  FROM [Sales].[Orders] so
    join [Sales].[OrderLines] sol on sol.OrderID = so.OrderID 
    join [Warehouse].[StockItems] ws on ws.[StockItemID] = sol.[StockItemID] 
	  and (ws.[UnitPrice] > 100 or (sol.[Quantity] > 20 and so.PickingCompletedWhen is not null))

SELECT so.*
  FROM [Sales].[Orders] so
  where exists(
    select 1 from [Sales].[OrderLines] sol
      join [Warehouse].[StockItems] ws on ws.[StockItemID] = sol.[StockItemID]
	  where sol.OrderID = so.OrderID and (ws.[UnitPrice] > 100 or (sol.[Quantity] > 20 and so.PickingCompletedWhen is not null)));
--4.
SELECT s.SupplierName, po.*
  FROM [Purchasing].[PurchaseOrders] po
    join [Application].[DeliveryMethods] dm on dm.DeliveryMethodID = po.DeliveryMethodID
    left join [Purchasing].[Suppliers] s on s.SupplierID = po.SupplierID
  where ((po.[ExpectedDeliveryDate] between '20130101' and '20130131'
    and dm.DeliveryMethodName in ('Air Freight','Refrigerated Air Freight'))
    or po.IsOrderFinalized = 1);
--5.
SELECT TOP (10) sc.[CustomerName],ap.[FullName],so.* 
  FROM [Sales].[Orders] so
    left join [Sales].[Customers] sc on sc.[CustomerID] = so.[CustomerID]
    left join [Application].[People] ap on ap.[PersonID] = so.[SalespersonPersonID]
  order by so.[OrderDate] desc;
--6.
SELECT distinct sc.[CustomerID],sc.[CustomerName],sc.[PhoneNumber]
  FROM [Warehouse].[StockItems] ws
    join [Sales].[OrderLines] sol on sol.[StockItemID] = ws.[StockItemID]
	left join [Sales].[Orders] so on so.[OrderID] = sol.[OrderID]
	left join [Sales].[Customers] sc on sc.[CustomerID] = so.[CustomerID]
  where ws.[StockItemName] = 'Chocolate frogs 250g';
