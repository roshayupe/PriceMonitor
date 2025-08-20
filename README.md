# Price Monitoring System

Application for monitoring competitor prices with ability to view, edit
and save data into Oracle database.\
Developed in **Delphi XE4+** with **DevExpress VCL** UI components and
**ODAC** data access.

------------------------------------------------------------------------

## Features

-   **Competitor selection** via `TcxCheckComboBox` (multi-select +
    "All" option).
-   **Date selection** via `TcxDateEdit`.
-   **Dynamic grid** (`TcxGridDBTableView`) with:
    -   Product column
    -   One column per selected competitor
-   **Conditional coloring**:
    -   🔴 Red --- price increased compared to previous monitoring
    -   🟢 Green --- price decreased
    -   ⚪ Gray --- no previous value / unchanged
-   **Edit rules**:
    -   Today's date → editing allowed
    -   Past dates → read-only
-   **Database persistence**:
    -   Load prices via `PRICE_MONITORING.GET_PRICES`
    -   Save prices via `PRICE_MONITORING.SAVE_PRICES`
-   **Cancel changes**:
    -   Revert to last snapshot or reload from DB

------------------------------------------------------------------------

## Database Schema

``` sql
-- PRODUCTS
CREATE TABLE PRODUCTS (
  ID     NUMBER PRIMARY KEY,
  NAME   VARCHAR2(200),
  STATUS NUMBER(1) DEFAULT 1 -- 1=active, 0=inactive
);

-- COMPETITORS
CREATE TABLE COMPETITORS (
  ID     NUMBER PRIMARY KEY,
  NAME   VARCHAR2(200),
  STATUS NUMBER(1) DEFAULT 1
);

-- PRICES
CREATE TABLE PRICES (
  PRODUCT_ID     NUMBER REFERENCES PRODUCTS(ID),
  COMPETITOR_ID  NUMBER REFERENCES COMPETITORS(ID),
  MONITOR_DATE   DATE,
  PRICE          NUMBER(12,2),
  CONSTRAINT PK_PRICES PRIMARY KEY (PRODUCT_ID, COMPETITOR_ID, MONITOR_DATE)
);
```

------------------------------------------------------------------------

## Stored Procedures

Package: **PRICE_MONITORING**

-   `GET_PRICES(p_monitor_date DATE, p_competitors VARCHAR2, RESULT OUT SYS_REFCURSOR)`
-   `SAVE_PRICES(p_data_csv CLOB)`

CSV format for `SAVE_PRICES`:

    product_id;competitor_id;monitor_date;price

Multiple rows separated by `|`\
Example:

    1001;5;2025-01-20;12.50|1002;7;2025-01-20;99.99

------------------------------------------------------------------------

## Installation

1.  Create Oracle schema with tables above.
2.  Compile and run Delphi project (`UnitMain.pas` is the main form).
3.  Configure **ODAC session** (`TOraSession`) to connect to your DB.
4.  Run the app:
    -   Select competitors
    -   Pick a date
    -   Press **Load** to fetch data
    -   Modify today's prices if needed
    -   Press **Save** to commit changes
    -   Press **Cancel** to revert unsaved edits

------------------------------------------------------------------------

## Development Notes

-   UI built with **DevExpress TcxGrid**.
-   Dynamic grid structure rebuilt each time based on selected
    competitors.
-   In-memory dataset: **TdxMemData** with snapshotting for undo.
-   Styling handled in `OnGetContentStyle`.

------------------------------------------------------------------------

## Requirements

-   Delphi XE4 or newer
-   DevExpress VCL components
-   ODAC (DevArt)
-   Oracle 11g or newer

------------------------------------------------------------------------

## Author

*System developed as part of test task "Competitor Price Monitoring".*
