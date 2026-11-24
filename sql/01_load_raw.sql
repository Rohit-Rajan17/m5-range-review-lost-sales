-- 01_load_raw.sql   (RECONSTRUCTED - not re-run; see note)
-- Purpose: land the three raw M5 files in Postgres without changing them.
-- Source files (Kaggle M5 Forecasting - Accuracy): sales_train_evaluation.csv, calendar.csv, sell_prices.csv
-- Note: the original load commands were not kept. The table definitions below match the live tables
--       (read from information_schema). The \copy lines are the standard way to load them in psql;
--       file paths are placeholders. Row counts expected after loading are listed so a reload can be checked.
-- Expected: raw_sales_lines 30,491 (1 header + 30,490 items x stores), raw_calendar 1,969, raw_prices 6,841,121.

CREATE TABLE raw_sales_lines (line text);   -- whole CSV lines; split in 02_unpivot_sales_long.sql
CREATE TABLE raw_calendar (
  date date, wm_yr_wk integer, weekday text, wday integer, month integer, year integer, d text,
  event_name_1 text, event_type_1 text, event_name_2 text, event_type_2 text,
  snap_ca integer, snap_tx integer, snap_wi integer);
CREATE TABLE raw_prices (store_id text, item_id text, wm_yr_wk integer, sell_price numeric);

-- Run in psql (not DBeaver's SQL editor):
-- \copy raw_sales_lines FROM '/path/sales_train_evaluation.csv' WITH (FORMAT text, DELIMITER E'\x01')
-- \copy raw_calendar   FROM '/path/calendar.csv'   WITH (FORMAT csv, HEADER true)
-- \copy raw_prices     FROM '/path/sell_prices.csv' WITH (FORMAT csv, HEADER true)

-- Speeds up the price join in 06 and the look-back in 09:
CREATE INDEX IF NOT EXISTS ix_raw_prices ON raw_prices (store_id, item_id, wm_yr_wk);
