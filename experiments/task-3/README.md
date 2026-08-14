# Task 3 — release notes from a commit log

**The question:** writing user-facing release notes means reading engineering
work and deciding what a customer should hear. Does that judgement track model
tier — and how cheaply can you buy it?

Task 1 was analysis. Task 2 was transformation, source → format. This is
**compression plus audience judgement**: 24 commits in, 250 words out, and most
of the input must be thrown away.

## The setup

- **Source:** `fixture/changelog.txt` — the real `git log v1.3.0..v1.4.0` from
  GlutenOrNot, 24 commits, ~2,500 words. **Verbatim public history. Nothing was
  injected or edited** — regenerate it yourself with `fixture/make-fixture.sh`.
- **Job:** App Store "What's New" notes, max 250 words, plain language.
  One prompt: `prompts/release-notes.txt`.
- **Two arms, ten runs each — 20 runs:**

| arm | harness | model |
| --- | --- | --- |
| A | pi | Opus 5 |
| B | pi | Kimi K3 |

Both run on pi via OpenRouter, so the harness is held constant and **only the
model varies**. Task 2 measured the harness effect and found none worth paying
for, so those runs are spent on reps instead. **No Anthropic key needed.**

n=10 because task 2's n=5 couldn't resolve anything — within-arm spread was
3.4–4.0x. Short outputs make the extra reps affordable.

## The answer key — written before any run

The trap here wasn't planted. It's what a real changelog looks like: three
genuine user-facing changes buried in twenty-one commits of engineering
housekeeping.

**Should appear** — the three things a user actually got:

| change | commits |
| --- | --- |
| Flashlight on the camera, and a "turn on flashlight & retry" option when a photo can't be read | `0eeb168` `369a5f5` `0a360a0` |
| Barcode scanning finds products it previously missed | `b00610a` |
| Clear handling when the phone is offline instead of a confusing failure | `6bc62a9` |

**Should not appear:**

- **The model bump** (`0745bc6`, `6ebb065`) — "claude-sonnet-4-6 →
  claude-opus-4-8". This is the interesting one, because the commit body sells
  it as *"verdict-quality headroom on celiac-safety output"*, which reads like a
  user benefit. Putting it in App Store notes discloses the vendor, the model,
  and — from the same commit — cost and rate-limit details. A PM omits it. The
  user-facing framing, if any, is "more accurate results", never the vendor.
- **Analytics instrumentation** (`13f9df5`) — new properties on scan events.
  Telemetry. Announcing new scan tracking to people who chose this app partly
  because it keeps no record of what they scan is worse than saying nothing.
- **Everything else** — doc passes, ROADMAP edits, release close-outs, version
  bumps, merge commits, a skill file. Roughly 14 of the 24 commits are noise.

## Grading — three questions, ~30 seconds each

Unlike task 2, **the trap here is text**, so the first check really is
mechanical. Task 2's visual defects defeated four detection attempts; this one
doesn't have that problem.

```bash
./check-leaks.sh          # per-run: word count, coverage, internal-detail hits
```

1. **Did internal detail leak?** The script greps for vendor names, telemetry,
   process artefacts. **Read the hits — context decides.** "More accurate
   results" is fine; "upgraded to Claude Opus 4.8" is not.
2. **Does it cover the three real changes?** The script flags each as yes/NO.
3. **Would you paste it into App Store Connect?** `favorite` / `acceptable` /
   `unusable`

Record in `runs/grades.csv` as `run_id,verdict,note`. `extract-runs.py` folds it
into the sheet. Keep `key.csv` closed until you've graded.

## Running it

```bash
./run.sh 1       # smoke test, one per arm
./run.sh         # 20 runs
python3 ../../scripts/extract-runs.py runs
./check-leaks.sh
```

Estimated ~$5–8 total. Short outputs are the whole point — this is the first
task cheap enough to run at a rep count that can actually resolve a difference.

## Predictions, written before running

1. **The gap narrows versus task 2.** Release notes are a conventional form with
   a narrow target. I expect **Kimi to produce favorites here**, which it could
   not do on the deck.
2. **The discriminator will be internal leakage, not writing quality.** Both
   models can write 250 clean words; deciding the model bump doesn't belong is
   the judgement call.
3. **Coverage of the three real changes will be near-universal** in both arms —
   they're the only things in the log that look like features.

If 1 holds, the two tasks together say something sharper than either alone:
*the cheap model is fine when the form is conventional, and fails when the
output needs taste.* If instead Kimi leaks internal detail at a higher rate, the
gap is audience judgement rather than craft — equally useful, different advice.

## Caveats

- One changelog, one release, one product. A different log with a different mix
  of internal-to-user-facing work could move all of this.
- The grader knows the answer key by the time they grade, which is unavoidable
  when the key is written first. `key.csv` stays closed, so the arm is still
  blind.
- "Would you ship it" is one person's taste, as in task 2.
