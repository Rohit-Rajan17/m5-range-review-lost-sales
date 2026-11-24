# Data dictionary

## Source (not in this repository)
Kaggle "M5 Forecasting - Accuracy": `sales_train_evaluation.csv` (wide daily sales), `calendar.csv` and `sell_prices.csv`. Foods category only in this project. Loaded as `raw_sales_lines`, `raw_calendar` and `raw_prices` (script 01).

## Tables used for reporting (Power BI star schema, script 11)

**`dim_store`**: one row per store (10)
| Column | Meaning |
|---|---|
| `store_id` | Store code, e.g. CA_1 |
| `state` | CA, TX or WI |

**`dim_product`**: one row per product (1,437)
| Column | Meaning |
|---|---|
| `item_id` | Product code, e.g. FOODS_3_090 |
| `dept_id` | Department: FOODS_1, FOODS_2 or FOODS_3 |
| `decision` | protect, keep, cut_candidate or review_new (see definitions) |
| `stores_top` | Stores where the product is in the top fifth by units |
| `stores_top_rev` | Stores where it is in the top fifth by revenue |
| `stores_bottom` | Stores where it is in the bottom fifth by units |
| `avg_active_days` | Average active trading days across its stores |
| `total_units` | Units sold on active days, all stores |

**`fact_store_product`**: one row per product in a store (14,370)
| Column | Meaning |
|---|---|
| `store_id`, `item_id` | Keys to the two dimensions |
| `active_days` | Active trading days |
| `total_units` | Units sold on active days |
| `units_per_day` | total_units / active_days |
| `revenue` | Units x that week's sell price, US dollars |
| `rate_tile`, `units_tile`, `rev_tile` | Fifth within the store (1 = top) by units per day, total units and revenue |

**`fact_runs`**: one row per zero-sales run of 3 or more days (900,485). Renamed `runs` in Power BI.
| Column | Meaning |
|---|---|
| `store_id`, `item_id` | Keys to the two dimensions |
| `start_date` | First day of the run |
| `run_days` | Length of the run in days |
| `rate_before` | Average daily units on active days in the 28 days before the run |
| `avg_price` | The product's revenue / units in that store, whole period |

## Definitions
- **Row status (script 03):** `active`, `pre_launch` (before the product's first sale in that store), `store_closed` (store total under 5% of its average day), `store_disrupted` (5% to under 30%), `never_sold`. Only active days count.
- **Lost units for a run:** `rate_before` x `run_days`. Lost revenue = lost units x `avg_price`.
- **`rate_before` is a floor**, because it includes the product's own earlier zero days.
- **Central case:** `rate_before` of 2 or more and `run_days` of 28 or less. Longer runs are left out, not trimmed.
- **Range decisions (script 07):** protect = top fifth by units or by revenue in 8 or more of the 10 stores; cut_candidate = bottom fifth by units in 8 or more stores and at least 365 active days on average; review_new = bottom fifth in 8 or more stores but newer than that; keep = everything else.
