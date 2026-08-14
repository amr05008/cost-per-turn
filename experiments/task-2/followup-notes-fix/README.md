# Follow-up — can one sentence fix the cheap model?

**Arm D = arm C with one sentence added to the prompt. Nothing else differs.**

## Why this is worth $0.70

In task 2, all three arms produced exactly **3/5 usable decks**. But the two
Kimi failures were *the same bug twice*:

- **r06** — speaker notes leaked onto the slides
- **r09** — notes rendered on the deck itself

That isn't five kinds of bad judgement. It's one mechanical defect, and the
original prompt never said the notes shouldn't be visible — it only asked for
notes. The expensive arms failed in varied, editorial ways instead: presentation
flow, mischaracterising the source, graphics errors, broken sizing.

So the question is: **was the gap capability, or was it the prompt?**

If arm D goes 3/5 → 5/5, the cheap arm's only weakness on this task was a
missing instruction, and cost-per-usable-deck drops from $0.23 to about $0.14 —
against $2.09–$2.75 for the Opus arms.

## The change

The prompt is byte-identical to `../prompts/build-deck.txt` except for one
appended sentence:

> Speaker notes are for me to read while presenting — they must not be visible
> on the slides themselves.

## What this does and does not test

**Tests:** whether Kimi's specific failure mode on this task is prompt-fixable.

**Does not test:** whether Kimi beats Opus. This gives the cheap arm a better
prompt than the expensive arms had, which would be an unfair comparison to run
head-to-head.

The honest framing is narrow and still useful: *the cheap model failed one way,
one sentence addressed it, here's what that was worth.* If you later want the
head-to-head, every arm has to get the v2 prompt.

Worth noting the added sentence probably wouldn't help the Opus failures anyway
— flow, framing, graphics and sizing aren't notes-related — but "probably"
isn't measured, so it stays out of the claim.

## Running it

```bash
./run.sh                                    # 5 runs, ~20 min, ~$0.70
python3 ../../../scripts/extract-runs.py runs
```

Needs only OpenRouter auth — no Anthropic key.

## Grading

Same three questions as task 2, same rubric, graded against the same bar. Open
each `runs/d*/deck.html` with wifi off:

- Does it work?
- How did it handle the planted 12h/~4h contradiction?
- Would you present it? `favorite` / `acceptable` / `unusable`

Record in `runs/grades.csv` as `run_id,verdict,note`; the extractor folds it in.

**The specific thing to check first:** are the speaker notes hidden? That's the
whole hypothesis. If notes are visible on any deck, the sentence didn't take.

## Prediction, written before running

Notes stop leaking (that part is a direct instruction), so **4–5 of 5 usable**.
But **still zero favorites** — task 2 suggested the ceiling isn't correctness,
it's taste, and a formatting instruction shouldn't move that. If a favorite
appears, that prediction is wrong and worth knowing.
