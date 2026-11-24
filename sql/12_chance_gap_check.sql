-- 12_chance_gap_check.sql   (verified: run on 24 Nov 2026, results below)
-- Purpose: test whether short zero runs could be chance rather than empty shelves.
-- Reasoning: a product selling about 2 a day has a zero day by chance about 13.5% of the time (Poisson model),
--   so short streaks can be random. A run is called "robust" when the usual daily sales x days empty >= 12 items.
--   The 12-item line is a judgement call, not a proven value.
-- Limits: real sales are clumpier than Poisson, which makes chance streaks more likely. The stricter test also
--   removes some real short stockouts, so the true figure probably lies between the robust and central values.
-- Central case throughout: rate_before >= 2, runs of 3 to 28 days (see 09 and 10).

-- 1. All gaps vs robust gaps.
-- Result: all 61,773 gaps, $3,570,070; robust 33,862 gaps, $2,965,524 (83.1% of the dollars).
SELECT count(*) AS gaps,
       round(sum(x.rate_before * x.run_days * rr.revenue / NULLIF(rr.units_joined, 0))) AS lost_revenue,
       count(*) FILTER (WHERE x.rate_before * x.run_days >= 12) AS robust_gaps,
       round(sum(x.rate_before * x.run_days * rr.revenue / NULLIF(rr.units_joined, 0))
             FILTER (WHERE x.rate_before * x.run_days >= 12)) AS robust_lost_revenue
FROM run_context x
JOIN range_revenue rr ON rr.store_id = x.store_id AND rr.item_id = x.item_id
WHERE x.rate_before >= 2 AND x.run_days <= 28;

-- 2. Gaps by the product's usual daily sales before the run.
-- Result: 2 to under 3 a day 33,012 gaps, $1,100,183; 3 to under 5 a day 16,927, $903,116;
--         5+ a day 11,834, $1,566,770. Total 61,773 gaps.
SELECT CASE WHEN x.rate_before < 3 THEN 'a: 2 to under 3'
            WHEN x.rate_before < 5 THEN 'b: 3 to under 5'
            ELSE 'c: 5+' END AS usual_daily_sales,
       count(*) AS gaps,
       round(sum(x.rate_before * x.run_days * rr.revenue / NULLIF(rr.units_joined, 0))) AS lost_revenue
FROM run_context x
JOIN range_revenue rr ON rr.store_id = x.store_id AND rr.item_id = x.item_id
WHERE x.rate_before >= 2 AND x.run_days <= 28
GROUP BY 1
ORDER BY 1;
