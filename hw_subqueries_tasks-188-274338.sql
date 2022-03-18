/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

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
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

TODO: напишите здесь свое решение

select ap.PersonID, ap.FullName
	from Application.People ap
		left join Sales.Invoices si on si.SalespersonPersonID = ap.PersonID and si.InvoiceDate = '20150704'
	where ap.IsSalesPerson = 1
	  and si.SalespersonPersonID is null;
go

select ap.PersonID, ap.FullName
	from Application.People ap
	where ap.IsSalesPerson = 1
	  and not exists(select 1 from Sales.Invoices si where si.SalespersonPersonID = ap.PersonID and si.InvoiceDate = '20150704');
go

with CTE_Invoices as (select distinct si.SalespersonPersonID from Sales.Invoices si where si.InvoiceDate = '20150704')
select ap.PersonID, ap.FullName 
  from Application.People ap
    left join CTE_Invoices ci on ci.SalespersonPersonID = ap.PersonID 
  where ap.IsSalesPerson = 1
    and ci.SalespersonPersonID is null;
go

with CTE_Invoices as (select distinct si.SalespersonPersonID from Sales.Invoices si where si.InvoiceDate = '20150704')
select ap.PersonID, ap.FullName 
  from Application.People ap
    left join CTE_Invoices ci on ci.SalespersonPersonID = ap.PersonID 
  where ap.IsSalesPerson = 1
    and not exists(select 1 from CTE_Invoices ci where ci.SalespersonPersonID = ap.PersonID);
go



/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

TODO: напишите здесь свое решение

select top 1 WITH TIES si.StockItemID, si.StockItemName, si.UnitPrice
from Warehouse.StockItems si
order by 3 

select si.StockItemID, si.StockItemName, si.UnitPrice
from Warehouse.StockItems si
where si.UnitPrice = (select min(si.UnitPrice) from Warehouse.StockItems si)
order by 3 

select si.StockItemID, si.StockItemName, si.UnitPrice
from Warehouse.StockItems si
where si.UnitPrice = (select top 1 si.UnitPrice from Warehouse.StockItems si order by 1)
order by 3 

/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

TODO: напишите здесь свое решение

/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

TODO: напишите здесь свое решение

select top 5 sc.CustomerID, sc.CustomerName, sct.TransactionAmount 
from Sales.CustomerTransactions sct
  left join sales.Customers sc on sc.CustomerID = sct.CustomerID
order by sct.TransactionAmount desc
go

with cte_trans as (
select top 5 sct.CustomerID, sct.TransactionAmount 
from Sales.CustomerTransactions sct  
order by sct.TransactionAmount desc)
select sc.CustomerID, sc.CustomerName, sct.TransactionAmount
  from cte_trans sct
    left join sales.Customers sc on sc.CustomerID = sct.CustomerID
go

-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- --

TODO: напишите здесь свое решение

with SalesTotals as (
SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000)
SELECT 
	si.InvoiceID, 
	si.InvoiceDate,
	ap.FullName AS SalesPersonName,
	st.TotalSumm AS TotalSummByInvoice,
	(SELECT SUM(sol.PickedQuantity*sol.UnitPrice) FROM Sales.OrderLines sol where sol.OrderId = so.OrderId) AS TotalSummForPickedItems
FROM Sales.Invoices si
	JOIN SalesTotals st ON si.InvoiceID = st.InvoiceID
	left join Application.People ap on ap.PersonID = si.SalespersonPersonID
	left join Sales.Orders so on so.OrderId = si.OrderId  and so.PickingCompletedWhen IS NOT NULL
ORDER BY TotalSumm DESC
go

with SalesTotals as (
SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000)
SELECT 
	si.InvoiceID, 
	si.InvoiceDate,
	ap.FullName AS SalesPersonName,
	st.TotalSumm AS TotalSummByInvoice,
	SUM(sol.PickedQuantity*sol.UnitPrice) AS TotalSummForPickedItems
FROM Sales.Invoices si
	JOIN SalesTotals st ON si.InvoiceID = st.InvoiceID
	left join Application.People ap on ap.PersonID = si.SalespersonPersonID
	left join Sales.Orders so on so.OrderId = si.OrderId  and so.PickingCompletedWhen IS NOT NULL
	left join Sales.OrderLines sol on sol.OrderId = so.OrderId
group by si.InvoiceID,si.InvoiceDate,ap.FullName,st.TotalSumm
ORDER BY TotalSumm DESC
go