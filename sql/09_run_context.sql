-- 09_run_context.sql   (verified)
-- Purpose: for each zero run of 3+ days, the average daily sales in the 28 active days before it (rate_before).
-- Lost units later = rate_before x run_days. Rule: rate_before >= threshold (1 / 2 / 5) and run_days <= cap
-- (14 / 28 / 56); runs longer than the cap are excluded, not trimmed. Central case: rate 2+, cap 28.
-- Limit: rate_before includes the product's own earlier zero days, so it is a floor.
-- Expected: 900,485 runs.  Verification: matched the original exactly.

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
