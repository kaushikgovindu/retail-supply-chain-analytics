import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import random
import os

np.random.seed(42)
random.seed(42)

OUTPUT_DIR = "c:/Users/rajikrishnamurthy/OneDrive/Desktop/Project/Analystics_Projects"
os.makedirs(OUTPUT_DIR, exist_ok=True)

print("Generating DIM_Date...")
# 1. DIM_Date
start_date = datetime(2024, 1, 1)
date_list = [start_date + timedelta(days=x) for x in range(1096)]
dim_date = pd.DataFrame({'full_date': date_list})
dim_date['date_id'] = dim_date['full_date'].dt.strftime('%Y%m%d').astype(int)
dim_date['year'] = dim_date['full_date'].dt.year
dim_date['quarter'] = dim_date['full_date'].dt.quarter
dim_date['month'] = dim_date['full_date'].dt.month
dim_date['day_of_week'] = dim_date['full_date'].dt.day_name()

# Canadian Holidays approximation
holidays = []
for y in [2024, 2025]:
    holidays.extend([
        f"{y}-01-01", f"{y}-07-01", f"{y}-11-11", f"{y}-12-25", f"{y}-12-26"
    ])
dim_date['is_holiday'] = dim_date['full_date'].dt.strftime('%Y-%m-%d').isin(holidays).astype(int)
dim_date_ordered = dim_date[['date_id', 'full_date', 'year', 'quarter', 'month', 'day_of_week', 'is_holiday']]

print("Generating DIM_Product...")
# 2. DIM_Product
categories = ['Furniture']*100 + ['Technology']*150 + ['Office Supplies']*250
sub_cats = {
    'Furniture': ['Chairs', 'Desks', 'Filing Cabinets', 'Tables'],
    'Technology': ['Monitors', 'Laptops', 'Printers', 'Accessories'],
    'Office Supplies': ['Pens', 'Paper', 'Binders', 'Staplers', 'Notebooks']
}
products = []
for i in range(1, 501):
    cat = categories[i-1]
    subcat = random.choice(sub_cats[cat])
    sku = f"{cat[:3].upper()}-{subcat[:3].upper()}-{i:04d}"
    
    if cat == 'Furniture': cost = round(random.uniform(50, 1500), 2)
    elif cat == 'Technology': cost = round(random.uniform(50, 1500), 2)
    else: cost = round(random.uniform(5, 100), 2)
    
    products.append([i, sku, f"Staples {subcat} Model {i}", cat, subcat, cost])
dim_product = pd.DataFrame(products, columns=['product_id', 'sku_code', 'product_name', 'category', 'sub_category', 'unit_cost'])

print("Generating DIM_Location...")
# 3. DIM_Location
locations = []
fc_cities = [('Toronto', 'Ontario', 'Eastern'), ('Mississauga', 'Ontario', 'Eastern'), ('Richmond Hill', 'Ontario', 'Eastern'), ('Calgary', 'Alberta', 'Western'), ('Montreal', 'Quebec', 'Eastern')]
for i, (city, prov, reg) in enumerate(fc_cities, 1):
    locations.append([i, 'Fulfillment Center', f"{city} FC", city, prov, reg])
store_cities = [('Toronto', 'Ontario', 'Eastern')]*15 + [('Mississauga', 'Ontario', 'Eastern')]*10 + [('Ottawa', 'Ontario', 'Eastern')]*5 + [('Vancouver', 'British Columbia', 'Western')]*10 + [('Calgary', 'Alberta', 'Western')]*5 + [('Montreal', 'Quebec', 'Eastern')]*5
for i, (city, prov, reg) in enumerate(store_cities, 6):
    locations.append([i, 'Store', f"Staples Store {city} #{i}", city, prov, reg])
dim_location = pd.DataFrame(locations, columns=['location_id', 'location_type', 'location_name', 'city', 'province', 'region'])

print("Generating DIM_Carrier...")
# 4. DIM_Carrier
carriers = [
    [1, 'Canada Post', 'Standard'],
    [2, 'Purolator', 'Next Day'],
    [3, 'UPS Canada', '2-Day'],
    [4, 'Internal Fleet', 'Standard LTL']
]
dim_carrier = pd.DataFrame(carriers, columns=['carrier_id', 'carrier_name', 'service_level'])

print("Generating FACT_Store_Order...")
# 5. FACT_Store_Order
store_ids = dim_location[dim_location['location_type'] == 'Store']['location_id'].tolist()
fc_ids = dim_location[dim_location['location_type'] == 'Fulfillment Center']['location_id'].tolist()
product_ids = dim_product['product_id'].tolist()
date_ids = dim_date['date_id'].tolist()

order_lines = []
order_ids = [f"ORD-{i:06d}" for i in range(1, 15001)] 
for i in range(1, 50001):
    order_line_id = i
    order_id = random.choice(order_ids)
    order_date_id = random.choice(date_ids)
    store_loc_id = random.choice(store_ids)
    fc_loc_id = random.choice(fc_ids)
    prod_id = random.choice(product_ids)
    
    cat = dim_product.loc[dim_product['product_id'] == prod_id, 'category'].values[0]
    if cat == 'Office Supplies': qty_ordered = random.randint(50, 500)
    elif cat == 'Furniture': qty_ordered = random.randint(1, 20)
    else: qty_ordered = random.randint(1, 50)
    
    is_stockout = 1 if random.random() < 0.20 else 0
    if is_stockout:
        qty_allocated = random.randint(0, max(0, qty_ordered - 1))
    else:
        qty_allocated = qty_ordered
        
    order_lines.append([order_line_id, order_id, order_date_id, store_loc_id, fc_loc_id, prod_id, qty_ordered, qty_allocated, is_stockout])
fact_store_order = pd.DataFrame(order_lines, columns=['order_line_id', 'order_id', 'order_date_id', 'store_loc_id', 'fc_loc_id', 'product_id', 'qty_ordered', 'qty_allocated', 'is_stockout'])

print("Generating FACT_Shipment...")
# 6. FACT_Shipment
shippable_orders = fact_store_order[fact_store_order['qty_allocated'] > 0]
shipped_orders = shippable_orders.sample(n=min(40000, len(shippable_orders)), random_state=42).copy()

shipments = []
for idx, row in enumerate(shipped_orders.itertuples(), 1):
    shipment_line_id = idx
    order_line_id = row.order_line_id
    
    o_date = datetime.strptime(str(row.order_date_id), '%Y%m%d')
    s_date = o_date + timedelta(days=random.randint(1, 3))
    a_date = s_date + timedelta(days=random.randint(1, 5))
    
    ship_date_id = int(s_date.strftime('%Y%m%d'))
    arrival_date_id = int(a_date.strftime('%Y%m%d'))
    
    carrier_id = random.randint(1, 4)
    qty_shipped = row.qty_allocated
    
    if random.random() < 0.90:
        qty_received = qty_shipped
    else:
        qty_received = max(0, qty_shipped - random.randint(1, 5))
        
    transport_cost = round(random.uniform(2, 50) * qty_shipped, 2)
    is_on_time = 1 if random.random() < 0.85 else 0
    is_perfect = 1 if (is_on_time == 1 and qty_received == qty_shipped) else 0
    
    shipments.append([shipment_line_id, order_line_id, ship_date_id, arrival_date_id, carrier_id, qty_shipped, qty_received, transport_cost, is_on_time, is_perfect])
fact_shipment = pd.DataFrame(shipments, columns=['shipment_line_id', 'order_line_id', 'ship_date_id', 'arrival_date_id', 'carrier_id', 'qty_shipped', 'qty_received', 'transport_cost', 'is_on_time', 'is_perfect_order'])

print("Generating FACT_Inventory_Daily...")
# 7. FACT_Inventory_Daily
top_prods = dim_product['product_id'].head(50).tolist()
loc_ids = dim_location['location_id'].tolist()
snap_dates = dim_date['date_id'].head(37).tolist()

inventory = []
inv_id = 1
for d in snap_dates:
    for loc in loc_ids:
        for p in top_prods:
            if inv_id > 100000: break
            qty_on_hand = random.randint(0, 500)
            reorder_point = random.randint(20, 100)
            cost = dim_product.loc[dim_product['product_id']==p, 'unit_cost'].values[0]
            holding_cost = round(cost * qty_on_hand * random.uniform(0.001, 0.005), 2)
            inventory.append([inv_id, d, loc, p, qty_on_hand, reorder_point, holding_cost])
            inv_id += 1
        if inv_id > 100000: break
    if inv_id > 100000: break
fact_inventory = pd.DataFrame(inventory, columns=['inventory_id', 'snapshot_date_id', 'location_id', 'product_id', 'qty_on_hand', 'reorder_point', 'holding_cost'])

print("Data generation complete. Exporting to CSV...")
dim_date_ordered.to_csv(os.path.join(OUTPUT_DIR, 'dim_date.csv'), index=False)
dim_product.to_csv(os.path.join(OUTPUT_DIR, 'dim_product.csv'), index=False)
dim_location.to_csv(os.path.join(OUTPUT_DIR, 'dim_location.csv'), index=False)
dim_carrier.to_csv(os.path.join(OUTPUT_DIR, 'dim_carrier.csv'), index=False)
fact_store_order.to_csv(os.path.join(OUTPUT_DIR, 'fact_store_order.csv'), index=False)
fact_shipment.to_csv(os.path.join(OUTPUT_DIR, 'fact_shipment.csv'), index=False)
fact_inventory.to_csv(os.path.join(OUTPUT_DIR, 'fact_inventory_daily.csv'), index=False)

print("Writing Summary Markdown...")
with open(os.path.join(OUTPUT_DIR, 'data_summary.md'), 'w') as f:
    f.write("# Synthetic Data Summary\n\n")
    dfs = {
        'DIM_Date': dim_date_ordered, 'DIM_Product': dim_product, 'DIM_Location': dim_location,
        'DIM_Carrier': dim_carrier, 'FACT_Store_Order': fact_store_order,
        'FACT_Shipment': fact_shipment, 'FACT_Inventory_Daily': fact_inventory
    }
    for name, df in dfs.items():
        f.write(f"## {name}\n")
        f.write(f"**Shape:** {df.shape[0]} rows, {df.shape[1]} columns\n\n")
        f.write("### Sample Data (First 3 Rows)\n")
        f.write(df.head(3).to_markdown(index=False))
        f.write("\n\n")
        if name.startswith('FACT'):
            f.write("### Basic Descriptive Statistics\n")
            desc_cols = [c for c in df.columns if c not in ['inventory_id', 'order_id', 'order_line_id', 'shipment_line_id', 'order_date_id', 'ship_date_id', 'arrival_date_id', 'snapshot_date_id', 'store_loc_id', 'fc_loc_id', 'product_id', 'location_id', 'carrier_id']]
            if desc_cols:
                f.write(df[desc_cols].describe().round(2).to_markdown())
            else:
                f.write(df.describe().round(2).to_markdown())
            f.write("\n\n")
print("All outputs saved successfully!")
