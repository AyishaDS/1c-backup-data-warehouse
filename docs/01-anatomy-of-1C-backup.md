# Anatomy of a 1C Backup

## 1. Introduction

This document describes the process of exploring a restored 1C backup in SQL Server. Table and column structures, relationships, and sample data were examined to understand their possible business meaning and identify useful data sources for a Data Warehouse.

The database structure can vary between 1C versions and configurations. As the original metadata was not directly available for analysis, reverse engineering was used to explore the specific backup. The work focused on understanding the data without changing the live 1C system.

## 2. System Tables and Business Data

The backup contained system tables and business tables. `Config`, `Params`, and `DBSchema` were related to the database structure. `_YearOffset` was checked to understand how dates were stored.

Tables such as `_Reference`, `_Document`, and `_AccumRg` contained business data. Their names helped identify possible table types.

## 3. Table Names

Table names gave the first clues about their purpose. `_Reference` was used for catalogs, `_Document` for documents, and `_AccumRg` for accumulation registers. Tables with `_VT` in their names usually contained rows from a document's table section.

These names helped guide the analysis, but the data was also checked to understand what each table contained.

## 4. Column Names and References

Some columns had technical names that did not clearly explain their meaning. For example, `_Fld...` was used for fields with a number in the name. Sample data helped explain what these fields might contain.

`_IDRRef` was used as a record identifier. `_ParentIDRRef` helped identify links between parent and child records. Fields such as `_Fld...RRef` could contain references to other objects.

SQL Server system views, such as `sys.columns` and `sys.types`, were used to check column names and data types.

| Column example | General meaning |
|---|---|
| `_IDRRef` | Record reference identifier |
| `_Code`, `_Description` | Code and name or description |
| `_ParentIDRRef` | Reference to a parent record |
| `_Folder` | Indicates a group in some catalogs |
| `_Marked` | Indicates that a record is marked for deletion |
| `_Version` | Record version |
| `_Date_Time`, `_Number`, `_Posted` | Document date, number, and posting status |
| `_Fld<N>RRef` | A field that may contain a reference to another object |
| `_Fld<N>_TYPE`, `_Fld<N>_RTRef`, `_Fld<N>_RRRef` | Fields that help identify the type of reference and its target |

## 5. Document Headers and Table Sections

A document usually has a header table and separate tables for its rows. The header contains general information, such as the date, number, and total amount. The other tables contain details, such as services, products, and quantities.

For example, a document may have a total amount of 100 and three rows. After joining the tables, the total amount may appear three times. Adding these values would give 300 instead of 100.

To avoid this, the grain of each table was considered. This means understanding what one row represents and checking how joins affect the number of rows.

## 6. Registers: Understanding the Data Source

### 6.1 Information Registers and Accumulation Registers

| Register | General purpose |
|---|---|
| `_InfoRg<N>` | Stores information or records changes over time. |
| `_AccumRg<N>` | Stores movements related to business events, such as payments, bonuses, or stock movements. |

The table prefix gives the first clue about its purpose. The exact business meaning cannot be identified from the table number alone. Column names, reference fields, amounts, quantities, and linked documents were examined to understand what each register contained.

### 6.2 Common Columns in `_AccumRg` Tables

| Column | General meaning |
|---|---|
| `_Period` | Date and time of the register record. |
| `_RecorderRRef` | Reference to the document that created the movement. |
| `_RecorderTRef` | Helps identify the type of the recorder document. |
| `_LineNo` | Line number of the register record. |
| `_Active` | Indicates whether the record is active. |
| `_RecordKind` | In balance-type accumulation registers, usually indicates income (0) or expense (1). |
| `_Fld<N>RRef` | May contain a reference to an object, such as a client, department, or product. |
| `_Fld<N>` | May contain a resource, such as an amount or quantity. |

The combination of `_RecorderTRef` and `_RecorderRRef` helps identify the document linked to a register movement. The exact relationship depends on the database structure.

### 6.3 `_RecordKind` and Amount Calculation

In balance-type accumulation registers, income and expense movements affect the balance in different ways. A common calculation is:

```sql
SUM(CASE WHEN _RecordKind = 0 THEN Amount ELSE -Amount END)
```

This formula may not work for every register. The meaning of `_RecordKind` and the way amounts are stored were checked for each register.

The calculation also depends on the business goal. Total sales, expenses, and the balance at the end of a period are different measures and need different calculations.

### 6.4 Total Tables

`_AccumRgT` stores balance totals, while `_AccumRgTn` stores turnover totals. Their availability depends on the register.

For this project, `_AccumRg` was used as the main source for fact data. Total tables were used to compare results where possible. Movement records and totals were kept separate to avoid counting the same data twice.

## 7. Dates and `_YearOffset`

The `_YearOffset` table was checked to understand how dates were stored in the backup. The offset value was read directly from the database:

```sql
SELECT TOP (1) Offset FROM _YearOffset;
```

In this backup, the offset was 2000 years. For example, a stored year of 4019 became 2019 after conversion.

```sql
DATEADD(YEAR, -Y.Offset, A._Period)
```

The date conversion was applied to the relevant columns. Empty or unusual dates were checked separately to avoid treating them as real business dates.

## 8. Example: Identifying the Sales Fact

Creating `FCT.SALES` requires more than selecting all rows from one register. The data must first be checked to understand which business events the register contains and which documents create these records.

The analysis focused on the following points:

1. Table columns, data types, row counts, dimensions, and resources.
2. Recorder types to identify which documents created the records.
3. Document types and sample data to understand the business meaning.
4. `_RecordKind` and `_Active` values to understand how records were stored.
5. The grain of the sales fact — what one row represents.
6. Row counts, amounts, date ranges, and available 1C reports to compare the results.

The following query was used to explore the data in a register. It shows the number of rows for each recorder type and record kind.

```sql
SELECT _RecorderTRef, _RecordKind, COUNT(*) AS row_count
FROM _AccumRg_A
GROUP BY _RecorderTRef, _RecordKind
ORDER BY row_count DESC;
```

Some registers may contain paired income and expense records for the same business event. These records were checked before calculating totals to avoid counting the same amount incorrectly. This behavior was not assumed to be the same for every register.

## 9. Data Warehouse Approach

The following principles were used during the analysis:

1. The business goal and grain of each fact were defined before selecting the source data.
2. Table names were used as a starting point. Column names, references, and sample data helped explain their meaning.
3. Main object tables were explored to identify possible dimensions and their source keys.
4. Records marked for deletion were checked separately. They were not treated as physically deleted records.
5. `_AccumRg` and `_Document..._VT...` tables were explored as possible fact sources. The choice depended on the business data they contained.
6. The values of `_RecorderTRef`, `_RecordKind`, and `_Active` were checked before selecting register records.
7. Table grain was considered before joining tables to avoid duplicate rows and incorrect totals.
8. Empty references were checked to understand how missing values were stored.
9. Additional type fields were checked when a reference could point to different object types.
10. The date offset was checked for each backup, and converted dates were compared with the expected date range.
11. Row counts, amounts, missing references, and date ranges were compared with the source data after ETL.

These principles helped guide the analysis and prepare the data for the Data Warehouse. Filters and calculations were selected based on the structure of the backup and the business requirements.

## 10. Conclusion

When metadata was not directly available, the analysis started with table names and column types. Relationships and sample data were then examined to understand the business meaning of the data.

Table names and technical structures provided useful clues, but they did not explain everything. The purpose of each register, the meaning of `_RecordKind`, the date offset, and empty references were checked against the actual backup.

The final Data Warehouse choices were based on the findings from this specific backup and its business data.

## Resources

[1] 1C:Enterprise Platform data saving structure in the DBMS (1C:Developer Network / Knowledge Base).
https://kb.1ci.com/1C_Enterprise_Platform/FAQ/Administration/DBMS/1C_Enterprise_Platform_data_saving_structure_in_the_DBMS/

[2] 1C:Enterprise 8.3.27 — Размещение данных 1С:Предприятия 8. Таблицы и поля.
https://its.1c.ru/db/content/metod8dev/src/admins/i8101798.htm

[3] 1C:Enterprise — Особенности хранения составных типов данных.
https://its.1c.ru/db/content/metod8dev/src/developers/platform/metod/other/i8101828.htm

[4] 1C:Developer Network — Data structure in 1C:Enterprise 8.
https://1c-dn.com/library/data_structure_in_1c_enterprise_8/