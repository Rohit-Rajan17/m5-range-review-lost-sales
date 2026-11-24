-- 09_run_context.sql
-- For each zero run of 3+ days: average daily units on the active days in the 28 days
-- before it (rate_before). It includes the product's own earlier zero days, so it's a floor.
-- Used in 10: lost units = rate_before x run_days.
-- Rows: 900,485 runs.
-- Checked: matched the original exactly.

CREATE TABLE run_context AS
SELECT r.store_id, r.item_id, r.start_day, r.end_day, r.run_days,
       AVG(s.units) AS rate_before
FROM zero_runs r
LEFT JOIN sales_clean s
  ON s.store_id = r.store_id AND s.item_id = r.item_id
 AND s.day_num BETWEEN r.start_day - 28 AND r.start_day - 1
 AND s.row_status = 'active'
WHERE r.run_days >= 3
GROUP BY r.store_id, r.item_id, r.start_day, r.end_day, r.run_days;
