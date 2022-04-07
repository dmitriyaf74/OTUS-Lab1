/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

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
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/
/*
Gasport, NY
Jessie, ND
Medicine Lodge, KS
Peeples Valley, AZ
Sylvanite, MT
*/  

--напишите здесь свое решение 
with SalesData as
(
select distinct DATEADD(month,-1,DATEADD(day,1,eomonth(si.InvoiceDate))) AS DateStart
	, substring(sc.CustomerName, p1+1, p2-p1-1) CustomerName
	, count(si.InvoiceID) over(partition by eomonth(si.InvoiceDate),si.CustomerID) SalesCount
  from Sales.Invoices si
    left join Sales.Customers sc on sc.CustomerID = si.CustomerID
	cross apply (select WorkString = sc.CustomerName + '  ') ca1
	cross apply (select p1 = charindex('(',WorkString)) ca2
	cross apply (select p2 = charindex(')',WorkString,p1+1)) ca3
  where si.CustomerID between 2 and 6
)
select FORMAT(DateStart, 'dd.MM.yyyy') InvoiceMonth
  ,isnull([Peeples Valley, AZ],0)	as [Peeples Valley, AZ]
  ,isnull([Medicine Lodge, KS],0)	as [Medicine Lodge, KS]
  ,isnull([Gasport, NY],0)			as [Gasport, NY]
  ,isnull([Sylvanite, MT],0)		as [Sylvanite, MT]
  ,isnull([Jessie, ND],0) as [Jessie, ND]

  from SalesData sd
  pivot (sum(SalesCount) for CustomerName in ([Gasport, NY],[Jessie, ND],[Medicine Lodge, KS],[Peeples Valley, AZ],[Sylvanite, MT])) as pvt
  order by FORMAT(DateStart, 'yyyyMMdd')
go

with SalesData0 as
(
select DATEADD(month,-1,DATEADD(day,1,eomonth(si.InvoiceDate))) AS DateStart
    , sc.CustomerName
	, count(si.InvoiceID) SalesCount
  from Sales.Invoices si
    left join Sales.Customers sc on sc.CustomerID = si.CustomerID
  where si.CustomerID between 2 and 6
  group by eomonth(si.InvoiceDate),sc.CustomerName
  --order by 1,2
)

select FORMAT(DateStart, 'dd.MM.yyyy') InvoiceMonth
  ,isnull([Peeples Valley, AZ],0)	as [Peeples Valley, AZ]
  ,isnull([Medicine Lodge, KS],0)	as [Medicine Lodge, KS]
  ,isnull([Gasport, NY],0)			as [Gasport, NY]
  ,isnull([Sylvanite, MT],0)		as [Sylvanite, MT]
  ,isnull([Jessie, ND],0) as [Jessie, ND]

  from (select DateStart,SalesCount 
	, substring(CustomerName, p1+1, p2-p1-1) CustomerName
	from SalesData0
	cross apply (select WorkString = CustomerName + '  ') ca1
	cross apply (select p1 = charindex('(',WorkString)) ca2
	cross apply (select p2 = charindex(')',WorkString,p1+1)) ca3) SalesData
  pivot (sum(SalesCount) for CustomerName in ([Gasport, NY],[Jessie, ND],[Medicine Lodge, KS],[Peeples Valley, AZ],[Sylvanite, MT])) as pvt
  order by FORMAT(DateStart, 'yyyyMMdd')
go


/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/

--напишите здесь свое решение
with CustData as
(
select sc.CustomerName, sc.DeliveryAddressLine1, sc.DeliveryAddressLine2, sc.PostalAddressLine1, sc.PostalAddressLine2
  from Sales.Customers sc
  where sc.CustomerName like '%Tailspin Toys%' 
)
select CustomerName,AddressLine
	from CustData
	unpivot(AddressLine for Name in (DeliveryAddressLine1, DeliveryAddressLine2, PostalAddressLine1, PostalAddressLine2)) as AddressLine


/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

--напишите здесь свое решение
select CountryId,CountryName,Code
from (select ac.CountryID, ac.CountryName, ac.IsoAlpha3Code, cast(ac.IsoNumericCode as nvarchar(3)) IsoNumericCode
		from Application.Countries ac) ac
	unpivot(Code for Name in (IsoAlpha3Code, IsoNumericCode)) as Code


/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

--напишите здесь свое решение
--Этот запрос 11%, т.е. более эффективный
select sd.* from (
select top(1) with ties si.CustomerID,sc.CustomerName,sil.StockItemID,/*ws.StockItemName,*/ws.UnitPrice,si.InvoiceDate
  from Sales.Invoices si
    join Sales.Customers sc on sc.CustomerID = si.CustomerID
    join Sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
	join Warehouse.StockItems ws on ws.StockItemID = sil.StockItemID
  order by iif(row_number() over(partition by si.CustomerID order by ws.UnitPrice desc)<=2,1,3)
) sd 
order by sd.CustomerID


--Этот запрос 89%
select sd.* from (
select si.CustomerID,sc.CustomerName, si.StockItemID,si.UnitPrice,si.InvoiceDate
	from Sales.Customers sc
	cross apply(
	select top(2) si.CustomerID,sil.StockItemID,ws.UnitPrice,si.InvoiceDate
		from Sales.Invoices si
			join Sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
			join Warehouse.StockItems ws on ws.StockItemID = sil.StockItemID
		where si.CustomerID = sc.CustomerID
		order by ws.UnitPrice desc) si
) sd 
order by sd.CustomerID