-- 05_range_base_tiers.sql   (verified)
-- Purpose: per store-product, how much it sold on active days, then rank products inside each store in fifths.
-- range_base: active days, total units, units per day (active days only).
-- range_tiers: tile 1 = top fifth, tile 5 = bottom fifth, within each store; by units per day and by total units.
--   The keep / cut / protect rule uses units_tile.
-- Expected: 14,370 rows each; sum(total_units) = 45,918,175.
-- Verification: both tables matched the original exactly (no tie differences).

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
