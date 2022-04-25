/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

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
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Загрузить эти данные в таблицу Warehouse.StockItems: 
существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName).

Сделать два варианта: с помощью OPENXML и через XQuery.
*/

--напишите здесь свое решение
--StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 


--OPENXML
drop table if exists #StockItems_Copy

declare @XmlDoc xml
select @XmlDoc = BulkColumn from openrowset (bulk 'C:\Install\MSSQL_course\Урок11\StockItems-188-1fb5df.xml', SINGLE_CLOB) as data
--select @XmlDoc
declare @docHandle int
exec sp_xml_preparedocument @docHandle OUTPUT,@XmlDoc
--select @docHandle

select StockItemName,SupplierID,UnitPackageID,OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 
into #StockItems_Copy
from OPENXML (@docHandle,N'/StockItems/Item')
with(
StockItemName nvarchar(100) '@Name'
,SupplierID int 'SupplierID'
,UnitPackageID int 'Package/UnitPackageID'
,OuterPackageID int 'Package/OuterPackageID'
,QuantityPerOuter int 'Package/QuantityPerOuter'
,TypicalWeightPerUnit decimal(18,3) 'Package/TypicalWeightPerUnit'
,LeadTimeDays int 'LeadTimeDays'
,IsChillerStock bit 'IsChillerStock'
,TaxRate decimal(18,3) 'TaxRate'
,UnitPrice decimal(18,2) 'UnitPrice'
)

--delete from Warehouse.StockItems where StockItemID >=230 

Merge Warehouse.StockItems as target
using (SELECT StockItemName,SupplierID,UnitPackageID,OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice
  FROM #StockItems_Copy) 
  as source (StockItemName,SupplierID,UnitPackageID,OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice) 
	  on (target.StockItemName = source.StockItemName)
	when matched 
		then update set SupplierID = source.SupplierID
		  ,UnitPackageID = source.UnitPackageID
		  ,OuterPackageID = source.OuterPackageID
		  ,QuantityPerOuter = source.QuantityPerOuter
		  ,TypicalWeightPerUnit = source.TypicalWeightPerUnit
		  ,LeadTimeDays = source.LeadTimeDays
		  ,IsChillerStock = source.IsChillerStock
		  ,TaxRate = source.TaxRate
		  ,UnitPrice = source.UnitPrice
	when not matched 
		then insert (StockItemName,SupplierID,UnitPackageID,OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice
		  ,LastEditedBy) 
	 values (source.StockItemName
      ,source.SupplierID
      ,source.UnitPackageID
      ,source.OuterPackageID
      ,source.QuantityPerOuter
      ,source.TypicalWeightPerUnit
      ,source.LeadTimeDays
      ,source.IsChillerStock
      ,source.TaxRate
      ,source.UnitPrice
	  ,1) 
;
exec sp_xml_removedocument @docHandle

select * from #StockItems_Copy --order by StockItemName
select * from Warehouse.StockItems --order by ValidFrom,StockItemName

drop table if exists #StockItems_Copy

--XQuery
drop table if exists #StockItems_Copy

declare @XmlDoc xml
select @XmlDoc = BulkColumn from openrowset (bulk 'C:\Install\MSSQL_course\Урок11\StockItems-188-1fb5df.xml', SINGLE_CLOB) as data


select n.Item.value('(@Name)[1]', 'nvarchar(100)' ) as StockItemName
, n.Item.value('(SupplierID)[1]', 'int' ) as SupplierID
, n.Item.value('(Package/UnitPackageID)[1]', 'int' ) as UnitPackageID
, n.Item.value('(Package/OuterPackageID)[1]', 'int' ) as OuterPackageID
, n.Item.value('(Package/QuantityPerOuter)[1]', 'int' ) as QuantityPerOuter
, n.Item.value('(Package/TypicalWeightPerUnit)[1]', 'decimal(18,3)' ) as TypicalWeightPerUnit
, n.Item.value('(LeadTimeDays)[1]', 'int' ) as LeadTimeDays
, n.Item.value('(IsChillerStock)[1]', 'bit' ) as IsChillerStock
, n.Item.value('(TaxRate)[1]', 'decimal(18,3)' ) as TaxRate
, n.Item.value('(UnitPrice)[1]', 'decimal(18,2)' ) as UnitPrice
into #StockItems_Copy
from @XmlDoc.nodes('/StockItems/Item') as n(Item)


--delete from Warehouse.StockItems where StockItemID >=230 

Merge Warehouse.StockItems as target
using (SELECT StockItemName,SupplierID,UnitPackageID,OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice
  FROM #StockItems_Copy) 
  as source (StockItemName,SupplierID,UnitPackageID,OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice) 
	  on (target.StockItemName = source.StockItemName)
	when matched 
		then update set SupplierID = source.SupplierID
		  ,UnitPackageID = source.UnitPackageID
		  ,OuterPackageID = source.OuterPackageID
		  ,QuantityPerOuter = source.QuantityPerOuter
		  ,TypicalWeightPerUnit = source.TypicalWeightPerUnit
		  ,LeadTimeDays = source.LeadTimeDays
		  ,IsChillerStock = source.IsChillerStock
		  ,TaxRate = source.TaxRate
		  ,UnitPrice = source.UnitPrice
	when not matched 
		then insert (StockItemName,SupplierID,UnitPackageID,OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice
		  ,LastEditedBy) 
	 values (source.StockItemName
      ,source.SupplierID
      ,source.UnitPackageID
      ,source.OuterPackageID
      ,source.QuantityPerOuter
      ,source.TypicalWeightPerUnit
      ,source.LeadTimeDays
      ,source.IsChillerStock
      ,source.TaxRate
      ,source.UnitPrice
	  ,1) 
;

select * from #StockItems_Copy --order by StockItemName
select * from Warehouse.StockItems --order by ValidFrom,StockItemName

drop table if exists #StockItems_Copy


/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/

--напишите здесь свое решение

drop table if exists ##Test
declare @a xml
set @a =  (select StockItemName as [@Name]
,SupplierID
,UnitPackageID as [Package/UnitPackageID]
,OuterPackageID as [Package/OuterPackageID]
, QuantityPerOuter as [Package/QuantityPerOuter]
, TypicalWeightPerUnit as [Package/TypicalWeightPerUnit]
, LeadTimeDays
, IsChillerStock
, TaxRate
, UnitPrice
from Warehouse.StockItems
for xml path('Item'), root('StockItems') )

declare @b nvarchar(max)
set @b = CONVERT(nvarchar(max), @a)
select @b as [xml_field] into ##Test

exec xp_cmdshell 'bcp "select xml_field from ##Test" queryout "C:\Install\MSSQL_course\StockItems.xml" -S "DON-HOME" -d "WideWorldImporters" /c /t, -T'

drop table if exists ##Test

/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/

--напишите здесь свое решение

--declare @J json
select ws.StockItemID, ws.StockItemName 
  ,json_value(ws.CustomFields, '$.CountryOfManufacture') 
  ,json_value(ws.CustomFields, '$.Tags[0]') 
  from Warehouse.StockItems ws
    

/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/


--напишите здесь свое решение
--var1
select ws.StockItemID, ws.StockItemName
  --,oj.[value]
  ,STRING_AGG(oj1.[key],',') AllTags
  from Warehouse.StockItems ws
    cross apply openjson(ws.CustomFields,'$.Tags') oj
    cross apply openjson(ws.CustomFields,'$') oj1
  where oj.[value] = 'Vintage'
  group by ws.StockItemID, ws.StockItemName, oj.[value]

--var2
select ws.StockItemID, ws.StockItemName
  --,oj.[value]
  ,STRING_AGG(oj1.[key],',') AllTags
  --,oj0.*
  from Warehouse.StockItems ws
    cross apply openjson(ws.CustomFields,'$') oj0
    cross apply openjson(iif(oj0.[type] <> 4, ws.CustomFields, oj0.[value]),'$') oj
    cross apply openjson(ws.CustomFields,'$') oj1
  where oj.[value] = 'Vintage'
  group by ws.StockItemID, ws.StockItemName, oj.[value]

