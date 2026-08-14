# Task 2 — results

**Run 2026-08-13 · 15 runs · $15.22 total · graded blind by eye, wifi off**

Three setups turned the same 2,400-word document into a slide deck, five times
each. One factual contradiction was planted in the source. Predictions were
written down before anything ran (see README) so they could be wrong.

## The headline

| arm | spend | favorite | acceptable | unusable | usable | **$ / usable** | **$ / favorite** |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Claude Code · Opus 5 | $8.25 | 2 | 1 | 2 | **3/5** | $2.75 | $4.13 |
| pi · Opus 5 | $6.28 | 2 | 1 | 2 | **3/5** | $2.09 | $3.14 |
| pi · Kimi K3 | $0.68 | **0** | 3 | 2 | **3/5** | **$0.23** | **never** |

**Every arm produced exactly three usable decks out of five.** The cheap arm
matched the expensive ones on hit rate at roughly a tenth of the cost.

**And the cheap arm produced zero decks worth being pleased with — at any
price.** Five runs, three of them fine, none of them good.

That pair of facts is the whole result. You are not paying for correctness on
this kind of work. You are paying for taste, and only sometimes.

## What that means in practice

If "fine" is the bar — an internal readout, a draft to edit yourself, something
nobody will remember next week — **$0.23 buys it and $2.75 does not buy more.**
A 12x price difference bought no additional usable output.

If you want a deck you'd be happy to stand behind, the cheap arm cannot get you
there, and you are looking at **$3–4 per deck you'd actually want** — including
the ones you throw away getting there.

## The harness made no measurable difference

Claude Code vs pi, same model, same task:

- **Cost:** medians $1.10 vs $1.26 — a $0.15 gap, against within-arm spreads of
  **3.4x and 4.0x**
- **Quality:** 3/5 usable each, 2 favorites each

The pre-registered falsifier fires: the arms differ by far less than either
arm's own run-to-run variance. **No measurable difference**, published as such.

Worth noting the smoke test showed a 2x harness gap on n=1. It was noise, and
publishing it would have been wrong. The reps are what made that visible.

## Spending more didn't buy a better deck

The two most expensive runs in the batch were nearly identical in price and
opposite in outcome:

| run | arm | cost | round-trips | verdict |
| --- | --- | --- | --- | --- |
| r10 | Claude Code · Opus | $2.71 | 101 | **favorite** |
| r01 | Claude Code · Opus | $2.69 | 96 | **unusable** — bad presentation flow |

Same setup, same prompt, 4x the cost of the cheapest run in that arm, and one of
them was thrown away. The cheapest favorite in the whole batch was r13 at $1.10.
Within an arm, cost and quality are unrelated.

## Catching the planted error predicted nothing

The source claimed memory syncs every 12 hours in its summary and ~4 hours twice
in the body. **No deck asserted the wrong number.** Five flagged the conflict;
ten silently used the correct value.

| verdict | caught the error |
| --- | --- |
| favorite | 2 of 4 |
| acceptable | 1 of 5 |
| unusable | 2 of 6 |

Flat. Noticing the defect had no relationship to whether the deck was any good —
prediction #2, confirmed. Catching it split by arm (3/5 · 2/5 · 0/5), so it
tracks the model somewhat, but not the outcome.

The best handling came from r11 (pi · Opus), which refused to pick a number:

> Note the sync interval in the source draft is inconsistent (12h in the
> summary, ~4h in the body) — confirm which before you say a number, or just
> say "on a schedule."

No Kimi deck mentioned it. All five quietly used the right figure, so you'd
never learn the source had a defect.

## The failure modes differ, and Kimi's is fixable

**Kimi failed the same way twice:** speaker notes rendered onto the visible
slides (r06, r09). That looked like one mechanical bug rather than five kinds of
bad judgement, and plausibly fixable with one line in the prompt.

**It was tested, and the fix didn't help** — see `followup-notes-fix/`. Adding
one sentence eliminated the notes bug completely (0/5 leaked) and the pass rate
stayed at exactly 3/5, because two different mechanical failures appeared in
their place: broken styling, and a deck that stops rendering at slide 5. The
cheap arm has a *rate* of defects, not a nameable bug. Patch one and another
takes its place.

**The Opus arms failed in varied, editorial ways:** presentation flow (r01),
mischaracterising four learnings as "four things that took longer" (r04),
graphics errors (r08), sizing broken from slide 3 (r14). Harder to prompt away.

## Predictions, scored

1. **"Model tier will matter less here than on Task 1."** *Half right.* It
   didn't matter at all for producing something usable — 3/5 across the board.
   It mattered completely for producing something good — 4 favorites from Opus,
   0 from Kimi.
2. **"Catching the planted error won't track cost."** *Confirmed.* Flat across
   every quality band.
3. **"The warm-vs-cold edit gap will be large."** *Not tested* — that split was
   cut before running and moved to a future task.

## Caveats

- **n=5.** Within-arm cost spread is 3.4–4.0x on the Opus arms, so only the
  Kimi separation ($0.11–$0.15 vs $0.53–$2.71, no overlap) is clean.
- **One grader, not blind to the fact that a grader exists.** Verdicts were made
  from the decks alone with the config key closed, but it's one person's taste.
- **One document, one deck format.** Nothing here generalises to work with a
  right answer.
- Both Opus arms billed at real API rates; Kimi via OpenRouter. Comparable, but
  a footnote.
