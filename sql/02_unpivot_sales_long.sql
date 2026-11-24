-- 02_unpivot_sales_long.sql   (verified)
-- Purpose: turn the wide file (one line per store-product, 1,941 day columns) into one row per store-product-day,
--          Foods category only (FOODS_1, FOODS_2, FOODS_3).
-- Line layout: id,item_id,dept_id,cat_id,store_id,state_id,d_1..d_1941  -> array positions 1..6, then days.
-- unnest ... WITH ORDINALITY numbers the day values; ordinal - 6 gives the day number.
-- Run one department at a time: each takes minutes; all three in one go took too long and did not finish.
-- Expected rows after each: FOODS_1 4,192,560; then 11,917,740; then 27,892,170 (14,370 store-products x 1,941 days).
-- Verification: rebuilt FOODS_1 + FOODS_2 matched the original table exactly (counts, unit totals, day-weighted totals
--               for all 6,140 store-products); one FOODS_3 product (FOODS_3_090 in CA_1) matched exactly.

CREATE TABLE sales_long
  (item_id text, dept_id text, store_id text, state_id text, d text, units integer);

INSERT INTO sales_long
SELECT s.f[2], s.f[3], s.f[5], s.f[6], 'd_' || (t.o - 6), btrim(t.u, E' \r')::int
FROM (SELECT string_to_array(line, ',') AS f FROM raw_sales_lines WHERE line LIKE 'FOODS_1%') s
CROSS JOIN LATERAL unnest(s.f) WITH ORDINALITY AS t(u, o)
WHERE t.o > 6;

INSERT INTO sales_long
SELECT s.f[2], s.f[3], s.f[5], s.f[6], 'd_' || (t.o - 6), btrim(t.u, E' \r')::int
FROM (SELECT string_to_array(line, ',') AS f FROM raw_sales_lines WHERE line LIKE 'FOODS_2%') s
CROSS JOIN LATERAL unnest(s.f) WITH ORDINALITY AS t(u, o)
WHERE t.o > 6;

INSERT INTO sales_long
SELECT s.f[2], s.f[3], s.f[5], s.f[6], 'd_' || (t.o - 6), btrim(t.u, E' \r')::int
FROM (SELECT string_to_array(line, ',') AS f FROM raw_sales_lines WHERE line LIKE 'FOODS_3%') s
CROSS JOIN LATERAL unnest(s.f) WITH ORDINALITY AS t(u, o)
WHERE t.o > 6;
