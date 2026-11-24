-- 07_range_decisions.sql   (verified)
-- Purpose: keep / cut / protect list. Two versions; the second is the one used in the project.
--
-- range_decision (first rule, units only):
--   protect       top fifth by units in 8+ of the 10 stores
--   cut_candidate bottom fifth by units in 8+ stores AND average 365+ active days
--   review_new    bottom fifth in 8+ stores but fewer than 365 active days (too new to judge)
--   keep          everything else
-- range_decision2 (revised): also protect a product that is in the top fifth by REVENUE in 8+ stores.
--   Reason: a product can sell fewer units but bring in a lot of money.
-- Expected (range_decision2, 1,437 products): protect 252, keep 1,035, cut_candidate 149, review_new 1.
-- The 8-store and 365-day lines are judgement calls; the 365-day line and the 8-store line were not stress-tested
-- beyond the first look (see README, limitations).
-- Verification: both tables matched the original exactly.

CREATE TABLE range_decision AS
SELECT item_id,
       COUNT(*) FILTER (WHERE units_tile = 1) AS stores_top,
       COUNT(*) FILTER (WHERE units_tile = 5) AS stores_bottom,
       AVG(active_days) AS avg_active_days,
       SUM(total_units) AS total_units,
       CASE WHEN COUNT(*) FILTER (WHERE units_tile = 1) >= 8 THEN 'protect'
            WHEN COUNT(*) FILTER (WHERE units_tile = 5) >= 8 AND AVG(active_days) >= 365 THEN 'cut_candidate'
            WHEN COUNT(*) FILTER (WHERE units_tile = 5) >= 8 THEN 'review_new'
            ELSE 'keep' END AS decision
FROM range_tiers
GROUP BY item_id;

CREATE TABLE range_decision2 AS
WITH rev AS (
  SELECT item_id, COUNT(*) FILTER (WHERE rev_tile = 1) AS stores_top_rev
  FROM range_rev_tiers
  GROUP BY item_id)
SELECT d.item_id, d.stores_top, r.stores_top_rev, d.stores_bottom, d.avg_active_days, d.total_units,
       CASE WHEN d.stores_top >= 8 OR r.stores_top_rev >= 8 THEN 'protect'
            WHEN d.stores_bottom >= 8 AND d.avg_active_days >= 365 THEN 'cut_candidate'
            WHEN d.stores_bottom >= 8 THEN 'review_new'
            ELSE 'keep' END AS decision
FROM range_decision d
JOIN rev r ON r.item_id = d.item_id;
