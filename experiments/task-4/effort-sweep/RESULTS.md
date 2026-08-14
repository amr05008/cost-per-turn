# Task 4 · effort sweep — results

**180 new runs · $2.23 · pooled with task 4's 60 into a 240-run, 6-model,
2-effort grid for $4.80 total**

Graded by the same scorer against the same key, both symlinked to the parent.

## The grid

| model | $/M in→out | effort | recall | **shippable** | median $ | $/shippable |
| --- | --- | --- | --- | --- | --- | --- |
| Opus 5 | 5 → 25 | high | 5.00 | **20/20** | $0.0578 | $0.059 |
| Opus 5 | | low | 5.00 | **20/20** | $0.0362 | $0.037 |
| Sonnet 5 | 2 → 10 | high | 5.00 | **20/20** | $0.0252 | $0.026 |
| Sonnet 5 | | low | 4.80 | 16/20 | $0.0156 | $0.021 |
| Kimi K3 | 3 → 15 | high | 4.45 | 9/20 | $0.0426 | $0.098 |
| Kimi K3 | | low | 4.45 | 9/20 | $0.0179 | $0.040 |
| Haiku 4.5 | 1 → 5 | high | 3.60 | 4/20 | $0.0112 | $0.056 |
| Haiku 4.5 | | low | 3.75 | 3/20 | $0.0112 | $0.074 |
| GPT-5.4-mini | .75 → 4.5 | high | 4.10 | 2/20 | $0.0089 | $0.096 |
| GPT-5.4-mini | | low | 2.85 | **0/20** | $0.0037 | — |
| GPT-5.4-nano | .2 → 1.25 | high | 3.90 | **0/20** | $0.0021 | — |
| GPT-5.4-nano | | low | 3.10 | 1/20 | $0.0014 | $0.028 |

## 1. Model tier finally predicted quality — and price is not the axis

This is the first clean tier result in the repo, and it **contradicts
FINDINGS #1** ("model tier never predicted whether the output was usable").

| model | price | shippable @ high |
| --- | --- | --- |
| Opus 5 | 5 → 25 | 20/20 |
| **Kimi K3** | **3 → 15** | **9/20** |
| **Sonnet 5** | **2 → 10** | **20/20** |
| Haiku 4.5 | 1 → 5 | 4/20 |
| GPT-5.4-mini | .75 → 4.5 | 2/20 |
| GPT-5.4-nano | .2 → 1.25 | 0/20 |

**Within the Anthropic family, price tracks capability — with a cliff, not a
slope.** Opus and Sonnet are indistinguishable at 20/20. Haiku falls off a
ledge to 4/20. The boundary sits between $2/$10 and $1/$5, and nothing about
the price sheet would tell you where.

**Across families, price predicts nothing.** Kimi K3 costs **50% more per token
than Sonnet 5 and delivers 9/20 against 20/20.** Sort the table by price and the
ordering breaks immediately.

**Why FINDINGS #1 held for three tasks and broke here:** tasks 2 and 3 were
graded on taste and contained no model below Opus's tier. The comparison was
Opus vs Kimi — a 1.7x band, near the top of the ladder, judged subjectively. Run
an objective task across a **20x** band and the effect is unmissable.

The old finding wasn't wrong. It was **under-powered on price range and blunted
by subjective grading**, and it should be restated that way rather than deleted.

## 2. Arm O's answer: effort didn't measurably matter for any model

**Within-model, high vs low — the only legitimate comparison here:**

| model | high | low | p (Fisher) | median cost change |
| --- | --- | --- | --- | --- |
| Opus 5 | 20/20 | 20/20 | 1.00 | **−37%** |
| Sonnet 5 | 20/20 | 16/20 | 0.11 | **−38%** |
| Kimi K3 | 9/20 | 9/20 | 1.00 | **−58%** |
| Haiku 4.5 | 4/20 | 3/20 | 1.00 | 0% |
| GPT-5.4-mini | 2/20 | 0/20 | 0.49 | **−58%** |
| GPT-5.4-nano | 0/20 | 1/20 | 1.00 | −33% |

**Not one model showed a statistically significant effort effect, and turning
effort down cut cost 33–58%.** On this task, high reasoning effort was money
spent on nothing.

**The caveat that keeps this honest: n=20 cannot distinguish "no effect" from "a
20% drop."** Sonnet's 20/20 → 16/20 is p=0.11 — not significant, and also not
nothing. A one-in-five failure rate matters enormously in practice, and this
design can't rule it out. **Do not read the table as "effort is free to turn
off."** Read it as: *the effect, if any, is smaller than 20 runs can resolve,
and the saving is 33–58%.*

**Where effort could plausibly matter is a narrow band.** Opus is comfortably
above the bar for this task and Kimi/Haiku/nano are comfortably below it — in
both regimes effort has nothing to buy. Sonnet is the only model sitting *at*
the threshold, and it is the only one whose point estimate moved. If that
pattern is real, **reasoning effort buys something only when the model is near
the capability threshold for the task** — which would make it a knob you tune
per task-and-model rather than set globally.

## 3. The order in which extraction abilities fail

240 runs, and the per-item miss counts sort into a clean ladder:

| item | what it requires | first cell to fail it |
| --- | --- | --- |
| A1, A2 | copy from the explicit next-steps block | **never — 240/240** |
| A5 | notice a commitment buried in pre-call small talk | mini-low, nano |
| A3 | infer the owner from who was speaking | haiku |
| **A4** | **link a stated precondition to a later decision** | **kimi, sonnet-low** |

**A4 is the whole experiment.** Across all twelve cells, **shippable count
equals A4 count exactly** — every run that made that one inference got
everything else right, and every run that missed it was unusable. A 240-run grid
reduces to a single binary.

**My designed difficulty ladder was wrong about A5.** I built it as tier 4, the
hardest, on the theory that burying an item in an opening tangent would defeat
extraction. It was the *third easiest* — 240/240 for every model down to Haiku.
**Positional burial is not difficulty. Inference is.** Anything that needs two
facts joined across a document is a different order of problem from anything
that needs a document read carefully.

## 4. Cost per shippable result is a trap below some reliability floor

The repo's headline metric picks **Sonnet at low effort, $0.021 per shippable
list — the cheapest cell in the grid.** Sonnet at high costs 24% more, $0.026.

The metric is wrong here, and task 4 already explained why: **a missing action
item is invisible to the person reading the list.** Sonnet-low fails one run in
five and gives no signal which one. Paying 24% more for a rate that never failed
is obviously correct, and cost-per-shippable does not say so.

**The reductio is in the table.** GPT-5.4-nano at low effort scores **$0.028 per
shippable list** — putting it within spitting distance of Sonnet — on the
strength of **1 success in 20 runs.** Any metric that ranks a 5% success rate
alongside a 100% one is measuring the wrong thing.

> **Cost per acceptable result is only meaningful above a reliability floor.
> Report the rate next to it, always, or the ratio will flatter whatever fails
> most often.**

That applies to every headline number in this repo, including the ones already
published in FINDINGS.

## Predictions, scored

**One right, one half-right, three wrong.**

1. **"Sonnet holds at or near 20/20 at low effort."** *Right, narrowly.* 16/20,
   p=0.11 — not significantly different, but the point estimate fell 20% and I'd
   no longer call the thinking "not load-bearing."
2. **"Kimi degrades most."** *Wrong.* Kimi was **identical** at 9/20 both ways.
   It was already failing the only item that discriminates; effort had nothing
   left to take away.
3. **"Opus's surplus drops at low effort while recall holds."** *Half right.*
   Recall held exactly (20/20 → 20/20). Surplus went the other way — **9 → 16**.
   Less deliberation produced *more* junk, not less.
4. **"Haiku lands ≥15/20 at high."** *Badly wrong — it got 4/20.* The biggest
   miss in the project. I substantially overestimated how far down the price
   ladder this capability extends, and that error is the reason the sweep was
   worth running.
5. **"GPT-5.4-mini's effort sensitivity is smaller than Kimi's."** *Wrong.*
   Kimi's was zero; mini went 2/20 → 0/20. Both are noise at this n, so the
   prediction was unfalsifiable as posed — a flaw in the prediction, not the run.

## Method notes

- **Models were verified from the session logs, not the labels.** All 240 runs
  report the model that was supposed to run.
- **Zero format failures.** Every run in all six models, including nano, emitted
  a numbered list.
- **Zero regex misses on the five planted items.** All 45 surplus lines were
  read. The anchor-carrying ones are *duplicates* of an already-credited item —
  runs splitting A1 into "write the scope doc" plus "share it in the shared
  doc." Greedy claiming handled those correctly.
- **Two distractor labels under-flag, and this is a real limitation.** One run
  phrased D4 without the word "procurement" (*"determine next steps if pilot
  clears 500 connected accounts"*), and two runs listed the deferred rate-limit
  line, which is not a named distractor at all — it entered the fixture with the
  smoke-test fix and behaves as a sixth trap. **`recall` and `surplus` are
  unaffected** (both derive from anchors and line counts, not distractor
  labels), so the headline metric stands. **The per-distractor rates in task 4's
  results are floors, not exact counts.**

## Caveats

- **One fixture, and the whole grid rests on one inference.** A4 is the only
  discriminating item, so this is a 240-run measurement of a single capability.
  A different call with three A4-shaped items could reorder everything.
- **`low` vs `high` is two points, not a curve.** `off` and `minimal` were never
  run, and they are where the interesting cliff might be.
- **Cross-vendor comparisons are in dollars, not tokens**, and move with
  `prices.json` (dated 2026-08-01).
- **The shippable rule was validated by a human on 20 lists from three models.**
  Haiku, mini and nano have never been checked against it. Their outputs are
  assumed to follow the same recall→shippable relation, which is an
  extrapolation across two new vendors.
