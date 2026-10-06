# 1C-backup-data-warehouse

How to turn an unlabeled 1C:Enterprise backup into a documented, analysis-ready
star schema in SQL Server. A portfolio project documenting the method and the decisions behind it.

## Problem
A clinic keeps customer and accounting data in 1C:Enterprise. No in-house developer,
no changes allowed on the live system. The only access is an IT-provided backup.
Restored into a separate SQL Server, 1C metadata is gone: tables appear as
`_AccumRg8785`, `_Reference15`, `_Document251`, with no names or relationships.

## Approach
1. Reverse engineering: identify what each table and column stores
2. Star schema design: choose dimensions and facts
3. Profiling and cleaning: duplicates, unmatched keys, before writing ETL
4. DDL and ETL (one-time historical load)
5. Documentation, including assumptions that turned out wrong

## Result
- 5 dimension tables, 1 fact tables  
- Covers: customers, employees, services, revenue
- Business questions it answers: 

## Documentation
- [Anatomy of a 1C backup](docs/01-1c-backup-anatomy.md)
- [Reverse-engineering method](docs/02-reverse-engineering.md)
- [Star schema design](docs/04-star-schema-design.md)

## Scope
Static archival dataset, one-time load. No incremental logic, no SCD handling.

## Repository layout
`sql/ddl`, `sql/etl`, `sql/run_order.sql` (anonymized)
