# What 314 runs across four tasks actually showed

**2026-08-14 · 294 agent sessions · $45.71 total** · *+20 local runs at $0.00 on 2026-08-16 (4c below)*

| task | shape | runs | spend |
| --- | --- | --- | --- |
| 1 · analyse 30 days of product analytics | open-ended, live data | 14 | $22.28 |
| 2 · turn a doc into a slide deck | bounded generation | 20 | $15.89 |
| 3 · turn a commit log into release notes | compression + audience judgement | 20 | $2.74 |
| 4 · pull action items out of call notes | **objective, checkable answer** | 60 | $2.57 |
| 4b · effort sweep, 6 models × 2 levels | same fixture, price ladder | 180 | $2.23 |
| 4c · local model — Muse Glimmer 30B on an M1 Pro | same fixture, free but paid in wall-clock | 20 | $0.00 |

Task 1 is a pilot, not a valid comparison — see `task-1/RESULTS.md` for why.
Tasks 2, 3 and 4 are clean.

**Task 4 changed several conclusions that tasks 1–3 had settled**, because it was
the first task with a right answer instead of a taste judgement, and the first to
span a real price range. Where a finding moved, the old version is stated too —
being able to see *why* an early result was wrong is worth more than a document
that only shows the current answer.

---

## The three findings that matter most

### 1. Two human passes, twenty minutes each, each overturned a mechanical headline

This is the most important thing in the repo and it isn't about models.

Task 4 was built specifically to escape taste: five planted action items, grading
by `diff`, no judgement in the loop. The scorer worked — every number it produced
survived inspection, zero regex misses across 240 runs.

**It was mis-weighted twice, and only a human found it both times.**

| pass | what it cost | what it overturned |
| --- | --- | --- |
| Task 4, 20 lists | ~15 min | `perfect` counted a spurious item and a missing one as equal failures. **A human doesn't.** Killed the "Sonnet beats Opus" headline. |
| Sweep, 12 lists | ~10 min | A 5/5 list that drops *owners* isn't shippable. **Reversed arm O** — from "effort doesn't matter" to p=0.014 that it does. |

> **A mechanical metric encodes a cost model. The measurement automates; the
> weighting does not. Check the weighting against a human before you let the
> metric pick a winner.**

Both repairs made results *worse* — Opus-low fell 20/20 → 15/20, Haiku-high 4/20
→ 1/20 — which is the test of whether a post-hoc change is honest. Neither
touched the answer key; both changed only how the key aggregates into a verdict,
and both were validated against the human verdicts they didn't come from. The
final rule agrees with **32/32** human judgements across two independent sessions.

### 2. A false negative and a false positive are not the same failure

The task-4 human pass separated shippable from unusable **20 for 20 on recall
alone. Precision predicted nothing.** Five lists were graded *"usable but I'd
delete the rev-share item."* One list carrying a false positive was still a
**favorite**.

> **A spurious action item costs a delete keystroke. A missing one costs a
> dropped commitment — and it is invisible.**

The dangerous case is concrete: **in 6 of 20 runs Kimi returned exactly five
items — the right count, the wrong five.** It dropped a real commitment and put
an unowned musing in its place. Nothing in that output tells a reader anything is
missing. Every list graded `unusable` in the whole project was one that had left
something out.

This is FINDINGS #6 in a sharper register: under-detection is indistinguishable
from a pass, and any symmetric metric will hide it.

### 3. Model tier does predict quality — the old finding was under-powered

**Superseded:** *"Model tier never predicted whether the output was usable."*
That held across five arm comparisons on tasks 2 and 3, and it was wrong.

Shippable rate at high effort, one fixture, n=20 per cell:

| model | $/M in→out | shippable |
| --- | --- | --- |
| Opus 5 | 5 → 25 | 19/20 |
| **Kimi K3** | **3 → 15** | **9/20** |
| **Sonnet 5** | **2 → 10** | **20/20** |
| Haiku 4.5 | 1 → 5 | 1/20 |
| GPT-5.4-mini | .75 → 4.5 | 2/20 |
| GPT-5.4-nano | .2 → 1.25 | 0/20 |

**Why the old finding held for three tasks:** those tasks were graded on taste and
contained no model below Opus's tier. The comparison was Opus vs Kimi — a **1.7x
band near the top of the ladder, judged subjectively.** Widen it to 20x and grade
objectively and the effect is unmissable.

**Within a family, price tracks capability — as a cliff, not a slope.** Opus and
Sonnet are indistinguishable. Haiku falls off a ledge between $2/$10 and $1/$5:
one usable list in forty runs. Nothing on the price sheet marks where that edge is.

**Across families, price predicts nothing.** Kimi K3 costs **50% more per token
than Sonnet 5 and delivers 9/20 against 20/20.** Sort that table by price and the
ordering breaks immediately.

**And this repo spent four tasks calling Kimi "the cheap model."** It isn't —
it's mid-priced, above Sonnet. No genuinely cheap model was tested here until
task 4b.

---

**Added 2026-08-16 — the local row.** A 30B open model on a laptop (Muse Glimmer,
Ollama MLX, 2021 M1 Pro / 32 GB) went 0/20 shippable at $0.00 and ~7 min per
run — below the cliff, on Haiku's side. But it failed *unlike* anything else in
the grid: every run listed the same three items, all correct, zero surplus; it
saw the two implied items in its reasoning each time and rejected them as "offer,
not commitment." Precise and capped, not noisy. See
[`task-4/local/RESULTS.md`](task-4/local/RESULTS.md).

## What holds, with boundaries now attached

### 4. Cost is driven by round-trips — when round-trips vary at all

**Holds, and now has a boundary.** The same model pair was 12x apart on task 2 and
2.1x on task 3.

| task | Opus round-trips | Kimi round-trips | cost ratio |
| --- | --- | --- | --- |
| 2 (deck) | 96 | 5 | 12x |
| 3 (notes) | 8 | 6 | 2.1x |
| 4 (action items) | 3 | 3 | 1.4x |

Task 4 pins the other end: across all 240 runs, **216 took exactly 3 round-trips**
and the maximum anywhere was 8 — the task is too bounded for turn count to move.
Cost then falls back to pure token economics. So the rule is conditional, not
universal — *when turn count is free to vary it dominates; when the task pins it,
price and caching are what's left.*

"Switch to a cheaper model to save money" is still advice about turn count
wearing a disguise, on any task where turn count is free to move.

### 5. Caching behaviour beats sticker price

**Holds, independently reconfirmed.** Kimi wrote **zero** cache tokens on task 3
and again on task 4, paying full freight on the input every run, while the
Anthropic arms wrote a cache once and read it at ~10% of input price. On task 3
that was enough to eat most of Kimi's sticker advantage.

### 6. Within-arm variance beats between-arm variance — on taste tasks only

**Bounded by task 4.** At fixed config on task 2, cost spread 3.4–4.0x and quality
spanned the whole scale. On task 4, **Sonnet's within-arm variance was literally
zero** — 20 runs, 20 identical verdicts — while between-arm variance ran from
20/20 to 0/20.

> **Variance was never a property of the models. It was a property of tasks graded
> on taste.** Give a task one right answer and a bounded output and the noise
> mostly disappears.

Practical consequence: **an objective task buys far more inference per dollar.**
n=5 resolves almost nothing on a subjective task; n=20 on an objective one
resolved a 20x effect for $2.23.

### 7. Cost per acceptable result — but only above a reliability floor

**Holds, with a caveat that invalidates several tempting numbers.** Cost per run
and cost per *usable* run were ~7x apart on task 1.

But the metric breaks at low success rates. In the sweep, **GPT-5.4-nano scores
$0.028 per shippable list — next to Sonnet's $0.026 — on one success in twenty.**
Haiku looks *expensive* at $0.224 for the mirror-image reason.

> **Always print the success rate beside the ratio.** A cost-per-acceptable figure
> computed on a handful of successes is noise wearing a decimal point.

### 8. Quality judgement resists automation; structural checks don't

**Holds, refined.** Ten attempts across tasks 2 and 3 to mechanise "is this good"
all under-detected. Task 4 shows the split precisely: **recall, item counts and
named-entity checks automate perfectly** — 240 runs, zero regex misses. What
didn't automate was deciding *what the numbers should weigh* (finding 1).

Write checkers that over-flag and hand a human the call. Task 4's scorer prints
every unclaimed line rather than judging it, and greedy line-to-item claiming
exists so that a fabricated line carrying a real anchor surfaces instead of being
absorbed into a credited item.

### 9. Fixing a named failure mode doesn't raise the pass rate

**Holds; untested since task 2.** One added sentence eliminated the speaker-notes
leak completely (2/5 → 0/5) and the pass rate stayed at exactly 3/5, because two
different mechanical failures appeared instead. The cheap model has a *rate* of
defects, not a nameable bug.

### 10. A benchmark on a live system has a half-life

**Holds, and task 4 is the proof of the alternative.** Task 1's trap was destroyed
within a day of acting on it. Tasks 2, 3 and 4 ship their fixtures, and task 4's
was re-run 240 times across two batches weeks apart with byte-identical input.

---

## New from task 4

### 11. Effort buys accuracy only near the capability threshold

Six models at high vs low reasoning effort. No single model reaches significance
at n=20 — but the two models capable of doing the task at all **both lost exactly
four runs**, same direction, same magnitude. Pooled (same vendor, same thinking
mechanism, both above the bar):

> **Opus + Sonnet: 39/40 at high vs 31/40 at low. p = 0.014.**

The models below the bar show nothing, because they have nothing to lose — Kimi
flat at 9/20, Haiku ~0, nano ~0.

> **Above the capability bar, effort is insurance costing 37–38%. Below it, it's
> money on fire.** Which makes "turn thinking down to save money" backwards: the
> models where you'd most want the saving are the ones already failing.

### 12. Inference is difficulty; position isn't

Five planted items, 240 runs, and they fail in a fixed order:

| item | what it demands | first to fail it |
| --- | --- | --- |
| stated outright, in a summary block | copying | **never — 240/240** |
| buried in pre-call small talk | reading it all | mini-low, nano |
| owner implied by who was speaking | attribution | haiku |
| **obligation implied by a decision** | **linking two moments** | **kimi, sonnet-low** |

I designed the buried item as the hardest tier. It came third. **Positional
burial is not difficulty — anything requiring two facts joined across a document
is a different order of problem from anything requiring a document read
carefully.** If you want to know whether a model can do your extraction task,
test the inference, not the haystack.

### 13. Owner attribution is a second, separate gate

Discovered only because a human looked. Weaker models — and stronger ones at
reduced effort — produce lists with the right *actions* and no *owners*:
`unassigned — send event volume estimates to Marcus`, where the notes plainly say
whose job that is. Correct content, useless artifact.

---

## Predictions: the running record

**16 predictions on record across four tasks; roughly 6 right, 2 partly right, 8
wrong.** The wrong ones have been consistently more informative than the right
ones, and two of the biggest misses drove the best findings:

- *"Haiku lands ≥15/20"* — it got **1/20**. The largest miss in the project, and
  the reason the price ladder was worth building.
- *"Precision is where tier shows up"* — precision turned out to be the axis
  **nobody cares about**.
- *"`listed` varies more within an arm than between"* — backwards, and that
  became finding 6.

Recording predictions costs nothing and is the only thing that reliably tells you
when you've learned something rather than confirmed something.

---

## What would be worth running next

Ranked by what each would settle.

**A. Find where the Haiku cliff actually is.** Between $2/$10 and $1/$5 something
breaks completely — 20/20 to 1/20 with no middle. Sonnet 4.6 and Haiku at higher
effort would locate it. This is the single most practically useful unknown left:
*how cheap can you go before the floor drops out.*

**B. A fixture built entirely from inference-shaped items.** Task 4
discriminated on one item in five; the rest were at ceiling for everything down
to Haiku. Three or four A4-shaped items would discriminate on every one, at the
same cost per run — a far sharper instrument for a fifth of the effort.

**C. The MCP price list.** Still unrun, still mechanical, still probably the most
shareable artifact available. Run a trivial task under each configuration and read
turn-1 input tokens; the delta *is* that server's standing cost. Measured so far:
pi's turn-1 prefix is **11,001 tokens**, a full-stack Claude Code session **~51.5k**.

**D. Turn count as a directly manipulated lever.** Finding 4 says turns drive cost
when they vary. Test it head-on: same task, one arm told to work in a single pass,
one unconstrained.

**E. Warm vs cold edit.** Identical small edit to a generated artifact, once in the
session that produced it and once fresh. Prices context-carrying directly, on
something PMs do hourly.

---

## Method notes worth keeping

- **Write the answer key, the regexes, and the predictions before run 1.** Task
  1's regrade picked a flattering exclusion rule after seeing outputs. Task 4
  pre-committed the scoring regexes with a 240-assertion test suite of
  hand-written paraphrases, so no regex was ever widened to fit an output.
- **Smoke test with one run per cell, always.** Task 4's smoke test found a
  *sixth* action item hiding in the fixture that neither the author nor an
  independent reader had spotted. Cost of finding it: $0.15.
- **When a run reveals ambiguity, fix the fixture and restart — never the key.**
- **Grade blind, and check what the run id leaks.** With three arms interleaved,
  `run_index mod 3` *is* the arm; scrambling order isn't enough, so grading files
  carry anonymous labels and the map stays closed.
- **A distractor nobody falls for is a control, not a wasted slot.** The
  status-report trap drew 0/240 while the unowned-musing trap drew most of the
  false positives — which is how you know the false positives are discrimination
  failing rather than models spraying at random.
- **Consensus across reps is a free quality signal.** On task 1 all 14 runs
  independently found the same data problem. Findings from a single run needed
  checking, and the two that mattered most were both singletons.
- **Report tokens within a model family, dollars across.** Same tokenizer means
  exact counts; different tokenizers don't. Prices are dated in `prices.json`.
