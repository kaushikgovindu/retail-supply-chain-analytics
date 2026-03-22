-- 01_data_cleaning.sql
-- This script designs the SQLite database schema, imports the 7 CSV files, 
-- enforces data integrity, and creates convenience views for analysis.
-- Run this script using the SQLite CLI: sqlite3 supply_chain.db < 01_data_cleaning.sql

PRAGMA foreign_keys = ON;

-- ==========================================
-- 1. CREATE TABLES (Star Schema Definition)
-- ==========================================

CREATE TABLE DIM_Date (
    date_id INTEGER PRIMARY KEY,
    full_date DATE,
    year INTEGER,
    quarter INTEGER,
    month INTEGER,
    day_of_week TEXT,
    is_holiday INTEGER
);

CREATE TABLE DIM_Product (
    product_id INTEGER PRIMARY KEY,
    sku_code TEXT,
    product_name TEXT,
    category TEXT,
    sub_category TEXT,
    unit_cost REAL
);

CREATE TABLE DIM_Location (
    location_id INTEGER PRIMARY KEY,
    location_type TEXT,
    location_name TEXT,
    city TEXT,
    province TEXT,
    region TEXT
);

CREATE TABLE DIM_Carrier (
    carrier_id INTEGER PRIMARY KEY,
    carrier_name TEXT,
    service_level TEXT
);

CREATE TABLE FACT_Store_Order (
    order_line_id INTEGER PRIMARY KEY,
    order_id TEXT,
    order_date_id INTEGER,
    store_loc_id INTEGER,
    fc_loc_id INTEGER,
    product_id INTEGER,
    qty_ordered INTEGER,
    qty_allocated INTEGER,
    is_stockout INTEGER,
    FOREIGN KEY(order_date_id) REFERENCES DIM_Date(date_id),
    FOREIGN KEY(store_loc_id) REFERENCES DIM_Location(location_id),
    FOREIGN KEY(fc_loc_id) REFERENCES DIM_Location(location_id),
    FOREIGN KEY(product_id) REFERENCES DIM_Product(product_id)
);

CREATE TABLE FACT_Shipment (
    shipment_line_id INTEGER PRIMARY KEY,
    order_line_id INTEGER,
    ship_date_id INTEGER,
    arrival_date_id INTEGER,
    carrier_id INTEGER,
    qty_shipped INTEGER,
    qty_received INTEGER,
    transport_cost REAL,
    is_on_time INTEGER,
    is_perfect_order INTEGER,
    FOREIGN KEY(order_line_id) REFERENCES FACT_Store_Order(order_line_id),
    FOREIGN KEY(ship_date_id) REFERENCES DIM_Date(date_id),
    FOREIGN KEY(arrival_date_id) REFERENCES DIM_Date(date_id),
    FOREIGN KEY(carrier_id) REFERENCES DIM_Carrier(carrier_id)
);

CREATE TABLE FACT_Inventory_Daily (
    inventory_id INTEGER PRIMARY KEY,
    snapshot_date_id INTEGER,
    location_id INTEGER,
    product_id INTEGER,
    qty_on_hand INTEGER,
    reorder_point INTEGER,
    holding_cost REAL,
    FOREIGN KEY(snapshot_date_id) REFERENCES DIM_Date(date_id),
    FOREIGN KEY(location_id) REFERENCES DIM_Location(location_id),
    FOREIGN KEY(product_id) REFERENCES DIM_Product(product_id)
);

-- ==========================================
-- 2. IMPORT DATA FROM CSV
-- ==========================================
-- Note: Requires sqlite3 shell. The '--skip 1' ignores CSV headers.
.mode csv
.import --skip 1 dim_date.csv DIM_Date
.import --skip 1 dim_product.csv DIM_Product
.import --skip 1 dim_location.csv DIM_Location
.import --skip 1 dim_carrier.csv DIM_Carrier
.import --skip 1 fact_store_order.csv FACT_Store_Order
.import --skip 1 fact_shipment.csv FACT_Shipment
.import --skip 1 fact_inventory_daily.csv FACT_Inventory_Daily

-- ==========================================
-- 3. VALIDATE FOREIGN KEY INTEGRITY
-- ==========================================
-- Returns any orphaned records violating constraints. 
-- Assuming clean synthetic data, this returns no records.
PRAGMA foreign_key_check;

-- ==========================================
-- 4. ADD INDEXES FOR PERFORMANCE
-- ==========================================
CREATE INDEX idx_order_date ON FACT_Store_Order(order_date_id);
CREATE INDEX idx_order_store_loc ON FACT_Store_Order(store_loc_id);
CREATE INDEX idx_order_fc_loc ON FACT_Store_Order(fc_loc_id);
CREATE INDEX idx_order_prod ON FACT_Store_Order(product_id);

CREATE INDEX idx_ship_order_line ON FACT_Shipment(order_line_id);
CREATE INDEX idx_ship_arr_date ON FACT_Shipment(arrival_date_id);

CREATE INDEX idx_inv_loc ON FACT_Inventory_Daily(location_id);
CREATE INDEX idx_inv_prod ON FACT_Inventory_Daily(product_id);
CREATE INDEX idx_inv_date ON FACT_Inventory_Daily(snapshot_date_id);

-- ==========================================
-- 5. CREATE CONVENIENCE VIEWS
-- ==========================================
CREATE VIEW v_store_orders AS
SELECT 
    o.order_line_id, o.order_id, 
    d.full_date AS order_date,
    s.location_name AS store_name,
    fc.location_name AS fc_name,
    p.sku_code, p.product_name, p.category,
    o.qty_ordered, o.qty_allocated, o.is_stockout
FROM FACT_Store_Order o
JOIN DIM_Date d ON o.order_date_id = d.date_id
JOIN DIM_Location s ON o.store_loc_id = s.location_id
JOIN DIM_Location fc ON o.fc_loc_id = fc.location_id
JOIN DIM_Product p ON o.product_id = p.product_id;

CREATE VIEW v_shipments AS
SELECT 
    sh.shipment_line_id, 
    o.order_id,
    sd.full_date AS ship_date,
    ad.full_date AS arrival_date,
    c.carrier_name,
    sh.qty_shipped, sh.transport_cost, sh.is_on_time, sh.is_perfect_order
FROM FACT_Shipment sh
JOIN FACT_Store_Order o ON sh.order_line_id = o.order_line_id
JOIN DIM_Date sd ON sh.ship_date_id = sd.date_id
JOIN DIM_Date ad ON sh.arrival_date_id = ad.date_id
JOIN DIM_Carrier c ON sh.carrier_id = c.carrier_id;

CREATE VIEW v_inventory AS
SELECT 
    i.inventory_id,
    d.full_date AS snapshot_date,
    l.location_name, l.location_type,
    p.sku_code, p.product_name,
    i.qty_on_hand, i.reorder_point, i.holding_cost
FROM FACT_Inventory_Daily i
JOIN DIM_Date d ON i.snapshot_date_id = d.date_id
JOIN DIM_Location l ON i.location_id = l.location_id
JOIN DIM_Product p ON i.product_id = p.product_id;
