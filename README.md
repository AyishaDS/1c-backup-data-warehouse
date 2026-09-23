# 1c-backup-data-warehouse
Building a star-schema data warehouse from a 1C ERP backup with no accessible metadata — reverse engineering, dimensional modeling, and ETL design.

## Problem
A company that uses only the 1C program for customer records and 
accounting wants to analyze its customer data. However, there is no 
in-house developer, and no changes can be made to the live system.

## Challenge
The chosen method was to restore an IT-provided backup file into a 
separate SQL Server environment. But when a 1C backup opens in a 
different environment, metadata relationships are lost — table and 
column names appear unreadable (AccumRgXXX, ReferenceXX, DocumentXX), 
with system and user tables mixed together.

## Approach
1. Reverse engineering — identify what each table and column stores
2. Star schema design — select dimension and fact tables
3. Mapping and data cleaning — resolve mismatches between source data 
   (duplicates, unmatched records) before writing ETL
4. Write DDL and ETL logic

## Scope
This is a static, archival dataset — not a live, incrementally updating 
system. As a result, the design does not include incremental load logic 
or slowly changing dimension (SCD) handling; the ETL process here is a 
one-time historical load.

## Status
Completed for one source system. Integration of additional sources is in progress.

