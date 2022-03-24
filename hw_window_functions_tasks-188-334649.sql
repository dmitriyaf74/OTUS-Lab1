/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

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
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/

--напишите здесь свое решение
with v_Invoices as(
select distinct si.InvoiceDate
  from Sales.Invoices si
  where si.InvoiceDate >= '20050101'
)
select vi.InvoiceDate
  ,(select sum(sil.Quantity * sil.UnitPrice)
    from Sales.Invoices si
    join sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
	where si.InvoiceDate between '20050101' and eomonth(vi.InvoiceDate))
  from v_Invoices vi
  order by 1
go

/*Время синтаксического анализа и компиляции SQL Server: 
 время ЦП = 24 мс, истекшее время = 24 мс.

(затронуто строк: 1069)
Таблица "Workfile". Сканирований 4286, логических операций чтения 252560, физических операций чтения 22998, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 229562, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "Worktable". Сканирований 1069, логических операций чтения 253242, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "Workfile". Сканирований 0, логических операций чтения 0, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "Worktable". Сканирований 0, логических операций чтения 0, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "Invoices". Сканирований 10, логических операций чтения 23394, физических операций чтения 3, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 10664, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "InvoiceLines". Сканирований 2138, логических операций чтения 0, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 161, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "InvoiceLines". Считано сегментов 1069, пропущено 0.

 Время работы SQL Server:
   Время ЦП = 123186 мс, затраченное время = 145969 мс.

Время выполнения: 2022-03-21T10:07:42.1727238+05:00*/

/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/

--напишите здесь свое решение
--set statistics time on;
--set statistics io on;
--set statistics time off;
--set statistics io off;
with v_Invoices as(
select si.InvoiceDate
  ,sum(sil.Quantity * sil.UnitPrice) qPrice
  from Sales.Invoices si
    join sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
  where si.InvoiceDate >= '20050101'
  group by si.InvoiceDate
)
select vi.InvoiceDate
  ,vi.qPrice
  ,sum(vi.qPrice) over(order by eomonth(vi.InvoiceDate), eomonth(vi.InvoiceDate) range BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW )
  from v_Invoices vi
  order by vi.InvoiceDate
go

/*Время синтаксического анализа и компиляции SQL Server: 
 время ЦП = 16 мс, истекшее время = 32 мс.

(затронуто строк: 1069)
Таблица "InvoiceLines". Сканирований 16, логических операций чтения 0, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 502, физических операций чтения LOB 3, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 778, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "InvoiceLines". Считано сегментов 1, пропущено 0.
Таблица "Worktable". Сканирований 0, логических операций чтения 0, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "Invoices". Сканирований 9, логических операций чтения 11994, физических операций чтения 3, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 10412, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.

 Время работы SQL Server:
   Время ЦП = 141 мс, затраченное время = 578 мс.

Время выполнения: 2022-03-21T10:13:58.5384158+05:00*/

/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/

--напишите здесь свое решение

with v_Invoices as(
select month(si.InvoiceDate) mDate
  ,sil.StockItemID
  ,(ROW_NUMBER() OVER (partition by month(si.InvoiceDate) ORDER BY sum(sil.Quantity) DESC))  rnum
  ,sum(sil.Quantity) Quantity
  from Sales.Invoices si
    join sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
  where si.InvoiceDate between '20160101' and '20161231' 
  group by month(si.InvoiceDate),sil.StockItemID
  --order by month(si.InvoiceDate),sum(sil.Quantity) desc
)
select vi.mDate,vi.StockItemID,ws.StockItemName,vi.Quantity
  from v_Invoices vi
    left join Warehouse.StockItems ws on ws.StockItemID = vi.StockItemID
  where rnum <=2
  order by vi.mDate,vi.Quantity desc
go

select top(1) with ties month(si.InvoiceDate) mDate
  ,sil.StockItemID,ws.StockItemName
  ,sum(sil.Quantity) Quantity
  from Sales.Invoices si
    join sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
    left join Warehouse.StockItems ws on ws.StockItemID = sil.StockItemID
  where si.InvoiceDate between '20160101' and '20161231' 
  group by month(si.InvoiceDate),sil.StockItemID,ws.StockItemName
  order by iif((ROW_NUMBER() OVER (partition by month(si.InvoiceDate) ORDER BY sum(sil.Quantity) DESC))<=2,1,3)
go

/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

--напишите здесь свое решение
select ws.StockItemID,ws.StockItemName,ws.Brand,ws.UnitPrice
  ,(ROW_NUMBER() OVER (partition by substring(ws.StockItemName,1,1) ORDER BY ws.StockItemName)) rownums
  ,(count(*) over()) countItems
  ,(count(*) over(partition by substring(ws.StockItemName,1,1))) countItemsalpha
  ,(lead(ws.StockItemID) over(ORDER BY ws.StockItemName)) nextid
  ,(lag(ws.StockItemID) over(ORDER BY ws.StockItemName)) previd
  ,(lag(ws.StockItemName,2,'"No items"') over(ORDER BY ws.StockItemName)) prev2name
  from Warehouse.StockItems ws
  order by ws.StockItemName
go

/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/

--напишите здесь свое решение
select top(1) with ties si.SalespersonPersonID,ap.FullName,si.CustomerID,sc.CustomerName,si.InvoiceDate
  ,sum(sil.Quantity * sil.UnitPrice) over(partition by sil.InvoiceID) TotalRub 
  --,ROW_NUMBER() OVER (partition by si.SalespersonPersonID ORDER BY si.InvoiceDate desc)
  from Sales.Invoices si
    left join Application.People ap on ap.PersonID = si.SalespersonPersonID
	left join Sales.Customers sc on sc.CustomerID = si.CustomerID
	left join Sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
  order by (ROW_NUMBER() OVER (partition by si.SalespersonPersonID ORDER BY si.InvoiceDate desc))
go

/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

--напишите здесь свое решение

select top(1) with ties si.CustomerID,sc.CustomerName,sil.StockItemID,ws.StockItemName,ws.UnitPrice,si.InvoiceDate
  from Sales.Invoices si
    join Sales.Customers sc on sc.CustomerID = si.CustomerID
    join Sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
	join Warehouse.StockItems ws on ws.StockItemID = sil.StockItemID
  order by iif(row_number() over(partition by si.CustomerID order by ws.UnitPrice desc)<=2,1,3)

--Опционально можете для каждого запроса без оконных функций сделать вариант запросов с оконными функциями и сравнить их производительность. 