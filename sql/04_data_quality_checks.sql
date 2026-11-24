-- 04_data_quality_checks.sql
-- Checks run on 23 Oct 2026. Each comment gives the result I got then; not re-run since.

-- 1. Rows: 14,370 store-products x 1,941 days = 27,892,170
SELECT count(*) FROM sales_clean;
-- 2. Missing units: 0
SELECT count(*) FROM sales_clean WHERE units IS NULL;
-- 3. Negative units: 0
SELECT count(*) FROM sales_clean WHERE units < 0;
-- 4. Duplicate store-product-days: 0
SELECT count(*) FROM (SELECT store_id, item_id, day_num FROM sales_clean GROUP BY 1,2,3 HAVING count(*) > 1) x;
-- 5. Missing prices: 0 (of 6,841,121 rows)
SELECT count(*) FROM raw_prices WHERE sell_price IS NULL;
-- 6. Lowest and highest price: 0.01 and 107.32 (all categories, US dollars)
SELECT min(sell_price), max(sell_price) FROM raw_prices;
-- 7. Rows by status (rules in 03): active 21,694,918, pre_launch 6,132,077, store_closed 59,655, store_disrupted 5,520
SELECT row_status, count(*) FROM sales_clean GROUP BY row_status ORDER BY row_status;
-- 8. Still open: 28,729 Foods price rows under $0.50 (lowest $0.01). Affects revenue only.
SELECT count(*) FROM raw_prices WHERE item_id LIKE 'FOODS%' AND sell_price < 0.50;
