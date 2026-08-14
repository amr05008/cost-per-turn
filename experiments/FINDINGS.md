# What 54 runs across three tasks actually showed

**2026-08-13 · 54 agent sessions · $40.91 total**

| task | shape | runs | spend |
| --- | --- | --- | --- |
| 1 · analyse 30 days of product analytics | open-ended, live data | 14 | $22.28 |
| 2 · turn a doc into a slide deck | bounded generation | 15 + 5 | $15.89 |
| 3 · turn a commit log into release notes | compression + audience judgement | 20 | $2.74 |

Task 1 is a pilot, not a valid comparison — see `task-1/RESULTS.md` for why.
Tasks 2 and 3 are clean.

---

## The eight findings

### 1. Model tier never predicted whether the output was usable

| task | arm | usable |
| --- | --- | --- |
| 2 | Claude Code · Opus 5 | 3/5 |
| 2 | pi · Opus 5 | 3/5 |
| 2 | pi · Kimi K3 | 3/5 |
| 3 | pi · Opus 5 | 3/10 |
| 3 | pi · Kimi K3 | 3/10 |

Five arms, two tasks, a ~12x spread in what the runs actually cost — and not one
comparison produced a difference in hit rate. On task 3 the **single best output
came from the cheaper of the two models tested**.

**Read that with one caveat, added after task 4.** The "budget" arm throughout
this repo is Kimi K3 at **$3/$15 per M tokens**, which is *cheaper than Opus 5
($5/$25) but more expensive than Sonnet 5 ($2/$10)*. It is a mid-priced model,
not a cheap one. Tasks 2 and 3 never contained a model below Opus's tier, so
**the tier question has only ever been asked across a 2.5x price band.** No
genuinely cheap model has been tested here yet.

What did differ was the ceiling, and only on task 2: Kimi produced zero
favourites there at any price, while both Opus arms produced two each. On task 3
that reversed.

### 2. Cost is driven by round-trips, not by model price

The same model pair was **12x apart on task 2 and 2.1x apart on task 3.**

| task | Opus round-trips | Kimi round-trips | cost ratio |
| --- | --- | --- | --- |
| 2 (deck) | 96 | 5 | 12x |
| 3 (notes) | 8 | 6 | 2.1x |

Task 2's gap was never about per-token price. Opus took 96 turns and re-sent a
growing context on every one — two million cache-read tokens against 3k of
input. When both models take a similar number of turns, cost collapses toward
token economics.

**"Switch to a cheaper model to save money" is advice about turn count wearing a
disguise.**

### 3. Prompt caching matters more than sticker price

On task 3, Kimi's cache-write was **zero** — it paid full freight on ~14.7k
input tokens every run. Opus wrote a cache once and read it at roughly a tenth
of input price, which is why its median *input* column reads **15 tokens**.

The expensive model's caching ate most of the cheap model's advantage. On any
task with a substantial fixed input, caching behaviour is a bigger cost lever
than the price sheet.

### 4. Within-arm variance beats between-arm variance

At fixed config on task 2, cost spread **3.4–4.0x** and quality spanned the
entire scale. The two most expensive runs in the batch — $2.71 and $2.69, same
arm, same prompt — produced one favourite and one throwaway.

Consequence: **n=5 resolves almost nothing.** Task 2's smoke test showed a 2x
harness gap at n=1 that turned out to be noise; publishing it would have been
wrong. Reps are what buy inference.

### 5. Cost per *acceptable* result is a different number from cost per run

On task 1, roughly **7x apart** — $11.14 vs a $1.66 median. On task 3, Opus cost
$0.63 per usable note and **never** produced a favourite, while Kimi cost $0.28
per usable and produced the only one.

Cost per run is the number everyone quotes. It is not the number that means
anything.

### 6. Quality judgement resists automation — structural checks don't

Ten attempts across two tasks to mechanise "is this good / should this have been
said." All ten under-detected, each in a new way.

- Task 2 (visual): a binary Ctrl-F scored the *best* run as a failure, because
  the best run mentioned the planted error in order to flag it.
- Task 3 (textual): five patterns missed disclosures phrased as "a newer, more
  capable AI model", "the engine… got an upgrade", "the measurements we now
  collect".

**Under-flagging is the dangerous failure, because it is indistinguishable from
a pass.** What automates cleanly: word counts, slide counts, external-reference
checks, coverage keywords, named-entity greps. What doesn't: intent, framing,
taste. The final checker surfaces candidate sentences and hands a human the call.

Task 3 made the distinction concrete: the same subject (diagnostics) appeared in
the top-graded note *and* in two rejected ones. Framing decided it.

### 7. Fixing a named failure mode didn't raise the pass rate

Task 2's cheap arm failed twice the same way — speaker notes rendered onto the
slides. One added sentence eliminated it completely: **0/5 leaked, down from
2/5.** The pass rate stayed at exactly 3/5, because two different mechanical
failures appeared instead (broken styling, a deck that stops rendering at slide
5). Cost unchanged.

The cheap model has a **rate** of defects, not a nameable bug. Patch one and
another takes its place.

### 8. A benchmark built on a live system has a half-life

Task 1's trap — reviewer traffic contaminating an analytics read — was
accidental and perishable. Acting on the finding (shipping the fix, creating an
exclusion cohort, writing it into a plan file) destroyed the instrument that
measured it **within a day**.

Anything you intend to re-run needs a fixture you control. Tasks 2 and 3 ship
their inputs in this repo for exactly that reason.

---

## What would be worth running next

Ranked by what each would actually settle.

### A. A task with a verifiable right answer ⭐

**The biggest gap.** All three tasks were graded on taste. If model tier never
matters on judgement work, does it matter when correctness is objective?

Something with a checkable output — reconcile two data sources, extract
structured records from messy text, compute a figure with a known answer. Then
the grading is `diff`, no human in the loop, and n can go to 20+ per arm cheaply.

If the tie holds there too, finding #1 becomes very hard to argue with. If it
breaks, you've found the boundary — which is more useful still.

**Leading candidate: parsing a synthetic set of call notes** containing five
planted action items, checking whether it catches all five. Grading is a `diff`.

**Measure precision, not just recall.** A model that lists twelve things scores
5/5 on recall trivially — and a bloated action list is the failure mode you'd
actually want to catch. Two mechanical numbers, no judgement:

- **recall** — how many of the five planted items it found
- **precision** — how many things it listed that weren't action items

**Graduate the difficulty, or everything scores 5/5 and nothing varies.**
Something like two items stated outright ("I'll send the deck Friday"), two
implicit ("we should probably get legal to look at that" — a commitment with no
owner), and one buried in a tangent. Add a deliberate near-miss that sounds like
a commitment but isn't ("someone should really look at pricing at some point");
counting it is a precision error, and that's what separates careful from eager.

Short outputs, so n=20+ per arm is affordable.

### B. The MCP price list ⭐

Mechanical, needs no grading at all: run a trivial task under each
configuration and read turn-1 input tokens. The delta *is* the standing cost of
that server.

Measured so far: pi's turn-1 prefix is **11,001 tokens**; a full-stack Claude
Code session measured **~51.5k**. Against a dozen-plus installed MCP servers,
this produces a price list for things everyone installs once and never audits —
probably the most shareable single artifact available here, and the best
on-camera segment.

### C. Turn count as a directly manipulated lever

Finding #2 says turns drive cost. Test it head-on: same task, same model, one
arm told to work in a single pass and one left unconstrained. Does forcing fewer
turns save money without costing quality?

This converts the project's most mechanistic finding into a habit a reader can
adopt tomorrow.

### D. Warm vs cold edit

Cut from task 2 before it ran. Identical small edit to a generated artifact,
once in the session that produced it and once in a fresh one. Prices context
carrying directly, on a thing PMs do hourly. Cheap and visual.

### E. More reps on one clean pair

Three tasks have now tied at 3/5 or 3/10. Is that a real tie or is n too small?
One task, two arms, **n=20 each** would say. Task 3 costs ~$0.13 a run, so this
is under $6.

### F. MCP vs a thin skill (arm F, never run cleanly)

Task 1's original question. Now runnable properly with `--bare` controlling the
context stack. The hypothesis — *a thin skill beats a fat MCP* — is contrarian
and generalises past any one server.

---

## Method notes worth keeping

- **Write the answer key before the runs.** The first pass of task 1's regrade
  picked a flattering exclusion rule and overstated the result — the same
  failure it was grading the runs for.
- **Grade blind, and scramble presentation order** when arms are interleaved.
- **Prefer discriminators that survive analyst choices.** `ocr_chars = 0 on 34
  of 34` needed no judgement calls; the `image_kb` gradient moved depending on
  which rows you excluded.
- **Record predictions before running and score them, including the wrong
  ones.** Six predictions made across tasks 2 and 3; four right, two wrong. The
  wrong ones were the informative ones.
- **Consensus across reps is a free quality signal.** On task 1 all 14 runs
  independently found the same data problem — almost certainly true. Findings
  from a single run needed checking, and the two that mattered most were both
  singletons.
