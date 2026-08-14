# Reading `runs-extracted.csv`

One row per run, produced by `scripts/extract-runs.py` from the raw session
logs. Ordered left-to-right as: what ran → what it cost → how long → how much
work it did → the raw token detail.

| column | what it is |
| --- | --- |
| `run_id` | Matches the folder in `runs/` and the row in `key.csv`. Opaque on purpose so decks can be graded without seeing the config. |
| `arm` | Which configuration this run was, merged from `key.csv` |
| `harness` | `claude-code` or `pi` |
| `model` | **Read from the session log, not from the run label.** If a run silently fell back to a different model, you see it here. Two values joined by `+` means the model changed mid-session. |
| `verdict` | Your quality call, merged from `grades.csv` — `favorite` / `acceptable` / `unusable` |
| `review_note` | Why, in your words. Blank where nothing needed saying. |
| `cost_usd` | What the run actually cost. Claude Code reports this directly; for pi it's the sum of per-message costs from the provider. |
| `wall_clock` | Human-readable duration, e.g. `11m 27s` |
| `wall_clock_s` | Same thing in seconds — use this one for math |
| `round_trips` | **Model API calls** (assistant messages). The honest cross-harness "turns" number, derived the same way from both. Cost tracks this more closely than it tracks model price. |
| `tool_calls` | Tool invocations issued across the run |
| `input_tokens` | Fresh input tokens — usually small, because most input is cached |
| `output_tokens` | Generated tokens. The expensive class per-token. |
| `cache_read_tokens` | Context re-sent and read from cache each turn. **Usually the largest number in the row**, and the main reason a long run costs more than a short one. |
| `cache_write_tokens` | Context written into the cache |
| `session_error` | Did the **harness** report a failed session — API error, aborted run? `no` / `yes` / `not reported by pi`. **This says nothing about whether the output was any good.** Quality lives in `grades.csv`. |
| `native_turn_count` | Claude Code's own `num_turns`. Kept only so the gap with `round_trips` is visible rather than mysterious — the two count different things, so **never compare it across harnesses.** Blank for pi. |
| `session_id` | Claude Code's session id, for tracing back to a transcript. Blank for pi. |

## The three files and how they join

| file | holds | when to open it |
| --- | --- | --- |
| `grades.csv` | your verdict + note per `run_id` | **you write this first, while grading** |
| `key.csv` | which arm each `run_id` was | **keep shut until `grades.csv` is written** |
| `runs-extracted.csv` | everything joined — cost, tokens, timing, arm, verdict | after grading |

`extract-runs.py` folds `grades.csv` and `key.csv` into `runs-extracted.csv`
automatically whenever they exist, so one sheet holds the whole experiment and
re-running the extractor never wipes your grading. Both sidecars are optional —
before grading, those columns are simply blank.

Keeping `key.csv` shut until `grades.csv` is written is what makes the grading
blind. The decks themselves carry no config, so it's genuinely blind as long as
you don't peek.

## The two numbers that matter most

**`cost_usd ÷ round_trips`** — separates "efficient" from "did less." On an
open-ended task a cheap run is often cheap because it stopped early, not because
it was better at the job.

**Cost per *acceptable* result**, not cost per run — total arm spend divided by
the number of outputs you'd actually use. On task 1 those two numbers were ~7x
apart. On task 2, three arms with identical hit rates ranged from $0.23 to
$2.75 per usable deck.
