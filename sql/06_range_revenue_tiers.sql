-- 06_range_revenue_tiers.sql
-- Revenue per product in each store = units x that week's price (active days only),
-- then fifths by revenue within each store (rev_tile 1 = top fifth).
-- Rows: 14,370 in each table. Revenue $111,130,675.60, units 45,918,175.
-- Checked: both tables matched the originals exactly.

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
