# Methodology – Retail Supply Chain Analytics

## 1. Overview

This document explains the analytical approach, KPI definitions, data transformations, and quality assurance used in the Retail Supply Chain Analytics project.

---

## 2. Data Architecture

### 2.1 Star Schema Design

The project uses a **star schema** with 4 dimension tables and 3 fact tables:


     DIM_Date
        |
        |

DIM_Product-+---DIM_Location
|
|
DIM_Carrier
FACT_Store_Order (references: Date, Product, Location-Store, Location-FC)
FACT_Shipment (references: Date, Location-FC, Location-Store, Carrier)
FACT_Inventory_Daily (references: Date, Product, Location)

**Benefits:**
- Normalized dimensions avoid redundancy.
- Fact tables remain focused on events/transactions.
- Enables efficient aggregations for KPI calculations.
- Supports historical tracking and period-over-period analysis.

### 2.2 Dimension Tables

| Table | Records | Key Fields | Purpose |
|-------|---------|-----------|---------|
| `DIM_Date` | 365–730 | date, day_of_week, month, quarter, is_holiday | Enables time-based slicing and trending |
| `DIM_Product` | 50 | product_id, product_name, category, unit_cost | Product-level analysis and cost allocation |
| `DIM_Location` | 23 | location_id, location_name, city, region, location_type (FC/Store) | Geographic and operational unit segmentation |
| `DIM_Carrier` | 5 | carrier_id, carrier_name, service_level | Logistics performance and cost analysis |

### 2.3 Fact Tables

| Table | Records | Key Metrics | Purpose |
|-------|---------|----------|---------|
| `FACT_Store_Order` | ~120K | requested_qty, allocated_qty, stockout_flag | Captures replenishment demand and fulfillment |
| `FACT_Shipment` | ~150K | shipped_qty, cost, on_time_flag, perfect_order_flag | Tracks logistics performance and cost |
| `FACT_Inventory_Daily` | ~180K | on_hand_qty, reorder_point, holding_cost | Monitors inventory levels and valuation |

---

## 3. KPI Definitions & Calculations

### 3.1 Fill Rate (%)

**Definition:** Percentage of store orders that were fully allocated by the FC.

**Formula:**

Fill Rate = (Orders with allocated_qty >= requested_qty) / Total Orders × 100

**Business Meaning:** Higher = better fulfillment reliability. Target: >95%.

**Aggregation:** Monthly by Region, FC, Store.

---

### 3.2 Stockout Rate (%)

**Definition:** Percentage of store orders that were NOT fully allocated (shortfall).

**Formula:**

Stockout Rate = (Orders with allocated_qty < requested_qty) / Total Orders × 100

**Business Meaning:** Lower = fewer lost sales due to unavailability. Target: <5%.

**Aggregation:** Monthly by Region, FC, Store, Product Category.

---

### 3.3 On-Time Delivery (%)

**Definition:** Percentage of shipments delivered by the promised delivery date.

**Formula:**

On-Time Delivery = (Shipments with actual_date <= promised_date) / Total Shipments × 100

**Business Meaning:** Logistics reliability. Target: >98%.

**Aggregation:** Monthly by Carrier, FC, Store.

---

### 3.4 Perfect Order Rate (%)

**Definition:** Percentage of orders that are On-Time AND Complete AND Error-Free.

**Formula:**

Perfect Order Rate = (Orders that are on_time=1 AND complete=1 AND error_free=1) / Total Orders × 100

**Business Meaning:** End-to-end supply chain reliability. Target: >90%.

**Aggregation:** Monthly by Region, FC, Store.

---

### 3.5 Average Replenishment Lead Time (days)

**Definition:** Average number of calendar days from store order creation to FC shipment date.

**Formula:**

Lead Time = AVG(shipment_date - order_date) for all orders

**Business Meaning:** Replenishment agility; impacts reorder point sizing. Lower = faster response.

**Aggregation:** Monthly by FC, Region.

---

### 3.6 Transportation Cost per Unit

**Definition:** Total transportation cost divided by total units shipped.

**Formula:**

Cost per Unit = SUM(shipment_cost) / SUM(shipped_qty)

**Business Meaning:** Logistics efficiency. Identify high-cost lanes for optimization.

**Aggregation:** Monthly by Carrier, FC-to-Store Lane.

---

### 3.7 Days Inventory on Hand (DIO)

**Definition:** Average number of days an item sits in inventory before being sold/consumed.

**Formula:**

DIO = AVG(on_hand_qty) / (Monthly Sales / Number of Days in Month)

**Business Meaning:** Balance between stockouts (low DIO) and excess inventory (high DIO). Target: 15–25 days depending on product category.

**Aggregation:** Monthly by Store, Product Category.

---

### 3.8 Inventory Turnover

**Definition:** Number of times inventory is sold/consumed during the period.

**Formula:**

Inventory Turnover = Monthly Sales / Average Inventory Level

**Business Meaning:** Capital efficiency. Higher = less working capital tied up.

**Aggregation:** Monthly by Store, Region.

---

## 4. Data Quality & Validation

### 4.1 Quality Checks Performed

1. **Completeness:**
   - No NULL values in key fields (order_id, shipment_id, product_id, location_id).
   - All stores and FCs appear in relevant fact tables.

2. **Consistency:**
   - Foreign keys match dimension tables (Product, Location, Carrier).
   - Dates within expected range (2024–2025).
   - Quantities are non-negative.

3. **Accuracy:**
   - Fill Rate + Stockout Rate = 100% (mutually exclusive).
   - On-Time flags only 0 or 1.
   - Lead times are non-negative.

4. **Timeliness:**
   - Data updated daily (snapshot of inventory).
   - Orders and shipments recorded within 24 hours of occurrence.

### 4.2 Anomaly Detection

- Stores with >20% stockout rate flagged as high-risk.
- Transportation cost >2 std devs from mean flagged as outlier.
- Lead times >3 std devs from mean reviewed for data entry errors.

---

## 5. Aggregation & Rollup Logic

### 5.1 Temporal Aggregation

All KPIs are calculated monthly. Weekly or daily drill-downs are supported by the fact tables but not pre-aggregated.

**Rationale:** Monthly is standard for supply chain planning cycles. Weekly rollup would increase storage ~4x without much business value.

### 5.2 Geographic Rollup

Hierarchy: **Store → Region → Company-Wide**

- Store-level metrics are primary (capture actual performance).
- Region-level metrics are weighted averages of constituent stores.
- Company-wide metrics are weighted averages of all regions.

**Formula:**
```
Regional KPI = SUM(Store Metric × Store Weight) / SUM(Store Weights)
where Store Weight = number of orders or shipments that month
```

---

## 6. Advanced Analyses

### 6.1 Scenario Analysis

The `scenario_analysis.sql` script simulates:
- Impact of +10% / +20% safety stock on stockout rates and holding costs.
- Effect of switching from weekly to daily replenishment on inventory levels.
- Break-even analysis for different replenishment policies.

**Method:** Proportional scaling based on industry benchmarks and historical correlations.

### 6.2 Insights Extraction

`03_insights_analysis.sql` identifies:
- Top 10 stores by stockout rate (prioritize for investigation).
- Top 10 FC-to-store lanes by cost per unit (optimize).
- Stores with misaligned inventory (too much + high stockouts = poor allocation).
- Carriers with on-time variance (performance issues).

---

## 7. Limitations & Future Work

### 7.1 Current Limitations

- **Synthetic Data:** Real performance will vary; scenario models are approximations.
- **Demand Seasonality:** Current model assumes constant demand; future versions should incorporate seasonal patterns.
- **Supplier Variability:** Lead time assumes fixed; real suppliers have variability.
- **Cost Allocation:** Transportation cost is simplified; doesn't account for fuel surcharges, packaging, etc.

### 7.2 Future Enhancements

- **Forecasting Model:** ARIMA or Prophet to predict demand and optimize reorder points.
- **Network Optimization:** Linear programming to optimize FC locations and shipment routing.
- **Machine Learning:** Clustering stores by demand pattern; dynamic safety stock by cluster.
- **Real Data Integration:** Connect to actual ERP/WMS systems (SAP, Oracle, NetSuite).
- **Real-Time Alerting:** Automated notifications when KPIs breach thresholds.
