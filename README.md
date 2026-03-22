# Retail Supply Chain Analytics – End‑to‑End Portfolio Project

## 1. Project Overview

This project simulates a large retail **Supply Chain Analytics** environment and delivers an end‑to‑end analytics solution: data generation, SQL pipeline, and an interactive Power BI dashboard for supply chain leadership.

Goals:

- Build reporting on **core KPIs** across Fulfillment Centers (FCs), stores, replenishment, and transportation.  
- Translate raw data into **actionable insights and recommendations** for Operations, Replenishment, and Transportation teams.  
- Demonstrate strong skills in **SQL, data modeling, and visualization (Power BI)** for senior data analyst roles.

Tech stack:

- Python (Pandas) – synthetic data generation  
- SQLite + SQL – data warehouse & KPI calculations  
- Power BI – executive & operational dashboards  
- Git + GitHub – version control and documentation  

## 2. Business Context

A national retailer operates multiple Fulfillment Centers and retail stores across several regions, serving both B2B and retail customers with office supplies, technology, and furniture. The supply chain team is under pressure to:

- Reduce **stockouts** on key SKUs.  
- Improve **replenishment efficiency** between FCs and stores.  
- Optimize **transportation cost per unit** while maintaining service levels.  

Leadership needs a **single source of truth** for supply chain KPIs and a clear view of **which FCs, stores, and SKUs** are driving service and cost issues.

## 3. Data Model & Datasets

I implemented a **star‑schema** data model with 4 dimensions and 3 fact tables to support inventory, orders, shipments, and KPI reporting.

**Dimensions**

- `DIM_Date` – calendar, year/quarter/month/day, holiday flag.  
- `DIM_Product` – SKU, product name, category, sub‑category, unit cost.  
- `DIM_Location` – both Stores and FCs, with city, province/state, region.  
- `DIM_Carrier` – carrier name and service level.

**Facts**

- `FACT_Store_Order` – store orders to FCs by SKU, including allocated quantity and stockout flag.  
- `FACT_Shipment` – FC‑to‑store shipments by SKU, including carrier, dates, quantities, cost, on‑time and perfect‑order flags.  
- `FACT_Inventory_Daily` – daily on‑hand inventory by product and location, with reorder point and holding cost.

Synthetic data (~200K+ rows) was generated in Python, exported as CSVs, and loaded into SQLite:

- `dim_date.csv`, `dim_product.csv`, `dim_location.csv`, `dim_carrier.csv`  
- `fact_store_order.csv`, `fact_shipment.csv`, `fact_inventory_daily.csv`  

## 4. SQL Pipeline

All SQL is organized into **three scripts**:

1. `01_data_cleaning.sql`  
2. `02_kpi_calculations.sql`  
3. `03_insights_analysis.sql`  

They:

- Create and index all tables, import CSVs, and build base views.  
- Compute KPIs by month, FC, store, and region:  
  - Fill Rate, Stockout Rate, On‑Time Delivery, Inventory Turnover, Avg Lead Time, Transportation Cost per Unit, Perfect Order Rate, Days Inventory on Hand.  
- Produce compact reporting tables: `kpi_summary` and `insights_summary`.

A Python script `run_pipeline.py` orchestrates: generate data → load → run SQL → export `kpi_summary.csv` and `insights_summary.csv`.

## 5. Power BI Dashboard

The Power BI report (`supply_chain_analytics.pbix`) is built on top of `kpi_summary` and `insights_summary` and currently contains **three main pages**:

### Page 1 – Executive Summary
- Slicers: Month, Region, Fulfillment Center.  
- KPI cards: Fill Rate, Stockout Rate, On‑Time Delivery, Perfect Order Rate, Transportation Cost per Unit.  
- Trend line: Fill Rate % over time by region.  
- Insights table: Top issues (e.g., highest stockout stores, worst cost‑per‑unit lanes).

### Page 2 – FC Performance
- Fill Rate by FC.  
- Stockout Rate by FC.  
- Average Replenishment Lead Time (days) by FC.

### Page 3 – Replenishment
- Stockout Rate by Store.  
- Days Inventory on Hand by Store.  
- Table of store/SKU combinations with the worst replenishment behaviour.

## 6. Example Insights

- One FC shows higher average lead time and slightly lower fill rate than others.  
- Some stores have both high stockout rates and low days of inventory on hand, suggesting reorder points are too low.  
- Certain FC–store lanes show above‑average transportation cost per unit, indicating optimization opportunities.

## 7. Repository Structure

```text
Analytics_Projects/
├─ README.md
├─ project_brief.md
├─ data_model.md
├─ data_quality_report.md
├─ generate_dataset.py
├─ run_pipeline.py
├─ 01_data_cleaning.sql
├─ 02_kpi_calculations.sql
├─ 03_insights_analysis.sql
├─ dim_date.csv
├─ dim_product.csv
├─ dim_location.csv
├─ dim_carrier.csv
├─ fact_store_order.csv
├─ fact_shipment.csv
├─ fact_inventory_daily.csv
├─ kpi_summary.csv
├─ insights_summary.csv
└─ supply_chain_analytics.pbix

8. How to Run


Install Python dependencies (Pandas, etc.).


Run:


python generate_dataset.py
python run_pipeline.py



Open Power BI Desktop and load supply_chain_analytics.pbix, or connect directly to kpi_summary.csv and insights_summary.csv.
