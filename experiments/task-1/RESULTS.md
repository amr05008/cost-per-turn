# Task 1 — results, regrade, and corrections

**Date:** 2026-08-13 · **Runs:** 14 · **Task:** "analyze the last 30 days of GlutenOrNot PostHog data — top 3 insights, 3 action items" · **Raw record:** `runs.csv`  · **Exports:** `raw/`

Related: `../../protocols/task-1-rerun.md`

## What changed

The original sheet graded 14 of 14 runs ✅ **usable as-is**. A column with no variance can't support "cost per acceptable result" — it just re-ranks on price. Regraded against ground truth queried independently from PostHog project 457245: **2 green, 4 yellow, 8 red.**

Two counts, often conflated — keep them separate when writing this up:

- **8 of 14 recommended the wrong action item** (an explicit client-side size/blur gate): t1-02, 06, 07, 09, 11, 12, 13, 14. These are the reds.
- **11 of 14 mishandled the contamination.** Only t1-01, t1-05 and t1-08 excluded the bad identities before analyzing. Seven more noticed the anomalous cluster and analyzed with it in anyway; four never saw it.

The gap between the two is the 4 yellows: they reasoned from contaminated data and still landed on a defensible action. Right answer, unreliable route — which is exactly what a binary pass/fail column cannot express.

## The discriminator

Every run had to answer the same open engineering question — the `image_kb` fork parked in `plans/ocr-capture-assist-2026-07-18.md`: are OCR failures a **blur/size** problem (ship a client-side size gate) or a **framing** problem (ship aiming guidance, skip the gate)?

It's the right thing to grade on because it's the only claim in all 14 outputs that is objectively checkable, several runs explicitly framed themselves as settling it, and a wrong answer ships the wrong release.

**Ground truth** (`scan`/`scan_failed`, 2026-07-14 → 2026-08-13, OCR path):

| image_kb | ok (all) | fail (all) | fail rate | ok (clean) | fail (clean) | fail rate |
| --- | --- | --- | --- | --- | --- | --- |
| <100 | 3 | 11 | **78.6%** | 3 | 2 | 40.0% |
| 100–200 | 10 | 7 | **41.2%** | 10 | 0 | **0.0%** |
| 200–300 | 18 | 3 | 14.3% | 18 | 1 | 5.3% |
| 300–400 | 35 | 9 | 20.5% | 35 | 4 | 10.3% |
| 400+ | 73 | 5 | 6.4% | 73 | 5 | 6.4% |

"Clean" excludes 5 identities with **zero successes and ≥3 failures** — three geolocated to Cupertino (one per App Store submission: Jul 20, Jul 28, Aug 3), one Atlanta on `platform: unknown`, one unlocated. They produce 23 of the 64 failures in the window.

**Sensitivity to the exclusion rule** — "zero successes and ≥3 failures" is a judgment call, so the same cut under three rules, coarser buckets:

| image_kb | raw | excl. Cupertino only | excl. zero-success set |
| --- | --- | --- | --- |
| <200 KB | 58.1% | 23.5% | 13.3% |
| 200–400 KB | 18.5% | 18.5% | 8.6% |
| 400+ KB | 6.4% | 6.4% | 6.4% |

A mild slope survives the conservative cut, so **the gradient does not vanish and the recommendation is not strictly inverted.** What does not survive is the *magnitude the red runs cited* — the 78–79% sub-100 KB failure rate, and t1-09's "a sub-200 KB gate would have prevented ~18 of 35 failures." Clean, there are **2–4 failures in total below 200 KB.** The specific thresholds recommended (100–200 KB) sit where the real failure count rounds to nothing. Eight of fourteen runs recommended that gate.

**The size argument is also the weaker leg, and the correct call doesn't rest on it.** Size-independent evidence, no exclusions applied:

| | n | ocr_chars = 0 | median chars | median KB |
| --- | --- | --- | --- | --- |
| OCR `scan` | 139 | 0 | 725 | 402 |
| `scan_failed` | 35 | **34** | 0 | 186 |

Blur yields garbled partial text at a normal file size. **34 of 35 failures returned zero characters** — Vision found no text in the frame at all, which is an aiming/framing signature regardless of how the size question resolves. This is what both green runs reasoned from, and it is why "framing, not blur" is the right call even under the most conservative reading of the contamination.

## Results

**Cost per acceptable result** — the headline metric, and it is nothing like cost per run:

| Arm | Runs | Spend | Acceptable | $ / acceptable |
| --- | --- | --- | --- | --- |
| CC · Opus · high · MCP | 3 | $6.24 | 1 | **$6.24** |
| CC · Opus · medium · MCP | 3 | $4.89 | 1 | **$4.89** |
| CC · Opus · high · API key | 2 | $3.52 | 0 | — |
| CC · Opus · medium · API key | 2 | $3.08 | 0 | — |
| pi · Opus | 2 | $2.09 | 0 | — |
| pi · Kimi K3 | 2 | $0.46 | 0 | — |

**$22.28 total spend, 2 acceptable results, $11.14 per acceptable result** — against a median cost per run of $1.66. That gap is the whole argument for the quality column.

**Quality distribution:**

| Arm | Runs |
| --- | --- |
| CC · Opus · high · MCP | ✅ 🔴 🟡 |
| CC · Opus · medium · MCP | 🟡 ✅ 🔴 |
| CC · Opus · high · API key | 🔴 🟡 |
| CC · Opus · medium · API key | 🔴 🟡 |
| pi · Opus | 🔴 🔴 |
| pi · Kimi K3 | 🔴 🔴 |

## The behavior that separates the winners

Both green runs did the same thing, and no red run did it: **they checked whether the population was clean before trusting a correlation in it.**

- t1-01 ran the analysis, got the size gradient, then re-ran it with reviewer and tester traffic stripped and **reversed its own conclusion mid-run** — the only run to visibly change its mind.
- t1-05 opened with the exclusion, then named the trap directly: *"the uncleaned data looks like a slam dunk for blur — that bucket is essentially pure reviewer traffic. It would have sent you down the wrong path."* It also recommended a permanent internal-traffic cohort so the weekly snapshot stops reporting a doubled failure rate.

The near-misses are the instructive part. **Five red/yellow runs spotted the anomalous cluster and still didn't exclude it** — t1-07 identified the Cupertino device as App Review *by name* and left it in the statistics; t1-14 called the Atlanta devices "pollution... worth identifying before it pollutes your rates" and then priced a threshold off the polluted distribution. Noticing was common. Propagating the correction into the analysis was rare.

Which is the actual lesson here, and it isn't about token counts: **the expensive part of the work wasn't querying the data, it was doubting it.**

## Findings worth keeping regardless of grade

Red runs still produced real value; the grade is about the shipping recommendation, not the whole output.

- **t1-13** — the `claude-opus-4-8` deploy on 2026-07-19 lands the same day as 1.4.0, and caution rose 47% → 68% on barcode-with-ingredients, a path with no capture involvement. So part of the "quality got worse" signal is the model getting hedgier, not photos getting worse. No other run found this, and it confounds several other runs' conclusions.
- **t1-08** — a scan with 3 characters of extracted OCR text returned verdict `safe`. Low confidence, but "safe" is the word a celiac acts on. This is a genuine safety bug and the single highest-value line in the batch.
- **t1-08 / t1-10** — `$lib_version` is `posthog-node` on every event; no event carries app version, so 1.4.1's effect is unattributable by construction.
- **Universal, therefore trustworthy** — 62 barcode scans (22%) return `had_ingredient_data: false` and 100% become low-confidence caution; all 15 UPCitemdb hits are in that bucket. Every run found it independently. Consensus across 14 runs is itself a quality signal worth using.

## Corrections applied to the sheet

Four rows were mislabeled on the MCP-vs-API column during transcription:

| Sheet row | Was | Is | Why |
| --- | --- | --- | --- |
| Opus High "MCP Run 2" $1.86 | MCP | **API key** | Only 3 MCP runs exist per effort level; this is `run2-api` |
| Opus Medium "MCP Run 1" $1.88 | MCP | **API key** | Same; this is `run1-api` |
| pi · Kimi K3 Run 2 | MCP | **API key** | pi has no PostHog MCP |
| pi · Opus Run 2 | MCP | **API key** | pi has no PostHog MCP |

pi ships 9 tools (`read, bash, edit, write, web_search, source_check, fetch_content, get_search_content, ask_user_question`) and all four pi runs open with the API-key prompt verbatim. **There are zero pi-MCP runs and there cannot be any** — the pi MCP column should be deleted, not corrected. Costs were all transcribed correctly (verified against the exports to 4 decimal places).

## Columns added

`projects/token-efficiency-runs.csv` is now the raw record — one row per run, derived tables generated from it rather than hand-maintained.

- **`run_id`** — joins a row to its export file. Needed for blind grading.
- **`tool_access`** — replaces the ambiguous MCP/API text buried in the task description.
- **`billing_mode`** — Max (API-equivalent) vs OpenRouter (actual). One footnote in the writeup, not a blocker.
- **`input/output/cache_read/cache_write_tokens`** — populated for all 4 pi runs (extractable from the base64 payload in the HTML export). **Empty for all 10 Claude Code runs** — the terminal `.txt` export carries no usage data and it is not recoverable after the fact. Fix: run future CC cells with `claude -p --output-format json`.
- **`wall_clock_s`** — recovered from CC's "Brewed for 4m 42s" footers and pi's entry timestamps. Range: 118s to 438s, a 3.7x spread. Arm L's $/minute-saved needs this.
- **`accuracy` / `contamination` / `decision`** — the three sub-scores behind the grade, so the grade can be re-weighted without re-reading 14 outputs.
- **`key_finding` / `defect`** — what each run uniquely contributed and what exactly is wrong with it.

## Protocol changes for the next batch

1. **Grade blind, for real.** This regrade was *not* blind — I knew each config. It's defensible because the criterion is objective and checked against independently queried ground truth, but it isn't the guarantee the protocol asked for. Next time: write outputs to `runs/<run_id>.md`, keep `runs/key.csv` closed until grades are in.
2. **Write acceptance criteria before running.** "Pulls accurate data, gives logical suggestion" passed all 14 including the ones that would ship the wrong release. For a repeat of T1 the criterion is now available and specific: *does it reach the correct blur-vs-framing call, and does it check for non-user traffic before trusting a correlation?*
3. **The answer key gets written and stress-tested before the runs, not after.** The first version of this regrade said the contamination "inverts the recommendation." It doesn't — that claim depended on my own choice of exclusion rule (zero-success + ≥3 failures), and a conservative Cupertino-only cut leaves a real slope. The grader had the same degrees of freedom the runs did, and used them the same way: picked the cut that made the finding cleaner. A key derived after seeing the outputs is not independent of them. Derive it first, publish the rule, then grade.
4. **Prefer discriminators that survive every reasonable analyst choice.** `ocr_chars = 0 on 34 of 35 failures` needs no exclusions and no judgment calls; the `image_kb` gradient needs both. The robust one should carry the grade and the fragile one should be a supporting note — not the reverse.
3. **Capture tokens natively.** `claude -p --output-format json` for CC. pi's HTML export is already fine.
4. **Fill the n=3 gaps** — four cells are at n=2 (`high/API`, `medium/API`, `pi·Kimi`, `pi·Opus`).
5. **Record a ground-truth answer key per task.** T1 now has one. It's what made a real quality column possible, and it's reusable for every future rep of this task.

## Not experiment findings — real product issues

These came out of the runs and belong in `glutenornot.com`, not here. Logged so they don't get buried in an experiment writeup:

- **Safety bug (t1-08):** a scan with 3 characters of extracted OCR text returned verdict `safe`. Everything else under 200 chars correctly degraded to caution. Needs a floor: sub-threshold `ocr_chars` can never return `safe`.
- **Reviewer contamination is structural, not a one-off.** Three Cupertino identities, one per App Store submission, each producing 100% OCR failures and zero successes — 14 of 35 OCR failures in the window. `reports/weekly-snapshot/` is reporting a roughly doubled failure rate as a result. Needs a permanent internal-traffic cohort, per t1-05's recommendation.
- **`platform: unknown` cluster** (Atlanta, 4 devices, ~12 failures vs 2 successes) — likely a stale build or a script. Identify before it pollutes further.
- **No app version on any event.** `$lib_version` is `posthog-node` because events ship server-side, so 1.4.1's effect is unattributable by construction and 1.4.2's will be too.

