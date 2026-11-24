-- 04_data_quality_checks.sql   (checks as recorded on 23 Oct 2026; re-run to confirm)
-- Each query should return the value in the comment. Results were typed into the workbook tab "Day 4 data quality".

-- 1. Row count = 14,370 store-products x 1,941 days = 27,892,170
SELECT count(*) FROM sales_clean;
-- 2. Null units: expect 0
SELECT count(*) FROM sales_clean WHERE units IS NULL;
-- 3. Negative units: expect 0
SELECT count(*) FROM sales_clean WHERE units < 0;
-- 4. Duplicate store-product-days: expect 0
SELECT count(*) FROM (SELECT store_id, item_id, day_num FROM sales_clean GROUP BY 1,2,3 HAVING count(*) > 1) x;
-- 5. Null prices: expect 0 (of 6,841,121 rows)
SELECT count(*) FROM raw_prices WHERE sell_price IS NULL;
-- 6. Lowest and highest price: expect 0.01 and 107.32 (all categories, US dollars)
SELECT min(sell_price), max(sell_price) FROM raw_prices;
-- 7. Rows by status (see 03 for the rule): active 21,694,918; pre_launch 6,132,077; store_closed 59,655; store_disrupted 5,520
SELECT row_status, count(*) FROM sales_clean GROUP BY row_status ORDER BY row_status;
-- 8. Open item, not yet resolved: Foods price rows under $0.50 (28,729 rows, minimum 0.01). Matters for revenue only.
SELECT count(*) FROM raw_prices WHERE item_id LIKE 'FOODS%' AND sell_price < 0.50;
