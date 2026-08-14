#!/usr/bin/env bash
# Task 4, effort sweep — arm O, and the price ladder task 4 was missing.
#
# Reuses task 4's fixture, prompt, answer key and scorer UNCHANGED (key.sh and
# score.sh here are symlinks to the parent), so these runs are directly
# comparable to the 60 in ../runs and the two batches can be pooled.
#
#   ./run.sh 1        smoke test, one per cell (9 runs) — ALWAYS do this first
#   ./run.sh          180 runs (20 per cell)
# Safe to re-run: completed runs are skipped.
#
# THE THREE HIGH-EFFORT CELLS FOR OPUS / SONNET / KIMI ARE NOT REPEATED HERE.
# They already exist as ../runs/c01-c60 at n=20 each. That is the whole reason
# this sweep is cheap: half the grid is already paid for.
set -uo pipefail                 # NOT -e: one bad run must not kill the batch
cd "$(dirname "$0")"

# ── CONFIG ────────────────────────────────────────────────────────────────
REPS_DEFAULT=20
ARTIFACT="action-items.md"
PROMPT_FILE="../prompts/action-items.txt"
FIXTURE="../fixture/call-notes.md"

# label : openrouter model : thinking level
#
# EFFORT IS COMPARED WITHIN A MODEL, NEVER ACROSS ONE.
# pi's --thinking maps to a different mechanism per vendor (Anthropic's
# thinking budget, OpenAI's reasoning_effort, whatever Moonshot does). Pooling
# "low effort" across vendors would be meaningless. Same model, same fixture,
# same prompt, only the level changes — that comparison is clean, and it is the
# only effort comparison this sweep makes.
CELLS=(
  "opus-low:anthropic/claude-opus-5:low"          # pairs with ../runs opus  (high)
  "sonnet-low:anthropic/claude-sonnet-5:low"      # pairs with ../runs sonnet(high)
  "kimi-low:moonshotai/kimi-k3:low"               # pairs with ../runs kimi  (high)
  "haiku-high:anthropic/claude-haiku-4.5:high"    # completes the Anthropic ladder
  "haiku-low:anthropic/claude-haiku-4.5:low"
  "mini-high:openai/gpt-5.4-mini:high"            # cross-vendor, price-matched to haiku
  "mini-low:openai/gpt-5.4-mini:low"
  "nano-high:openai/gpt-5.4-nano:high"            # the floor — 20x below opus
  "nano-low:openai/gpt-5.4-nano:low"
)
# ──────────────────────────────────────────────────────────────────────────

N=${1:-$REPS_DEFAULT}
PROMPT="$(cat "$PROMPT_FILE")"
mkdir -p runs
{ echo "date:         $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "pi:           $(pi --version 2>&1 | head -1)"
  echo "reps_per_cell: $N"
  echo "prompt_sha:   $(shasum -a 256 "$PROMPT_FILE" | cut -c1-16)"
  echo "fixture_sha:  $(shasum -a 256 "$FIXTURE" | cut -c1-16)"
  echo "key_sha:      $(shasum -a 256 key.sh | cut -c1-16)"
  echo "pairs_with:   ../runs (opus/sonnet/kimi at --thinking high, n=20 each)"
} > runs/meta.txt
cat runs/meta.txt; echo
echo "run_id,arm,harness,model,effort" > runs/key.csv

ok=0; skip=0; fail=0; i=0
for rep in $(seq 1 "$N"); do
  for spec in "${CELLS[@]}"; do              # interleaved, so drift hits every cell
    IFS=: read -r label model think <<< "$spec"
    i=$((i+1)); id=$(printf "e%03d" $i); d="runs/$id"
    echo "$id,$label,pi,${label%-*},$think" >> runs/key.csv
    if [ -s "$d/$ARTIFACT" ] && [ -s "$d/run.jsonl" ]; then
      echo "[$id] already done, skipping"; skip=$((skip+1)); continue
    fi
    mkdir -p "$d"; cp "$FIXTURE" "$d/"
    printf "[%s] %-11s (rep %s) ... " "$id" "$label" "$rep"
    ( cd "$d" && pi -p --mode json --no-session --no-context-files --no-skills \
        --no-extensions --provider openrouter --model "$model" --thinking "$think" \
        "$PROMPT" < /dev/null > run.jsonl 2> run.err )   # </dev/null or it stalls on stdin
    if [ -s "$d/$ARTIFACT" ]; then echo "ok"; ok=$((ok+1))
    else echo "NO ARTIFACT — see $d/run.err"; fail=$((fail+1)); fi
  done
done
echo; echo "$ok ok · $skip skipped · $fail missing $ARTIFACT"
echo "Costs:  python3 ../../../scripts/extract-runs.py runs"
echo "Score:  ./score.sh"
