-- 11_export_tables.sql
-- Four small tables for the Power BI star schema, exported to CSV from DBeaver.
-- Rows: dim_store 10, dim_product 1,437, fact_store_product 14,370, fact_runs 900,485.
-- Checked: all four matched the originals exactly. fact_runs is called "runs" in Power BI.

CREATE TABLE dim_store AS
SELECT DISTINCT store_id, LEFT(store_id, 2) AS state
FROM range_base;

CREATE TABLE dim_product AS
SELECT item_id,
       SPLIT_PART(item_id,'_',1) || '_' || SPLIT_PART(item_id,'_',2) AS dept_id,
       decision, stores_top, stores_top_rev, stores_bottom,
       ROUND(avg_active_days::numeric, 0) AS avg_active_days,
       total_units
FROM range_decision2;

CREATE TABLE fact_store_product AS
SELECT t.store_id, t.item_id, t.active_days, t.total_units,
       ROUND(t.units_per_day::numeric, 3) AS units_per_day,
       ROUND(r.revenue::numeric, 2) AS revenue,
       t.rate_tile, t.units_tile, v.rev_tile
FROM range_tiers t
JOIN range_revenue r   ON r.store_id = t.store_id AND r.item_id = t.item_id
JOIN range_rev_tiers v ON v.store_id = t.store_id AND v.item_id = t.item_id;

CREATE TABLE fact_runs AS
SELECT x.store_id, x.item_id, c.date AS start_date, x.run_days,
       ROUND(x.rate_before::numeric, 3) AS rate_before,
       ROUND((rr.revenue / NULLIF(rr.units_joined, 0))::numeric, 3) AS avg_price
FROM run_context x
JOIN range_revenue rr ON rr.store_id = x.store_id AND rr.item_id = x.item_id
JOIN raw_calendar c   ON c.d = 'd_' || x.start_day;
