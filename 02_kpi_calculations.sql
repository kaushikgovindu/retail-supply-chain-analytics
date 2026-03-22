-- 02_kpi_calculations.sql
-- This script calculates the 8 core Key Performance Indicators (KPIs) requested.
-- It aggregates metrics efficiently using CTEs and outputs a unified `kpi_summary` view/table.

DROP VIEW IF EXISTS kpi_summary;

CREATE VIEW kpi_summary AS
WITH monthly_orders AS (
    -- First CTE aggregates facts from orders and shipment interactions grouped by Month and Location
    SELECT 
        strftime('%Y-%m', ord_d.full_date) AS reporting_month,
        s.region AS store_region,
        s.location_name AS store_name,
        fc.location_id AS fc_loc_id,
        fc.location_name AS fc_name,
        
        -- Calculated Metrics
        AVG(CAST(o.qty_allocated AS REAL) / NULLIF(o.qty_ordered, 0)) AS fill_rate,
        AVG(CAST(o.is_stockout AS REAL)) AS stockout_rate,
        SUM(sh.qty_shipped) AS total_qty_shipped,
        SUM(sh.transport_cost) AS total_transport_cost,
        AVG(CAST(sh.is_on_time AS REAL)) AS on_time_rate,
        AVG(CAST(sh.is_perfect_order AS REAL)) AS perfect_order_rate,
        
        -- Lead time derived via Julian Day calculation (differences between dates in float days)
        AVG(julianday(arr_d.full_date) - julianday(ord_d.full_date)) AS lead_time_days
        
    FROM FACT_Store_Order o
    JOIN DIM_Location s ON o.store_loc_id = s.location_id
    JOIN DIM_Location fc ON o.fc_loc_id = fc.location_id
    JOIN DIM_Date ord_d ON o.order_date_id = ord_d.date_id
    LEFT JOIN FACT_Shipment sh ON o.order_line_id = sh.order_line_id
    LEFT JOIN DIM_Date arr_d ON sh.arrival_date_id = arr_d.date_id
    GROUP BY 
        reporting_month,
        s.region,
        s.location_name,
        fc.location_id,
        fc.location_name
),
monthly_inventory AS (
    -- Second CTE calculates average inventory levels per location per month
    SELECT 
        strftime('%Y-%m', d.full_date) AS reporting_month,
        i.location_id,
        AVG(i.qty_on_hand) AS avg_qty_on_hand
    FROM FACT_Inventory_Daily i
    JOIN DIM_Date d ON i.snapshot_date_id = d.date_id
    GROUP BY reporting_month, i.location_id
)
-- Final Output ties orders, shipments, and inventory metrics together
SELECT 
    mo.reporting_month,
    mo.store_region,
    mo.store_name,
    mo.fc_name,
    
    -- 1. Fill Rate (%) 
    ROUND(mo.fill_rate * 100, 2) AS fill_rate_pct,
    
    -- 2. Stockout Rate (%) 
    ROUND(mo.stockout_rate * 100, 2) AS stockout_rate_pct,
    
    -- 3. On-Time Delivery (%) 
    ROUND(mo.on_time_rate * 100, 2) AS on_time_delivery_pct,
    
    -- 4. Inventory Turnover (Shipped Output / Avg On-Hand at FC)
    ROUND(mo.total_qty_shipped / NULLIF(mi.avg_qty_on_hand, 0), 2) AS inventory_turnover,
    
    -- 5. Replenishment Lead Time (Days)
    ROUND(mo.lead_time_days, 2) AS avg_lead_time_days,
    
    -- 6. Transportation Cost per Unit
    ROUND(mo.total_transport_cost / NULLIF(mo.total_qty_shipped, 0), 2) AS transport_cost_per_unit,
    
    -- 7. Perfect Order Rate (%)
    ROUND(mo.perfect_order_rate * 100, 2) AS perfect_order_pct,
    
    -- 8. Days Inventory on Hand (Avg On-Hand / Estimated Daily Sales via Monthly Shipments)
    ROUND(mi.avg_qty_on_hand / NULLIF(mo.total_qty_shipped / 30.0, 0), 1) AS days_inventory_on_hand

FROM monthly_orders mo
LEFT JOIN monthly_inventory mi 
    ON mo.fc_loc_id = mi.location_id 
    AND mo.reporting_month = mi.reporting_month;
