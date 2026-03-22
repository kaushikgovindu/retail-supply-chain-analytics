# Data Quality & Pipeline Report

## 1. Database Population
- **DIM_Date**: 1,096 rows loaded successfully.
- **DIM_Product**: 500 rows loaded successfully.
- **DIM_Location**: 55 rows loaded successfully.
- **DIM_Carrier**: 4 rows loaded successfully.
- **FACT_Store_Order**: 50,000 rows loaded successfully.
- **FACT_Shipment**: 40,000 rows loaded successfully.
- **FACT_Inventory_Daily**: 100,000 rows loaded successfully.

## 2. KPI Metric Ranges
Summarizing the calculated KPIs across all region-month combinations to ensure they fall within realistic ranges:

|       |   fill_rate_pct |   stockout_rate_pct |   on_time_delivery_pct |   inventory_turnover |   avg_lead_time_days |   transport_cost_per_unit |   perfect_order_pct |   days_inventory_on_hand |
|:------|----------------:|--------------------:|-----------------------:|---------------------:|---------------------:|--------------------------:|--------------------:|-------------------------:|
| count |         8959    |             8959    |                8888    |               494    |              8885    |                   8888    |             8888    |                   494    |
| mean  |           89.22 |               20.31 |                  84.92 |                 2.42 |                 4.99 |                     26.1  |               76.2  |                    59.98 |
| std   |           11.98 |               19.25 |                  19.7  |                 1.64 |                 0.9  |                      9.77 |               23.42 |                   357.56 |
| min   |            0    |                0    |                   0    |                 0    |                 2    |                      2.02 |                0    |                     3.4  |
| 25%   |           83.02 |                0    |                  75    |                 1.24 |                 4.5  |                     19.04 |               66.67 |                     9    |
| 50%   |           91.67 |               20    |                 100    |                 2.12 |                 5    |                     26.14 |               80    |                    14.1  |
| 75%   |          100    |               33.33 |                 100    |                 3.35 |                 5.5  |                     33.06 |              100    |                    24.2  |
| max   |          100    |              100    |                 100    |                 8.85 |                 8    |                     49.95 |              100    |                  7478.5  |

## 3. Data Quality Checks
- **Foreign Key Integrity**: Tested successfully. Relationship mapped correctly across the Star Schema.
- **Null Values**: Handled gracefully via `NULLIF` directly inside KPI Views (safeguarding zero-division).
- **Readiness**: Target database `staples_supply_chain.db` is built and ready for **Power BI DirectQuery** or standard Import mode.
