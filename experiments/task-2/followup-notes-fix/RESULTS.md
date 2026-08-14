# Follow-up results — the fix worked and changed nothing

**5 runs · $0.67 · graded by eye against the same bar as task 2**

## The result

| arm | prompt | spend | usable | favorites | $ / usable |
| --- | --- | --- | --- | --- | --- |
| pi · Kimi K3 | v1 | $0.68 | **3/5** | 0 | $0.228 |
| pi · Kimi K3 | v2 (+1 sentence) | $0.67 | **3/5** | 0 | $0.223 |

**The sentence did exactly what it was asked to do.** Zero of five decks had
speaker notes visible on the slides. The specific defect that killed r06 and
r09 was eliminated completely.

**The pass rate did not move.** Still 3 of 5. The failures relocated:

| | run | why it failed |
| --- | --- | --- |
| v1 | r06 | speaker notes leaked onto the slides |
| v1 | r09 | notes rendered on the deck itself |
| v2 | d03 | weird styling |
| v2 | d05 | does not render beyond slide 5 |

Cost was untouched — $0.11–$0.15 per run either way, 4 round-trips every time.

## What this actually says

The tempting read of task 2 was: *the cheap model has one bug, patch the prompt,
get 5/5 at a tenth of the price.* That's wrong.

What the cheap model has is a **rate of mechanical defects**, not a specific bug.
Name one and it stops making that one. Something else takes its place — a styling
problem, a deck that dies at slide 5. You are not closing a hole; you are moving
it.

That's a more useful thing to know than a win would have been, and it's the kind
of result that only shows up if you run the follow-up instead of assuming.

## Prediction, scored

Written before running: *"notes stop leaking, so 4–5 of 5 usable, but still zero
favorites."*

- **Notes stop leaking** — correct, 5/5 clean.
- **4–5 usable** — **wrong.** Stayed at 3/5.
- **Zero favorites** — correct.

The wrong half is the one worth keeping. Predicting that fixing a named defect
raises the pass rate is exactly the intuition this experiment was built to test,
and it didn't survive.

## Caveats

- **n=5.** 3/5 vs 3/5 cannot rule out a real improvement — the confidence
  interval here is enormous. What *is* clean is the hypothesis check itself:
  0/5 decks leaked notes under v2, against 2/5 under v1.
- **Different graders' bars drift.** Same person, same rubric, but the v2 decks
  were graded knowing what to look for.
- The v2 prompt was only ever given to Kimi. This says nothing about how the
  Opus arms would fare with it, and no head-to-head claim should be built on it.
