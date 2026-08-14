# Smoke test — 2026-08-13, one run per arm

Run before the full batch to verify the pipeline. It found three things, which
is why it's worth doing.

## Results

| run | harness | model | cost | round-trips | output tok | cache read | wall clock |
| --- | --- | --- | --- | --- | --- | --- | --- |
| r01 | Claude Code | claude-opus-5 | **$2.6888** | 96 | 47,250 | 1,990,258 | 11m 27s |
| r02 | pi | anthropic/claude-opus-5 | **$1.2566** | 21 | 24,065 | 594,086 | 5m 41s |
| r03 | pi | moonshotai/kimi-k3 | **$0.11** | 5 | 4,864 | 13,303 | 3m 23s |

All three produced a valid, genuinely self-contained deck: 11 / 10 / 10 slides,
zero external references, speaker notes, keyboard navigation.

## What it caught

**1. Cost tracks round-trips, not model price.** r01 cost 24x r03 while doing
the same job. The mechanism is in the cache-read column: 2 million tokens
re-read across 96 round-trips, on a task with ~3k tokens of input. Claude Code
wasn't expensive per token — it took 96 turns, and every turn re-sent a growing
context.

This is the quadratic showing up on a *bounded* task, which is where the
experiment was designed to avoid it. **A bounded output spec does not bound
effort.** r01 spent most of its turns on work nobody asked for: re-rendering in
headless Chrome with DNS blackholed, measuring content bounds on every slide,
driving 17 keystroke scenarios. It found and fixed real bugs doing it. Whether
that's worth $2.58 more than Kimi is the actual question this task asks.

So `cost / round_trips` is load-bearing here, not a nice-to-have.

**2. The binary grading rule was wrong.** The original check was "Ctrl-F
`12 hours` — if present, the deck repeated the error." r01 *caught* the planted
contradiction and wrote it into the speaker notes:

> *Accuracy note:* my earlier draft said memory syncs every 12 hours, elsewhere
> every ~4. The body of the writeup says ~4 hours twice, so I've used that here.

That's the best possible handling, and the binary rule scored it as a failure.
Meanwhile r02 used the correct value and never mentioned the conflict — a
materially different outcome that the same rule scored identically.

Fixed to three outcomes (caught / silent / repeated). See README.

**3. Two harness bugs.** Both agents stalled ~3s waiting on stdin that never
arrives, and could hang outright when detached — fixed with `< /dev/null`.
The original `set -e` meant one failed run aborted the whole batch; now runs
continue and completed ones are skipped, so a re-run retries only failures.

## Open questions the full batch should answer

- Does r01's round-trip count hold across reps, or was it one thorough run?
- Is the Kimi deck **presentable**, not just structurally valid? Human call.
- Does defect handling track cost, or is it a coin flip? Task 1 says coin flip.

## Caveat

n=1 per arm. Task 1's lesson was that within-cell variance spans the entire
quality scale at n=3, so treat every number here as a hypothesis, not a result.
