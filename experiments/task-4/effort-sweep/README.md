# Task 4 · effort sweep — arm O, and the price ladder task 4 was missing

**The question, in two parts:**

1. **Does reasoning effort change the outcome?** Every run in this repo has been
   at `--thinking high`. Effort is the one knob that moves output tokens — the
   5x-priced class — directly, and almost nobody touches it.
2. **Does model tier predict correctness across a *real* price range?** Tasks 2
   and 3 contained no model below Opus's tier, and task 4's "budget" arm
   (Kimi K3, $3/$15) is priced *above* Sonnet 5 ($2/$10). **This repo has never
   tested a cheap model.** The tier question has only ever been asked across a
   2.5x band.

This sweep answers both on one fixture, because half the grid is already paid
for.

## The grid — 6 models × 2 effort levels

| model | $/M in→out | high | low |
| --- | --- | --- | --- |
| Opus 5 | 5 → 25 | ✅ `../runs`, n=20 | **new** |
| Sonnet 5 | 2 → 10 | ✅ `../runs`, n=20 | **new** |
| Kimi K3 | 3 → 15 | ✅ `../runs`, n=20 | **new** |
| Haiku 4.5 | 1 → 5 | **new** | **new** |
| GPT-5.4-mini | 0.75 → 4.5 | **new** | **new** |
| GPT-5.4-nano | 0.2 → 1.25 | **new** | **new** |

**180 new runs at n=20; 240 in the completed grid.** Est. ~$3.

**Opus → Sonnet → Haiku is a within-family ladder** — one tokenizer, so token
counts are exactly comparable. **Kimi, mini and nano are three cross-vendor
points at three price tiers**, so no conclusion rests on one vendor.

**Nano is in because it is the only arm that can break the tier finding**, and
both outcomes are publishable: if a model 20x cheaper than Opus produces the
same list, that is the most quotable number in the project; if it fails, the
tier claim finally gets a lower bound instead of being unbounded.

**Kimi stays despite being the odd one out on price** — it and Opus are the only
models present in all four tasks, and dropping it would break every cross-task
comparison the write-up rests on.

## The one methodological guard

**Effort is compared within a model, never across one.** pi's `--thinking` maps
to a different mechanism per vendor — Anthropic's thinking budget, OpenAI's
`reasoning_effort`, whatever Moonshot does. Pooling "low effort" across vendors
would be meaningless. Same model, same fixture, same prompt, only the level
changes: that comparison is clean, and it is the only effort comparison made
here.

Confirmed at smoke test that the knob does something outside Anthropic:
GPT-5.4-mini cost **$0.0123 at high vs $0.0042 at low**, a 3x swing.

## Fixture, key and scorer are task 4's, unchanged

`key.sh` and `score.sh` in this directory are **symlinks to the parent**, so the
sweep is graded by byte-identical code against a byte-identical key, and the two
batches can be pooled without an asterisk. The fixture and prompt are read from
`../fixture/` and `../prompts/`.

**Headline metric: cost per shippable list, where shippable = recall 5/5.**
That is the rule task 4's blind human pass established — recall separated
shippable from unusable 20 for 20, and precision predicted nothing.

## Predictions

**Written before any run in this sweep**, and reproduced here verbatim. The
9-run smoke test has since been seen; these were **not** revised afterwards.

1. **Sonnet holds at or near 20/20 at low effort.** If it does, the thinking was
   never load-bearing here — that is the money finding.
2. **Kimi degrades most.** A4 is the only item requiring two facts linked across
   a document, which is exactly what deliberation buys, and it is already at
   9/20.
3. **Opus's surplus drops at low effort while recall holds** — cheaper *and*
   mechanically better, at zero cost to shippability.
4. **Haiku lands ≥15/20 recall at high** — better than Kimi, short of Sonnet.
5. **GPT-5.4-mini's effort sensitivity is smaller than Kimi's**, whatever its
   absolute level.

## Running it

```bash
./run.sh 1     # smoke, one per cell (9 runs)
./score.sh
./run.sh       # 180 runs
python3 ../../../scripts/extract-runs.py runs
./score.sh
```

## Caveats

- **One fixture, and a narrow one.** Task 4 discriminated on exactly one of its
  five items (A4). This sweep inherits that: it is really a 240-run measurement
  of *one* inference — linking a stated precondition to a later decision.
  Everything else in the fixture is at ceiling for every model.
- **`low` vs `high` is two points, not a curve.** pi offers
  `off/minimal/low/medium/high/xhigh/max`. If low ≈ high, `off` is the cheap
  follow-up that would say whether *any* thinking was needed.
- **Cross-vendor dollars, not tokens.** Within the Anthropic ladder token counts
  are exact. Across vendors only dollars are comparable, and they move with the
  price sheet — dated `prices.json`, as everywhere in this repo.
- **The shippable rule is an extrapolation.** It was validated by a human on 20
  lists from three models. The two new vendors have never been checked against
  it, which is what the spot-check at the end is for.
