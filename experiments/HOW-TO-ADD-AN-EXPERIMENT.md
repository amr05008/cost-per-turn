# Adding an experiment

Everything needed to run a new task is in this repo. This file is the part that
isn't obvious from reading the code: what makes an experiment produce a real
result instead of a plausible-looking one.

Read [`FINDINGS.md`](FINDINGS.md) first — several questions are already settled
and re-running them wastes budget.

## Paste this into a fresh session

> I want to add a new experiment to `~/repos/cost-per-turn`. Read
> `experiments/FINDINGS.md`, `experiments/HOW-TO-ADD-AN-EXPERIMENT.md`, and
> `experiments/task-3/` as the reference implementation, then help me design
> task N.
>
> Don't re-run anything listed as settled in FINDINGS. Follow the checklist:
> answer key committed before any run, predictions on record, smoke test before
> the batch, blind grading.
>
> The task I have in mind is: `<describe it>`

Task 3 is the best template — cheapest, cleanest, and the one whose design held
up. Task 1 is a worked example of how an experiment goes wrong.

## Already settled — don't spend runs re-testing

| question | answer | where |
| --- | --- | --- |
| Does the harness (Claude Code vs pi) change cost or quality? | No measurable difference | task-2 |
| Does model tier predict usable output? | Not in 5 arm comparisons | FINDINGS #1 |
| Does catching a planted defect predict quality? | No | task-2, task-3 |
| Can "is this good" be graded mechanically? | No. Ten attempts, ten failures | FINDINGS #6 |
| Does fixing a named failure mode raise the pass rate? | No — defects relocate | task-2 follow-up |

## What makes a task work

**Self-contained fixture that ships in the repo.** Task 1 queried a live
analytics project; the trap it depended on was destroyed within a day of acting
on the findings, and no reader could ever reproduce it. If the input can change
without you changing it, the experiment has a half-life.

**Bounded container, free judgement inside it.** Specify the format, the length,
the file name, the audience. Leave the *content* choices to the model. Bounded
output makes costs comparable; free selection is what makes quality vary enough
to measure. Task 1 was unbounded and its cost numbers are uninterpretable as a
result.

**Cheap outputs so you can afford reps.** Within-arm variance is 3.4–4.0x on
cost and spans the whole quality scale, so n=5 resolves almost nothing. Task 2
cost $15 for n=5 per arm; task 3 got n=10 per arm for $2.74. Prefer short
outputs and spend the savings on reps.

**Read-only, or writing only into its own run directory.** The moment a task
mutates shared state you inherit worktrees and reset discipline, and that's
where protocols quietly break.

**A defect you control.** Plant it, or find one that occurs naturally and won't
be fixed. It gives you one objective axis alongside the taste judgement. Note
that in both tasks so far, defect handling did *not* predict quality — it's a
separate signal, not a quality proxy.

## The checklist

1. **Write the answer key and predictions, and commit them, before run 1.** A
   key derived after seeing outputs isn't independent of them. The first pass of
   task 1's regrade picked a flattering exclusion rule and overstated the result
   — exactly the failure it was grading the runs for.
2. **Copy `_template/`**, edit the CONFIG block in `run.sh`, drop in the fixture
   and prompt.
3. **`./run.sh 1` first.** Every batch so far has had something wrong that only
   a real run surfaced.
4. **Check the smoke test** — artifact written? `run.jsonl` ends with `result`
   (Claude Code) or `turn_end` (pi)? Does `extract-runs.py` report non-zero cost?
5. **Run the batch** detached: `nohup caffeinate -i ./run.sh > batch.log 2>&1 &`
6. **Extract:** `python3 ../../scripts/extract-runs.py runs`
7. **Grade blind.** Export all outputs into one file in *scrambled* order —
   arms are interleaved, so reading position leaks the arm otherwise. See
   `task-3/ALL-NOTES.md`.
8. **Write `runs/grades.csv`** as `run_id,verdict,note`. The extractor folds it
   and `key.csv` into the sheet automatically, so re-extracting never wipes
   grading.
9. **Score your predictions, including the wrong ones.** Two of six so far were
   wrong and they were the informative ones.

## Grading, honestly

Three questions, by eye, one to two minutes per artifact:

1. **Does it work?** — mechanical, automate this
2. **How did it handle the defect?** — surface candidates mechanically, judge by eye
3. **Would you ship it?** `favorite` / `acceptable` / `unusable`

**Do not try to automate #3, or the judgement half of #2.** Ten attempts failed,
each in a new way, and under-flagging is indistinguishable from a pass — a
binary check once scored the *best* run in a batch as a failure because it
mentioned the defect in order to flag it. Write checkers that over-flag and hand
a human the call.

**The headline metric is cost per *acceptable* result**, not cost per run. On
task 1 those were ~7x apart.

## Gotchas that cost real time

- **`< /dev/null` on every agent invocation.** Both harnesses otherwise stall
  ~3s waiting on stdin and can hang outright when detached.
- **Never `set -e` in a batch runner.** One transient API error would kill an
  hour of runs. Let failures record and continue; skip completed runs on re-run.
- **Claude Code `--bare`** disables auto-memory, CLAUDE.md, hooks and plugins in
  one flag — and requires `ANTHROPIC_API_KEY`, not the Max login. pi's mirror is
  `--no-context-files --no-skills --no-extensions`.
- **Uncontrolled memory decides outcomes.** In task 1 both top-graded runs had
  memory recall and one credited a stored note containing the answer; nine runs
  without memory produced zero top grades.
- **Pin absolute dates** in any prompt referencing a time window. "Last 30 days"
  means every run sees different data.
- **Don't use `num_turns`** for cross-harness comparison — Claude Code and pi
  count turns differently. Use `round_trips` from the extractor.
- **`cost ÷ round_trips`** separates "efficient" from "did less". On open-ended
  tasks a cheap run is often cheap because it stopped early.
