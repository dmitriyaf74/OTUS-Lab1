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
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

TODO: напишите здесь свое решение

select year(si.InvoiceDate) YearInvoice
  , month(si.InvoiceDate) MonthInvoice
  , avg(sil.UnitPrice) AvgExtendedPrice
  , sum(sil.ExtendedPrice) SumExtendedPrice
  from Sales.Invoices si
    left join Sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
  group by year(si.InvoiceDate),month(si.InvoiceDate)
  order by YearInvoice,MonthInvoice

/*
2. Отобразить все месяцы, где общая сумма продаж превысила 10 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

TODO: напишите здесь свое решение

select year(si.InvoiceDate) YearInvoice
  , month(si.InvoiceDate) MonthInvoice
  , sum(sil.ExtendedPrice) SumExtendedPrice
  from Sales.Invoices si
    left join Sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
  group by year(si.InvoiceDate),month(si.InvoiceDate)
  having sum(sil.ExtendedPrice) > 10000
  order by YearInvoice,MonthInvoice

/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

TODO: напишите здесь свое решение

select year(si.InvoiceDate) YearInvoice
  , month(si.InvoiceDate) MonthInvoice
  , ws.StockItemName
  , sum(sil.ExtendedPrice) SumExtendedPrice
  , min(si.InvoiceDate) MinInvoiceDate
  , sum(sil.Quantity) SumQuantity
  from Sales.Invoices si
    left join Sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
	left join Warehouse.StockItems ws on ws.StockItemID = sil.StockItemID
  group by year(si.InvoiceDate),month(si.InvoiceDate),ws.StockItemName
  having sum(sil.Quantity) < 50
  order by YearInvoice,MonthInvoice


-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 2-3 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/

--2---------------------------------------------------------

declare @MinInvoiceDate datetime2(7);
declare @MaxInvoiceDate datetime2(7);
select @MinInvoiceDate=min(si.InvoiceDate) from Sales.Invoices si;
select @MaxInvoiceDate=max(si.InvoiceDate) from Sales.Invoices si;
WITH Dates AS
	(
		SELECT DATEADD(month,-1,DATEADD(day,1,eomonth(@MinInvoiceDate))) AS DateStart -- Задаем якорь рекурсии
		UNION ALL
		SELECT DATEADD(month, 1, DateStart) AS DateStart -- Увеличиваем значение даты на 1 месяц
		FROM Dates
		WHERE DateStart < @MaxInvoiceDate -- Прекращаем выполнение, когда дойдем до даты окончания
	)
, Invoices2 AS
(select 
   year(si.InvoiceDate) YearInvoice
  , month(si.InvoiceDate) MonthInvoice
  , sum(sil.ExtendedPrice) SumExtendedPrice
  , DATEADD(month,-1,DATEADD(day,1,eomonth(si.InvoiceDate))) AS DateStart
  from Sales.Invoices si
    left join Sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
  group by year(si.InvoiceDate),month(si.InvoiceDate),DATEADD(month,-1,DATEADD(day,1,eomonth(si.InvoiceDate)))
  having sum(sil.ExtendedPrice) > 10000--5000000
  )
select year(d.DateStart) YearInvoice
  , month(d.DateStart) MonthInvoice
  , i.SumExtendedPrice
from Dates d
  left join Invoices2 i on i.DateStart = d.DateStart
order by YearInvoice,MonthInvoice
go
--3--------------------------------------------------------------------------

declare @MinInvoiceDate datetime2(7);
declare @MaxInvoiceDate datetime2(7);
select @MinInvoiceDate=min(si.InvoiceDate) from Sales.Invoices si;
select @MaxInvoiceDate=max(si.InvoiceDate) from Sales.Invoices si;
WITH Dates AS
	(
		SELECT DATEADD(month,-1,DATEADD(day,1,eomonth(@MinInvoiceDate))) AS DateStart -- Задаем якорь рекурсии
		UNION ALL
		SELECT DATEADD(month, 1, DateStart) AS DateStart -- Увеличиваем значение даты на 1 месяц
		FROM Dates
		WHERE DateStart < @MaxInvoiceDate -- Прекращаем выполнение, когда дойдем до даты окончания
	)
	
, Invoices2 AS
(select year(si.InvoiceDate) YearInvoice
  , month(si.InvoiceDate) MonthInvoice
  , ws.StockItemName
  , sum(sil.ExtendedPrice) SumExtendedPrice
  , min(si.InvoiceDate) MinInvoiceDate
  , sum(sil.Quantity) SumQuantity
  , DATEADD(month,-1,DATEADD(day,1,eomonth(si.InvoiceDate))) AS DateStart
  from Sales.Invoices si 
    left join Sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
	left join Warehouse.StockItems ws on ws.StockItemID = sil.StockItemID
  group by year(si.InvoiceDate),month(si.InvoiceDate),ws.StockItemName,DATEADD(month,-1,DATEADD(day,1,eomonth(si.InvoiceDate)))
  having sum(sil.Quantity) < 50
  ) 
select year(d.DateStart) YearInvoice
  , month(d.DateStart) MonthInvoice
  , i.StockItemName
  , i.SumExtendedPrice
  , i.MinInvoiceDate
  , i.SumQuantity
from Dates d
  left join Invoices2 i on i.DateStart = d.DateStart
order by YearInvoice,MonthInvoice
go
