--Оригинальный запрос
Select ord.CustomerID, det.StockItemID, SUM(det.UnitPrice), SUM(det.Quantity), COUNT(ord.OrderID)
	FROM Sales.Orders AS ord
		JOIN Sales.OrderLines AS det ON det.OrderID = ord.OrderID
		JOIN Sales.Invoices AS Inv ON Inv.OrderID = ord.OrderID
		JOIN Sales.CustomerTransactions AS Trans ON Trans.InvoiceID = Inv.InvoiceID
		JOIN Warehouse.StockItemTransactions AS ItemTrans ON ItemTrans.StockItemID = det.StockItemID
	WHERE Inv.BillToCustomerID != ord.CustomerID
		AND (Select SupplierId
			FROM Warehouse.StockItems AS It
			Where It.StockItemID = det.StockItemID) = 12
		AND (SELECT SUM(Total.UnitPrice*Total.Quantity)
			FROM Sales.OrderLines AS Total
				Join Sales.Orders AS ordTotal On ordTotal.OrderID = Total.OrderID
			WHERE ordTotal.CustomerID = Inv.CustomerID) > 250000
				AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID
GO

/*
Время выполнения клиента	23:13:35		
Статистика по профилю запроса			
  Количество инструкций INSERT, DELETE и UPDATE	0		0.0000
  Строки, изменяемые инструкциями INSERT, DELETE и UPDATE	0		0.0000
  Количество инструкций SELECT 	2		2.0000
  Строк, возвращенных инструкциями SELECT	3620		3620.0000
  Количество транзакций 	0		0.0000
Сетевая статистика			
  Количество циклов обращения к серверу	2		2.0000
  TDS-пакетов отправлено клиентом	2		2.0000
  TDS-пакетов получено с сервера	24		24.0000
  байтов отправлено клиентом	1954		1954.0000
  байтов получено с сервера	90808		90808.0000
Статистика по времени			
  Время обработки клиента	8		8.0000
  Общее время выполнения	306		306.0000
  Время ожидания при ответе сервера	298		298.0000
*/

--Первый подселект лишний, переносим его в JOIN
--Второй подзапрос нужно сделать ведущим, например вынесем в CTE
--Результат - Запрос более удобочитаемый, но прироста скорости нет

--Inv.InvoiceDate и ord.OrderDate типа дата, достаточно просто их сравнить
--Что примечательно запрос ухудшился, а потому можно оставить старое загрубление, хотя преподаватели не рекомендуют

--Sales.CustomerTransactions и Warehouse.StockItemTransactions убирать из запроса нельзя, т.к. они накладывают дополнительные ограничения

with BigCustomers (BigCustomerID) as
(SELECT ordTotal.CustomerID
	FROM Sales.OrderLines AS Total
		Join Sales.Orders AS ordTotal On ordTotal.OrderID = Total.OrderID
	Group by ordTotal.CustomerID
	HAVING SUM(Total.UnitPrice*Total.Quantity) > 250000)

Select ord.CustomerID, det.StockItemID, SUM(det.UnitPrice), SUM(det.Quantity), COUNT(ord.OrderID)
	FROM Sales.Orders AS ord
		JOIN Sales.OrderLines AS det ON det.OrderID = ord.OrderID
		JOIN Sales.Invoices AS Inv ON Inv.OrderID = ord.OrderID
		--Первый подзапрос
		JOIN Warehouse.StockItems AS It on It.StockItemID = det.StockItemID
		--Второй подзапрос
		JOIN BigCustomers as bc on bc.BigCustomerID = Inv.CustomerID

		JOIN Sales.CustomerTransactions AS Trans ON Trans.InvoiceID = Inv.InvoiceID
		JOIN Warehouse.StockItemTransactions AS ItemTrans ON ItemTrans.StockItemID = det.StockItemID
	WHERE 1=1
		AND Inv.BillToCustomerID != ord.CustomerID
		AND It.SupplierId = 12
		AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID
GO
/*
Время выполнения клиента	23:14:10		
Статистика по профилю запроса			
  Количество инструкций INSERT, DELETE и UPDATE	0		0.0000
  Строки, изменяемые инструкциями INSERT, DELETE и UPDATE	0		0.0000
  Количество инструкций SELECT 	2		2.0000
  Строк, возвращенных инструкциями SELECT	3620		3620.0000
  Количество транзакций 	0		0.0000
Сетевая статистика			
  Количество циклов обращения к серверу	2		2.0000
  TDS-пакетов отправлено клиентом	2		2.0000
  TDS-пакетов получено с сервера	24		24.0000
  байтов отправлено клиентом	2254		2254.0000
  байтов получено с сервера	90808		90808.0000
Статистика по времени			
  Время обработки клиента	2		2.0000
  Общее время выполнения	511		511.0000
  Время ожидания при ответе сервера	509		509.0000
*/

--Любопытный факт, следующий запрос подтверждает что изменение порядка таблиц в запросе влияет на план и время выполнения
--В данном случае ухудшает его
with BigCustomers (BigCustomerID) as
(SELECT ordTotal.CustomerID
	FROM Sales.OrderLines AS Total
		Join Sales.Orders AS ordTotal On ordTotal.OrderID = Total.OrderID
	Group by ordTotal.CustomerID
	HAVING SUM(Total.UnitPrice*Total.Quantity) > 250000)

Select ord.CustomerID, det.StockItemID, SUM(det.UnitPrice), SUM(det.Quantity), COUNT(ord.OrderID)
	FROM BigCustomers as bc
		JOIN Sales.Invoices AS Inv on bc.BigCustomerID = Inv.CustomerID
		JOIN Sales.Orders AS ord ON Inv.OrderID = ord.OrderID
		JOIN Sales.OrderLines AS det ON det.OrderID = ord.OrderID
		--Первый подзапрос
		JOIN Warehouse.StockItems AS It on It.StockItemID = det.StockItemID

		JOIN Sales.CustomerTransactions AS Trans ON Trans.InvoiceID = Inv.InvoiceID
		JOIN Warehouse.StockItemTransactions AS ItemTrans ON ItemTrans.StockItemID = det.StockItemID
	WHERE 1=1
		AND Inv.BillToCustomerID != ord.CustomerID
		AND It.SupplierId = 12
		AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID
GO
/*
Время выполнения клиента	23:15:22		
Статистика по профилю запроса			
  Количество инструкций INSERT, DELETE и UPDATE	0		0.0000
  Строки, изменяемые инструкциями INSERT, DELETE и UPDATE	0		0.0000
  Количество инструкций SELECT 	2		2.0000
  Строк, возвращенных инструкциями SELECT	3620		3620.0000
  Количество транзакций 	0		0.0000
Сетевая статистика			
  Количество циклов обращения к серверу	2		2.0000
  TDS-пакетов отправлено клиентом	2		2.0000
  TDS-пакетов получено с сервера	24		24.0000
  байтов отправлено клиентом	2210		2210.0000
  байтов получено с сервера	90808		90808.0000
Статистика по времени			
  Время обработки клиента	10		10.0000
  Общее время выполнения	404		404.0000
  Время ожидания при ответе сервера	394		394.0000
*/
--сравнение запросов 1 и 2 - 50/50
--сравнение запросов 2 и 3 - 41/59

--Статистика запросов примерно одинаковая и изменяется при загрузке компьютера
