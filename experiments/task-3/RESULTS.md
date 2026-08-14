# Task 3 — results

**20 runs · $2.74 · graded blind, scrambled order, `key.csv` closed until done**

## Read this first

The grader states his own bias: *"I'm really tough on AI writing… in general I
hate wordy writing, so I'm probably tougher on this test than others."*

That is not a disclaimer to skip. **A 3/10 pass rate against this bar is not a
3/10 against a general one**, and 14 of 20 were rejected primarily for prose
style rather than for anything in the answer key. Read every rate below as
*"would this specific PM ship it unedited"* — which is the honest question, and
a harsher one than task 2's.

## The headline

| arm | spend | favorite | acceptable | unusable | usable | $ / usable | $ / favorite |
| --- | --- | --- | --- | --- | --- | --- | --- |
| pi · Opus 5 | $1.90 | 0 | 3 | 7 | **3/10** | $0.63 | **never** |
| pi · Kimi K3 | $0.84 | **1** | 2 | 7 | **3/10** | **$0.28** | $0.84 |

**Identical pass rate. Again.** Third time across two tasks that arms have tied
on usable output — task 2 was 3/5 for all three arms, this is 3/10 for both.

**And the single best release note in the batch came from the cheap model.**
n18, the only `favorite`, is Kimi K3 at $0.08.

That inverts task 2, where Kimi produced zero favorites at any price. The
prediction written before this ran — *"the gap narrows, and I expect Kimi to
produce favorites here"* — was right, and understated it.

## Why the cost gap collapsed: 12x → 2.1x

Same two models, same harness, different task. Medians:

| arm | cost | input | output | cache read | cache write | round-trips |
| --- | --- | --- | --- | --- | --- | --- |
| pi · Opus 5 | $0.176 | 15 | 3,063 | 64,680 | 11,284 | 8 |
| pi · Kimi K3 | $0.083 | 14,664 | 1,664 | 27,038 | **0** | 6 |

**Round-trips converged.** Task 2's 12x gap was never really about model price —
Opus took 96 round-trips there against Kimi's 5, and each one re-sent a growing
context. Here both sit at 6–8, and cost falls back toward token economics.

**Kimi writes no cache, and it costs it.** Cache write is zero, so it pays full
freight on ~14.7k input tokens every run. Opus writes a cache once and reads it
at roughly a tenth of input price — which is why its input column reads *15*.
The expensive model's caching eats most of the cheap model's sticker advantage.

**So the lever isn't the model, it's how many turns it takes.** Identical model
pair, 12x apart on one task and 2.1x on another. Any advice of the form "switch
to a cheaper model to save money" is really advice about turn count wearing a
disguise.

## Predictions, scored

1. **"The gap narrows; Kimi produces favorites here."** *Right,* and stronger
   than predicted — Kimi produced the only favorite.
2. **"The discriminator will be internal leakage."** *Wrong.* The model-bump
   disclosure appeared in 5/10 Opus and 4/10 Kimi runs and barely tracked the
   verdict (2 of 9 disclosing runs were usable, vs 4 of 11 that didn't). The
   real discriminator was prose density.
3. **"Coverage will be near-universal."** *Right.* 20 of 20 covered all three
   real user-facing changes.

## The answer key still earned its keep

Two rejections cite it directly, in the grader's words:

> **n10** — "was good but this line made no sense to tell users: *Anonymous,
> counts-only failure reporting… helps us find and fix the cases where the app
> falls short.*"
>
> **n20** — "no need to announce behind-the-scenes error reporting. not user
> facing benefit."

Both are the telemetry disclosure the key said shouldn't appear. So the trap was
real and did cost runs — it just wasn't the *main* thing separating them.

**And the judgement is about framing, not topic.** n18 — the favorite — also
mentions diagnostics, under a reassuring "Privacy, as always" heading. Same
subject, opposite outcome. That's a distinction no keyword check can make, which
is consistent with everything else this task showed about automated grading.

## Brevity was not the mechanism

Given the stated anti-wordiness bias, the obvious hypothesis is that shorter won.
It didn't:

| verdict | n | median words | range |
| --- | --- | --- | --- |
| favorite | 1 | 231 | — |
| acceptable | 5 | 246 | 239–250 |
| unusable | 14 | 247 | 217–252 |

The *shortest* note in the batch (217 words) was rejected. So "wordy" means
low density per word, not high word count — a style judgement, not a length one.

## Caveats — several, and they matter

- **One grader, with a declared strong bias.** Stated up front, which makes it
  usable data, but it is one person's bar.
- **n=10 per arm.** 3/10 vs 3/10 cannot rule out a real difference. And "the
  cheap model produced the best one" rests on a **single** observation — it is
  not a rate.
- **The grader knew the answer key**, unavoidable when the key is written first.
  Arm assignment stayed blind: notes were presented in hash-scrambled order so
  reading position couldn't leak the A/B interleave.
- One changelog, one release, one product.
