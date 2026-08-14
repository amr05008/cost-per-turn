# Task 4 — results

**60 runs · $2.57 · graded mechanically against a key committed before run 1**

## The headline: the tie broke, and the middle tier won

Tasks 2 and 3 tied every arm they compared — 3/5, 3/5, 3/5, then 3/10, 3/10.
Task 4 is the first task in this repo where model tier predicted the outcome.

**It did not predict it monotonically.**

| arm | spend | recall | perfect | $ / perfect | median $ |
| --- | --- | --- | --- | --- | --- |
| pi · Opus 5 | $1.17 | **5.00**/5 | 13/20 | $0.090 | $0.058 |
| pi · Sonnet 5 | $0.51 | **5.00**/5 | **20/20** | **$0.026** | $0.025 |
| pi · Kimi K3 | $0.89 | 4.45/5 | 8/20 | $0.111 | $0.043 |

**Sonnet 5 was perfect on all twenty runs** — exactly five action items, the
correct five, no false positives, every time. Against Opus that is 20/20 vs
13/20, **p = 0.008** (Fisher exact, two-tailed). Against Kimi, p < 0.0001.

The frontier model was beaten by the model one tier below it, and cost 3.5x more
per correct answer to lose.

**Opus vs Kimi did not separate** (13/20 vs 8/20, p = 0.20) — but they failed in
completely different ways, and one of those ways is far more dangerous.

## The two failure modes are not interchangeable

Every arm found A1, A2, A3 and A5 on all twenty runs. **Only one item and one
trap did any work.**

| item | tier | opus | sonnet | kimi |
| --- | --- | --- | --- | --- |
| A1 scope doc | stated outright | 20/20 | 20/20 | 20/20 |
| A2 volume estimates | stated outright | 20/20 | 20/20 | 20/20 |
| A3 sandbox | owner implied | 20/20 | 20/20 | 20/20 |
| **A4 `plan.changed`** | **decision that obligates work** | 20/20 | 20/20 | **9/20** |
| A5 Q3 usage numbers | buried in the pre-call tangent | 20/20 | 20/20 | 20/20 |

| trap | opus | sonnet | kimi |
| --- | --- | --- | --- |
| **D1 unowned musing** (rev-share) | **7/20** | 0/20 | **7/20** |
| D2 retracted (co-branded screen) | 1/20 | 0/20 | 0/20 |
| D3 already done (NDA) | 0/20 | 0/20 | 0/20 |
| D4 conditional (procurement) | 1/20 | 0/20 | 0/20 |
| D5 status, not action — **control** | 0/20 | 0/20 | 0/20 |

**Opus over-includes, with its eyes open.** Its nine surplus lines are annotated
with the very reason they don't belong: *"revisit the co-branded onboarding
screen **(parked pending Northwind brand review)** — after the pilot"*, *"loop in
procurement **once the pilot clears 500 connected accounts**"*. It extracted the
nuance correctly and listed the item anyway. That is a disposition, not a
comprehension failure, and a one-line prompt change would probably fix it.

**Kimi substitutes, and that is the dangerous one.** It missed A4 in 11 of 20
runs — and in **6 of 20 it returned exactly five items: the right count, the
wrong five.** It dropped a real commitment and put the rev-share musing in its
place. A human skimming that list has no signal that anything is missing. The
count looks right, the formatting looks right, and a roadmap commitment has
quietly fallen out of the follow-up email.

**This is the finding that generalises past this task.** An extraction that is
wrong *and the right length* is invisible without a key. It is exactly what
FINDINGS #6 warned about in a different register: under-detection is
indistinguishable from a pass.

## The cheapest model was the most expensive per correct answer

$0.111 per perfect extraction for Kimi against $0.090 for Opus, on a task where
Kimi's median run cost 26% less. Sticker price inverted once correctness was
priced in.

**Round-trips were identical — 3 — across all sixty runs.** So unlike task 2
(96 vs 5 round-trips, 12x cost gap), nothing here is explained by turn count.
This is pure token economics on a fixed, small input, which is why the spread is
only 2.3x rather than 12x.

**Kimi wrote zero cache again**, exactly as in task 3, paying full freight on the
input every run while both Anthropic arms wrote ~3.3k cache tokens. Second
independent confirmation of FINDINGS #3.

## Within-arm variance collapsed — and that refines FINDINGS #4

FINDINGS #4 says within-arm variance beats between-arm variance. **On this task
it is decisively the other way round**, and Sonnet's within-arm variance on
correctness was *literally zero*.

| arm | cost spread | listed-items distribution |
| --- | --- | --- |
| opus | 1.4x | 5 ×13, 6 ×6, 8 ×1 |
| sonnet | 1.8x | **5 ×20** |
| kimi | 3.4x | 4 ×5, 5 ×14, 6 ×1 |

Compare task 2's 3.4–4.0x cost spread and quality spanning the entire scale at
fixed config.

This doesn't contradict finding #4 so much as bound it: **variance was never a
property of the models, it was a property of tasks graded on taste.** Give the
task one right answer and a bounded output and the noise mostly disappears. That
is a useful thing to know before designing any future arm — and it means an
objective task buys far more inference per run than a subjective one.

## Predictions, scored

Four were scoreable. **One half-right, three wrong** — which per the repo's own
method note is the informative outcome.

1. **"A1/A2 near 100%; the discriminators will be A4 and A5."** *Half right.*
   A1/A2 were 60/60 and A4 was the only discriminating item. **A5 was not hard at
   all** — 60/60. The tier-4 "buried in a tangent" difficulty I designed did
   nothing; models read the whole document. Positional burial is not a real
   difficulty axis for a 940-word input.
2. **"Precision, not recall, is where tier shows up."** *Wrong* — too narrow.
   Tier showed up on **both** axes, but in different models: Kimi failed on
   recall, Opus failed on precision, Sonnet on neither. A single-axis prediction
   couldn't have been right.
3. **"`listed` varies more within an arm than between arms."** *Wrong*, and
   informatively so — see above. First break of FINDINGS #4 in the repo.
4. **"D2 the retracted item is the most common false positive; D5 near zero."**
   *Wrong on the ranking, right on the control.* D1 — the unowned musing —
   took 14 of the 16 false positives; D2 took one. **Being unowned is a much
   stronger lure than having been retracted.** The near-miss that survives is
   the one that was never anybody's job, not the one that was killed. D5 drew
   0/60, so the control held: false positives are discrimination failing on hard
   cases, not models spraying items at random.
5. **"Mechanical `perfect` and the human verdict disagree on ≥20%."**
   *Pending* — the 20-list blind human pass has not been graded yet.

## Method notes

- **The smoke test paid for itself immediately.** It found a sixth action item
  hiding in the fixture — *"so they can size it properly"* implied Northwind
  would size the rate limit — that neither the author nor the independent reader
  caught. Cost of finding it: $0.15. Fixed in the fixture, key untouched, smoke
  runs discarded. See README.
- **The key and the regexes held.** All 16 surplus lines across 60 runs were
  named distractors; **zero regex misses**, so no widening was needed and none
  was done. Every A4 match was verified by eye to be a genuine `plan.changed`
  line rather than an anchor collision.
- **Greedy line-to-item claiming mattered.** Without it, a fabricated line
  carrying an item's anchor is absorbed into an already-found item and vanishes
  from the false-positive count. The pre-run test suite (240 assertions) caught
  the design; the first smoke batch caught a live instance.

## Caveats

- **One fixture, one call, five items, one difficulty ladder.** The task
  discriminated on exactly *one* of its five items. A different call could
  reorder all of this.
- **Sonnet's 20/20 is a ceiling.** This fixture cannot distinguish Sonnet from
  anything better than Sonnet, and cannot say how much harder a document it
  would survive.
- **`--thinking high` throughout.** Reasoning effort is plausibly the single
  biggest lever on over-listing, and Opus's failure mode is *precisely*
  over-listing. Read Opus's 13/20 as *at high effort*, not in general. This is
  now the most interesting untested variable in the project.
- **Recall is measured by anchor, not by meaning.** Mitigated by reading all 16
  surplus lines and all 49 A4 matches, but it is a real limit of the method.
- **No harness comparison.** All three arms are pi; task 2 found no harness
  effect worth paying for and those runs were spent on reps instead.

## What this earns for the next experiment

**Arm O — reasoning effort — is now the obvious next run**, and this fixture is
its natural home. Opus's only failure mode is over-inclusion; if low effort
removes it, the result is a one-word config change that turns a 13/20 into
something near 20/20 at lower cost. That is the most directly actionable thing
this project has surfaced.

**The prompt-sensitivity question is now sharp too.** Every false positive in
the batch is an item nobody committed to. A single added sentence — *"only
include items someone committed to"* — is a five-minute experiment with a
plausible large effect. Task 2's follow-up showed that fixing a named failure
mode doesn't raise the pass rate because defects relocate; this is a clean
chance to test whether that holds when the failure is a disposition rather than
a defect.
