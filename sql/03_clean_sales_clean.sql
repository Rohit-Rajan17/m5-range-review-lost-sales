-- 03_clean_sales_clean.sql   (verified)
-- Purpose: separate real trading days from days when a zero does NOT mean "out of stock".
-- Status rules, in this order:
--   never_sold      product never sold in that store
--   pre_launch      day is before the product's first sale in that store (not yet on sale)
--   store_closed    the store's total that day is under 5% of its average day
--   store_disrupted store total is 5% to under 30% of its average day
--   active          everything else: the only rows used for stockout analysis
-- Verification: store_day (19,410), closed_days (60: 52 closed + 8 disrupted) and first_sale (14,370) matched the
--   original tables exactly; sales_clean rebuilt for FOODS_1 (4,192,560 rows) matched the original on counts by
--   status, units, day numbers, week numbers, dates and event names for every store-product.
-- Expected totals for the full table: 27,892,170 rows = active 21,694,918 + pre_launch 6,132,077
--   + store_closed 59,655 + store_disrupted 5,520 + never_sold 0.

CREATE TABLE store_day AS
SELECT store_id, substr(d, 3)::int AS day_num, SUM(units) AS store_units
FROM sales_long
GROUP BY store_id, substr(d, 3)::int;

CREATE TABLE closed_days AS
WITH a AS (
  SELECT store_id, day_num, store_units,
         AVG(store_units) OVER (PARTITION BY store_id) AS avg_units
  FROM store_day)
SELECT store_id, day_num,
       CASE WHEN store_units < 0.05 * avg_units THEN 'closed' ELSE 'disrupted' END AS day_type
FROM a
WHERE store_units < 0.30 * avg_units;

CREATE TABLE first_sale AS
SELECT store_id, item_id, MIN(substr(d, 3)::int) AS first_day
FROM sales_long
WHERE units > 0
GROUP BY store_id, item_id;

CREATE TABLE sales_clean AS
SELECT l.store_id, l.state_id, l.dept_id, l.item_id,
       substr(l.d, 3)::int AS day_num,
       c.date, c.wm_yr_wk, c.weekday, c.event_name_1, l.units,
       CASE WHEN f.first_day IS NULL THEN 'never_sold'
            WHEN substr(l.d, 3)::int < f.first_day THEN 'pre_launch'
            WHEN cd.day_type = 'closed' THEN 'store_closed'
            WHEN cd.day_type = 'disrupted' THEN 'store_disrupted'
            ELSE 'active' END AS row_status
FROM sales_long l
JOIN raw_calendar c ON c.d = l.d
LEFT JOIN first_sale f  ON f.store_id = l.store_id AND f.item_id = l.item_id
LEFT JOIN closed_days cd ON cd.store_id = l.store_id AND cd.day_num = substr(l.d, 3)::int;

CREATE INDEX IF NOT EXISTS ix_sales_clean ON sales_clean (store_id, item_id, day_num);
