-- ============================================================================
-- SCENARIO ANALYSIS: Replenishment Optimization Impact
-- ============================================================================
-- Purpose: Simulate the impact of increasing safety stock by 10-20% on:
--   1. Reduction in stockout rate
--   2. Increase in days inventory on hand (holding cost proxy)
--   3. Net impact on working capital vs. service level improvement
--
-- This analysis helps answer: "If we increase safety stock by X%, how much 
-- better will service be, and how much will it cost?"
-- ============================================================================

-- ============================================================================
-- Scenario 1: Current State Baseline
-- ============================================================================
-- Capture baseline KPIs for stores with high stockout rates

SELECT 
    'Baseline' AS scenario,
    store_name,
    ROUND(AVG(stockout_rate_pct), 2) AS avg_stockout_rate_pct,
    ROUND(AVG(days_inventory_on_hand), 2) AS avg_days_on_hand,
    ROUND(AVG(inventory_turnover), 2) AS avg_inventory_turnover,
    COUNT(*) AS num_months_analyzed
FROM kpi_summary
WHERE stockout_rate_pct > 5  -- Focus on stores with elevated stockout rates
GROUP BY store_name
ORDER BY avg_stockout_rate_pct DESC;

-- ============================================================================
-- Scenario 2: Simulate +10% Safety Stock Increase
-- ============================================================================
-- Assumptions:
--   - +10% safety stock reduces stockout rate by ~15-20% (diminishing returns)
--   - Increases days inventory on hand by ~8-10%
--   - Holding cost proxy: 1 day of inventory = 0.5% holding cost

SELECT 
    'Scenario: +10% Safety Stock' AS scenario,
    store_name,
    ROUND(AVG(stockout_rate_pct) * 0.80, 2) AS projected_stockout_rate_pct,  -- 20% reduction
    ROUND(AVG(days_inventory_on_hand) * 1.08, 2) AS projected_days_on_hand,
    ROUND(AVG(inventory_turnover) * 0.93, 2) AS projected_inventory_turnover,  -- Slower turnover due to more inventory
    ROUND(
        (AVG(days_inventory_on_hand) * 1.08 - AVG(days_inventory_on_hand)) * 0.005,
        4
    ) AS incremental_holding_cost_pct,
    'Improvement: Lower stockouts | Cost: Higher holding costs' AS trade_off
FROM kpi_summary
WHERE stockout_rate_pct > 5
GROUP BY store_name
ORDER BY projected_stockout_rate_pct ASC;

-- ============================================================================
-- Scenario 3: Simulate +20% Safety Stock Increase (Aggressive)
-- ============================================================================
-- Assumptions:
--   - +20% safety stock reduces stockout rate by ~30-35%
--   - Increases days inventory on hand by ~15-18%

SELECT 
    'Scenario: +20% Safety Stock (Aggressive)' AS scenario,
    store_name,
    ROUND(AVG(stockout_rate_pct) * 0.65, 2) AS projected_stockout_rate_pct,  -- 35% reduction
    ROUND(AVG(days_inventory_on_hand) * 1.17, 2) AS projected_days_on_hand,
    ROUND(AVG(inventory_turnover) * 0.86, 2) AS projected_inventory_turnover,
    ROUND(
        (AVG(days_inventory_on_hand) * 1.17 - AVG(days_inventory_on_hand)) * 0.005,
        4
    ) AS incremental_holding_cost_pct,
    'Improvement: Minimal stockouts | Cost: Significantly higher holding costs' AS trade_off
FROM kpi_summary
WHERE stockout_rate_pct > 5
GROUP BY store_name
ORDER BY projected_stockout_rate_pct ASC;

-- ============================================================================
-- Scenario 4: Optimal Replenishment Cadence Impact (Daily vs. Weekly)
-- ============================================================================
-- Switching from weekly to daily replenishment can reduce safety stock needs
-- by ~30% while maintaining same service level

SELECT 
    'Scenario: Daily Replenishment (vs. Weekly)' AS scenario,
    store_name,
    ROUND(AVG(stockout_rate_pct) * 0.85, 2) AS projected_stockout_rate_pct,  -- 15% reduction from more frequent orders
    ROUND(AVG(days_inventory_on_hand) * 0.75, 2) AS projected_days_on_hand,  -- 25% reduction in inventory needed
    ROUND(AVG(inventory_turnover) * 1.15, 2) AS projected_inventory_turnover,  -- Better turnover
    ROUND(
        (AVG(days_inventory_on_hand) * 0.75 - AVG(days_inventory_on_hand)) * 0.005,
        4
    ) AS incremental_holding_cost_pct,  -- Negative = cost savings
    'Improvement: Lower inventory + good service | Cost: Slightly higher transportation' AS trade_off
FROM kpi_summary
WHERE stockout_rate_pct > 5
GROUP BY store_name
ORDER BY projected_days_on_hand ASC;
