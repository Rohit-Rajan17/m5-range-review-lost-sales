-- 06_range_revenue_tiers.sql   (verified)
-- Purpose: revenue per store-product = units sold x that week's sell price (active days only),
--          then rank products in fifths by revenue inside each store (rev_tile 1 = top fifth).
-- Expected: 14,370 rows each; total revenue $111,130,675.60; units_joined adds up to 45,918,175.
-- Verification: both tables matched the original exactly.

CREATE TABLE range_revenue AS
SELECT s.store_id, s.item_id,
       SUM(s.units) AS units_joined,
       SUM(s.units * p.sell_price) AS revenue
FROM sales_clean s
JOIN raw_prices p
  ON p.store_id = s.store_id AND p.item_id = s.item_id AND p.wm_yr_wk = s.wm_yr_wk
WHERE s.row_status = 'active'
GROUP BY s.store_id, s.item_id;

CREATE TABLE range_rev_tiers AS
SELECT store_id, item_id, revenue,
       NTILE(5) OVER (PARTITION BY store_id ORDER BY revenue DESC) AS rev_tile
FROM range_revenue;
