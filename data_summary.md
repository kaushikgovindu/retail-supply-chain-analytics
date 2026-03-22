# Synthetic Data Summary

## DIM_Date
**Shape:** 1096 rows, 7 columns

### Sample Data (First 3 Rows)
|   date_id | full_date           |   year |   quarter |   month | day_of_week   |   is_holiday |
|----------:|:--------------------|-------:|----------:|--------:|:--------------|-------------:|
|  20240101 | 2024-01-01 00:00:00 |   2024 |         1 |       1 | Monday        |            1 |
|  20240102 | 2024-01-02 00:00:00 |   2024 |         1 |       1 | Tuesday       |            0 |
|  20240103 | 2024-01-03 00:00:00 |   2024 |         1 |       1 | Wednesday     |            0 |

## DIM_Product
**Shape:** 500 rows, 6 columns

### Sample Data (First 3 Rows)
|   product_id | sku_code     | product_name                    | category   | sub_category    |   unit_cost |
|-------------:|:-------------|:--------------------------------|:-----------|:----------------|------------:|
|            1 | FUR-CHA-0001 | Staples Chairs Model 1          | Furniture  | Chairs          |       86.27 |
|            2 | FUR-FIL-0002 | Staples Filing Cabinets Model 2 | Furniture  | Filing Cabinets |      405.09 |
|            3 | FUR-DES-0003 | Staples Desks Model 3           | Furniture  | Desks           |     1117.88 |

## DIM_Location
**Shape:** 55 rows, 6 columns

### Sample Data (First 3 Rows)
|   location_id | location_type      | location_name    | city          | province   | region   |
|--------------:|:-------------------|:-----------------|:--------------|:-----------|:---------|
|             1 | Fulfillment Center | Toronto FC       | Toronto       | Ontario    | Eastern  |
|             2 | Fulfillment Center | Mississauga FC   | Mississauga   | Ontario    | Eastern  |
|             3 | Fulfillment Center | Richmond Hill FC | Richmond Hill | Ontario    | Eastern  |

## DIM_Carrier
**Shape:** 4 rows, 3 columns

### Sample Data (First 3 Rows)
|   carrier_id | carrier_name   | service_level   |
|-------------:|:---------------|:----------------|
|            1 | Canada Post    | Standard        |
|            2 | Purolator      | Next Day        |
|            3 | UPS Canada     | 2-Day           |

## FACT_Store_Order
**Shape:** 50000 rows, 9 columns

### Sample Data (First 3 Rows)
|   order_line_id | order_id   |   order_date_id |   store_loc_id |   fc_loc_id |   product_id |   qty_ordered |   qty_allocated |   is_stockout |
|----------------:|:-----------|----------------:|---------------:|------------:|-------------:|--------------:|----------------:|--------------:|
|               1 | ORD-007674 |        20240603 |             15 |           2 |          441 |           396 |             396 |             0 |
|               2 | ORD-006512 |        20260119 |             11 |           4 |            8 |             9 |               9 |             0 |
|               3 | ORD-007452 |        20260124 |             49 |           3 |          300 |           245 |             245 |             0 |

### Basic Descriptive Statistics
|       |   qty_ordered |   qty_allocated |   is_stockout |
|:------|--------------:|----------------:|--------------:|
| count |      50000    |        50000    |       50000   |
| mean  |        148.52 |          133.42 |           0.2 |
| std   |        158.35 |          151.6  |           0.4 |
| min   |          1    |            0    |           0   |
| 25%   |         16    |           13    |           0   |
| 50%   |         51    |           46    |           0   |
| 75%   |        278    |          243    |           0   |
| max   |        500    |          500    |           1   |

## FACT_Shipment
**Shape:** 40000 rows, 10 columns

### Sample Data (First 3 Rows)
|   shipment_line_id |   order_line_id |   ship_date_id |   arrival_date_id |   carrier_id |   qty_shipped |   qty_received |   transport_cost |   is_on_time |   is_perfect_order |
|-------------------:|----------------:|---------------:|------------------:|-------------:|--------------:|---------------:|-----------------:|-------------:|-------------------:|
|                  1 |           47545 |    2.02608e+07 |       2.02608e+07 |            1 |            12 |             12 |            41.55 |            1 |                  1 |
|                  2 |           30148 |    2.02603e+07 |       2.02603e+07 |            4 |           369 |            367 |         10471    |            1 |                  0 |
|                  3 |             864 |    2.02503e+07 |       2.02504e+07 |            4 |             9 |              9 |           325.98 |            1 |                  1 |

### Basic Descriptive Statistics
|       |   qty_shipped |   qty_received |   transport_cost |   is_on_time |   is_perfect_order |
|:------|--------------:|---------------:|-----------------:|-------------:|-------------------:|
| count |      40000    |       40000    |         40000    |     40000    |           40000    |
| mean  |        135.06 |         134.76 |          3515.11 |         0.85 |               0.76 |
| std   |        151.79 |         151.79 |          4856.05 |         0.36 |               0.42 |
| min   |          1    |           0    |             2    |         0    |               0    |
| 25%   |         14    |          14    |           284.72 |         1    |               1    |
| 50%   |         47    |          47    |          1098.28 |         1    |               1    |
| 75%   |        246    |         245    |          5092.52 |         1    |               1    |
| max   |        500    |         500    |         24851.6  |         1    |               1    |

## FACT_Inventory_Daily
**Shape:** 100000 rows, 7 columns

### Sample Data (First 3 Rows)
|   inventory_id |   snapshot_date_id |   location_id |   product_id |   qty_on_hand |   reorder_point |   holding_cost |
|---------------:|-------------------:|--------------:|-------------:|--------------:|----------------:|---------------:|
|              1 |        2.02401e+07 |             1 |            1 |           173 |              23 |          70.83 |
|              2 |        2.02401e+07 |             1 |            2 |           382 |              68 |         262.14 |
|              3 |        2.02401e+07 |             1 |            3 |           124 |              32 |         148.04 |

### Basic Descriptive Statistics
|       |   qty_on_hand |   reorder_point |   holding_cost |
|:------|--------------:|----------------:|---------------:|
| count |     100000    |       100000    |      100000    |
| mean  |        249.42 |           59.97 |         563.02 |
| std   |        144.39 |           23.37 |         566    |
| min   |          0    |           20    |           0    |
| 25%   |        125    |           40    |         143.85 |
| 50%   |        249    |           60    |         369.9  |
| 75%   |        374    |           80    |         795.84 |
| max   |        500    |          100    |        3552.56 |

