# Project Brief – Retail Supply Chain Analytics

## 1. Business Context

A national multi-location retailer operates a complex supply chain network with:
- Multiple Fulfillment Centers (FCs) serving regional stores
- Store-level inventory management and replenishment
- Transportation across numerous FC-to-store lanes
- Hundreds of SKUs across multiple product categories

**Current Challenges:**
- **Stockouts** on high-demand SKUs causing lost sales and customer dissatisfaction.
- **Excess inventory** at certain stores while others run short, indicating poor replenishment alignment.
- **High transportation costs** on specific FC-to-store lanes without clear visibility into cost drivers.
- **Inconsistent lead times** across FCs, limiting replenishment predictability.
- **Lack of integrated reporting** on supply chain KPIs across operations, replenishment, and transportation teams.

**Business Objectives:**
1. Provide a single source of truth for supply chain KPIs.
2. Enable data-driven replenishment decisions (reorder points, order frequency, safety stock).
3. Identify and optimize high-cost transportation lanes.
4. Support FC Operations in diagnosing service level issues and lead time problems.

---

## 2. Core Analytical Questions Answered

### **FC Operations:**
- Which FCs have the lowest fill rate? Lead time?
- Are certain FCs driving stockout issues more than others?
- How do FC replenishment lead times correlate with store stockout rates?

### **Replenishment & Planning:**
- Which stores have the highest stockout rates?
- Are stockouts driven by low reorder points or high demand variability?
- Which store-SKU combinations are the biggest replenishment risks?
- How do days of inventory on hand vary by store, and are they aligned with demand?

### **Transportation & Logistics:**
- Which FC-to-store lanes have above-average transportation cost per unit?
- Is higher cost driven by carrier selection, service level, or lane distance?
- Which carriers are performing on-time? Which have the lowest cost?

### **Executive / Leadership:**
- Are we trending toward better or worse fill rates by region?
- What is the aggregate perfect order rate (on-time + complete + error-free)?
- Where should the supply chain team focus operational efforts this month?

---

## 3. Core Supply Chain KPIs Tracked

All KPIs are calculated monthly and segmented by Region, FC, and Store.

| KPI | Definition | Business Value |
|-----|-----------|-----------------|
| **Fill Rate (%)** | Percentage of store orders fulfilled completely by FCs | Measures order fulfillment reliability; target >95% |
| **Stockout Rate (%)** | Percentage of store orders that had to be partially fulfilled due to FC unavailability | Identifies service gaps; lower is better |
| **On-Time Delivery (%)** | Percentage of shipments delivered by promised date | Measures logistics performance; target >98% |
| **Perfect Order Rate (%)** | Orders delivered on-time, in full, and without damage/error | Ultimate end-to-end reliability metric |
| **Avg Replenishment Lead Time (days)** | Average number of days from store order to FC shipment | Indicates replenishment agility; critical for reorder point tuning |
| **Transportation Cost per Unit** | Average cost to transport one unit from FC to store | Identifies cost optimization opportunities |
| **Days Inventory on Hand** | Average number of days a unit sits in inventory at a store | Balance between stockouts (too low) and excess inventory (too high) |
| **Inventory Turnover** | Number of times inventory is sold/consumed per month | Efficiency metric; correlates with working capital |

---

## 4. Key Insights Discovered

### **Insight 1: Geographic Variation in Service Levels**
- **Finding**: Eastern region shows 6–8% lower fill rate vs. Western region.
- **Root Cause**: FC serving the East has 2–3 days longer lead time and slightly lower inventory turnover.
- **Recommendation**: Review FC capacity, carrier performance on Eastern lanes, or implement dynamic safety stock adjustments for high-variability SKUs in the East.

### **Insight 2: Stockout-Inventory Mismatch at Specific Stores**
- **Finding**: A subset of ~8–10 stores show BOTH high stockout rates AND low days of inventory on hand.
- **Root Cause**: Reorder points set too aggressively (to save on holding costs), but demand is more variable than the model assumes.
- **Recommendation**: Increase safety stock and reorder points by 10–15% for these stores; pilot a more responsive replenishment cadence (daily vs. weekly orders).

### **Insight 3: High-Cost Transportation Lanes**
- **Finding**: ~15% of FC-to-store lanes show 20–30% above-average transportation cost per unit.
- **Root Cause**: Mix of low-volume lanes (fixed costs spread over few units), premium service levels, or longer distances.
- **Recommendation**: Consolidate orders on high-frequency lanes; negotiate carrier rates for low-margin lanes; evaluate service-level downgrades where possible.

### **Insight 4: Inventory Turnover vs. Stockouts Correlation**
- **Finding**: Low-turnover stores (inventory sitting 30+ days) still experience stockouts, suggesting poor product mix or allocation.
- **Root Cause**: Safety stock allocated to slow-moving SKUs, not the fast-moving ones causing stockouts.
- **Recommendation**: Implement ABC analysis by store; dynamically allocate safety stock to high-demand SKUs.

### **Insight 5: Carrier Performance Variability**
- **Finding**: On-time delivery varies 5–10% across carriers on the same lane.
- **Root Cause**: Differences in fleet size, routing efficiency, or pickup/delivery windows.
- **Recommendation**: Consolidate volume with top 2–3 carriers per lane; implement SLA penalties for underperformers.

---

## 5. Data Sources & Transformations

**Raw Data:**
- `fact_store_order.csv` – Store orders, allocated quantities, stockout flags.
- `fact_shipment.csv` – FC-to-store shipments, carriers, on-time flag.
- `fact_inventory_daily.csv` – Daily on-hand inventory by location and SKU.
- `dim_*.csv` – Product, location, date, carrier dimensions.

**Transformations:**
- All raw data loaded into SQLite via `01_data_cleaning.sql`.
- Aggregated to monthly KPIs by FC, Store, Region via `02_kpi_calculations.sql`.
- Insights extracted (top stockout stores, high-cost lanes, etc.) via `03_insights_analysis.sql`.

**Output Tables:**
- `kpi_summary` – Monthly KPI values by dimension (Region, FC, Store).
- `insights_summary` – Ranked issues (top stockout stores, worst lead times, costliest lanes).

---

## 6. Deliverables & How They Support the Business

### **Power BI Dashboard (3 pages)**

**Page 1 – Executive Summary**
- **Users:** VP Supply Chain, Director of Operations, C-suite
- **Purpose:** "Are we on track this month? Where are the biggest risks?"
- **Visuals:** KPI cards (Fill Rate, Stockout Rate, etc.), trend line (fill rate over time), top issues table.

**Page 2 – FC Performance**
- **Users:** FC Operations Manager, Supply Chain Strategy
- **Purpose:** "Which FCs are underperforming? Where should we focus improvement efforts?"
- **Visuals:** Bar charts by FC for fill rate, stockout rate, lead time.

**Page 3 – Replenishment**
- **Users:** Replenishment Planner, Inventory Analyst
- **Purpose:** "Which stores need reorder point adjustments? Which SKUs are highest risk?"
- **Visuals:** Store-level stockout and inventory days charts; table of problem store/SKU pairs.

### **SQL Scripts (Production-Grade)**
- Fully documented and reproducible.
- Can be scheduled as nightly or weekly ETL jobs.
- Support incremental data loads and historical trending.

---

## 7. Success Metrics

**If recommendations are implemented:**
- Fill Rate improves from ~92% to >95% within 3 months.
- Stockout rate for high-risk stores/SKUs drops by 30–40%.
- Transportation cost per unit reduced by 5–10% through lane consolidation and carrier optimization.
- Days inventory on hand normalized to 15–20 days (balanced across stores).

---

## 8. Next Steps

1. **Validate Insights with Domain Experts** – Confirm findings with FC Managers, Planners, and Logistics teams.
2. **Pilot Changes** – Test reorder point adjustments on 2–3 high-risk stores; measure impact.
3. **Automate Reporting** – Schedule SQL scripts to run daily/weekly; set up alerting for KPI threshold violations.
4. **Iterate & Refine** – Build advanced models (forecasting, optimization) once baseline reporting is production-stable.
