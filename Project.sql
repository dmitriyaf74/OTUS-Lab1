USE [master]
GO

--select @@SERVERNAME

--declare @databasename varchar(20)
--set @databasename = 'KPK_DB'

drop database if exists KPK_DB_X

CREATE DATABASE [KPK_DB_X]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'KPK_DB1', FILENAME = N'C:\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\KPK_DB_X.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'KPK_DB1_log', FILENAME = N'C:\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\KPK_DB_X_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO

USE [KPK_DB_X]
GO


drop table if exists OrderSpecs
drop sequence if exists OrderSpecGen
drop table if exists Orders
drop sequence if exists OrderGen
drop table if exists Goods
drop sequence if exists GoodGen
drop table if exists AgentRoutes
drop sequence if exists AgentRouteGen
drop table if exists ClientStores
drop sequence if exists ClientStoreGen
drop table if exists Clients
drop sequence if exists ClientGen
drop table if exists ClientTypes
drop sequence if exists ClientTypeGen
drop table if exists Genders
drop sequence if exists GenderGen
drop table if exists Addresses
drop sequence if exists AddressGen

CREATE TABLE ClientTypes(
	ClientTypeID bigint NOT NULL,
	ClientTypeName varchar(255) NOT NULL)

alter table ClientTypes add CONSTRAINT PK_ClientTypes primary key (ClientTypeID)
GO

CREATE TABLE Genders(
	GenderID bigint NOT NULL,
	GenderName varchar(255) NOT NULL)
alter table Genders ADD CONSTRAINT PK_Genders primary key (GenderID)
GO

CREATE TABLE Addresses(
	AddressID bigint NOT NULL,
	Fias varchar(25) NULL,
	AddressStr varchar(255) NOT NULL)
alter table Addresses add CONSTRAINT PK_Addresses primary key (AddressID)
create sequence AddressGen
ALTER TABLE Addresses ADD  CONSTRAINT AddressID  DEFAULT (NEXT VALUE FOR AddressGen) FOR AddressID
CREATE UNIQUE NONCLUSTERED INDEX UNC_AddressStr ON Addresses (AddressStr ASC)
GO

CREATE TABLE Clients(
	ClientID bigint NOT NULL,
	ClientName varchar(255) NOT NULL,
	GenderID bigint NULL,
	ClientTypeId  bigint NOT NULL)
alter table Clients add CONSTRAINT PK_Clients primary key (ClientID)
create sequence ClientGen
ALTER TABLE Clients ADD  CONSTRAINT ClientID  DEFAULT (NEXT VALUE FOR ClientGen) FOR ClientID

ALTER TABLE Clients WITH CHECK ADD  CONSTRAINT FK_Clients_Genders FOREIGN KEY(GenderId) REFERENCES Genders (GenderId)
ALTER TABLE ClientTypes WITH CHECK ADD  CONSTRAINT FK_ClientTypes_Genders FOREIGN KEY(ClientTypeId) REFERENCES ClientTypes (ClientTypeId)
GO

CREATE TABLE ClientStores(
	ClientStoreId bigint NOT NULL,
	ClientID bigint NOT NULL,
	AddressID bigint NOT NULL,
	ClientStoreName varchar(255) NOT NULL)
alter table ClientStores add CONSTRAINT PK_ClientStores primary key (ClientStoreId)
create sequence ClientStoreGen
ALTER TABLE ClientStores ADD  CONSTRAINT ClientStoreId  DEFAULT (NEXT VALUE FOR ClientStoreGen) FOR ClientStoreId

ALTER TABLE ClientStores  WITH CHECK ADD  CONSTRAINT FK_ClientStores_Addresses FOREIGN KEY(AddressId) REFERENCES Addresses (AddressId)
ALTER TABLE ClientStores CHECK CONSTRAINT FK_ClientStores_Addresses
ALTER TABLE ClientStores  WITH CHECK ADD  CONSTRAINT FK_ClientStores_Clients FOREIGN KEY(ClientId) REFERENCES Clients (ClientId)
ALTER TABLE ClientStores CHECK CONSTRAINT FK_ClientStores_Clients
GO

CREATE TABLE AgentRoutes(
	AgentRouteId bigint NOT NULL,
	AgentId bigint NOT NULL,
	AgentRouteName varchar(25) NOT NULL)
alter table AgentRoutes add CONSTRAINT PK_AgentRoutes primary key (AgentRouteId)
create sequence AgentRouteGen
ALTER TABLE AgentRoutes ADD  CONSTRAINT AgentRouteId  DEFAULT (NEXT VALUE FOR AgentRouteGen) FOR AgentRouteId

ALTER TABLE AgentRoutes  WITH CHECK ADD  CONSTRAINT FK_AgentRoutes_Clients FOREIGN KEY(AgentRouteId) REFERENCES Clients (ClientId)
ALTER TABLE AgentRoutes CHECK CONSTRAINT FK_AgentRoutes_Clients
GO


CREATE TABLE Goods(
	GoodId bigint NOT NULL,
	GoodName varchar(255) NOT NULL,
	PhotoUrl varchar(1000) NOT NULL,
	Price numeric(18, 2) NOT NULL)
alter table Goods add CONSTRAINT PK_Goods primary key (GoodId)
create sequence GoodGen
ALTER TABLE Goods ADD  CONSTRAINT GoodId  DEFAULT (NEXT VALUE FOR GoodGen) FOR GoodId
GO

CREATE TABLE Orders(
	OrderId bigint NOT NULL,
	OrderNo bigint NOT NULL,
	OrderDate date NOT NULL,
	OrderDeliveryDatePlan date NULL,
	CustomerID bigint NOT NULL,
	CustomerStoreId bigint NOT NULL,
	AgentId bigint NOT NULL)
alter table Orders add CONSTRAINT PK_Orders primary key (OrderId)
create sequence OrderGen as bigint START WITH 1 INCREMENT BY 1
ALTER TABLE Orders ADD  CONSTRAINT OrderId  DEFAULT (NEXT VALUE FOR OrderGen) FOR OrderId
ALTER TABLE Orders  WITH CHECK ADD  CONSTRAINT FK_Orders_ClientsAgent FOREIGN KEY(AgentId) REFERENCES Clients (ClientId)
ALTER TABLE Orders CHECK CONSTRAINT FK_Orders_ClientsAgent
ALTER TABLE Orders  WITH CHECK ADD  CONSTRAINT FK_Orders_ClientsCust FOREIGN KEY(CustomerID) REFERENCES Clients (ClientId)
ALTER TABLE Orders CHECK CONSTRAINT FK_Orders_ClientsCust
ALTER TABLE Orders  WITH CHECK ADD  CONSTRAINT FK_Orders_ClientStores FOREIGN KEY(CustomerStoreId) REFERENCES ClientStores (ClientStoreId)
ALTER TABLE Orders CHECK CONSTRAINT FK_Orders_ClientStores
GO

CREATE TABLE OrderSpecs(
	OrderSpecId bigint NOT NULL,
	OrderId bigint NOT NULL,
	GoodId bigint NOT NULL,
	Quantity numeric(18, 3) NOT NULL,
	Price numeric(18, 2) NOT NULL)
alter table OrderSpecs add CONSTRAINT PK_OrderSpecs primary key (OrderSpecId)
create sequence OrderSpecGen as bigint START WITH 1 INCREMENT BY 1
ALTER TABLE OrderSpecs ADD  CONSTRAINT OrderSpecId  DEFAULT (NEXT VALUE FOR OrderSpecGen) FOR OrderSpecId
ALTER TABLE OrderSpecs  WITH CHECK ADD  CONSTRAINT FK_OrderSpecs_Orders FOREIGN KEY(OrderId) REFERENCES Orders (OrderId)
ALTER TABLE OrderSpecs CHECK CONSTRAINT FK_OrderSpecs_Orders
ALTER TABLE OrderSpecs  WITH CHECK ADD  CONSTRAINT FK_OrderSpecs_Goods FOREIGN KEY(GoodId) REFERENCES Goods (GoodId)
ALTER TABLE OrderSpecs CHECK CONSTRAINT FK_OrderSpecs_Goods
GO

insert into ClientTypes (ClientTypeID,ClientTypeName) values(0,'Предприятие')
insert into ClientTypes (ClientTypeID,ClientTypeName) values(1,'Агент')
insert into ClientTypes (ClientTypeID,ClientTypeName) values(2,'Покупатель')
insert into ClientTypes (ClientTypeID,ClientTypeName) values(3,'Поставщик')

insert into Genders (GenderID,GenderName) values (0,'Unknown')
insert into Genders (GenderID,GenderName) values (1,'Male')
insert into Genders (GenderID,GenderName) values (2,'Female')

insert into Clients(ClientID,ClientName,GenderID,ClientTypeId) values (0,'Агент 0',0,0)
insert into Clients(ClientID,ClientName,GenderID,ClientTypeId) values (1,'Покупатель 1',0,0)
insert into Clients(ClientID,ClientName,GenderID,ClientTypeId) values (2,'Покупатель 2',0,1)
insert into Clients(ClientID,ClientName,GenderID,ClientTypeId) values (3,'Покупатель 3',0,1)
insert into Clients(ClientID,ClientName,GenderID,ClientTypeId) values (4,'Покупатель 4',0,1)
insert into Clients(ClientID,ClientName,GenderID,ClientTypeId) values (5,'Покупатель 5',0,1)
insert into Clients(ClientID,ClientName,GenderID,ClientTypeId) values (6,'Покупатель 6',1,2)
insert into Clients(ClientID,ClientName,GenderID,ClientTypeId) values (7,'Покупатель 7',1,2)
insert into Clients(ClientID,ClientName,GenderID,ClientTypeId) values (8,'Покупатель 8',2,2)
insert into Clients(ClientID,ClientName,GenderID,ClientTypeId) values (9,'Покупатель 9',1,2)
insert into Clients(ClientID,ClientName,GenderID,ClientTypeId) values (10,'Покупатель 10',1,2)
insert into Clients(ClientID,ClientName,GenderID,ClientTypeId) values (11,'Покупатель 11',2,2)


insert into Addresses(AddressID,AddressStr) values(1,'Уфа, Мира, 8')
insert into Addresses(AddressID,AddressStr) values(2,'Казань, Фронтовых бригад, 6')
insert into Addresses(AddressID,AddressStr) values(3,'Вятка, Луговая, 1')
insert into Addresses(AddressID,AddressStr) values(4,'Москва, Ленинградский проспект, 33')
insert into Addresses(AddressID,AddressStr) values(5,'Челябинск, Ульяновых, 45')
insert into Addresses(AddressID,AddressStr) values(6,'Уфа, Мира, 18')
insert into Addresses(AddressID,AddressStr) values(7,'Казань, Фронтовых бригад, 16')
insert into Addresses(AddressID,AddressStr) values(8,'Вятка, Луговая, 11')
insert into Addresses(AddressID,AddressStr) values(9,'Москва, Ленинградский проспект, 133')
insert into Addresses(AddressID,AddressStr) values(10,'Челябинск, Ульяновых, 145')
insert into Addresses(AddressID,AddressStr) values(11,'Челябинск, Ульяновых, 245')


insert into ClientStores(ClientStoreId,ClientID,AddressID,ClientStoreName) 
	select ad.AddressID,ad.AddressID,ad.AddressId,ad.AddressStr from Addresses ad


DECLARE @counter SMALLINT;  
SET @counter = 1;  
WHILE @counter < 1000  
   BEGIN  
	  insert into Goods(GoodId,GoodName,PhotoUrl,Price) values (@counter,'Товар ' + str(@counter),'',rand()*1000)
      SET @counter = @counter + 1  
   END; 

--select * from Goods

DECLARE @counter1 SMALLINT;  
DECLARE @counter2 SMALLINT;  
DECLARE @OrderDate1 date;  
SET @counter1 = 1;  
WHILE @counter1 < 8000  
   BEGIN  
      --set @OrderDate1 = DATEADD(day,round(rand()*6000,0),'2000-01-01')
      set @OrderDate1 = DATEADD(day,@counter1,'2000-01-01')
	  insert into Orders(OrderId,OrderNo,OrderDate,OrderDeliveryDatePlan,CustomerID,CustomerStoreId,AgentId)
	    values(@counter1,@counter1,@OrderDate1,DATEADD(day,1,@OrderDate1),round(rand()*10+1,0),round(rand()*10+1,0),0)

	  SET @counter2 = round(rand()*10,0) 
	  WHILE @counter2 > 0
	  begin
		insert into OrderSpecs(OrderId,GoodId,Quantity,Price) 
			values (@counter1,round(rand()*10+1,0),round(rand()*100,0),round(rand()*100,2));
		set @counter2 = @counter2 - 1
	  end



      SET @counter1 = @counter1 + 1  
   END; 

select * from Orders --Specs

--select NEXT VALUE FOR OrderSpecGen



--Партиционирование Orders
--Перестраиваем таблицы(PK FK)
alter table OrderSpecs DROP CONSTRAINT FK_OrderSpecs_Orders
alter table Orders DROP CONSTRAINT PK_Orders
alter table Orders add CONSTRAINT PK_Orders primary key NONCLUSTERED (OrderId) 
ALTER TABLE OrderSpecs  WITH CHECK ADD  CONSTRAINT FK_OrderSpecs_Orders FOREIGN KEY(OrderId) REFERENCES Orders (OrderId)

--alter table OrderSpecs add CONSTRAINT PK_OrderSpecs primary key (OrderSpecId) 
--select distinct str(DATEPART(year,orderdate)) + '0101' from orders order by 1

alter database KPK_DB_X add FileGroup YearData 
alter database KPK_DB_X add File
(Name = N'YEARS',FileName=N'C:\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\KPK_DB_X_YearData.ndf',
size=100mb, FileGrowth=10mb) to FileGroup YearData 


create partition function fnYearPartityon(DATE) as range right for values
	('20100101','20150101','20200101','20210101','20220101','20230101')
create partition scheme schmYearPartition as partition fnYearPartityon all to (YearData)

CREATE CLUSTERED INDEX ClusteredIndex_on_schmYearPartition ON Orders
	(OrderDate) ON schmYearPartition(OrderDate)


--Наблюдается небольшой  прирост производительности, при условии что период находится в рамках одного раздела (54%/46%)
select * from Orders o where 1=1
and o.OrderDeliveryDatePlan = '20130422'
and o.OrderDate >= '20130102' and o.OrderDate < '20180102'

select * from Orders o where 1=1
and o.OrderDeliveryDatePlan = '20130422'
and o.OrderDate >= '20100101' and o.OrderDate < '20150101'


