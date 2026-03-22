-- 03_insights_analysis.sql
-- This script leverages facts and dimensions to uncover actionable insights.
-- Answers the 6 core analytical questions from project_brief.md.

-- =========================================================================
-- 1. Top 5 stockout stores/products: 
-- Which stores and product categories experience the highest stockout frequency?
-- =========================================================================
SELECT 
    l.location_name AS store_name,
    p.category,
    p.product_name,
    COUNT(o.order_line_id) AS total_orders,
    SUM(o.is_stockout) AS stockout_count,
    ROUND(CAST(SUM(o.is_stockout) AS REAL) / COUNT(o.order_line_id) * 100, 2) AS stockout_rate_pct
FROM FACT_Store_Order o
JOIN DIM_Location l ON o.store_loc_id = l.location_id
JOIN DIM_Product p ON o.product_id = p.product_id
GROUP BY l.location_name, p.category, p.product_name
HAVING total_orders > 10
ORDER BY stockout_count DESC
LIMIT 10;

-- =========================================================================
-- 2. Lead time by FC/region: 
-- How do replenishment lead times vary by Fulfillment Center and store region?
-- =========================================================================
SELECT 
    fc.location_name AS fc_name,
    s.region AS store_region,
    ROUND(AVG(julianday(ad.full_date) - julianday(od.full_date)), 2) AS avg_lead_time_days,
    COUNT(sh.shipment_line_id) AS total_shipments
FROM FACT_Shipment sh
JOIN FACT_Store_Order o ON sh.order_line_id = o.order_line_id
JOIN DIM_Location fc ON o.fc_loc_id = fc.location_id
JOIN DIM_Location s ON o.store_loc_id = s.location_id
JOIN DIM_Date od ON o.order_date_id = od.date_id
JOIN DIM_Date ad ON sh.arrival_date_id = ad.date_id
GROUP BY fc.location_name, s.region
ORDER BY avg_lead_time_days DESC -- Severity: Longest wait times first
LIMIT 10;

-- =========================================================================
-- 3. On-time by carrier: 
-- What is the on-time delivery rate for FC-to-store shipments by carrier and route?
-- =========================================================================
SELECT 
    c.carrier_name,
    c.service_level,
    COUNT(sh.shipment_line_id) AS total_shipments,
    ROUND(AVG(CAST(sh.is_on_time AS REAL)) * 100, 2) AS on_time_delivery_pct
FROM FACT_Shipment sh
JOIN DIM_Carrier c ON sh.carrier_id = c.carrier_id
GROUP BY c.carrier_name, c.service_level
ORDER BY on_time_delivery_pct ASC -- Severity: Worst performance (lowest on-time delivery) first
LIMIT 10;

-- =========================================================================
-- 4. Worst cost-per-unit FC-store lanes: 
-- Which FC-store lanes have the highest transportation cost per unit and lowest fill rates?
-- =========================================================================
SELECT 
    fc.location_name AS fc_name,
    s.location_name AS store_name,
    SUM(sh.qty_shipped) AS total_shipped,
    SUM(sh.transport_cost) AS total_transport_cost,
    ROUND(SUM(sh.transport_cost) / NULLIF(SUM(sh.qty_shipped),0), 2) AS avg_cost_per_unit,
    ROUND(AVG(CAST(o.qty_allocated AS REAL) / NULLIF(o.qty_ordered, 0)) * 100, 2) AS avg_fill_rate_pct
FROM FACT_Shipment sh
JOIN FACT_Store_Order o ON sh.order_line_id = o.order_line_id
JOIN DIM_Location fc ON o.fc_loc_id = fc.location_id
JOIN DIM_Location s ON o.store_loc_id = s.location_id
GROUP BY fc.location_name, s.location_name
ORDER BY avg_cost_per_unit DESC, avg_fill_rate_pct ASC -- Severity: Highest cost and worst fill rate
LIMIT 10;

-- =========================================================================
-- 5. Inventory turnover correlation: 
-- How does inventory turnover correlate with stockouts and holding costs across product categories?
-- =========================================================================
WITH category_metrics AS (
    SELECT 
        p.category,
        SUM(sh.qty_shipped) AS total_shipped,
        AVG(CAST(o.is_stockout AS REAL)) * 100 AS stockout_rate_pct
    FROM FACT_Store_Order o
    JOIN DIM_Product p ON o.product_id = p.product_id
    LEFT JOIN FACT_Shipment sh ON o.order_line_id = sh.order_line_id
    GROUP BY p.category
),
category_inventory AS (
    SELECT 
        p.category,
        AVG(i.qty_on_hand) AS avg_on_hand,
        AVG(i.holding_cost) AS avg_holding_cost
    FROM FACT_Inventory_Daily i
    JOIN DIM_Product p ON i.product_id = p.product_id
    GROUP BY p.category
)
SELECT 
    cm.category,
    ROUND(cm.total_shipped / NULLIF(ci.avg_on_hand, 0), 2) AS inventory_turnover,
    ROUND(cm.stockout_rate_pct, 2) AS stockout_rate_pct,
    ROUND(ci.avg_holding_cost, 2) AS avg_holding_cost
FROM category_metrics cm
JOIN category_inventory ci ON cm.category = ci.category
ORDER BY stockout_rate_pct DESC -- Severity: Highest proportion of stockouts
LIMIT 10;

-- =========================================================================
-- 6. Reorder point recommendations: 
-- Where should reorder points and shipment frequency be adjusted to balance service levels?
-- (Identifies items experiencing persistent stockouts despite theoretically "available" inventory flags)
-- =========================================================================
SELECT 
    l.location_name,
    p.product_name,
    i.reorder_point,
    ROUND(AVG(i.qty_on_hand), 1) AS avg_qty_on_hand,
    COUNT(o.order_line_id) AS total_orders,
    SUM(o.is_stockout) AS stockout_events,
    ROUND(CAST(SUM(o.is_stockout) AS REAL) / NULLIF(COUNT(o.order_line_id),0) * 100, 2) AS stockout_rt_pct
FROM FACT_Inventory_Daily i
JOIN DIM_Location l ON i.location_id = l.location_id
JOIN DIM_Product p ON i.product_id = p.product_id
LEFT JOIN FACT_Store_Order o ON l.location_id = o.store_loc_id AND p.product_id = o.product_id
GROUP BY l.location_name, p.product_name, i.reorder_point
HAVING stockout_events > 0
ORDER BY stockout_rt_pct DESC -- Severity: Most frequent stockouts flagged for urgent Reorder Point adjustment
LIMIT 10;
