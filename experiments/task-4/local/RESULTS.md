# Task 4 · local model — results

**20 runs · $0.00 · 2.9 hours of wall-clock on a 2021 M1 Pro · 0/20 shippable**

Same fixture, prompt, key and scorer as the other 240 task-4 runs
(`key.sh`/`score.sh` are symlinks to the parent). Pooled into
`experiments/all-runs.csv` as task `4-local`, model `glimmer`.

## The row

| model | $/M in→out | effort | pre-reg 5/5 | **shippable** | median $ | median wall | $/shippable |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Sonnet 5 | 2 → 10 | high | 20/20 | **20/20** | $0.0252 | 17 s | $0.026 |
| Opus 5 | 5 → 25 | high | 20/20 | 19/20 | $0.0578 | 13 s | $0.062 |
| Kimi K3 | 3 → 15 | high | 9/20 | 9/20 | $0.0426 | 60 s | $0.098 |
| Haiku 4.5 | 1 → 5 | high | 4/20 | 1/20 | $0.0112 | 5 s | $0.224 |
| **Muse Glimmer 30B, local** | **0 → 0** | high | **0/20** | **0/20** | **$0.00** | **418 s** (7 min) | **—** |

Wall-clock is the extractor's first-to-last-message span, the same unit as
every other cell. End-to-end as the runner measured it (pi startup + the last
turn's generation) was **median 483 s, min 361 s, max 821 s**; the whole batch
took **2 h 51 min** serial. Cold load, excluded from every run: 28 s.

## 1. It landed *below* the cliff — on Haiku's side, not Kimi's

Aaron's prediction on record was "similar output to Kimi", ~9/20. The result
is 0/20: every run failed the shippable rule. On the cliff question this arm
was built to answer, a 30B model on a laptop is on the far side of it.

## 2. But the failure is unlike anything else in the grid — and it's the finding

**All 20 runs listed exactly the same three items: A1, A2 and A5.** Never A3,
never A4, never a distractor, never a dropped owner. `listed=3 · recall 3/5 ·
surplus=0 · unassigned=0`, twenty times out of twenty. Not one line in 60 was
wrong.

That is not determinism — the model ships at temperature 1 and the twenty
files have 15 distinct wordings and orderings. It is a **stable rule**: the
model extracts *explicit* commitments ("I'll send X Thursday") and refuses
*implied* ones. The thinking traces show it:

- **A3 (the sandbox, owner never named) — considered and rejected in 20/20
  runs.** *"'we can get a sandbox tenant spun up' — is that an action? Could be
  offer. Not commit."*
- **A4 (`plan.changed`, obligated by a decision eleven minutes later) —
  considered in 13/20, rejected every time.** *"'we'd have to add plan.changed
  to the event catalog' — maybe action for Marcus? Not explicit."*

So this is not a comprehension failure. The model read the notes closely
enough to find A5 — the tier-4 item, buried in small talk before the call
started, which Kimi missed on 11 of 20 runs — every single time. It found A3
and A4 too. It then applied a threshold ("only if someone says *I will*") that
is defensible in the abstract and wrong for this job, because a PM who sends
that list has silently dropped two things the other side is now expecting.

Compare the other failures in the grid:

| model | how it failed | pattern |
| --- | --- | --- |
| Kimi K3 (9/20) | missed items, but *different* items on different runs; sometimes listed 5 wrong ones | inconsistent recall |
| Haiku 4.5 (1/20) | 5/5 recall on some runs, but dropped the owners | format/ownership |
| GPT-5.4-mini/nano | over- and under-listed, fell for distractors | noise |
| **Glimmer 30B (0/20)** | **same 3 items every time, all correct, 2 always missing** | **precise, capped** |

Prediction 3 was therefore half right: it missed A3 and A4 as guessed, but not
"like Kimi" — Kimi's misses were scattered; these are systematic.

**The practical reading:** this is the one model in the grid whose output you
could trust *as far as it goes*. Everything it wrote was true. It just stops at
the literal, and no amount of reruns changes that — 20 reps at temperature 1
never once crossed the line. Reruns fix noise; they don't fix a rule.

## 3. What "free" cost

- **7 minutes per run** vs 17 s for Sonnet — **~25×**. Twenty runs took nearly
  three hours because a local model is strictly serial; the cloud cells ran
  concurrently.
- **The machine.** 21 GB resident on a 32 GB box; macOS was compressing memory
  and using ~1 GB of swap throughout. Generation ran ~8 tok/s. That box was
  unusable for anything else for the afternoon — which is fine for an
  always-on Mac and not fine for a laptop you work on.
- **A hardware gate no other row has.** 32 GB unified memory is Ollama's floor
  for the MLX engine, and 21 GB is the model. A 16 GB machine cannot run this
  cell at all. Every other row needs an API key.
- **Sonnet's whole 20-run cell cost $0.50.** The 2.9 hours of M1 time here
  bought a worse answer than fifty cents.

## 4. Predictions, scored

| # | prediction | outcome |
| --- | --- | --- |
| 1 | ~9/20, "similar to Kimi" (Aaron) | **wrong — 0/20.** Below the cliff, not on it |
| 2 | 3–5 min per run (Claude) | **wrong — 7 min median span, 8 min end-to-end.** ~8 tok/s under memory pressure, plus 5 round-trips of `high` thinking |
| 3 | fails like Kimi: misses A4/A5 (Claude) | **half.** Missed A4 — but also A3, never A5, and systematically rather than noisily |

## The machine, as run

| | |
| --- | --- |
| model host | MacBook Pro 14" 2021, **Apple M1 Pro** (6P+2E), **32 GB**, macOS 26.3.1 |
| runtime | **Ollama 0.32.13**, MLX engine, `muse-glimmer:30b-mlx` — 32.3B params, **nvfp4** quant, 21 GB, safetensors; context slot 32,768; DFlash on (`draft_num_predict 15`); model defaults temp 1 / top_k 64 / top_p 0.95 |
| harness | pi 0.84.1 on the M3, `--provider ollama --thinking high`, tools executing on the M3 exactly as for every cloud cell; SSH tunnel to the M1's loopback Ollama |
| also running on the M1 | the always-on Discord channel agent (`claude`, ~0.9 GB); otherwise idle, clamshell |
| memory during the batch | 21.3 GB wired to the GPU; compressor active; ~1.1 GB swap |

## Caveats

- **One local model, one quant, one machine.** A 36 GB+ box would swap less
  and run faster; a different 30B (Qwen 3.6-27B) might draw the
  explicit/implied line elsewhere. This row says "a current, purpose-built 30B
  agent model on the most common 32 GB Mac", not "local models."
- **`high` only.** Glimmer also has `xhigh`; the grid held effort at `high`
  and so did this. Whether `xhigh` crosses the implied-commitment line is a
  reasonable one-cell follow-up (~3 more hours).
- **The prompt was not tuned for the model**, by design. "Include implied
  commitments" in the prompt would very likely lift recall — and would break
  comparability with the other 240 runs. That is the follow-up, not the cell.
- **Wall-clock includes tunnel latency** — milliseconds per request, invisible
  against a 7-minute run.
