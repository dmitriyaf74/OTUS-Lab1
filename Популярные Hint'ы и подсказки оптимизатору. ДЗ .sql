--������������ ������
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
����� ���������� �������	23:13:35		
���������� �� ������� �������			
  ���������� ���������� INSERT, DELETE � UPDATE	0		0.0000
  ������, ���������� ������������ INSERT, DELETE � UPDATE	0		0.0000
  ���������� ���������� SELECT 	2		2.0000
  �����, ������������ ������������ SELECT	3620		3620.0000
  ���������� ���������� 	0		0.0000
������� ����������			
  ���������� ������ ��������� � �������	2		2.0000
  TDS-������� ���������� ��������	2		2.0000
  TDS-������� �������� � �������	24		24.0000
  ������ ���������� ��������	1954		1954.0000
  ������ �������� � �������	90808		90808.0000
���������� �� �������			
  ����� ��������� �������	8		8.0000
  ����� ����� ����������	306		306.0000
  ����� �������� ��� ������ �������	298		298.0000
*/

--������ ��������� ������, ��������� ��� � JOIN
--������ ��������� ����� ������� �������, �������� ������� � CTE
--��������� - ������ ����� �������������, �� �������� �������� ���

--Inv.InvoiceDate � ord.OrderDate ���� ����, ���������� ������ �� ��������
--��� ������������� ������ ���������, � ������ ����� �������� ������ �����������, ���� ������������� �� �����������

--Sales.CustomerTransactions � Warehouse.StockItemTransactions ������� �� ������� ������, �.�. ��� ����������� �������������� �����������

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
		--������ ���������
		JOIN Warehouse.StockItems AS It on It.StockItemID = det.StockItemID
		--������ ���������
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
����� ���������� �������	23:14:10		
���������� �� ������� �������			
  ���������� ���������� INSERT, DELETE � UPDATE	0		0.0000
  ������, ���������� ������������ INSERT, DELETE � UPDATE	0		0.0000
  ���������� ���������� SELECT 	2		2.0000
  �����, ������������ ������������ SELECT	3620		3620.0000
  ���������� ���������� 	0		0.0000
������� ����������			
  ���������� ������ ��������� � �������	2		2.0000
  TDS-������� ���������� ��������	2		2.0000
  TDS-������� �������� � �������	24		24.0000
  ������ ���������� ��������	2254		2254.0000
  ������ �������� � �������	90808		90808.0000
���������� �� �������			
  ����� ��������� �������	2		2.0000
  ����� ����� ����������	511		511.0000
  ����� �������� ��� ������ �������	509		509.0000
*/

--���������� ����, ��������� ������ ������������ ��� ��������� ������� ������ � ������� ������ �� ���� � ����� ����������
--� ������ ������ �������� ���
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
		--������ ���������
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
����� ���������� �������	23:15:22		
���������� �� ������� �������			
  ���������� ���������� INSERT, DELETE � UPDATE	0		0.0000
  ������, ���������� ������������ INSERT, DELETE � UPDATE	0		0.0000
  ���������� ���������� SELECT 	2		2.0000
  �����, ������������ ������������ SELECT	3620		3620.0000
  ���������� ���������� 	0		0.0000
������� ����������			
  ���������� ������ ��������� � �������	2		2.0000
  TDS-������� ���������� ��������	2		2.0000
  TDS-������� �������� � �������	24		24.0000
  ������ ���������� ��������	2210		2210.0000
  ������ �������� � �������	90808		90808.0000
���������� �� �������			
  ����� ��������� �������	10		10.0000
  ����� ����� ����������	404		404.0000
  ����� �������� ��� ������ �������	394		394.0000
*/
--��������� �������� 1 � 2 - 50/50
--��������� �������� 2 � 3 - 41/59

--���������� �������� �������� ���������� � ���������� ��� �������� ����������
