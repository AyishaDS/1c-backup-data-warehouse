## Star Schema Design

The warehouse uses a Kimball-style star schema with two schemas: `DIM` for dimension tables and `FCT` for fact tables.

No staging layer is included. The source is a static archive, loaded using a full reload. Incremental loading and SCD handling are not required for this dataset.

### Tables

The model includes one fact table and six dimension tables.

**FCT.SALES** is the central fact table. Each row represents one sales movement. It stores two measures: quantity and net amount.

The dimension tables are:

- **DIM.DATE** — date attributes, including day, month, year, and quarter.
- **DIM.CLIENT** — client information, including a foreign key to DIM.CLIENT_SOURCE.
- **DIM.CLIENT_SOURCE** — the channel through which a client was acquired. It is linked to DIM.CLIENT, not directly to FCT.SALES.
- **DIM.EMPLOYEE** — employee information.
- **DIM.DEPARTMENT** — department information.
- **DIM.ITEM** — product and service information.

### Conventions

Each dimension uses an integer surrogate key as its primary key. Each dimension also contains an `Unknown` row with key `-1`. Fact records without a matching dimension reference use this row to keep foreign keys non-null.

Source balance tables (`_AccumRgT` and `_AccumRgTn`) are not loaded into the warehouse. Running balances can be calculated from the base movement tables when needed.