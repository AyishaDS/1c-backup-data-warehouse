## Reverse Engineering

The table and column names in a 1C database are mainly technical identifiers. For example, tables may have names such as `_Reference###`, `_Document###` and `_AccumRg####`, while columns may use names such as `_Fld####`. These names do not directly show the business meaning of the data.

To prepare the ETL layer, a 1C backup restored in SQL Server was analysed to identify the purpose of its tables and columns and determine how the data could be used in the Data Warehouse.

### Analysis Approach

The analysis started with the `Reference` tables. Their `Description` columns were reviewed to identify the objects represented by each table, and the results were recorded in mapping files.

Next, other table types, including `Document` and `AccumRg`, were analysed. Row counts were used to set priorities, with larger tables examined first.

For each relevant `_Fld####RRef` column, SQL queries were used to identify the reference table it pointed to. `JOIN` conditions were then added to combine the related data and clarify the meaning of the columns.

For example, an accumulation register could be joined with reference tables to retrieve readable values for business dimensions and examine measures such as quantity, net amount, gross amount and cost amount.

The SQL results were then compared with the information displayed in the 1C interface. This comparison was used to verify the identified column meanings against the application data.

The following example illustrates the query structure. The original table and column names have been anonymised.

```sql
SELECT
    DATEADD(YEAR, -Y.Offset, A._Period) AS FACT_DATE,
    R1._Description AS DEPARTMENT,
    R2._Description AS CLIENT_NAME,
    R3._Description AS ITEM,
    A._Fld0001 AS QUANTITY,
    A._Fld0002 AS NET_AMOUNT,
    A._Fld0003 AS GROSS_AMOUNT
FROM _AccumRg0000 A
CROSS JOIN _YearOffset Y
LEFT JOIN _Reference000 R1
    ON R1._IDRRef = A._Fld0004RRef
LEFT JOIN _Reference001 R2
    ON R2._IDRRef = A._Fld0005RRef
LEFT JOIN _Reference002 R3
    ON R3._IDRRef = A._Fld0006RRef
ORDER BY FACT_DATE;
```

The query combines register records with related reference data. The date expression also applies the year offset stored in the database.

### Main Table Types Identified

| Table type | Example name | Purpose |
|---|---|---|
| Reference | `_Reference##` | Stores information about business objects |
| Document | `_Document###` | Stores document data related to business operations |
| Document tabular section | `_Document###_VT###` | Stores row-level details within a document |
| Accumulation register | `_AccumRg####` | Stores business movements, such as sales, discounts and bonuses |

Full column mappings are in `mapping/`.
