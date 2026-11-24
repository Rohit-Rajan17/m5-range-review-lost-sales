-- 08_zero_runs.sql   (verified)
-- Purpose: find every run of consecutive zero-sales days per store-product (gaps-and-islands).
-- Trick: day_num minus ROW_NUMBER() stays constant inside a run of consecutive days, so grouping on it finds the runs.
-- Only active days are used, so closures and pre-launch days cannot create or extend a run.
-- Expected: 3,012,944 runs (all lengths, 1 day and up).
-- Verification: matched the original exactly.

CREATE TABLE zero_runs AS
WITH z AS (
  SELECT store_id, item_id, day_num,
         day_num - ROW_NUMBER() OVER (PARTITION BY store_id, item_id ORDER BY day_num) AS grp
  FROM sales_clean
  WHERE row_status = 'active' AND units = 0)
SELECT store_id, item_id, grp,
       MIN(day_num) AS start_day, MAX(day_num) AS end_day, COUNT(*) AS run_days
FROM z
GROUP BY store_id, item_id, grp;
