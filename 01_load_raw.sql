-- 01_load_raw.sql
-- Loads the three raw M5 files into Postgres, unchanged.
-- I didn't save my original load commands, so this was rebuilt from the live table
-- definitions and hasn't been re-run. File paths are placeholders.
-- Rows after loading: raw_sales_lines 30,491 (incl. header), raw_calendar 1,969,
-- raw_prices 6,841,121.

-- The sales file has 1,947 columns, over Postgres's 1,600 limit, so each line is loaded
-- as one text value and split in 02.
CREATE TABLE raw_sales_lines (line text);
CREATE TABLE raw_calendar (
  date date, wm_yr_wk integer, weekday text, wday integer, month integer, year integer, d text,
  event_name_1 text, event_type_1 text, event_name_2 text, event_type_2 text,
  snap_ca integer, snap_tx integer, snap_wi integer);
CREATE TABLE raw_prices (store_id text, item_id text, wm_yr_wk integer, sell_price numeric);

-- Run these in psql (DBeaver's editor doesn't support \copy):
-- \copy raw_sales_lines FROM '/path/sales_train_evaluation.csv' WITH (FORMAT text, DELIMITER E'\x01')
-- \copy raw_calendar   FROM '/path/calendar.csv'   WITH (FORMAT csv, HEADER true)
-- \copy raw_prices     FROM '/path/sell_prices.csv' WITH (FORMAT csv, HEADER true)

-- Speeds up the price join in 06.
CREATE INDEX IF NOT EXISTS ix_raw_prices ON raw_prices (store_id, item_id, wm_yr_wk);
