# Task 4 · local model — arm Q

**The question:** task 4's finding is that model tier is a cliff, not a slope,
and price isn't the axis — Sonnet 20/20, Opus 19/20, Kimi 9/20, Haiku 1/20,
GPT-5.4-mini 2/20, nano 0/20 (shippable, high effort). **Which side of the cliff
does a 30B model running on a laptop land on?**

Every other row in the grid is priced in dollars. This one changes the
currency: marginal cost is $0.00, and the bill is paid in wall-clock, hardware
you already own, and a machine you can't use for anything else while it runs.

## The model

**Muse Glimmer** — Meta Superintelligence Labs, released 2026-08-10. 30B dense,
Apache 2.0, 128K context, "purpose-built for autonomous agentic tasks on
consumer hardware." Controllable reasoning: `low` / `medium` / `high` / `xhigh`.

Run through **Ollama's MLX engine** as `muse-glimmer:30b-mlx` (21 GB on disk;
it fit, and ran at 100% GPU — see `runs/meta.txt`). The GGUF build
`muse-glimmer:30b` (18 GB) was the fallback and was not needed.

**Results: [`RESULTS.md`](RESULTS.md).**

## The machine — publish this beside every number

| | |
| --- | --- |
| model host | **2021 MacBook Pro 14", Apple M1 Pro** (8-core: 6P/2E), **32 GB** unified memory, macOS 26.3.1 |
| runtime | **Ollama 0.32.13**, MLX engine, `muse-glimmer:30b-mlx` = 32.3B params, **nvfp4**, 21 GB; context slot 32,768; DFlash on |
| harness host | M3 Pro (36 GB) — runs pi 0.84.1 and the tools, same as every other cell |
| link | SSH tunnel, loopback to loopback; adds milliseconds, never seconds |
| also on the box | the always-on Discord channel agent (`claude`, ~0.9 GB) — left running; noted here so the wall-clock isn't read as a clean-room number |

32 GB is the floor for a 30B model at this quant, and it is exactly the floor
for Ollama's MLX engine. **A reader on 16 GB cannot reproduce this row.** Every
other row in the table needs only an API key. That asymmetry is part of the
finding, not a footnote.

## Protocol — matched to task 4 exactly, or the cell can't sit in the table

- **n=20**, pre-committed. Not the n=3 used for other arms: the cliff finding
  rests on 20 runs per cell.
- **Same fixture, same prompt, same key, same scorer.** `key.sh` and `score.sh`
  are symlinks to the parent. Nothing is re-prompted or softened for the local
  model.
- **`--thinking high`**, matching the main table. A `low` cell is optional and
  only if the smoke test says there's time; effort is compared within a model,
  never across.
- **Fresh context per run.** `pi -p --no-session`, new run directory each time.
- **Strictly serial.** One local model saturates the machine; the cloud cells
  ran concurrently. So the batch's wall-clock is 20× the per-run number, and
  that is itself one of the two things this arm exists to say.
- **The model is warmed before run 1** (`/api/generate` with no prompt) so cold
  load isn't inside any run's wall-clock. Cold-load time is printed by `run.sh`
  and reported separately.
- **Graded blind, mechanically**, by the same `score.sh`. Shippable = recall
  5/5 and ≤1 `unassigned` — the repaired rule from the effort sweep, applied
  unchanged.

## What's new to capture

| field | where | note |
| --- | --- | --- |
| shippable / 20 | `scores.csv` | the cliff answer |
| wall-clock per run | `runs-extracted.csv` | **the point of this arm** — cloud cells ran 5–38 s median |
| cold-load time | `run.sh` output | reported once, separately |
| tokens/s | Ollama server log on the M1 (`~/Library/Logs/ollama.err.log`, `print_timing` lines) | optional colour |
| machine / RAM / quant / engine | this file + `meta.txt` | published beside the number |
| cost_usd | `$0.00` | pi's models.json prices the model at zero |

## Predictions — written before run 1

Committed 2026-08-16, before the smoke test.

1. **Shippable out of 20 — Aaron: "similar output to Kimi", i.e. ~9/20.** The
   three publishable outcomes were ~20 (matches Sonnet — the headline of the
   post if it happens), ~9 (confirms the cliff and adds a local axis to it),
   ~1 (kills "just run it locally" as advice). Aaron's call is the middle one.
2. **Per-run wall-clock — Claude's estimate: 3–5 min**, against Sonnet's 19 s
   and Kimi's 38 s. 30B dense at this quant on an M1 Pro should generate at
   roughly 10–20 tok/s with DFlash; `high` reasoning adds a thinking budget on
   top of a ~5k-token prefix.
3. **Failure mode if it fails — Claude's guess: Kimi's.** Misses A4 (the two
   moments eleven minutes apart) and A5 (the buried tangent) rather than
   over-listing or dropping owners.

## Setup (once)

```bash
# M1: Ollama ≥ 0.32.7 (MLX + DFlash), then the model
ollama pull muse-glimmer:30b-mlx

# M3: pi's ~/.pi/agent/models.json has an `ollama` provider pointing at
# http://127.0.0.1:11434/v1 with muse-glimmer:30b-mlx priced at $0.
# Open the tunnel, then run from this directory:
ssh -f -N -L 11434:127.0.0.1:11434 cos@cos-m1
./run.sh 1                     # smoke test — time it before committing to 20
nohup caffeinate -i ./run.sh > batch.log 2>&1 &
python3 ../../../scripts/extract-runs.py runs
./score.sh
```
