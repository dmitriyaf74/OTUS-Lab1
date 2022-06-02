/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "12 - Хранимые процедуры, функции, триггеры, курсоры".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

USE WideWorldImporters

/*
Во всех заданиях написать хранимую процедуру / функцию и продемонстрировать ее использование.
*/

/*
1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
*/

--напишите здесь свое решение
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE or ALTER FUNCTION dbo.ClientMaxBill()
RETURNS int
WITH EXECUTE AS OWNER
AS
BEGIN
	declare @CustomerId int;
	select top(1) @CustomerId = si.CustomerID--, sc.CustomerName
		--, si.InvoiceID
		--, sum(sil.quantity*sil.unitprice) TotalSum
	from Sales.Invoices si
		join Sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
		--left join Sales.Customers sc on sc.CustomerID = si.CustomerID
	group by si.CustomerID, si.InvoiceID--, sc.CustomerName
	order by sum(sil.quantity*sil.unitprice) desc


	RETURN @CustomerId

END
GO
SELECT [dbo].[ClientMaxBill] ()
GO

/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/

--напишите здесь свое решение
--Ver1
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE or Alter PROCEDURE TotalPyByCustomer 
	@CustomerId int,
	@TotalSum numeric(18,2) out
AS
BEGIN
	SET NOCOUNT ON;
	--Непонятно, для чего использовать Sales.Customers
	select @TotalSum = sum(sil.quantity*sil.unitprice)
		from Sales.Invoices si
			join Sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
		where si.CustomerID = @CustomerID
END
GO

DECLARE @CustomerId int
DECLARE @TotalSum numeric(18,2)

-- TODO: задайте здесь значения параметров.
set @CustomerId = [dbo].[ClientMaxBill] ()

EXECUTE [TotalPyByCustomer] 
   @CustomerId
  ,@TotalSum OUTPUT

select @TotalSum
GO

--Ver2
CREATE or Alter PROCEDURE TotalPyByCustomer2 
	@CustomerId int,
	@TotalSum numeric(18,2) out
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select si.InvoiceID,sum(sil.quantity*sil.unitprice)
		from Sales.Invoices si
			join Sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
		where si.CustomerID = @CustomerID
		group by si.InvoiceID
END
GO

DECLARE @CustomerId int
DECLARE @TotalSum numeric(18,2)

-- TODO: задайте здесь значения параметров.
set @CustomerId = [dbo].[ClientMaxBill] ()

EXECUTE [TotalPyByCustomer2] 
   @CustomerId
  ,@TotalSum OUTPUT
GO

/*
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/

--напишите здесь свое решение
CREATE or Alter PROCEDURE dbo.ClientMaxBill_proc
--	@CustomerID int OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	declare @CustomerId int;
	select top(1) @CustomerId = si.CustomerID--, sc.CustomerName
		--, si.InvoiceID
		--, sum(sil.quantity*sil.unitprice) TotalSum
	from Sales.Invoices si
		join Sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
		--left join Sales.Customers sc on sc.CustomerID = si.CustomerID
	group by si.CustomerID, si.InvoiceID--, sc.CustomerName
	order by sum(sil.quantity*sil.unitprice) desc
	RETURN @CustomerId
END
go

--Query 1
DECLARE @RC int
EXECUTE @RC = [dbo].[ClientMaxBill_proc] 
select @RC
GO
--Query 2
DECLARE @RC int
EXECUTE @RC = [dbo].[ClientMaxBill] 
select @RC
GO
--Query 3
SELECT [dbo].[ClientMaxBill] ()
GO
/*
Запросы 1 и 2 абсолютно идентичные
Запрос 3 срабатывает мгновенно, план не использует таблицы, предполагаю что этот запрос выдает ранее рассчитанное значение функции. Это так?
*/

/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла. 
*/

--напишите здесь свое решение
--Выбираем первые 2е записи заказа с наибольшей ценой
CREATE or ALTER FUNCTION [Sales].[OrderLinesFuncMaxPrice] (@OrderID int, @ItemCount int)  
RETURNS TABLE  
AS  
RETURN   
(  
    select  top (@ItemCount) so.[StockItemID],ws.[StockItemName], so.[Quantity],so.[Quantity]*so.[UnitPrice] Summa 
	  from [Sales].[OrderLines] so
	    left join [Warehouse].[StockItems] ws on ws.[StockItemID] = so.[StockItemID]
	  where so.[OrderID] = @OrderID
	  order by so.[UnitPrice] desc
);  
GO   

SELECT so.OrderID, so.OrderDate, sc.CustomerName, fso.StockItemID,fso.StockItemName, fso.Quantity,fso.Summa
	FROM [Sales].[Orders] so
		left join [Sales].[Customers] sc on sc.CustomerID = so.CustomerID
		cross apply [Sales].[OrderLinesFuncMaxPrice] (so.OrderID,2) fso
GO




/*
5) Опционально. Во всех процедурах укажите какой уровень изоляции транзакций вы бы использовали и почему. 
обычно я использую ReadCommited
для инкрементных псевдо-генераторов типа max+1 (не secuence) можно использовать DirtyRead, хотя от этого больше вреда
Snapshot хорош лишь на базе OLAP где нет изменений, причем должен инициироваться клиентом, на боевой БД много снимков съедят всю память
*/
