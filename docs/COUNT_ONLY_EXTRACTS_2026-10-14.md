# Count-only and aggregate-only extracts — KPI 41 and KPI 52 (2026-10-14)

Two KPIs needed data from tables that are never copied to the lake. Both are now fed
by totals computed at the source; no row of either table leaves its database.
**Pending: data-officer confirmation** (actions 2.5 and 5.1 of the KPI unlock plan).

| | KPI 41 — OTP SMS sent | KPI 52 — parking fee paid |
| --- | --- | --- |
| Source table | `sma.Otps` — credential store (CT019), never copied | `parkly.Payments` — classified Red by the parkly team |
| What is read | Only the `AUTO_INCREMENT=N` value in the `CREATE TABLE` line of each nightly dump (`grep -m1`); no data line of `Otps` | One aggregate query inside the local `pg-parkly` copy (restored nightly) |
| What leaves | `day, otp_sent, window_from, window_to, source` | `grain, period, payment_type, success, payments, distinct_cars, paid_amount, suppressed` |
| Never leaves | OTP codes, phone numbers, any row | Payment rows, plates, car ids, amounts per car |
| Small-group rule | Not applicable (one system-wide total per day) | A group with fewer than 5 distinct cars keeps its row but every number is blanked at the source (`suppressed=yes`) |
| Lake table | `bronze_ref.sma_otp_daily` | `bronze_ref.parkly_payment_daily` |
| Built by | `/home/developer/dbbackup/sma_otp_counts.sh` (nightly) | `/home/developer/dbbackup/parkly_payment_counts.sh` (nightly) |
| Schema control | Declared in `jobs/load_reference_csv.py` (`REFERENCES`); an undeclared column fails the load | same |
| MCP exposure | Read only by the fixed KPI query; `run_sql` and `query` cannot reach either table | same |

## Method notes

- **KPI 41.** The app deletes OTP rows after use (2026-10-14: ids 57,966–59,240 spanned,
  63 rows left), so row counts in a snapshot are meaningless. Each OTP takes the next id,
  so the counter difference between two consecutive daily dumps (02:00 Ulaanbaatar) is
  the number of OTPs created that day. A missing dump leaves a gap rather than an
  estimate. History starts 2026-10-10 (the oldest dump still on the sma host).
  2026-10-13 shows 1,287 OTPs against ~310–365 on the three days before — worth a look by
  the sma team (campaign, login problem or SMS abuse).
- **KPI 52.** parkly has no user on a payment; the payer is a car
  (`Payments.inRecord_id` → `inOutHistory.carId`), so the KPI counts distinct cars that
  paid. Each fee appears as a `pending` and a `paid` row, so the KPI counts
  `payment_type = 'paid'` with `success`. It stays **partial** until the parkly team
  confirms whether `split` and `full` also mean a paid fee.

## For the data officer

- [ ] Confirm action 2.5: count-only OTP figure from the dump's id counter.
- [ ] Confirm action 5.1: aggregate-only parking payments with the 5-car rule.
- [ ] Assign purpose references for `sma_otp_daily` and `parkly_payment_daily`.
