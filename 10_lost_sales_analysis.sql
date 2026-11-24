-- 10_lost_sales_analysis.sql
-- Lost sales for each qualifying run = rate_before x run_days, valued at the product's
-- average price in that store (revenue / units over the whole period).
-- Assumes demand carried on at the pre-run rate. There's no stock data, so this is an estimate.
-- Rebuilt from my workbook definitions. Queries A, B and C matched the workbook on 30 Oct 2026.

-- A. Nine settings: minimum rate (1, 2, 5 a day) x longest run counted (14, 28, 56 days).
-- Lost units:   rate 1: 2,186,162 / 2,742,997 / 3,409,788   rate 2: 1,236,159 / 1,671,305 / 2,200,712
--               rate 5: 603,265 / 900,454 / 1,255,005
-- Lost dollars: rate 1: 5,518,983 / 6,807,093 / 8,292,952   rate 2: 2,640,754 / 3,570,070 / 4,671,845
--               rate 5: 1,007,212 / 1,566,770 / 2,231,177
-- Runs at 28 days: 231,399 / 61,773 / 11,834.
SELECT t.rate_min, c.cap_days,
       count(*) AS runs,
       round(sum(x.rate_before * x.run_days)) AS lost_units,
       round(sum(x.rate_before * x.run_days * rr.revenue / NULLIF(rr.units_joined, 0))) AS lost_revenue
FROM run_context x
JOIN range_revenue rr ON rr.store_id = x.store_id AND rr.item_id = x.item_id
CROSS JOIN (VALUES (1), (2), (5)) AS t(rate_min)
CROSS JOIN (VALUES (14), (28), (56)) AS c(cap_days)
WHERE x.rate_before >= t.rate_min AND x.run_days <= c.cap_days
GROUP BY t.rate_min, c.cap_days
ORDER BY t.rate_min, c.cap_days;

-- B. Central case (2+ a day, runs up to 28 days) by range decision.
-- protect: 252 products, 26,883 runs, 1,105,926 units, $2,191,781
-- keep: 1,035, 34,597, 560,400, $1,358,194
-- cut_candidate: 149, 290, 4,958, $19,957
-- review_new: 1, 3, 20, $138
SELECT d.decision,
       (SELECT count(*) FROM range_decision2 WHERE decision = d.decision) AS products,
       count(*) AS runs,
       round(sum(x.rate_before * x.run_days)) AS lost_units,
       round(sum(x.rate_before * x.run_days * rr.revenue / NULLIF(rr.units_joined, 0))) AS lost_revenue
FROM run_context x
JOIN range_revenue rr ON rr.store_id = x.store_id AND rr.item_id = x.item_id
JOIN range_decision2 d ON d.item_id = x.item_id
WHERE x.rate_before >= 2 AND x.run_days <= 28
GROUP BY d.decision
ORDER BY lost_revenue DESC;

-- C. Central case by store, as a share of each store's revenue.
-- Lost $ and %: CA_3 645,223 3.5% | WI_2 482,056 4.1% | CA_1 434,208 3.2% | WI_3 381,137 3.5%
--   TX_2 359,084 3.0% | CA_2 303,228 3.4% | TX_3 297,925 2.9% | TX_1 258,235 2.8%
--   WI_1 234,242 2.8% | CA_4 174,734 2.4%
-- Runs, same order: 10,140 / 7,393 / 7,316 / 5,575 / 5,748 / 6,441 / 5,033 / 4,745 / 4,985 / 4,397.
WITH lost AS (
  SELECT x.store_id, count(*) AS runs,
         sum(x.rate_before * x.run_days * rr.revenue / NULLIF(rr.units_joined, 0)) AS lost_revenue
  FROM run_context x
  JOIN range_revenue rr ON rr.store_id = x.store_id AND rr.item_id = x.item_id
  WHERE x.rate_before >= 2 AND x.run_days <= 28
  GROUP BY x.store_id),
rev AS (SELECT store_id, sum(revenue) AS store_revenue FROM range_revenue GROUP BY store_id)
SELECT l.store_id, l.runs, round(l.lost_revenue) AS lost_revenue,
       round(100 * l.lost_revenue / r.store_revenue, 1) AS pct_of_store_revenue
FROM lost l JOIN rev r ON r.store_id = l.store_id
ORDER BY pct_of_store_revenue DESC;
