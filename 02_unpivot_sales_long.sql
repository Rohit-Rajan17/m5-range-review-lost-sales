-- 02_unpivot_sales_long.sql
-- Turns the wide sales file (one line per store-product, one column per day) into one row
-- per store, product and day. Foods only.
-- unnest WITH ORDINALITY numbers each value. The first 6 are ID columns, so day = position - 6.
-- Run one department at a time: all three in one go didn't finish.
-- Rows after each insert: 4,192,560, then 11,917,740, then 27,892,170 (14,370 x 1,941 days).
-- Checked: rebuilt FOODS_1 and FOODS_2 matched the original table exactly. FOODS_3 was
-- checked on one product (FOODS_3_090 in CA_1).

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
