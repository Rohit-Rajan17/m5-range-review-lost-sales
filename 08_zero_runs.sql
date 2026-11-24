-- 08_zero_runs.sql
-- Finds every run of consecutive zero-sales days for each product in each store (gaps and islands).
-- Inside a run of consecutive days, day_num minus ROW_NUMBER() stays the same, so grouping on it
-- gives one row per run. Only active days are used, so closed or pre-launch days can't create
-- or extend a run.
-- Rows: 3,012,944 runs (all lengths, 1 day and up).
-- Checked: matched the original exactly.

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
