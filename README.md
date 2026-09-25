# 1c-backup-data-warehouse

A reproducible methodology for reverse-engineering an unlabeled 1C ERP backup into a documented, analysis-ready star schema — built as a foundation layer for integration with other data sources.

## Problem & Challenge

A company that uses only the 1C program for customer records and accounting wants to analyze its customer data. There is no in-house developer, and no changes can be made to the live system. This is common for small and mid-sized businesses — especially in beauty, wellness, and clinic sectors in the CIS region.

The chosen method was to restore an IT-provided backup file into a separate SQL Server environment. But when a 1C backup opens in a different environment, metadata relationships are lost. Table and column names appear unreadable (AccumRgXXX, ReferenceXX, DocumentXX), with system and user tables mixed together.

## Approach

1. **Reverse engineering** — identify what each table and column stores
2. **Star schema design** — select dimension and fact tables
3. **Mapping and data cleaning** — resolve mismatches in the source data (duplicates, unmatched records) before writing ETL
4. **Write DDL and ETL logic**
5. **Document the process** — mapping decisions and cases where a first assumption turned out wrong


## Scope

This is a static, archival dataset — not a live, incrementally updating system. The design does not include incremental load logic or slowly changing dimension (SCD) handling. The ETL process here is a one-time historical load.

## Status
Core layer complete: dimension tables and the primary sales fact table, covering customer, employee, service, and revenue data for one archival source system.

## Scope
This is a static, archival dataset — not a live, incrementally updating 
system. As a result, the design does not include incremental load logic 
or slowly changing dimension (SCD) handling; the ETL process here is a 
one-time historical load.

## Status
Completed for one source system. Integration of additional sources is in progress.

