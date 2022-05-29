/*ТЗ
Требуется создать БД для обмена данными между КИС и КПК
Агент получает Список клиентов и их торговых точек согласно маршруту
В БД выгружает готовые заказы, с указанием дня доставки, количества товара. 
Цена фиксируется*/

--DROP DATABASE KPK_DB; 
--GO

USE master; 
GO 
IF DB_ID (N'KPK_DB1') IS NOT NULL 
	DROP DATABASE KPK_DB1; 
GO 

CREATE DATABASE KPK_DB1;
GO
USE [KPK_DB1]
GO

/****** Object:  Table [dbo].[Клиенты]    Script Date: 29.05.2022 18:47:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
/*
drop table if exists [Клиенты]
drop table if exists [ТорговыеТочки]
drop table if exists [Агенты]
drop table if exists [Маршруты]
drop table if exists [Адреса]
drop table if exists [Номенклатура]
drop table if exists [Заказы]
drop table if exists [СпецификацияЗаказов]

drop sequence if exists [КлиентыKod];*/

CREATE SEQUENCE [КлиентыГен]
  START WITH 1
  INCREMENT BY 1;

CREATE TABLE [dbo].[Клиенты](
	[КодКлиента] [bigint] primary key CONSTRAINT [КодКлиента] DEFAULT (NEXT VALUE FOR [КлиентыГен]) ,
	[НаименованиеКлиента] [varchar](255) NOT NULL,
	[Пол] char(1) CHECK ([Пол] in ('М','Ж')))
GO

CREATE SEQUENCE [ТорговыеТочкиГен]
  START WITH 1
  INCREMENT BY 1;

CREATE TABLE [dbo].[ТорговыеТочки](
	[КодТорговойТочки] [bigint]  primary key CONSTRAINT [КодТорговойТочки] DEFAULT (NEXT VALUE FOR [ТорговыеТочкиГен]),
	[КодКлиента] [bigint] NOT NULL,
	[КодАдреса] [bigint] NOT NULL,
	[НаименованиеТорговойТочки] [varchar](255) NOT NULL)
GO

CREATE SEQUENCE [АгентыГен]
  START WITH 1
  INCREMENT BY 1;

CREATE TABLE [dbo].[Агенты](
	[КодАгента] [bigint] primary key CONSTRAINT [КодАгента] DEFAULT (NEXT VALUE FOR [АгентыГен]),
	[НаименованиеАгента] [varchar](255) NOT NULL,
	[ЭТП] varchar(3) CHECK ([ЭТП] in ('Да','Нет')))
GO

CREATE SEQUENCE [МаршрутыГен]
  START WITH 1
  INCREMENT BY 1;

CREATE TABLE [dbo].[Маршруты](
	[КодМаршрута] [bigint] primary key CONSTRAINT [КодМаршрута] DEFAULT (NEXT VALUE FOR [МаршрутыГен]),
	[КодАгента] [bigint] NOT NULL,
	[НаименованиеМаршрута] [varchar](25) NOT NULL)
GO

CREATE SEQUENCE [АдресаГен]
  START WITH 1
  INCREMENT BY 1;

CREATE TABLE [dbo].[Адреса](
	[КодАдреса] [bigint] primary key CONSTRAINT [КодАдреса] DEFAULT (NEXT VALUE FOR [АдресаГен]),
	[КодФиас] [varchar](25) NOT NULL,
	[АдресВСтроку] [varchar](255) NOT NULL)
GO

CREATE SEQUENCE [НоменклатураГен]
  START WITH 1
  INCREMENT BY 1;

CREATE TABLE [dbo].[Номенклатура](
	[КодТовара] [bigint] primary key CONSTRAINT [КодТовара] DEFAULT (NEXT VALUE FOR [НоменклатураГен]),
	[НаименованиеТовара] [varchar](255) NOT NULL,
	[ФотоТовараUrl] [varchar](1000) NOT NULL,
	[ЦенаТовара] [numeric](18,2) NOT NULL)
GO

CREATE SEQUENCE [ЗаказыГен]
  START WITH 1
  INCREMENT BY 1;

CREATE TABLE [dbo].[Заказы](
	[КодЗаказа] [bigint] primary key CONSTRAINT [КодЗаказа] DEFAULT (NEXT VALUE FOR [ЗаказыГен]),
	[НомерЗаказа] [bigint] NOT NULL,
	[ДатаЗаказа] [date] NOT NULL,
	[ДатаДоставки] [date],
	[КодКлиента] [bigint] NOT NULL,
	[КодТорговойТочки] [bigint] NOT NULL,
	[КодАгента] [bigint] NOT NULL)
GO

CREATE TABLE [dbo].[СпецификацияЗаказов](
	[КодЗаказа] [bigint] NOT NULL,
	[КодТовара] [bigint] NOT NULL,
	[Количество] [numeric](18,3) NOT NULL,
	[Цена] [numeric](18,2) NOT NULL)
GO

--Внешние ключи
ALTER TABLE [СпецификацияЗаказов]
   ADD CONSTRAINT FK_СпецификацияЗаказов_Заказы FOREIGN KEY ([КодЗаказа])
      REFERENCES [Заказы] ([КодЗаказа]);
GO
ALTER TABLE [СпецификацияЗаказов]
   ADD CONSTRAINT FK_СпецификацияЗаказов_Номенклатура FOREIGN KEY ([КодТовара])
      REFERENCES [Номенклатура] ([КодТовара]);
GO

ALTER TABLE [ТорговыеТочки]
   ADD CONSTRAINT FK_ТорговыеТочки_Клиенты FOREIGN KEY ([КодКлиента])
      REFERENCES [Клиенты] ([КодКлиента]);
GO
ALTER TABLE [ТорговыеТочки]
   ADD CONSTRAINT FK_ТорговыеТочки_Адреса FOREIGN KEY ([КодАдреса])
      REFERENCES [Адреса] ([КодАдреса]);
GO
ALTER TABLE [Маршруты]
   ADD CONSTRAINT FK_Маршруты_Агенты FOREIGN KEY ([КодАгента])
      REFERENCES [Агенты] ([КодАгента]);
GO

ALTER TABLE [Заказы]
   ADD CONSTRAINT FK_Заказы_Клиенты FOREIGN KEY ([КодКлиента])
      REFERENCES [Клиенты] ([КодКлиента]);
GO
ALTER TABLE [Заказы]
   ADD CONSTRAINT FK_Заказы_ТорговыеТочки FOREIGN KEY ([КодТорговойТочки])
      REFERENCES [ТорговыеТочки] ([КодТорговойТочки]);
GO
ALTER TABLE [Заказы]
   ADD CONSTRAINT FK_Заказы_Агенты FOREIGN KEY ([КодАгента])
      REFERENCES [Агенты] ([КодАгента]);
GO

--Индексы
CREATE UNIQUE INDEX [КлиентыНаименование] ON [Клиенты] ([НаименованиеКлиента]);
GO

CREATE INDEX [НоменклатураНаименование] ON [Номенклатура] ([НаименованиеТовара]);
GO


