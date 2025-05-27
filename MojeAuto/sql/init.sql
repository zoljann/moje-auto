USE master;
GO

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'MojeAutoDb')
BEGIN
    CREATE DATABASE MojeAutoDb;
END
GO

USE MojeAutoDb;
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Categories' AND xtype='U')
BEGIN
    CREATE TABLE Categories (
        Id INT PRIMARY KEY IDENTITY,
        Name NVARCHAR(100) NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM Categories WHERE Name = 'Motor')
BEGIN
    INSERT INTO Categories (Name) VALUES ('Motor'), ('Kočioni sistem'), ('Ovjes');
END
GO
