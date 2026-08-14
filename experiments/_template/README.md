# Task N — <one line: what job is being done>

**The question:** <what this settles that FINDINGS.md doesn't already>

## The setup

- **Source:** `fixture/<file>` — <what it is, where it came from>
- **Job:** <the output>, one prompt: `prompts/task.txt`
- **Arms:** <table>  · **Reps:** n=<10+>  · **Est. cost:** $<x>

## The answer key — written before any run

**Should appear:** <...>
**Should not appear:** <...>

## Grading — three questions, by eye

1. Does it work?
2. How did it handle the defect? (`caught` / `silent` / `repeated`)
3. Would you ship it? `favorite` / `acceptable` / `unusable`

Record in `runs/grades.csv` as `run_id,verdict,note`.
**Headline metric: cost per acceptable result.**

## Running it

```bash
./run.sh 1                                  # smoke test FIRST
./run.sh
python3 ../../scripts/extract-runs.py runs
```

## Predictions, written before running

1. <...>   2. <...>   3. <...>

## Caveats

<n, single grader, one fixture, anything else that limits the claim>
