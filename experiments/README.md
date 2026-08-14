# Experiments

Each task is a fixed job run many times across different harnesses and models,
so the same work can be priced side by side. The point isn't to rank models —
it's to find out which levers actually move the bill, and what a cheap result
costs you in quality.

| task | shape | source | status |
| --- | --- | --- | --- |
| **task-1** | Open-ended analysis of a live analytics dataset | private PostHog project | pilot run 2026-08-13; not reproducible by others (see below) |
| **task-2** | Bounded generation — a markdown doc into an HTML slide deck | ships in this repo | ready to run |

## Read these in order

1. `task-1/RESULTS.md` — what the pilot found, including why it isn't a valid cost comparison
2. `../protocols/task-1-rerun.md` — the redesign that fixes it
3. `task-2/README.md` — the setup, the planted error, and the predictions, all written before any run

## The two tasks are deliberately opposite

**Task 1 is input-heavy.** Cost lives in reading data and re-sending it every
turn — one run logged 899k cache-read tokens against 23k output. It's ambiguous
work with no single right answer.

**Task 2 is output-heavy.** ~3k tokens in, and nearly all the cost is
*generating* the deck. Output tokens are the expensive class, so this is where
model tier should show up if it shows up anywhere. The job is bounded and
largely mechanical.

Running both is how you find out whether "use a cheaper model" is good advice or
bad advice, instead of guessing — the answer is probably different for each.

## Reproducibility

**Task 2 is fully reproducible.** The source document, the prompts, the answer
key, and the grader are all here. You need an API key and nothing else.

**Task 1 is not.** It queries a private analytics project, so you can read the
outputs and the method but you can't re-run it. That's a real limitation and
it's the main reason task 2 is built the way it is — a benchmark nobody else can
run is a demo, not a benchmark.

## A note on task-1's transcripts

`task-1/raw/` holds the unedited session logs. Two scrubs were applied before
publishing: a town name and a truncated identifier that together described one
identifiable user's behaviour over 12 days. Replaced with `[TOWN-GB]` and
`[ID-N]`. Nothing else was altered — including the parts where the runs got
things wrong, which is most of the value.
