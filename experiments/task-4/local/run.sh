#!/usr/bin/env bash
# Task 4, local model — arm Q. One added cell on task 4's fixture: a 30B model
# running on a laptop, graded by the same key as the other 240 runs.
#
# Reuses task 4's fixture, prompt, answer key and scorer UNCHANGED (key.sh and
# score.sh here are symlinks to the parent), so these runs pool with ../runs and
# ../effort-sweep/runs. The harness is the same pi binary and flags; the ONLY
# difference is --provider ollama, which points at a local Ollama server.
#
# Topology used for the published numbers: pi runs on the M3 (same as every
# other cell); the model runs on the M1 Pro under Ollama, reached over an SSH
# tunnel (ssh -N -L 11434:127.0.0.1:11434 cos@cos-m1). Tools (read/write/bash)
# therefore execute exactly where they did for the cloud cells. Only the model
# endpoint moved.
#
#   ./run.sh 1        smoke test, one run — ALWAYS do this first, and time it
#   ./run.sh          20 runs, serial (a local model can't run in parallel)
# Safe to re-run: completed runs are skipped.
set -uo pipefail                 # NOT -e: one bad run must not kill the batch
cd "$(dirname "$0")"

# ── CONFIG ────────────────────────────────────────────────────────────────
REPS_DEFAULT=20                  # pre-committed, same as every task-4 cell
ARTIFACT="action-items.md"
PROMPT_FILE="../prompts/action-items.txt"
FIXTURE="../fixture/call-notes.md"
OLLAMA_URL="${OLLAMA_URL:-http://127.0.0.1:11434}"

# label : ollama model tag : thinking level
# Muse Glimmer exposes low/medium/high/xhigh reasoning; pi's --thinking maps to
# reasoning_effort on the OpenAI-compatible endpoint. `high` matches the main
# task-4 table (every model there ran at high). Add a *-low cell only if the
# per-run time from the smoke test leaves room — effort is compared within a
# model, never across one (see ../effort-sweep/README.md).
CELLS=(
  "glimmer-high:muse-glimmer:30b-mlx:high"
)
# ──────────────────────────────────────────────────────────────────────────

N=${1:-$REPS_DEFAULT}
PROMPT="$(cat "$PROMPT_FILE")"
mkdir -p runs

# Warm the model so run 1 doesn't pay the cold load inside its wall-clock, and
# pin it in memory for the batch (gaps between runs are seconds; the server
# default keep_alive is 5m, so this is belt-and-braces).
first_model="${CELLS[0]#*:}"; first_model="${first_model%:*}"
printf "warming %s ... " "$first_model"
t0=$(date +%s)
curl -s -m 600 "$OLLAMA_URL/api/generate" -d "{\"model\":\"$first_model\",\"keep_alive\":\"90m\"}" > /dev/null \
  && echo "loaded in $(( $(date +%s) - t0 ))s" || echo "WARM-UP FAILED — is the tunnel up? ($OLLAMA_URL)"

{ echo "date:          $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "pi:            $(pi --version 2>&1 | head -1)"
  echo "ollama:        $(curl -s -m 5 "$OLLAMA_URL/api/version" | sed 's/.*"version":"\([^"]*\)".*/\1/')"
  echo "ollama_ps:     $(curl -s -m 5 "$OLLAMA_URL/api/ps" | tr -d '\n' | cut -c1-400)"
  echo "harness_host:  $(hostname) (pi + tools run here)"
  echo "model_host:    see README.md — hardware/RAM/quant/engine are published beside the number"
  echo "reps_per_cell: $N"
  echo "prompt_sha:    $(shasum -a 256 "$PROMPT_FILE" | cut -c1-16)"
  echo "fixture_sha:   $(shasum -a 256 "$FIXTURE" | cut -c1-16)"
  echo "key_sha:       $(shasum -a 256 key.sh | cut -c1-16)"
  echo "pairs_with:    ../runs and ../effort-sweep/runs (same fixture, prompt, key, scorer)"
} > runs/meta.txt
cat runs/meta.txt; echo
echo "run_id,arm,harness,model,effort" > runs/key.csv

ok=0; skip=0; fail=0; i=0
for rep in $(seq 1 "$N"); do
  for spec in "${CELLS[@]}"; do
    label="${spec%%:*}"; rest="${spec#*:}"; think="${rest##*:}"; model="${rest%:*}"
    i=$((i+1)); id=$(printf "l%02d" $i); d="runs/$id"
    echo "$id,$label,pi,${label%-*},$think" >> runs/key.csv
    if [ -s "$d/$ARTIFACT" ] && [ -s "$d/run.jsonl" ]; then
      echo "[$id] already done, skipping"; skip=$((skip+1)); continue
    fi
    mkdir -p "$d"; cp "$FIXTURE" "$d/"
    printf "[%s] %-12s (rep %s) ... " "$id" "$label" "$rep"
    t0=$(date +%s)
    ( cd "$d" && pi -p --mode json --no-session --no-context-files --no-skills \
        --no-extensions --provider ollama --model "$model" --thinking "$think" \
        "$PROMPT" < /dev/null > run.jsonl 2> run.err )   # </dev/null or it stalls on stdin
    secs=$(( $(date +%s) - t0 ))
    if [ -s "$d/$ARTIFACT" ]; then echo "ok  (${secs}s)"; ok=$((ok+1))
    else echo "NO ARTIFACT after ${secs}s — see $d/run.err"; fail=$((fail+1)); fi
  done
done
echo; echo "$ok ok · $skip skipped · $fail missing $ARTIFACT"
echo "Costs:  python3 ../../../scripts/extract-runs.py runs   (cost will be \$0 — that's the point)"
echo "Score:  ./score.sh"
