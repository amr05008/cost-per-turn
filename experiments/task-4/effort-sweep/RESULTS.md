# Task 4 · effort sweep — results

**180 new runs · $2.23 · pooled with task 4's 60 into a 240-run, 6-model,
2-effort grid for $4.80 total**

Graded by the same scorer against the same key, both symlinked to the parent.

## The metric was repaired mid-analysis. Read this first.

A blind 12-list spot check on the three models no human had graded —
Haiku, mini, nano — **rejected two runs that scored a mechanically perfect
5/5 recall with zero surplus.** In task 4 that had never happened once in 15.

Both rejected runs had **dropped the owners**:

> `2. unassigned — Send event volume estimates to Marcus — Friday`

That is the note-taker's own commitment, and the notes say so. **An action item
with no owner is a note, not an action item** — and the scorer, which graded the
action and explicitly ignored the owner, could not see it.

**The repaired rule: shippable = recall 5/5 **and** at most one `unassigned`.**

It is post-hoc, so it is held to the standard that implies:

- **The answer key was never touched.** What changed is how the key is
  aggregated into a verdict. Logged in `score.sh` with before/after numbers.
- **Validated on 32 human judgements from two independent sessions** — it
  explains all 6 recall-5/5 verdicts in the spot check *and* still agrees
  **20/20** with task 4's original human pass.
- **It makes results worse, not better** — Opus-low 20/20 → 15/20, Haiku-high
  4/20 → 1/20. Not a flattering rule.
- **Both columns ship.** `perfect` (pre-registered) stays in `scores.csv`
  alongside `shippable` (repaired), so the original metric stays auditable.

Every number below uses the repaired rule, with the pre-registered one shown
beside it.

## The grid

| model | $/M in→out | effort | pre-reg 5/5 | **shippable** | median $ | $/shippable |
| --- | --- | --- | --- | --- | --- | --- |
| Opus 5 | 5 → 25 | high | 20/20 | **19/20** | $0.0578 | $0.062 |
| Opus 5 | | low | 20/20 | 15/20 | $0.0362 | $0.049 |
| Sonnet 5 | 2 → 10 | high | 20/20 | **20/20** | $0.0252 | $0.026 |
| Sonnet 5 | | low | 16/20 | 16/20 | $0.0156 | $0.021 |
| Kimi K3 | 3 → 15 | high | 9/20 | 9/20 | $0.0426 | $0.098 |
| Kimi K3 | | low | 9/20 | 9/20 | $0.0179 | $0.040 |
| Haiku 4.5 | 1 → 5 | high | 4/20 | 1/20 | $0.0112 | $0.224 |
| Haiku 4.5 | | low | 3/20 | **0/20** | $0.0112 | — |
| GPT-5.4-mini | .75 → 4.5 | high | 2/20 | 2/20 | $0.0089 | $0.096 |
| GPT-5.4-mini | | low | 0/20 | **0/20** | $0.0037 | — |
| GPT-5.4-nano | .2 → 1.25 | high | 0/20 | **0/20** | $0.0021 | — |
| GPT-5.4-nano | | low | 1/20 | 1/20 | $0.0014 | $0.028 |

**Sonnet 5 at high effort is the only cell in the grid that never failed.**

## 1. Model tier finally predicted quality — and price is not the axis

This is the first clean tier result in the repo, and it **contradicts
FINDINGS #1** ("model tier never predicted whether the output was usable").

| model | price | shippable @ high |
| --- | --- | --- |
| Opus 5 | 5 → 25 | 19/20 |
| **Kimi K3** | **3 → 15** | **9/20** |
| **Sonnet 5** | **2 → 10** | **20/20** |
| Haiku 4.5 | 1 → 5 | 1/20 |
| GPT-5.4-mini | .75 → 4.5 | 2/20 |
| GPT-5.4-nano | .2 → 1.25 | 0/20 |

**Within the Anthropic family, price tracks capability — with a cliff, not a
slope.** Opus and Sonnet are indistinguishable at the top. Haiku falls off a
ledge to **1/20** — it produced a usable list once in forty runs across both
effort levels. The boundary sits between $2/$10 and $1/$5, and nothing about
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

## 2. Arm O's answer: effort matters, but only for models good enough to use it

**Within-model, high vs low:**

| model | high | low | p (Fisher) | median cost change |
| --- | --- | --- | --- | --- |
| Opus 5 | 19/20 | 15/20 | 0.18 | **−37%** |
| Sonnet 5 | 20/20 | 16/20 | 0.11 | **−38%** |
| Kimi K3 | 9/20 | 9/20 | 1.00 | **−58%** |
| Haiku 4.5 | 1/20 | 0/20 | 1.00 | 0% |
| GPT-5.4-mini | 2/20 | 0/20 | 0.49 | **−58%** |
| GPT-5.4-nano | 0/20 | 1/20 | 1.00 | −33% |

No single model reaches significance at n=20. **But the two models capable of
doing the task at all both lost exactly four runs**, in the same direction, at
the same magnitude. Pooled — same vendor, same thinking-budget mechanism, both
above this task's capability bar:

> **Opus + Sonnet: 39/40 at high effort vs 31/40 at low. p = 0.014.**

**That is a real effect**, and it is the opposite of what the pre-registered
metric said before the spot check repaired it. Under the old rule Opus showed
20/20 → 20/20 and the honest summary was "no measurable effect." The runs Opus
lost at low effort were losing *owners*, which the old metric didn't count.

**The three models below the bar show nothing, because they have nothing to
lose.** Kimi is flat at 9/20, Haiku at ~0, nano at ~0. Effort can't buy a
capability that isn't there.

> **Reasoning effort buys accuracy only where the model is already close to
> succeeding.** Above the bar it's insurance; below it, it's money on fire. That
> makes effort a per-model-and-task knob, not a global setting — and it means
> the cheap-model advice "just turn thinking off" is exactly backwards: the
> models where you'd most want the saving are the ones already failing.

**Cost of that insurance, on this task: 37–38%.** Sonnet at high effort costs
$0.026 per shippable list against $0.021 at low — **24% more for the only
never-fails cell in the grid.**

## 3. The order in which extraction abilities fail

240 runs, and the per-item miss counts sort into a clean ladder:

| item | what it requires | first cell to fail it |
| --- | --- | --- |
| A1, A2 | copy from the explicit next-steps block | **never — 240/240** |
| A5 | notice a commitment buried in pre-call small talk | mini-low, nano |
| A3 | infer the owner from who was speaking | haiku |
| **A4** | **link a stated precondition to a later decision** | **kimi, sonnet-low** |

**A4 is necessary but — after the repair — no longer sufficient.** Under the
pre-registered rule, shippable count equalled A4 count in all twelve cells: the
grid reduced to one binary. The owner check adds a **second gate**, and it bites
in exactly two cells — Opus-low (20 found A4, 15 shippable) and Haiku-high (4
found A4, 1 shippable). Everywhere else, making that one inference still
predicts everything.

So the honest version is two gates, not one: **can it link a precondition to a
decision, and can it hold on to who owes what.** The second only becomes visible
when you either drop the effort or drop the tier.

**My designed difficulty ladder was wrong about A5.** I built it as tier 4, the
hardest, on the theory that burying an item in an opening tangent would defeat
extraction. It came *third* — missed 18 times in 240, all of them by mini-low
and nano, and never once by Opus, Sonnet, Kimi or Haiku.
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
shippable list** — within spitting distance of Sonnet's $0.026 — on the strength
of **1 success in 20 runs.** Haiku at high effort looks *expensive* at $0.224
for the same reason, on 1 success in 20. Both numbers are noise wearing a
decimal point. Any metric that ranks a 5% success rate
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
