# Task 4 — results

**60 runs · $2.57 · mechanical grading against a key committed before run 1,
plus a 20-list blind human pass**

## The headline: recall is the whole game, and precision barely counts

Tasks 2 and 3 tied every arm they compared — 3/5, 3/5, 3/5, then 3/10, 3/10.
Task 4 is the first task in this repo where model tier predicted the outcome.

But the headline changed once a human graded the output, and **the way it
changed is the most useful thing this task produced.**

| arm | spend | recall | mech. perfect | **shippable** | $ / shippable |
| --- | --- | --- | --- | --- | --- |
| pi · Opus 5 | $1.17 | **5.00**/5 | 13/20 | **20/20** | $0.059 |
| pi · Sonnet 5 | $0.51 | **5.00**/5 | **20/20** | **20/20** | **$0.026** |
| pi · Kimi K3 | $0.89 | 4.45/5 | 8/20 | 9/20 | $0.098 |

**The mechanical metric and the human disagreed on 25% of the sample, and every
single disagreement ran the same direction:** runs the scorer failed, the human
would ship. Zero mechanically-perfect runs were rejected.

The reason is that `perfect` weights the two error types equally, and **a human
does not.**

| in the graded sample | shippable | unusable |
| --- | --- | --- |
| **recall 5/5** | **15** | **0** |
| **recall 4/5** | **0** | **5** |
| surplus 0 (no false positives) | 10 | 1 |
| surplus ≥ 1 | 5 | 4 |

**Recall separated shippable from unusable perfectly, 20 for 20. Precision
predicted nothing.** Five lists were graded *"usable but I'd delete the
rev-share item"* — and one list carrying a false positive was still graded a
**favorite**.

**A spurious action item costs a delete keystroke. A missing one costs a dropped
roadmap commitment.** That asymmetry is invisible to any symmetric metric, and
it is the thing to carry out of this task.

### What that does to the model comparison

On the mechanical metric Sonnet beat Opus 20/20 vs 13/20 (Fisher exact,
**p = 0.008**). On the human standard **they tie at 20/20, and only price
separates them** — Sonnet is 2.3x cheaper per shippable list.

Kimi is the only arm that actually loses, and it loses on the axis that matters:
9/20 shippable at $0.098 each, the most expensive per usable result despite the
cheapest median run.

**Caveat on the tie, and it is a real one.** The shippable column extrapolates
the rule *recall 5/5 → shippable* from 20 graded lists to all 60. The rule held
without exception in the sample, but only 8 Opus and 5 Sonnet runs were graded,
and **the maximum surplus ever put in front of a human was one extra item.** The
worst over-lister in the batch — c28, three spurious items — was never sampled.
"One junk line is survivable" is measured; "three is survivable" is not.

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
comprehension failure — **and the human pass says it costs nothing.** Every
Opus run in the sample was shippable, including the ones the scorer failed. Five
were graded *"usable but I'd delete the rev-share item"*; one was a **favorite**
in spite of it.

**Kimi substitutes, and that is the dangerous one.** It missed A4 in 11 of 20
runs — and in **6 of 20 it returned exactly five items: the right count, the
wrong five.** It dropped a real commitment and put the rev-share musing in its
place. A human skimming that list has no signal that anything is missing. The
count looks right, the formatting looks right, and a roadmap commitment has
quietly fallen out of the follow-up email.

**This is the finding that generalises past this task**, and the human pass
confirmed it the hard way: **all five lists graded `unusable` were Kimi runs
that had dropped A4** — including one with no false positive at all, a clean
four-item list that simply left a commitment out. An extraction that is wrong
*and the right length* is invisible without a key. It is exactly what
FINDINGS #6 warned about in a different register: under-detection is
indistinguishable from a pass.

## On this task there was no cheap-vs-good tradeoff at all

**Sonnet 5 was the least expensive model in the batch and also the best.** Not a
compromise pick — the cheapest sticker price of the three ($2/$10 per M tokens
against Opus's $5/$25), the cheapest median run ($0.025), full recall on every
run, and the lowest cost per shippable list at $0.026.

| arm | $/M in→out | median run | $ / shippable |
| --- | --- | --- | --- |
| Sonnet 5 | **2 → 10** | **$0.025** | **$0.026** |
| Kimi K3 | 3 → 15 | $0.043 | $0.098 |
| Opus 5 | 5 → 25 | $0.058 | $0.059 |

**Correction to an earlier draft of this file, which called Kimi "the cheapest
model."** It isn't. **Kimi K3 is priced above Sonnet 5** — 50% more per input
token, 50% more per output token — and its median run cost 69% more. It is
cheaper than *Opus*, which is the only comparison tasks 2 and 3 could make,
because Sonnet wasn't in those batches. The accurate claim is narrower and
still worth having:

> **Kimi cost more per usable result than either Anthropic arm ($0.098 vs $0.059
> and $0.026), while sitting in the middle of the price sheet.** Cheaper per run
> than Opus, more expensive per answer than both.

**This repo has never actually tested a cheap model.** Across four tasks the
"budget" arm has been Kimi K3, which is mid-priced. The entire tier question has
so far been asked across a **2.5x price band**. That is a narrow base for the
claim tasks 2 and 3 rest on, and it is the gap the effort sweep should close.

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
5. **"Mechanical `perfect` and the human verdict disagree on ≥20%."** *Right* —
   **25%, 5 of 20** — but right for a reason the prediction didn't anticipate.
   I expected noise in both directions. Every disagreement went one way: the
   scorer was harsher than the human, always because of a false positive the
   human simply deleted. The prediction was correct and the model behind it was
   wrong.

**Scored across the whole task: one half-right, three wrong, one right-for-the-
wrong-reason.** The two that mattered most — #3 and #4 — were both wrong, and
prediction 2 ("precision is where tier shows up") was not just wrong but
backwards: precision is the axis that turned out *not to matter to anyone*.

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

## The grading metric was wrong, and that is worth as much as the result

Task 4 was built to escape taste, and the mechanical scorer did exactly what it
was designed to do: `recall`, `listed` and `surplus` are reproducible, need no
judgement, and every number in them survived inspection. The scorer was not
inaccurate.

**It was mis-weighted**, and only a human could have revealed that. `perfect`
treats one spurious line and one missing commitment as the same failure. The
person who has to send the follow-up email does not, and the gap between those
two views is 25% of the sample and the entire Opus-vs-Sonnet result.

The lesson is not "mechanical grading doesn't work." It is:

> **A mechanical metric encodes a cost model. Write the cost model down, and
> check it against a human before you let the metric pick a winner.**

Ten runs of human grading, on a stratified sample, cost about fifteen minutes
and overturned the headline of a 60-run batch. That is the cheapest correction
in this project so far — and it is a step that FINDINGS #6 (*"quality judgement
resists automation"*) implies but never states directly: even when the
*measurement* automates cleanly, the *weighting* doesn't.

The honest headline metric for this task is therefore **cost per shippable
result**, where shippable = full recall, precision ignored. On that basis both
Anthropic arms are equivalent and Sonnet is 2.3x cheaper.

## What this earns for the next experiment

The human pass reordered this list. Two candidates that looked strong before it
are now much weaker, and the reason is worth stating: **anything aimed at
reducing over-listing is aimed at a problem nobody has.**

**Weaker than they looked:**

- **Arm O, reasoning effort, framed as a fix for over-inclusion.** Opus's only
  failure mode is listing extra items, and the human deleted them without
  complaint. Cutting effort to suppress a costless error buys nothing.
- **The prompt patch** — *"only include items someone committed to."* Same
  problem: it targets precision. Worth one cheap run to confirm it doesn't
  *damage* recall, not worth a batch.

**Stronger than they looked:**

- **Arm O aimed at recall instead.** The real question is whether effort moves
  A4-type items — the ones requiring two facts to be linked across a document.
  If low effort costs recall, that is a config change with a genuine failure
  attached, and it's the same fixture and rig. This is now the obvious next run.
- **A harder fixture, targeting the one axis that matters.** A4 was the only
  discriminating item out of five, and A5's positional burial did nothing.
  A task-4b built entirely from A4-shaped items — commitments that follow from
  a decision rather than being stated — would discriminate on every item instead
  of one in five, at the same cost per run.
- **Surplus at higher doses.** Every graded list carried at most one spurious
  item. c28 carried three and was never seen. If shippability degrades somewhere
  between one and three, there *is* a precision threshold and this task simply
  never reached it. Ten lists, fifteen minutes.

**The originally-planned task 4b — a fixture with only two real items — is now
more interesting, not less.** If a model reports five items on a document
containing two, that is a recall-shaped error dressed as over-listing: it means
inventing commitments, not merely including weak ones. The human standard says
that would matter.
