# Task 2 — turn a document into a slide deck

**The question:** on ordinary, bounded work — the kind where there's no clever
answer, just a thing to produce — does it matter which model or which tool you
use? And what does the cheap option actually cost you?

Task 1 was the opposite shape: open-ended analysis with no single right answer.
Running both is how you find out whether "just use a cheaper model" is good
advice or bad advice. It's probably different for each.

## The setup

- **The source:** `fixture/talk-source.md` — a real blog post, ~2,400 words,
  framed as a working draft for an internal talk.
- **The job:** turn it into a self-contained HTML slide deck. One prompt,
  `prompts/build-deck.txt`.
- **Three setups, five runs each — 15 decks:**

| arm | tool | model |
| --- | --- | --- |
| A | Claude Code | Opus 5 |
| B | pi | Opus 5 |
| C | pi | Kimi K3 |

A vs B is the same model in two different tools. B vs C is two models in the
same tool. Nothing else changes.

Claude Code runs with `--bare`, which starts it without its memory, project
files, or plugins loaded — so both tools begin from the same place. Task 1
showed that difference mattered more than the model did, which is exactly why
it can't be left uncontrolled here.

## The one planted error

The summary block at the top of the source says the agents sync memory **every
12 hours**. The body says **~4 hours**, in two different sections. The body is
right; the summary is stale — which is what happens to real documents when you
revise the middle and forget the top.

Nobody is told to look for it. The question is just whether a deck repeats it.

## Running it

```bash
export ANTHROPIC_API_KEY=sk-ant-...     # --bare needs a key, not a login
./run.sh                                 # 15 runs, ~1.5-2 hours
python3 ../../scripts/extract-runs.py runs
```

Smoke-test first with `./run.sh 1` — three runs, one per arm. The arm assignment
for the first three is identical either way and completed runs are skipped, so
`./run.sh` afterwards keeps them and runs only the remaining twelve.

Each run gets its own directory and its own copy of the source, so no run can
see another's work. Runtime is dominated by the Claude Code arm — measured at
~11 min per run against ~3 min for Kimi. `run.sh` writes `runs/key.csv` — **don't open it until
you've graded**, or you'll be grading the label instead of the deck.

## Grading — three questions, by eye

Open each `runs/r*/deck.html` **with your wifi off**. About a minute each.

| | |
| --- | --- |
| **Does it work?** | Opens, pages through, nothing missing or broken |
| **How did it handle the planted error?** | Ctrl-F `12 hours`, then read the sentence around it (see below) |
| **Would you present it?** | yes / needs one pass / no |

Ctrl-F alone isn't enough — a good run *mentions* 12 hours in order to flag it.
Read the sentence and pick one:

| result | what you're looking at |
| --- | --- |
| **caught** | Names the conflict — "the summary says 12 hours, the body says ~4, I used ~4" |
| **silent** | No `12 hours` anywhere; deck says ~4 hours. Right answer, no sign it noticed |
| **repeated** | Asserts `12 hours` as fact on a slide or in notes |

Record in `runs/grades.csv` as `run_id,works,error_handling,presentable`. Then
join against `key.csv` and the cost numbers.

**Headline metric: cost per deck you'd actually present.** Task 1's lesson was
that this is a very different number from cost per run — about 7x apart there —
and only one of them means anything.

## Written down before running, so it can be wrong

1. Model tier will matter **less** here than on Task 1. This is mechanical work
   against a spec; if the cheap arm produces a presentable deck at a fraction of
   the cost, that's the finding.
2. Catching the planted error **won't track cost**. Task 1's evidence says this
   is closer to a coin flip than a capability ladder.
3. If the arms differ by less than the spread *within* an arm, the answer is
   **"no measurable difference"** — and it gets published that way.

If 1 and 2 both hold, the pair of tasks says something more useful than either
alone: **pay for judgement, don't pay for typing.**
