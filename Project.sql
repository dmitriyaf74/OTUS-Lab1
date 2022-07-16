USE [master]
GO

--select @@SERVERNAME

--declare @databasename varchar(20)
--set @databasename = 'KPK_DB'

drop database if exists kpkDBx

CREATE DATABASE [kpkDBx]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'KPK_DB1', FILENAME = N'C:\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\kpkDBx.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'KPK_DB1_log', FILENAME = N'C:\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\kpkDBx_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO

USE [kpkDBx]
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
	ClientTypeId  bigint NOT NULL,
	Debt numeric(18, 2))
alter table Clients add CONSTRAINT PK_Clients primary key (ClientID)
create sequence ClientGen
ALTER TABLE Clients ADD  CONSTRAINT ClientID  DEFAULT (NEXT VALUE FOR ClientGen) FOR ClientID

ALTER TABLE Clients WITH CHECK ADD  CONSTRAINT FK_Clients_Genders FOREIGN KEY(GenderId) REFERENCES Genders (GenderId)
ALTER TABLE Clients WITH CHECK ADD  CONSTRAINT FK_ClientTypes_Genders FOREIGN KEY(ClientTypeId) REFERENCES ClientTypes (ClientTypeId)
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
DECLARE @WD smallint;  
SET @counter1 = 1;  
WHILE @counter1 < 8000  
   BEGIN  
      --set @OrderDate1 = DATEADD(day,round(rand()*6000,0),'2000-01-01')
      set @OrderDate1 = DATEADD(day,@counter1,'2000-01-01')
	  set @WD = DATEPART(weekday,@OrderDate1)
	  if @WD > 5
	    set @OrderDate1 = DATEADD(day,-4,@OrderDate1)
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

alter database kpkDBx add FileGroup YearData 
alter database kpkDBx add File
(Name = N'YEARS',FileName=N'C:\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\kpkDBx_YearData.ndf',
size=100mb, FileGrowth=10mb) to FileGroup YearData 


create partition function fnYearPartityon(DATE) as range right for values
	('20100101','20150101','20200101','20210101','20220101','20230101')
create partition scheme schmYearPartition as partition fnYearPartityon all to (YearData)

CREATE CLUSTERED INDEX ClusteredIndex_on_schmYearPartition ON Orders
	(OrderDate) ON schmYearPartition(OrderDate)


/*--Наблюдается небольшой  прирост производительности, при условии что период находится в рамках одного раздела (54%/46%)
select * from Orders o where 1=1
and o.OrderDeliveryDatePlan = '20130422'
and o.OrderDate >= '20130102' and o.OrderDate < '20180102'

select * from Orders o where 1=1
and o.OrderDeliveryDatePlan = '20130422'
and o.OrderDate >= '20100101' and o.OrderDate < '20150101'*/

SELECT * INTO Clients_Source  FROM Clients

--Включение СервисБрокера

/*Описание!!!
При изменении данных о задолженности клиента в учетной БД - Table - Clients_Source
Создаем сообщение для БД-КПК и записываем ее в Clients
*/

USE [master]
ALTER DATABASE kpkDBx SET ENABLE_BROKER; 
ALTER DATABASE kpkDBx SET TRUSTWORTHY ON;
ALTER AUTHORIZATION ON DATABASE::kpkDBx TO [sa];


USE [kpkDBx]
--Создание запросов
-- For Request
CREATE MESSAGE TYPE
[//KDX/Debt/RequestMessage]
VALIDATION=WELL_FORMED_XML;
-- For Reply
CREATE MESSAGE TYPE
[//KDX/Debt/ReplyMessage]
VALIDATION=WELL_FORMED_XML; 

CREATE CONTRACT [//KDX/Debt/Contract]
      ([//KDX/Debt/RequestMessage]
         SENT BY INITIATOR,
       [//KDX/Debt/ReplyMessage]
         SENT BY TARGET
      );
go
--СОздание очередей
CREATE QUEUE TargetQueueKDX;
CREATE SERVICE [//KDX/Debt/TargetService]
       ON QUEUE TargetQueueKDX
       ([//KDX/Debt/Contract]);
GO
CREATE QUEUE InitiatorQueueKDX;
CREATE SERVICE [//KDX/Debt/InitiatorService]
       ON QUEUE InitiatorQueueKDX
       ([//KDX/Debt/Contract]);
GO
--Отправка сообщения
CREATE or ALTER PROCEDURE DebtInfoSend
	@ClientID INT
AS
BEGIN
	SET NOCOUNT ON;
    --Sending a Request Message to the Target	
	DECLARE @InitDlgHandle UNIQUEIDENTIFIER;
	DECLARE @RequestMessage NVARCHAR(4000);
	BEGIN TRAN 
	--Prepare the Message
	SELECT @RequestMessage = (SELECT ClientID,Debt
							  FROM Clients_Source AS Clients
							  WHERE ClientID = @ClientID
							  FOR XML AUTO, root('RequestMessage')); 
	
	--Determine the Initiator Service, Target Service and the Contract 
	BEGIN DIALOG @InitDlgHandle
	FROM SERVICE
	[//KDX/Debt/InitiatorService]
	TO SERVICE
	'//KDX/Debt/TargetService'
	ON CONTRACT
	[//KDX/Debt/Contract]
	WITH ENCRYPTION=OFF; 

	--Send the Message
	SEND ON CONVERSATION @InitDlgHandle 
	MESSAGE TYPE
	[//KDX/Debt/RequestMessage]
	(@RequestMessage);
	--SELECT @RequestMessage AS SentRequestMessage;
	COMMIT TRAN 
END
GO

--SELECT ClientID,Debt FROM Clients_Source AS Clients WHERE ClientID = 1 FOR XML AUTO, root('RequestMessage')

CREATE or ALTER PROCEDURE DebtInfoUpply
AS
BEGIN

	DECLARE @TargetDlgHandle UNIQUEIDENTIFIER,
			@Message NVARCHAR(4000),
			@MessageType Sysname,
			@ReplyMessage NVARCHAR(4000),
			@ReplyMessageName Sysname,
			@ClientID BIGINT,
			@Debt Numeric(18,3),
			@xml XML; 
	
	BEGIN TRAN; 

	--Receive message from Initiator
	RECEIVE TOP(1)
		@TargetDlgHandle = Conversation_Handle,
		@Message = Message_Body,
		@MessageType = Message_Type_Name
	FROM dbo.TargetQueueKDX; 

	SELECT @Message;

	SET @xml = CAST(@Message AS XML);

	SELECT @ClientID = R.Clients.value('@ClientID','BIGINT'),
		@Debt = R.Clients.value('@Debt','Numeric(18,2)')
	FROM @xml.nodes('/RequestMessage/Clients') as R(Clients);

	IF EXISTS (SELECT * FROM Clients WHERE ClientID = @ClientID)
	BEGIN
		UPDATE Clients
		SET Debt = @Debt
		WHERE ClientID = @ClientID;
	END;
	
	SELECT @Message AS ReceivedRequestMessage, @MessageType; 
	
	-- Confirm and Send a reply
	IF @MessageType=N'//KDX/Debt/RequestMessage'
	BEGIN
		SET @ReplyMessage =N'<ReplyMessage> Message received</ReplyMessage>'; 
	
		SEND ON CONVERSATION @TargetDlgHandle
		MESSAGE TYPE
		[//KDX/Debt/ReplyMessage]
		(@ReplyMessage);
		END CONVERSATION @TargetDlgHandle;
	END 
	
	SELECT @ReplyMessage AS SentReplyMessage; 

	COMMIT TRAN;
END
go

CREATE or ALTER PROCEDURE DebtInfoConfirm
AS
BEGIN
	--Receiving Reply Message from the Target.	
	DECLARE @InitiatorReplyDlgHandle UNIQUEIDENTIFIER,
			@ReplyReceivedMessage NVARCHAR(1000) 
	
	BEGIN TRAN; 

		RECEIVE TOP(1)
			@InitiatorReplyDlgHandle=Conversation_Handle
			,@ReplyReceivedMessage=Message_Body
		FROM dbo.InitiatorQueueKDX; 
		
		END CONVERSATION @InitiatorReplyDlgHandle; 
		
		SELECT @ReplyReceivedMessage AS ReceivedRepliedMessage; 

	COMMIT TRAN; 
END
go

ALTER QUEUE [dbo].[InitiatorQueueKDX] WITH STATUS = ON , RETENTION = OFF , POISON_MESSAGE_HANDLING (STATUS = OFF) 
	, ACTIVATION (   STATUS = ON ,
        PROCEDURE_NAME = DebtInfoConfirm, MAX_QUEUE_READERS = 1, EXECUTE AS OWNER) ; 

GO
ALTER QUEUE [dbo].[TargetQueueKDX] WITH STATUS = ON , RETENTION = OFF , POISON_MESSAGE_HANDLING (STATUS = OFF)
	, ACTIVATION (  STATUS = ON ,
        PROCEDURE_NAME = DebtInfoUpply, MAX_QUEUE_READERS = 1, EXECUTE AS OWNER) ; 

GO

CREATE TRIGGER Clients_Source_DebtChanche
   ON  Clients_Source
   AFTER UPDATE
AS 
declare @ClientId bigint;
BEGIN
  IF (COLUMNS_UPDATED()) > 0  
  begin
	SELECT @ClientId = ClientId FROM inserted ins;
    exec DebtInfoSend @ClientId;
  end	
END
GO

update Clients_Source set Debt = coalesce(Debt,0) + 1 where ClientID = 1;
select * from Clients_Source where ClientID = 1;
select * from Clients --where ClientID = 1;
go


