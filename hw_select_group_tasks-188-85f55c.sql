/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

TODO: напишите здесь свое решение

SELECT [StockItemID], [StockItemName]
  FROM [Warehouse].[StockItems]
  where ([StockItemName] like '%urgent%') or ([StockItemName] like 'Animal%');

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

TODO: напишите здесь свое решение

SELECT ps.SupplierID, ps.SupplierName
  FROM [Purchasing].[Suppliers] ps
    left join [Purchasing].[PurchaseOrders] po on po.[SupplierID] = ps.[SupplierID]
  where po.[SupplierID] is null;

/* Этот дешевле
SELECT ps.SupplierID, ps.SupplierName
  FROM [Purchasing].[Suppliers] ps
  where not exists(select 1 from [Purchasing].[PurchaseOrders] po
    where po.[SupplierID] = ps.[SupplierID]);*/

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

TODO: напишите здесь свое решение

SELECT distinct so.OrderID
  ,convert(nvarchar(16),so.OrderDate, 104) DateRus
  ,DATENAME(m, so.OrderDate) DateMonth
  ,DATEPART(q, so.OrderDate) DateQuarter
  ,floor((month(so.OrderDate)-1)/4)+1 DateT
  ,sc.[CustomerName]
  FROM [Sales].[Orders] so
    join [Sales].[OrderLines] sol on sol.OrderID = so.OrderID 
    join [Warehouse].[StockItems] ws on ws.[StockItemID] = sol.[StockItemID] 
    left join [Sales].[Customers] sc on sc.[CustomerID] = so.[CustomerID]
  where (ws.[UnitPrice] > 100 or (sol.[Quantity] > 20 and so.PickingCompletedWhen is not null))
ORDER BY DateQuarter,DateT,DateRus OFFSET 1000 ROWS FETCH FIRST 100 ROWS ONLY;

/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

TODO: напишите здесь свое решение

SELECT dm.DeliveryMethodName,po.ExpectedDeliveryDate, s.SupplierName, ap.FullName
  FROM [Purchasing].[PurchaseOrders] po
    join [Application].[DeliveryMethods] dm on dm.DeliveryMethodID = po.DeliveryMethodID
    left join [Purchasing].[Suppliers] s on s.SupplierID = po.SupplierID
	left join [Application].[People] ap on ap.PersonID = po.ContactPersonID
  where (po.[ExpectedDeliveryDate] between '20130101' and '20130131'
    and dm.DeliveryMethodName in ('Air Freight','Refrigerated Air Freight')
    and po.IsOrderFinalized = 1);

/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

TODO: напишите здесь свое решение

SELECT TOP (10) sc.[CustomerName],ap.[FullName],so.* 
  FROM [Sales].[Orders] so
    left join [Sales].[Customers] sc on sc.[CustomerID] = so.[CustomerID]
    left join [Application].[People] ap on ap.[PersonID] = so.[SalespersonPersonID]
  order by so.[OrderDate] desc;

/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

TODO: напишите здесь свое решение

SELECT distinct sc.[CustomerID],sc.[CustomerName],sc.[PhoneNumber]
  FROM [Warehouse].[StockItems] ws
    join [Sales].[OrderLines] sol on sol.[StockItemID] = ws.[StockItemID]
	left join [Sales].[Orders] so on so.[OrderID] = sol.[OrderID]
	left join [Sales].[Customers] sc on sc.[CustomerID] = so.[CustomerID]
  where ws.[StockItemName] = 'Chocolate frogs 250g';
