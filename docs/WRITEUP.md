# Write-up: range review and lost sales from likely stockouts

## Question
Which products earn their place in the range, store by store, and where are sales probably lost to empty shelves?

## Data
Walmart M5 (Kaggle), Foods category only: 10 stores (4 California, 3 Texas, 3 Wisconsin), 1,437 products, 14,370 store-products, 1,941 days = 27,892,170 daily rows. US data. No stock levels, no costs. Revenue and units, not profit.

## Method
1. **Unpivot and clean.** The raw sales file is wide (one column per day). It is unpivoted to one row per store, product and day, then cleaned: store-closure days, days before a product first sold in a store, and days when a whole store was disrupted are removed, because a zero on those days does not mean an empty shelf.
2. **Range review.** Within each store, products are ranked in fifths by units and by revenue. A product is labelled *protect* (best sellers), *keep* (the middle), *cut candidate* (bottom fifth in 8 or more of the 10 stores, with at least a year of history) or *review* (too new to judge).
3. **Zero runs.** A gaps-and-islands query finds every run of consecutive zero-sales days. Runs of 3 or more days are kept for the estimate.
4. **Lost sales.** For each run: lost units = average daily sales on the active days in the 28 days before the run x run length. Lost revenue = lost units x the product's average price in that store.
5. **Settings.** Only runs after steady selling count. The central case needs 2 or more units a day before the run and counts runs of 3 to 28 days. Runs longer than the cap are left out, not trimmed. Nine settings are tested: a minimum rate of 1, 2 or 5 units a day by a longest run of 14, 28 or 56 days.

## Results (central case: 2 or more units a day, runs of 3 to 28 days)
- 61,773 runs, 1,671,305 lost units, **$3.57M** lost revenue, 3.2% of $111.13M revenue.
- Across the nine settings: **$1.0M to $8.3M** (0.9% to 7.5% of revenue). The minimum-rate threshold matters more than the run cap.

| Longest run (days) | 14 | 28 | 56 |
|---|---|---|---|
| 1+ units a day | $5.52M | $6.81M | $8.29M |
| 2+ units a day | $2.64M | $3.57M | $4.67M |
| 5+ units a day | $1.01M | $1.57M | $2.23M |

- **Chance gaps (script 12).** A product selling about 2 a day has a zero day by chance about 13.5% of the time, so short streaks can be random. Keeping only gaps where usual daily sales x days empty is at least 12 items leaves 33,862 of 61,773 gaps (55%) but $2.97M of $3.57M (83%). Short, low-rate gaps are the likeliest to be chance, and they carry little money. The 12-item line is a judgement call, and the model assumes random sales, which real sales are not.

By product group (products / runs / lost revenue):

| Group | Products | Runs | Lost revenue | Share |
|---|---|---|---|---|
| Protect (best sellers) | 252 | 26,883 | $2,191,781 | 61.4% |
| Keep (everyday) | 1,035 | 34,597 | $1,358,194 | 38.0% |
| Cut candidate (weakest) | 149 | 290 | $19,957 | 0.6% |
| Review (new) | 1 | 3 | $138 | <0.1% |

Part of the concentration in best sellers is built into the method: a fast seller loses more per empty day.

By store (lost revenue as a share of that store's revenue): WI_2 4.1%, CA_3 3.5%, WI_3 3.5%, CA_2 3.4%, CA_1 3.2%, TX_2 3.0%, TX_3 2.9%, TX_1 2.8%, WI_1 2.8%, CA_4 2.4%. The reasons for the differences were not tested.

Top 10 products by estimated lost revenue: $493,602 together, 13.8% of the total.

| Product | Lost revenue |
|---|---|
| FOODS_3_090 | $86,781 |
| FOODS_3_120 | $67,380 |
| FOODS_3_202 | $62,293 |
| FOODS_2_183 | $52,919 |
| FOODS_2_029 | $49,519 |
| FOODS_3_785 | $38,349 |
| FOODS_3_682 | $36,495 |
| FOODS_1_096 | $34,145 |
| FOODS_3_811 | $33,007 |
| FOODS_3_723 | $32,714 |

## Checks
- The tables from scripts 02, 03, 05 to 09 and 11 were rebuilt in a separate schema and compared with the originals in both directions, with zero differences. Scripts 02 and 03 were proved on a subset because the full run was too slow. The queries in script 10 matched the Excel workbook. Script 01 (load) and script 04 (data-quality checks) were not re-run.
- Revenue ($111,130,675.60) and units (45,918,175) were reproduced in Excel.
- Power BI measures were compared with SQL on the 3 x 3 grid. Largest gap $19, from stored decimals (central cell $3,570,066 in Power BI vs $3,570,070 in SQL).

## Limits
See the README. The main ones: no stock data, the rule cannot see slow sellers, the thresholds are judgement calls (the 365-day line, the 28-day look-back and the 3-day minimum run were not tested), the pre-run rate is a floor, one average price per product and store, sales not profit, US data.

## What I would do next
1. Check shelf availability on the 252 best sellers first, where about 61% of the estimated loss sits.
2. Review the 149 weakest sellers before removing any. They may be new or out of stock.
3. Get real stock data to confirm which gaps were true empty shelves.
