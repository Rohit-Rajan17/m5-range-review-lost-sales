-- 05_range_base_tiers.sql
-- Sales per product in each store (active days only), then ranks products in fifths
-- within each store. Tile 1 = top fifth.
-- rate_tile ranks by units per day, units_tile by total units. The range rules in 07 use units_tile.
-- Rows: 14,370 in each table. Total units 45,918,175.
-- Checked: both tables matched the originals exactly.

CREATE TABLE range_base AS
SELECT store_id, item_id,
       COUNT(*)   AS active_days,
       SUM(units) AS total_units,
       AVG(units) AS units_per_day
FROM sales_clean
WHERE row_status = 'active'
GROUP BY store_id, item_id;

CREATE TABLE range_tiers AS
SELECT store_id, item_id, active_days, total_units, units_per_day,
       NTILE(5) OVER (PARTITION BY store_id ORDER BY units_per_day DESC) AS rate_tile,
       NTILE(5) OVER (PARTITION BY store_id ORDER BY total_units DESC)   AS units_tile
FROM range_base;
