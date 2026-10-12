-- run_order.sql
-- Purpose: execution order of the DW load (cleanup -> load).
-- Requires: SQLCMD Mode (SSMS: Query > SQLCMD Mode) or the sqlcmd utility.
-- Set EtlPath to the folder that contains the ETL_*.sql files.

:on error exit
:setvar EtlPath "C:\path\to\repo\ETL"

USE DataWarehouse
GO

-- 1. CLEANUP (child -> parent)
-- Facts reference dimensions through foreign keys, so facts are deleted first.
-- DELETE is used instead of TRUNCATE because TRUNCATE fails on tables
-- referenced by a foreign key.
-- DIM.Date is not cleaned here: no foreign key references it,
-- and its ETL script truncates it itself.
SET XACT_ABORT ON
BEGIN TRAN
    DELETE FROM FCT.SALES;

    DELETE FROM DIM.CLIENT;
    DELETE FROM DIM.CLIENT_SOURCE;
    DELETE FROM DIM.DEPARTMENT;
    DELETE FROM DIM.EMPLOYEE;
    DELETE FROM DIM.ITEM;
COMMIT;
GO

-- Reset IDENTITY counters.
-- Separate batch on purpose: with :on error exit it runs only if every
-- DELETE above succeeded.
DBCC CHECKIDENT ('FCT.SALES', RESEED, 0);
DBCC CHECKIDENT ('DIM.CLIENT', RESEED, 0);
DBCC CHECKIDENT ('DIM.CLIENT_SOURCE', RESEED, 0);
DBCC CHECKIDENT ('DIM.DEPARTMENT', RESEED, 0);
DBCC CHECKIDENT ('DIM.EMPLOYEE', RESEED, 0);
DBCC CHECKIDENT ('DIM.ITEM', RESEED, 0);
GO

-- 2. LOAD (parent -> child)
-- One GO after each file: every ETL script runs as its own batch,
-- so an error stops the run at the failing file.
-- CLIENT_SOURCE must load before CLIENT (the CLIENT ETL joins to it).
:r $(EtlPath)\ETL_DIM.Date.sql
GO
:r $(EtlPath)\ETL_DIM.CLIENT_SOURCE.sql
GO
:r $(EtlPath)\ETL_DIM.CLIENT.sql
GO
:r $(EtlPath)\ETL_DIM.DEPARTMENT.sql
GO
:r $(EtlPath)\ETL_DIM.EMPLOYEE.sql
GO
:r $(EtlPath)\ETL_DIM.ITEM.sql
GO
:r $(EtlPath)\ETL_FCT.SALES.sql
GO

-- 3. SANITY CHECK
-- Row counts per table; a table with 0 rows means its ETL did not load.
SELECT 'DIM.Date' AS tbl, COUNT(*) AS cnt FROM DIM.Date
UNION ALL SELECT 'DIM.CLIENT_SOURCE', COUNT(*) FROM DIM.CLIENT_SOURCE
UNION ALL SELECT 'DIM.CLIENT', COUNT(*) FROM DIM.CLIENT
UNION ALL SELECT 'DIM.DEPARTMENT', COUNT(*) FROM DIM.DEPARTMENT
UNION ALL SELECT 'DIM.EMPLOYEE', COUNT(*) FROM DIM.EMPLOYEE
UNION ALL SELECT 'DIM.ITEM', COUNT(*) FROM DIM.ITEM
UNION ALL SELECT 'FCT.SALES', COUNT(*) FROM FCT.SALES;
GO


