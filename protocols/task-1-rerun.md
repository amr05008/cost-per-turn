# T1 rerun — execution protocol

**Status:** ready to run · **Supersedes:** the 2026-08-13 pilot ([[token-efficiency-task1-regrade]]) · **Parent:** [[token-efficiency-experiments]]

31 runs. Fixes the four flaws the pilot exposed: uncontrolled memory, uncontrolled skill loading, a relative date window, and n=3 against within-cell variance that spanned the whole quality scale.

Everything the analysis needs comes out of one JSONL file per run. There is no separate export step.

---

## Phase 0 — setup (once, ~20 min)

### 0.1 Get an Anthropic API key

`--bare` is the flag that makes this experiment controllable: it disables auto-memory, CLAUDE.md discovery, hooks, and plugin sync in one switch. It requires `ANTHROPIC_API_KEY` and will not read the Max/OAuth session.

That's a feature, not a tax — it also puts Claude Code and pi on the same billing basis (real per-token API pricing), which retires the Max-vs-OpenRouter footnote entirely.

```bash
# add to ~/.zshenv on the M3 — never in this repo
export ANTHROPIC_API_KEY=sk-ant-...
```

Verify: `claude --bare -p --model sonnet "say ok"` should return `ok` and not an auth error.

### 0.2 Create the run directory

```bash
mkdir -p ~/repos/glutenornot.com/cost-experiments/t1-rerun/{raw,answers}
cd ~/repos/glutenornot.com/cost-experiments/t1-rerun
```

`raw/` holds `<run_id>.jsonl`. `answers/` is generated. **Do not put arm names in filenames** — that's what makes blind grading possible. The key lives in `key.csv`, which you don't open until grading is done.

### 0.3 Write the prompts to files

Prompts get pasted from a file, never retyped — retyping moves the work and silently changes the experiment.

`prompts/open-api.txt` (arms A, B, C, D):

```
Use the PostHog API key in this project's .env to analyze GlutenOrNot event data for the window 2026-07-14 through 2026-08-13 inclusive. What are your top 3 insights? What 3 action items should I prioritize for further investigation to improve this app?
```

`prompts/open-mcp.txt` (arm E only — one clause differs):

```
Use the PostHog MCP associated with this project to analyze GlutenOrNot event data for the window 2026-07-14 through 2026-08-13 inclusive. What are your top 3 insights? What 3 action items should I prioritize for further investigation to improve this app?
```

**The one change from the pilot: the window is pinned to absolute dates.** The pilot said "last 30 days," so every run analyzed a slightly different dataset (the pilot's runs saw 429–430 scans; the same query today returns 432) and a rerun next month would see something else entirely. Absolute dates make the runs comparable to each other, make the answer key stable, and make the give-repo reproducible by a reader. Everything else is the pilot's wording.

### 0.4 Write the answer key BEFORE running

Non-negotiable, and the lesson the pilot's regrade learned the expensive way — a key derived after seeing outputs isn't independent of them.

Create `answer-key.md` and commit it with a timestamp *before* run 1. It already exists in draft form in [[token-efficiency-task1-regrade]]; move the ground-truth section into it and add the grading rule:

- **Robust discriminator (carries the grade):** `ocr_chars = 0` on 34 of 35 OCR failures; median 725 chars on successes. Needs no exclusions and no judgment calls.
- **Fragile discriminator (supporting note only):** the `image_kb` gradient. It moves depending on which identities you exclude — do not let it decide a grade.
- **Grades:** ✅ reaches "framing, not blur" and checks the population before trusting a correlation · 🟡 defensible action, contaminated or unstated reasoning · 🔴 recommends a size/blur gate, or asserts a size threshold as justification.
- Pre-register the falsifier: *if arms disagree by less than the within-arm spread, the answer is "no measurable difference," and that gets published as-is.*

### 0.5 Snapshot the memory store (arm D only)

Arm D deliberately runs with the full context stack, so it can both read and **write** memory. In the pilot a run wrote memories mid-batch, which means later runs weren't independent.

```bash
MEM=~/.claude/projects/-Users-aaronroy-repos-glutenornot-com/memory
cp -R "$MEM" /tmp/mem-snapshot
# then between every arm-D rep:
rm -rf "$MEM" && cp -R /tmp/mem-snapshot "$MEM"
```

Arms A/B/C/E use `--bare` or pi, so memory is off and no snapshot is needed.

---

## Phase 1 — the run matrix (31 runs)

| Arm | Harness | Model | Context stack | Tools | n |
| --- | --- | --- | --- | --- | --- |
| **A** | Claude Code | Opus 5 | bare | API key | 7 |
| **B** | pi | Opus 5 | bare | API key | 7 |
| **C** | pi | Kimi K3 | bare | API key | 7 |
| **D** | Claude Code | Opus 5 | **full** (memory + CLAUDE.md + skills) | API key | 5 |
| **E** | Claude Code | Opus 5 | bare | **PostHog MCP** | 5 |

What each comparison buys:

- **A vs B** — harness effect. Same model, same tools, same (absent) context stack. This is the clean number the pilot never had.
- **B vs C** — model effect, same harness, same tools.
- **A vs D** — **the context-stack lever, and the pilot's real finding.** Both pilot greens had memory recall; one credited a stored note naming the contaminated profiles outright. Nine runs without memory produced zero greens. This arm tests whether that holds.
- **A vs E** — MCP vs raw API key. Arm F's core question.

**Interleave the arms rather than running A×7 then B×7.** Round-robin A,B,C,A,B,C… so any drift affects all arms equally. Vary nothing else between reps.

### The commands

Claude Code (arms A, E — and D without `--bare`):

```bash
cd ~/repos/glutenornot.com

# Arm A — bare, API key, no MCP
claude --bare -p --model opus --effort high \
  --output-format stream-json --verbose \
  --dangerously-skip-permissions \
  "$(cat prompts/open-api.txt)" \
  > cost-experiments/t1-rerun/raw/r001.jsonl

# Arm D — full context stack (drop --bare)
claude -p --model opus --effort high \
  --output-format stream-json --verbose \
  --dangerously-skip-permissions \
  "$(cat prompts/open-api.txt)" \
  > cost-experiments/t1-rerun/raw/r022.jsonl

# Arm E — bare + PostHog MCP only
claude --bare -p --model opus --effort high \
  --mcp-config ~/.claude/mcp-posthog-only.json \
  --output-format stream-json --verbose \
  --dangerously-skip-permissions \
  "$(cat prompts/open-mcp.txt)" \
  > cost-experiments/t1-rerun/raw/r027.jsonl
```

pi (arms B, C):

```bash
cd ~/repos/glutenornot.com

# Arm B — Opus 5
pi -p --mode json --no-session --no-context-files --no-skills --no-extensions \
  --provider openrouter --model anthropic/claude-opus-5 --thinking high \
  "$(cat prompts/open-api.txt)" \
  > cost-experiments/t1-rerun/raw/r008.jsonl

# Arm C — Kimi K3
pi -p --mode json --no-session --no-context-files --no-skills --no-extensions \
  --provider openrouter --model moonshotai/kimi-k3 --thinking high \
  "$(cat prompts/open-api.txt)" \
  > cost-experiments/t1-rerun/raw/r015.jsonl
```

**On `--dangerously-skip-permissions`:** the task is read-only (query PostHog, read files) and unattended runs otherwise hang on a permission prompt and record a bogus wall-clock. Only acceptable because the task is read-only — do not carry this flag to a task that writes.

**`--no-context-files --no-skills --no-extensions` on pi** is the mirror of `--bare`. Without it pi picks up `AGENTS.md`/`CLAUDE.md` and the comparison is unequal again in the opposite direction.

**Sanity-check run 1 before doing the other 30.** Open the JSONL, confirm it ends with a `result` event (Claude Code) or `turn_end` (pi), and that the model actually reached PostHog rather than erroring on auth.

---

## Phase 2 — capture

There isn't one. `> raw/<run_id>.jsonl` is the capture — the stream already contains every message, tokens by class, per-message cost, tool calls, and the final text.

This replaces the pilot's `/export` to `.txt`, which carried **no usage data at all**. All ten pilot Claude Code runs are permanently blank on tokens because of it.

Log to `key.csv` as you go — and don't open it again until grading is finished:

```csv
run_id,arm,harness,model,context_stack,tools,rep,timestamp
r001,A,claude-code,opus-5,bare,api-key,1,2026-08-14T09:00:00Z
```

---

## Phase 3 — extraction

```bash
python3 ~/repos/vault/projects/scripts/extract-runs.py \
  ~/repos/glutenornot.com/cost-experiments/t1-rerun/raw --debug
```

Produces `runs-extracted.csv` (one row per run) and `answers/<run_id>.md` (the final output, no config attached — this is what you grade).

**Turns, the comparable way.** Claude Code reports `num_turns` and pi counts turns differently, so the two aren't comparable. The script derives the same two metrics from both:

- **`round_trips`** — assistant messages, i.e. model API calls. This is the honest cross-harness "turns" number.
- **`tool_calls`** — `tool_use` blocks issued.

Both are the mediator variable the pilot lacked. On an open-ended task, cost partly measures *how much work the run chose to do* — the pilot's most expensive run was also its best, and its cheapest stopped early. `cost ÷ round_trips` separates "efficient" from "did less," and without it a cost delta can't be interpreted at all.

Run with `--debug` on the first batch to confirm tool-call blocks are being counted (the script prints every content-block type it saw); the block naming differs between harnesses and is worth eyeballing once.

---

## Phase 4 — grading (blind, for real this time)

1. Grade every file in `answers/` against `answer-key.md`. `key.csv` stays closed.
2. Record `grade` + the three sub-scores (`accuracy`, `contamination`, `decision`) in a separate `grades.csv` keyed by `run_id`.
3. **Then** join `grades.csv` + `runs-extracted.csv` + `key.csv`.
4. Report cost per acceptable result, and the full distribution per cell — not the median. Print all reps.

The pilot graded 14/14 ✅ because the criteria ("pulls accurate data, gives logical suggestion") passed anything coherent, including runs that would have shipped the wrong release. The criteria in `answer-key.md` are specific enough to fail things.

---

## What changed vs. the pilot

| | Pilot | Rerun |
| --- | --- | --- |
| Reps per cell | 3 | 7 (5 on satellites) |
| Memory | uncontrolled; one run wrote memories mid-batch | off in core, isolated arm D, restored between reps |
| Skills | auto-loaded, varied run to run at fixed config | off via `--bare` / `--no-skills` |
| CLAUDE.md | loaded on CC, absent on pi | off on both in core |
| Date window | "last 30 days" (relative, drifting) | pinned absolute dates |
| Billing basis | Max vs OpenRouter | API key on both |
| Token capture | none for Claude Code | all four classes, both harnesses |
| Turns / tool calls | not captured | derived identically from both |
| Grading | unblinded, key written afterward | blind, key committed before run 1 |

## Known limits — state these in the writeup

- **n=7 is still small.** A pass-rate difference under ~30 points won't be distinguishable. Pre-registering that as the falsifier is what keeps the result honest.
- **Arm D reintroduces the billing question** if Claude Code prefers the Max session over `ANTHROPIC_API_KEY` when not bare. Check the first arm-D run and footnote whichever it used.
- **`--bare` Claude Code is not the Claude Code anyone runs.** Arm A is the scientifically clean comparison; arm D is the realistic one. Report both and say plainly which is which — that framing is stronger than picking one.
- **One repo, one task.** Nothing here generalizes past "analyze a PostHog dataset" until a second task runs.

## Bonus measurement already in hand

A trivial `claude -p` in the vault (full stack, non-bare) shows a turn-1 prefix of **~51.5k tokens** (27,098 cache-write + 24,422 cache-read). pi's measured turn-1 prefix is **11,001 tokens**.

So the real ratio is **~4.7x, not the ~50x the project file estimated** — Claude Code's ~50k was about right, but pi is 11k rather than "under 1k." Re-measure both properly in `glutenornot.com` with the experiment's exact config before publishing; this is one sample from the wrong directory.
