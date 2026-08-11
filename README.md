# cost-per-turn

Measure what your agent work actually costs.

Claude Code has been writing per-turn token usage to disk for every session you
have ever run. `analyze-history.py` reads those transcripts, prices each turn
against a date-stamped price sheet, and gives you a baseline — cost per turn
across a session, your real cache hit rate, and spend grouped by repo.

No new instrumentation. No account linking. Nothing leaves your machine.

```bash
python3 analyze-history.py --list-repos          # see what's on disk
python3 analyze-history.py --repo my-project     # analyse just that repo
```

Python 3.10+, standard library only.

## Start here: put a cost meter in your terminal

Before analysing anything, make the number visible while you work. Claude Code
has a built-in **status line** — it runs a command you specify, pipes it JSON
about the current session, and prints whatever your command returns at the
bottom of the terminal.

`statusline.py` in this repo is a ready-made one:

```
📁 widget-shop │ ⏱ 15m 32s │ ▲ +118 -40 │ ◔ 380k/1000k ▓▓▓░░░░░ 38% │ $2.47 │ 5h ▓░░░░░░░ 22% │ 7d ▓▓▓▓░░░░ 61% │ ◆ Opus 5
```

Repo · session duration · lines changed · context used · **session cost** ·
5-hour and 7-day rate-limit bars · model. Cost turns yellow at $1 and red at
$5; context and limit bars turn yellow at 70% and red at 90%.

Install:

```bash
cp statusline.py ~/.claude/statusline.py
```

Then add this to `~/.claude/settings.json` (use the absolute path — `~` is not
expanded in the command string):

```json
{
  "statusLine": {
    "type": "command",
    "command": "python3 /Users/YOU/.claude/statusline.py"
  }
}
```

Start a new session and the line appears. Test it without Claude Code by piping
it a payload:

```bash
echo '{"workspace":{"current_dir":"/tmp/demo"},"cost":{"total_cost_usd":2.47},
"model":{"display_name":"Opus 5"}}' | python3 statusline.py
```

The minimum useful version is four lines — everything else is decoration:

```python
import json, sys, os
d = json.load(sys.stdin)
print(f"{os.path.basename(d.get('workspace',{}).get('current_dir',''))} "
      f"· ${(d.get('cost') or {}).get('total_cost_usd') or 0:.2f}")
```

**What it shows you is per-session, live, and gone when the session ends.** That
is exactly the gap `analyze-history.py` fills — the status line is the gauge,
the script is the record.

## What you get

```
1. COST PER TURN ACROSS A LONG SESSION  (the curve)
   turns        $/turn   ctx tokens
      1-17      0.3180       98,412   ###########.................
     ...
    186-202     0.8298      381,650   ############################

2. CACHE HIT RATE
   overall            95.85%

3. COST BY REPO
   repo                        cost  sess  turns   $/turn   cache
   ...
```

Plus two CSVs in `out/`:

| file | one row per | use it for |
| --- | --- | --- |
| `sessions.csv` | session | totals, wall clock, per-session cache hit rate |
| `turns.csv` | API request | plotting the cost curve; nothing reads it yet |

## The `--repo` filter is required

Not an option — a required argument. Transcripts on a working machine mix
personal projects with whatever else you have opened Claude Code in, and a
cost report is the kind of artifact that gets pasted into a blog post. Making
inclusion explicit means shipping the wrong sessions somewhere takes a
deliberate act rather than a forgotten flag.

`--list-repos` prints repo names and session counts only — no tokens, no costs,
no content — so you can choose a filter without reading anything into the CSVs.

**`out/` is gitignored, and so is every CSV.** The script is the thing worth
publishing; the data never is.

## Prices live in `prices.json`, never in the script

Every historical cost number is only meaningful against a known price sheet, so
the sheet is a separate, date-stamped file. To reprice history against different
rates, copy it, edit it, and pass `--prices`.

Two things the sheet gets right that are easy to get wrong:

- **Cache writes have two rates, not one.** The 5-minute TTL bills at 1.25x the
  model's input rate and the 1-hour TTL at 2x. Claude Code uses both in the same
  session, so `cache_creation_input_tokens` must be split on
  `usage.cache_creation.ephemeral_{1h,5m}_input_tokens`. On real data the 1-hour
  writes alone were 31% of total spend — pricing them at the 5m rate understates
  the bill badly.
- **Model is read per message, not per session.** Sessions switch models
  mid-way, and pricing has to follow the model that actually served each turn.

If a model appears in a transcript but not in the sheet, its turns are counted,
priced at zero, and named in the output — never silently dropped.

## The one thing you must not do: sum the JSONL lines

Claude Code writes **one line per content block** of an assistant message — the
thinking block, the text block, and each `tool_use` block are separate lines —
and repeats the *identical* `message.usage` on every one of them. Summing
assistant lines therefore counts the same API response two to six times.

On one real history: 14,400 assistant lines carrying usage, but only 5,713
actual API requests. Naive summing inflated `cache_creation_input_tokens` by
**5.75x** and output tokens by **3.31x**.

`message.id` is the API response id, so it is the correct unit of billing. This
script deduplicates on it. If you write your own parser, do the same — this is
the single easiest way to produce a confidently wrong number.

Two related shapes worth knowing:

- **Subagent transcripts** live at `<project>/<session-id>/subagents/*.jsonl`
  and carry the *parent* session's id. They are real spend on that session. A
  one-level glob misses them entirely; a recursive glob that treats each file
  as its own session mis-attributes them. Here they are folded into the parent
  and flagged with `is_sidechain`.
- **`<synthetic>` model lines** are locally generated and carry an all-zero
  usage block. Priced at zero, counted separately, so turn counts stay honest.

## Running it on a clean machine

A synthetic fixture ships with the repo so you can run the whole thing without
any session history of your own:

```bash
python3 analyze-history.py --projects-dir tests/fixtures/projects \
        --repo widget-shop --repo note-taker
```

The fixture reproduces every awkward shape above on purpose — repeated usage
across content blocks, both cache TTLs in one session, a model switch mid-run, a
nested subagent transcript, a `<synthetic>` line, and non-assistant lines with
no usage at all. Regenerate it deterministically with
`python3 tests/make_fixture.py`.

## Caveats

- **Machine-scoped.** Transcripts are per-machine. Run it on each machine and
  merge on `session_id`.
- **List prices, not your bill.** If the sessions ran under a Claude
  subscription plan rather than metered API billing, these figures are
  *equivalent API cost* — the right number for comparing configurations against
  each other, not the amount anyone charged you. Say which one you mean when
  publishing.
- **Turn = one API request**, not one thing you typed. A single prompt usually
  costs several turns.

## Scope

This is step one of a larger rig: establish a baseline from history that already
exists, before optimising anything. The experiment runner, the pass/fail
grading, and the analytics pipeline are deliberately not built yet — a
half-built harness is an invitation to skip the baseline.
