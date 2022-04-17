/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

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
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/

--напишите здесь свое решение
insert into [WideWorldImporters].[Sales].[Customers]
	([CustomerName]
      ,[BillToCustomerID]
      ,[CustomerCategoryID]
      ,[BuyingGroupID]
      ,[PrimaryContactPersonID]
      ,[AlternateContactPersonID]
      ,[DeliveryMethodID]
      ,[DeliveryCityID]
      ,[PostalCityID]
      ,[CreditLimit]
      ,[AccountOpenedDate]
      ,[StandardDiscountPercentage]
      ,[IsStatementSent]
      ,[IsOnCreditHold]
      ,[PaymentDays]
      ,[PhoneNumber]
      ,[FaxNumber]
      ,[DeliveryRun]
      ,[RunPosition]
      ,[WebsiteURL]
      ,[DeliveryAddressLine1]
      ,[DeliveryAddressLine2]
      ,[DeliveryPostalCode]
      ,[DeliveryLocation]
      ,[PostalAddressLine1]
      ,[PostalAddressLine2]
      ,[PostalPostalCode]
      ,[LastEditedBy]) 
SELECT TOP (5) 'New_' + [CustomerName]
      ,[BillToCustomerID]
      ,[CustomerCategoryID]
      ,[BuyingGroupID]
      ,[PrimaryContactPersonID]
      ,[AlternateContactPersonID]
      ,[DeliveryMethodID]
      ,[DeliveryCityID]
      ,[PostalCityID]
      ,[CreditLimit]
      ,[AccountOpenedDate]
      ,[StandardDiscountPercentage]
      ,[IsStatementSent]
      ,[IsOnCreditHold]
      ,[PaymentDays]
      ,[PhoneNumber]
      ,[FaxNumber]
      ,[DeliveryRun]
      ,[RunPosition]
      ,[WebsiteURL]
      ,[DeliveryAddressLine1]
      ,[DeliveryAddressLine2]
      ,[DeliveryPostalCode]
      ,[DeliveryLocation]
      ,[PostalAddressLine1]
      ,[PostalAddressLine2]
      ,[PostalPostalCode]
      ,[LastEditedBy]

  FROM [WideWorldImporters].[Sales].[Customers]
  order by [CustomerId]


/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

--напишите здесь свое решение

with sc as
(select top(1) * from  [WideWorldImporters].[Sales].[Customers] order by [CustomerId] desc)
delete FROM sc

delete FROM [WideWorldImporters].[Sales].[Customers] where [CustomerId] = (select max([CustomerId]) FROM [WideWorldImporters].[Sales].[Customers])




/*
3. Изменить одну запись, из добавленных через UPDATE
*/

--напишите здесь свое решение
with sc as
(select top(1) * from  [WideWorldImporters].[Sales].[Customers] order by [CustomerId] desc)
update sc set [AccountOpenedDate] = CONVERT (date, CURRENT_TIMESTAMP)



/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

--напишите здесь свое решение

Merge [WideWorldImporters].[Sales].[Customers] as target
using (SELECT TOP (5) 'New_' + [CustomerName]
      ,[BillToCustomerID]
      ,[CustomerCategoryID]
      ,[BuyingGroupID]
      ,[PrimaryContactPersonID]
      ,[AlternateContactPersonID]
      ,[DeliveryMethodID]
      ,[DeliveryCityID]
      ,[PostalCityID]
      ,[CreditLimit]
      ,[AccountOpenedDate]
      ,[StandardDiscountPercentage]
      ,[IsStatementSent]
      ,[IsOnCreditHold]
      ,[PaymentDays]
      ,[PhoneNumber]
      ,[FaxNumber]
      ,[DeliveryRun]
      ,[RunPosition]
      ,[WebsiteURL]
      ,[DeliveryAddressLine1]
      ,[DeliveryAddressLine2]
      ,[DeliveryPostalCode]
      ,[DeliveryLocation]
      ,[PostalAddressLine1]
      ,[PostalAddressLine2]
      ,[PostalPostalCode]
      ,[LastEditedBy]

  FROM [WideWorldImporters].[Sales].[Customers]
  order by [CustomerId]) 
  as source ([CustomerName]
      ,[BillToCustomerID]
      ,[CustomerCategoryID]
      ,[BuyingGroupID]
      ,[PrimaryContactPersonID]
      ,[AlternateContactPersonID]
      ,[DeliveryMethodID]
      ,[DeliveryCityID]
      ,[PostalCityID]
      ,[CreditLimit]
      ,[AccountOpenedDate]
      ,[StandardDiscountPercentage]
      ,[IsStatementSent]
      ,[IsOnCreditHold]
      ,[PaymentDays]
      ,[PhoneNumber]
      ,[FaxNumber]
      ,[DeliveryRun]
      ,[RunPosition]
      ,[WebsiteURL]
      ,[DeliveryAddressLine1]
      ,[DeliveryAddressLine2]
      ,[DeliveryPostalCode]
      ,[DeliveryLocation]
      ,[PostalAddressLine1]
      ,[PostalAddressLine2]
      ,[PostalPostalCode]
      ,[LastEditedBy]) 
	  on (target.[CustomerName] = source.[CustomerName])
	when matched and target.[AccountOpenedDate] = source.[AccountOpenedDate] 
		then update set [AccountOpenedDate] = source.[AccountOpenedDate]
	when not matched 
		then insert ([CustomerName]
      ,[BillToCustomerID]
      ,[CustomerCategoryID]
      ,[BuyingGroupID]
      ,[PrimaryContactPersonID]
      ,[AlternateContactPersonID]
      ,[DeliveryMethodID]
      ,[DeliveryCityID]
      ,[PostalCityID]
      ,[CreditLimit]
      ,[AccountOpenedDate]
      ,[StandardDiscountPercentage]
      ,[IsStatementSent]
      ,[IsOnCreditHold]
      ,[PaymentDays]
      ,[PhoneNumber]
      ,[FaxNumber]
      ,[DeliveryRun]
      ,[RunPosition]
      ,[WebsiteURL]
      ,[DeliveryAddressLine1]
      ,[DeliveryAddressLine2]
      ,[DeliveryPostalCode]
      ,[DeliveryLocation]
      ,[PostalAddressLine1]
      ,[PostalAddressLine2]
      ,[PostalPostalCode]
      ,[LastEditedBy]) 
	 values (source.[CustomerName]
      ,source.[BillToCustomerID]
      ,source.[CustomerCategoryID]
      ,source.[BuyingGroupID]
      ,source.[PrimaryContactPersonID]
      ,source.[AlternateContactPersonID]
      ,source.[DeliveryMethodID]
      ,source.[DeliveryCityID]
      ,source.[PostalCityID]
      ,source.[CreditLimit]
      ,source.[AccountOpenedDate]
      ,source.[StandardDiscountPercentage]
      ,source.[IsStatementSent]
      ,source.[IsOnCreditHold]
      ,source.[PaymentDays]
      ,source.[PhoneNumber]
      ,source.[FaxNumber]
      ,source.[DeliveryRun]
      ,source.[RunPosition]
      ,source.[WebsiteURL]
      ,source.[DeliveryAddressLine1]
      ,source.[DeliveryAddressLine2]
      ,source.[DeliveryPostalCode]
      ,source.[DeliveryLocation]
      ,source.[PostalAddressLine1]
      ,source.[PostalAddressLine2]
      ,source.[PostalPostalCode]
      ,source.[LastEditedBy]) 
;


/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/

--напишите здесь свое решение

-- To allow advanced options to be changed.  
EXEC sp_configure 'show advanced options', 1;  
GO  
-- To update the currently configured value for advanced options.  
RECONFIGURE;  
GO  
-- To enable the feature.  
EXEC sp_configure 'xp_cmdshell', 1;  
GO  
-- To update the currently configured value for this feature.  
RECONFIGURE;  
GO  


declare @dml as nvarchar(max)
declare @SrvName as nvarchar(50)
declare @SrcTable as nvarchar(250)
declare @TmpFile as nvarchar(250)
declare @Sep as nvarchar(10)
set @Sep = ' @eu&$1& '
set @SrcTable = '[WideWorldImporters].[Sales].Customers'
set @TmpFile = 'C:\Install\MyTest.txt'
set @SrvName = @@SERVERNAME

set @dml = N'exec master..xp_cmdshell ''bcp "' + @SrcTable + '" out  "' + @TmpFile + '" -T -w -t"' + @Sep + '" -S ' + @SrvName + ''''
exec sp_executesql @dml

set @dml = N'drop table if exists ' + @SrcTable + '_Copy'
exec sp_executesql @dml

set @dml = N'select * into ' + @SrcTable + '_Copy from ' + @SrcTable + ' where 1=2' 
exec sp_executesql @dml

set @dml = N'BULK INSERT ' + @SrcTable + '_Copy
				   FROM "' + @TmpFile + '"
				   WITH 
					 (
						BATCHSIZE = 1000, 
						DATAFILETYPE = ''widechar'',
						FIELDTERMINATOR = ''' + @Sep + ''',
						ROWTERMINATOR =''\n'',
						KEEPNULLS,
						TABLOCK        
					  );'
exec sp_executesql @dml

set @dml = N'select * from ' + @SrcTable + '_Copy'
exec sp_executesql @dml

set @dml = N'truncate table ' + @SrcTable + '_Copy'
exec sp_executesql @dml

set @dml = N'select * from ' + @SrcTable + '_Copy'
exec sp_executesql @dml
go
